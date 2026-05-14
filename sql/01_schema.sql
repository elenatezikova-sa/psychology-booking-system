-- =============================================================
-- MindSpace — Маркетплейс психологов
-- База данных: PostgreSQL 16
-- Версия схемы: 2.0
-- Автор: Елена Тезикова (системный аналитик)
-- =============================================================
--
-- Структура схемы (20 таблиц):
--
--   Пользователи и профили
--     users                        — аккаунты всех ролей (клиент / психолог / admin / support)
--     client_profiles              — расширенный профиль клиента
--     psychologist_profiles        — профиль психолога с ценой и рейтингом
--
--   Справочники
--     specializations              — справочник специализаций (тревога, депрессия и т.д.)
--     therapy_methods              — справочник методов терапии (КПТ, EMDR и т.д.)
--     psychologist_specializations — M:N психолог ↔ специализация
--     psychologist_methods         — M:N психолог ↔ метод
--
--   Верификация психологов
--     verification_requests        — заявка на верификацию
--     verification_documents       — документы к заявке (диплом, паспорт и т.д.)
--     verification_log             — журнал действий администратора
--
--   Расписание и бронирования
--     schedule_slots               — слоты доступности психолога
--     bookings                     — бронирование сессии клиентом
--
--   Платежи и выплаты
--     payments                     — платёж по бронированию (54-ФЗ)
--     refunds                      — возврат средств
--     payouts                      — выплата психологу за вычетом комиссии
--
--   Отзывы
--     reviews                      — отзыв клиента после сессии
--     review_replies               — ответ психолога на отзыв
--
--   Коммуникации
--     pre_booking_messages         — чат до бронирования
--     notifications                — уведомления (email / Telegram)
--
--   Споры
--     disputes                     — спор по завершённой сессии
--
-- =============================================================


-- =============================================================
-- ПОЛЬЗОВАТЕЛИ И ПРОФИЛИ
-- =============================================================

CREATE TABLE users (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email            VARCHAR(255) NOT NULL UNIQUE,
    password_hash    VARCHAR(255) NOT NULL,
    -- Роль определяет доступные функции в системе
    role             VARCHAR(20)  NOT NULL CHECK (role IN ('client', 'psychologist', 'admin', 'support')),
    email_confirmed  BOOLEAN NOT NULL DEFAULT FALSE,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    -- Блокировка администратором без удаления аккаунта
    is_blocked       BOOLEAN NOT NULL DEFAULT FALSE,
    -- Мягкое удаление: запись остаётся в БД для истории транзакций
    deleted_at       TIMESTAMP WITH TIME ZONE,
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE client_profiles (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    display_name      VARCHAR(100),
    preferred_format  VARCHAR(20) CHECK (preferred_format IN ('online', 'offline', 'any')),
    timezone          VARCHAR(50),  -- формат IANA, например 'Europe/Moscow'
    notify_email      BOOLEAN NOT NULL DEFAULT TRUE,
    notify_telegram   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE psychologist_profiles (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id              UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name            VARCHAR(255) NOT NULL,
    photo_url            VARCHAR(500),
    bio                  TEXT,
    experience_years     INTEGER CHECK (experience_years >= 0),
    session_duration     INTEGER NOT NULL DEFAULT 50,  -- продолжительность сессии в минутах
    price_rub            NUMERIC(10,2) NOT NULL CHECK (price_rub > 0),
    -- Профиль скрыт из поиска до прохождения верификации
    verification_status  VARCHAR(20) NOT NULL DEFAULT 'pending'
                             CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    -- Пересчитывается триггером после публикации нового отзыва
    avg_rating           NUMERIC(3,2) CHECK (avg_rating >= 1 AND avg_rating <= 5),
    created_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- =============================================================
-- СПРАВОЧНИКИ
-- =============================================================

CREATE TABLE specializations (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE  -- скрытие без удаления
);

CREATE TABLE therapy_methods (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(100) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Составной PK исключает дублирование связей
CREATE TABLE psychologist_specializations (
    psychologist_id   UUID    NOT NULL REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    specialization_id INTEGER NOT NULL REFERENCES specializations(id) ON DELETE CASCADE,
    PRIMARY KEY (psychologist_id, specialization_id)
);

CREATE TABLE psychologist_methods (
    psychologist_id  UUID    NOT NULL REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    method_id        INTEGER NOT NULL REFERENCES therapy_methods(id) ON DELETE CASCADE,
    PRIMARY KEY (psychologist_id, method_id)
);


-- =============================================================
-- ВЕРИФИКАЦИЯ ПСИХОЛОГОВ
-- =============================================================

CREATE TABLE verification_requests (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    psychologist_id  UUID NOT NULL REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    status           VARCHAR(20) NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'approved', 'rejected')),
    -- Счётчик повторных заявок после отказа
    attempt_number   INTEGER NOT NULL DEFAULT 1,
    submitted_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    reviewed_at      TIMESTAMP WITH TIME ZONE,
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE verification_documents (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_request_id  UUID NOT NULL REFERENCES verification_requests(id) ON DELETE CASCADE,
    doc_type                 VARCHAR(30) NOT NULL
                                 CHECK (doc_type IN ('diploma', 'passport', 'tax_status', 'certificate')),
    file_url                 VARCHAR(500) NOT NULL,
    uploaded_at              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Аудит-лог: фиксирует каждое действие администратора по заявке
CREATE TABLE verification_log (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verification_request_id  UUID NOT NULL REFERENCES verification_requests(id) ON DELETE CASCADE,
    admin_id                 UUID NOT NULL REFERENCES users(id),
    action                   VARCHAR(20) NOT NULL CHECK (action IN ('approved', 'rejected', 'commented')),
    comment                  TEXT,
    created_at               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- =============================================================
-- РАСПИСАНИЕ И БРОНИРОВАНИЯ
-- =============================================================

CREATE TABLE schedule_slots (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    psychologist_id  UUID NOT NULL REFERENCES psychologist_profiles(id) ON DELETE CASCADE,
    starts_at        TIMESTAMP WITH TIME ZONE NOT NULL,
    ends_at          TIMESTAMP WITH TIME ZONE NOT NULL,
    -- reserved: слот временно заблокирован на время оплаты (15 мин)
    status           VARCHAR(20) NOT NULL DEFAULT 'available'
                         CHECK (status IN ('available', 'reserved', 'booked', 'blocked')),
    format           VARCHAR(20) NOT NULL CHECK (format IN ('online', 'offline')),
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

CREATE TABLE bookings (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id               UUID NOT NULL REFERENCES users(id),
    psychologist_id         UUID NOT NULL REFERENCES psychologist_profiles(id),
    -- UNIQUE гарантирует: один слот = одно бронирование
    slot_id                 UUID NOT NULL UNIQUE REFERENCES schedule_slots(id),
    -- Цена фиксируется на момент бронирования, не зависит от изменения тарифа
    price_rub               NUMERIC(10,2) NOT NULL CHECK (price_rub > 0),
    status                  VARCHAR(30) NOT NULL DEFAULT 'pending_payment'
                                CHECK (status IN (
                                    'pending_payment',  -- ожидание оплаты
                                    'confirmed',        -- оплачено
                                    'completed',        -- сессия проведена
                                    'cancelled',        -- отменено
                                    'no_show',          -- клиент не явился
                                    'disputed'          -- открыт спор
                                )),
    -- Истечение резервирования: слот освобождается автоматически
    reservation_expires_at  TIMESTAMP WITH TIME ZONE,
    created_at              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- =============================================================
-- ПЛАТЕЖИ И ВЫПЛАТЫ
-- =============================================================

CREATE TABLE payments (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id           UUID NOT NULL REFERENCES bookings(id),
    amount_rub           NUMERIC(10,2) NOT NULL CHECK (amount_rub > 0),
    status               VARCHAR(20) NOT NULL DEFAULT 'pending'
                             CHECK (status IN ('pending', 'succeeded', 'failed', 'refunded')),
    provider_payment_id  VARCHAR(255),  -- ID транзакции на стороне платёжного провайдера
    -- URL фискального чека согласно требованиям 54-ФЗ
    fiscal_receipt_url   VARCHAR(500),
    -- Idempotency key защищает от двойного списания при повторных запросах
    idempotency_key      VARCHAR(255) NOT NULL UNIQUE,
    created_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE refunds (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id  UUID NOT NULL REFERENCES payments(id),
    amount_rub  NUMERIC(10,2) NOT NULL CHECK (amount_rub > 0),
    -- Процент возврата зависит от политики отмены (100% / 50% / 0%)
    refund_pct  INTEGER NOT NULL CHECK (refund_pct >= 0 AND refund_pct <= 100),
    reason      VARCHAR(30) NOT NULL
                    CHECK (reason IN ('cancel_early', 'cancel_late', 'psychologist_cancel', 'dispute')),
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE payouts (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    psychologist_id   UUID NOT NULL REFERENCES psychologist_profiles(id),
    booking_id        UUID NOT NULL REFERENCES bookings(id),
    gross_amount      NUMERIC(10,2) NOT NULL CHECK (gross_amount > 0),
    commission_amount NUMERIC(10,2) NOT NULL CHECK (commission_amount >= 0),
    -- net_amount = gross_amount - commission_amount
    net_amount        NUMERIC(10,2) NOT NULL CHECK (net_amount >= 0),
    scheduled_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    processed_at      TIMESTAMP WITH TIME ZONE,  -- NULL до момента фактической выплаты
    created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- =============================================================
-- ОТЗЫВЫ
-- =============================================================

CREATE TABLE reviews (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- UNIQUE: один отзыв на одно бронирование
    booking_id         UUID NOT NULL UNIQUE REFERENCES bookings(id),
    client_id          UUID NOT NULL REFERENCES users(id),
    psychologist_id    UUID NOT NULL REFERENCES psychologist_profiles(id),
    rating             INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text               TEXT,
    -- Отзыв виден в профиле только после модерации
    moderation_status  VARCHAR(20) NOT NULL DEFAULT 'pending'
                           CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
    published_at       TIMESTAMP WITH TIME ZONE,
    created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE review_replies (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- UNIQUE: психолог может ответить на отзыв только один раз
    review_id        UUID NOT NULL UNIQUE REFERENCES reviews(id) ON DELETE CASCADE,
    psychologist_id  UUID NOT NULL REFERENCES psychologist_profiles(id),
    text             TEXT NOT NULL,
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- =============================================================
-- КОММУНИКАЦИИ
-- =============================================================

-- Чат между клиентом и психологом до оформления бронирования
CREATE TABLE pre_booking_messages (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id        UUID NOT NULL REFERENCES users(id),
    psychologist_id  UUID NOT NULL REFERENCES psychologist_profiles(id),
    -- sender_id указывает кто написал: клиент или психолог
    sender_id        UUID NOT NULL REFERENCES users(id),
    text             TEXT NOT NULL,
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    type        VARCHAR(30) NOT NULL
                    CHECK (type IN (
                        'booking_confirmed',
                        'reminder_24h',
                        'reminder_1h',
                        'payout_done',
                        'dispute_update'
                    )),
    channel     VARCHAR(20) NOT NULL CHECK (channel IN ('email', 'telegram')),
    status      VARCHAR(20) NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'sent', 'failed')),
    -- Дополнительные данные для шаблона уведомления в формате JSON
    payload     JSONB,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    sent_at     TIMESTAMP WITH TIME ZONE
);


-- =============================================================
-- СПОРЫ
-- =============================================================

CREATE TABLE disputes (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id   UUID NOT NULL REFERENCES bookings(id),
    opened_by    UUID NOT NULL REFERENCES users(id),
    status       VARCHAR(20) NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open', 'in_review', 'resolved', 'closed')),
    reason       TEXT,
    -- Решение администратора с обоснованием
    resolution   TEXT,
    opened_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    resolved_at  TIMESTAMP WITH TIME ZONE,
    created_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


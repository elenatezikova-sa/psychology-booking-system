-- =============================================================
-- MindSpace — Аналитические запросы
-- =============================================================
--
-- Разделы:
--   1. Пользователи и регистрация
--   2. Верификация психологов
--   3. Расписание и бронирования
--   4. Финансы и выплаты
--   5. Отзывы и репутация
--   6. Коммуникации и уведомления
--   7. Споры
--   8. Сводные дашборд-метрики
--   9. Сложные аналитические запросы
-- =============================================================


-- =============================================================
-- 1. ПОЛЬЗОВАТЕЛИ И РЕГИСТРАЦИЯ
-- =============================================================

-- Количество пользователей по ролям
SELECT
    role,
    COUNT(*)                                            AS total,
    COUNT(*) FILTER (WHERE email_confirmed = TRUE)      AS email_confirmed,
    COUNT(*) FILTER (WHERE is_blocked = TRUE)           AS blocked,
    COUNT(*) FILTER (WHERE deleted_at IS NOT NULL)      AS deleted
FROM users
GROUP BY role
ORDER BY total DESC;


-- Новые регистрации по дням за последние 30 дней
SELECT
    DATE(created_at)    AS registration_date,
    role,
    COUNT(*)            AS new_users
FROM users
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at), role
ORDER BY registration_date DESC, role;


-- Клиенты с неподтверждённым email (требуют повторной отправки письма)
SELECT
    u.email,
    u.created_at,
    cp.display_name,
    cp.notify_telegram
FROM users u
JOIN client_profiles cp ON cp.user_id = u.id
WHERE u.email_confirmed = FALSE
  AND u.is_active = TRUE
  AND u.deleted_at IS NULL
ORDER BY u.created_at DESC;


-- =============================================================
-- 2. ВЕРИФИКАЦИЯ ПСИХОЛОГОВ
-- =============================================================

-- Воронка верификации: сколько психологов на каждом статусе
SELECT
    verification_status,
    COUNT(*) AS psychologists_count
FROM psychologist_profiles
GROUP BY verification_status;


-- Детальный статус верификации по каждому психологу
SELECT
    pp.full_name,
    pp.verification_status,
    vr.attempt_number,
    vr.status           AS last_request_status,
    vr.submitted_at,
    vr.reviewed_at,
    EXTRACT(DAY FROM (vr.reviewed_at - vr.submitted_at)) AS review_days
FROM psychologist_profiles pp
LEFT JOIN verification_requests vr ON vr.psychologist_id = pp.id
    AND vr.attempt_number = (
        SELECT MAX(attempt_number)
        FROM verification_requests
        WHERE psychologist_id = pp.id
    )
ORDER BY vr.submitted_at DESC;


-- Среднее время рассмотрения заявок на верификацию (в днях)
SELECT
    ROUND(AVG(EXTRACT(DAY FROM (reviewed_at - submitted_at))), 1) AS avg_review_days,
    MIN(EXTRACT(DAY FROM (reviewed_at - submitted_at)))            AS min_days,
    MAX(EXTRACT(DAY FROM (reviewed_at - submitted_at)))            AS max_days
FROM verification_requests
WHERE reviewed_at IS NOT NULL;


-- Психологи с повторными заявками на верификацию
SELECT
    pp.full_name,
    COUNT(vr.id)        AS attempts,
    MAX(vr.submitted_at) AS last_attempt_at
FROM psychologist_profiles pp
JOIN verification_requests vr ON vr.psychologist_id = pp.id
GROUP BY pp.id, pp.full_name
HAVING COUNT(vr.id) > 1
ORDER BY attempts DESC;


-- =============================================================
-- 3. РАСПИСАНИЕ И БРОНИРОВАНИЯ
-- =============================================================

-- Загрузка психологов: количество слотов по статусам
SELECT
    pp.full_name,
    COUNT(ss.id)                                                AS total_slots,
    COUNT(ss.id) FILTER (WHERE ss.status = 'available')        AS available,
    COUNT(ss.id) FILTER (WHERE ss.status = 'booked')           AS booked,
    COUNT(ss.id) FILTER (WHERE ss.status = 'blocked')          AS blocked,
    ROUND(
        COUNT(ss.id) FILTER (WHERE ss.status = 'booked')::NUMERIC
        / NULLIF(COUNT(ss.id), 0) * 100, 1
    )                                                           AS occupancy_pct
FROM psychologist_profiles pp
LEFT JOIN schedule_slots ss ON ss.psychologist_id = pp.id
WHERE pp.verification_status = 'approved'
GROUP BY pp.id, pp.full_name
ORDER BY occupancy_pct DESC NULLS LAST;


-- Воронка бронирований по статусам
SELECT
    status,
    COUNT(*)                        AS bookings_count,
    SUM(price_rub)                  AS total_rub,
    ROUND(AVG(price_rub), 2)        AS avg_price_rub
FROM bookings
GROUP BY status
ORDER BY bookings_count DESC;


-- Бронирования с полной информацией (для операционного контроля)
SELECT
    b.id                            AS booking_id,
    cp.display_name                 AS client_name,
    u_c.email                       AS client_email,
    pp.full_name                    AS psychologist_name,
    ss.starts_at,
    ss.format,
    b.price_rub,
    b.status,
    p.status                        AS payment_status
FROM bookings b
JOIN users u_c              ON u_c.id = b.client_id
JOIN client_profiles cp     ON cp.user_id = u_c.id
JOIN psychologist_profiles pp ON pp.id = b.psychologist_id
JOIN schedule_slots ss      ON ss.id = b.slot_id
LEFT JOIN payments p        ON p.booking_id = b.id
ORDER BY ss.starts_at DESC;


-- Отменённые бронирования: кто отменял и когда
SELECT
    b.id                        AS booking_id,
    cp.display_name             AS client,
    pp.full_name                AS psychologist,
    ss.starts_at                AS session_time,
    b.updated_at                AS cancelled_at,
    r.reason                    AS refund_reason,
    r.refund_pct,
    r.amount_rub                AS refunded_rub
FROM bookings b
JOIN client_profiles cp     ON cp.user_id = b.client_id
JOIN psychologist_profiles pp ON pp.id = b.psychologist_id
JOIN schedule_slots ss      ON ss.id = b.slot_id
LEFT JOIN payments pay      ON pay.booking_id = b.id
LEFT JOIN refunds r         ON r.payment_id = pay.id
WHERE b.status = 'cancelled'
ORDER BY b.updated_at DESC;


-- =============================================================
-- 4. ФИНАНСЫ И ВЫПЛАТЫ
-- =============================================================

-- Выручка платформы по месяцам
SELECT
    DATE_TRUNC('month', p.created_at)   AS month,
    COUNT(p.id)                         AS payments_count,
    SUM(p.amount_rub)                   AS gross_revenue_rub,
    SUM(po.commission_amount)           AS platform_commission_rub,
    SUM(po.net_amount)                  AS paid_to_psychologists_rub
FROM payments p
LEFT JOIN bookings b    ON b.id = p.booking_id
LEFT JOIN payouts po    ON po.booking_id = b.id
WHERE p.status = 'succeeded'
GROUP BY DATE_TRUNC('month', p.created_at)
ORDER BY month DESC;


-- Топ психологов по выручке
SELECT
    pp.full_name,
    COUNT(b.id)             AS completed_sessions,
    SUM(b.price_rub)        AS gross_revenue_rub,
    SUM(po.commission_amount) AS platform_commission_rub,
    SUM(po.net_amount)      AS earned_rub
FROM psychologist_profiles pp
JOIN bookings b     ON b.psychologist_id = pp.id AND b.status = 'completed'
JOIN payouts po     ON po.booking_id = b.id
GROUP BY pp.id, pp.full_name
ORDER BY earned_rub DESC;


-- Возвраты: сумма и причины
SELECT
    r.reason,
    COUNT(*)            AS refunds_count,
    SUM(r.amount_rub)   AS total_refunded_rub,
    AVG(r.refund_pct)   AS avg_refund_pct
FROM refunds r
GROUP BY r.reason
ORDER BY total_refunded_rub DESC;


-- Невыплаченные выплаты (на удержании)
SELECT
    pp.full_name,
    po.gross_amount,
    po.net_amount,
    po.scheduled_at,
    b.status            AS booking_status
FROM payouts po
JOIN psychologist_profiles pp ON pp.id = po.psychologist_id
JOIN bookings b ON b.id = po.booking_id
WHERE po.processed_at IS NULL
ORDER BY po.scheduled_at;


-- =============================================================
-- 5. ОТЗЫВЫ И РЕПУТАЦИЯ
-- =============================================================

-- Рейтинг психологов с детализацией отзывов
SELECT
    pp.full_name,
    pp.avg_rating,
    COUNT(r.id)                                             AS total_reviews,
    COUNT(r.id) FILTER (WHERE r.rating = 5)                 AS five_stars,
    COUNT(r.id) FILTER (WHERE r.rating = 4)                 AS four_stars,
    COUNT(r.id) FILTER (WHERE r.rating <= 3)                AS three_and_below,
    COUNT(rr.id)                                            AS replies_count
FROM psychologist_profiles pp
LEFT JOIN reviews r     ON r.psychologist_id = pp.id AND r.moderation_status = 'approved'
LEFT JOIN review_replies rr ON rr.psychologist_id = pp.id
WHERE pp.verification_status = 'approved'
GROUP BY pp.id, pp.full_name, pp.avg_rating
ORDER BY pp.avg_rating DESC NULLS LAST;


-- Отзывы на модерации
SELECT
    r.id            AS review_id,
    cp.display_name AS client,
    pp.full_name    AS psychologist,
    r.rating,
    LEFT(r.text, 100) || '...'  AS text_preview,
    r.created_at
FROM reviews r
JOIN client_profiles cp     ON cp.user_id = r.client_id
JOIN psychologist_profiles pp ON pp.id = r.psychologist_id
WHERE r.moderation_status = 'pending'
ORDER BY r.created_at;


-- Психологи, не отвечающие на отзывы
SELECT
    pp.full_name,
    COUNT(r.id)     AS approved_reviews,
    COUNT(rr.id)    AS replies_count,
    COUNT(r.id) - COUNT(rr.id) AS unanswered
FROM psychologist_profiles pp
JOIN reviews r ON r.psychologist_id = pp.id AND r.moderation_status = 'approved'
LEFT JOIN review_replies rr ON rr.review_id = r.id
GROUP BY pp.id, pp.full_name
HAVING COUNT(r.id) - COUNT(rr.id) > 0
ORDER BY unanswered DESC;


-- =============================================================
-- 6. КОММУНИКАЦИИ И УВЕДОМЛЕНИЯ
-- =============================================================

-- Статистика доставки уведомлений по каналам и типам
SELECT
    channel,
    type,
    COUNT(*)                                            AS total,
    COUNT(*) FILTER (WHERE status = 'sent')             AS sent,
    COUNT(*) FILTER (WHERE status = 'failed')           AS failed,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'sent')::NUMERIC
        / NULLIF(COUNT(*), 0) * 100, 1
    )                                                   AS delivery_rate_pct
FROM notifications
GROUP BY channel, type
ORDER BY channel, type;


-- Сообщения до бронирования: активные диалоги
SELECT
    cp.display_name     AS client,
    pp.full_name        AS psychologist,
    COUNT(m.id)         AS messages_count,
    MAX(m.created_at)   AS last_message_at
FROM pre_booking_messages m
JOIN client_profiles cp     ON cp.user_id = m.client_id
JOIN psychologist_profiles pp ON pp.id = m.psychologist_id
GROUP BY cp.display_name, pp.full_name
ORDER BY last_message_at DESC;


-- =============================================================
-- 7. СПОРЫ
-- =============================================================

-- Все споры с деталями
SELECT
    d.id                    AS dispute_id,
    cp.display_name         AS opened_by_client,
    pp.full_name            AS psychologist,
    b.price_rub,
    d.status,
    d.reason,
    d.resolution,
    d.opened_at,
    d.resolved_at,
    EXTRACT(DAY FROM (COALESCE(d.resolved_at, NOW()) - d.opened_at)) AS open_days
FROM disputes d
JOIN bookings b             ON b.id = d.booking_id
JOIN client_profiles cp     ON cp.user_id = d.opened_by
JOIN psychologist_profiles pp ON pp.id = b.psychologist_id
ORDER BY d.opened_at DESC;


-- Психологи с наибольшим числом споров (риск-профиль)
SELECT
    pp.full_name,
    COUNT(d.id)     AS disputes_count,
    COUNT(b.id)     AS total_bookings,
    ROUND(COUNT(d.id)::NUMERIC / NULLIF(COUNT(b.id), 0) * 100, 1) AS dispute_rate_pct
FROM psychologist_profiles pp
LEFT JOIN bookings b    ON b.psychologist_id = pp.id
LEFT JOIN disputes d    ON d.booking_id = b.id
GROUP BY pp.id, pp.full_name
ORDER BY disputes_count DESC;


-- =============================================================
-- 8. СВОДНЫЕ ДАШБОРД-МЕТРИКИ
-- =============================================================

-- Общие показатели платформы (один запрос для главного дашборда)
SELECT
    (SELECT COUNT(*) FROM users WHERE role = 'client' AND deleted_at IS NULL)
        AS total_clients,

    (SELECT COUNT(*) FROM psychologist_profiles WHERE verification_status = 'approved')
        AS approved_psychologists,

    (SELECT COUNT(*) FROM bookings WHERE status = 'completed')
        AS completed_sessions,

    (SELECT COALESCE(SUM(amount_rub), 0) FROM payments WHERE status = 'succeeded')
        AS total_revenue_rub,

    (SELECT COALESCE(SUM(commission_amount), 0) FROM payouts)
        AS total_commission_rub,

    (SELECT ROUND(AVG(avg_rating), 2) FROM psychologist_profiles WHERE avg_rating IS NOT NULL)
        AS platform_avg_rating,

    (SELECT COUNT(*) FROM disputes WHERE status IN ('open', 'in_review'))
        AS open_disputes,

    (SELECT COUNT(*) FROM verification_requests WHERE status = 'pending')
        AS pending_verifications;


-- Метрики за текущий месяц vs прошлый месяц
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', created_at) AS month,
        COUNT(*)                        AS new_bookings,
        SUM(price_rub)                  AS revenue_rub
    FROM bookings
    WHERE status IN ('completed', 'confirmed')
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT
    TO_CHAR(month, 'YYYY-MM')   AS period,
    new_bookings,
    revenue_rub,
    LAG(new_bookings) OVER (ORDER BY month)     AS prev_bookings,
    LAG(revenue_rub)  OVER (ORDER BY month)     AS prev_revenue_rub,
    ROUND(
        (new_bookings - LAG(new_bookings) OVER (ORDER BY month))::NUMERIC
        / NULLIF(LAG(new_bookings) OVER (ORDER BY month), 0) * 100, 1
    )                                           AS bookings_growth_pct
FROM monthly
ORDER BY month DESC;


-- =============================================================
-- 9. СЛОЖНЫЕ АНАЛИТИЧЕСКИЕ ЗАПРОСЫ
-- =============================================================


-- ---------------------------------------------------------------
-- 9.1 Когортный анализ удержания клиентов
--     Показывает, какой % клиентов из каждой когорты (месяц
--     первой сессии) вернулся во 2-й, 3-й и 4-й раз.
-- ---------------------------------------------------------------
WITH first_booking AS (
    SELECT
        b.client_id,
        DATE_TRUNC('month', MIN(ss.starts_at))  AS cohort_month
    FROM bookings b
    JOIN schedule_slots ss ON ss.id = b.slot_id
    WHERE b.status = 'completed'
    GROUP BY b.client_id
),
all_sessions AS (
    SELECT
        b.client_id,
        ss.starts_at,
        ROW_NUMBER() OVER (
            PARTITION BY b.client_id
            ORDER BY ss.starts_at
        ) AS session_number
    FROM bookings b
    JOIN schedule_slots ss ON ss.id = b.slot_id
    WHERE b.status = 'completed'
)
SELECT
    TO_CHAR(fb.cohort_month, 'YYYY-MM')                         AS cohort,
    COUNT(DISTINCT fb.client_id)                                 AS cohort_size,
    COUNT(DISTINCT als2.client_id)                               AS returned_2nd,
    COUNT(DISTINCT als3.client_id)                               AS returned_3rd,
    COUNT(DISTINCT als4.client_id)                               AS returned_4th,
    ROUND(COUNT(DISTINCT als2.client_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT fb.client_id), 0) * 100, 1)     AS retention_2nd_pct,
    ROUND(COUNT(DISTINCT als3.client_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT fb.client_id), 0) * 100, 1)     AS retention_3rd_pct,
    ROUND(COUNT(DISTINCT als4.client_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT fb.client_id), 0) * 100, 1)     AS retention_4th_pct
FROM first_booking fb
LEFT JOIN all_sessions als2
       ON als2.client_id = fb.client_id AND als2.session_number = 2
LEFT JOIN all_sessions als3
       ON als3.client_id = fb.client_id AND als3.session_number = 3
LEFT JOIN all_sessions als4
       ON als4.client_id = fb.client_id AND als4.session_number = 4
GROUP BY fb.cohort_month
ORDER BY fb.cohort_month;


-- ---------------------------------------------------------------
-- 9.2 RFM-сегментация клиентов
--     Recency   — сколько дней прошло с последней сессии
--     Frequency — общее число завершённых сессий
--     Monetary  — суммарно потрачено рублей
--     Итоговый сегмент: Champions / Loyal / At Risk / Lost
-- ---------------------------------------------------------------
WITH rfm_raw AS (
    SELECT
        b.client_id,
        EXTRACT(DAY FROM NOW() - MAX(ss.starts_at))::INT    AS recency_days,
        COUNT(b.id)                                         AS frequency,
        SUM(b.price_rub)                                    AS monetary
    FROM bookings b
    JOIN schedule_slots ss ON ss.id = b.slot_id
    WHERE b.status = 'completed'
    GROUP BY b.client_id
),
rfm_scored AS (
    SELECT
        client_id,
        recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency_days ASC)   AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC)     AS f_score,
        NTILE(4) OVER (ORDER BY monetary DESC)      AS m_score
    FROM rfm_raw
)
SELECT
    cp.display_name,
    u.email,
    rfm.recency_days,
    rfm.frequency,
    rfm.monetary,
    rfm.r_score,
    rfm.f_score,
    rfm.m_score,
    CASE
        WHEN rfm.r_score >= 3 AND rfm.f_score >= 3 THEN 'Champions'
        WHEN rfm.r_score >= 3 AND rfm.f_score >= 2 THEN 'Loyal'
        WHEN rfm.r_score <= 2 AND rfm.f_score >= 3 THEN 'At Risk'
        WHEN rfm.r_score = 1  AND rfm.f_score = 1  THEN 'Lost'
        ELSE 'Potential'
    END AS rfm_segment
FROM rfm_scored rfm
JOIN users u            ON u.id = rfm.client_id
JOIN client_profiles cp ON cp.user_id = rfm.client_id
ORDER BY rfm.monetary DESC;


-- ---------------------------------------------------------------
-- 9.3 Конверсионная воронка: от регистрации до повторной сессии
--     Каждый шаг показывает абсолютное число и % от предыдущего.
-- ---------------------------------------------------------------
WITH steps AS (
    SELECT
        COUNT(DISTINCT u.id)                AS s1_registered,
        COUNT(DISTINCT cp.user_id)          AS s2_profile_filled,
        COUNT(DISTINCT pbm.client_id)       AS s3_sent_message,
        COUNT(DISTINCT b_any.client_id)     AS s4_booked,
        COUNT(DISTINCT b_paid.client_id)    AS s5_paid,
        COUNT(DISTINCT b_done.client_id)    AS s6_completed,
        COUNT(DISTINCT b_repeat.client_id)  AS s7_returned
    FROM users u
    LEFT JOIN client_profiles cp        ON cp.user_id = u.id
    LEFT JOIN pre_booking_messages pbm  ON pbm.client_id = u.id
    LEFT JOIN bookings b_any            ON b_any.client_id = u.id
    LEFT JOIN bookings b_paid           ON b_paid.client_id = u.id
                                       AND b_paid.status IN ('confirmed', 'completed')
    LEFT JOIN bookings b_done           ON b_done.client_id = u.id
                                       AND b_done.status = 'completed'
    LEFT JOIN (
        SELECT client_id
        FROM bookings
        WHERE status = 'completed'
        GROUP BY client_id
        HAVING COUNT(*) >= 2
    ) b_repeat ON b_repeat.client_id = u.id
    WHERE u.role = 'client'
)
SELECT 'Зарегистрировались'        AS step, s1_registered  AS users,
    100.0 AS pct_from_prev FROM steps
UNION ALL
SELECT 'Заполнили профиль',        s2_profile_filled,
    ROUND(s2_profile_filled::NUMERIC / NULLIF(s1_registered, 0) * 100, 1) FROM steps
UNION ALL
SELECT 'Написали психологу',       s3_sent_message,
    ROUND(s3_sent_message::NUMERIC / NULLIF(s2_profile_filled, 0) * 100, 1) FROM steps
UNION ALL
SELECT 'Создали бронирование',     s4_booked,
    ROUND(s4_booked::NUMERIC / NULLIF(s3_sent_message, 0) * 100, 1) FROM steps
UNION ALL
SELECT 'Оплатили',                 s5_paid,
    ROUND(s5_paid::NUMERIC / NULLIF(s4_booked, 0) * 100, 1) FROM steps
UNION ALL
SELECT 'Провели сессию',           s6_completed,
    ROUND(s6_completed::NUMERIC / NULLIF(s5_paid, 0) * 100, 1) FROM steps
UNION ALL
SELECT 'Вернулись (2+ сессии)',    s7_returned,
    ROUND(s7_returned::NUMERIC / NULLIF(s6_completed, 0) * 100, 1) FROM steps;


-- ---------------------------------------------------------------
-- 9.4 Скользящая выручка за 7 дней (rolling revenue)
--     Сглаживает всплески и провалы, показывает тренд.
-- ---------------------------------------------------------------
WITH daily_revenue AS (
    SELECT
        DATE(p.created_at)      AS day,
        SUM(p.amount_rub)       AS daily_revenue
    FROM payments p
    WHERE p.status = 'succeeded'
    GROUP BY DATE(p.created_at)
)
SELECT
    day,
    daily_revenue,
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY day
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                       AS rolling_7d_avg,
    SUM(daily_revenue) OVER (
        ORDER BY day
    )                           AS cumulative_revenue
FROM daily_revenue
ORDER BY day;


-- ---------------------------------------------------------------
-- 9.5 Перцентильное ранжирование психологов по доходу
--     Показывает место каждого психолога относительно остальных:
--     топ 25% / средние / нижние 25%.
-- ---------------------------------------------------------------
WITH psychologist_revenue AS (
    SELECT
        pp.id,
        pp.full_name,
        pp.price_rub,
        pp.avg_rating,
        COUNT(b.id)         AS sessions_count,
        SUM(b.price_rub)    AS total_revenue
    FROM psychologist_profiles pp
    LEFT JOIN bookings b ON b.psychologist_id = pp.id AND b.status = 'completed'
    WHERE pp.verification_status = 'approved'
    GROUP BY pp.id, pp.full_name, pp.price_rub, pp.avg_rating
)
SELECT
    full_name,
    price_rub,
    avg_rating,
    sessions_count,
    total_revenue,
    RANK()         OVER (ORDER BY total_revenue DESC NULLS LAST)  AS revenue_rank,
    ROUND(
        (PERCENT_RANK() OVER (ORDER BY total_revenue DESC NULLS LAST) * 100)::NUMERIC, 1
    )                                                             AS percent_rank,
    CASE NTILE(4)  OVER (ORDER BY total_revenue DESC NULLS LAST)
        WHEN 1 THEN 'Топ 25%'
        WHEN 2 THEN 'Выше среднего'
        WHEN 3 THEN 'Ниже среднего'
        WHEN 4 THEN 'Нижние 25%'
    END                                                           AS tier
FROM psychologist_revenue
ORDER BY revenue_rank;


-- ---------------------------------------------------------------
-- 9.6 Анализ оттока: клиенты без активности более 30 дней
--     Показывает «спящих» клиентов для реактивационной кампании.
-- ---------------------------------------------------------------
WITH client_activity AS (
    SELECT
        b.client_id,
        MAX(ss.starts_at)                               AS last_session_at,
        COUNT(b.id)                                     AS total_sessions,
        SUM(b.price_rub)                                AS total_spent,
        EXTRACT(DAY FROM NOW() - MAX(ss.starts_at))     AS days_since_last_session
    FROM bookings b
    JOIN schedule_slots ss ON ss.id = b.slot_id
    WHERE b.status = 'completed'
    GROUP BY b.client_id
),
has_future_booking AS (
    SELECT DISTINCT client_id
    FROM bookings
    WHERE status IN ('pending_payment', 'confirmed')
)
SELECT
    cp.display_name,
    u.email,
    ca.last_session_at,
    ca.days_since_last_session::INT     AS inactive_days,
    ca.total_sessions,
    ca.total_spent,
    cp.notify_email,
    cp.notify_telegram,
    CASE
        WHEN ca.days_since_last_session BETWEEN 30 AND 60   THEN 'Риск оттока'
        WHEN ca.days_since_last_session BETWEEN 61 AND 90   THEN 'Высокий риск'
        WHEN ca.days_since_last_session > 90                THEN 'Отток'
    END                                 AS churn_segment
FROM client_activity ca
JOIN users u            ON u.id = ca.client_id
JOIN client_profiles cp ON cp.user_id = ca.client_id
LEFT JOIN has_future_booking hfb ON hfb.client_id = ca.client_id
WHERE ca.days_since_last_session > 30
  AND hfb.client_id IS NULL
ORDER BY ca.days_since_last_session DESC;


-- ---------------------------------------------------------------
-- 9.7 Влияние напоминаний на явку клиентов
--     Сравниваем no-show rate у сессий с напоминаниями и без.
-- ---------------------------------------------------------------
WITH booking_notifications AS (
    SELECT
        b.id        AS booking_id,
        b.status,
        MAX(CASE WHEN n.type = 'reminder_24h' AND n.status = 'sent' THEN 1 ELSE 0 END) AS had_24h,
        MAX(CASE WHEN n.type = 'reminder_1h'  AND n.status = 'sent' THEN 1 ELSE 0 END) AS had_1h
    FROM bookings b
    LEFT JOIN notifications n ON n.user_id = b.client_id
    WHERE b.status IN ('completed', 'no_show')
    GROUP BY b.id, b.status
)
SELECT
    CASE
        WHEN had_24h = 1 AND had_1h = 1 THEN 'Оба напоминания'
        WHEN had_24h = 1                 THEN 'Только за 24ч'
        WHEN had_1h  = 1                 THEN 'Только за 1ч'
        ELSE 'Без напоминаний'
    END                                                         AS reminder_type,
    COUNT(*)                                                    AS total_sessions,
    COUNT(*) FILTER (WHERE status = 'no_show')                  AS no_shows,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'no_show')::NUMERIC
        / NULLIF(COUNT(*), 0) * 100, 1
    )                                                           AS no_show_rate_pct
FROM booking_notifications
GROUP BY had_24h, had_1h
ORDER BY no_show_rate_pct;


-- ---------------------------------------------------------------
-- 9.8 Матрица переходов клиентов между психологами
--     Показывает, к кому уходили клиенты после первого психолога.
--     Помогает выявить, кто «удерживает», а кто «отдаёт» клиентов.
-- ---------------------------------------------------------------
WITH ordered_sessions AS (
    SELECT
        b.client_id,
        b.psychologist_id,
        pp.full_name        AS psychologist_name,
        ss.starts_at,
        ROW_NUMBER() OVER (
            PARTITION BY b.client_id
            ORDER BY ss.starts_at
        )                   AS session_num
    FROM bookings b
    JOIN schedule_slots ss        ON ss.id = b.slot_id
    JOIN psychologist_profiles pp ON pp.id = b.psychologist_id
    WHERE b.status = 'completed'
)
SELECT
    s1.psychologist_name            AS from_psychologist,
    s2.psychologist_name            AS to_psychologist,
    COUNT(*)                        AS transitions,
    COUNT(DISTINCT s1.client_id)    AS unique_clients
FROM ordered_sessions s1
JOIN ordered_sessions s2
    ON  s2.client_id     = s1.client_id
    AND s2.session_num   = s1.session_num + 1
    AND s2.psychologist_id <> s1.psychologist_id
GROUP BY s1.psychologist_name, s2.psychologist_name
ORDER BY transitions DESC;


# 🧠 MindSpace — Маркетплейс психологов

> Учебный проект системного аналитика · Полный цикл аналитики от BRD до прототипа UI

**Автор:** Тезикова Елена · Системный аналитик  
**Версия:** 2.0 · Май 2026  
**Статус:** в работе

![BRD](https://img.shields.io/badge/BRD-готово-27AE60?style=flat-square)
![User Stories](https://img.shields.io/badge/User_Stories-готово-27AE60?style=flat-square)
![BPMN](https://img.shields.io/badge/BPMN-готово-27AE60?style=flat-square)
![UML](https://img.shields.io/badge/UML-готово-27AE60?style=flat-square)
![C4](https://img.shields.io/badge/C4_Model-готово-27AE60?style=flat-square)
![ER](https://img.shields.io/badge/ER_Diagram-готово-27AE60?style=flat-square)
![API](https://img.shields.io/badge/REST_API-готово-27AE60?style=flat-square)
![SQL](https://img.shields.io/badge/SQL-готово-27AE60?style=flat-square)
![n8n](https://img.shields.io/badge/n8n_Workflow-в_работе-E67E22?style=flat-square)
![Figma](https://img.shields.io/badge/Figma-в_работе-E67E22?style=flat-square)

---

## 📌 О проекте

**MindSpace** — платформа для подбора психологов и онлайн-записи на сессии.  
Клиент находит специалиста по параметрам (специализация, формат, цена, язык), бронирует слот и оплачивает сессию. Психолог управляет расписанием, загружает документы для верификации и получает выплаты.

**Роли:** Клиент · Психолог · Администратор · Служба поддержки  
**MVP включает:** поиск и подбор, бронирование, онлайн-оплата (54-ФЗ), верификация психологов, отзывы с модерацией, уведомления (Email + Telegram), управление спорами  
**Вне скоупа MVP:** встроенный видеозвонок, групповые сессии, мобильное приложение, B2B-модуль  
**Регуляторные требования:** 54-ФЗ (онлайн-касса), 152-ФЗ (персональные данные), хранение данных в РФ

---

## 📂 Структура репозитория

```
📁 psychology-booking-system/
├── README.md
├── 📁 docs/
│   ├── BRD_MindSpace.docx                   ← бизнес-требования
│   └── UserStories_MindSpace.docx           ← пользовательские истории
├── 📁 diagrams/
│   ├── booking_process.bpmn                 ← BPMN: процесс бронирования
│   ├── booking_process_drawio.svg           ← BPMN: визуализация (draw.io SVG)
│   ├── er_mindspace.puml                    ← ER-диаграмма
│   ├── 📁 uml/
│   │   ├── usecase_mindspace.puml           ← Use Case
│   │   ├── sequence_booking_mindspace.puml  ← Sequence: бронирование
│   │   └── statemachine_mindspace.puml      ← State Machine
│   └── 📁 c4/
│       ├── c4_level1_context.puml           ← Context
│       ├── c4_level2_container.puml         ← Container
│       └── c4_level3_component.puml         ← Component
├── 📁 api/
│   ├── mindspace_api.json                   ← OpenAPI 3.0.3 спецификация
│   └── mindspace_swagger.html               ← Swagger UI (интерактивная документация)
└── 📁 sql/
    ├── 01_schema.sql                        ← DDL: создание 20 таблиц
    ├── 02_seed.sql                          ← тестовые данные (12 пользователей, 6 бронирований)
    ├── 02b_seed_extra.sql                   ← дополнительные данные для аналитических запросов
    └── 03_queries.sql                       ← 28 аналитических запросов
```

---

## 📋 Артефакты

### 1. BRD — Business Requirements Document ✅

Описывает бизнес-цели, проблему, заинтересованные стороны, персоны и высокоуровневые требования к платформе MindSpace.

**Ключевые разделы:** бизнес-контекст · процессы To-Be · функциональные и нефункциональные требования · риски · критерии успеха MVP

👉 [BRD_MindSpace.docx](./docs/BRD_MindSpace.docx) · [Открыть как PDF](./docs/BRD_MindSpace_pdf.pdf)

---

### 2. User Stories ✅

22 пользовательские истории по 8 эпикам с критериями приёмки, Definition of Ready и Definition of Done.

| Эпик | User Stories |
|------|-------------|
| Регистрация и профиль | US-01 – US-04, US-17 |
| Поиск и подбор | US-05 – US-06a |
| Бронирование | US-07 – US-10, US-18 |
| Оплата | US-11 – US-12, US-19 |
| Отзывы | US-13, US-20 |
| Уведомления | US-14 – US-15 |
| Верификация психологов | US-16, US-21 |
| Споры и поддержка | US-22 |

👉 [UserStories_MindSpace.docx](./docs/UserStories_MindSpace.docx) · [Открыть как PDF](./docs/UserStories_MindSpace_pdf.pdf)

---

### 3. BPMN — процесс бронирования ✅

Три дорожки: Клиент · Платформа MindSpace · Психолог.  
Покрывает: поиск, проверку слота, 15-минутный резерв, оплату, подтверждение, завершение сессии, отмену и обработку ошибок.

![BPMN — процесс бронирования MindSpace](./diagrams/booking_process.drawio.svg)

👉 [diagrams/booking_process.bpmn](./diagrams/booking_process.bpmn) · [booking_process_drawio.svg](./diagrams/booking_process_drawio.svg)

---

### 4. UML-диаграммы ✅

#### Use Case

Взаимодействие трёх акторов (Клиент, Психолог, Администратор) с функциями платформы.

👉 [diagrams/uml/usecase_mindspace.puml](./diagrams/uml/usecase_mindspace.puml)

---

#### Sequence Diagram — бронирование сессии

Happy Path + сценарий отмены клиентом.

👉 [diagrams/uml/sequence_booking_mindspace.puml](./diagrams/uml/sequence_booking_mindspace.puml)

---

#### State Machine — жизненный цикл сущностей

👉 [diagrams/uml/statemachine_mindspace.puml](./diagrams/uml/statemachine_mindspace.puml)

---

### 5. C4 Model ✅

👉 [diagrams/c4/c4_level1_context.puml](./diagrams/c4/c4_level1_context.puml) · [c4_level2_container.puml](./diagrams/c4/c4_level2_container.puml) · [c4_level3_component.puml](./diagrams/c4/c4_level3_component.puml)

---

### 6. ER-диаграмма ✅

👉 [diagrams/er_mindspace.puml](./diagrams/er_mindspace.puml)

---

### 7. REST API ✅

Спецификация в формате OpenAPI 3.0.3. Аутентификация: Bearer JWT.  
**Серверы:** `https://api.mindspace.ru/v1` · `https://api-staging.mindspace.ru/v1`

> 🔍 **[Открыть API в Swagger Editor](https://editor.swagger.io/?url=https://raw.githubusercontent.com/elenatezikova-sa/psychology-booking-system/refs/heads/main/api/mindspace_api.json)** — просматривай все эндпоинты прямо в браузере

<details>
<summary>▶ Показать все эндпоинты (31)</summary>

| Метод | Путь | Описание |
|-------|------|----------|
| `POST` | `/auth/register/client` | Регистрация клиента |
| `POST` | `/auth/register/psychologist` | Регистрация психолога |
| `POST` | `/auth/login` | Вход в систему |
| `POST` | `/auth/refresh` | Обновление access токена |
| `POST` | `/auth/confirm-email` | Подтверждение email |
| `GET` | `/client/profile` | Получить профиль клиента |
| `PUT` | `/client/profile` | Обновить профиль клиента |
| `DELETE` | `/client/profile` | Запрос на удаление аккаунта |
| `GET` | `/psychologist/profile` | Собственный профиль психолога |
| `PUT` | `/psychologist/profile` | Обновить профиль психолога |
| `GET` | `/psychologists/{id}/profile` | Публичный профиль психолога |
| `GET` | `/psychologist/documents` | Список загруженных документов |
| `POST` | `/psychologist/documents` | Загрузить документ для верификации |
| `GET` | `/psychologist/stats` | Статистика и история выплат |
| `GET` | `/search/psychologists` | Поиск психологов по фильтрам |
| `GET` | `/dictionaries/specializations` | Справочник специализаций |
| `GET` | `/dictionaries/methods` | Справочник методов работы |
| `GET` | `/messages` | История переписки |
| `POST` | `/messages` | Отправить сообщение психологу до записи |
| `GET` | `/psychologist/schedule` | Расписание психолога |
| `POST` | `/psychologist/schedule/slots` | Создать слоты расписания |
| `DELETE` | `/psychologist/schedule/slots/{slot_id}` | Удалить / заблокировать слот |
| `GET` | `/psychologists/{id}/slots` | Доступные слоты для клиента |
| `POST` | `/bookings` | Создать бронирование |
| `GET` | `/bookings` | Список сессий клиента |
| `GET` | `/bookings/{id}` | Детали бронирования |
| `POST` | `/bookings/{id}/cancel` | Отменить бронирование |
| `POST` | `/bookings/{id}/no-show` | Отметить no-show клиента |
| `GET` | `/bookings/{id}/calendar.ics` | Скачать .ics для календаря |
| `POST` | `/payments` | Инициировать оплату бронирования |
| `POST` | `/payments/webhook` | Webhook от платёжного провайдера |

</details>

👉 [api/mindspace_api.json](./api/mindspace_api.json) · [Swagger UI](./api/mindspace_swagger.html)

---

### 8. SQL — схема и данные ✅

PostgreSQL 16 · 20 таблиц · 8 доменов · тестовые данные · 28 аналитических запросов

#### Схема базы данных

| Домен | Таблицы |
|-------|---------|
| Пользователи и профили | `users`, `client_profiles`, `psychologist_profiles` |
| Справочники | `specializations`, `therapy_methods`, `psychologist_specializations`, `psychologist_methods` |
| Верификация | `verification_requests`, `verification_documents`, `verification_log` |
| Расписание и бронирования | `schedule_slots`, `bookings` |
| Платежи и выплаты | `payments`, `refunds`, `payouts` |
| Отзывы | `reviews`, `review_replies` |
| Коммуникации | `pre_booking_messages`, `notifications` |
| Споры | `disputes` |

#### Тестовые данные

| Сущность | Записей | Сценарии |
|----------|---------|---------|
| Пользователи | 12 | все 4 роли, неподтверждённый email |
| Психологи | 4 | одобрен / на верификации / отклонён и перезаявился |
| Бронирования | 10 | completed / cancelled / disputed |
| Платежи | 6 | succeeded / refunded |
| Отзывы | 5 | approved / pending, с ответами психологов |
| Споры | 1 | открыт клиентом, на рассмотрении |

#### Аналитические запросы (28)

<details>
<summary>▶ Показать все запросы</summary>

| № | Запрос | SQL-техники |
|---|--------|-------------|
| 1–3 | Пользователи: по ролям, регистрации по дням, неподтверждённый email | `GROUP BY`, `FILTER` |
| 4–7 | Верификация: воронка, время рассмотрения, повторные заявки | коррелированный подзапрос, `HAVING` |
| 8–11 | Бронирования: загрузка психологов, воронка, операционный отчёт | multi-JOIN, `FILTER` |
| 12–15 | Финансы: выручка по месяцам, топ психологов, возвраты, удержания | `DATE_TRUNC`, `COALESCE` |
| 16–18 | Отзывы: рейтинг со звёздами, модерация, нет ответов | `LEFT JOIN`, `HAVING` |
| 19–20 | Уведомления: доставляемость по каналам, активные диалоги | conditional aggregation |
| 21–22 | Споры: детали, риск-профиль психологов | `EXTRACT`, `COALESCE` |
| 23–24 | Дашборд: все метрики одним запросом, рост MoM | скалярные подзапросы, `LAG` |
| **9.1** | **Когортный анализ удержания клиентов** | CTE, `ROW_NUMBER`, self-join |
| **9.2** | **RFM-сегментация: Champions / Loyal / At Risk / Lost** | CTE, `NTILE`, `CASE WHEN` |
| **9.3** | **Конверсионная воронка от регистрации до повторной сессии** | CTE, `UNION ALL`, вложенные подзапросы |
| **9.4** | **Скользящая выручка за 7 дней** | `ROWS BETWEEN`, накопленная сумма |
| **9.5** | **Перцентильное ранжирование психологов** | `RANK`, `PERCENT_RANK`, `NTILE` |
| **9.6** | **Анализ оттока: «Риск» / «Высокий риск» / «Отток»** | CTE, `LEFT JOIN` для исключения |
| **9.7** | **Влияние напоминаний на no-show rate** | conditional aggregation, `FILTER` |
| **9.8** | **Матрица переходов клиентов между психологами** | CTE, `ROW_NUMBER`, self-join на смежные строки |

</details>

#### Примеры результатов

<!-- После выполнения запросов в DBeaver добавьте скриншоты сюда -->
<!-- Рекомендуемые запросы для скриншотов: 9.2 RFM, 9.3 Воронка, 9.5 Ранжирование, 9.6 Отток, 9.1 Когорты -->

👉 [sql/01_schema.sql](./sql/01_schema.sql) · [sql/02_seed.sql](./sql/02_seed.sql) · [sql/03_queries.sql](./sql/03_queries.sql)

---

### 9. n8n Workflow 🚧 в работе

Автоматизация уведомлений: напоминание клиенту за 24 часа и за 1 час до сессии, уведомление психологу о новом бронировании.

---

### 10. Figma — прототипы интерфейсов 🚧 в работе

Экраны для клиента (поиск, бронирование, профиль) и для психолога (расписание, верификация, история выплат).

---

## 🛠 Инструменты

| Артефакт | Инструмент |
|----------|------------|
| BRD, User Stories | Word |
| BPMN | draw.io |
| Use Case, Sequence, State Machine, C4, ER | PlantUML |
| API | OpenAPI 3.0.3 / Swagger |
| SQL | PostgreSQL 16 · DBeaver · Docker |
| Workflow | n8n |
| UI-прототипы | Figma |

---

## 👤 Автор

**Тезикова Елена** · Системный аналитик

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin)](https://linkedin.com/in/your-profile)
[![Telegram](https://img.shields.io/badge/Telegram-Write-26A5E4?style=flat-square&logo=telegram)](https://t.me/dudkina8)

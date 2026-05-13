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
![SQL](https://img.shields.io/badge/SQL-в_работе-E67E22?style=flat-square)
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
📁 mindspace/
├── README.md
│
├── 📁 docs/
│   ├── BRD_MindSpace_v2.docx           ← бизнес-требования
│   └── UserStories_MindSpace_v2.docx   ← пользовательские истории (22 US)
│
├── 📁 diagrams/
│   ├── booking_process_v3.bpmn         ← BPMN: процесс бронирования
│   ├── 📁 uml/
│   │   ├── usecase_mindspace_v4.puml   ← Use Case
│   │   ├── sequence_booking.puml       ← Sequence: бронирование (happy path + отмена)
│   │   └── statemachine.puml          ← State Machine: бронирование + верификация
│   ├── 📁 c4/
│   │   ├── c4_level1_context.puml      ← Context: система и окружение
│   │   ├── c4_level2_container_v3.puml ← Container: внутренние контейнеры
│   │   └── c4_level3_component_v2.puml ← Component: компоненты Backend API
│   └── er_mindspace_v4.puml            ← ER-диаграмма (8 доменов)
│
├── 📁 api/
│   └── mindspace_api.json              ← OpenAPI 3.0.3 спецификация
│
├── 📁 database/
│   └── 🚧 schema.sql                   ← в работе
│
├── 📁 n8n/
│   └── 🚧 workflow.json                ← в работе
│
└── 📁 figma/
    └── 🚧 figma_link.md                ← в работе
```

---

## 📋 Артефакты

### 1. BRD — Business Requirements Document ✅

Описывает бизнес-цели, проблему, заинтересованные стороны, персоны и высокоуровневые требования к платформе MindSpace.

**Ключевые разделы:**
- Бизнес-контекст и описание проблемы
- Заинтересованные стороны и пользовательские персоны (Анна / Дмитрий / Мария)
- Процессы To-Be: запись на сессию, политика отмен, верификация психолога
- Функциональные и нефункциональные требования
- Риски, ограничения, критерии успеха MVP

👉 [BRD_MindSpace_v2.docx](./docs/BRD_MindSpace_v2.docx)

---

### 2. User Stories ✅

22 пользовательские истории по 8 эпикам с критериями приёмки (Acceptance Criteria), Definition of Ready и Definition of Done.

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

👉 [UserStories_MindSpace_v2.docx](./docs/UserStories_MindSpace_v2.docx)

---

### 3. BPMN — процесс бронирования ✅

Описывает полный флоу записи клиента к психологу с тремя дорожками: Клиент · Платформа MindSpace · Психолог.

Покрывает: поиск и фильтрацию, проверку слота, 15-минутный резерв, оплату, подтверждение бронирования, happy path завершения сессии, отмену и обработку ошибок оплаты.

👉 [booking_process_v3.bpmn](./diagrams/booking_process_v3.bpmn)

---

### 4. UML-диаграммы ✅

#### Use Case
Взаимодействие трёх акторов (Клиент, Психолог, Администратор) с функциями платформы. Покрывает все эпики User Stories.

👉 [usecase_mindspace_v4.puml](./diagrams/uml/usecase_mindspace_v4.puml)

#### Sequence Diagram
Последовательность вызовов при бронировании сессии: Happy Path + сценарий отмены клиентом.

Участники: `Клиент → Web App (SPA) → Backend API → PostgreSQL → Платёжный провайдер → Notification Service`

👉 [sequence_booking.puml](./diagrams/uml/sequence_booking.puml)

#### State Machine
Жизненный цикл двух ключевых сущностей:
- **Бронирование:** `pending_payment` → `confirmed` → `completed` / `cancelled` / `no_show` / `disputed`
- **Верификация психолога:** `pending_review` → `verified` / `rejected`

👉 [statemachine.puml](./diagrams/uml/statemachine.puml)

---

### 5. C4 Model ✅

Архитектура системы на трёх уровнях детализации.

#### Level 1 — System Context
MindSpace в окружении пользователей и внешних систем.

**Внешние системы:** Платёжный провайдер (54-ФЗ) · Email-сервис · Telegram Bot API · Zoom / Google Meet (вне скоупа)  
**Регуляторы:** ФНС / Роскомнадзор (54-ФЗ, 152-ФЗ)

👉 [c4_level1_context.puml](./diagrams/c4/c4_level1_context.puml)

#### Level 2 — Container
Внутренние контейнеры платформы.

| Контейнер | Тип | Назначение |
|-----------|-----|-----------|
| Web App (SPA) | React / Vue | UI для всех ролей, CDN / Nginx |
| Backend API | REST / JSON | Бизнес-логика, JWT + bcrypt |
| Notification Service | Worker | Email + Telegram, напоминания за 24ч и 1ч |
| Job Scheduler | Cron / Queue | Автоотмена резерва, триггер выплат |
| PostgreSQL | Database | Пользователи, бронирования, платежи (данные в РФ) |
| File Storage | Object Storage | Документы психологов (закрытый доступ) |

👉 [c4_level2_container_v3.puml](./diagrams/c4/c4_level2_container_v3.puml)

#### Level 3 — Component
Компоненты Backend API: Auth · Profile · Search · Booking · Payment · Verification · Reviews · Disputes · Notifications.

👉 [c4_level3_component_v2.puml](./diagrams/c4/c4_level3_component_v2.puml)

---

### 6. ER-диаграмма ✅

Схема базы данных — 8 доменов, нотация Crow's Foot.

| Домен | Таблицы |
|-------|---------|
| Users & Profiles | `users`, `client_profiles`, `psychologist_profiles` |
| Verification | `psychologist_documents`, `verification_decisions` |
| Schedule & Booking | `schedule_slots`, `bookings` |
| Payments & Payouts | `payments`, `payouts` |
| Reviews | `reviews`, `review_responses` |
| Notifications | `notifications` |
| Messages & Disputes | `messages`, `disputes` |
| Справочники | `specializations`, `therapy_methods`, `psychologist_specializations` |

👉 [er_mindspace_v4.puml](./diagrams/er_mindspace_v4.puml)

---

### 7. REST API ✅

Спецификация в формате OpenAPI 3.0.3. Аутентификация: Bearer JWT.

**Серверы:** `https://api.mindspace.ru/v1` · `https://api-staging.mindspace.ru/v1`  
**Теги:** Auth · Client Profile · Psychologist Profile · Search · Messages · Schedule · Bookings · Payments · Reviews · Verification · Admin · Notifications · Disputes

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
| `GET` | `/bookings/{id}/calendar.ics` | Скачать .ics для добавления в календарь |
| `POST` | `/payments` | Инициировать оплату бронирования |
| `POST` | `/payments/webhook` | Webhook от платёжного провайдера |

</details>

👉 [mindspace_api.json](./api/mindspace_api.json)

---

### 8. SQL — схема и данные 🚧 в работе

Создание таблиц и наполнение тестовыми данными по ER-диаграмме.

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
| BRD, User Stories | Word / Notion |
| BPMN | bpmn-js / Camunda Modeler |
| Use Case, Sequence, State Machine, C4, ER | PlantUML |
| API | OpenAPI 3.0.3 / Swagger |
| SQL | PostgreSQL |
| Workflow | n8n |
| UI-прототипы | Figma |

---

## 👤 Автор

**Тезикова Елена** · Системный аналитик

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin)](https://linkedin.com/in/your-profile)
[![Telegram](https://img.shields.io/badge/Telegram-Write-26A5E4?style=flat-square&logo=telegram)](https://t.me/your-username)

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
📁 psychology-booking-system/
├── README.md
├── 📁 docs/
│   ├── BRD_MindSpace.docx              ← бизнес-требования
│   └── UserStories_MindSpace.docx      ← пользовательские истории (22 US)
├── 📁 diagrams/
│   ├── booking_process.bpmn            ← BPMN: процесс бронирования
│   ├── booking_process_drawio.svg      ← BPMN: визуализация (draw.io SVG)
│   ├── er_mindspace.puml               ← ER-диаграмма (8 доменов)
│   ├── 📁 uml/
│   │   ├── usecase_mindspace.puml      ← Use Case
│   │   ├── sequence_booking_mindspace.puml  ← Sequence: бронирование
│   │   └── statemachine_mindspace.puml ← State Machine
│   └── 📁 c4/
│       ├── c4_level1_context.puml      ← Context
│       ├── c4_level2_container.puml    ← Container
│       └── c4_level3_component.puml    ← Component
└── 📁 api/
    ├── mindspace_api.json              ← OpenAPI 3.0.3 спецификация
    └── mindspace_swagger.html          ← Swagger UI (интерактивная документация)
```

---

## 📋 Артефакты

### 1. BRD — Business Requirements Document ✅

Описывает бизнес-цели, проблему, заинтересованные стороны, персоны и высокоуровневые требования к платформе MindSpace.

**Ключевые разделы:** бизнес-контекст · персоны (Анна / Дмитрий / Мария) · процессы To-Be · функциональные и нефункциональные требования · риски · критерии успеха MVP

👉 [docs/BRD_MindSpace.docx](./docs/BRD_MindSpace.docx)

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

👉 [docs/UserStories_MindSpace.docx](./docs/UserStories_MindSpace.docx)

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

```mermaid
flowchart LR
    Client(["👤 Клиент"])
    Psych(["🧑‍⚕️ Психолог"])
    Admin(["🛡️ Администратор"])

    subgraph MS ["🧠 MindSpace"]
        subgraph ACC ["Аккаунт"]
            UC_Reg["Зарегистрироваться"]
            UC_Login["Войти в систему"]
        end
        subgraph SEARCH ["Поиск и запись"]
            UC_Search["Найти психолога по фильтрам"]
            UC_Profile["Просмотреть профиль"]
            UC_PreMsg["Написать психологу до записи"]
            UC_Book["Забронировать сессию"]
            UC_Pay["Оплатить сессию"]
            UC_Cancel["Отменить бронь"]
        end
        subgraph AFTER ["После сессии"]
            UC_Review["Оставить отзыв"]
            UC_Dispute["Открыть диспут"]
        end
        subgraph PSYCH_UC ["Практика психолога"]
            UC_Schedule["Управлять расписанием"]
            UC_EditProfile["Заполнить профиль и цены"]
            UC_Docs["Загрузить документы"]
            UC_Reply["Ответить на отзыв"]
            UC_PsychCancel["Отменить сессию"]
        end
        subgraph ADMIN_UC ["Администрирование"]
            UC_Verify["Верифицировать психолога"]
            UC_ModReview["Модерировать отзывы"]
            UC_Block["Заблокировать пользователя"]
            UC_ResolveDisp["Разрешить диспут"]
        end
    end

    Client --- UC_Reg & UC_Login & UC_Search & UC_Profile
    Client --- UC_Book & UC_Cancel & UC_Review & UC_Dispute & UC_PreMsg
    Psych --- UC_Reg & UC_Login & UC_Schedule
    Psych --- UC_EditProfile & UC_Docs & UC_Reply & UC_PsychCancel
    Admin --- UC_Verify & UC_ModReview & UC_Block & UC_ResolveDisp

    UC_Book -.->|«include»| UC_Pay
    UC_EditProfile -.->|«include»| UC_Docs
    UC_Verify -.->|«include»| UC_Docs
    UC_Profile -.->|«extend»| UC_PreMsg
```

👉 [diagrams/uml/usecase_mindspace.puml](./diagrams/uml/usecase_mindspace.puml)

---

#### Sequence Diagram — бронирование сессии

Happy Path + сценарий отмены клиентом.

```mermaid
sequenceDiagram
    actor Client as 👤 Клиент
    participant SPA as Web App (SPA)
    participant API as Backend API
    participant DB as PostgreSQL
    participant Pay as Платёжный провайдер
    participant Notify as Notification Service

    rect rgb(235, 245, 255)
        Note over Client,DB: Поиск и выбор
        Client->>SPA: Ввод фильтров (специализация, цена, слот)
        SPA->>API: GET /search?filters=...
        API->>DB: SELECT психологи WHERE verified + фильтры
        DB-->>API: Список психологов
        API-->>SPA: Психологи + свободные слоты
        SPA-->>Client: Карточки психологов
        Client->>SPA: Выбрать слот
        SPA->>API: POST /bookings {slot_id, psychologist_id}
        API->>DB: UPDATE slot → reserved, INSERT booking(pending_payment), expires = now+15min
        DB-->>API: booking_id
        API-->>SPA: booking_id, таймер 15 мин
        SPA-->>Client: ⏱ Экран оплаты (15 минут)
    end

    rect rgb(235, 255, 240)
        Note over Client,Notify: Оплата
        Client->>SPA: Нажать «Оплатить»
        SPA->>API: POST /payments {booking_id}
        API->>Pay: POST /charge {amount, idempotency_key}
        Pay-->>API: payment_id, completed + чек (54-ФЗ)
        API->>DB: UPDATE payment → completed, booking → confirmed, slot → booked
        DB-->>API: OK
        API->>Notify: Событие: booking_confirmed
        Notify-->>Client: 📧 Email + Telegram: «Бронь подтверждена»
        SPA-->>Client: Экран «Сессия забронирована»
    end

    rect rgb(255, 235, 235)
        Note over Client,Notify: Отмена клиентом
        alt Отмена за 24+ ч — возврат 100%
            Client->>SPA: Отменить бронь
            SPA->>API: POST /bookings/{id}/cancel
            API->>Pay: POST /refund {amount=100%}
            Pay-->>API: refund: completed
            API->>DB: UPDATE booking → cancelled, slot → available
            Notify-->>Client: 📧 «Возврат 100%»
        else Отмена менее чем за 24 ч — возврат 50%
            Client->>SPA: Отменить бронь
            SPA->>API: POST /bookings/{id}/cancel
            API->>Pay: POST /refund {amount=50%}
            Pay-->>API: refund: completed
            API->>DB: UPDATE booking → cancelled
            Notify-->>Client: 📧 «Возврат 50%»
        end
    end
```

👉 [diagrams/uml/sequence_booking_mindspace.puml](./diagrams/uml/sequence_booking_mindspace.puml)

---

#### State Machine — жизненный цикл сущностей

```mermaid
stateDiagram-v2
    direction LR
    [*] --> pending_payment : Слот выбран клиентом

    pending_payment : ⏳ pending_payment\nОжидает оплаты
    confirmed : ✅ confirmed\nПодтверждено
    completed : 🎉 completed\nЗавершено
    cancelled : ❌ cancelled\nОтменено
    no_show : 👻 no_show\nКлиент не явился
    disputed : ⚖️ disputed\nВ споре

    pending_payment --> confirmed : Оплата прошла
    pending_payment --> cancelled : Таймер 15 мин истёк
    confirmed --> completed : Сессия проведена
    confirmed --> cancelled : Отмена клиентом / психологом
    confirmed --> no_show : Клиент не подключился через 20 мин
    completed --> disputed : Открыт диспут
    disputed --> completed : Диспут закрыт
    disputed --> cancelled : Диспут → возврат
    cancelled --> [*]
    completed --> [*]
    no_show --> [*]
```

```mermaid
stateDiagram-v2
    [*] --> pending : Психолог загрузил документы

    pending : ⏳ pending\nНа проверке
    approved : ✅ approved\nВерифицирован
    rejected : ❌ rejected\nОтклонён

    pending --> approved : Администратор одобрил\n→ профиль публикуется
    pending --> rejected : Администратор отклонил
    rejected --> pending : Загружены исправленные документы

    approved --> [*]
```

👉 [diagrams/uml/statemachine_mindspace.puml](./diagrams/uml/statemachine_mindspace.puml)

---

### 5. C4 Model ✅

#### Level 1 — System Context

```mermaid
flowchart TD
    Client(["👤 Клиент\nИщет психолога,\nзаписывается, оплачивает"])
    Psych(["🧑‍⚕️ Психолог\nУправляет расписанием,\nпринимает оплату"])
    Admin(["🛡️ Администратор\nВерификация, модерация,\nрассмотрение споров"])

    subgraph MS ["🧠 MindSpace [Web Platform]\nМаркетплейс психологов · MVP"]
    end

    Pay["💳 Платёжный провайдер\nОплата, возвраты, выплаты\nФискализация (54-ФЗ)"]
    Email["📧 Email-сервис\nПодтверждения, напоминания"]
    Tg["✈️ Telegram Bot API\nПуш-уведомления"]
    Zoom["📹 Zoom / Google Meet\nВидеосвязь (вне скоупа)"]
    FNS["🏛️ ФНС / Роскомнадзор\n54-ФЗ · 152-ФЗ"]

    Client -->|"Поиск, бронирование, оплата [HTTPS]"| MS
    Psych -->|"Профиль, расписание, документы [HTTPS]"| MS
    Admin -->|"Панель администратора [HTTPS]"| MS
    MS -->|"Оплата, возвраты, выплаты [REST API]"| Pay
    MS -->|"Письма [SMTP / REST API]"| Email
    MS -->|"Push-уведомления [Bot API]"| Tg
    MS -.->|"Соблюдает требования"| FNS
    Client -.->|"Проводит сессию (вне платформы)"| Zoom
    Psych -.->|"Проводит сессию (вне платформы)"| Zoom
```

#### Level 2 — Container

```mermaid
flowchart TD
    Client(["👤 Клиент"])
    Psych(["🧑‍⚕️ Психолог"])
    Admin(["🛡️ Администратор"])

    subgraph MindSpace ["🧠 MindSpace Platform"]
        SPA["🖥️ Web App (SPA)\nReact / Vue\nUI для всех ролей"]
        API["⚙️ Backend API\nREST / JSON\nБизнес-логика · JWT + bcrypt"]
        Notify["🔔 Notification Service\nWorker\nEmail + Telegram · напоминания 24ч/1ч"]
        Scheduler["⏰ Job Scheduler\nCron / Queue\nАвтоотмена резерва · триггер выплат"]
        PG[("🗄️ PostgreSQL\nПользователи, брони,\nплатежи · данные в РФ")]
        Files[("📁 File Storage\nObject Storage\nДокументы психологов")]
    end

    Pay["💳 Платёжный провайдер"]
    EmailSvc["📧 Email-сервис"]
    TgBot["✈️ Telegram Bot API"]

    Client & Psych & Admin -->|HTTPS| SPA
    SPA -->|REST API / HTTPS| API
    API -->|SQL / TLS| PG
    API -->|S3 API| Files
    API -->|REST API| Pay
    API -->|событие| Notify
    API -->|событие| Scheduler
    Notify -->|SMTP / API| EmailSvc
    Notify -->|Bot API| TgBot
```

👉 [diagrams/c4/c4_level1_context.puml](./diagrams/c4/c4_level1_context.puml) · [c4_level2_container.puml](./diagrams/c4/c4_level2_container.puml) · [c4_level3_component.puml](./diagrams/c4/c4_level3_component.puml)

---

### 6. ER-диаграмма ✅

```mermaid
erDiagram
    users ||--o| client_profiles : "профиль клиента"
    users ||--o| psychologist_profiles : "профиль психолога"

    psychologist_profiles ||--o{ psychologist_specializations : "содержит"
    specializations ||--o{ psychologist_specializations : "используется в"
    psychologist_profiles ||--o{ psychologist_methods : "использует"
    therapy_methods ||--o{ psychologist_methods : "используется в"

    psychologist_profiles ||--o{ verification_requests : "подаёт заявку"
    verification_requests ||--o{ verification_documents : "включает"
    verification_requests ||--o{ verification_log : "логируется"

    psychologist_profiles ||--o{ schedule_slots : "владеет"
    client_profiles ||--o{ bookings : "создаёт"
    psychologist_profiles ||--o{ bookings : "получает"
    schedule_slots ||--o| bookings : "резервируется"

    bookings ||--o| payments : "оплачивается"
    payments ||--o{ refunds : "возвращается"
    bookings ||--o{ refunds : "порождает"
    psychologist_profiles ||--o{ payouts : "получает"
    bookings ||--o| payouts : "генерирует"

    bookings ||--o| reviews : "содержит"
    reviews ||--o| review_replies : "отвечает"

    users ||--o{ notifications : "получает"
    bookings ||--o{ notifications : "порождает"

    client_profiles ||--o{ pre_booking_messages : "отправляет"
    bookings ||--o| disputes : "эскалируется"

    users {
        UUID id PK
        string email
        string role "client / psychologist / admin"
        bool email_confirmed
        bool is_active
    }
    psychologist_profiles {
        UUID id PK
        UUID user_id FK
        string full_name
        decimal price_rub
        string verification_status "pending / verified / rejected"
        bool is_published
        decimal avg_rating
    }
    client_profiles {
        UUID id PK
        UUID user_id FK
        string display_name
        string preferred_format "online / offline / any"
    }
    bookings {
        UUID id PK
        UUID client_id FK
        UUID psychologist_id FK
        UUID slot_id FK
        decimal price_rub
        string status "pending_payment / confirmed / completed / cancelled / no_show / disputed"
        timestamp reservation_expires_at
    }
    payments {
        UUID id PK
        UUID booking_id FK
        decimal amount_rub
        string status "pending / completed / refunded / failed"
        string fiscal_receipt_url
    }
    schedule_slots {
        UUID id PK
        UUID psychologist_id FK
        timestamp starts_at
        timestamp ends_at
        string status "available / reserved / booked / blocked"
    }
    verification_requests {
        UUID id PK
        UUID psychologist_id FK
        string status "pending / approved / rejected"
        string reject_reason
        int attempt_number
    }
    reviews {
        UUID id PK
        UUID booking_id FK
        UUID client_id FK
        int rating
        string moderation_status "pending / approved / rejected"
    }
    disputes {
        UUID id PK
        UUID booking_id FK
        string status "open / in_review / resolved / closed"
        string resolution
    }
```

👉 [diagrams/er_mindspace.puml](./diagrams/er_mindspace.puml)

---

### 7. REST API ✅

Спецификация в формате OpenAPI 3.0.3. Аутентификация: Bearer JWT.  
**Серверы:** `https://api.mindspace.ru/v1` · `https://api-staging.mindspace.ru/v1`

> 🔍 **[Открыть API в Swagger Editor](https://editor.swagger.io/?url=https://raw.githubusercontent.com/elenatezikova-sa/psychology-booking-system/main/api/mindspace_api.json)

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

# Архитектура и спецификация API для клонирования платформы

## 1. Схема данных (Data Model)

```mermaid
erDiagram
    USER ||--o{ SUBSCRIPTION : has
    USER ||--o{ POST : writes
    USER ||--o{ TOPIC : creates
    USER ||--o{ REACTION : gives
    CATEGORY ||--o{ TOPIC : contains
    TOPIC ||--o{ POST : contains
    SUBSCRIPTION ||--|| EXTERNAL_ORDER : linked_to

    USER {
        int id PK
        string username
        string email
        string display_name
        string avatar_url
        int trust_level
        boolean is_club_member
    }

    SUBSCRIPTION {
        int id PK
        int user_id FK
        string source_type "getcourse | stripe | prodamus | cloudpayments"
        string external_email
        datetime valid_until
        string status "active | expired | pending"
    }

    CATEGORY {
        int id PK
        string name
        string slug
        boolean is_private
        int required_trust_level
    }

    TOPIC {
        int id PK
        int category_id FK
        string title
        string slug
        int views
        int posts_count
        boolean is_locked
    }

    POST {
        int id PK
        int topic_id FK
        int user_id FK
        text raw_content
        text cooked_html
        datetime created_at
    }
```

---

## 2. Основные REST API эндпоинты

### Публичные / Ознакомительные:
- `GET /api/site.json` — метаданные платформы, доступные типы уведомлений, базовые настройки.
- `GET /api/categories.json` — список категорий (фильтруется в зависимости от статуса подписки пользователя).
- `GET /api/latest.json` — список последних доступных тем с авторами, счетчиками просмотров и ответов.
- `GET /api/t/{id}.json` — поток постов выбранной темы (для платных тем — проверка токена сессии и валидности подписки).

### Личный кабинет и подписка (`club_access`):
- `GET /api/club/account` — статус подписки текущего пользователя, дата окончания, привязанный аккаунт школы/платежки.
- `POST /api/club/verify-email` — отправка проверочного кода на email покупки при несовпадении с email аккаунта.
- `POST /api/club/confirm-code` — подтверждение кода и мгновенная активация доступа к клубу.
- `POST /api/webhooks/payment` — входящий вебхук от платежной системы (Prodamus / GetCourse / CloudPayments / ЮKassa) для автопродления или закрытия доступа при отмене подписки.

### Интерактив и сообщество:
- `POST /api/posts` — создание поста / ответа в тему.
- `POST /api/post_actions` — добавление реакции (лайк, огонь, спасибо и т.д.).
- `GET /api/chat/channels` — список доступных чат-комнат клуба.
- `WS /api/chat/ws` — WebSocket-канал реального времени для сообщений и статусов присутствия.


# Границы и интерфейсы: Реконструкция платформы «ИИ Клуб»

## 1. Правила проекта (Договорились)
- Развёртывание: Docker & Docker-Compose с официальным Discourse launcher / base image.
- Плагин пейволла `club_access`: поддержка GetCourse + универсальный Webhook (Prodamus / ЮKassa / Stripe).
- Хранилище видео: интеграция с Яндекс.Диск + S3/MP4 прямые ссылки.
- Полная совместимость с оригинальными Ember-компонентами и плагинами Discourse.

---

## 2. Границы модулей

### Модуль 1: Инфраструктура Discourse (`infra/`)
- **Что владеет**: Конфигурация запуска Discourse, PostgreSQL 15, Redis 7, Nginx, скрипты сборки контейнера.
- **Что выставляет**:
  - Порт `3000` / `80` / `443` для веб-интерфейса и API.
  - Подключение официальных плагинов: `discourse-chat`, `discourse-reactions`, `discourse-topic-voting`, `discourse-solved`, `discourse-presence`, `poll`, `checklist`.
- **Что скрывает**: Внутренние сокеты и сетевую конфигурацию Docker-bridge.

### Модуль 2: Серверный плагин `discourse-club-access` (`plugins/discourse-club-access/`)
- **Что владеет**: Моделью подписок пользователей, логикой пейволла и интеграцией с внешними платёжками.
- **Что выставляет**:
  - `GET /club/account` -> `{ has_active_subscription: boolean, valid_until: string, linked_email: string }`
  - `POST /club/verify-email` -> `{ email: string }` -> `{ status: "code_sent" }`
  - `POST /club/confirm-code` -> `{ email: string, code: string }` -> `{ status: "activated" }`
  - `POST /webhooks/payment` -> входящие вебхуки оплат -> обновление статуса `ClubSubscription` и добавление/удаление пользователя из группы `club_members`.
  - Защита контроллеров приватных категорий форума.
- **Что скрывает**: Секретные ключи вебхуков и внешние токены API GetCourse.

### Модуль 3: Компонент видеоплеера `iiclub-material-library` (`themes/iiclub-theme/javascripts/discourse/components/`)
- **Что владеет**: Воспроизведением видеозаписей, связкой с Яндекс.Диском/Zoom/Telegram, паузой и таймкодами.
- **Что выставляет**:
  - Шаблон и контроллер плеера с iframe `/club/watch/{post_id}/{video_id}?embed=1`.
  - Шина `postMessage`: приём `{ type: "club-video-resize", height }` и генерация `iiclub:recording-player-resized`.
  - Возобновление просмотра: состояние `{ position, duration }`, кнопка «Продолжить с MM:SS».
  - Полка `/club/watching` («Я смотрю и слушаю»).
- **Что скрывает**: Прямые технические ссылки на потоки видео.

### Модуль 4: Читалка, расшифровки и закладки `iiclub-reader` (`themes/iiclub-theme/assets/reader/`)
- **Что владеет**: Отображением книг и материалов, автодетектом транскриптов и хранением закладок.
- **Что выставляет**:
  - Регулярные выражения автоопределения транскриптов: `/расшифров|транскрип|transcript/i`.
  - ES-модули читалки: `journals.mjs`, `reading.mjs`, `book-formats.mjs` (MD, PDF, EPUB, FB2).
  - Микрозакладки с координатами: `{ page, chapter, block, offset, progress, zoom, anchor }`.
  - API синхронизации: `POST /club/reading/{upload_id}.json`.
  - Полка `/club/library` («Я читаю») с процентом дочитывания.
- **Что скрывает**: Алгоритмы бакетизации скролла (80/160px) и dwell-time таймеры.

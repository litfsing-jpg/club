# ИИ Клуб (Первопроходцы) — Реконструкция платформы сообщества

Проект полноценного клона и реконструкции платформы «ИИ Клуб» на базе **Discourse 2026**, выполненный по результатам глубинного реверс-инжиниринга реального рантайма через **REA** и методологию пошаговой сборки **Autopilot 2.0**.

---

## 🌟 Ключевые возможности

1. **Базовый стек Discourse**:
   - Ядро Discourse с официальными плагинами коммуникации: `discourse-chat`, `discourse-reactions`, `discourse-topic-voting`, `discourse-solved`, `discourse-presence`, `poll`, `checklist`.
   - Реляционная БД PostgreSQL 15, очереди Sidekiq и кэш Redis 7.

2. **Серверный плагин пейволла и подписки (`plugins/discourse-club-access`)**:
   - Личный кабинет проверки подписки: `/club/account`.
   - Подтверждение доступа через аккаунт GetCourse (`edu.malovnik.ru`) или проверочный код на email покупки.
   - Универсальный Webhook (`/club/webhooks/payment`) для интеграции с GetCourse, Prodamus, ЮKassa, Stripe.
   - Автоматическое управление членством в группе `club_members` и защита закрытых категорий.

3. **Медиаплеер и видеотека (`themes/iiclub-theme/.../iiclub-material-library`)**:
   - Адаптивный плеер в изолированном iframe с двусторонней шиной `postMessage` (автоподгонка высоты 240–1400px).
   - Поддержка внешних источников: **Яндекс Диск** (папки и видео), **Zoom Cloud Recordings**, **Telegram** и прямые `.mp4`.
   - Память позиции воспроизведения (возобновление с точностью до секунды): кнопка «Продолжить с MM:SS».
   - Персональная полка начатых видео: `/club/watching` («Я смотрю и слушаю»).

4. **Читалка материалов, расшифровки и закладки (`themes/iiclub-theme/.../iiclub-reader`)**:
   - Автоматическое распознавание транскриптов эфиров по паттернам `/расшифров|транскрип/` и методичек по `/методичк/`.
   - Встроенная читалка для форматов **MD, PDF, EPUB, FB2** прямо в браузере без скачивания файлов.
   - Двухуровневая система закладок:
     - Нативные закладки Discourse по темам.
     - Микрозакладки читалки с точными координатами `{ page, chapter, block, offset, progress, zoom, anchor }`, локальным кэшированием и синхронизацией на сервер.
     - Полка прогресса чтения: `/club/library` («Я читаю») с процентом дочитывания.

---

## 🚀 Быстрый запуск

### Требования
- Docker и Docker Compose v2+
- Git

### 1. Клонирование и запуск
```bash
git clone https://github.com/litfsing-jpg/club.git
cd club

# Запуск окружения (PostgreSQL, Redis, Discourse)
./scripts/setup.sh
```

Либо вручную через Docker Compose:
```bash
docker compose up -d
```

Портал будет доступен по адресу: `http://localhost:3000`.

---

## 📂 Структура проекта

```text
├── docker-compose.yml              # Описание контейнеров Discourse, Postgres, Redis
├── infra/containers/app.yml        # Рецепт Discourse Launcher со списком официальных плагинов
├── scripts/
│   ├── setup.sh                    # Скрипт автоматического первого запуска
│   └── seed_categories.rb          # Посев разделов (Журнал, Доступ в клуб, Анонсы, Эфиры)
├── plugins/discourse-club-access/   # Серверный Rails Engine плагин пейволла и вебхуков
├── themes/iiclub-theme/            # Кастомная тема оформления ИИ Клуба (Ember.js компоненты)
│   ├── javascripts/discourse/      # Компоненты плеера и распознавания материалов
│   └── assets/reader/              # Модули читалки, закладок и форматов (reading.mjs, book-formats.mjs)
├── docs/                           # Отчёты по реверс-инжинирингу и скриншоты
│   ├── deep-investigation-report.md
│   ├── architecture-and-api.md
│   └── screenshots/
└── .autopilot/                     # Полная история прогона Autopilot 2.0 (спецификация, манифест, таски)
```

---

## 📜 Лицензия
MIT

# 03 — Компоненты плеера, читалки и закладок iiclub-theme

**Требования:** R02, R03, R04, R04.1, R05, R06
**Зависит от:** 01, 02
**Зона:** `themes/iiclub-theme/`
**Волна:** 3
**Ревью:** нет
**Модель:** обычная

## Что должно заработать
Ember.js компоненты и скрипты темы `themes/iiclub-theme`:
1. **Плеер `iiclub-material-library`**:
   - Обертка плеера в адаптивный iframe `/club/watch/{post_id}/{video_id}?embed=1`.
   - Слушатель `window.addEventListener("message")` для событий `{ type: "club-video-resize", height }`.
   - Парсинг внешних ссылок (Яндекс.Диск, Zoom, Telegram, прямые MP4 файлы).
   - Запоминание позиции: если позиция $\ge 5$ сек, кнопка меняется на «Продолжить с MM:SS».
   - Персональная полка начатых видео `/club/watching` («Я смотрю и слушаю»).
2. **Читалка и расшифровки `iiclub-reader`**:
   - Автораспознавание расшифровок по регулярке `/расшифров|транскрип/` и методичек по `/методичк/`.
   - Встроенная читалка для форматов MD, PDF, EPUB, FB2 (`journals.mjs`, `book-formats.mjs`).
   - Трекинг дочитывания (`iiclub-material-reading`) с бакетизацией по 80/160px и dwell time.
3. **Двухуровневая система закладок**:
   - Микрозакладки с координатами: `{ page, chapter, block, offset, progress, zoom, anchor }`.
   - Локальный кэш в localStorage + синхронизация на сервер `POST /club/reading/{upload_id}.json`.
   - Полка прогресса чтения `/club/library` («Я читаю»).

## Приёмка
1. Компоненты оформлены в формате Discourse Theme Component (`about.json`, `javascripts/`, `stylesheets/`).
2. В коде плеера присутствует обработка postMessage изменения высоты и таймкода паузы.
3. В читалке присутствуют модули парсинга и синхронизации закладок.

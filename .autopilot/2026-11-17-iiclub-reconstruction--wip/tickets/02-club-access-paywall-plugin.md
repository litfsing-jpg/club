# 02 — Плагин доступа и подписки club_access

**Требования:** R01.1, R07, R08
**Зависит от:** 01
**Зона:** `plugins/discourse-club-access/`
**Волна:** 2
**Ревью:** да — деньги
**Модель:** сильная

## Что должно заработать
Серверный плагин `discourse-club-access` на Ruby on Rails Engine:
- Модель `ClubSubscription` (поля: `user_id`, `status`, `valid_until`, `source_type`, `external_email`).
- Контроллер `ClubAccess::AccountController`:
  - `GET /club/account` — статус подписки, дата окончания, привязанные данные.
  - `POST /club/verify-email` — отправка проверочного кода при несовпадении почты форума и почты покупки.
  - `POST /club/confirm-code` — активация подписки по проверочному коду.
- Вебхук-контроллер `ClubAccess::WebhooksController`:
  - `POST /club/webhooks/payment` — приём уведомлений об оплате (GetCourse / Prodamus / ЮKassa / Stripe).
  - Автоматическое добавление пользователя в группу `club_members` при активной подписке и исключение при окончании срока.
- Защита контроллеров приватных разделов: доступ к закрытым темам блокируется со статусом 403/404, если пользователь не входит в `club_members`.

## Приёмка
1. Структура плагина валидна согласно стандарту Discourse Plugin (`plugin.rb`, `config/routes.rb`, `app/controllers`).
2. При вызове вебхука с валидной сигнатурой пользователь добавляется в группу `club_members`.
3. Тесты или спецификация эндпоинтов покрывают все статусы подписки (`active`, `expired`, `pending`).

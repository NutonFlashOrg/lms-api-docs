# Авторизация (Frontend Guide)

Гайд описывает, как фронтенду корректно работать с нашей авторизацией на базе **Telegram WebApp initData + JWT**.  
**Актуальная логика**: вход возможен **только для уже заведённых в системе пользователей**. Если пользователь отсутствует — сервер вернёт 401.

## Обзор

- **Вход**: Telegram WebApp `initData` → сервер проверяет подпись и срок.
- **Сессии**: короткоживущий **Access JWT** (в заголовке `Authorization: Bearer`), и долгоживущий **Refresh JWT** в **HttpOnly cookie** `refresh_token`.
- **Обновление**: тихий `/v1/auth/refresh` (ротирует refresh и выдаёт новый access).
- **Выход**: `/v1/auth/logout` отзывает текущий refresh и чистит cookie.

## Открытые и защищённые маршруты

Глобальный middleware пропускает **только**:
- `OPTIONS`
- `/v1/auth/*`
- `/docs`, `/docs/json`, `/docs/yaml`, `/docs/static/*`

Все остальные эндпоинты требуют `Authorization: Bearer <accessToken>`.

- Нет/битый токен → **401** (+ заголовок `WWW-Authenticate: Bearer`).
- Токен валиден, но в payload отсутствует `role` → **403**.

## Эндпоинты

### 1) POST `/v1/auth/refresh` — тихое продление сессии

- **Запрос**: без тела. Браузер отправит cookie `refresh_token` автоматически (same‑origin).  
  Для Swagger/тестов можно передать заголовок `X-Refresh-Token`.

- **Ответ (200)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "<JWT>",
    "expiresIn": 900
  }
}
```

- **Ошибки**: `401` — нет/просрочен/отозван refresh.

### 2) POST `/v1/auth/telegram` — вход по Telegram initData

- **Body**:
```json
{ "initData": "<строка от Telegram WebApp>" }
```
- **Логика**:
  - Проверяем подпись и свежесть `initData`.
  - Ищем пользователя **по `telegramId`** или **по `telegramUsername`**.
    - Если нашли по username и у пользователя ещё не привязан `telegramId` — **привязываем**.
    - Если `telegramUsername` изменился — **обновляем**.
  - Если пользователь **не найден** → **401 UNAUTHORIZED** ("Пользователь не зарегистрирован").
  - Если найден — **выдаём Access JWT** и устанавливаем **HttpOnly cookie** `refresh_token`.

- **Set-Cookie**:
```
Set-Cookie: refresh_token=<...>; HttpOnly; SameSite=Strict; Path=/v1/auth; Max-Age=<конфиг>; Secure=<prod>
```

- **Ответ (200)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "<JWT>",
    "expiresIn": 900
  }
}
```

### 3) POST `/v1/auth/logout` — выход

- **Запрос**: без тела. Использует cookie `refresh_token` (или заголовок `X-Refresh-Token`).
- **Действие**: помечает текущий refresh отозванным и очищает cookie.
- **Ответ**: `204 No Content`.

## Жизненный цикл токенов

- **Access JWT** — короткий TTL (секунды в поле `expiresIn`), кладите в `Authorization: Bearer`.
- **Refresh JWT** — длительный TTL, хранится **только** в HttpOnly cookie (`/v1/auth`).  
  На успешном `/v1/auth/refresh` сервер **ротирует** refresh: старый помечается отозванным, новый устанавливается в cookie.

## Рекомендуемый флоу на старте приложения

```
try POST /v1/auth/refresh
  -> 200: используем accessToken
  -> 401: POST /v1/auth/telegram { initData } и используем новый accessToken
```

Дальше для каждого защищённого запроса добавляйте заголовок `Authorization: Bearer <accessToken>`.
При получении `401` (действие с истёкшим access) — повторяйте `/v1/auth/refresh`.

## Формат ошибок

Любая ошибка авторизации следует единому формату:
```jsonc
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED|FORBIDDEN|BAD_REQUEST",
    "message": "Текст ошибки",
    "traceId": "uuid"
  }
}
```

## Частые вопросы

- **Нужны ли «инвайты»?** Нет. Сейчас вход доступен **только** уже существующим пользователям (создаются админом). Если вас нет в базе — будет `401`.
- **Где брать `initData`?** Телеграм Mini App отдаёт его при запуске вашего WebApp.
- **Почему не виден refresh из JS?** Он хранится в HttpOnly cookie и недоступен фронту по соображениям безопасности.
- **Можно ли несколько устройств?** Да, refresh хранится на устройстве, ротация привязана к конкретной cookie.

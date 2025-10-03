# Стандарты REST API

Этот документ фиксирует единые правила разработки и использования REST API для нашего проекта (**Fastify JS + Ajv + @fastify/swagger + Prisma + BullMQ + SSE**).  
Ниже отражены **актуальные контракты** с учётом базовых схем и авторизации.

## 1) Общие принципы

- **Явные контракты.** Каждый роут имеет JSON‑Schema на `body`, `query`, `params`, `response`. Документация генерируется автоматически (Swagger).
- **Единый envelope.** Все ответы обёрнуты в `{ success, ... }`.
- **Понятные HTTP‑коды.** Используем стандартные коды и их семантику (см. ниже).
- **Унифицированная пагинация.** Только **page‑based** (`limit` + `page`), **без курсоров**.
- **Строгая валидация.** Только whitelisted‑поля в query; дополнительные поля запрещены.
- **Версионирование.** Путь начинается с `/v1`. Изменение контракта — только через новую версию.
- **Часовой пояс и даты.** Внешний контракт — ISO 8601 в UTC (`2025-10-03T12:00:00Z`).

## 2) Формат ответа (envelope)

### 2.1 Успех

```jsonc
{
  "success": true,
  "data": { /* объект или массив */ }
}
```

- **GET single** → `data` — объект.
- **GET list** → `data` — массив **и** объект `meta.pagination` (см. ниже).

Если у ответа требуется пагинация/метаданные, используется расширенная форма:

```jsonc
{
  "success": true,
  "data": [ /* элементы */ ],
  "meta": {
    "pagination": {
      "limit": 20,
      "currentPage": 2,
      "totalPages": 13,
      "totalItems": 250
    }
  }
}
```

> Для успешных ответов применяется одна из двух фабрик:
> - `successResponseSchema(dataSchema)` — `{ success: true, data }`.
> - `successResponseWithMetaSchema(itemsSchema)` — `{ success: true, data, meta.pagination }` для списков.

### 2.2 Ошибка

```jsonc
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "Некорректные входные данные",
    "details": [
      { "path": "query.limit", "message": "Должно быть >= 1" }
    ],
    "traceId": "b5c2a1d4-..."
  }
}
```

Требуемые поля ошибки: `code`, `message`, `traceId`. Массив `details[]` опционален и используется для валидаций/бизнес‑правил.

## 3) HTTP‑коды

### 2xx
- **200 OK** — успешный GET/PUT/PATCH; тело содержит `data`.
- **201 Created** — успешный POST; заголовок `Location: /v1/<collection>/<id>` обязателен; тело содержит созданный объект в `data`.
- **204 No Content** — успешный запрос без тела (обычно DELETE, иногда PATCH/PUT).

### 4xx
- **400 BAD_REQUEST** — неверный запрос/валидация данных.
- **401 UNAUTHORIZED** — нет/недействительный JWT, либо не прошла проверка Telegram initData.
- **403 FORBIDDEN** — JWT есть, но нет роли или прав.
- **404 NOT_FOUND** — объект не найден.
- **409 CONFLICT** — конфликт состояния/уникальности.
- **429 RATE_LIMITED** — превышены лимиты частоты.

### 5xx
- **500 INTERNAL_ERROR** — непредвиденная ошибка.
- **503 UNAVAILABLE** — недоступность внешних зависимостей/деградация.

## 4) Пагинация, сортировка, фильтры

### 4.1 Пагинация (page‑based)

Запрос: `GET /v1/<resource>?limit=20&page=2`

- `limit` — целое `1..100` (по умолчанию `20`).
- `page` — целое `>=1` (по умолчанию `1`).

Ответ всегда содержит `meta.pagination` с полями **ровно**:

```jsonc
{
  "pagination": {
    "limit": 20,
    "currentPage": 2,
    "totalPages": 13,
    "totalItems": 250
  }
}
```

Если `page` выходит за диапазон — возвращаем пустой массив `data: []` и валидную `meta.pagination`.

### 4.2 Сортировка

- `by` — одно из разрешённых полей для ресурса (whitelist).
- `order` — `asc|desc` (по умолчанию задаётся ресурсом).

### 4.3 Фильтры

- Разрешены **только на списках** (`GET /v1/<resource>`).
- Синтаксис: простые равенства или операторы в скобках:
  - `field=value` → `eq`
  - `field=value1&field=value2` → `in`
  - `field[op]=value` → операторы `gte|gt|lte|lt|startsWith|contains` (в завимости от поля).
- Можно задавать паттерны через `patternProperties` в JSON‑Schema, например:
  - `^title\[(startsWith|contains)\]$`
  - `^(createdAt|updatedAt)\[(gte|gt|lte|lt)\]$`
  - `^id\[(gte|gt|lte|lt)\]$`
- **Single GET (`/v1/<resource>/:id`) не принимает никаких фильтров/сортиовок.**

### 4.4 Запрет лишних полей в query

`additionalProperties: false` — любые неизвестные параметры запроса отвергаются с `400 BAD_REQUEST` и `details[]`.

## 5) Trace Id

- Каждый запрос получает уникальный `traceId` (совпадает с request id Fastify).
- В ответах с ошибкой он **обязателен** в `error.traceId`.
- Рекомендуется также дублировать в заголовке `X-Trace-Id`.

## 6) CRUD‑семантика

- **GET `/collection`** → `200 OK`, `data: []` (возможно пусто) + `meta.pagination`.
- **GET `/collection/:id`** → `200 OK` или `404 Not Found`.
- **POST `/collection`** → `201 Created`, `Location`, `data` — созданный объект. Конфликты → `409`.
- **PUT `/collection/:id`** → `200` (`data` — заменённый объект) или `204`. Нет объекта → `404`.
- **PATCH `/collection/:id`** → `200`/`204`. Нет объекта → `404`.
- **DELETE `/collection/:id`** → `204`. Нет объекта → `404`. Конфликт FK → `409`.

## 7) Авторизация и открытые пути

- Глобальный хук требует **Bearer JWT** на всех путях, кроме:
  - `OPTIONS`
  - `/v1/auth/*`
  - `/docs`, `/docs/json`, `/docs/yaml`, `/docs/static/*`
- Если JWT невалиден/отсутствует → `401` + заголовок `WWW-Authenticate: Bearer`.
- Если роль в JWT отсутствует → `403 FORBIDDEN`.

## 8) Документация

- Swagger UI: **`/docs`**
- OpenAPI: **`/docs/json`** (JSON) и **`/docs/yaml`** (YAML)
- Все контракты и примеры ответов отражаются в Swagger.

## 9) Примеры

### 9.1 Список с пагинацией и сортировкой
```
GET /v1/scenarios?limit=20&page=3&by=updatedAt&order=desc&title[contains]=CRM
```
Успех `200`:
```jsonc
{
  "success": true,
  "data": [ /* ... */ ],
  "meta": { "pagination": { "limit": 20, "currentPage": 3, "totalPages": 5, "totalItems": 84 } }
}
```

### 9.2 Создание
```
POST /v1/practices
```
Успех `201` + `Location: /v1/practices/500`:
```jsonc
{ "success": true, "data": { "id": 500, "title": "..." } }
```

### 9.3 Ошибка валидации
```jsonc
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST",
    "message": "Неверные параметры запроса",
    "details": [{ "path": "query.page", "message": "Должно быть >= 1" }],
    "traceId": "b5c2a1d4-..."
  }
}
```

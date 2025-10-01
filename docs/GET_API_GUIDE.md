
# GET API — Гайд для фронтенда (v1)

Этот документ описывает, **как работать с GET-запросами** для всех сущностей бэкенда. Во всех ресурсах действует единый паттерн:

- **`GET /v1/<resource>`** — список объектов с **курсорной пагинацией**, сортировкой и фильтрами.
- **`GET /v1/<resource>/:id`** — один объект по первичному ключу `id` (везде целое число).

> Сейчас все GET-запросы возвращают «легкие» объекты **без включённых связей** (ассоциированных таблиц). По запросу фронтенда мы добавим поддержку `?include=...` в следующих апдейтах.

---

## 1) Унифицированные параметры запросов
get-api-guide.md
### Пагинация (cursor-based)
- `limit` — количество элементов (по умолчанию зависит от ресурса, обычно `20`, максимум — из конфигурации ресурса).
- `cursor` — якорь (значение `id` последнего/первого элемента предыдущего ответа).
- `dir` — направление постраничного чтения: `next` (по умолчанию) или `prev`.
- `withCount` — если `true|1`, вернёт ещё `total` и `totalPages` в `meta.pagination`.

**Как это работает**
1. Первый запрос: без `cursor` → получаем первую страницу.
2. Для следующей страницы используем `meta.pagination.nextCursor` и `dir=next`.
3. Для предыдущей страницы используем `meta.pagination.prevCursor` и `dir=prev`.
4. При смене сортировки/фильтров курсор **сбрасываем** (начинаем заново).

**Ответ `meta.pagination`**
```json
{
  "pagination": {
    "limit": 20,
    "prevCursor": "123",
    "nextCursor": "168",
    "hasPrev": true,
    "hasNext": true,
    "total": 237,        // если withCount=true
    "totalPages": 12,    // если withCount=true
    "dir": "next"
  },
  "sort": { "by": "createdAt", "order": "desc" },
  "filters": { "title[contains]": "CRM" } // эхо переданных фильтров
}
```
- `hasPrev/hasNext` вычисляются точно, без «угадываний».
- Курсор — это **значение PK** (`id`) последнего/первого элемента, а стабильность при сортировке обеспечивается тай-брейком по `id` (двухполевая сортировка: `orderBy: [{by}, {id}]`).

### Сортировка
- `by` — ключ сортировки (разрешён только из набора для ресурса).
- `order` — `asc|desc` (по умолчанию зависит от ресурса).

### Фильтры
Для каждого ресурса есть **белый список полей и операторов**. Поддерживаются два синтаксиса:
- Простое равенство / множественный выбор:
  - `field=value` → `eq`
  - `field=value1&field=value2` → `in`
- Операторы в скобках: `field[op]=value`
  Операторы:
  `eq`, `in`, `gte`, `gt`, `lte`, `lt`, `startsWith`, `contains`
  (регистр для строковых `startsWith|contains` часто игнорируется — зависит от ресурса).

**Типы значений:**
- `number`, `boolean` (`true|false|1|0`), `date` (ISO 8601, например `2025-09-30T00:00:00Z`), `enum` (проверяется против списка).

**Ошибки валидации фильтров/сортировки** приводят к `400 BAD_REQUEST` с деталями.

---

## 2) Шаблоны эндпоинтов

Префиксы монтируются в приложении: `app.register(routes, { prefix: '/v1/<resource>' })`.
Далее везде предполагаем базовые пути из префиксов:

- `GET /v1/users` • `GET /v1/users/:id`
- `GET /v1/clients` • `GET /v1/clients/:id`
- `GET /v1/mop-profiles` • `GET /v1/mop-profiles/:id`
- `GET /v1/license-slots` • `GET /v1/license-slots/:id`
- `GET /v1/license-assignment-history` • `GET /v1/license-assignment-history/:id`
- `GET /v1/user-invites` • `GET /v1/user-invites/:id`
- `GET /v1/skills` • `GET /v1/skills/:id`
- `GET /v1/cases` • `GET /v1/cases/:id`
- `GET /v1/scenarios` • `GET /v1/scenarios/:id`
- `GET /v1/practices` • `GET /v1/practices/:id`
- `GET /v1/practice-observers` • `GET /v1/practice-observers/:id`
- `GET /v1/practice-skills` • `GET /v1/practice-skills/:id`
- `GET /v1/evaluation-tasks` • `GET /v1/evaluation-tasks/:id`
- `GET /v1/evaluation-submissions` • `GET /v1/evaluation-submissions/:id`
- `GET /v1/participant-eval-summaries` • `GET /v1/participant-eval-summaries/:id`
- `GET /v1/rep-events` • `GET /v1/rep-events/:id`
- `GET /v1/user-skill-summaries` • `GET /v1/user-skill-summaries/:id`
- `GET /v1/user-skill-events` • `GET /v1/user-skill-events/:id`
- `GET /v1/courses` • `GET /v1/courses/:id`
- `GET /v1/course-client-access` • `GET /v1/course-client-access/:id`
- `GET /v1/modules` • `GET /v1/modules/:id`
- `GET /v1/lessons` • `GET /v1/lessons/:id`
- `GET /v1/lesson-contents` • `GET /v1/lesson-contents/:id`
- `GET /v1/quizzes` • `GET /v1/quizzes/:id`
- `GET /v1/quiz-questions` • `GET /v1/quiz-questions/:id`
- `GET /v1/quiz-answer-options` • `GET /v1/quiz-answer-options/:id`
- `GET /v1/quiz-attempts` • `GET /v1/quiz-attempts/:id`
- `GET /v1/user-course-progress` • `GET /v1/user-course-progress/:id`
- `GET /v1/user-lesson-statuses` • `GET /v1/user-lesson-statuses/:id`
- `GET /v1/user-module-statuses` • `GET /v1/user-module-statuses/:id`
- `GET /v1/user-course-statuses` • `GET /v1/user-course-statuses/:id`
- `GET /v1/storage-objects` • `GET /v1/storage-objects/:id`

> Для детального списка разрешённых полей/операторов и сортировок — смотрите соответствующие `*.list.config.js` в фичах.

---

## 3) Ответы и ошибки

### Успех
- **Списки**: `200 OK` → `{ success:true, data:[...], meta:{ ... } }`
- **Один объект**: `200 OK` → `{ success:true, data:{...} }`

### Ошибки (единый формат)
```json
{
  "success": false,
  "error": {
    "code": "BAD_REQUEST|NOT_FOUND|CONFLICT|INTERNAL_ERROR|...",
    "message": "Human‑readable",
    "details": [ { "path": "...", "message": "..." } ],
    "traceId": "uuid"
  }
}
```
Частые случаи:
- `404 NOT_FOUND` — объект по `/:id` не найден.
- `404 NOT_FOUND` — `cursor` невалиден/удалён (при листинге).
- `400 BAD_REQUEST` — неразрешённая сортировка/фильтр/тип значения.

---

## 4) Примеры по ресурсам

> В примерах используются реальные операторы фильтров и курсорная навигация.
> Значения `id`, курсоров и поля зависят от данных и конкретной `list.config` ресурса.

### Users
- **Список**: первые 20 пользователей, сортировка по `id` по возрастанию (по умолчанию)
```
GET /v1/users?limit=20
```
- **Следующая страница**:
```
GET /v1/users?limit=20&cursor=20&dir=next
```
- **Фильтр по роли + поиск по username (prefix)**:
```
GET /v1/users?role=ADMIN&telegramUsername[startsWith]=bot_
```
- **Один объект**:
```
GET /v1/users/123
```

### Clients
- **Список активных клиентов уровня 4, отсортированных по `name`**:
```
GET /v1/clients?status=ACTIVE&level=4&by=name&order=asc&limit=50
```
- **Диапазон по дате активации**:
```
GET /v1/clients?activatedAt[gte]=2025-01-01T00:00:00Z&activatedAt[lte]=2025-12-31T23:59:59Z
```
- **Один объект**: `GET /v1/clients/42`

### Mop Profiles
- **Список по `clientId`**:
```
GET /v1/mop-profiles?clientId=7
```
- **Один объект**: `GET /v1/mop-profiles/15`

### License Slots
- **Неистёкшие слоты клиента, ближайшие к истечению**:
```
GET /v1/license-slots?clientId=7&expiresAt[gt]=2025-10-01T00:00:00Z&by=expiresAt&order=asc
```
- **Один объект**: `GET /v1/license-slots/99`

### License Assignment History
- **История по слоту**:
```
GET /v1/license-assignment-history?licenseSlotId=99&by=assignedAt&order=desc
```
- **Один объект**: `GET /v1/license-assignment-history/1001`

### User Invites
- **Инвайты по username (case‑insensitive contains)**:
```
GET /v1/user-invites?targetUsername[contains]=alex
```
- **По статусу и компании**:
```
GET /v1/user-invites?status=ACCEPTED&clientId=7
```
- **Один объект**: `GET /v1/user-invites/55`

### Skills
- **Поиск по префиксу**:
```
GET /v1/skills?name[startsWith]=C
```
- **Несколько `id` (IN)**:
```
GET /v1/skills?id=1&id=2&id=3
```
- **Один объект**: `GET /v1/skills/3`

### Cases
- **Фултекстовые поля через `contains` (осторожно)**:
```
GET /v1/cases?title[contains]=CRM&sellerTask[contains]=обработать
```
- **Диапазон по `updatedAt`**:
```
GET /v1/cases?updatedAt[gte]=2025-01-01T00:00:00Z&updatedAt[lt]=2026-01-01T00:00:00Z
```
- **Один объект**: `GET /v1/cases/10`

### Scenarios
- **По типу практики и статусу**:
```
GET /v1/scenarios?practiceType=WITH_CASE&status=PUBLISHED&by=updatedAt&order=desc
```
- **Один объект**: `GET /v1/scenarios/7`

### Practices
- **Запланированные практики конкретного сценария**:
```
GET /v1/practices?scenarioId=7&status=SCHEDULED&by=startAt&order=asc&limit=50
```
- **Фильтр по ролям**:
```
GET /v1/practices?sellerUserId=123&moderatorUserId=456
```
- **Один объект**: `GET /v1/practices/500`

### Practice Observers
- **Наблюдатели практики**:
```
GET /v1/practice-observers?practiceId=500
```
- **Один объект**: `GET /v1/practice-observers/12`

### Practice Skills
- **Навыки практики**:
```
GET /v1/practice-skills?practiceId=500
```
- **Один объект**: `GET /v1/practice-skills/25`

### Evaluation Tasks
- **Задачи к оценке по практикам и оценщику**:
```
GET /v1/evaluation-tasks?evaluatorUserId=321&status=PENDING&by=deadlineAt&order=asc
```
- **Один объект**: `GET /v1/evaluation-tasks/100`

### Evaluation Submissions
- **Сданные формы за период**:
```
GET /v1/evaluation-submissions?createdAt[gte]=2025-09-01T00:00:00Z&createdAt[lte]=2025-09-30T23:59:59Z
```
- **Один объект**: `GET /v1/evaluation-submissions/77`

### Participant Evaluation Summaries
- **Сводки по пользователю**:
```
GET /v1/participant-eval-summaries?userId=123&by=computedAt&order=desc
```
- **Один объект**: `GET /v1/participant-eval-summaries/5`

### Rep Events
- **Последние репутационные события пользователя**:
```
GET /v1/rep-events?userId=123&by=createdAt&order=desc&limit=50
```
- **Один объект**: `GET /v1/rep-events/9001`

### User Skill Summaries
- **Срез по конкретному навыку**:
```
GET /v1/user-skill-summaries?skillId=3&by=updatedAt&order=desc
```
- **Один объект**: `GET /v1/user-skill-summaries/42`

### User Skill Events
- **Позитивные события по навыку**:
```
GET /v1/user-skill-events?skillId=3&result=POSITIVE&by=createdAt&order=desc
```
- **Один объект**: `GET /v1/user-skill-events/31415`

### Courses
- **Только интро-курсы**:
```
GET /v1/courses?isIntro=true&by=createdAt&order=desc
```
- **Фильтр по области доступа (enum или массив)**:
```
GET /v1/courses?accessScope=ALL&accessScope=CLIENTS_LIST
```
- **Один объект**: `GET /v1/courses/1`

### Course Client Access
- **Доступ клиента к курсам**:
```
GET /v1/course-client-access?clientId=7
```
- **Один объект**: `GET /v1/course-client-access/55`

### Modules
- **Модули курса, отсортированные по порядку**:
```
GET /v1/modules?courseId=1&by=orderIndex&order=asc
```
- **Один объект**: `GET /v1/modules/10`

### Lessons
- **Уроки модуля (по порядку)**:
```
GET /v1/lessons?moduleId=10&by=orderIndex&order=asc
```
- **Один объект**: `GET /v1/lessons/100`

### Lesson Contents
- **Контент по id урока**:
```
GET /v1/lesson-contents?lessonId=100
```
- **Один объект**: `GET /v1/lesson-contents/77`

### Quizzes
- **Тесты урока или модуля**:
```
GET /v1/quizzes?lessonId=100
GET /v1/quizzes?moduleId=10
```
- **Один объект**: `GET /v1/quizzes/5`

### Quiz Questions
- **Вопросы теста по порядку**:
```
GET /v1/quiz-questions?quizId=5&by=order&order=asc
```
- **Один объект**: `GET /v1/quiz-questions/12`

### Quiz Answer Options
- **Ответы вопроса, только правильные**:
```
GET /v1/quiz-answer-options?questionId=12&isCorrect=true
```
- **Один объект**: `GET /v1/quiz-answer-options/33`

### Quiz Attempts
- **Попытки пользователя по тесту, последние сверху**:
```
GET /v1/quiz-attempts?quizId=5&userId=123&by=startedAt&order=desc
```
- **Один объект**: `GET /v1/quiz-attempts/99`

### User Course Progress
- **Прогресс юзера по всем курсам**:
```
GET /v1/user-course-progress?userId=123&by=id&order=asc
```
- **Один объект**: `GET /v1/user-course-progress/7`

### User Lesson Statuses
- **Завершённые уроки пользователя за период**:
```
GET /v1/user-lesson-statuses?userId=123&completedAt[gte]=2025-01-01T00:00:00Z
```
- **Один объект**: `GET /v1/user-lesson-statuses/11`

### User Module Statuses
- **Завершённые модули пользователя**:
```
GET /v1/user-module-statuses?userId=123
```
- **Один объект**: `GET /v1/user-module-statuses/12`

### User Course Statuses
- **Сданные курсы пользователя**:
```
GET /v1/user-course-statuses?userId=123&passed=true
```
- **Один объект**: `GET /v1/user-course-statuses/13`

### Storage Objects
- **Поиск по bucket и префиксу objectKey (CI)**:
```
GET /v1/storage-objects?bucket=public&objectKey[startsWith]=avatars/
```
- **Один объект**: `GET /v1/storage-objects/100500`

---

## 5) Расширенные примеры курсорной навигации

### Поток «вперёд»
```http
# 1. Первая страница
GET /v1/cases?limit=20&by=updatedAt&order=desc&withCount=1

# 2. Следующая
GET /v1/cases?limit=20&by=updatedAt&order=desc&cursor=<nextCursor из предыдущего>&dir=next
```

### Поток «назад»
```http
# 1. Текущая страница (имеем prevCursor в meta)
GET /v1/lessons?moduleId=10&limit=10&by=orderIndex&order=asc

# 2. Назад
GET /v1/lessons?moduleId=10&limit=10&by=orderIndex&order=asc&cursor=<prevCursor>&dir=prev
```

### Смена сортировки/фильтра
```http
# После перехода на "3-ю страницу" решаем отсортировать иначе — СБРАСЫВАЕМ cursor!
GET /v1/quiz-attempts?userId=123&by=startedAt&order=desc&limit=20
GET /v1/quiz-attempts?userId=123&by=scorePercent&order=desc&limit=20  # без cursor
```

---

## 6) Памятка по массивам и операторам

- `IN`: передавайте параметр несколько раз
  `?id=1&id=2&id=3`
- Числа/булевы/даты приводятся автоматически; валидация типов — на бэке.
- Строковые `contains/startsWith` по многим ресурсам — **case‑insensitive** (см. конкретный `list.config.js`).

---

## 7) Что под капотом (для ориентира)

- Нормализация query → `parseQuery` (лимит, сортировка, where, `filtersEcho`, `withCount`).
- По курсору: корректный **seek** вперёд/назад с тай‑брейком по PK и обратным `orderBy` для `dir=prev`.
- Единый ответ: `data + meta.pagination` (`nextCursor`, `prevCursor`, `hasNext`, `hasPrev`, `total*`), `sort`, `filters`.

---

## 8) Roadmap

- `?include=...` для детальных представлений и «тонкого» выбора связей.
- Преднастроенные `views`: например, `GET /v1/practices?view=calendar`.

Если чего-то не хватает — напишите, расширим конфиг конкретного ресурса.

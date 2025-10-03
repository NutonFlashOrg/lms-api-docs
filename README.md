# LMS API Docs & Local Backend Setup

Этот репозиторий предназначен для фронтенд-разработчиков.  
Он содержит документацию по API и конфигурацию `docker-compose.yml`, позволяющую локально поднять **бэкенд** и **базу данных** без доступа к исходному коду.

---

## 📦 Docker image backend

Backend собирается и публикуется автоматически в GitHub Container Registry (GHCR):

👉 [Актуальные образы](https://github.com/NutonFlashOrg/lms_tg_app/pkgs/container/lms_tg_app)

Основной тег для фронта:

```
ghcr.io/nutonflashorg/lms_tg_app:staging
```

---

## ⚙️ Предварительные требования

1. **Docker** и **Docker Compose** установлены локально.  
   Проверка:

   ```bash
   docker --version
   docker compose version
   ```

2. Доступ к образу в GHCR.  
   Для этого нужно сгенерировать **Personal Access Token (PAT)** с правами `read:packages` (обычный **classic PAT** подойдёт).  
   После генерации токена — залогиньтесь:

   ```bash
   echo YOUR_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

   > ⚠️ Обратите внимание: вы должны быть добавлены в организацию `NutonFlashOrg` или иметь доступ к пакету, иначе даже с токеном `docker pull` вернёт ошибку.

---

## 🚀 Запуск

1. Склонируй этот репозиторий:

   ```bash
   git clone https://github.com/NutonFlashOrg/lms-api-docs.git
   cd lms-api-docs
   ```

2. Подготовь файл окружения:

   ```bash
   cp .env.sample .env.local
   ```

   В `.env.local` уже будут значения по умолчанию:

   ```dotenv
   # Environment
   NODE_ENV=development
   PORT=3000
   HOST=0.0.0.0

   # Database
   DATABASE_URL=mysql://root:root@db:3306/lms_tg_app

   # Redis
   REDIS_HOST=redis
   REDIS_PORT=6379
   REDIS_PASSWORD=
   REDIS_DB=0

   # JWT Configuration (Required)
   # Generate a secure random string at least 32 characters long
   JWT_ACCESS_SECRET=2f1c4a8e9d0b7c6e5f3a2d1c9b8e7a6d5c4b3a29181726354433221100ffeedd
   JWT_ACCESS_EXPIRES_IN=7d
   JWT_REFRESH_EXPIRES_IN=30d

   # Telegram
   TELEGRAM_BOT_TOKEN=8125124336:AAExd_lHKu4BBo7v6iPsbO7kV8qM1wHknj4
   TELEGRAM_WEBHOOK_URL=http://localhost:3000

   # MinIO/S3 Storage
   MINIO_ENDPOINT=minio
   MINIO_PORT=9000
   MINIO_ACCESS_KEY=minioadmin
   MINIO_SECRET_KEY=minioadmin
   MINIO_BUCKET=lms-storage
   MINIO_USE_SSL=false

   # Rate Limiting
   RATE_LIMIT_MAX=100
   RATE_LIMIT_WINDOW=1 minute

   # CORS
   CORS_ORIGIN=*
   CORS_CREDENTIALS=true
   ```

   > ⚠️ Обрати внимание: в `DATABASE_URL` хост должен быть `db` — так контейнер backend свяжется с контейнером базы из `docker-compose`.

3. Подними сервисы:

   ```bash
   docker compose pull
   docker compose up
   ```

4. Бэкенд будет доступен по адресу:  
   👉 http://localhost:3000

---

## 🛠 API документация

После запуска Swagger UI доступен по адресу:  
👉 http://localhost:3000/docs

Отсюда можно изучить и протестировать все эндпоинты.

---

## 🔑 Тестовая авторизация через initData

Чтобы проверять доступы в Swagger под разными пользователями, можно сгенерировать тестовую строку `initData`:

1. Добавьте вручную пользователя в базу данных (таблица `users`) с нужным `username`.

2. Используйте вспомогательный скрипт для генерации `initData`.  
   В проекте есть файл `scripts/mockInitData.js`.

   Пример запуска:

   ```bash
   node scripts/mockInitData.js <BOT_TOKEN> <TG_ID> <USERNAME>
   ```

   Например:

   ```bash
   node scripts/mockInitData.js 8125124336:AAExd_lHKu4BBo7v6iPsbO7kV8qM1wHknj4 123456 adminuser
   ```

   На выходе вы получите строку вида:

   ```
   user=%7B%22id%22%3A123456%2C%22username%22%3A%22adminuser%22%7D&auth_date=1712345678&hash=abcdef123456...
   ```

3. Скопируйте эту строку `initData` и используйте её для авторизации в Swagger.  
   В Swagger введите её в `/v1/auth/telegram` в поле `initData`, чтобы войти от имени созданного пользователя.

---

## 🧹 Управление контейнерами

- Остановить:

  ```bash
  docker compose down
  ```

- Перезапустить с пересборкой:
  ```bash
  docker compose pull
  docker compose up --force-recreate
  ```

---

## 📌 Замечания

- Все данные в базе хранятся внутри volume `dbdata`.  
  Чтобы очистить БД:

  ```bash
  docker compose down -v
  ```

- Если образ обновился, достаточно выполнить:
  ```bash
  docker compose pull backend
  docker compose up -d
  ```

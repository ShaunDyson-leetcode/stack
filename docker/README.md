## Docker - Build

### 1. update `.env` in `docker/setup`

```sh
cd docker/setup
cp .env.development .env
```

1. Create tokens

```sh
cd docker/setup
pnpm i --ignore-workspace
pnpm tsx scripts/generateKeys.ts
```
svix-server jwt generate
2. set ips

`NEXT_PUBLIC_STACK_URL`, `NEXT_PUBLIC_STACK_SVIX_SERVER_URL` cannot be localhost or 127.0.0.1, for example
```
NEXT_PUBLIC_STACK_URL=http://192.168.1.1:8102
NEXT_PUBLIC_STACK_SVIX_SERVER_URL=http://192.168.1.1:8113
NEXT_PUBLIC_STACK_HEAD_TAGS=[{ "tagName": "script", "attributes": {}, "innerHTML": "// insert head tags here" }]
```

3. sentry

Create sentry auth tokens by [sentry manual setup](https://docs.sentry.io/platforms/javascript/guides/nextjs/manual-setup), get
```
NEXT_PUBLIC_SENTRY_DSN=
NEXT_PUBLIC_SENTRY_ORG=
NEXT_PUBLIC_SENTRY_PROJECT=
SENTRY_AUTH_TOKEN=
```

4. generate builder env `builder/.env`

```sh
cd docker/setup
pnpm dotenv -c -- tsx scripts/generateBuilderEnv.ts
```

copy it to `docker/builder/.env`

5. build
```sh
cd docker/builder
docker compose build
```

## Services

### 1. generate dashboard `.env.dashboard`
```sh
cd docker/setup
pnpm dotenv -c -- tsx scripts/generateDashboardEnv.ts
```

### 2. .env.backend

- copy from build/.env
  - STACK_SERVER_SECRET
  - STACK_SVIX_API_KEY
- config emails STACK_EMAIL_

### 3.env

```sh
cd docker/services
cp .env.development .env
```
- copy from build/.env
  - POSTGRES_STACKFRAME_PASSWORD
  - POSTGRES_SVIX_PASSWORD

### 4. .env.sentry

- copy from build/.env

### 5. start

```sh
cd docker/services
docker compose up -d
```

### 6. init data

```sh
cd docker/setup
cp -r ../../apps/backend/prisma/ .
pnpm prisma generate
pnpm prisma migrate deploy
pnpm dotenv -c -- tsx scripts/seed.ts
```
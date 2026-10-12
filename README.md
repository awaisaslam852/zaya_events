# Zaya Events

Multi-role event planning platform: customers and vendors share one Flutter app; admins use the web portal; vendors also have a dedicated web app.

| App | Path | Default URL |
| --- | --- | --- |
| API | `apps/api` | http://localhost:4000 |
| Admin web | `apps/admin-web` | http://localhost:5173 |
| Vendor web | `apps/vendor-web` | http://localhost:5174 |
| Mobile (customer + vendor) | `mobile/` | Flutter |

API responses always use `{ "success": true, "data": ... }` or `{ "success": false, "error": { "code", "message" } }`. Translatable fields are `{ "en", "ar" }`.

## Folder layout

```
apps/                 Node backend + web panels (not mixed with Flutter)
  api/                Express API
  admin-web/          Admin portal
  vendor-web/         Vendor portal
mobile/               Flutter customer + vendor app
docs/                 Postman collection
```

## Prerequisites

- Node.js 20.11+
- [pnpm](https://pnpm.io) 9.15.4 (`corepack enable`)
- Docker (Postgres 16 + Redis 7)
- Flutter SDK (Dart 3.11+). Local path used in this workspace: `/Volumes/Projects/development/flutter/bin/flutter`

## First-time setup

Step-by-step for **VS Code** (software install, Docker, API, admin, vendor): see **[LOCAL_SETUP.md](./LOCAL_SETUP.md)**.

```bash
cp .env.example .env
# Edit JWT secrets (min 32 chars) and any provider keys.

docker compose up -d postgres redis
pnpm install
pnpm db:generate
pnpm db:migrate
pnpm db:seed
```

Seeded admin (override with `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD`):

- Email: `admin@zayaevents.com`
- Password: `ChangeMeAdmin!123`

Vendor demo passwords default to `ChangeMeVendor!123` (see `apps/api/prisma/seed.ts`).

## Environment variables

Copy `.env.example`. Important groups:

- **Runtime:** `NODE_ENV`, `PORT`, `API_URL`, `ADMIN_WEB_URL`, `VENDOR_WEB_URL`, `CORS_ORIGINS`
- **Data:** `DATABASE_URL`, `REDIS_URL`, `POSTGRES_*` (Compose)
- **Auth:** `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` (each ≥ 32 characters), `BCRYPT_ROUNDS`
- **Storage:** see [STORAGE.md](./STORAGE.md)
- **Agora:** see [AGORA.md](./AGORA.md)
- **Integrations (one line each):** `FLIGHTS_PROVIDER`, `HOTELS_PROVIDER`, `WHATSAPP_PROVIDER`, `OPENAI_PROVIDER`, `MAPS_PROVIDER` (`mock` or the real driver). Real credentials (`AMADEUS_*`, `BOOKINGCOM_*`, `OPENAI_API_KEY`, …) stay in `.env`.
- **Payments / push / mail:** `STRIPE_*`, `FCM_*`, `SMTP_*`

Never commit `.env`.

## Run commands

### Full local stack (API + admin + vendor web + Postgres + Redis)

```bash
docker compose up --build
```

- API: http://localhost:4000 (`/health`, `/api/docs`)
- Admin: http://localhost:5173
- Vendor web: http://localhost:5174

Optional S3-compatible MinIO (DigitalOcean Spaces emulation):

```bash
docker compose --profile spaces up -d minio
```

Console: http://localhost:9001 (see [STORAGE.md](./STORAGE.md)).

### API (dev)

```bash
docker compose up -d postgres redis
pnpm dev:api
```

- Lint: `pnpm --filter @zaya/api lint`
- Typecheck: `pnpm --filter @zaya/api typecheck`
- Test (needs Postgres + Redis): `pnpm test:api`
- Build: `pnpm build:api`
- Prisma Studio: `pnpm db:studio`

### Admin web

```bash
pnpm dev:admin
```

Vite proxy/API base: `VITE_API_URL` (default `http://localhost:4000`).

- Lint / typecheck / build: `pnpm --filter @zaya/admin-web lint|typecheck|build`

### Vendor web

```bash
pnpm dev:vendor
```

- Lint / typecheck / build: `pnpm --filter @zaya/vendor-web lint|typecheck|build`

### Mobile (customer + vendor, one app)

```bash
cd mobile
flutter pub get
flutter run
# optional: --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
# optional: --dart-define=ADMIN_WEB_URL=http://localhost:5173
# optional: --dart-define=AGORA_APP_ID=<public-app-id>
```

Role is chosen at registration/login. Customers land on `/customer/home`; vendors on `/vendor/dashboard`; admin accounts open the web portal.

- Tests: `cd mobile && flutter test`
- Analyze: `cd mobile && flutter analyze`
- Android: `cd mobile && flutter build apk` / `flutter build appbundle`
- iOS: `cd mobile && flutter build ipa` (macOS)

## Tests

| Surface | Command |
| --- | --- |
| API (Jest + Supertest) | `pnpm test:api` |
| Flutter widgets | `cd mobile && flutter test` |
| CI | `.github/workflows/ci.yml` — lint → typecheck → test → build for api, admin-web, vendor-web, mobile |

API coverage includes auth, booking transitions, availability overlap (`AVAILABILITY_OVERLAP`), Agora RTC tokens, and uploads through the storage adapter.

## API docs

- Swagger UI: http://localhost:4000/api/docs
- Postman: [docs/Zaya-Events.postman_collection.json](./docs/Zaya-Events.postman_collection.json)

## More docs

- [STORAGE.md](./STORAGE.md) — local / SFTP / FTP / Spaces / custom
- [AGORA.md](./AGORA.md) — tokens, 1:1 calls, admin observe
- [DEPLOYMENT.md](./DEPLOYMENT.md) — VPS, cPanel, stores
- [HANDOVER.md](./HANDOVER.md) — delivery checklist

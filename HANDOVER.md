# Handover checklist

Phase 7 finalization is complete. Use this list when transferring the repo.

## Repository

- [ ] `README.md`, `STORAGE.md`, `AGORA.md`, `DEPLOYMENT.md` reviewed
- [ ] `.env.example` matches production keys (no secrets committed)
- [ ] `.env` is gitignored and delivered out of band
- [ ] JWT secrets replaced (`≥ 32` characters)
- [ ] `pnpm install` + `docker compose up -d postgres redis` documented for the client

## Backend (`apps/api`)

- [ ] `pnpm db:migrate` / `prisma migrate deploy` on the target database
- [ ] `pnpm db:seed` only on empty environments
- [ ] Health: `GET /health` and `GET /api/v1/health`
- [ ] Swagger: `/api/docs`
- [ ] Jest: auth, booking machine, availability overlap, Agora tokens, storage upload
- [ ] Rate limiter skips Redis store when `NODE_ENV=test`
- [ ] Storage driver selected (`STORAGE.md`) and a test upload succeeds
- [ ] Agora App ID + certificate set; token endpoint returns `success`
- [ ] Integration providers: mock vs real (`.env` `*_PROVIDER` lines)
- [ ] Stripe webhook secret if payments are live
- [ ] Vendor finance (commission rates, payouts, settlements) admin-only

## Admin web (`apps/admin-web`)

- [ ] `VITE_API_URL` points at production API
- [ ] Login as seeded admin
- [ ] Pagination, i18n (en/ar), uploads, reports
- [ ] Agora observe is subscriber-only

## Vendor web (`apps/vendor-web`) — Phase 4 shipped

- [ ] `VITE_API_URL` set
- [ ] Vendor cannot see commission rates, payouts, or settlements
- [ ] Listings, calendar, requests, chat, earnings (sanitized)

## Mobile (`mobile/`)

- [ ] `cd mobile && flutter test` (login, role nav, venue list, incoming call shell)
- [ ] One binary for customer + vendor; admin opens web portal
- [ ] `--dart-define` for `API_BASE_URL`, `ADMIN_WEB_URL`, `AGORA_APP_ID`
- [ ] Camera / mic permissions on device
- [ ] Play Store AAB and App Store IPA process understood (`DEPLOYMENT.md`)

## Local stack & CI

- [ ] `docker compose up --build` brings up postgres, redis, api, admin-web, vendor-web
- [ ] Optional `docker compose --profile spaces up minio`
- [ ] GitHub Actions: api, admin-web, vendor-web, mobile (lint → typecheck → test → build)
- [ ] Postman: `docs/Zaya-Events.postman_collection.json`

## Client credentials to collect

- [ ] Production domain(s) and TLS
- [ ] Postgres + Redis (or managed)
- [ ] Agora App ID + certificate
- [ ] Storage (cPanel SFTP or DO Spaces keys)
- [ ] Stripe, FCM, WhatsApp Cloud, OpenAI, Google Maps, GDS keys as needed
- [ ] Apple / Google store accounts and signing keys

## Out of scope after Phase 7

No further product phases in this engagement. Follow-ups (store screenshots, production DNS, live GDS wiring) are operations work, not a new build phase.

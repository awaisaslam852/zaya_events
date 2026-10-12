# Deployment

## API + PostgreSQL + Redis

### VPS (Docker, recommended)

1. Provision Ubuntu 22.04+ (2 vCPU / 4 GB is a workable start).
2. Install Docker and Docker Compose.
3. Clone the repo, copy `.env.example` → `.env`, set production values:
   - `NODE_ENV=production`
   - `API_URL=https://api.yourdomain.com`
   - Strong `JWT_*` secrets
   - `DATABASE_URL` pointing at Compose Postgres **or** a managed database
   - `REDIS_URL`
   - `CORS_ORIGINS` = admin + vendor origins
   - Storage + Agora + Stripe + FCM as needed
4. Put TLS in front (Caddy, Nginx, or a load balancer) to `:4000`.
5. Launch:

```bash
docker compose up -d postgres redis api
```

`apps/api/Dockerfile` runs `prisma migrate deploy` then `node dist/index.js`. Mount `zaya_uploads` if `STORAGE_DRIVER=local`.

For a managed Postgres, drop the `postgres` service and set `DATABASE_URL` to the provider URL. Keep Redis for rate limits and sockets, or run Redis on the same VPS.

### cPanel / shared hosting

cPanel is a poor fit for a long-running Node + Socket.IO process, but this pattern works:

1. **PostgreSQL:** use a remote managed DB (or cPanel Postgres if offered). Set `DATABASE_URL`.
2. **Redis:** use Redis Cloud / Upstash; set `REDIS_URL`.
3. **API:** run Node on a VPS, or a cPanel “Node.js app” / Passenger instance with `pnpm --filter @zaya/api start` after `pnpm build:api` and `prisma migrate deploy`.
4. **Uploads:** do **not** rely on ephemeral disk. Set `STORAGE_DRIVER=sftp` or `ftp` into `public_html/uploads` (see [STORAGE.md](./STORAGE.md)), or `spaces` for object storage.
5. Point `api.yourdomain.com` at the Node process; enable HTTPS in cPanel.

Keep Socket.IO sticky sessions if you scale to more than one Node process (Redis adapter is not wired by default — one API instance is the simple production setup).

## Admin web (static)

```bash
cd apps/admin-web
VITE_API_URL=https://api.yourdomain.com pnpm build
```

Deploy `apps/admin-web/dist` to:

- Nginx / Caddy on the VPS
- Cloudflare Pages, Netlify, or S3+CDN
- cPanel `public_html/admin` as static files

SPA fallback: all routes → `index.html`.

Vendor web is the same:

```bash
cd apps/vendor-web
VITE_API_URL=https://api.yourdomain.com pnpm build
```

Serve `apps/vendor-web/dist` at `https://vendors.yourdomain.com`. Add both origins to `CORS_ORIGINS`.

## Flutter — Play Store and App Store

One codebase serves **customer and vendor**. Role is stored on the user (`CUSTOMER` | `VENDOR`). Do not ship two store listings unless product marketing requires it.

Build defines:

```bash
cd mobile
flutter build appbundle \
  --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1 \
  --dart-define=ADMIN_WEB_URL=https://admin.yourdomain.com \
  --dart-define=AGORA_APP_ID=<public-app-id>
```

```bash
cd mobile
flutter build ipa \
  --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1 \
  --dart-define=ADMIN_WEB_URL=https://admin.yourdomain.com \
  --dart-define=AGORA_APP_ID=<public-app-id>
```

### Google Play

1. Create a signing key (`mobile/android/app` keystore) — keep it off git.
2. `cd mobile && flutter build appbundle` → upload the `.aab` in Play Console.
3. Fill Data safety (camera, mic, photos, approximate location if maps are on).
4. Use the same package name as `android/app/build.gradle`.

### Apple App Store

1. Open `mobile/ios/Runner.xcworkspace` in Xcode; set team, bundle id, capabilities (Push, background modes if needed).
2. `cd mobile && flutter build ipa` or archive from Xcode.
3. Camera / microphone usage strings must be present in `Info.plist`.
4. TestFlight first, then submit.

### One app, both roles (production)

- Customers and vendors download the **same** binary.
- Registration chooses `customer` or `vendor`.
- After login, go_router sends vendors to `/vendor/*` and customers to `/customer/*`.
- Admin users are redirected to `ADMIN_WEB_URL` (they do not use the mobile admin UI).
- Optional: use Play / App Store listing copy that mentions both audiences; do not fork the repo per role.

## Checklist before go-live

- [ ] TLS on API and static hosts
- [ ] JWT secrets rotated from the example values
- [ ] `STORAGE_DRIVER` not `local` unless disk is backed up
- [ ] Agora certificate only on the API
- [ ] Stripe webhook URL `https://api.yourdomain.com/api/v1/payments/webhook`
- [ ] FCM service account for push
- [ ] `CORS_ORIGINS` limited to real frontends
- [ ] Database backups and Redis persistence policy

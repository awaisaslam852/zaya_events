# Local backend + admin + vendor (VS Code)

Use this to run **API**, **admin panel**, and **vendor panel** on your computer. You do **not** need Flutter for these three.

| What | URL |
| --- | --- |
| API | http://localhost:4000 |
| API docs (Swagger) | http://localhost:4000/api/docs |
| Admin panel | http://localhost:5173 |
| Vendor panel | http://localhost:5174 |

---

## 1. Software to install

Install these **once**, then restart VS Code.

### Required

1. **Visual Studio Code**  
   https://code.visualstudio.com/

2. **Git**  
   https://git-scm.com/downloads  
   macOS also has Git if Xcode Command Line Tools are installed (`xcode-select --install`).

3. **Node.js 20 LTS** (20.11 or newer, not Node 18)  
   https://nodejs.org/  
   After install, in a terminal: `node -v` should print `v20.x` or `v22.x`.

4. **Docker Desktop** (Postgres + Redis run in Docker)  
   https://www.docker.com/products/docker-desktop/  
   Start Docker Desktop and wait until it says it is running. Then: `docker version`.

### Enable pnpm (package manager this repo uses)

After Node is installed, in a terminal:

```bash
corepack enable
corepack prepare pnpm@9.15.4 --activate
pnpm -v
```

You should see `9.15.4` (or similar 9.x).

### Recommended VS Code extensions

- **ESLint** (`dbaeumer.vscode-eslint`)
- **Prisma** (`Prisma.prisma`)
- **Docker** (`ms-azuretools.vscode-docker`)
- **Pretty TypeScript Errors** (optional)

### Not required for backend / panels

- Flutter, Android Studio, Xcode — only for the mobile app in `mobile/`

---

## 2. Open the project in VS Code

1. File → **Open Folder…**
2. Select the repo folder: `zaya_events` (the one that contains `apps/`, `package.json`, `docker-compose.yml`).
3. Open the terminal: **Terminal → New Terminal** (or `` Ctrl+` `` / `` Cmd+` ``).  
   The terminal must be at the **repo root** (you should see `package.json` if you run `ls`).

---

## 3. Create your local env file (first time only)

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
copy .env.example .env
```

Open `.env` and keep these for local work (they already match Docker Compose):

- `DATABASE_URL=postgresql://zaya:zaya_dev_password@localhost:5432/zaya_events?schema=public`
- `REDIS_URL=redis://localhost:6379`
- `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` — each must be **at least 32 characters** (the example values already are)
- `STORAGE_DRIVER=local`
- Integration providers can stay `mock` (`FLIGHTS_PROVIDER=mock`, etc.)

You can leave Agora / Stripe / FCM empty while developing the panels.

---

## 4. Start Postgres and Redis

Docker Desktop must be running.

```bash
docker compose up -d postgres redis
```

Check:

```bash
docker compose ps
```

`postgres` and `redis` should be **healthy** / running. Ports: **5432** (Postgres), **6379** (Redis).

Stop later with: `docker compose stop postgres redis`.

---

## 5. Install Node packages and set up the database (first time only)

From the **repo root**:

```bash
pnpm install
pnpm db:generate
pnpm db:migrate
pnpm db:seed
```

Run these from the **repo root** (`zaya_events/`), not from `apps/api`. Prisma now loads `DATABASE_URL` from the root `.env`.

If `pnpm db:migrate` asks for a migration name, you already have migrations — use:

```bash
pnpm --filter @zaya/api prisma:migrate:deploy
```

then `pnpm db:seed`.

Seeded logins:

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@zayaevents.com` | `ChangeMeAdmin!123` |
| Demo vendor | `palms@vendors.zayaevents.com` | `ChangeMeVendor!123` |
| Demo customer (mobile) | `guest@zayaevents.com` | `ChangeMeGuest!123` |

(Other seeded vendors use the same vendor password unless you changed `SEED_VENDOR_PASSWORD`.)

---

## 6. Run API + admin + vendor (every day)

You need **three terminals** in VS Code: **Terminal → New Terminal** (split if you like).

**Terminal 1 — API**

```bash
pnpm dev:api
```

Wait until it is listening. Open http://localhost:4000/health — you should see `"success": true`.

`GET http://localhost:4000/` returning `NOT_FOUND` is expected (there is no home route). Use `/health` or `/api/v1/health`.

**Terminal 2 — Admin panel**

```bash
pnpm dev:admin
```

Open http://localhost:5173

**Terminal 3 — Vendor panel**

```bash
pnpm dev:vendor
```

Open http://localhost:5174

Leave all three running. Stop a process with `Ctrl+C` in that terminal.

---

## 7. Log in

- **Admin:** http://localhost:5173 → `admin@zayaevents.com` / `ChangeMeAdmin!123`
- **Vendor:** http://localhost:5174 → `palms@vendors.zayaevents.com` / `ChangeMeVendor!123`

API Swagger (optional): http://localhost:4000/api/docs  
Postman collection: `docs/Zaya-Events.postman_collection.json`

---

## 8. Run the Flutter app against this API

Keep **`pnpm dev:api`** running. The app talks to `/api/v1` (not the JSON 404 on `/`).

Install Flutter once: https://docs.flutter.dev/get-started/install then:

```bash
cd mobile
flutter pub get
flutter devices
```

**iOS Simulator** (API on your Mac):

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1
```

**Android emulator** (use `10.0.2.2`, not `localhost`):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
```

**Physical phone** on the same Wi‑Fi — replace with your Mac’s LAN IP (`ipconfig getifaddr en0` on macOS):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:4000/api/v1
```

If you omit `--dart-define`, Android defaults to `10.0.2.2` and iOS to `127.0.0.1`.

On the login screen, tap **Fill customer demo** then **Login**, or:

- Customer: `guest@zayaevents.com` / `ChangeMeGuest!123`
- Vendor: `palms@vendors.zayaevents.com` / `ChangeMeVendor!123`

Re-seed after this update if the guest user is missing: from repo root `pnpm db:seed`.

VS Code: open the repo, pick **Zaya mobile (Android emulator)** or **Zaya mobile (iOS simulator)** in Run and Debug.

Firebase is optional. The app starts without `google-services.json`.

---

## 9. Optional: everything in Docker (no `pnpm dev`)

If you prefer one command that builds API + both panels + databases:

```bash
docker compose up --build
```

Same URLs: API `:4000`, admin `:5173`, vendor `:5174`.  
For day-to-day coding, **step 6** (`pnpm dev:*`) is faster because Vite and the API reload on file changes.

---

## Typical problems

| Symptom | What to do |
| --- | --- |
| `docker: command not found` or cannot connect | Start **Docker Desktop** and wait until it is ready |
| `port 5432 already allocated` | Another Postgres is using 5432. Stop it, or change the Compose port |
| `Invalid environment` / JWT too short | `.env` JWT secrets must be ≥ 32 characters |
| `Can't reach database` | `docker compose up -d postgres redis` then retry migrate |
| Prisma `DATABASE_URL` / P1012 | Root `.env` exists (`cp .env.example .env`) and you ran `pnpm db:migrate` from `zaya_events/`, not `apps/api` |
| Admin/vendor blank or CORS errors | API must be running on `:4000`; `.env` `CORS_ORIGINS` must include the panel origins. Flutter web on localhost is allowed automatically in development. Restart `pnpm dev:api` after CORS changes. |
| Phone `flutter run` hangs / black screen / `log reader stopped unexpectedly` | Vivo: enable USB debugging (Security settings) + Install via USB, File transfer, tap the USB allow popup. Or `flutter run --release`. See `mobile/README.md`. |
| `pnpm: command not found` | Run `corepack enable` again, then open a **new** terminal |
| Wrong Node version | Install Node 20 LTS; `node -v` |

After pulling new code:

```bash
pnpm install
pnpm db:generate
pnpm --filter @zaya/api prisma:migrate:deploy
```

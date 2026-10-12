# Storage drivers

Uploads go through `apps/api/src/storage`. The driver is selected with **one** environment variable. There is **no AWS SDK**; S3-compatible stores (DigitalOcean Spaces, MinIO, Wasabi) use the `minio` client.

Set:

```bash
STORAGE_DRIVER=local   # local | sftp | ftp | spaces | custom
STORAGE_PUBLIC_URL=https://api.example.com
```

`POST /api/v1/uploads` (multipart field `file`, optional `folder`) always talks to `getStorageProvider()`. Swap drivers without changing callers.

## `local`

Files on the API disk, served at `/uploads`.

| Key | Purpose |
| --- | --- |
| `STORAGE_DRIVER=local` | Select driver |
| `STORAGE_LOCAL_DIR` | Directory (default `./uploads`) |
| `STORAGE_PUBLIC_URL` | Public origin used in returned URLs |

Use in development and simple VPS deploys. Persist the volume in Docker (`zaya_uploads`).

## `sftp` (typical cPanel)

Put files on a hosting account over SSH/SFTP.

| Key | Purpose |
| --- | --- |
| `STORAGE_DRIVER=sftp` | Select driver |
| `SFTP_HOST` | Hostname (e.g. `server.example.com`) |
| `SFTP_PORT` | Default `22` |
| `SFTP_USER` | cPanel / SSH user |
| `SFTP_PASSWORD` | Password (or provision key-based auth at OS level) |
| `SFTP_BASE_PATH` | Remote directory (e.g. `/home/user/public_html/uploads`) |
| `STORAGE_PUBLIC_URL` | Public HTTPS origin that maps to that directory |

Example — SFTP into cPanel `public_html/uploads`:

```bash
STORAGE_DRIVER=sftp
SFTP_HOST=server.yourdomain.com
SFTP_PORT=22
SFTP_USER=cpaneluser
SFTP_PASSWORD=********
SFTP_BASE_PATH=/home/cpaneluser/public_html/uploads
STORAGE_PUBLIC_URL=https://yourdomain.com
```

Returned object URLs look like `https://yourdomain.com/uploads/<key>`. Point a subdomain or path at `SFTP_BASE_PATH`.

## `ftp`

Same idea as SFTP using `basic-ftp`.

| Key | Purpose |
| --- | --- |
| `STORAGE_DRIVER=ftp` | Select driver |
| `FTP_HOST` / `FTP_PORT` | Default port `21` |
| `FTP_USER` / `FTP_PASSWORD` | Credentials |
| `FTP_SECURE` | `true` for TLS (`ftps`) |
| `FTP_BASE_PATH` | Remote folder |
| `STORAGE_PUBLIC_URL` | Public origin |

## `spaces` (DigitalOcean Spaces / MinIO)

S3-compatible object storage via `minio`.

| Key | Purpose |
| --- | --- |
| `STORAGE_DRIVER=spaces` | Select driver |
| `SPACES_ENDPOINT` | Host **without** scheme, e.g. `nyc3.digitaloceanspaces.com` or `127.0.0.1` |
| `SPACES_PORT` | `443` (DO) or `9000` (MinIO) |
| `SPACES_USE_SSL` | `true` in production; `false` for local MinIO |
| `SPACES_BUCKET` | Bucket name |
| `SPACES_ACCESS_KEY` / `SPACES_SECRET_KEY` | Keys |
| `SPACES_REGION` | e.g. `nyc3` or `us-east-1` |
| `SPACES_PUBLIC_URL` | CDN or public bucket origin (preferred for returned URLs) |

### DigitalOcean Spaces

```bash
STORAGE_DRIVER=spaces
SPACES_ENDPOINT=nyc3.digitaloceanspaces.com
SPACES_PORT=443
SPACES_USE_SSL=true
SPACES_BUCKET=zaya-events
SPACES_ACCESS_KEY=DO00...
SPACES_SECRET_KEY=********
SPACES_REGION=nyc3
SPACES_PUBLIC_URL=https://zaya-events.nyc3.cdn.digitaloceanspaces.com
```

### Local MinIO (Compose profile)

```bash
docker compose --profile spaces up -d minio
# Console: http://localhost:9001  (minioadmin / minioadmin unless overridden)
# Create a bucket named zaya-events (or match SPACES_BUCKET).
```

```bash
STORAGE_DRIVER=spaces
SPACES_ENDPOINT=127.0.0.1
SPACES_PORT=9000
SPACES_USE_SSL=false
SPACES_BUCKET=zaya-events
SPACES_ACCESS_KEY=minioadmin
SPACES_SECRET_KEY=minioadmin
SPACES_REGION=us-east-1
SPACES_PUBLIC_URL=http://127.0.0.1:9000/zaya-events
```

From the API container, use host `minio` instead of `127.0.0.1`.

## `custom`

HTTP webhook-style backend: the API `POST`s the file to your URL.

| Key | Purpose |
| --- | --- |
| `STORAGE_DRIVER=custom` | Select driver |
| `CUSTOM_STORAGE_UPLOAD_URL` | Upload endpoint |
| `CUSTOM_STORAGE_DELETE_URL` | Delete endpoint |
| `CUSTOM_STORAGE_API_KEY` | Sent as `x-api-key` |

Your service must return JSON the driver can map to `{ key, url }`. Use this when hosting already exposes a proprietary upload API.

## Switching

1. Set `STORAGE_DRIVER` and the keys for that driver.
2. Restart the API process (`docker compose up -d api` or `pnpm dev:api`).
3. Upload a test file via `POST /api/v1/uploads` (see Postman collection).
4. Existing keys on another driver are **not** migrated automatically.

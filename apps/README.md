# Apps (API + web panels)

Node/pnpm packages live here. Flutter is in `/mobile`, not in this folder.

| Package | Path | Role |
| --- | --- | --- |
| `@zaya/api` | `api/` | Express API |
| `@zaya/admin-web` | `admin-web/` | Admin portal |
| `@zaya/vendor-web` | `vendor-web/` | Vendor portal |

From the repo root:

```bash
pnpm install
pnpm dev:api
pnpm dev:admin
pnpm dev:vendor
```

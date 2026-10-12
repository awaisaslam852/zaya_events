# Zaya Events mobile

Customer + vendor Flutter app. Backend and web panels live in `/apps`, not here.

Keep the API running (`pnpm dev:api` at the repo root). Confirm http://localhost:4000/health — a JSON 404 on `/` is normal.

```bash
cd mobile
flutter pub get
```

iOS Simulator:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1
```

Android emulator (`localhost` inside the emulator is the phone, not your Mac):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
```

Physical device: use your computer’s LAN IP, e.g. `http://192.168.1.10:4000/api/v1`.

## Physical Android (`flutter run` vs APK)

`flutter build apk` + install works because that is **release** (AOT). `flutter run` is **debug** (JIT). Vivo / iQOO / Oppo / Xiaomi often block USB debug install or kill the Dart VM before the tool can connect. That looks like: install hangs, black screen, then:

`Error waiting for a debug connection: The log reader stopped unexpectedly`

On the phone (Developer options):

1. USB debugging **on**
2. **USB debugging (Security settings)** / **Disable permission monitoring** **on** (Vivo: tap it, enter lock-screen PIN)
3. **Install via USB** **on**
4. USB mode = **File transfer**, not Charge only
5. When you run, accept every **Allow USB install / debugging** popup immediately
6. Uninstall any previous `zaya_events` from the phone, then run again

From the laptop:

```bash
adb devices
cd mobile
flutter run -d V2419 --no-enable-impeller --dart-define=API_BASE_URL=http://YOUR_LAN_IP:4000/api/v1
```

If debug still cannot attach, run a release build on the device (same as your working APK):

```bash
flutter run -d V2419 --release --dart-define=API_BASE_URL=http://YOUR_LAN_IP:4000/api/v1
```

Login (after `pnpm db:seed`):

| Role | Email | Password |
| --- | --- | --- |
| Customer | `guest@zayaevents.com` | `ChangeMeGuest!123` |
| Vendor | `palms@vendors.zayaevents.com` | `ChangeMeVendor!123` |

The login screen has **Fill customer demo** / **Fill vendor demo**. Debug builds also show the API URL.

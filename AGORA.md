# Agora (voice / video)

Zaya uses **Agora only** (no Twilio, LiveKit, or WebRTC SFU of our own). The **App Certificate never leaves the API**. Clients receive short-lived RTC tokens.

## App ID and certificate

1. Create a project at [https://console.agora.io](https://console.agora.io).
2. Choose **App ID + App Certificate** (token authentication). Do not use “testing mode” without a certificate in production.
3. Copy:
   - `AGORA_APP_ID` — 32-character public ID
   - `AGORA_APP_CERTIFICATE` — secret, **server only**
4. Put both in `.env` on the API. Restart the API.

```bash
AGORA_APP_ID=your32characterappidhere000000
AGORA_APP_CERTIFICATE=yourcertificate****************
AGORA_TOKEN_EXPIRES_IN=3600
```

Flutter / admin web may receive the **App ID** (public). Never embed the certificate in mobile or Vite apps.

The mobile in-call UI uses **`agora_rtc_engine` ^6.6.4** (not Agora UIKit).

```bash
cd mobile
flutter run --dart-define=AGORA_APP_ID=your32characterappidhere000000
```

Admin web reads the App ID from token payloads (`data.appId`) returned by the API.

## Token flow

1. User authenticates (`POST /api/v1/auth/login`).
2. Client requests `POST /api/v1/agora/rtc-token` with:

```json
{
  "channelName": "call_<callerId>_<calleeId>",
  "uid": 101,
  "role": "PUBLISHER"
}
```

Allowed channel prefixes:

- `booking_<bookingId>` — tied to a booking
- `call_<a>_<b>` — 1:1 call

3. API signs a token with `agora-access-token` (`PUBLISHER` or `SUBSCRIBER`) and returns `{ token, appId, channelName, uid, role, expiresAt }`.
4. Client joins the Agora channel with App ID + token + uid.

Calls in the product also go through `/api/v1/calls` (initiate / accept / reject / history). Accepting a call fetches a **publisher** token. Admin observe uses **subscriber** so the admin cannot publish camera/mic into the room.

## Testing a 1:1 call on two devices

1. API running with valid `AGORA_APP_ID` and `AGORA_APP_CERTIFICATE`.
2. Two users (customer + vendor, or two customers) on two phones / emulators, same `--dart-define=AGORA_APP_ID`.
3. Device A opens chat or call history and starts an outgoing call to Device B’s user id.
4. Device B should show **Incoming call** (push and/or socket `incoming_call` on the `/calls` namespace).
5. Accept on B; both join the same `call_*` or `booking_*` channel as publishers.
6. Confirm audio (and video if permissions granted). End on either side.

Emulator notes:

- Android emulator → API on the host: `API_BASE_URL=http://10.0.2.2:4000/api/v1`
- Grant microphone/camera on both OS permission dialogs.
- Two Android emulators can call each other if both reach the same API and Agora (needs host network).

If tokens fail, check API logs for `AGORA_MISCONFIGURED` or `INVALID_CHANNEL`.

## Admin observe mode

The admin portal joins as **Agora subscriber** (`role: SUBSCRIBER` on `POST /api/v1/agora/rtc-token`, and the observe UI uses `agora-rtc-react` in subscriber mode).

Typical flow:

1. Sign in as admin on http://localhost:5173
2. Open the booking or live-call observe screen (admin calls / booking detail).
3. Admin requests a subscriber token for the same `booking_<id>` or `call_*` channel.
4. Admin sees/hears the session but does not publish.

Vendors and customers always publish. Admins must not be given publisher tokens for observe.

## Security

- Rotate the certificate in Agora Console if it leaks; update `.env` and restart.
- Tokens expire (`AGORA_TOKEN_EXPIRES_IN`). Clients should request a fresh token before re-join.
- Channel names are validated server-side; do not accept arbitrary room names from the client without the `booking_` / `call_` prefix.

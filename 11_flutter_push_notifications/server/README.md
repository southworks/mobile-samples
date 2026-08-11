# FCM Topic Sender CLI

Dart command-line app that sends a push notification to Firebase Cloud Messaging (FCM) **targeted at a topic** (default: `sample_push`).

Pairs with the Flutter app in [`../flutter/`](../flutter/). Devices only receive messages if they have subscribed to the same topic.

**Not a Flutter app** — runs with the Dart SDK only.

---

## Prerequisites

- Dart SDK (included with Flutter)
- Firebase project with Cloud Messaging enabled
- Service account JSON from Firebase Console (see below)
- Flutter app running and subscribed to topic `sample_push`

---

## Service account setup

1. Firebase Console → **Project settings** → **Service accounts**.
2. Click **Generate new private key** → download the JSON.
3. Store locally, for example:

   ```text
   c:\diatom\mobile-samples\11_flutter_push_notifications\secrets\fcm-service-account.json
   ```

**Never commit this file.** The `secrets/` folder is gitignored.

This credential is for **sending only**. Never embed it in the Flutter APK/IPA.

---

## Run

```powershell
cd c:\diatom\mobile-samples\11_flutter_push_notifications\server
dart pub get
```

Set credentials (PowerShell):

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "c:\diatom\mobile-samples\11_flutter_push_notifications\secrets\fcm-service-account.json"
dart run
```

Or pass the path explicitly:

```powershell
dart run -- --service-account ..\secrets\fcm-service-account.json
```

Optional topic override:

```powershell
dart run -- --topic sample_push --service-account ..\secrets\fcm-service-account.json
```

---

## Interactive prompts

The CLI prompts for:

| Input | Constraint |
|-------|------------|
| Notification title | max **30** characters |
| Notification body | max **100** characters |

Invalid input prints an error and re-prompts. Empty input is rejected.

---

## CLI options

| Flag | Default | Purpose |
|------|---------|---------|
| `--topic` | `sample_push` | FCM topic to send to |
| `--service-account` | (or env `GOOGLE_APPLICATION_CREDENTIALS`) | Path to service account JSON |
| `-h`, `--help` | — | Show help |

The CLI does **not** require a device FCM token.

---

## What gets sent

FCM HTTP v1 request body (conceptually):

```json
{
  "message": {
    "topic": "sample_push",
    "notification": {
      "title": "Hello",
      "body": "Sent from the sample CLI"
    }
  }
}
```

Title/body length limits are **sample validation rules** for good UX, not hard FCM platform limits.

On success, the CLI prints the FCM message name/id. On failure, it prints a readable error.

---

## End-to-end test

1. Configure Firebase for the Flutter app (see [`../flutter/README.md`](../flutter/README.md)).
2. Place service account JSON under `../secrets/`.
3. Run the Flutter app → grant permission → confirm **Subscribed** to `sample_push`.
4. Run this CLI → enter title and body → send.
5. Confirm notification on device and in-app “Last notification”.

If you send before any device has subscribed, the API call may still succeed but **no device** will show the notification.

---

## Dependencies

- `googleapis_auth` — OAuth from service account
- `http` — FCM HTTP v1 POST

---

## Key files

- [`bin/server.dart`](bin/server.dart) — entry point
- [`lib/server.dart`](lib/server.dart) — prompts + orchestration
- [`lib/fcm_topic_sender.dart`](lib/fcm_topic_sender.dart) — FCM HTTP v1 send
- [`lib/notification_input_validator.dart`](lib/notification_input_validator.dart) — title/body validation

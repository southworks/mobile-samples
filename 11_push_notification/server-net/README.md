# FCM Topic Sender CLI (.NET)

.NET command-line app that sends a push notification to Firebase Cloud Messaging (FCM) **targeted at a topic** (default: `sample_push`).

Pairs with the Flutter app in [`../flutter/`](../flutter/). Devices only receive messages if they have subscribed to the same topic.

**Not a Flutter app** — runs with the .NET SDK only. Functionally equivalent to the Dart CLI in [`../server/`](../server/).

---

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) (includes C# 14)
- Firebase project with Cloud Messaging enabled
- Service account JSON from Firebase Console (see below)
- Flutter app running and subscribed to topic `sample_push`

---

## Service account setup

1. Firebase Console → **Project settings** → **Service accounts**.
2. Click **Generate new private key** → download the JSON.
3. Store locally, for example:

   ```text
   c:\diatom\mobile-samples\11_push_notification\secrets\fcm-service-account.json
   ```

**Never commit this file.** The `secrets/` folder is gitignored.

This credential is for **sending only**. Never embed it in the Flutter APK/IPA.

---

## Run

```powershell
cd c:\diatom\mobile-samples\11_push_notification\server-net
dotnet restore
```

Set credentials (PowerShell):

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "c:\diatom\mobile-samples\11_push_notification\secrets\fcm-service-account.json"
dotnet run --project src/ServerNet
```

Or pass the path explicitly:

```powershell
dotnet run --project src/ServerNet -- --service-account ..\secrets\fcm-service-account.json
```

Optional topic override:

```powershell
dotnet run --project src/ServerNet -- --topic sample_push --service-account ..\secrets\fcm-service-account.json
```

When passing program flags, place them after `--` so they are forwarded to the app.

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

- `Google.Apis.Auth` — OAuth from service account
- `HttpClient` (BCL) — FCM HTTP v1 POST

---

## Tests

```powershell
cd c:\diatom\mobile-samples\11_push_notification\server-net
dotnet test
```

---

## Common pitfalls

| Symptom | Fix |
|---------|-----|
| `Provide --service-account or set GOOGLE_APPLICATION_CREDENTIALS` | Set the env var or pass `--service-account` after `--` |
| CLI succeeds but phone silent | App not subscribed; wrong topic string; permission denied; Android emulator without Google Play |

---

## Key files

- [`src/ServerNet/Program.cs`](src/ServerNet/Program.cs) — entry point
- [`src/ServerNet/CliApp.cs`](src/ServerNet/CliApp.cs) — prompts + orchestration
- [`src/ServerNet/FcmTopicSender.cs`](src/ServerNet/FcmTopicSender.cs) — FCM HTTP v1 send
- [`src/ServerNet/NotificationInputValidator.cs`](src/ServerNet/NotificationInputValidator.cs) — title/body validation

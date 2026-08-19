# Sample 11 — Flutter Push Notifications (SPEC)

Agent brief for implementing `11_push_notification`. Follow this document as the source of truth for scope, layout, architecture, and Firebase setup. Do not expand beyond the acceptance checklist unless asked.

---

## 1. Goal

Build a learning sample that demonstrates **Firebase Cloud Messaging (FCM)** end to end using **topic messaging**:

1. A **Flutter** mobile app (Android + iOS) that **subscribes to an FCM topic**, **receives** push notifications for that topic, and shows a simple complementary UI (live clock).
2. A **Dart CLI** that **sends** a notification to Firebase FCM **targeted at that topic**, which then delivers it to all subscribed app instances.

**Why topics (not device tokens) for this sample:** simpler demo UX (no copy-paste of device tokens), closer to a “broadcast to everyone running the sample” mental model, and enough to learn FCM send/receive. Device tokens still exist under the hood; the sample simply does not use them as the CLI target.

Architecture for the mobile app: **Clean Architecture + MVVM** (presentation uses ViewModels; domain/data stay free of Flutter UI widgets). Prefer patterns already used in `03_patterns/flutter` (e.g. `ChangeNotifier` + `ListenableBuilder`). Do **not** add new state-management or architecture packages without explicit approval.

---

## 2. Folder layout

```text
11_push_notification/
  SPEC.md                 # this file
  flutter/                # Flutter app (Android + iOS)
  server/                 # Dart CLI sender
  secrets/                # local only; gitignored (service account JSON)
```

Optional later (not required for first implementation):

- Root-level `README.md` — human-oriented overview (can be derived from this SPEC).
- Sample-local Cursor rules under `11_push_notification/.cursor/` if needed; root rule `sample-11-ai-rules-flutter-and-dart.mdc` already scopes to `11_push_notification/flutter/**/*.dart`.

---

## 3. Targeting model: FCM topics

### 3.1 Shared topic name

Use one fixed topic for the sample (same string in app and CLI):

| Constant | Value |
|----------|--------|
| Sample topic | `sample_push` |

Document this name in `flutter/README.md` and `server/README.md`. Optionally allow overriding via CLI flag `--topic` (default: `sample_push`); the Flutter app may keep the topic as a named constant in domain/config.

**Topic name rules (FCM):** prefer lowercase letters, numbers, and underscores; avoid spaces. `sample_push` is valid.

### 3.2 End-to-end flow

```text
┌─────────────────────┐     title + body                      ┌──────────────┐
│  server/ (Dart CLI) │     target topic: sample_push         │ Firebase FCM │
│  + service account  │ ────────────────────────────────────► │              │
└─────────────────────┘                                       └──────┬───────┘
                                                                     │
                                                                     │ fan-out to
                                                                     │ topic subscribers
                                                                     ▼
                                                          ┌─────────────────────┐
                                                          │ flutter/ installs   │
                                                          │ subscribed to       │
                                                          │ sample_push         │
                                                          └─────────────────────┘
```

### 3.3 Important clarifications

- FCM does **not** send to “every Firebase app” automatically. Devices only receive topic messages after **`subscribeToTopic('sample_push')`** succeeds (and notification permission is granted where required).
- You do **not** need to publish the app to Google Play or the App Store. Firebase app registration is only linking your **debug/dev** Android `applicationId` and iOS Bundle ID to the Firebase project.
- Client config (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) is for the **mobile app (receive + subscribe)**. The **service account JSON** is for the **CLI only (send)**. Never embed the service account in the Flutter app.
- FCM still assigns each install a device registration token internally. For this sample, **do not require pasting that token into the CLI**. Optional: show the token in a collapsed “Debug” section for troubleshooting only.

---

## 4. `flutter/` — mobile app requirements

### 4.1 Platforms

- Generate / support **Android** and **iOS** targets.
- Use Flutter stable, Material 3, null-safe Dart 3.x.
- Follow root Cursor rule for this sample when editing `flutter/**/*.dart`.

### 4.2 Features

**A. Push notifications via topic (primary)**

- Initialize Firebase at startup (`firebase_core` + generated `firebase_options.dart`).
- Use `firebase_messaging` to:
  - Request notification permission (iOS; Android 13+).
  - **Subscribe** to topic `sample_push` after permission is granted (recommended: **auto-subscribe** on first successful init for an easy demo).
  - Allow **Unsubscribe** / **Subscribe** again from the UI.
  - Expose subscription status (subscribed / not subscribed / error message).
  - Handle messages in **foreground**, **background**, and **terminated** (notification tap).
- Register a **top-level** background handler with `@pragma('vm:entry-point')` before `runApp`.
- UI must show:
  - Topic name (`sample_push`).
  - Subscription status + Subscribe / Unsubscribe controls.
  - Permission status (simple text is enough).
  - Last received notification (title + body), when available.
  - Optional debug: FCM device token (copyable), not part of the main happy path.
- Foreground display: either rely on system behavior where applicable or show an in-app banner/snackbar/card with title + body. Keep it simple; do not require `flutter_local_notifications` unless needed for a clear Android foreground UX — if added, ask for approval first per repo dependency policy.

**B. Live clock (complementary UI)**

- Show **current time**, **day/date**, and **time zone** (device local zone name/offset is fine).
- **Tick every second**: domain/data expose a stream or periodic update; ViewModel listens and notifies the View.
- This feature exists to exercise Clean Architecture + MVVM alongside push, not as a full world-clock product.

### 4.3 Architecture (Clean Architecture + MVVM)

Organize by feature and layer. Suggested structure (adjust names only if clearer; keep layers):

```text
lib/
  main.dart
  app.dart
  firebase_options.dart          # from flutterfire configure (or placeholder + docs)
  di/                            # lightweight manual DI / composition root
  features/
    clock/
      domain/
        entities/
        repositories/            # abstract
        use_cases/
      data/
        repositories/            # SystemClockRepositoryImpl
      presentation/
        view_models/             # ClockViewModel (ChangeNotifier)
        views/                   # Clock section / page widgets
    push/
      domain/
        entities/                # e.g. PushMessage, TopicSubscription
        repositories/
        use_cases/               # subscribe, unsubscribe, observe messages, …
      data/
        datasources/             # FirebaseMessaging wrappers
        repositories/
      presentation/
        view_models/
        views/
  shared/                        # optional small shared widgets/theme
```

Rules:

- **Views** contain UI only; no Firebase / FCM calls.
- **ViewModels** hold UI state and call use cases; no `BuildContext` business logic.
- **Use cases** orchestrate domain work (including subscribe/unsubscribe).
- **Repositories** abstract data sources; Firebase Messaging lives in `data`.
- Prefer immutability (`final` fields, simple entity classes).
- Prefer sealed classes/enums for finite UI states where useful.
- Mirror the spirit of `03_patterns/flutter` clean side; keep the sample focused (one home screen composing clock + push panels is enough).

### 4.4 UI sketch (minimal)

Single home screen is enough, for example:

- Top: live clock (time, day/date, zone).
- Middle: topic name, subscription status, Subscribe / Unsubscribe, permission status.
- Bottom: “Last notification” card (title, body, received-at if easy).
- Optional: expandable “Debug” with FCM token.

No navigation stack required for v1.

### 4.5 Dependencies (mobile)

Expected:

- `firebase_core`
- `firebase_messaging`

Ask before adding anything else (including `provider`, `get_it`, `flutter_local_notifications`, etc.). Manual wiring + `ChangeNotifier` is preferred for v1.

---

## 5. `server/` — Dart CLI requirements

### 5.1 Nature of the project

- **Dart CLI application** (accurate label: not a Flutter app).
- Runnable with `dart pub get` and `dart run` from `server/`.
- No Flutter SDK dependency required for the CLI itself.

### 5.2 User interaction

Interactively prompt for (or accept equivalent CLI args if both are implemented; interactive prompts are required):

| Input | Constraint | Purpose |
|-------|------------|---------|
| Notification title | max **30** characters | FCM notification title |
| Notification body (corpus) | max **100** characters | FCM notification body |

Optional CLI flags (recommended):

| Flag | Default | Purpose |
|------|---------|---------|
| `--topic` | `sample_push` | FCM topic to send to |
| `--service-account` | (or env `GOOGLE_APPLICATION_CREDENTIALS`) | Path to service account JSON |

Do **not** require an FCM device token prompt.

Validate title/body lengths before sending; print a clear error and re-prompt or exit non-zero.

### 5.3 Sending to Firebase

- Use **FCM HTTP v1** API.
- Authenticate with a **Firebase service account** JSON file.
- Message target: **`topic: "sample_push"`** (or `--topic` value), not a device token.
- Include a **notification** payload (`title`, `body`) so the system tray can show it when appropriate. Optionally include a matching `data` map for app handling — keep payload minimal.
- Print success (message name/id if returned) or a readable failure reason.
- Remind the operator in CLI help/README: devices only receive the message if they have subscribed to the same topic.
- **Never** commit the service account file. Document placing it under `11_push_notification/secrets/` (gitignored) or an absolute local path.

### 5.4 Dependencies (server)

Prefer the smallest workable approach:

- Official Google Auth + HTTP client calling FCM v1, **or**
- A well-known Dart package for FCM/Admin if it fits without overengineering.

Ask before adding packages if unsure. Do not put Admin credentials in the mobile app.

---

## 6. Firebase configuration guide (beginner-focused)

This section is written for developers with **little or no Firebase experience**. The implementing agent must turn it into clear steps in `flutter/README.md` and `server/README.md`, and keep secrets out of git.

You do **not** need to publish the app to any store to use FCM in development.

### 6.1 Concepts (read once)

| Term | Meaning for this sample |
|------|-------------------------|
| **Firebase project** | A cloud project container. One project holds your Android app, iOS app, and Cloud Messaging settings. |
| **Registered Android / iOS app** | An entry in that project with your package name / Bundle ID. Not a store listing. |
| **Client config files** | `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). They tell the SDK which Firebase project to talk to. |
| **`firebase_options.dart`** | Dart version of those client settings, usually generated by FlutterFire CLI. |
| **FCM topic** | A named channel (here: `sample_push`). Apps subscribe; the CLI sends to the topic; FCM delivers to subscribers. |
| **Service account JSON** | Server credential used by the Dart CLI to call FCM send APIs. Treat like a password. **Never** put it in the mobile app or commit it. |
| **APNs** | Apple Push Notification service. Required for real iOS push; you upload an APNs key to Firebase. |

### 6.2 Prerequisites

- Google account (for Firebase Console).
- Flutter SDK installed; able to run a sample on Android and/or iOS.
- **Android:** emulator with **Google Play** image, or a physical device.
- **iOS (if testing on iPhone):** Apple Developer account (paid) for Push + APNs key; physical device recommended.
- For the CLI: Dart SDK (comes with Flutter) and a place to store the service account file locally.

### 6.3 Create the Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/) and sign in.
2. Click **Add project** (or create project). Follow the wizard.
   - Google Analytics is **optional** for this sample; you can disable it to keep things simpler.
3. When the project opens, note the **Project name** and **Project ID** (Project settings → General). You will need the project ID when calling FCM HTTP v1 from the CLI (`https://fcm.googleapis.com/v1/projects/<PROJECT_ID>/messages:send`).

You do **not** need Authentication, Firestore, Storage, or Functions for this sample—only **Cloud Messaging**.

### 6.4 Enable Cloud Messaging

1. In the left menu, open **Engage → Messaging** (or **Build → Cloud Messaging**, depending on Console layout), or go to Project settings → **Cloud Messaging**.
2. Ensure Cloud Messaging API is available for the project (on newer Google Cloud projects it is often enabled automatically when you use FCM).
3. No need to compose a campaign in the Console for this sample; the **Dart CLI** will send messages via the API.

### 6.5 Register the Android app (dev / sample — not Play Store)

1. Project overview → **Add app** → **Android**.
2. **Android package name:** must match `applicationId` in `flutter/android/app/build.gradle.kts` (or `.gradle`) exactly (example shape: `com.example.flutter_push_notifications`).
3. Nickname is optional (e.g. `Push Sample Android`).
4. Debug signing SHA-1 is **not required** for basic FCM receive/subscribe in this sample (unlike Google Sign-In). You can skip SHA unless a later feature needs it.
5. Register the app → download **`google-services.json`**.
6. Place it at:

   ```text
   flutter/android/app/google-services.json
   ```

7. Ensure the Google Services Gradle plugin is applied (standard FlutterFire / FlutterFire docs for Android). Without this, the native Firebase SDK may not initialize correctly.
8. Run on an emulator **with Google Play** or a real device. Emulators without Google Play often cannot receive FCM.

**Store publishing:** not required. The Firebase Android app entry is only so your local/debug build can talk to Firebase.

### 6.6 Register the iOS app (dev / sample — not App Store)

1. Project overview → **Add app** → **iOS**.
2. **iOS bundle ID:** must match Xcode `Runner` Bundle Identifier exactly.
3. Register → download **`GoogleService-Info.plist`**.
4. Add the file to the Xcode `Runner` target (FlutterFire configure often helps with this).
5. **APNs setup (required for real iOS push):**
   1. Sign in to [Apple Developer](https://developer.apple.com/account) → Certificates, Identifiers & Profiles.
   2. Ensure your App ID has **Push Notifications** capability enabled.
   3. Create an **APNs Auth Key** (Keys → + → Apple Push Notifications service). Download the `.p8` once; note Key ID and Team ID.
   4. Firebase Console → Project settings → **Cloud Messaging** → Apple app configuration → upload the APNs key (`.p8` + Key ID + Team ID).
6. In the Flutter/iOS project, enable the Push Notifications capability for `Runner` if not already enabled.
7. Prefer a **physical iPhone** for testing. Simulator support for remote push is limited/version-dependent; do not rely on it for this sample.
8. The app must **request notification permission** at runtime before iOS will show alerts.

**App Store / TestFlight:** not required to develop this sample. TestFlight is optional later; local installs on a registered device are enough.

### 6.7 Generate Flutter client options (FlutterFire CLI)

From `flutter/` after Android/iOS apps exist in Firebase:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

When prompted, select your Firebase project and the Android/iOS apps you registered. This should:

- Create/update `lib/firebase_options.dart`
- Help place/align platform config files

Initialize in `main.dart` (order matters):

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// register top-level background messaging handler
// then runApp(...)
```

### 6.8 Configure topic messaging in the apps (no Console “topic create” step)

Topics are created **implicitly**:

1. When the Flutter app calls `FirebaseMessaging.instance.subscribeToTopic('sample_push')`, that install is subscribed.
2. When the CLI sends to topic `sample_push`, FCM delivers to current subscribers.

There is **no** separate “create topic” button you must click in Firebase Console for this sample. Still:

- Use the **exact same** topic string in Flutter and CLI: `sample_push`.
- Subscribe **after** Firebase init and (on platforms that need it) after notification permission is granted.
- If you send from the CLI before any device has subscribed, the send may still succeed at the API level, but **no device** will show the notification—document this in the READMEs.

### 6.9 Service account for the Dart CLI (sending)

1. Firebase Console → gear icon → **Project settings** → **Service accounts**.
2. Confirm the Firebase Admin SDK language tip can be ignored; you only need the key file.
3. Click **Generate new private key** → confirm → download the JSON.
4. Store it locally, for example:

   ```text
   11_push_notification/secrets/fcm-service-account.json
   ```

5. Gitignore `secrets/` and patterns like `**/*service-account*.json`.
6. Point the CLI at the file:

   ```powershell
   $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\diatom\mobile-samples\11_push_notification\secrets\fcm-service-account.json"
   cd C:\diatom\mobile-samples\11_push_notification\server
   dart run
   ```

   Or: `dart run -- --service-account ..\secrets\fcm-service-account.json` (exact args per CLI implementation).

This JSON can mint access tokens to call FCM as your project. **Never commit it. Never ship it inside the Flutter APK/IPA.**

### 6.10 What the CLI sends (topic message shape)

Conceptually (FCM HTTP v1), the body targets a topic:

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

Title max 30 and body max 100 are **sample validation rules** in our CLI (good UX for the exercise), not hard FCM platform limits.

### 6.11 What is safe to commit vs not

| Artifact | Where | Commit? |
|----------|--------|---------|
| `google-services.json` / `GoogleService-Info.plist` | Flutter app | Prefer placeholders + docs, or follow existing repo practice (e.g. SSO sample). These identify the Firebase *client* project; they are not the send credential. |
| `firebase_options.dart` | Flutter app | Same as above (client identifiers). |
| Service account JSON | CLI / `secrets/` | **Never commit.** |
| Topic name `sample_push` | Code + docs | Yes — it is not a secret. |
| Device FCM token | Optional debug UI only | Ephemeral; do not hardcode. |

### 6.12 Manual test path (topics)

1. Complete Firebase Android (and iOS if applicable) registration + FlutterFire configure.
2. Place service account JSON under `secrets/` (gitignored).
3. Run the Flutter app → grant notification permission → confirm UI shows subscribed to `sample_push` (auto-subscribe or tap Subscribe).
4. Run the Dart CLI with service account → enter title (≤30) and body (≤100) → send to topic `sample_push`.
5. Confirm the device shows the system notification and the in-app “Last notification” updates.
6. Tap Unsubscribe → send again → confirm the device does **not** receive (or document platform quirks). Tap Subscribe and retest.

### 6.13 Common beginner pitfalls

| Symptom | Likely cause |
|---------|----------------|
| CLI succeeds but phone silent | App not subscribed; wrong topic string; permission denied; Android emulator without Google Play |
| iOS never receives | APNs key missing/incorrect in Firebase; Push capability missing; testing only on Simulator; permission denied |
| Firebase init fails | Missing/misplaced `google-services.json` / plist; package name / Bundle ID mismatch; `firebase_options.dart` not generated |
| Subscribe fails | Called before `Firebase.initializeApp`; no network; invalid topic name |
| “Permission” confusion | Notification permission ≠ topic subscription; you usually need **both** for a visible notification |

---

## 7. Out of scope (v1)

- Device-token targeting as the primary send path (optional debug display of token is fine).
- Multiple topics, topic conditions (`'TopicA' in topics && ...`), or device groups.
- User authentication / Firestore / Remote Config.
- Production analytics, crash reporting, or CI-stored Firebase secrets.
- Full navigation, settings screens, or multi-language clock formatting beyond a clear default locale.
- Publishing to Play Store / App Store.
- Kotlin/Swift native sibling apps for this sample number (Flutter + Dart CLI only).

---

## 8. Implementation order (suggested for the agent)

1. Create `flutter/` Flutter project with Android + iOS.
2. Wire Clean Architecture + MVVM skeleton; implement **clock** feature (1s ticks) first to prove layers.
3. Add Firebase + FCM; implement **push** feature with topic subscribe/unsubscribe + message observers; compose home UI.
4. Create `server/` Dart CLI with title/body prompts, validation, FCM HTTP v1 **topic** send (default `sample_push`).
5. Add gitignore for secrets; write `flutter/README.md` and `server/README.md` from section 6 (beginner-friendly).
6. Smoke-test the checklist below.

---

## 9. Acceptance checklist

- [ ] `flutter/` runs on Android and has an iOS target configured.
- [ ] Home UI shows ticking clock (updates every second): time, day/date, time zone.
- [ ] Layers follow Clean Architecture + MVVM (views / view models / use cases / repositories).
- [ ] FCM initializes; notification permission can be requested.
- [ ] App can subscribe / unsubscribe to topic `sample_push`; status is visible in the UI (auto-subscribe after permission recommended).
- [ ] Foreground messages update “Last notification”.
- [ ] Background / terminated delivery is handled (at least notification tap updates UI or is documented if limited on emulator).
- [ ] `server/` is a Dart CLI; prompts for title (≤30) and body (≤100); validates lengths; sends to topic (default `sample_push`).
- [ ] CLI does **not** require a device token for the happy path.
- [ ] CLI sends via FCM HTTP v1 using a local service account path/env; success/failure is printed.
- [ ] Service account path is gitignored; no Admin credentials in the Flutter app.
- [ ] Firebase setup (project, Android/iOS registration without stores, FlutterFire, APNs note, service account, topics) is documented for beginners in the sample READMEs.

---

## 10. Notes for the implementing agent

- Prefer small, focused commits/changes; do not bump Flutter/Gradle/plugin versions unless required to make Firebase work, and call out any version change.
- Match existing mobile-samples style: clear folder names, practical README steps, PowerShell-friendly commands where documented.
- Keep topic name `sample_push` consistent across Flutter constant, CLI default, and docs.
- If a requirement in this SPEC conflicts with a repo `AGENTS.md` or Cursor rule, stop and ask — do not silently expand dependencies.

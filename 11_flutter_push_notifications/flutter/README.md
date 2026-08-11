# Flutter Push Notifications Sample

Flutter mobile app (Android + iOS) that demonstrates **Firebase Cloud Messaging (FCM)** end to end using **topic messaging**.

- Subscribes to FCM topic `sample_push`
- Receives push notifications for that topic
- Shows a live clock (Clean Architecture + MVVM exercise)
- Pairs with the Dart CLI in [`../server/`](../server/) to send notifications

**Stack:** Flutter, Material 3, `firebase_core`, `firebase_messaging`, `ChangeNotifier` + `ListenableBuilder`.

---

## Structure

```text
lib/
  main.dart, app.dart, firebase_options.dart
  di/dependencies.dart
  features/
    clock/     # domain / data / presentation
    push/      # domain / data / presentation
  shared/
```

---

## Dependencies

- `firebase_core`
- `firebase_messaging`

No third-party state-management packages.

---

## Firebase setup (step by step)

You do **not** need to publish the app to Google Play or the App Store. Firebase app registration only links your debug/dev package name and Bundle ID to a Firebase project.

### Concepts

| Term | Meaning for this sample |
|------|-------------------------|
| Firebase project | Container for your Android app, iOS app, and Cloud Messaging |
| Registered app | Firebase entry for your package name / Bundle ID (not a store listing) |
| Client config | `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` |
| FCM topic | Named channel (`sample_push`); apps subscribe, CLI sends to the topic |
| Service account JSON | **CLI only** — never put it in the mobile app |

### 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/) and sign in.
2. Click **Add project** and follow the wizard (Google Analytics is optional).
3. Note the **Project ID** (Project settings → General). The CLI uses it for FCM HTTP v1.

You only need **Cloud Messaging** for this sample.

### 2. Register the Android app

1. Project overview → **Add app** → **Android**.
2. **Package name:** `com.example.flutter_push_notifications` (must match `applicationId` in `android/app/build.gradle.kts`).
3. Register → download **`google-services.json`**.
4. Replace the placeholder at:

   ```text
   android/app/google-services.json
   ```

5. Use an emulator **with Google Play** or a physical device. Emulators without Google Play often cannot receive FCM.

Debug SHA-1 is **not** required for basic FCM in this sample.

### 3. Register the iOS app

1. Project overview → **Add app** → **iOS**.
2. **Bundle ID:** `com.example.flutterPushNotifications` (must match Xcode Runner).
3. Register → download **`GoogleService-Info.plist`**.
4. Add the file to the Xcode **Runner** target (drag into `ios/Runner` in Xcode).

**APNs (required for real iOS push):**

1. [Apple Developer](https://developer.apple.com/account) → ensure App ID has **Push Notifications**.
2. Create an **APNs Auth Key** (`.p8`); note Key ID and Team ID.
3. Firebase Console → Project settings → **Cloud Messaging** → upload the APNs key.
4. `ios/Runner/Runner.entitlements` includes `aps-environment`; confirm Push capability is enabled in Xcode for Runner.
5. Prefer a **physical iPhone**; Simulator remote push support is limited.

### 4. Generate `firebase_options.dart`

FlutterFire CLI requires the **official Firebase CLI** to be installed first. See [Install the Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli).

From this folder:

**1. Install and verify Firebase CLI:**

```powershell
npm install -g firebase-tools
firebase --version
```

**2. Log in (required once per machine):**

```powershell
firebase login
```

**3. Install FlutterFire CLI and configure:**

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

If `flutterfire` is not found, add Dart’s pub cache to PATH (e.g. `%LOCALAPPDATA%\Pub\Cache\bin`) and open a new terminal.

Select your Firebase project and the Android/iOS apps you registered. This updates `lib/firebase_options.dart` and aligns platform config files.

**Do not commit real Firebase client config.** This repo ships **placeholders** only (`firebase_options.dart`, `google-services.json`). After `flutterfire configure`, keep the generated files local — GitHub secret scanning flags embedded API keys even when they are client-side Firebase keys. The service account under `../secrets/` must never be committed.

If you already pushed real keys, rotate/restrict them in [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials) and close the GitHub alerts after this cleanup.

If you already know your Project ID:

```powershell
flutterfire configure --project=YOUR_PROJECT_ID
```

#### Troubleshooting `flutterfire configure`

| Symptom | Fix |
|---------|-----|
| `requires the official Firebase CLI` | Install `firebase-tools`; verify `firebase --version` |
| `Found 0 Firebase projects` / `Failed to list Firebase projects` | Stale auth — run `firebase logout` then `firebase login --reauth`; verify with `firebase projects:list` |
| Still fails after re-login | Use the same Google account as Firebase Console; create the project in Console first, then `flutterfire configure --project=YOUR_PROJECT_ID` |
| `firebase login` says “Already logged in” but list still fails (401) | Tokens expired — use `--reauth`; check `firebase-debug.log` in this folder for 401 / expired token details |
| Node engine warnings from `firebase-tools` | Prefer Node 22 LTS (`nvm install 22`, then `nvm use 22`), reinstall `firebase-tools` |
### 5. Topic messaging (no Console “create topic” step)

Topics are created **implicitly**:

1. The app calls `subscribeToTopic('sample_push')` after permission is granted.
2. The CLI sends to topic `sample_push`.
3. FCM delivers to current subscribers.

Use the **exact same** topic string in the app and CLI: **`sample_push`**.

---

## Run the app

```powershell
cd c:\diatom\mobile-samples\11_flutter_push_notifications\flutter
flutter pub get
flutter run
```

On first launch:

1. Grant notification permission when prompted.
2. Confirm the UI shows **Subscribed** to `sample_push` (auto-subscribe after permission).
3. Send a test message from the CLI (see [`../server/README.md`](../server/README.md)).

---

## UI overview

Single home screen:

- **Top:** live clock (time, date, time zone; ticks every second)
- **Middle:** topic name, permission status, Subscribe / Unsubscribe
- **Bottom:** last received notification (title, body, received-at)
- **Debug:** expandable FCM device token (copyable; not required for the happy path)

---

## Manual test path

1. Complete Firebase Android (and iOS if applicable) registration + `flutterfire configure`.
2. Place service account JSON under `../secrets/` (see server README).
3. Run this app → grant permission → confirm subscribed to `sample_push`.
4. Run the Dart CLI → enter title (≤30) and body (≤100) → send.
5. Confirm system notification + in-app “Last notification” update.
6. Tap **Unsubscribe** → send again → device should not receive → **Subscribe** and retest.

---

## Common pitfalls

| Symptom | Likely cause |
|---------|----------------|
| CLI succeeds but phone silent | App not subscribed; wrong topic; permission denied; Android emulator without Google Play |
| iOS never receives | APNs key missing in Firebase; Push capability missing; Simulator only; permission denied |
| Firebase init fails | Missing/wrong config files; package/Bundle ID mismatch; placeholder `firebase_options.dart` |
| Subscribe fails | Firebase not initialized; no network; invalid topic name |
| FlutterFire requires Firebase CLI | Install `firebase-tools`; verify `firebase --version` |
| `flutterfire configure` lists 0 projects | Re-auth: `firebase logout` then `firebase login --reauth`; run `firebase projects:list` |

---

## Key files

- [`lib/main.dart`](lib/main.dart) — Firebase init + background handler registration
- [`lib/di/dependencies.dart`](lib/di/dependencies.dart) — composition root
- [`lib/features/push/domain/config/push_topic_config.dart`](lib/features/push/domain/config/push_topic_config.dart) — topic constant `sample_push`
- [`lib/features/push/presentation/view_models/push_view_model.dart`](lib/features/push/presentation/view_models/push_view_model.dart) — push UI state
- [`lib/features/clock/presentation/view_models/clock_view_model.dart`](lib/features/clock/presentation/view_models/clock_view_model.dart) — clock ticks

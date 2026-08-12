# Flutter Push Notifications Sample

End-to-end **Firebase Cloud Messaging (FCM)** demo using **topic messaging**.

- **Flutter app** (`flutter/`) — subscribes to topic `sample_push`, receives push notifications, and shows a live clock (Clean Architecture + MVVM)
- **Dart CLI** (`server/`) — sends a notification to the same topic via FCM HTTP v1

You do not need to publish the app to Google Play or the App Store. Firebase app registration only links your debug/dev package name and Bundle ID to a Firebase project.

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

**Stack:** Flutter, Material 3, `firebase_core`, `firebase_messaging`, `ChangeNotifier` + `ListenableBuilder`.

---

## Structure

```text
11_flutter_push_notifications/
  flutter/          # Flutter mobile app (Android + iOS)
  server/           # Dart CLI sender (FCM HTTP v1)
  secrets/          # local only; gitignored (service account JSON)
  SPEC.md           # implementation brief
```

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| **Flutter / Dart SDK** | Dart `^3.12.2` (included with Flutter stable) |
| **Firebase project** | Cloud Messaging enabled |
| **Android device or emulator** | Emulator must include **Google Play** |
| **iOS device** (optional) | Physical iPhone recommended; Simulator remote push is limited |
| **Apple Developer account** (iOS) | Required for real push; APNs Auth Key (`.p8`) uploaded to Firebase |
| **Firebase CLI + FlutterFire CLI** | Generate `firebase_options.dart` and align platform config |
| **Service account JSON** | CLI send credential only — never embed in the mobile app |

**Platform identifiers** (must match Firebase Console registration):

| Platform | Identifier |
|----------|------------|
| Android | `com.example.flutter_push_notifications` |
| iOS | `com.example.flutterPushNotifications` |

**Shared topic:** `sample_push` (same string in app and CLI).

---

## Configure and run (whole sample)

### 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/) and sign in.
2. Click **Add project** and follow the wizard (Google Analytics is optional).
3. Note the **Project ID** (Project settings → General).

You only need **Cloud Messaging** for this sample.

### 2. Register the Android app

1. Project overview → **Add app** → **Android**.
2. **Package name:** `com.example.flutter_push_notifications`.
3. Register → download **`google-services.json`**.
4. Replace the placeholder at `flutter/android/app/google-services.json`.

Use an emulator **with Google Play** or a physical device. Debug SHA-1 is **not** required for basic FCM in this sample.

### 3. Register the iOS app (optional)

1. Project overview → **Add app** → **iOS**.
2. **Bundle ID:** `com.example.flutterPushNotifications`.
3. Register → download **`GoogleService-Info.plist`**.
4. Add the file to the Xcode **Runner** target.

For real iOS push, configure APNs in Apple Developer and upload the APNs Auth Key to Firebase Console → Cloud Messaging. See [flutter/README.md](flutter/README.md) for the full iOS walkthrough.

### 4. Generate `firebase_options.dart`

Install the [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli), then from the `flutter/` folder:

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
cd c:\diatom\mobile-samples\11_flutter_push_notifications\flutter
flutterfire configure
```

Select your Firebase project and the Android/iOS apps you registered. This updates `lib/firebase_options.dart` and aligns platform config files.

**Do not commit real Firebase client config.** This repo ships **placeholders** only. Keep generated files local.

### 5. Set up the CLI service account

1. Firebase Console → **Project settings** → **Service accounts**.
2. Click **Generate new private key** → download the JSON.
3. Store locally, for example:

   ```text
   c:\diatom\mobile-samples\11_flutter_push_notifications\secrets\fcm-service-account.json
   ```

**Never commit this file.** The `secrets/` folder is gitignored. This credential is for **sending only** — never embed it in the Flutter APK/IPA.

### 6. Run the Flutter app

```powershell
cd c:\diatom\mobile-samples\11_flutter_push_notifications\flutter
flutter pub get
flutter run
```

On first launch:

1. Grant notification permission when prompted.
2. Confirm the UI shows **Subscribed** to `sample_push` (auto-subscribe after permission).

### 7. Send a test notification

```powershell
cd c:\diatom\mobile-samples\11_flutter_push_notifications\server
dart pub get
dart run server --service-account ..\secrets\fcm-service-account.json
```

Or set the environment variable:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "c:\diatom\mobile-samples\11_flutter_push_notifications\secrets\fcm-service-account.json"
dart run server
```

The CLI prompts for a title (≤30 characters) and body (≤100 characters). Confirm the system notification and the in-app **Last notification** update.

### 8. Verify unsubscribe (optional)

1. Tap **Unsubscribe** in the app → send again → device should not receive.
2. Tap **Subscribe** → send again → notification should arrive.

---

## Further reading

| Document | Contents |
|----------|----------|
| [flutter/README.md](flutter/README.md) | Firebase setup deep dive, UI overview, FlutterFire troubleshooting, common pitfalls |
| [server/README.md](server/README.md) | CLI flags, credentials, interactive prompts, end-to-end test details |
| [SPEC.md](SPEC.md) | Implementation brief and acceptance checklist |

---

## Notes

- **Topics are implicit** — there is no Firebase Console step to "create" a topic. The app calls `subscribeToTopic('sample_push')` and the CLI sends to `sample_push`; FCM delivers to current subscribers.
- **Client config vs service account** — `google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` are for the mobile app (receive + subscribe). The service account JSON is for the CLI only (send).
- **Placeholders in repo** — `firebase_options.dart` and `google-services.json` ship with placeholder values. Replace them locally via Firebase Console downloads and `flutterfire configure` before running.
- **No device token required** — this sample uses topic messaging, not per-device token targeting. An expandable debug section in the app shows the FCM token for troubleshooting only.

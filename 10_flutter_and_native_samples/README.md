# flutter_and_native_samples

Flutter samples that demonstrate interoperability with platform-native Android (Kotlin) and iOS (Swift) code through `MethodChannel`.

## Examples

| Example | Description |
| ------- | ----------- |
| `native_biometric_auth` | Unlock protected Flutter UI after native biometric authentication (AndroidX `BiometricPrompt` / iOS `LocalAuthentication`). |
| Native view | A view rendered entirely by native code (Android `View` / iOS `UIView`) embedded in Flutter through a `PlatformView`. |
| Call native view | Flutter uses a `MethodChannel` to open a native Android `Activity` or iOS `UIViewController` with a profile screen. |
| Async native task | Flutter invokes native code that waits a random delay (1–10 s) and returns the result asynchronously. |
| Pigeon sample | A single `WifiStatus` type defined in a Pigeon schema and generated as type-safe code for Dart, Kotlin and Swift. |

The home screen (`lib/screens/home_screen.dart`) lists every sample.

---

## native_biometric_auth

Small Flutter app that unlocks a protected section after the device owner authenticates with biometrics.

**This example performs local device-owner authentication. It does not identify a remote user, create a login session, or replace server-side authentication.**

### Architecture

```text
Flutter UI
    ↓
BiometricAuthService (Dart)
    ↓
MethodChannel: examples.native_biometric_auth/biometrics
    ├── Android: Kotlin + AndroidX BiometricPrompt
    └── iOS: Swift + LocalAuthentication
```

### Responsibility split

| Responsabilidad              | Flutter/Dart | Kotlin     | Swift      |
| ---------------------------- | ------------ | ---------- | ---------- |
| Renderizar la interfaz       | Sí           | No         | No         |
| Administrar estado bloqueado | Sí           | No         | No         |
| Consultar disponibilidad     | Solicita     | Implementa | Implementa |
| Mostrar diálogo biométrico   | No           | Sí         | Sí         |
| Interpretar APIs del sistema | No           | Sí         | Sí         |
| Mostrar resultado final      | Sí           | No         | No         |

### Project layout

```text
lib/
  main.dart
  models/
    biometric_type.dart
    biometric_status.dart
    biometric_auth_result.dart
  services/
    biometric_auth_service.dart
  screens/
    biometric_auth_screen.dart
android/app/src/main/kotlin/.../
  MainActivity.kt
  BiometricAuthChannel.kt
ios/Runner/
  AppDelegate.swift
  BiometricAuthChannel.swift
  Info.plist   # NSFaceIDUsageDescription
```

### MethodChannel contract

Channel name (must match on Dart, Kotlin, and Swift):

```text
examples.native_biometric_auth/biometrics
```

#### `getBiometricStatus`

Returns availability without showing a prompt:

```json
{
  "available": true,
  "type": "fingerprint",
  "reason": null
}
```

`type`: `fingerprint` | `face` | `iris` | `multiple` | `none` | `unknown`

When unavailable, `reason` is one of:
`notSupported` | `notEnrolled` | `temporarilyLocked` | `permanentlyLocked` | `permissionMissing` | `unavailable` | `unknown`

#### `authenticate`

Arguments:

```json
{ "reason": "Authenticate to access the protected content" }
```

Result:

```json
{
  "success": true,
  "errorCode": null,
  "errorMessage": null
}
```

Shared error codes:
`userCanceled` | `systemCanceled` | `authenticationFailed` | `notSupported` | `notEnrolled` | `temporarilyLocked` | `permanentlyLocked` | `permissionMissing` | `unavailable` | `invalidArguments` | `alreadyInProgress` | `unknown`

### What this sample intentionally excludes

- `local_auth` and other biometric plugins
- PIN / password / device-credential fallback (`DEVICE_CREDENTIAL` / `deviceOwnerAuthentication`)
- Backend auth, sessions, tokens, Keystore/Keychain crypto tied to biometrics

### Run

```bash
flutter pub get
flutter run
```

Use a physical device or an emulator/simulator with biometrics enrolled (fingerprint on Android emulator, Face ID / Touch ID on iOS Simulator).

### Notes

- Android uses `BiometricManager.Authenticators.BIOMETRIC_STRONG` only.
- iOS uses `LAPolicy.deviceOwnerAuthenticationWithBiometrics` only.
- Flutter owns lock/unlock UI state; **Lock again** does not call native code.

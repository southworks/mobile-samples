# Authors Collection

Aplicación Flutter lista para extender con:

- Flutter estable
- Material 3
- Google Sign-In
- Firebase Authentication
- Persistencia de sesión usando `FirebaseAuth`

## Estructura

```text
lib/
  app.dart
  firebase_options.dart
  config/
    google_sign_in_config.dart
  models/
    auth_result.dart
  screens/
    home_screen.dart
    login_screen.dart
    startup_error_screen.dart
  services/
    auth_service.dart
  state/
    auth_controller.dart
  widgets/
    auth_gate.dart
  main.dart
```

## Dependencias

- `firebase_core`
- `firebase_auth`
- `google_sign_in`
- `provider`

## Configuración paso a paso

### 1. Crear proyecto Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/).
2. Crea un proyecto nuevo.
3. Entra al proyecto y abre `Project settings`.

### 2. Registrar Android

1. Agrega una app Android.
2. Usa el mismo `applicationId` que está en `android/app/build.gradle.kts`.
3. Descarga `google-services.json`.
4. Copia el archivo en `android/app/google-services.json`.
5. En Firebase, agrega la huella SHA-1 y SHA-256 de tu app.

Para obtener la huella debug:

```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

### 3. Registrar iOS

1. Agrega una app iOS en Firebase.
2. Usa el mismo Bundle ID que configures en Xcode para `Runner`.
3. Descarga `GoogleService-Info.plist`.
4. Usa ese archivo para completar estos valores en `ios/Runner/Info.plist`:
   - `GIDClientID` con `CLIENT_ID`
   - `GIDServerClientID` con tu Web client ID
   - `CFBundleURLSchemes` con `REVERSED_CLIENT_ID`
5. Recomendado: agrega también `GoogleService-Info.plist` al target `Runner` desde Xcode.

### 4. Habilitar Google Provider

1. Ve a `Authentication`.
2. Abre `Sign-in method`.
3. Habilita `Google`.
4. Selecciona un email de soporte si Firebase lo pide.

### 5. Generar `firebase_options.dart`

La forma recomendada es usar FlutterFire CLI y reemplazar el archivo placeholder actual:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Ese comando:

- actualiza `lib/firebase_options.dart`
- ayuda a alinear Android/iOS con el proyecto Firebase

Si no usas `flutterfire configure`, reemplaza manualmente los placeholders actuales de `lib/firebase_options.dart`.

### 6. Configurar Google Sign-In server client ID

Si tu flujo lo necesita explícitamente, corre con:

```powershell
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

En Android, con `google-services.json` actualizado y un cliente web presente, normalmente no hace falta.

## Correr la app

```powershell
flutter pub get
flutter run
```

Para iOS:

```powershell
flutter run -d ios
```

Para Android:

```powershell
flutter run -d android
```

## Notas importantes

- `google_sign_in` 7.x requiere `initialize()` antes de autenticar. Eso ya está resuelto en `AuthService`.
- El login de Google se convierte en sesión de la app usando `FirebaseAuth.signInWithCredential`.
- La persistencia de sesión la maneja `FirebaseAuth`, por eso `AuthGate` salta directo al Home si el usuario sigue autenticado.
- Antes de ejecutar en dispositivos reales, reemplaza todos los placeholders de Firebase y Google.

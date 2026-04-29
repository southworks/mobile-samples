# Authors Collection Android

Aplicación Android nativa en Kotlin + Jetpack Compose que replica la app Flutter de referencia con autenticación Google SSO sobre Firebase Authentication.

## Stack

- Kotlin
- Android nativo
- Jetpack Compose
- Material 3
- Firebase Authentication
- Credential Manager + Google ID token
- ViewModel + StateFlow
- Navigation Compose

## Estructura

```text
AuthorsCollection/
├── app/
│   ├── build.gradle.kts
│   ├── google-services.json.example
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/example/authorscollection/
│       │   ├── MainActivity.kt
│       │   ├── app/AuthorsCollectionApp.kt
│       │   ├── auth/
│       │   │   ├── AuthRepository.kt
│       │   │   ├── AuthUiState.kt
│       │   │   ├── AuthUser.kt
│       │   │   └── AuthViewModel.kt
│       │   ├── navigation/AppDestination.kt
│       │   ├── navigation/AppNavGraph.kt
│       │   └── ui/
│       │       ├── screens/
│       │       │   ├── HomeScreen.kt
│       │       │   ├── LoginScreen.kt
│       │       │   ├── SplashScreen.kt
│       │       │   └── StartupErrorScreen.kt
│       │       └── theme/
│       │           ├── Color.kt
│       │           ├── Theme.kt
│       │           └── Type.kt
│       └── res/
│           ├── values/
│           │   ├── strings.xml
│           │   └── themes.xml
│           └── xml/
│               ├── backup_rules.xml
│               └── data_extraction_rules.xml
├── build.gradle.kts
├── gradle.properties
└── settings.gradle.kts
```

## Configuración manual

### 1. Crear proyecto Firebase

1. Entrá a [Firebase Console](https://console.firebase.google.com/).
2. Creá un proyecto nuevo o reutilizá uno existente.
3. Agregá una app Android con package name `com.example.authorscollection`.

### 2. Registrar la app Android

1. En Firebase, registrá:
   - `ApplicationId`: `com.example.authorscollection`
2. Descargá el archivo `google-services.json`.
3. Copialo en:
   - `C:\Southworks\Code\Research\AuthorsCollection\app\google-services.json`

### 3. Habilitar Firebase Authentication

1. En Firebase Console, abrí `Authentication`.
2. Entrá en `Sign-in method`.
3. Habilitá el proveedor `Google`.

### 4. Configurar SHA-1 y SHA-256

Firebase y Google Sign-In necesitan las huellas del certificado de firma.

Podés obtenerlas con:

```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

Luego:

1. Copiá `SHA1` y `SHA-256`.
2. En Firebase Console, abrí la app Android registrada.
3. Agregá ambas huellas.
4. Volvé a descargar `google-services.json` si Firebase lo solicita.

### 5. Confirmar Web client ID

Este proyecto usa `Credential Manager` para pedir un `Google ID token` y luego autenticar en Firebase con `GoogleAuthProvider`.

Ese flujo necesita el `Web client ID` de OAuth 2.0:

1. En Firebase Console o Google Cloud Console, buscá el cliente OAuth de tipo `Web application`.
2. Verificá que exista un client ID con formato:
   - `1234567890-xxxxx.apps.googleusercontent.com`
3. Normalmente `google-services.json` ya expone ese valor como `default_web_client_id`.
4. Si por alguna razón no aparece, revisá la configuración OAuth del proyecto.

### 6. Sincronizar y correr

Desde Android Studio:

1. Abrí la carpeta:
   - `C:\Southworks\Code\Research\AuthorsCollection`
2. Esperá el `Gradle Sync`.
3. Seleccioná un emulador o dispositivo.
4. Ejecutá la app.

## Comandos útiles

Desde Android Studio:

1. `Sync Project with Gradle Files`
2. `Run 'app'`

Si agregás Gradle Wrapper desde Android Studio o ya lo tenés disponible:

```powershell
gradle assembleDebug
gradle installDebug
```

## Decisión técnica

Se usa `Credential Manager` con `GetGoogleIdOption` porque hoy es el camino recomendado para Android moderno al pedir credenciales federadas de Google y convertir el `ID token` en una credencial válida de Firebase. Además, permite limpiar el estado de credenciales al cerrar sesión para evitar auto sign-in no deseado.

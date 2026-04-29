# Authors Collection iOS

Aplicacion iOS nativa en Swift que replica la app Flutter de referencia:

- SwiftUI
- Firebase Authentication
- Google Sign-In
- Persistencia de sesion usando `FirebaseAuth`

## Estructura

```text
swift/
  AuthorsCollection.xcodeproj
  AuthorsCollection/
    AppDelegate.swift
    AuthorsCollectionApp.swift
    Models/
    Services/
    ViewModels/
    Views/
    Resources/
      Assets.xcassets
      Base.lproj/LaunchScreen.storyboard
      GoogleService-Info.plist
      Info.plist
```

## Configuracion

### 1. Crear la app iOS en Firebase

1. Entra a [Firebase Console](https://console.firebase.google.com/).
2. Agrega una app iOS al proyecto.
3. Usa como Bundle ID el mismo que queda configurado en Xcode.
   - Por defecto este proyecto usa `com.example.authorscollection`

### 2. Reemplazar `GoogleService-Info.plist`

1. Descarga el `GoogleService-Info.plist` real desde Firebase.
2. Reemplaza este archivo:
   - `swift/AuthorsCollection/Resources/GoogleService-Info.plist`

Mientras el archivo tenga placeholders, la app compila pero muestra una pantalla de error al iniciar.

### 3. Completar `Info.plist`

Edita:

- `swift/AuthorsCollection/Resources/Info.plist`

Reemplaza estos valores:

- `GIDClientID` con `CLIENT_ID` del `GoogleService-Info.plist`
- `GIDServerClientID` con tu Web client ID de OAuth
- `CFBundleURLSchemes` con `REVERSED_CLIENT_ID`

### 4. Habilitar Google provider

1. En Firebase, abre `Authentication`.
2. Ve a `Sign-in method`.
3. Habilita `Google`.

## Abrir y compilar en Mac

1. Abre `swift/AuthorsCollection.xcodeproj` en Xcode.
2. Espera a que Xcode resuelva los paquetes Swift Package Manager.
3. Selecciona un iPhone o simulador iOS.
4. Ejecuta `Run`.

Si vas a instalar en un iPhone real:

1. Cambia el `Team` en Signing & Capabilities.
2. Si modificas el bundle ID, vuelve a registrar ese ID en Firebase.
3. Reemplaza nuevamente `GoogleService-Info.plist` si corresponde a otro bundle ID.

## Flujo replicado desde Flutter

- Splash mientras se inicializa Firebase
- Pantalla de error si falta configuracion nativa
- Login con Google
- Intercambio del token de Google por credencial Firebase
- Home con nombre, email y avatar
- Logout con limpieza de sesion local

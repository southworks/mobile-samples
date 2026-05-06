import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

enum StartupConfigurationError: LocalizedError {
    case missingGoogleServiceInfo
    case invalidGoogleServiceInfo
    case placeholderGoogleServiceInfo
    case placeholderInfoPlist

    var errorDescription: String? {
        switch self {
        case .missingGoogleServiceInfo:
            return "Falta el archivo GoogleService-Info.plist en google-sso-sample/Resources."
        case .invalidGoogleServiceInfo:
            return "GoogleService-Info.plist existe, pero no tiene un formato valido."
        case .placeholderGoogleServiceInfo:
            return "GoogleService-Info.plist todavia tiene placeholders. Reemplazalo con el archivo real de Firebase."
        case .placeholderInfoPlist:
            return "Info.plist todavia tiene placeholders de Google Sign-In. Completa GIDClientID, GIDServerClientID y CFBundleURLSchemes."
        }
    }
}

final class AuthService {
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private var auth: Auth {
        Auth.auth()
    }

    deinit {
        if let authStateHandle {
            auth.removeStateDidChangeListener(authStateHandle)
        }
    }

    func configureFirebaseIfNeeded() throws {
        if FirebaseApp.app() != nil {
            return
        }

        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            throw StartupConfigurationError.missingGoogleServiceInfo
        }

        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            throw StartupConfigurationError.invalidGoogleServiceInfo
        }
        
        guard let clientID = options.clientID,
              let apiKey = options.apiKey else {
            throw StartupConfigurationError.invalidGoogleServiceInfo
        }
        
        let hasPlaceholders = [
            options.googleAppID,
            clientID,
            apiKey,
            options.projectID ?? "",
        ].contains { value in
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            value.contains("YOUR_") ||
            value.contains("REPLACE_")
        }

        if hasPlaceholders {
            throw StartupConfigurationError.placeholderGoogleServiceInfo
        }

        let infoClientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String ?? ""
        let infoServerClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String ?? ""
        let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] ?? []
        let urlSchemes = urlTypes.flatMap { item in
            item["CFBundleURLSchemes"] as? [String] ?? []
        }

        let hasInfoPlistPlaceholders = [infoClientID, infoServerClientID].contains { value in
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value.contains("YOUR_")
        } || urlSchemes.contains(where: { $0.contains("YOUR_") })

        if hasInfoPlistPlaceholders {
            throw StartupConfigurationError.placeholderInfoPlist
        }

        FirebaseApp.configure(options: options)
    }

    func observeAuthState(_ onChange: @escaping (AuthUser?) -> Void) {
        if let authStateHandle {
            auth.removeStateDidChangeListener(authStateHandle)
        }

        authStateHandle = auth.addStateDidChangeListener { _, user in
            onChange(user.map(Self.makeAuthUser(from:)))
        }
    }

    @MainActor
    func signInWithGoogle() async -> Result<Void, Error> {
        do {
            try configureFirebaseIfNeeded()

            guard let rootViewController = UIApplication.shared.topViewController else {
                throw NSError(
                    domain: "google-sso-sample.auth",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "No se encontro una pantalla valida para presentar Google Sign-In."]
                )
            }

            guard let clientID = FirebaseApp.app()?.options.clientID, !clientID.isEmpty else {
                throw NSError(
                    domain: "google-sso-sample.auth",
                    code: 1002,
                    userInfo: [NSLocalizedDescriptionKey: "Falta el Client ID de iOS en la configuracion de Firebase."]
                )
            }

            let serverClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String
            //let normalizedServerClientID = serverClientID?.trimmingCharacters(in: .whitespacesAndNewlines)
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(
                clientID: clientID,
                //serverClientID: normalizedServerClientID?.isEmpty == false ? normalizedServerClientID : nil
            )

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let googleUser = result.user

            guard let idToken = googleUser.idToken?.tokenString else {
                throw NSError(
                    domain: "google-sso-sample.auth",
                    code: 1003,
                    userInfo: [NSLocalizedDescriptionKey: "Google no devolvio un token valido. Revisa la configuracion del proyecto."]
                )
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: googleUser.accessToken.tokenString
            )

            _ = try await auth.signIn(with: credential)
            return .success(())
        } catch {
            return .failure(mapToUserReadableError(error))
        }
    }

    func signOut() -> Result<Void, Error> {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    private func mapToUserReadableError(_ error: Error) -> Error {
        let nsError = error as NSError

        if nsError.localizedDescription.localizedCaseInsensitiveContains("canceled") ||
            nsError.localizedDescription.localizedCaseInsensitiveContains("cancelled") {
            return NSError(
                domain: nsError.domain,
                code: nsError.code,
                userInfo: [NSLocalizedDescriptionKey: "Inicio de sesion cancelado."]
            )
        }

        if nsError.domain == AuthErrorDomain {
            switch AuthErrorCode(_bridgedNSError: nsError)?.code {
            case .accountExistsWithDifferentCredential:
                return NSError(
                    domain: nsError.domain,
                    code: nsError.code,
                    userInfo: [NSLocalizedDescriptionKey: "Ya existe una cuenta con ese email usando otro metodo de acceso."]
                )
            case .invalidCredential:
                return NSError(
                    domain: nsError.domain,
                    code: nsError.code,
                    userInfo: [NSLocalizedDescriptionKey: "Las credenciales recibidas no son validas."]
                )
            case .networkError:
                return NSError(
                    domain: nsError.domain,
                    code: nsError.code,
                    userInfo: [NSLocalizedDescriptionKey: "No hay conexion disponible. Revisa tu red e intenta nuevamente."]
                )
            case .userDisabled:
                return NSError(
                    domain: nsError.domain,
                    code: nsError.code,
                    userInfo: [NSLocalizedDescriptionKey: "Esta cuenta fue deshabilitada."]
                )
            default:
                break
            }
        }

        return NSError(
            domain: nsError.domain,
            code: nsError.code,
            userInfo: [NSLocalizedDescriptionKey: nsError.localizedDescription]
        )
    }

    private static func makeAuthUser(from user: FirebaseAuth.User) -> AuthUser {
        AuthUser(
            displayName: user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? user.displayName!
                : "Usuario sin nombre",
            email: user.email?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? user.email!
                : "Sin email disponible",
            photoURL: user.photoURL?.absoluteString
        )
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        let rootViewController = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        return topViewController(from: rootViewController)
    }

    func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        return viewController
    }
}

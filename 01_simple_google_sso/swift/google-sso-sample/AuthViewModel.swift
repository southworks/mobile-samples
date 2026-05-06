import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var isInitializing = true
    @Published private(set) var isSigningIn = false
    @Published private(set) var isSigningOut = false
    @Published private(set) var user: AuthUser?
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
        start()
    }

    func signInWithGoogle() {
        guard !isSigningIn else { return }

        errorMessage = nil
        isSigningIn = true

        Task {
            let result = await authService.signInWithGoogle()

            if case .failure(let error) = result {
                errorMessage = error.localizedDescription
            }

            isSigningIn = false
        }
    }

    func signOut() {
        guard !isSigningOut else { return }

        errorMessage = nil
        isSigningOut = true

        let result = authService.signOut()

        if case .failure(let error) = result {
            errorMessage = error.localizedDescription
        }

        isSigningOut = false
    }

    private func start() {
        do {
            try authService.configureFirebaseIfNeeded()
            authService.observeAuthState { [weak self] user in
                guard let self else { return }
                self.user = user
                self.isInitializing = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isInitializing = false
        }
    }
}

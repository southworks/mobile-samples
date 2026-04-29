import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var state = AuthViewState()

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
        start()
    }

    func signInWithGoogle() {
        guard !state.isSigningIn else { return }

        state.errorMessage = nil
        state.isSigningIn = true

        Task {
            let result = await authService.signInWithGoogle()

            if case .failure(let error) = result {
                state.errorMessage = error.localizedDescription
            }

            state.isSigningIn = false
        }
    }

    func signOut() {
        guard !state.isSigningOut else { return }

        state.errorMessage = nil
        state.isSigningOut = true

        let result = authService.signOut()

        if case .failure(let error) = result {
            state.errorMessage = error.localizedDescription
        }

        state.isSigningOut = false
    }

    private func start() {
        do {
            try authService.configureFirebaseIfNeeded()
            authService.observeAuthState { [weak self] user in
                guard let self else { return }
                self.state.user = user
                self.state.isInitializing = false
            }
        } catch {
            state.startupErrorMessage = error.localizedDescription
            state.isInitializing = false
        }
    }
}

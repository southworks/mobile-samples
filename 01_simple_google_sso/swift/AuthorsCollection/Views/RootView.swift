import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        if viewModel.state.isInitializing {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBackground.ignoresSafeArea())
        } else if let user = viewModel.state.user {
            HomeView(
                user: user,
                isSigningOut: viewModel.state.isSigningOut,
                errorMessage: viewModel.state.errorMessage,
                onSignOutTap: viewModel.signOut
            )
        } else {
            LoginView(
                isSigningIn: viewModel.state.isSigningIn,
                errorMessage: viewModel.state.startupErrorMessage ?? viewModel.state.errorMessage,
                onSignInTap: viewModel.signInWithGoogle
            )
        }
    }
}

extension Color {
    static let appBackground = Color(red: 0.965, green: 0.973, blue: 0.984)
    static let appPrimary = Color(red: 0.059, green: 0.463, blue: 0.431)
    static let appTextSecondary = Color(red: 0.376, green: 0.424, blue: 0.478)
    static let appCardBackground = Color.white
    static let appBorder = Color.black.opacity(0.05)
}

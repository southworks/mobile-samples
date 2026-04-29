struct AuthViewState {
    var isInitializing = true
    var isSigningIn = false
    var isSigningOut = false
    var user: AuthUser?
    var errorMessage: String?
    var startupErrorMessage: String?
}

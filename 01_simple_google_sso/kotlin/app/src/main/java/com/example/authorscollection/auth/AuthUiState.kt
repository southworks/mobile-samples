package com.example.authorscollection.auth

data class AuthUiState(
    val isInitializing: Boolean = true,
    val isSigningIn: Boolean = false,
    val isSigningOut: Boolean = false,
    val user: AuthUser? = null,
    val errorMessage: String? = null
) {
    val isAuthenticated: Boolean
        get() = user != null
}


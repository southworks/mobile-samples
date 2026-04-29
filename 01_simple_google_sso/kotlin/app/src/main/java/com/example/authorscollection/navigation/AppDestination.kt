package com.example.authorscollection.navigation

sealed class AppDestination(val route: String) {
    data object Splash : AppDestination("splash")
    data object Login : AppDestination("login")
    data object Home : AppDestination("home")
    data object StartupError : AppDestination("startup_error")
}


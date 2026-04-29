package com.example.authorscollection.navigation

import android.app.Activity
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.navigation.NavHostController
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.authorscollection.auth.AuthUiState
import com.example.authorscollection.ui.screens.HomeScreen
import com.example.authorscollection.ui.screens.LoginScreen
import com.example.authorscollection.ui.screens.SplashScreen
import com.example.authorscollection.ui.screens.StartupErrorScreen

@Composable
fun AppNavGraph(
    authUiState: AuthUiState?,
    startupError: String?,
    onSignInClick: (Activity) -> Unit,
    onSignOutClick: () -> Unit,
    navController: NavHostController = rememberNavController()
) {
    LaunchedEffect(startupError, authUiState?.isInitializing, authUiState?.isAuthenticated) {
        val targetRoute = when {
            startupError != null -> AppDestination.StartupError.route
            authUiState == null || authUiState.isInitializing -> AppDestination.Splash.route
            authUiState.isAuthenticated -> AppDestination.Home.route
            else -> AppDestination.Login.route
        }

        navController.navigate(targetRoute) {
            popUpTo(navController.graph.findStartDestination().id) {
                inclusive = true
            }
            launchSingleTop = true
        }
    }

    NavHost(
        navController = navController,
        startDestination = AppDestination.Splash.route
    ) {
        composable(AppDestination.Splash.route) {
            SplashScreen()
        }

        composable(AppDestination.Login.route) {
            LoginScreen(
                isLoading = authUiState?.isSigningIn == true,
                errorMessage = authUiState?.errorMessage,
                onSignInClick = onSignInClick
            )
        }

        composable(AppDestination.Home.route) {
            val user = authUiState?.user
            if (user != null) {
                HomeScreen(
                    user = user,
                    isSigningOut = authUiState.isSigningOut,
                    errorMessage = authUiState.errorMessage,
                    onSignOutClick = onSignOutClick
                )
            } else {
                SplashScreen()
            }
        }

        composable(AppDestination.StartupError.route) {
            StartupErrorScreen(
                message = startupError
                    ?: "No se pudo inicializar Firebase. Revisá la configuración del proyecto."
            )
        }
    }
}

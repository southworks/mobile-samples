package com.example.authorscollection.app

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.authorscollection.auth.AuthViewModel
import com.example.authorscollection.navigation.AppNavGraph
import com.example.authorscollection.ui.theme.AuthorsCollectionTheme

@Composable
fun AuthorsCollectionApp(startupError: String?) {
    AuthorsCollectionTheme {
        Surface(modifier = Modifier.fillMaxSize()) {
            if (startupError != null) {
                AppNavGraph(
                    authUiState = null,
                    startupError = startupError,
                    onSignInClick = {},
                    onSignOutClick = {}
                )
            } else {
                val context = LocalContext.current.applicationContext
                val viewModel: AuthViewModel = viewModel(
                    factory = AuthViewModel.Factory(context)
                )
                val authUiState by viewModel.uiState.collectAsStateWithLifecycle()

                AppNavGraph(
                    authUiState = authUiState,
                    startupError = null,
                    onSignInClick = viewModel::signInWithGoogle,
                    onSignOutClick = viewModel::signOut
                )
            }
        }
    }
}


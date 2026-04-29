package com.example.authorscollection.auth

import android.app.Activity
import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class AuthViewModel(
    private val repository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            repository.authState().collect { user ->
                _uiState.update { currentState ->
                    currentState.copy(
                        isInitializing = false,
                        user = user
                    )
                }
            }
        }
    }

    fun signInWithGoogle(activity: Activity) {
        if (_uiState.value.isSigningIn) return

        viewModelScope.launch {
            _uiState.update {
                it.copy(
                    isSigningIn = true,
                    errorMessage = null
                )
            }

            val result = repository.signInWithGoogle(activity)

            _uiState.update {
                it.copy(
                    isSigningIn = false,
                    errorMessage = result.exceptionOrNull()?.message
                )
            }
        }
    }

    fun signOut() {
        if (_uiState.value.isSigningOut) return

        viewModelScope.launch {
            _uiState.update {
                it.copy(
                    isSigningOut = true,
                    errorMessage = null
                )
            }

            val result = repository.signOut()

            _uiState.update {
                it.copy(
                    isSigningOut = false,
                    errorMessage = result.exceptionOrNull()?.message
                )
            }
        }
    }

    class Factory(
        private val appContext: Context
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return AuthViewModel(
                repository = AuthRepository(appContext)
            ) as T
        }
    }
}


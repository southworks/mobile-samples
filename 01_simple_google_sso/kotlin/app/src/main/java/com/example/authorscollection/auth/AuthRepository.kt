package com.example.authorscollection.auth

import android.app.Activity
import android.content.Context
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.exceptions.ClearCredentialException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.example.authorscollection.BuildConfig
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenParsingException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class AuthRepository(
    private val appContext: Context,
    private val credentialManager: CredentialManager = CredentialManager.create(appContext),
    private val firebaseAuth: FirebaseAuth = FirebaseAuth.getInstance()
) {

    fun authState(): Flow<AuthUser?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { auth ->
            trySend(auth.currentUser?.toAuthUser())
        }

        firebaseAuth.addAuthStateListener(listener)
        awaitClose { firebaseAuth.removeAuthStateListener(listener) }
    }

    suspend fun signInWithGoogle(activity: Activity): Result<Unit> {
        val webClientId = resolveWebClientId()
            ?: return Result.failure(
                IllegalStateException(
                    "Falta el Web client ID de Google. Revisá google-services.json y la configuración OAuth en Firebase."
                )
            )

        return runCatching {
            val credentialResponse = try {
                getCredentialResponse(
                    activity = activity,
                    webClientId = webClientId,
                    filterByAuthorizedAccounts = true
                )
            } catch (_: NoCredentialException) {
                getCredentialResponse(
                    activity = activity,
                    webClientId = webClientId,
                    filterByAuthorizedAccounts = false
                )
            }

            val googleIdToken = extractGoogleIdToken(credentialResponse)
            val firebaseCredential = GoogleAuthProvider.getCredential(googleIdToken, null)
            firebaseAuth.signInWithCredential(firebaseCredential).await()
            Unit
        }.recoverCatching { throwable ->
            throw mapToUserReadableException(throwable)
        }
    }

    suspend fun signOut(): Result<Unit> {
        return runCatching {
            firebaseAuth.signOut()

            try {
                credentialManager.clearCredentialState(ClearCredentialStateRequest())
            } catch (_: ClearCredentialException) {
                // Firebase ya cerró sesión; si falla la limpieza de credenciales,
                // evitamos bloquear el logout.
            }
        }
    }

    private suspend fun getCredentialResponse(
        activity: Activity,
        webClientId: String,
        filterByAuthorizedAccounts: Boolean
    ): GetCredentialResponse {
        val googleIdOption = GetGoogleIdOption.Builder()
            .setServerClientId(webClientId)
            .setFilterByAuthorizedAccounts(filterByAuthorizedAccounts)
            .setAutoSelectEnabled(false)
            .build()

        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        return credentialManager.getCredential(
            context = activity,
            request = request
        )
    }

    private fun extractGoogleIdToken(response: GetCredentialResponse): String {
        val credential = response.credential

        if (
            credential is CustomCredential &&
            credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
        ) {
            return try {
                GoogleIdTokenCredential.createFrom(credential.data).idToken
            } catch (exception: GoogleIdTokenParsingException) {
                throw IllegalStateException(
                    "Google devolvió una credencial inválida. Revisá la configuración del proveedor.",
                    exception
                )
            }
        }

        throw IllegalStateException("No se recibió una credencial de Google compatible.")
    }

    private fun resolveWebClientId(): String? {
        val generatedResourceId = appContext.resources.getIdentifier(
            "default_web_client_id",
            "string",
            appContext.packageName
        )

        val value = when {
            generatedResourceId != 0 -> appContext.getString(generatedResourceId)
            else -> BuildConfig.GOOGLE_WEB_CLIENT_ID_PLACEHOLDER
        }

        return value.takeUnless {
            it.isBlank() || it == BuildConfig.GOOGLE_WEB_CLIENT_ID_PLACEHOLDER
        }
    }

    private fun mapToUserReadableException(throwable: Throwable): Throwable {
        return when (throwable) {
            is GetCredentialCancellationException ->
                IllegalStateException("Inicio de sesión cancelado.")

            is NoCredentialException ->
                IllegalStateException("No hay cuentas de Google disponibles para iniciar sesión.")

            is GetCredentialException ->
                IllegalStateException(
                    "No se pudo obtener la credencial de Google. Revisá Play Services y la configuración OAuth.",
                    throwable
                )

            else -> throwable
        }
    }

    private fun com.google.firebase.auth.FirebaseUser.toAuthUser(): AuthUser {
        return AuthUser(
            displayName = displayName?.takeIf { it.isNotBlank() } ?: "Usuario sin nombre",
            email = email?.takeIf { it.isNotBlank() } ?: "Sin email disponible",
            photoUrl = photoUrl?.toString()
        )
    }
}


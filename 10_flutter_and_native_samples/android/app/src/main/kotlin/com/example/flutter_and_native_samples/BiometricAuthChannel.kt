package com.example.flutter_and_native_samples

import android.content.pm.PackageManager
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Flutter MethodChannel calls to AndroidX BiometricPrompt.
 *
 * Android owns and displays the biometric system prompt.
 */
class BiometricAuthChannel(
    private val activity: FragmentActivity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel =
        MethodChannel(messenger, "examples.native_biometric_auth/biometrics")

    private var authenticationInProgress = false
    private var pendingResult: MethodChannel.Result? = null
    private var activePrompt: BiometricPrompt? = null

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
        activePrompt?.cancelAuthentication()
        complete(
            authFailure(
                errorCode = "systemCanceled",
                errorMessage = "Authentication was canceled by the system",
            ),
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBiometricStatus" -> result.success(getBiometricStatus())
            "authenticate" -> authenticate(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getBiometricStatus(): Map<String, Any?> {
        val biometricManager = BiometricManager.from(activity)
        val authenticity =
            biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)

        return when (authenticity) {
            BiometricManager.BIOMETRIC_SUCCESS ->
                mapOf(
                    "available" to true,
                    "type" to detectBiometricType(),
                    "reason" to null,
                )

            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE,
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED,
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED,
            ->
                unavailableStatus(reason = "notSupported")

            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED ->
                unavailableStatus(reason = "notEnrolled")

            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE ->
                unavailableStatus(reason = "unavailable")

            BiometricManager.BIOMETRIC_STATUS_UNKNOWN ->
                unavailableStatus(reason = "unknown")

            else -> unavailableStatus(reason = "unknown")
        }
    }

    private fun authenticate(call: MethodCall, result: MethodChannel.Result) {
        if (authenticationInProgress) {
            result.success(
                authFailure(
                    errorCode = "alreadyInProgress",
                    errorMessage = "A biometric authentication request is already in progress.",
                ),
            )
            return
        }

        val reason = call.argument<String>("reason")
        if (reason.isNullOrBlank()) {
            result.success(
                authFailure(
                    errorCode = "invalidArguments",
                    errorMessage = "authenticate requires a non-empty reason string.",
                ),
            )
            return
        }

        val status = getBiometricStatus()
        val available = status["available"] as? Boolean ?: false
        if (!available) {
            val unavailableReason = status["reason"] as? String ?: "unavailable"
            result.success(
                authFailure(
                    errorCode = unavailableReason,
                    errorMessage = "Biometric authentication is not available ($unavailableReason).",
                ),
            )
            return
        }

        authenticationInProgress = true
        pendingResult = result

        val executor = ContextCompat.getMainExecutor(activity)
        val prompt =
            BiometricPrompt(
                activity,
                executor,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(
                        result: BiometricPrompt.AuthenticationResult,
                    ) {
                        complete(
                            mapOf(
                                "success" to true,
                                "errorCode" to null,
                                "errorMessage" to null,
                            ),
                        )
                    }

                    override fun onAuthenticationError(
                        errorCode: Int,
                        errString: CharSequence,
                    ) {
                        val mapped = mapPromptError(errorCode, errString.toString())
                        complete(mapped)
                    }

                    override fun onAuthenticationFailed() {
                        // Intermediate failure; the system prompt stays open.
                    }
                },
            )

        activePrompt = prompt

        val promptInfo =
            BiometricPrompt.PromptInfo.Builder()
                .setTitle("Biometric authentication")
                .setSubtitle(reason)
                .setNegativeButtonText("Cancel")
                .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
                .build()

        // Android owns and displays the biometric system prompt.
        prompt.authenticate(promptInfo)
    }

    private fun mapPromptError(
        errorCode: Int,
        errString: String,
    ): Map<String, Any?> {
        val mappedCode =
            when (errorCode) {
                BiometricPrompt.ERROR_USER_CANCELED,
                BiometricPrompt.ERROR_NEGATIVE_BUTTON,
                -> "userCanceled"

                BiometricPrompt.ERROR_CANCELED -> "systemCanceled"

                BiometricPrompt.ERROR_LOCKOUT -> "temporarilyLocked"

                BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> "permanentlyLocked"

                BiometricPrompt.ERROR_NO_BIOMETRICS -> "notEnrolled"

                BiometricPrompt.ERROR_HW_NOT_PRESENT,
                BiometricPrompt.ERROR_NO_DEVICE_CREDENTIAL,
                -> "notSupported"

                BiometricPrompt.ERROR_HW_UNAVAILABLE,
                BiometricPrompt.ERROR_VENDOR,
                BiometricPrompt.ERROR_UNABLE_TO_PROCESS,
                BiometricPrompt.ERROR_TIMEOUT,
                -> "unavailable"

                BiometricPrompt.ERROR_NO_SPACE -> "unavailable"

                else -> "authenticationFailed"
            }

        val message =
            when (mappedCode) {
                "userCanceled" -> "Authentication was canceled by the user"
                "systemCanceled" -> "Authentication was canceled by the system"
                else -> errString.ifBlank { "Biometric authentication failed ($mappedCode)." }
            }

        return authFailure(errorCode = mappedCode, errorMessage = message)
    }

    private fun detectBiometricType(): String {
        val packageManager = activity.packageManager
        val fingerprint = packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)
        val face =
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                packageManager.hasSystemFeature(PackageManager.FEATURE_FACE)
        val iris =
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                packageManager.hasSystemFeature(PackageManager.FEATURE_IRIS)

        val enabledCount = listOf(fingerprint, face, iris).count { it }
        return when {
            enabledCount > 1 -> "multiple"
            fingerprint -> "fingerprint"
            face -> "face"
            iris -> "iris"
            else -> "unknown"
        }
    }

    private fun unavailableStatus(reason: String): Map<String, Any?> =
        mapOf(
            "available" to false,
            "type" to "none",
            "reason" to reason,
        )

    private fun authFailure(
        errorCode: String,
        errorMessage: String,
    ): Map<String, Any?> =
        mapOf(
            "success" to false,
            "errorCode" to errorCode,
            "errorMessage" to errorMessage,
        )

    private fun complete(payload: Map<String, Any?>) {
        val result = pendingResult ?: return
        clearInProgressState()
        result.success(payload)
    }

    private fun clearInProgressState() {
        authenticationInProgress = false
        pendingResult = null
        activePrompt = null
    }
}

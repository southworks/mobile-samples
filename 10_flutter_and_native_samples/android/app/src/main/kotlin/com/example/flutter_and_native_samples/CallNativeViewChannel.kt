package com.example.flutter_and_native_samples

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * MethodChannel bridge that starts [ProfileActivity].
 *
 * Flutter requests navigation; Android owns the full-screen native UI.
 */
class CallNativeViewChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel =
        MethodChannel(messenger, "examples.flutter_native_calls/call_native_view")

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openProfile" -> openProfile(result)
            else -> result.notImplemented()
        }
    }

    private fun openProfile(result: MethodChannel.Result) {
        try {
            activity.startActivity(Intent(activity, ProfileActivity::class.java))
            result.success(null)
        } catch (error: Exception) {
            result.error(
                "unavailable",
                "Unable to open native profile Activity: ${error.message}",
                null,
            )
        }
    }
}

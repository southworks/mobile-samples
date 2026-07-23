package com.example.flutter_and_native_samples

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private var biometricAuthChannel: BiometricAuthChannel? = null
    private var nativeComputationChannel: NativeComputationChannel? = null
    private var callNativeViewChannel: CallNativeViewChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        biometricAuthChannel =
            BiometricAuthChannel(activity = this, messenger = messenger)
                .also { it.register() }

        nativeComputationChannel =
            NativeComputationChannel(messenger = messenger).also { it.register() }

        callNativeViewChannel =
            CallNativeViewChannel(activity = this, messenger = messenger)
                .also { it.register() }

        // Pigeon-generated setup: the WifiStatus contract lives in the schema.
        WifiStatusApi.setUp(messenger, WifiStatusApiImpl(this))

        // Android draws this view; Flutter only hosts it through a PlatformView.
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "examples.flutter_native_calls/native_view",
            NativeViewFactory(),
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        biometricAuthChannel?.unregister()
        biometricAuthChannel = null
        nativeComputationChannel?.unregister()
        nativeComputationChannel = null
        callNativeViewChannel?.unregister()
        callNativeViewChannel = null
        WifiStatusApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

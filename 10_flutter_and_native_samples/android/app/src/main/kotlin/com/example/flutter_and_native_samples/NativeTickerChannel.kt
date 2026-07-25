package com.example.flutter_and_native_samples

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * Pushes a tick event to Flutter every second while a listener is active.
 *
 * Demonstrates EventChannel lifecycle: [onListen] starts the timer,
 * [onCancel] stops it.
 */
class NativeTickerChannel(
    messenger: BinaryMessenger,
) : EventChannel.StreamHandler {
    private val channel =
        EventChannel(messenger, "examples.flutter_native_calls/ticker")

    private val mainHandler = Handler(Looper.getMainLooper())
    private var events: EventChannel.EventSink? = null
    private var tick = 0

    private val tickerRunnable =
        object : Runnable {
            override fun run() {
                val sink = events ?: return
                tick += 1
                sink.success(
                    mapOf(
                        "tick" to tick,
                        "timestampMs" to System.currentTimeMillis(),
                    ),
                )
                mainHandler.postDelayed(this, 1_000L)
            }
        }

    fun register() {
        channel.setStreamHandler(this)
    }

    fun unregister() {
        stopTicker()
        channel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
        tick = 0
        // Emit the first tick immediately, then every second.
        mainHandler.post(tickerRunnable)
    }

    override fun onCancel(arguments: Any?) {
        stopTicker()
    }

    private fun stopTicker() {
        mainHandler.removeCallbacks(tickerRunnable)
        events = null
        tick = 0
    }
}

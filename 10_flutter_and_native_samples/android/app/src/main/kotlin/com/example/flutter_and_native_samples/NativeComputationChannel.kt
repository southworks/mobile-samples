package com.example.flutter_and_native_samples

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.random.Random

/**
 * Runs a delayed native task on a background thread and returns the
 * result to Flutter asynchronously on the main thread.
 */
class NativeComputationChannel(
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel =
        MethodChannel(messenger, "examples.flutter_native_calls/async_task")

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun register() {
        channel.setMethodCallHandler(this)
    }

    fun unregister() {
        channel.setMethodCallHandler(null)
        executor.shutdownNow()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "runDelayedTask" -> runDelayedTask(result)
            else -> result.notImplemented()
        }
    }

    private fun runDelayedTask(result: MethodChannel.Result) {
        // Native work: sleep a random number of seconds, then reply on the main thread.
        executor.execute {
            val delaySeconds = Random.nextInt(1, 11)
            val start = System.nanoTime()
            try {
                Thread.sleep(delaySeconds * 1_000L)
            } catch (_: InterruptedException) {
                mainHandler.post {
                    result.error(
                        "unavailable",
                        "Native delayed task was interrupted.",
                        null,
                    )
                }
                return@execute
            }
            val durationMs = ((System.nanoTime() - start) / 1_000_000).toInt()

            mainHandler.post {
                result.success(
                    mapOf(
                        "result" to "Native delay completed after $delaySeconds s",
                        "durationMs" to durationMs,
                    ),
                )
            }
        }
    }
}

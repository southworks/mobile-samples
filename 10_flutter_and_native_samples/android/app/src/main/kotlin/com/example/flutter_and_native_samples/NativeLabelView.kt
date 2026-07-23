package com.example.flutter_and_native_samples

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView
import java.net.URL
import java.util.concurrent.Executors

/**
 * A view built entirely with Android widgets (Kotlin).
 *
 * Flutter embeds it, but every pixel here is drawn by the Android UI toolkit.
 */
class NativeLabelView(context: Context) : PlatformView {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val imageLoader = Executors.newSingleThreadExecutor()

    private val avatarView =
        ImageView(context).apply {
            val size = (96 * context.resources.displayMetrics.density).toInt()
            layoutParams = LinearLayout.LayoutParams(size, size)
            scaleType = ImageView.ScaleType.CENTER_CROP
            setBackgroundColor(Color.parseColor("#C8E6C9"))
            contentDescription = "Fake profile photo"
            post {
                outlineProvider =
                    object : android.view.ViewOutlineProvider() {
                        override fun getOutline(
                            view: View,
                            outline: android.graphics.Outline,
                        ) {
                            outline.setOval(0, 0, view.width, view.height)
                        }
                    }
                clipToOutline = true
            }
        }

    private val container: LinearLayout =
        LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#E8F5E9"))
            setPadding(48, 48, 48, 48)

            addView(
                TextView(context).apply {
                    text = "Rendered by Android"
                    textSize = 22f
                    setTextColor(Color.parseColor("#1B5E20"))
                },
            )
            addView(
                TextView(context).apply {
                    text = "android.widget views built in Kotlin"
                    textSize = 14f
                    setPadding(0, 16, 0, 24)
                },
            )
            addView(avatarView)
            addView(
                TextView(context).apply {
                    text = "Alex Rivera"
                    textSize = 16f
                    setTextColor(Color.parseColor("#1B5E20"))
                    setPadding(0, 16, 0, 0)
                },
            )
            addView(
                TextView(context).apply {
                    text = "Native profile card"
                    textSize = 13f
                    setTextColor(Color.parseColor("#388E3C"))
                },
            )
        }

    init {
        loadProfileImage()
    }

    private fun loadProfileImage() {
        imageLoader.execute {
            try {
                val connection = URL("https://picsum.photos/120").openConnection()
                connection.connectTimeout = 8_000
                connection.readTimeout = 8_000
                connection.getInputStream().use { stream ->
                    val bitmap = BitmapFactory.decodeStream(stream)
                    if (bitmap != null) {
                        mainHandler.post { avatarView.setImageBitmap(bitmap) }
                    }
                }
            } catch (_: Exception) {
                // Keep the placeholder background if the image cannot be loaded.
            }
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        imageLoader.shutdownNow()
    }
}

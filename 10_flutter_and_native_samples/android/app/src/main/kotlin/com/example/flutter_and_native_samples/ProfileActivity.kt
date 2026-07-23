package com.example.flutter_and_native_samples

import android.app.Activity
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Outline
import android.graphics.Typeface
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.ViewOutlineProvider
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import java.net.URL
import java.util.concurrent.Executors

/**
 * Full-screen Android Activity that shows a native profile.
 *
 * Opened by Flutter through a MethodChannel — not embedded as a PlatformView.
 */
class ProfileActivity : Activity() {
    private val imageLoader = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val density = resources.displayMetrics.density
        fun dp(value: Int): Int = (value * density).toInt()

        val avatar =
            ImageView(this).apply {
                layoutParams =
                    LinearLayout.LayoutParams(dp(120), dp(120)).apply {
                        topMargin = dp(24)
                        gravity = Gravity.CENTER_HORIZONTAL
                    }
                scaleType = ImageView.ScaleType.CENTER_CROP
                setBackgroundColor(Color.parseColor("#B2DFDB"))
                contentDescription = "Profile photo"
                post {
                    outlineProvider =
                        object : ViewOutlineProvider() {
                            override fun getOutline(view: View, outline: Outline) {
                                outline.setOval(0, 0, view.width, view.height)
                            }
                        }
                    clipToOutline = true
                }
            }

        val closeButton =
            TextView(this).apply {
                text = "Close"
                setTextColor(Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                gravity = Gravity.CENTER
                setBackgroundColor(Color.parseColor("#0F766E"))
                setPadding(dp(28), dp(14), dp(28), dp(14))
                layoutParams =
                    LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                    ).apply {
                        topMargin = dp(32)
                        gravity = Gravity.CENTER_HORIZONTAL
                    }
                setOnClickListener { finish() }
            }

        val content =
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_HORIZONTAL
                setPadding(dp(24), dp(32), dp(24), dp(32))
                setBackgroundColor(Color.parseColor("#F0FDFA"))

                addView(
                    TextView(this@ProfileActivity).apply {
                        text = "Native Android profile"
                        setTextColor(Color.parseColor("#0F766E"))
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                        setTypeface(typeface, Typeface.BOLD)
                        gravity = Gravity.CENTER
                    },
                )
                addView(avatar)
                addView(
                    TextView(this@ProfileActivity).apply {
                        text = "Alex Rivera"
                        setTextColor(Color.parseColor("#134E4A"))
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
                        setTypeface(typeface, Typeface.BOLD)
                        gravity = Gravity.CENTER
                        setPadding(0, dp(20), 0, 0)
                    },
                )
                addView(
                    TextView(this@ProfileActivity).apply {
                        text = "Age: 29"
                        setTextColor(Color.parseColor("#0F766E"))
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                        gravity = Gravity.CENTER
                        setPadding(0, dp(8), 0, 0)
                    },
                )
                addView(
                    TextView(this@ProfileActivity).apply {
                        text =
                            "Mobile engineer who builds Flutter samples that call " +
                                "Kotlin Activities and Swift view controllers."
                        setTextColor(Color.parseColor("#115E59"))
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                        gravity = Gravity.CENTER
                        setPadding(0, dp(16), 0, 0)
                    },
                )
                addView(closeButton)
            }

        setContentView(
            ScrollView(this).apply {
                addView(content)
            },
        )

        loadProfileImage(avatar)
    }

    private fun loadProfileImage(avatar: ImageView) {
        imageLoader.execute {
            try {
                val connection = URL("https://picsum.photos/240").openConnection()
                connection.connectTimeout = 8_000
                connection.readTimeout = 8_000
                connection.getInputStream().use { stream ->
                    val bitmap = BitmapFactory.decodeStream(stream)
                    if (bitmap != null) {
                        mainHandler.post { avatar.setImageBitmap(bitmap) }
                    }
                }
            } catch (_: Exception) {
                // Keep the placeholder background if the image cannot be loaded.
            }
        }
    }

    override fun onDestroy() {
        imageLoader.shutdownNow()
        super.onDestroy()
    }
}

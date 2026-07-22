package com.ixeken.gakuu.engines

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.random.Random

class AuraWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private val paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
        // Blend mode to simulate screen blending for glowing overlay mesh
        xfermode = PorterDuffXfermode(PorterDuff.Mode.ADD)
    }

    private val blobs = mutableListOf<AuraBlob>()
    private val numBlobs = 6

    private var touchX: Float? = null
    private var touchY: Float? = null

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        initBlobs(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initBlobs(width: Int, height: Int) {
        blobs.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920

        val colors = listOf(
            Color.parseColor("#FFFF007F"), // Vivid hot pink
            Color.parseColor("#FF7F00FF"), // Violet purple
            Color.parseColor("#FF00F0FF"), // Neon cyan
            Color.parseColor("#FFFFD700")  // Vibrant gold
        )

        repeat(numBlobs) {
            blobs.add(AuraBlob(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                vx = (Random.nextFloat() - 0.5f) * 1.5f,
                vy = (Random.nextFloat() - 0.5f) * 1.5f,
                radius = Random.nextFloat() * 250f + 300f, // Massive blobs
                pulsePhase = Random.nextFloat() * 10f,
                color = colors[Random.nextInt(colors.size)]
            ))
        }
    }

    override fun onUpdatePhysics() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f

        val tx = touchX
        val ty = touchY

        for (b in blobs) {
            if (tx != null && ty != null) {
                // Attract toward touch smoothly
                val dx = tx - b.x
                val dy = ty - b.y
                val dist = sqrt((dx * dx + dy * dy).toDouble()).toFloat()
                if (dist > 1f) {
                    b.vx += (dx / dist) * 0.15f
                    b.vy += (dy / dist) * 0.15f
                }
            } else {
                // Add random wandering forces
                b.vx += (Random.nextFloat() - 0.5f) * 0.08f
                b.vy += (Random.nextFloat() - 0.5f) * 0.08f
            }

            // Cap speeds
            b.vx = b.vx.coerceIn(-3f, 3f)
            b.vy = b.vy.coerceIn(-3f, 3f)

            b.x += b.vx
            b.y += b.vy

            // Ambient fluid resistance friction
            b.vx *= 0.98f
            b.vy *= 0.98f

            // Wraparound screen
            if (b.x < -b.radius * 0.5f) b.x = w + b.radius * 0.5f
            if (b.x > w + b.radius * 0.5f) b.x = -b.radius * 0.5f
            if (b.y < -b.radius * 0.5f) b.y = h + b.radius * 0.5f
            if (b.y > h + b.radius * 0.5f) b.y = -b.radius * 0.5f

            b.pulsePhase += 0.01f
        }
    }

    override fun onDraw(canvas: Canvas) {
        // Holographic deep night canvas
        canvas.drawColor(Color.parseColor("#07050E"))

        for (b in blobs) {
            val currentRadius = b.radius * (1.0f + sin(b.pulsePhase) * 0.08f)

            val argbCore = Color.argb((0.35f * 255).toInt(), Color.red(b.color), Color.green(b.color), Color.blue(b.color))
            val argbMid = Color.argb((0.15f * 255).toInt(), Color.red(b.color), Color.green(b.color), Color.blue(b.color))

            val gradient = RadialGradient(
                b.x, b.y, currentRadius,
                intArrayOf(argbCore, argbMid, Color.TRANSPARENT),
                floatArrayOf(0.0f, 0.5f, 1.0f),
                Shader.TileMode.CLAMP
            )
            paint.shader = gradient

            canvas.drawCircle(b.x, b.y, currentRadius, paint)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                touchX = event.x
                touchY = event.y
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                touchX = null
                touchY = null
            }
        }
    }

    private class AuraBlob(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        var pulsePhase: Float,
        val color: Int
    )
}

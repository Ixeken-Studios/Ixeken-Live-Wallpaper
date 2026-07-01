package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.MotionEvent
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.random.Random

class PachinkoWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private class Ball(var x: Float, var y: Float, var vx: Float, var vy: Float, val color: Int)
    private class Pin(val x: Float, val y: Float, val radius: Float)
    private class Spark(var x: Float, var y: Float, var vx: Float, var vy: Float, var alpha: Float, val color: Int)

    private val balls = mutableListOf<Ball>()
    private val pins = mutableListOf<Pin>()
    private val sparks = mutableListOf<Spark>()

    private val pinPaint = Paint().apply {
        color = Color.parseColor("#475569")
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val pinGlow = Paint().apply {
        color = Color.argb(76, 56, 189, 248)
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val ballPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val ballGlow = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val sparkPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    private var initialized = false
    private val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator

    override val frameIntervalMs = 16L // ~60 FPS

    private fun initPachinko(w: Float, h: Float) {
        pins.clear()
        // Denser alternating layout: 9 rows
        val rows = 9
        for (row in 0 until rows) {
            val py = h * 0.18f + row * (h * 0.075f)
            val pinsInRow = 6 + (row % 2)
            val spacing = w / (pinsInRow + 1)
            for (col in 0 until pinsInRow) {
                pins.add(Pin(spacing * (col + 1), py, 11f))
            }
        }
        initialized = true
    }

    override fun onUpdatePhysics() {
        val frame = currentHolder?.surfaceFrame ?: return
        val w = frame.width().toFloat()
        val h = frame.height().toFloat()

        if (!initialized) initPachinko(w, h)

        if (Random.nextFloat() < 0.035f && balls.size < 10) {
            val colors = intArrayOf(
                Color.parseColor("#38BDF8"),
                Color.parseColor("#F43F5E"),
                Color.parseColor("#10B981")
            )
            balls.add(
                Ball(
                    x = w * 0.25f + Random.nextFloat() * (w * 0.5f),
                    y = 20f,
                    vx = (Random.nextFloat() - 0.5f) * 2.5f,
                    vy = 1.5f,
                    colors[Random.nextInt(colors.size)]
                )
            )
        }

        // 1. Update balls
        for (i in balls.indices.reversed()) {
            val b = balls[i]
            b.vy += 0.24f
            b.x += b.vx
            b.y += b.vy

            for (pin in pins) {
                val dx = b.x - pin.x
                val dy = b.y - pin.y
                val distSq = dx * dx + dy * dy
                val radiusSum = pin.radius + 15f // Pin (11f) + Ball (15f)
                if (distSq < radiusSum * radiusSum) {
                    val dist = sqrt(distSq)
                    b.x = pin.x + (dx / dist) * radiusSum
                    b.y = pin.y + (dy / dist) * radiusSum

                    val nx = dx / dist
                    val ny = dy / dist
                    val dot = b.vx * nx + b.vy * ny
                    b.vx = (b.vx - 2f * dot * nx) * 0.62f
                    b.vy = (b.vy - 2f * dot * ny) * 0.62f
                    b.vx += (Random.nextFloat() - 0.5f) * 1.5f

                    for (k in 0 until 4) {
                        val angle = Random.nextFloat() * 2f * Math.PI.toFloat()
                        val speed = Random.nextFloat() * 3f + 1f
                        sparks.add(
                            Spark(
                                x = pin.x + nx * radiusSum,
                                y = pin.y + ny * radiusSum,
                                vx = cos(angle) * speed,
                                vy = sin(angle) * speed - 1f,
                                alpha = 1.0f,
                                color = b.color
                            )
                        )
                    }

                    triggerVibration()
                }
            }

            if (b.x < 15f) { b.x = 15f; b.vx *= -0.7f }
            if (b.x > w - 15f) { b.x = w - 15f; b.vx *= -0.7f }

            if (b.y > h + 50f) {
                balls.removeAt(i)
            }
        }

        // 2. Update sparks
        for (i in sparks.indices.reversed()) {
            val s = sparks[i]
            s.x += s.vx
            s.y += s.vy
            s.vy += 0.08f
            s.alpha -= 0.05f
            if (s.alpha <= 0f) {
                sparks.removeAt(i)
            }
        }
    }

    private fun triggerVibration() {
        try {
            if (android.os.Build.VERSION.SDK_INT >= 26) {
                vibrator?.vibrate(VibrationEffect.createOneShot(8, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                vibrator?.vibrate(8)
            }
        } catch (e: Exception) {}
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        if (!initialized) initPachinko(w, h)

        canvas.drawColor(Color.parseColor("#030308"))

        // Draw pins
        for (pin in pins) {
            canvas.drawCircle(pin.x, pin.y, pin.radius + 6f, pinGlow)
            canvas.drawCircle(pin.x, pin.y, pin.radius, pinPaint)
        }

        // Draw sparks
        sparkPaint.shader = null
        for (s in sparks) {
            sparkPaint.color = s.color
            sparkPaint.alpha = (s.alpha * 255).toInt().coerceIn(0, 255)
            canvas.drawCircle(s.x, s.y, 4f, sparkPaint)
        }

        // Draw balls
        for (b in balls) {
            ballGlow.color = b.color
            ballGlow.alpha = 102
            canvas.drawCircle(b.x, b.y, 28f, ballGlow)

            ballPaint.color = b.color
            ballPaint.alpha = 255
            canvas.drawCircle(b.x, b.y, 15f, ballPaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_DOWN) {
            val colors = intArrayOf(
                Color.parseColor("#38BDF8"),
                Color.parseColor("#F43F5E"),
                Color.parseColor("#10B981")
            )
            balls.add(
                Ball(
                    x = event.x,
                    y = event.y,
                    vx = (Random.nextFloat() - 0.5f) * 4f,
                    vy = -4f,
                    colors[Random.nextInt(colors.size)]
                )
            )
        }
    }
}

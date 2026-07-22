package com.ixeken.gakuu.engines

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.sin
import kotlin.random.Random

class BokehWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private val paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
    }
    
    private val lights = mutableListOf<BokehLight>()
    private val numLights = 25

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        initLights(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initLights(width: Int, height: Int) {
        lights.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920

        val colors = listOf(
            Color.parseColor("#FFFFB347"), // Soft amber orange
            Color.parseColor("#FFB39DDB"), // Lavender violet
            Color.parseColor("#FFFFD54F"), // Pale golden yellow
            Color.parseColor("#FF4DD0E1"), // Cyan/Teal
            Color.parseColor("#FFF48FB1")  // Warm rose pink
        )

        repeat(numLights) {
            lights.add(BokehLight(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                vx = (Random.nextFloat() - 0.5f) * 0.8f,
                vy = (Random.nextFloat() - 0.5f) * 0.8f,
                radius = Random.nextFloat() * 140f + 90f,
                alpha = Random.nextFloat() * 0.22f + 0.12f,
                pulseTime = Random.nextFloat() * 10f,
                pulseSpeed = Random.nextFloat() * 0.03f + 0.015f,
                color = colors[Random.nextInt(colors.size)]
            ))
        }
    }

    override fun onUpdatePhysics() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f

        for (b in lights) {
            b.x += b.vx
            b.y += b.vy

            // Bounce off boundaries with safety margin
            if (b.x < -b.radius) {
                b.x = w + b.radius
            } else if (b.x > w + b.radius) {
                b.x = -b.radius
            }

            if (b.y < -b.radius) {
                b.y = h + b.radius
            } else if (b.y > h + b.radius) {
                b.y = -b.radius
            }

            b.pulseTime += b.pulseSpeed
        }
    }

    override fun onDraw(canvas: Canvas) {
        // Deep purple-black ambient color
        canvas.drawColor(Color.parseColor("#0A0915"))

        for (b in lights) {
            val pulse = sin(b.pulseTime) * 0.2f + 0.8f
            val currentRadius = b.radius * pulse

            // Set up radial gradient shader
            val argbColorCore = Color.argb((b.alpha * 255 * 0.7f).toInt().coerceIn(0, 255), Color.red(b.color), Color.green(b.color), Color.blue(b.color))
            val argbColorMid = Color.argb((b.alpha * 255 * 0.35f).toInt().coerceIn(0, 255), Color.red(b.color), Color.green(b.color), Color.blue(b.color))
            
            val gradient = RadialGradient(
                b.x, b.y, currentRadius,
                intArrayOf(argbColorCore, argbColorMid, Color.TRANSPARENT),
                floatArrayOf(0.0f, 0.4f, 1.0f),
                Shader.TileMode.CLAMP
            )
            paint.shader = gradient

            canvas.drawCircle(b.x, b.y, currentRadius, paint)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_DOWN || event.action == MotionEvent.ACTION_MOVE) {
            // Push lights away slightly on touch
            val tx = event.x
            val ty = event.y
            for (b in lights) {
                val dx = b.x - tx
                val dy = b.y - ty
                val dist = Math.sqrt((dx * dx + dy * dy).toDouble()).toFloat()
                if (dist < 400f && dist > 1f) {
                    val force = (400f - dist) / 400f * 3f
                    b.vx += (dx / dist) * force
                    b.vy += (dy / dist) * force
                }
            }
        }
    }

    private class BokehLight(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        val alpha: Float,
        var pulseTime: Float,
        val pulseSpeed: Float,
        val color: Int
    )
}

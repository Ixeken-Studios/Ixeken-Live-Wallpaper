package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import kotlin.math.atan2
import kotlin.math.sqrt
import kotlin.random.Random

class BoidsWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private class Boid(var x: Float, var y: Float, var vx: Float, var vy: Float) {
        val history = mutableListOf<PointF>()
    }

    private val boids = mutableListOf<Boid>()
    private val paint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val particlePaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private var initialized = false
    private var touchX: Float? = null
    private var touchY: Float? = null

    override val frameIntervalMs = 16L // ~60 FPS

    private fun initBoids(w: Float, h: Float) {
        boids.clear()
        // Abundant population: 55 boids
        for (i in 0 until 55) {
            val rx = Random.nextFloat() * w
            val ry = Random.nextFloat() * h
            val rvx = (Random.nextFloat() - 0.5f) * 10f
            val rvy = (Random.nextFloat() - 0.5f) * 10f
            boids.add(Boid(rx, ry, rvx, rvy))
        }
        initialized = true
    }

    override fun onUpdatePhysics() {
        val frame = currentHolder?.surfaceFrame ?: return
        val w = frame.width().toFloat()
        val h = frame.height().toFloat()

        if (!initialized) initBoids(w, h)

        val tx = touchX
        val ty = touchY

        for (b in boids) {
            b.history.add(PointF(b.x, b.y))
            if (b.history.size > 8) b.history.removeAt(0)

            var avgX = 0f
            var avgY = 0f
            var avgVx = 0f
            var avgVy = 0f
            var count = 0

            for (other in boids) {
                if (other !== b) {
                    val dx = b.x - other.x
                    val dy = b.y - other.y
                    val dist = sqrt(dx * dx + dy * dy)
                    if (dist < 100f) {
                        avgX += other.x
                        avgY += other.y
                        avgVx += other.vx
                        avgVy += other.vy
                        count++
                    }
                }
            }

            if (count > 0) {
                avgX /= count
                avgY /= count
                avgVx /= count
                avgVy /= count

                // Loose forces for more sporadic movement
                b.vx += (avgX - b.x) * 0.002f
                b.vy += (avgY - b.y) * 0.002f
                b.vx += (avgVx - b.vx) * 0.015f
                b.vy += (avgVy - b.vy) * 0.015f
            }

            // Sporadic random wander force
            b.vx += (Random.nextFloat() - 0.5f) * 0.9f
            b.vy += (Random.nextFloat() - 0.5f) * 0.9f

            if (tx != null && ty != null) {
                val dx = tx - b.x
                val dy = ty - b.y
                val dist = sqrt(dx * dx + dy * dy)
                if (dist > 1f && dist < 450f) {
                    b.vx += (dx / dist) * 0.8f
                    b.vy += (dy / dist) * 0.8f
                }
            }

            if (b.x < 50f) b.vx += 0.6f
            if (b.x > w - 50f) b.vx -= 0.6f
            if (b.y < 50f) b.vy += 0.6f
            if (b.y > h - 50f) b.vy -= 0.6f

            val speed = sqrt(b.vx * b.vx + b.vy * b.vy)
            if (speed > 12f) { // Increased max speed
                b.vx = (b.vx / speed) * 12f
                b.vy = (b.vy / speed) * 12f
            } else if (speed < 3f) {
                b.vx = (b.vx / speed) * 4f
                b.vy = (b.vy / speed) * 4f
            }

            b.x += b.vx
            b.y += b.vy
        }
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        if (!initialized) initBoids(w, h)

        canvas.drawColor(Color.parseColor("#04060E"))

        val path = Path()

        // Draw trails
        for (b in boids) {
            for (i in b.history.indices) {
                val pos = b.history[i]
                val factor = i.toFloat() / b.history.size
                particlePaint.color = Color.parseColor("#00FFCC")
                particlePaint.alpha = (factor * 70).toInt().coerceIn(0, 255)
                canvas.drawCircle(pos.x, pos.y, factor * 8f, particlePaint)
            }
        }

        // Draw Boids
        for (b in boids) {
            val angle = Math.toDegrees(atan2(b.vy.toDouble(), b.vx.toDouble()).toDouble()).toFloat()
            val speed = sqrt(b.vx * b.vx + b.vy * b.vy)

            canvas.save()
            canvas.translate(b.x, b.y)
            canvas.rotate(angle)

            path.reset()
            path.moveTo(14f, 0f)
            path.lineTo(-10f, -8f)
            path.lineTo(-6f, 0f)
            path.lineTo(-10f, 8f)
            path.close()

            val factor = (speed / 12f).coerceIn(0f, 1f)
            val red = (99 * (1f - factor) + 0 * factor).toInt()
            val green = (102 * (1f - factor) + 255 * factor).toInt()
            val blue = (241 * (1f - factor) + 204 * factor).toInt()

            paint.color = Color.rgb(red, green, blue)
            paint.alpha = 80
            canvas.drawCircle(0f, 0f, 15f, paint)

            paint.alpha = 255
            canvas.drawPath(path, paint)
            canvas.restore()
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
}

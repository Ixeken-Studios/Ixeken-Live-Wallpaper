package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.MotionEvent
import kotlin.math.sqrt
import kotlin.random.Random

class VoronoiWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private class VorPoint(var x: Float, var y: Float, var vx: Float, var vy: Float, val color: Int)

    private val points = mutableListOf<VorPoint>()
    private val linePaint = Paint().apply {
        strokeWidth = 2f
        style = Paint.Style.STROKE
        isAntiAlias = true
    }
    private val nodePaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val corePaint = Paint().apply {
        color = Color.WHITE
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private var initialized = false

    override val frameIntervalMs = 16L // ~60 FPS

    private fun initPoints(w: Float, h: Float) {
        points.clear()
        val colors = intArrayOf(
            Color.parseColor("#6366F1"),
            Color.parseColor("#EC4899"),
            Color.parseColor("#06B6D4"),
            Color.parseColor("#8B5CF6")
        )
        // Denser constellation with 18 stars
        for (i in 0 until 18) {
            val rx = Random.nextFloat() * w
            val ry = Random.nextFloat() * h
            val rvx = (Random.nextFloat() - 0.5f) * 3f
            val rvy = (Random.nextFloat() - 0.5f) * 3f
            points.add(VorPoint(rx, ry, rvx, rvy, colors[i % colors.size]))
        }
        initialized = true
    }

    override fun onUpdatePhysics() {
        val frame = currentHolder?.surfaceFrame ?: return
        val w = frame.width().toFloat()
        val h = frame.height().toFloat()

        if (!initialized) initPoints(w, h)

        for (p in points) {
            p.x += p.vx
            p.y += p.vy

            if (p.x < 0 || p.x > w) p.vx *= -1f
            if (p.y < 0 || p.y > h) p.vy *= -1f
        }
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        if (!initialized) initPoints(w, h)

        // Deep space clean black background
        canvas.drawColor(Color.parseColor("#030206"))

        // Draw connecting lines with opacity fade
        for (i in points.indices) {
            for (j in (i + 1) until points.size) {
                val dx = points[i].x - points[j].x
                val dy = points[i].y - points[j].y
                val d = sqrt(dx * dx + dy * dy)
                if (d < 300f) {
                    val factor = (1f - (d / 300f)).coerceIn(0f, 1f)
                    linePaint.color = Color.WHITE
                    linePaint.alpha = (factor * 60).toInt().coerceIn(0, 255)
                    canvas.drawLine(points[i].x, points[i].y, points[j].x, points[j].y, linePaint)
                }
            }
        }

        // Draw glowing nodes (stars)
        for (p in points) {
            // Star Outer Glow
            nodePaint.color = Color.WHITE
            nodePaint.alpha = 38
            canvas.drawCircle(p.x, p.y, 22f, nodePaint)

            nodePaint.color = p.color
            nodePaint.alpha = 90
            canvas.drawCircle(p.x, p.y, 11f, nodePaint)

            // Bright White Core
            canvas.drawCircle(p.x, p.y, 4f, corePaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_DOWN || event.action == MotionEvent.ACTION_MOVE) {
            val tx = event.x
            val ty = event.y
            for (p in points) {
                val dx = p.x - tx
                val dy = p.y - ty
                val dist = sqrt(dx * dx + dy * dy)
                if (dist < 250f && dist > 1f) {
                    p.vx = (dx / dist) * 4f
                    p.vy = (dy / dist) * 4f
                }
            }
        }
    }
}

package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import kotlin.math.cos
import kotlin.math.sin

class WaveformsWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private var time = 0f
    private val waveColors = intArrayOf(
        Color.parseColor("#EC4899"), // Pink
        Color.parseColor("#06B6D4"), // Cyan
        Color.parseColor("#8B5CF6")  // Purple
    )
    private val paint = Paint().apply {
        style = Paint.Style.STROKE
        strokeWidth = 6f
        isAntiAlias = true
    }
    private val gridPaint = Paint().apply {
        color = Color.parseColor("#1E1435")
        alpha = 40
        strokeWidth = 2f
        style = Paint.Style.STROKE
    }
    private val particlePaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    override val frameIntervalMs = 16L // ~60 FPS

    override fun onUpdatePhysics() {
        time += 0.04f
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        canvas.drawColor(Color.parseColor("#030107"))

        // Draw retro grid
        val step = 90f
        var x = 0f
        while (x < w) {
            canvas.drawLine(x, 0f, x, h, gridPaint)
            x += step
        }
        var y = 0f
        while (y < h) {
            canvas.drawLine(0f, y, w, y, gridPaint)
            y += step
        }

        val path = Path()

        for (i in waveColors.indices) {
            path.reset()
            
            // Linear gradient for wave stroke
            val lineGrad = LinearGradient(
                0f, 0f, w, 0f,
                intArrayOf(waveColors[i], waveColors[(i + 1) % 3], waveColors[i]),
                null, Shader.TileMode.CLAMP
            )
            paint.shader = lineGrad

            val waveOffset = i * Math.PI.toFloat() / 3f
            val speedFactor = 1.0f + (i * 0.15f)
            val baseHeight = h / 2f

            var first = true
            var wx = 0f
            while (wx < w) {
                val angle = (wx / w) * 3.5f * Math.PI.toFloat() + (time * speedFactor) + waveOffset
                val wy = baseHeight + 
                        sin(angle) * 150f * sin(time * 0.4f + waveOffset) + 
                        cos(angle * 1.3f) * 50f

                if (first) {
                    path.moveTo(wx, wy)
                    first = false
                } else {
                    path.lineTo(wx, wy)
                }
                wx += 6f
            }
            canvas.drawPath(path, paint)

            // Draw sparkles along wave
            for (pIdx in 0 until 4) {
                val progress = ((time * 0.05f + pIdx / 4f) % 1f)
                val px = progress * w
                val angle = (px / w) * 3.5f * Math.PI.toFloat() + (time * speedFactor) + waveOffset
                val py = baseHeight + 
                        sin(angle) * 150f * sin(time * 0.4f + waveOffset) + 
                        cos(angle * 1.3f) * 50f

                particlePaint.shader = null
                particlePaint.color = waveColors[i]
                particlePaint.alpha = 90
                canvas.drawCircle(px, py, 14f, particlePaint)
                particlePaint.color = Color.WHITE
                particlePaint.alpha = 255
                canvas.drawCircle(px, py, 5f, particlePaint)
            }
        }
    }
}

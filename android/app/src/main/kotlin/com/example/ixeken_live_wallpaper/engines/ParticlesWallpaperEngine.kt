package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class ParticlesWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val particles = mutableListOf<Particle>()
    private val numParticles = 40
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                drawFrame()
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        initParticles(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initParticles(width: Int, height: Int) {
        particles.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920
        repeat(numParticles) {
            particles.add(Particle(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                vx = (Random.nextFloat() - 0.5f) * 5f,
                vy = (Random.nextFloat() - 0.5f) * 5f,
                radius = Random.nextFloat() * 8f + 2f,
                color = Color.argb(Random.nextInt(50, 150), 100, 150, 255)
            ))
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) {
            Choreographer.getInstance().postFrameCallback(frameCallback)
        } else {
            Choreographer.getInstance().removeFrameCallback(frameCallback)
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initParticles(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        // Fondo oscuro
        canvas.drawColor(Color.parseColor("#0F0F1B"))
        
        val width = canvas.width.toFloat()
        val height = canvas.height.toFloat()

        for (p in particles) {
            p.x += p.vx
            p.y += p.vy

            // Rebote
            if (p.x < 0 || p.x > width) p.vx *= -1
            if (p.y < 0 || p.y > height) p.vy *= -1

            paint.color = p.color
            canvas.drawCircle(p.x, p.y, p.radius, paint)
        }
    }

    private fun drawFrame() {
        val holder = currentHolder ?: return
        val canvas = if (android.os.Build.VERSION.SDK_INT >= 26) holder.lockHardwareCanvas() else holder.lockCanvas()
        if (canvas == null) return
        try {
            onDraw(canvas)
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
    }

    override fun onDestroy() {
        isVisible = false
        Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    data class Particle(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        val color: Int
    )
}

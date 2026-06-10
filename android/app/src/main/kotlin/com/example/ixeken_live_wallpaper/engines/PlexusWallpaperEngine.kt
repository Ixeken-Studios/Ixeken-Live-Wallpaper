package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class PlexusWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val particles = mutableListOf<Node>()
    private val numNodes = 50
    private val connectionDistance = 250f
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    
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
        initNodes(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initNodes(width: Int, height: Int) {
        particles.clear()
        repeat(numNodes) {
            particles.add(Node(
                x = Random.nextFloat() * width,
                y = Random.nextFloat() * height,
                vx = (Random.nextFloat() - 0.5f) * 2f,
                vy = (Random.nextFloat() - 0.5f) * 2f
            ))
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) Choreographer.getInstance().postFrameCallback(frameCallback)
        else Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initNodes(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#050A10"))
        
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        // Actualizar posiciones
        for (n in particles) {
            n.x += n.vx
            n.y += n.vy
            if (n.x < 0 || n.x > w) n.vx *= -1
            if (n.y < 0 || n.y > h) n.vy *= -1
        }

        // Dibujar conexiones
        for (i in 0 until particles.size) {
            for (j in i + 1 until particles.size) {
                val p1 = particles[i]
                val p2 = particles[j]
                val dx = p1.x - p2.x
                val dy = p1.y - p2.y
                val distSq = dx * dx + dy * dy
                
                if (distSq < connectionDistance * connectionDistance) {
                    val dist = kotlin.math.sqrt(distSq)
                    val alpha = ((1.0 - dist / connectionDistance) * 150).toInt()
                    paint.color = Color.CYAN
                    paint.alpha = alpha
                    paint.strokeWidth = 2f
                    canvas.drawLine(p1.x, p1.y, p2.x, p2.y, paint)
                }
            }
        }

        // Dibujar nodos
        paint.color = Color.WHITE
        paint.alpha = 200
        for (n in particles) {
            canvas.drawCircle(n.x, n.y, 4f, paint)
        }

        val isDim = prefs.getBoolean("isDimEnabled", false)
        if (isDim) {
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), android.graphics.PorterDuff.Mode.SRC_OVER)
        }
    }

    private fun drawFrame() {
        val holder = currentHolder ?: return
        if (!holder.surface.isValid) return
        val canvas = try {
            if (android.os.Build.VERSION.SDK_INT >= 26) holder.lockHardwareCanvas() else holder.lockCanvas()
        } catch (e: Exception) {
            try { holder.lockCanvas() } catch (ex: Exception) { null }
        } ?: return
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

    data class Node(var x: Float, var y: Float, var vx: Float, var vy: Float)
}

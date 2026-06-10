package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.SurfaceHolder
import kotlin.random.Random

class PlexusWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {
    
    private val paint = Paint().apply { isAntiAlias = true }
    private val particles = mutableListOf<Node>()
    private val numNodes = 50
    private val connectionDistance = 250f

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        initNodes(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initNodes(width: Int, height: Int) {
        particles.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920
        repeat(numNodes) {
            particles.add(Node(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                vx = (Random.nextFloat() - 0.5f) * 2f,
                vy = (Random.nextFloat() - 0.5f) * 2f
            ))
        }
    }

    override fun onUpdatePhysics() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f

        // Actualizar posiciones
        for (n in particles) {
            n.x += n.vx
            n.y += n.vy
            if (n.x < 0 || n.x > w) n.vx *= -1
            if (n.y < 0 || n.y > h) n.vy *= -1
        }
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#050A10"))
        
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
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        super.onSurfaceChanged(holder, format, width, height)
        initNodes(width, height)
    }

    data class Node(var x: Float, var y: Float, var vx: Float, var vy: Float)
}

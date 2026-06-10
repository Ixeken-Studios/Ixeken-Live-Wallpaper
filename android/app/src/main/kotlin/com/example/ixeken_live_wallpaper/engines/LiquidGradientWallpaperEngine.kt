package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.RadialGradient
import android.graphics.Shader
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.math.cos
import kotlin.math.sin

class LiquidGradientWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private var time = 0f
    
    private val paint = Paint().apply { isAntiAlias = true }
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                time += 0.002f // Movimiento extremadamente suave y lento
                drawFrame()
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) Choreographer.getInstance().postFrameCallback(frameCallback)
        else Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()
        val isDim = prefs.getBoolean("isDimEnabled", false)
        
        // 1. Fondo base muy oscuro (azul espacial profundo)
        canvas.drawColor(Color.parseColor("#080512"))
        
        // 2. Dibujar 4 blobs de colores líquidos en movimiento orgánico desfasado
        // Blob 1: Púrpura brillante, se mueve arriba a la izquierda
        val x1 = w * 0.35f + sin(time) * (w * 0.18f)
        val y1 = h * 0.3f + cos(time * 0.9f) * (h * 0.12f)
        drawBlob(canvas, x1, y1, w * 0.65f, Color.parseColor("#6366F1"), 0.33f) // Indigo
        
        // Blob 2: Magenta, se mueve abajo a la derecha
        val x2 = w * 0.65f + cos(time * 1.1f) * (w * 0.2f)
        val y2 = h * 0.7f + sin(time * 0.8f) * (h * 0.15f)
        drawBlob(canvas, x2, y2, w * 0.75f, Color.parseColor("#EC4899"), 0.28f) // Rose
        
        // Blob 3: Cian, se mueve en el centro / Lissajous
        val x3 = w * 0.5f + sin(time * 0.7f) * (w * 0.22f)
        val y3 = h * 0.5f + cos(time * 1.3f) * (h * 0.18f)
        drawBlob(canvas, x3, y3, w * 0.6f, Color.parseColor("#06B6D4"), 0.26f) // Cyan
        
        // Blob 4: Violeta, se mueve arriba a la derecha
        val x4 = w * 0.6f + cos(time * 0.6f) * (w * 0.25f)
        val y4 = h * 0.4f + sin(time * 0.7f) * (h * 0.2f)
        drawBlob(canvas, x4, y4, w * 0.7f, Color.parseColor("#8B5CF6"), 0.3f) // Violet

        // 3. Efecto Dim opcional para oscurecer el fondo
        if (isDim) {
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
        }
    }
    
    private fun drawBlob(canvas: Canvas, x: Float, y: Float, radius: Float, color: Int, opacity: Float) {
        val alphaColor = Color.argb(
            (opacity * 255).toInt().coerceIn(0, 255),
            Color.red(color),
            Color.green(color),
            Color.blue(color)
        )
        
        val colors = intArrayOf(alphaColor, Color.TRANSPARENT)
        val gradient = RadialGradient(x, y, radius, colors, null, Shader.TileMode.CLAMP)
        
        paint.reset()
        paint.isAntiAlias = true
        paint.shader = gradient
        
        // Dibujar círculo que contiene el gradiente radial (acelerado por hardware)
        canvas.drawCircle(x, y, radius, paint)
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
}

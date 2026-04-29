package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.math.sin

class LiquidGradientWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private var time = 0f
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                time += 0.01f
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

        // Crear un gradiente radial que se mueve
        val x = w / 2 + sin(time) * (w / 3)
        val y = h / 2 + sin(time * 0.8f) * (h / 3)
        
        val colors = intArrayOf(
            Color.parseColor("#4A148C"), // Deep Purple
            Color.parseColor("#880E4F"), // Magenta
            Color.parseColor("#01579B")  // Deep Blue
        )
        
        val gradient = RadialGradient(x, y, w, colors, null, Shader.TileMode.MIRROR)
        val paint = Paint().apply { shader = gradient }
        
        canvas.drawRect(0f, 0f, w, h, paint)
        
        // Capa de mezcla sutil
        val overlayPaint = Paint().apply {
            color = Color.BLACK
            alpha = 50
        }
        canvas.drawRect(0f, 0f, w, h, overlayPaint)
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
}

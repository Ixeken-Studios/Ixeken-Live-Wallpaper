package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.Choreographer
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.random.Random

class StarfieldWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    
    private val stars = mutableListOf<Star>()
    private val numStars = 150
    
    private var isWarping = false
    private var currentSpeed = 6f
    private val normalSpeed = 6f
    private val warpSpeed = 32f
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                updateLogic()
                drawFrame()
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        initStars(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initStars(width: Int, height: Int) {
        stars.clear()
        val w = if (width > 0) width.toFloat() else 1080f
        val h = if (height > 0) height.toFloat() else 1920f
        
        repeat(numStars) {
            stars.add(Star(
                x = (Random.nextFloat() - 0.5f) * w,
                y = (Random.nextFloat() - 0.5f) * h,
                z = Random.nextFloat() * 1000f + 10f,
                prevZ = 0f,
                color = Color.argb(
                    Random.nextInt(100, 255),
                    Random.nextInt(180, 255),
                    Random.nextInt(200, 255),
                    255
                )
            ).apply { prevZ = z })
        }
    }

    private fun updateLogic() {
        // Interpolar suavemente hacia la velocidad objetivo
        val targetSpeed = if (isWarping) warpSpeed else normalSpeed
        currentSpeed += (targetSpeed - currentSpeed) * 0.12f
        
        val holder = currentHolder ?: return
        val w = holder.surfaceFrame.width().toFloat()
        val h = holder.surfaceFrame.height().toFloat()

        for (s in stars) {
            s.prevZ = s.z
            s.z -= currentSpeed
            
            // Si la estrella se acerca demasiado o sale de la pantalla, reiniciar en la lejanía
            if (s.z <= 0f) {
                s.z = 1000f
                s.prevZ = 1000f
                s.x = (Random.nextFloat() - 0.5f) * w
                s.y = (Random.nextFloat() - 0.5f) * h
            }
        }
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()
        
        // Espacio negro profundo
        canvas.drawColor(Color.parseColor("#030206"))
        
        val cx = w / 2f
        val cy = h / 2f
        
        for (s in stars) {
            // Proyección 3D a 2D para posición actual
            val x2d = (s.x / s.z) * cx + cx
            val y2d = (s.y / s.z) * cy + cy
            
            // Proyección 3D a 2D para posición previa (rastro)
            val px2d = (s.x / s.prevZ) * cx + cx
            val py2d = (s.y / s.prevZ) * cy + cy
            
            // Omitir si está fuera de pantalla
            if (x2d < 0 || x2d > w || y2d < 0 || y2d > h) {
                // Forzar reinicio en el siguiente ciclo
                s.z = 0f
                continue
            }
            
            // Ancho del rastro según velocidad y cercanía
            val thickness = (1.0f - (s.z / 1000f)) * 4.5f + 1f
            paint.strokeWidth = thickness
            paint.color = s.color
            
            // Si vamos rápido, dibuja líneas (rastro de movimiento/warp)
            if (currentSpeed > 8f) {
                canvas.drawLine(px2d, py2d, x2d, y2d, paint)
            } else {
                // Dibujar como puntos redondos en velocidad normal
                paint.style = Paint.Style.FILL
                canvas.drawCircle(x2d, y2d, thickness * 0.7f, paint)
            }
        }

        val isDim = prefs.getBoolean("isDimEnabled", false)
        if (isDim) {
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), android.graphics.PorterDuff.Mode.SRC_OVER)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> isWarping = true
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> isWarping = false
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) {
            Choreographer.getInstance().postFrameCallback(frameCallback)
        } else {
            Choreographer.getInstance().removeFrameCallback(frameCallback)
            isWarping = false
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initStars(width, height)
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

    data class Star(
        var x: Float,
        var y: Float,
        var z: Float,
        var prevZ: Float,
        val color: Int
    )
}

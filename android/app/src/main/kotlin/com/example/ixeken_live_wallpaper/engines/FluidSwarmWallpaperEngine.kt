package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.view.Choreographer
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.random.Random

class FluidSwarmWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    private var engineHost: android.service.wallpaper.WallpaperService.Engine? = null
    
    private val particles = mutableListOf<FluidParticle>()
    private val numParticles = 140
    private var time = 0f
    
    private var isTouching = false
    private var touchX = 0f
    private var touchY = 0f
    
    private var lastLockFrameTimeMs = 0L
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                if (isLockScreen()) {
                    val now = System.currentTimeMillis()
                    if (now - lastLockFrameTimeMs >= 1000L) {
                        lastLockFrameTimeMs = now
                        time += 0.01f
                        updateLogic()
                        drawFrame()
                    }
                } else {
                    time += 0.01f
                    updateLogic()
                    drawFrame()
                }
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun setEngineHost(host: android.service.wallpaper.WallpaperService.Engine) {
        engineHost = host
    }

    private fun isLockScreen(): Boolean {
        if (android.os.Build.VERSION.SDK_INT >= 34) {
            val host = engineHost
            if (host != null) {
                val flags = try { host.getWallpaperFlags() } catch (e: Exception) { 0 }
                if (flags != 0) {
                    val isLock = (flags and android.app.WallpaperManager.FLAG_LOCK) != 0
                    val isSystem = (flags and android.app.WallpaperManager.FLAG_SYSTEM) != 0
                    if (isLock && !isSystem) {
                        return true
                    }
                }
            }
        }
        val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as? android.app.KeyguardManager
        return keyguardManager?.isKeyguardLocked == true
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        initParticles(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initParticles(width: Int, height: Int) {
        particles.clear()
        val w = if (width > 0) width.toFloat() else 1080f
        val h = if (height > 0) height.toFloat() else 1920f
        
        val colorPalette = intArrayOf(
            Color.parseColor("#06B6D4"), // Cyan
            Color.parseColor("#3B82F6"), // Blue
            Color.parseColor("#6366F1"), // Indigo
            Color.parseColor("#8B5CF6"), // Violet
            Color.parseColor("#EC4899")  // Pink
        )
        
        repeat(numParticles) {
            particles.add(FluidParticle(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                px = 0f,
                py = 0f,
                vx = (Random.nextFloat() - 0.5f) * 4f,
                vy = (Random.nextFloat() - 0.5f) * 4f,
                radius = Random.nextFloat() * 4f + 2f,
                color = colorPalette[Random.nextInt(colorPalette.size)]
            ).apply { px = x; py = y })
        }
    }

    private fun updateLogic() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f
        
        for (p in particles) {
            p.px = p.x
            p.py = p.y
            
            // Fricción suave del fluido (amortiguación)
            p.vx *= 0.96f
            p.vy *= 0.96f
            
            // Fuerzas naturales de turbulencia de fondo (ondas sinusoidales)
            p.vx += sin(time + p.y * 0.006f).toFloat() * 0.15f
            p.vy += cos(time + p.x * 0.006f).toFloat() * 0.15f
            
            // Interacción táctil
            if (isTouching) {
                val dx = touchX - p.x
                val dy = touchY - p.y
                val dist = sqrt(dx * dx + dy * dy)
                if (dist > 1f && dist < 450f) {
                    val force = (1f - (dist / 450f)) * 2.2f
                    // Atracción suave
                    p.vx += (dx / dist) * force * 0.6f
                    p.vy += (dy / dist) * force * 0.6f
                    // Remolino rotacional (vórtice)
                    p.vx += (dy / dist) * force * 1.5f
                    p.vy -= (dx / dist) * force * 1.5f
                }
            }
            
            p.x += p.vx
            p.y += p.vy
            
            // Rebotar en bordes
            if (p.x < 0) { p.x = 0f; p.vx *= -0.5f }
            else if (p.x > w) { p.x = w; p.vx *= -0.5f }
            
            if (p.y < 0) { p.y = 0f; p.vy *= -0.5f }
            else if (p.y > h) { p.y = h; p.vy *= -0.5f }
        }
    }

    override fun onDraw(canvas: Canvas) {
        val isDim = prefs.getBoolean("isDimEnabled", false)
        
        // Espacio negro/azul oscuro
        canvas.drawColor(Color.parseColor("#06050F"))
        
        // Dibujar rastro y partículas
        for (p in particles) {
            // Rastro fluido
            paint.reset()
            paint.isAntiAlias = true
            paint.color = p.color
            paint.strokeWidth = p.radius * 0.9f
            paint.alpha = 130
            canvas.drawLine(p.px, p.py, p.x, p.y, paint)
            
            // Cabeza brillante de la partícula
            paint.alpha = 240
            paint.style = Paint.Style.FILL
            canvas.drawCircle(p.x, p.y, p.radius, paint)
        }

        if (isDim) {
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                isTouching = true
                touchX = event.x
                touchY = event.y
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isTouching = false
            }
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) {
            Choreographer.getInstance().postFrameCallback(frameCallback)
        } else {
            Choreographer.getInstance().removeFrameCallback(frameCallback)
            isTouching = false
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initParticles(width, height)
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

    data class FluidParticle(
        var x: Float,
        var y: Float,
        var px: Float,
        var py: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        val color: Int
    )
}

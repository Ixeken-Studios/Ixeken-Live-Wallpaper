package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.PorterDuff
import android.view.Choreographer
import android.view.SurfaceHolder

/**
 * Base class for interactive live wallpapers to reduce boilerplate and unify frame pacing,
 * dimming overlays, lockscreen 1 FPS battery optimization, and visibility handling.
 */
abstract class BaseWallpaperEngine(protected val context: Context) : IxekenWallpaperEngine {
    protected val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    protected var currentHolder: SurfaceHolder? = null
    protected var isVisible = false
    protected var hostEngine: android.service.wallpaper.WallpaperService.Engine? = null
    protected open val frameIntervalMs: Long = 0L
    private var frameCount = 0L
    private var lastFrameTimeMs = 0L

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                frameCount++
                val isHalfFps = prefs.getBoolean("isHalfFpsEnabled", false)
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as? android.os.PowerManager
                val isPowerSave = powerManager?.isPowerSaveMode == true
                
                if ((isHalfFps || isPowerSave) && frameCount % 2L != 0L) {
                    Choreographer.getInstance().postFrameCallback(this)
                    return
                }

                val now = System.currentTimeMillis()
                val targetInterval = if (isLockScreen()) 1000L else frameIntervalMs
                if (now - lastFrameTimeMs >= targetInterval) {
                    lastFrameTimeMs = now
                    onUpdatePhysics()
                    drawFrame()
                }
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun setEngineHost(host: android.service.wallpaper.WallpaperService.Engine) {
        hostEngine = host
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
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
    }

    override fun onDestroy() {
        isVisible = false
        Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    /**
     * Subclasses can override this to update animation state or physics logic on every render frame.
     */
    protected open fun onUpdatePhysics() {}

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
            drawDimOverlay(canvas)
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
    }

    private fun drawDimOverlay(canvas: Canvas) {
        val isDim = prefs.getBoolean("isDimEnabled", false)
        if (isDim) {
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
        }
    }

    private fun isLockScreen(): Boolean {
        if (android.os.Build.VERSION.SDK_INT >= 34) {
            val host = hostEngine
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
}

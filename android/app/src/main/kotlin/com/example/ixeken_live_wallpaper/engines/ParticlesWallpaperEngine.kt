package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class ParticlesWallpaperEngine(private val context: Context) : IxekenWallpaperEngine, SensorEventListener {
    
    private val prefs: SharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val particles = mutableListOf<Particle>()
    private val numParticles = 40
    
    private var lastFrameTimeMs = 0L

    private var sensorManager: SensorManager? = null
    private var rotationSensor: Sensor? = null
    private var isParallaxEnabled = false
    private var targetOffsetX = 0f
    private var targetOffsetY = 0f
    private var smoothOffsetX = 0f
    private var smoothOffsetY = 0f

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                val now = System.currentTimeMillis()
                val powerManager = context.getSystemService(Context.POWER_SERVICE) as? android.os.PowerManager
                val isPowerSave = powerManager?.isPowerSaveMode == true
                val targetInterval = if (isPowerSave) 33L else 0L
                
                if (now - lastFrameTimeMs >= targetInterval) {
                    lastFrameTimeMs = now
                    if (isParallaxEnabled) {
                        smoothOffsetX = smoothOffsetX * 0.9f + targetOffsetX * 0.1f
                        smoothOffsetY = smoothOffsetY * 0.9f + targetOffsetY * 0.1f
                    }
                    drawFrame()
                }
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        isParallaxEnabled = prefs.getBoolean("isParallaxEnabled", false)
        if (isParallaxEnabled) {
            sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
            rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                ?: sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        }
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
            registerSensor()
            Choreographer.getInstance().postFrameCallback(frameCallback)
        } else {
            unregisterSensor()
            Choreographer.getInstance().removeFrameCallback(frameCallback)
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initParticles(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#0F0F1B"))
        
        canvas.save()
        if (isParallaxEnabled) {
            canvas.translate(smoothOffsetX, smoothOffsetY)
        }
        
        val width = canvas.width.toFloat()
        val height = canvas.height.toFloat()

        for (p in particles) {
            p.x += p.vx
            p.y += p.vy

            if (p.x < 0 || p.x > width) p.vx *= -1
            if (p.y < 0 || p.y > height) p.vy *= -1

            paint.color = p.color
            canvas.drawCircle(p.x, p.y, p.radius, paint)
        }
        canvas.restore()

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
        unregisterSensor()
        Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    private fun registerSensor() {
        if (isParallaxEnabled && sensorManager != null && rotationSensor != null) {
            sensorManager?.registerListener(this, rotationSensor, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun unregisterSensor() {
        if (isParallaxEnabled && sensorManager != null) {
            sensorManager?.unregisterListener(this)
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        var targetX = 0f
        var targetY = 0f
        
        if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR) {
            val rotationMatrix = FloatArray(9)
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            val orientation = FloatArray(3)
            SensorManager.getOrientation(rotationMatrix, orientation)
            targetX = -orientation[2]
            targetY = -orientation[1]
        } else if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
            targetX = event.values[0] / 9.8f
            targetY = (event.values[1] - 5f) / 9.8f
        }
        
        val maxOffset = 60f
        targetOffsetX = targetX.coerceIn(-1f, 1f) * maxOffset
        targetOffsetY = targetY.coerceIn(-1f, 1f) * maxOffset
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    data class Particle(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        val color: Int
    )
}

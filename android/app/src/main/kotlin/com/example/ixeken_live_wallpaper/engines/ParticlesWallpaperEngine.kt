package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.SurfaceHolder
import kotlin.random.Random

class ParticlesWallpaperEngine(context: Context) : BaseWallpaperEngine(context), SensorEventListener {
    
    private val paint = Paint().apply { isAntiAlias = true }
    private val particles = mutableListOf<Particle>()
    private val numParticles = 40
    
    private var sensorManager: SensorManager? = null
    private var rotationSensor: Sensor? = null
    private var isParallaxEnabled = false
    private var targetOffsetX = 0f
    private var targetOffsetY = 0f
    private var smoothOffsetX = 0f
    private var smoothOffsetY = 0f

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
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

    override fun onUpdatePhysics() {
        if (isParallaxEnabled) {
            smoothOffsetX = smoothOffsetX * 0.9f + targetOffsetX * 0.1f
            smoothOffsetY = smoothOffsetY * 0.9f + targetOffsetY * 0.1f
        }
        
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f
        for (p in particles) {
            p.x += p.vx
            p.y += p.vy
            if (p.x < 0 || p.x > w) p.vx *= -1
            if (p.y < 0 || p.y > h) p.vy *= -1
        }
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#0F0F1B"))
        
        canvas.save()
        if (isParallaxEnabled) {
            canvas.translate(smoothOffsetX, smoothOffsetY)
        }
        
        for (p in particles) {
            paint.color = p.color
            canvas.drawCircle(p.x, p.y, p.radius, paint)
        }
        canvas.restore()
    }

    override fun onVisibilityChanged(visible: Boolean) {
        super.onVisibilityChanged(visible)
        if (visible) {
            registerSensor()
        } else {
            unregisterSensor()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterSensor()
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

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        super.onSurfaceChanged(holder, format, width, height)
        initParticles(width, height)
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

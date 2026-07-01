package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.MotionEvent
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

class SakuraWallpaperEngine(context: Context) : BaseWallpaperEngine(context), SensorEventListener {

    private class Petal(
        var x: Float,
        var y: Float,
        var size: Float,
        var speedY: Float,
        var speedX: Float,
        var angle: Float,
        var rotateSpeed: Float
    )

    private val petals = mutableListOf<Petal>()
    private val paint = Paint().apply { style = Paint.Style.FILL }
    private val trunkPaint = Paint().apply {
        color = Color.parseColor("#38101E") // Sumi-e Ink
        strokeWidth = 16f
        strokeCap = Paint.Cap.ROUND
        style = Paint.Style.STROKE
        isAntiAlias = true
    }
    private val blossomPaint = Paint().apply {
        color = Color.argb(90, 244, 114, 182)
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val sunPaint = Paint().apply {
        color = Color.argb(90, 253, 164, 175)
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    private var sensorManager: SensorManager? = null
    private var accelSensor: Sensor? = null
    private var windX = 0f
    private var tiltWindX = 0f
    private var initialized = false
    private var time = 0f

    override val frameIntervalMs = 16L // ~60 FPS

    private fun initSakura(w: Float, h: Float) {
        petals.clear()
        for (i in 0 until 40) {
            petals.add(
                Petal(
                    x = Random.nextFloat() * w,
                    y = Random.nextFloat() * h,
                    size = Random.nextFloat() * 10f + 6f,
                    speedY = Random.nextFloat() * 2f + 1.2f,
                    speedX = (Random.nextFloat() - 0.5f) * 1.5f,
                    angle = Random.nextFloat() * 2f * Math.PI.toFloat(),
                    rotateSpeed = (Random.nextFloat() - 0.5f) * 0.1f
                )
            )
        }
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        accelSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager?.registerListener(this, accelSensor, SensorManager.SENSOR_DELAY_GAME)
        initialized = true
    }

    override fun onUpdatePhysics() {
        val frame = currentHolder?.surfaceFrame ?: return
        val w = frame.width().toFloat()
        val h = frame.height().toFloat()

        if (!initialized) initSakura(w, h)

        time += 0.02f
        val waveWind = sin(time) * 0.8f
        windX = windX * 0.95f + (tiltWindX + waveWind) * 0.05f

        for (p in petals) {
            p.y += p.speedY
            p.x += p.speedX + windX
            p.angle += p.rotateSpeed

            if (p.y > h) {
                p.y = -20f
                p.x = Random.nextFloat() * w
            }
            if (p.x < -20f) p.x = w + 20f
            if (p.x > w + 20f) p.x = -20f
        }
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        if (!initialized) initSakura(w, h)

        // Draw soft watercolor background
        val bgShader = LinearGradient(
            0f, 0f, 0f, h,
            intArrayOf(Color.parseColor("#FFFFECEF"), Color.parseColor("#FEF3C7"), Color.parseColor("#FDF2F8")),
            null, Shader.TileMode.CLAMP
        )
        paint.reset()
        paint.shader = bgShader
        canvas.drawRect(0f, 0f, w, h, paint)
        paint.shader = null

        // Draw soft red sun back layer
        canvas.drawCircle(w * 0.3f, h * 0.25f, 150f, sunPaint)

        // Draw tree trunk and branching paths
        val baseW = w * 0.78f
        val trunkPath = Path().apply {
            moveTo(baseW, h)
            quadTo(baseW - 35f, h * 0.72f, baseW - 95f, h * 0.65f)
        }
        canvas.drawPath(trunkPath, trunkPaint)

        trunkPaint.strokeWidth = 9f
        canvas.drawLine(baseW - 95f, h * 0.65f, baseW - 220f, h * 0.53f, trunkPaint)
        canvas.drawLine(baseW - 95f, h * 0.65f, baseW + 30f, h * 0.50f, trunkPaint)
        trunkPaint.strokeWidth = 16f

        // Draw sakura foliage overlays
        blossomPaint.color = Color.argb(76, 253, 164, 175)
        canvas.drawCircle(baseW - 200f, h * 0.53f, 110f, blossomPaint)
        blossomPaint.color = Color.argb(63, 244, 114, 182)
        canvas.drawCircle(baseW + 15f, h * 0.50f, 120f, blossomPaint)
        blossomPaint.color = Color.argb(102, 253, 242, 248)
        canvas.drawCircle(baseW - 95f, h * 0.43f, 140f, blossomPaint)

        // Draw falling petals with simulated 3D spin
        paint.reset()
        paint.style = Paint.Style.FILL

        val petalPath = Path()

        for (p in petals) {
            // Calculate scaleX from sin to simulate spin
            val scaleX = sin(p.angle * 2.5f).let { if (it < 0f) -it else it }.coerceIn(0.15f, 1.0f)

            canvas.save()
            canvas.translate(p.x, p.y)
            canvas.rotate(Math.toDegrees(p.angle.toDouble()).toFloat())
            canvas.scale(scaleX, 1.0f)

            val petalGrad = RadialGradient(
                0f, 0f, p.size * 1.5f,
                intArrayOf(Color.parseColor("#FEE2E2"), Color.parseColor("#F472B6")),
                null, Shader.TileMode.CLAMP
            )
            paint.shader = petalGrad

            petalPath.reset()
            petalPath.moveTo(0f, -p.size)
            petalPath.cubicTo(-p.size, -p.size, -p.size, p.size, 0f, p.size * 1.5f)
            petalPath.cubicTo(p.size, p.size, p.size, -p.size, 0f, -p.size)
            petalPath.close()

            canvas.drawPath(petalPath, paint)
            canvas.restore()
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_DOWN || event.action == MotionEvent.ACTION_MOVE) {
            windX = 7f
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
            val ax = event.values[0]
            tiltWindX = -ax * 0.6f
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
    }
}

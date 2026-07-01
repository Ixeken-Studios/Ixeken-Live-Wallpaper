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
import kotlin.math.atan2
import kotlin.math.sqrt
import kotlin.random.Random

class KaleidoscopeWallpaperEngine(context: Context) : BaseWallpaperEngine(context), SensorEventListener {

    private class Item(
        var radius: Float,
        var angle: Float,
        val size: Float,
        var speedRadius: Float,
        var speedAngle: Float,
        val color: Int,
        val type: Int
    )

    private val items = mutableListOf<Item>()
    private val polyPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val linePaint = Paint().apply {
        style = Paint.Style.STROKE
        strokeWidth = 2f
        isAntiAlias = true
    }
    private val nodePaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    private val vignettePaint = Paint().apply {
        isAntiAlias = true
    }

    private var sensorManager: SensorManager? = null
    private var gyroSensor: Sensor? = null
    private var gyroAngle = 0f
    private var targetAngle = 0f
    private var initialized = false

    override val frameIntervalMs = 16L // ~60 FPS

    private fun initKaleidoscope() {
        items.clear()
        val colors = intArrayOf(
            Color.parseColor("#F43F5E"),
            Color.parseColor("#3B82F6"),
            Color.parseColor("#10B981"),
            Color.parseColor("#F59E0B"),
            Color.parseColor("#8B5CF6")
        )
        val sectorAngle = (2f * Math.PI.toFloat() / 8f)

        for (i in 0 until 24) {
            items.add(
                Item(
                    radius = Random.nextFloat() * 320f + 20f,
                    angle = Random.nextFloat() * sectorAngle,
                    size = Random.nextFloat() * 15f + 8f,
                    speedRadius = (Random.nextFloat() - 0.5f) * 1.5f,
                    speedAngle = (Random.nextFloat() - 0.5f) * 0.008f,
                    color = colors[Random.nextInt(colors.size)],
                    type = Random.nextInt(3)
                )
            )
        }

        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        gyroSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager?.registerListener(this, gyroSensor, SensorManager.SENSOR_DELAY_GAME)
        initialized = true
    }

    override fun onUpdatePhysics() {
        if (!initialized) initKaleidoscope()

        val sectorAngle = (2f * Math.PI.toFloat() / 8f)

        for (item in items) {
            item.radius += item.speedRadius
            item.angle += item.speedAngle

            if (item.radius < 10f || item.radius > 450f) {
                item.speedRadius *= -1f
            }

            if (item.angle < 0f) {
                item.angle = 0f
                item.speedAngle *= -1f
            } else if (item.angle > sectorAngle) {
                item.angle = sectorAngle
                item.speedAngle *= -1f
            }
        }

        gyroAngle = gyroAngle * 0.9f + targetAngle * 0.1f
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        if (!initialized) initKaleidoscope()

        canvas.drawColor(Color.parseColor("#020104"))

        // Honeycomb grid layout R (Radius)
        val R = w * 0.45f
        val hexWidth = R * sqrt(3f)
        val hexHeight = R * 1.5f

        val cols = (w / hexWidth).toInt() + 2
        val rows = (h / hexHeight).toInt() + 2

        val sectorAngle = Math.PI.toFloat() / 3f
        val path = Path()

        // Filter and sort items to draw triangles correctly
        val sectorItems = items.filter { it.angle in 0f..sectorAngle }.sortedBy { it.angle }

        for (r in -1..rows) {
            val y = r * hexHeight
            for (c in -1..cols) {
                val x = c * hexWidth + (if (r % 2 != 0) hexWidth / 2f else 0f)

                canvas.save()
                canvas.translate(x, y)

                for (i in 0 until 6) {
                    canvas.save()
                    canvas.rotate(Math.toDegrees((i * sectorAngle + gyroAngle).toDouble()).toFloat())

                    if (i % 2 == 1) {
                        canvas.scale(1f, -1f)
                    }

                    // 1. Draw overlapping translucent crystal glass polygons
                    for (j in sectorItems.indices) {
                        val itemA = sectorItems[j]
                        val itemB = sectorItems[(j + 1) % sectorItems.size]

                        val px1 = itemA.radius * cos(itemA.angle)
                        val py1 = itemA.radius * sin(itemA.angle)
                        val px2 = itemB.radius * cos(itemB.angle)
                        val py2 = itemB.radius * sin(itemB.angle)

                        path.reset()
                        path.moveTo(0f, 0f)
                        path.lineTo(px1, py1)
                        path.lineTo(px2, py2)
                        path.close()

                        val radialShader = RadialGradient(
                            (px1 + px2) / 2f, (py1 + py2) / 2f, itemA.radius * 0.8f,
                            intArrayOf(itemA.color, Color.TRANSPARENT),
                            null, Shader.TileMode.CLAMP
                        )
                        polyPaint.shader = radialShader
                        polyPaint.alpha = 55
                        canvas.drawPath(path, polyPaint)
                    }

                    // 2. Draw crystal lines structure
                    for (j in sectorItems.indices) {
                        val itemA = sectorItems[j]
                        val itemB = sectorItems[(j + 1) % sectorItems.size]

                        val px1 = itemA.radius * cos(itemA.angle)
                        val py1 = itemA.radius * sin(itemA.angle)
                        val px2 = itemB.radius * cos(itemB.angle)
                        val py2 = itemB.radius * sin(itemB.angle)

                        linePaint.color = itemA.color
                        linePaint.alpha = 115
                        canvas.drawLine(px1, py1, px2, py2, linePaint)

                        linePaint.alpha = 45
                        canvas.drawLine(0f, 0f, px1, py1, linePaint)
                    }

                    // 3. Draw nodes / shiny jewels
                    for (item in sectorItems) {
                        val px = item.radius * cos(item.angle)
                        val py = item.radius * sin(item.angle)

                        nodePaint.color = item.color
                        nodePaint.alpha = 140
                        canvas.drawCircle(px, py, item.size / 2.5f + 2f, nodePaint)

                        nodePaint.color = Color.WHITE
                        nodePaint.alpha = 255
                        canvas.drawCircle(px, py, 3f, nodePaint)
                    }

                    canvas.restore()
                }
                canvas.restore()
            }
        }

        // Draw radial dark vignette overlay for optical realism
        val vignetteShader = RadialGradient(
            w / 2f, h / 2f, h * 0.6f,
            intArrayOf(Color.TRANSPARENT, Color.BLACK),
            floatArrayOf(0.35f, 1f), Shader.TileMode.CLAMP
        )
        vignettePaint.shader = vignetteShader
        canvas.drawRect(0f, 0f, w, h, vignettePaint)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
            val ax = event.values[0]
            val ay = event.values[1]
            targetAngle = atan2(-ax, ay)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onDestroy() {
        super.onDestroy()
        sensorManager?.unregisterListener(this)
    }
}

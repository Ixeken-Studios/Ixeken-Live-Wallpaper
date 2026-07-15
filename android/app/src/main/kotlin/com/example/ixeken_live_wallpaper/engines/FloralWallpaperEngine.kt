package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.sin
import kotlin.math.cos
import kotlin.math.abs
import kotlin.random.Random

class FloralWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private val paint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
    }
    
    private val veinPaint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.STROKE
        strokeWidth = 1f
        color = Color.argb(40, 255, 255, 255)
    }

    private val petals = mutableListOf<Petal>()
    private val numPetals = 35

    private var windX = 0f
    private var windY = 0f
    private var lastTouchX = 0f
    private var lastTouchY = 0f

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        initPetals(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initPetals(width: Int, height: Int) {
        petals.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920
        
        val colors = listOf(
            Color.parseColor("#FFFFB7B2"), // Light peach pink
            Color.parseColor("#FFFFC6FF"), // Soft lavender pink
            Color.parseColor("#FFFF85A1"), // Cherry pink
            Color.parseColor("#FFF7CAD0"), // Pale rose
            Color.parseColor("#FFF9BEC7")  // Rose gold accent
        )

        repeat(numPetals) {
            petals.add(Petal(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h - h, // scattered above
                vx = (Random.nextFloat() - 0.5f) * 1.5f,
                vy = Random.nextFloat() * 2.5f + 1.8f,
                scale = Random.nextFloat() * 0.6f + 0.4f,
                angle = Random.nextFloat() * 360f,
                rotationSpeed = (Random.nextFloat() - 0.5f) * 1.5f,
                swayTime = Random.nextFloat() * 10f,
                swaySpeed = Random.nextFloat() * 0.04f + 0.02f,
                swayAmplitude = Random.nextFloat() * 35f + 15f,
                windSensitivity = Random.nextFloat() * 0.6f + 0.8f,
                color = colors[Random.nextInt(colors.size)]
            ))
        }
    }

    override fun onUpdatePhysics() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f

        // Slowly decay user-driven wind back to zero
        windX *= 0.96f
        windY *= 0.96f

        for (p in petals) {
            p.x += p.vx + windX * p.windSensitivity
            p.y += p.vy + windY * p.windSensitivity

            p.swayTime += p.swaySpeed
            val sway = sin(p.swayTime) * p.swayAmplitude
            val drawX = p.x + sway

            p.angle += p.rotationSpeed

            // Wrap around screen boundaries
            if (p.y > h + 50f) {
                p.y = -50f
                p.x = Random.nextFloat() * w
                p.swayTime = Random.nextFloat() * 10f
            }
            if (p.x < -100f) {
                p.x = w + 50f
            } else if (p.x > w + 100f) {
                p.x = -50f
            }
        }
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#0F0F1B"))

        for (p in petals) {
            val sway = sin(p.swayTime) * p.swayAmplitude
            val drawX = p.x + sway

            canvas.save()
            canvas.translate(drawX, p.y)
            canvas.rotate(p.angle)
            
            // Simulate 3D rotation by scaling horizontally
            val scaleX = abs(cos(p.swayTime * 0.5f)) * 0.6f + 0.4f
            canvas.scale(scaleX * p.scale, p.scale)

            paint.color = p.color
            
            // Build petal path
            val path = Path().apply {
                moveTo(0f, -20f)
                quadTo(20f, -10f, 10f, 20f)
                quadTo(0f, 30f, -10f, 20f)
                quadTo(-20f, -10f, 0f, -20f)
                close()
            }
            canvas.drawPath(path, paint)
            
            // Draw central vein
            val veinPath = Path().apply {
                moveTo(0f, 20f)
                quadTo(4f, 0f, 0f, -10f)
            }
            canvas.drawPath(veinPath, veinPaint)

            canvas.restore()
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                lastTouchX = event.x
                lastTouchY = event.y
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = event.x - lastTouchX
                val dy = event.y - lastTouchY
                // Apply impulse force
                windX += dx * 0.05f
                windY += dy * 0.05f
                // Cap wind speeds
                windX = windX.coerceIn(-12f, 12f)
                windY = windY.coerceIn(-12f, 12f)
                
                lastTouchX = event.x
                lastTouchY = event.y
            }
        }
    }

    private class Petal(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val scale: Float,
        var angle: Float,
        val rotationSpeed: Float,
        var swayTime: Float,
        val swaySpeed: Float,
        val swayAmplitude: Float,
        val windSensitivity: Float,
        val color: Int
    )
}

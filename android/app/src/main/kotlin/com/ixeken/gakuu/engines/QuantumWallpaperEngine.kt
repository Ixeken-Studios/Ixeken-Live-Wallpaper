package com.ixeken.gakuu.engines

import android.content.Context
import android.graphics.*
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.math.sqrt
import kotlin.random.Random

class QuantumWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private val paintNode = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
    }

    private val paintLine = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.STROKE
    }

    private val nodes = mutableListOf<QuantumNode>()
    private val numNodes = 35

    private var gravityX: Float? = null
    private var gravityY: Float? = null

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        initNodes(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initNodes(width: Int, height: Int) {
        nodes.clear()
        val w = if (width > 0) width else 1080
        val h = if (height > 0) height else 1920

        val colors = listOf(
            Color.parseColor("#FF00E5FF"), // Electric cyan
            Color.parseColor("#FFD500F9"), // Cyber purple
            Color.parseColor("#FF651FFF"), // Deep purple
            Color.parseColor("#FF00E676")  // Bright green
        )

        repeat(numNodes) {
            nodes.add(QuantumNode(
                x = Random.nextFloat() * w,
                y = Random.nextFloat() * h,
                vx = (Random.nextFloat() - 0.5f) * 3f,
                vy = (Random.nextFloat() - 0.5f) * 3f,
                radius = Random.nextFloat() * 6f + 4f,
                color = colors[Random.nextInt(colors.size)]
            ))
        }
    }

    override fun onUpdatePhysics() {
        val w = currentHolder?.surfaceFrame?.width()?.toFloat() ?: 1080f
        val h = currentHolder?.surfaceFrame?.height()?.toFloat() ?: 1920f

        val gx = gravityX
        val gy = gravityY

        for (n in nodes) {
            if (gx != null && gy != null) {
                // Apply touch gravity attraction force
                val dx = gx - n.x
                val dy = gy - n.y
                val dist = sqrt((dx * dx + dy * dy).toDouble()).toFloat()
                if (dist > 1f && dist < 600f) {
                    val force = (600f - dist) / 600f * 1.2f
                    n.vx += (dx / dist) * force
                    n.vy += (dy / dist) * force
                }
            }

            // Terminal velocity limit
            n.vx = n.vx.coerceIn(-6f, 6f)
            n.vy = n.vy.coerceIn(-6f, 6f)

            n.x += n.vx
            n.y += n.vy

            // Ambient drag friction
            n.vx *= 0.98f
            n.vy *= 0.98f

            // Bounce off boundaries
            if (n.x < 0f || n.x > w) {
                n.vx *= -1f
                n.x = n.x.coerceIn(0f, w)
            }
            if (n.y < 0f || n.y > h) {
                n.vy *= -1f
                n.y = n.y.coerceIn(0f, h)
            }
        }
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawColor(Color.parseColor("#03020A"))

        // Draw links
        for (i in 0 until nodes.size) {
            for (j in i + 1 until nodes.size) {
                val n1 = nodes[i]
                val n2 = nodes[j]

                val dx = n2.x - n1.x
                val dy = n2.y - n1.y
                val dist = sqrt((dx * dx + dy * dy).toDouble()).toFloat()

                if (dist < 220f) {
                    val alpha = (1.0f - (dist / 220f)).coerceIn(0.0f, 1.0f)
                    paintLine.strokeWidth = 3f * alpha
                    
                    val shader = LinearGradient(
                        n1.x, n1.y, n2.x, n2.y,
                        Color.argb((alpha * 120).toInt(), Color.red(n1.color), Color.green(n1.color), Color.blue(n1.color)),
                        Color.argb((alpha * 120).toInt(), Color.red(n2.color), Color.green(n2.color), Color.blue(n2.color)),
                        Shader.TileMode.CLAMP
                    )
                    paintLine.shader = shader
                    canvas.drawLine(n1.x, n1.y, n2.x, n2.y, paintLine)
                }
            }
        }

        // Draw nodes
        for (n in nodes) {
            paintNode.shader = null
            paintNode.color = n.color
            canvas.drawCircle(n.x, n.y, n.radius, paintNode)

            // Draw radial glow aura
            val alphaGlowCore = Color.argb(90, Color.red(n.color), Color.green(n.color), Color.blue(n.color))
            val glow = RadialGradient(
                n.x, n.y, n.radius * 3.5f,
                intArrayOf(alphaGlowCore, Color.TRANSPARENT),
                floatArrayOf(0.0f, 1.0f),
                Shader.TileMode.CLAMP
            )
            paintNode.shader = glow
            canvas.drawCircle(n.x, n.y, n.radius * 3.5f, paintNode)
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                gravityX = event.x
                gravityY = event.y
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                gravityX = null
                gravityY = null
            }
        }
    }

    private class QuantumNode(
        var x: Float,
        var y: Float,
        var vx: Float,
        var vy: Float,
        val radius: Float,
        val color: Int
    )
}

package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class MatrixWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply {
        isAntiAlias = true
        typeface = Typeface.MONOSPACE
        textSize = 40f
    }
    
    private var cols = 0
    private lateinit var yPositions: IntArray
    private val chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ日ハミヒヘホマミムメモヤユヨラリルレロ".toCharArray()
    private val charSize = 45f
    
    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                drawFrame()
                // Controlar velocidad: Matrix se ve mejor un poco más lento que 60fps
                Thread.sleep(30) 
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        initMatrix(holder.surfaceFrame.width())
    }

    private fun initMatrix(width: Int) {
        cols = (width / charSize).toInt() + 1
        yPositions = IntArray(cols) { Random.nextInt(-100, 0) }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) Choreographer.getInstance().postFrameCallback(frameCallback)
        else Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initMatrix(width)
    }

    override fun onDraw(canvas: Canvas) {
        // Fondo con rastro de desvanecimiento
        // Dibujamos un negro muy translúcido para que los caracteres anteriores se borren poco a poco
        canvas.drawColor(Color.argb(40, 0, 0, 0))
        
        paint.textAlign = Paint.Align.CENTER
        
        for (i in yPositions.indices) {
            val x = i * charSize + charSize / 2
            val y = yPositions[i] * charSize
            
            // Caracter aleatorio
            val char = chars[Random.nextInt(chars.size)]
            
            // El primer caracter de la lluvia es blanco/brillante
            paint.color = if (Random.nextInt(10) > 8) Color.WHITE else Color.GREEN
            paint.setShadowLayer(10f, 0f, 0f, Color.GREEN) // Brillo neón
            
            canvas.drawText(char.toString(), x, y, paint)
            paint.clearShadowLayer()
            
            // Actualizar posición
            if (y > canvas.height && Random.nextInt(100) > 95) {
                yPositions[i] = 0
            } else {
                yPositions[i]++
            }
        }
    }

    private fun drawFrame() {
        val holder = currentHolder ?: return
        val canvas = holder.lockCanvas() ?: return
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

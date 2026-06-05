package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
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
    }
    
    private var cols = 0
    private var charSize = 40f
    private val chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ日ハミヒヘホマミムメモヤユヨラリルレロ".toCharArray()
    private val drops = mutableListOf<MatrixDrop>()
    
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)

    private var lastFrameTime = 0L
    private val frameInterval = 45L // ~22 FPS para movimiento cinemático clásico de Matrix

    // Estructura de gota para representar cada columna de lluvia
    data class MatrixDrop(
        val x: Float,
        var y: Float, // posición de la cabeza de la gota en caracteres
        val speed: Float,
        val length: Int,
        val columnChars: MutableList<Char>
    )

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                val now = System.currentTimeMillis()
                if (now - lastFrameTime >= frameInterval) {
                    drawFrame()
                    lastFrameTime = now
                }
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        initMatrix(holder.surfaceFrame.width(), holder.surfaceFrame.height())
    }

    private fun initMatrix(width: Int, height: Int) {
        charSize = width.toFloat() / 25f // Fijar a 25 columnas para mejor densidad
        if (charSize < 32f) charSize = 32f
        
        paint.textSize = charSize * 0.85f
        cols = (width / charSize).toInt() + 1
        
        drops.clear()
        val rowsCount = (height / charSize).toInt() + 5
        
        repeat(cols) { colIndex ->
            val length = Random.nextInt(8, 20)
            val columnChars = MutableList(rowsCount) { chars[Random.nextInt(chars.size)] }
            drops.add(
                MatrixDrop(
                    x = colIndex * charSize + charSize / 2f,
                    y = Random.nextFloat() * -rowsCount, // Iniciar arriba aleatoriamente
                    speed = Random.nextFloat() * 0.35f + 0.15f, // velocidad lenta y variada
                    length = length,
                    columnChars = columnChars
                )
            )
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) {
            lastFrameTime = System.currentTimeMillis()
            Choreographer.getInstance().postFrameCallback(frameCallback)
        } else {
            Choreographer.getInstance().removeFrameCallback(frameCallback)
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        initMatrix(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        // Fondo negro profundo y sólido (evita problemas acumulativos de doble búfer)
        canvas.drawColor(Color.parseColor("#020402"))
        
        paint.textAlign = Paint.Align.CENTER
        
        val rowsCount = (canvas.height / charSize).toInt() + 2
        val isDim = prefs.getBoolean("isDimEnabled", false)
        
        for (drop in drops) {
            // Actualizar posición de la cabeza
            drop.y += drop.speed
            if (drop.y - drop.length > rowsCount) {
                drop.y = -Random.nextInt(4, 12).toFloat()
            }
            
            // Mutar aleatoriamente caracteres del rastro
            if (Random.nextFloat() > 0.96f) {
                val idx = Random.nextInt(drop.columnChars.size)
                drop.columnChars[idx] = chars[Random.nextInt(chars.size)]
            }
            
            // Dibujar el trail de abajo hacia arriba (cabeza a cola)
            val headIndex = drop.y.toInt()
            for (j in 0 until drop.length) {
                val charYIdx = headIndex - j
                if (charYIdx < 0 || charYIdx >= drop.columnChars.size) continue
                
                val yPos = charYIdx * charSize + charSize
                val char = drop.columnChars[charYIdx]
                
                // Opacidad en base a la distancia de la cabeza
                val fraction = 1.0f - (j.toFloat() / drop.length.toFloat())
                val alpha = (fraction * 255).toInt().coerceIn(0, 255)
                
                if (j == 0) {
                    // La cabeza es blanca brillante y brilla neón
                    paint.color = Color.WHITE
                    paint.setShadowLayer(14f, 0f, 0f, Color.parseColor("#34D399")) // Brillo verde brillante
                } else {
                    // El cuerpo es verde degradado
                    paint.color = Color.argb(alpha, 16, 185, 129) // Emerald-500 (#10B981)
                    paint.clearShadowLayer()
                }
                
                canvas.drawText(char.toString(), drop.x, yPos, paint)
            }
        }
        paint.clearShadowLayer()
        
        if (isDim) {
            canvas.drawColor(Color.argb(110, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
        }
    }

    private fun drawFrame() {
        val holder = currentHolder ?: return
        val canvas = if (android.os.Build.VERSION.SDK_INT >= 26) holder.lockHardwareCanvas() else holder.lockCanvas()
        if (canvas == null) return
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

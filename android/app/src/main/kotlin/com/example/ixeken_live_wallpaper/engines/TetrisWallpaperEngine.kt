package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.RectF
import android.graphics.Shader
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class TetrisWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    private val prefs = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    
    private val cols = 10
    private var rows = 20
    private var cellSize = 0f
    private var grid = Array(rows) { IntArray(cols) { 0 } }
    
    private var currentPieceX = 0
    private var currentPieceY = 0
    private var currentPieceType = 0
    private var currentRotation = 0
    
    private var targetX = 0
    private var targetRotation = 0
    
    private var lastUpdate = 0L
    private val dropInterval = 200L

    private val shapes = arrayOf(
        arrayOf(arrayOf(intArrayOf(1,1,1,1)), arrayOf(intArrayOf(1),intArrayOf(1),intArrayOf(1),intArrayOf(1))),
        arrayOf(arrayOf(intArrayOf(1,0,0),intArrayOf(1,1,1)), arrayOf(intArrayOf(1,1),intArrayOf(1,0),intArrayOf(1,0)), arrayOf(intArrayOf(1,1,1),intArrayOf(0,0,1)), arrayOf(intArrayOf(0,1),intArrayOf(0,1),intArrayOf(1,1))),
        arrayOf(arrayOf(intArrayOf(0,0,1),intArrayOf(1,1,1)), arrayOf(intArrayOf(1,0),intArrayOf(1,0),intArrayOf(1,1)), arrayOf(intArrayOf(1,1,1),intArrayOf(1,0,0)), arrayOf(intArrayOf(1,1),intArrayOf(0,1),intArrayOf(0,1))),
        arrayOf(arrayOf(intArrayOf(1,1),intArrayOf(1,1))),
        arrayOf(arrayOf(intArrayOf(0,1,1),intArrayOf(1,1,0)), arrayOf(intArrayOf(1,0),intArrayOf(1,1),intArrayOf(0,1))),
        arrayOf(arrayOf(intArrayOf(0,1,0),intArrayOf(1,1,1)), arrayOf(intArrayOf(1,0),intArrayOf(1,1),intArrayOf(1,0)), arrayOf(intArrayOf(1,1,1),intArrayOf(0,1,0)), arrayOf(intArrayOf(0,1),intArrayOf(1,1),intArrayOf(0,1))),
        arrayOf(arrayOf(intArrayOf(1,1,0),intArrayOf(0,1,1)), arrayOf(intArrayOf(0,1),intArrayOf(1,1),intArrayOf(1,0)))
    )

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isVisible) {
                updateLogic()
                drawFrame()
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        resetGrid(holder.surfaceFrame.width(), holder.surfaceFrame.height())
        spawnPiece()
    }

    private fun resetGrid(width: Int, height: Int) {
        cellSize = width.toFloat() / cols
        rows = (height / cellSize).toInt()
        grid = Array(rows) { IntArray(cols) { 0 } }
    }

    private fun spawnPiece() {
        currentPieceType = Random.nextInt(0, 7)
        currentRotation = 0
        currentPieceX = cols / 2 - 1
        currentPieceY = 0
        
        if (checkCollision(currentPieceX, currentPieceY, currentRotation)) {
            grid = Array(rows) { IntArray(cols) { 0 } }
        }
        
        thinkBestMove()
    }

    private fun thinkBestMove() {
        var bestScore = -1000000.0
        var bestX = currentPieceX
        var bestRot = 0

        val rotations = shapes[currentPieceType].size
        for (r in 0 until rotations) {
            val shape = shapes[currentPieceType][r]
            val pieceW = shape[0].size
            
            for (x in 0..(cols - pieceW)) {
                var y = 0
                while (!checkCollision(x, y + 1, r)) {
                    y++
                }
                
                val score = evaluatePosition(x, y, r)
                if (score > bestScore) {
                    bestScore = score
                    bestX = x
                    bestRot = r
                }
            }
        }
        
        targetX = bestX
        targetRotation = bestRot
    }

    private fun evaluatePosition(px: Int, py: Int, pr: Int): Double {
        val tempGrid = Array(rows) { grid[it].copyOf() }
        val shape = shapes[currentPieceType][pr]
        
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0 && (py + y) < rows) {
                    tempGrid[py + y][px + x] = 1
                }
            }
        }

        var aggregateHeight = 0
        var completeLines = 0
        var holes = 0
        var bumpiness = 0
        
        val heights = IntArray(cols) { 0 }
        for (x in 0 until cols) {
            for (y in 0 until rows) {
                if (tempGrid[y][x] != 0) {
                    heights[x] = rows - y
                    break
                }
            }
            aggregateHeight += heights[x]
        }

        for (y in 0 until rows) {
            if (tempGrid[y].all { it != 0 }) completeLines++
        }

        for (x in 0 until cols) {
            var blockFound = false
            for (y in 0 until rows) {
                if (tempGrid[y][x] != 0) blockFound = true
                else if (blockFound && tempGrid[y][x] == 0) holes++
            }
        }

        for (x in 0 until (cols - 1)) {
            bumpiness += kotlin.math.abs(heights[x] - heights[x+1])
        }

        return (-0.51 * aggregateHeight) + (0.76 * completeLines) + (-0.35 * holes) + (-0.18 * bumpiness)
    }

    private fun updateLogic() {
        val now = System.currentTimeMillis()
        if (now - lastUpdate > dropInterval) {
            if (currentRotation != targetRotation) {
                currentRotation = targetRotation
            }

            if (currentPieceX < targetX) currentPieceX++
            else if (currentPieceX > targetX) currentPieceX--

            if (!checkCollision(currentPieceX, currentPieceY + 1, currentRotation)) {
                currentPieceY++
            } else {
                lockPiece()
                clearLines()
                spawnPiece()
            }
            lastUpdate = now
        }
    }

    private fun checkCollision(nx: Int, ny: Int, nr: Int): Boolean {
        val shape = shapes[currentPieceType][nr % shapes[currentPieceType].size]
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0) {
                    val tx = nx + x
                    val ty = ny + y
                    if (tx < 0 || tx >= cols || ty >= rows || (ty >= 0 && grid[ty][tx] != 0)) return true
                }
            }
        }
        return false
    }

    private fun lockPiece() {
        val shape = shapes[currentPieceType][currentRotation % shapes[currentPieceType].size]
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0) {
                    val ty = currentPieceY + y
                    val tx = currentPieceX + x
                    if (ty in 0 until rows) grid[ty][tx] = currentPieceType + 1
                }
            }
        }
    }

    private fun clearLines() {
        for (y in rows - 1 downTo 0) {
            if (grid[y].all { it != 0 }) {
                for (moveY in y downTo 1) grid[moveY] = grid[moveY - 1].copyOf()
                grid[0] = IntArray(cols) { 0 }
                clearLines()
                return
            }
        }
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) Choreographer.getInstance().postFrameCallback(frameCallback)
        else Choreographer.getInstance().removeFrameCallback(frameCallback)
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        resetGrid(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        val style = prefs.getString("tetris_style", "neon") ?: "neon"
        val isRetro = style == "retro"
        
        // Dibujar Fondo
        val bgPaint = Paint().apply {
            if (isRetro) {
                color = Color.parseColor("#8BAC0F") // Fondo verde clásico Gameboy
            } else {
                shader = LinearGradient(0f, 0f, 0f, canvas.height.toFloat(), 
                    Color.parseColor("#080810"), Color.parseColor("#121220"), Shader.TileMode.CLAMP)
            }
        }
        canvas.drawRect(0f, 0f, canvas.width.toFloat(), canvas.height.toFloat(), bgPaint)

        // Líneas de la cuadrícula
        paint.reset()
        paint.isAntiAlias = true
        paint.color = if (isRetro) Color.parseColor("#306230") else Color.WHITE
        paint.alpha = if (isRetro) 30 else 12
        paint.strokeWidth = 1f
        for (x in 0..cols) canvas.drawLine(x * cellSize, 0f, x * cellSize, canvas.height.toFloat(), paint)
        for (y in 0..rows) canvas.drawLine(0f, y * cellSize, canvas.width.toFloat(), y * cellSize, paint)

        // Bloques ya fijados
        for (y in 0 until rows) {
            for (x in 0 until cols) {
                if (grid[y][x] != 0) drawBlock(canvas, x, y, grid[y][x], style)
            }
        }

        // Pieza actual cayendo
        val shape = shapes[currentPieceType][currentRotation % shapes[currentPieceType].size]
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0) drawBlock(canvas, currentPieceX + x, currentPieceY + y, currentPieceType + 1, style, true)
            }
        }
    }

    private fun drawBlock(canvas: Canvas, x: Int, y: Int, colorIndex: Int, style: String, isCurrent: Boolean = false) {
        val colors = when(style) {
            "retro" -> intArrayOf(
                Color.TRANSPARENT,
                Color.parseColor("#9BBC0F"), Color.parseColor("#8BAC0F"),
                Color.parseColor("#306230"), Color.parseColor("#0F380F"),
                Color.parseColor("#8BAC0F"), Color.parseColor("#306230"),
                Color.parseColor("#9BBC0F")
            )
            "pastel" -> intArrayOf(
                Color.TRANSPARENT,
                Color.parseColor("#FFB7B2"), Color.parseColor("#FFDAC1"),
                Color.parseColor("#E2F0CB"), Color.parseColor("#B5EAD7"),
                Color.parseColor("#C7CEEA"), Color.parseColor("#FFC6FF"),
                Color.parseColor("#FF9AA2")
            )
            else -> intArrayOf( // neon and outline
                Color.TRANSPARENT,
                Color.parseColor("#00F0F0"), Color.parseColor("#3B82F6"),
                Color.parseColor("#F59E0B"), Color.parseColor("#FBBF24"),
                Color.parseColor("#10B981"), Color.parseColor("#8B5CF6"),
                Color.parseColor("#EF4444")
            )
        }
        
        val color = colors[colorIndex.coerceIn(0, colors.size - 1)]
        val left = x * cellSize + 2.5f
        val top = y * cellSize + 2.5f
        val right = (x + 1) * cellSize - 2.5f
        val bottom = (y + 1) * cellSize - 2.5f
        
        paint.reset()
        paint.isAntiAlias = true
        
        when(style) {
            "retro" -> {
                // Gameboy clásico: bloques planos con bordes oscuros
                paint.color = color
                paint.style = Paint.Style.FILL
                canvas.drawRect(left, top, right, bottom, paint)
                
                paint.color = Color.parseColor("#0F380F")
                paint.style = Paint.Style.STROKE
                paint.strokeWidth = 2.5f
                canvas.drawRect(left, top, right, bottom, paint)
            }
            "pastel" -> {
                // Pastel Minimal: bloques suaves muy redondeados
                paint.color = color
                paint.style = Paint.Style.FILL
                canvas.drawRoundRect(RectF(left, top, right, bottom), 8f, 8f, paint)
            }
            "outline" -> {
                // Cyberpunk Outline: solo bordes de neón resplandecientes
                paint.color = color
                paint.style = Paint.Style.STROKE
                paint.strokeWidth = 3.5f
                if (isCurrent) paint.setShadowLayer(10f, 0f, 0f, color)
                canvas.drawRoundRect(RectF(left + 2, top + 2, right - 2, bottom - 2), 6f, 6f, paint)
                paint.clearShadowLayer()
            }
            else -> {
                // Neon Glow: bloques con brillo de neón y relieve superior blanco
                paint.color = color
                paint.style = Paint.Style.FILL
                if (isCurrent) paint.setShadowLayer(14f, 0f, 0f, color)
                canvas.drawRoundRect(RectF(left, top, right, bottom), 10f, 10f, paint)
                paint.clearShadowLayer()
                
                paint.color = Color.WHITE
                paint.alpha = 50
                canvas.drawRoundRect(RectF(left + 2, top + 2, right - 2, top + 8), 3f, 3f, paint)
            }
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

package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.view.Choreographer
import android.view.SurfaceHolder
import kotlin.random.Random

class TetrisWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private var currentHolder: SurfaceHolder? = null
    private var isVisible = false
    private val paint = Paint().apply { isAntiAlias = true }
    
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
    private val dropInterval = 200L // Más fluido
    
    private val colors = intArrayOf(
        Color.TRANSPARENT,
        Color.parseColor("#00F0F0"), // I
        Color.parseColor("#0000F0"), // J
        Color.parseColor("#F0A000"), // L
        Color.parseColor("#F0F000"), // O
        Color.parseColor("#00F000"), // S
        Color.parseColor("#A000F0"), // T
        Color.parseColor("#F00000")  // Z
    )

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

    /**
     * IA AVANZADA: Simula todas las rotaciones y posiciones para encontrar la mejor jugada.
     */
    private fun thinkBestMove() {
        var bestScore = -1000000.0
        var bestX = currentPieceX
        var bestRot = 0

        val rotations = shapes[currentPieceType].size
        for (r in 0 until rotations) {
            val shape = shapes[currentPieceType][r]
            val pieceW = shape[0].size
            
            for (x in 0..(cols - pieceW)) {
                // Simular caída
                var y = 0
                while (!checkCollision(x, y + 1, r)) {
                    y++
                }
                
                // Calcular puntuación de este estado futuro
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
        // Clonar grid para simular
        val tempGrid = Array(rows) { grid[it].copyOf() }
        val shape = shapes[currentPieceType][pr]
        
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0 && (py + y) < rows) {
                    tempGrid[py + y][px + x] = 1
                }
            }
        }

        // Heurísticas
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

        // Formula de Dellacherie (ajustada)
        return (-0.51 * aggregateHeight) + (0.76 * completeLines) + (-0.35 * holes) + (-0.18 * bumpiness)
    }

    private fun updateLogic() {
        val now = System.currentTimeMillis()
        if (now - lastUpdate > dropInterval) {
            // Rotar hacia el objetivo
            if (currentRotation != targetRotation) {
                currentRotation = targetRotation
            }

            // Mover horizontalmente
            if (currentPieceX < targetX) currentPieceX++
            else if (currentPieceX > targetX) currentPieceX--

            // Caer
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
        val bgPaint = Paint().apply {
            shader = LinearGradient(0f, 0f, 0f, canvas.height.toFloat(), 
                Color.parseColor("#0A0A14"), Color.parseColor("#141428"), Shader.TileMode.CLAMP)
        }
        canvas.drawRect(0f, 0f, canvas.width.toFloat(), canvas.height.toFloat(), bgPaint)

        paint.color = Color.WHITE
        paint.alpha = 15
        for (x in 0..cols) canvas.drawLine(x * cellSize, 0f, x * cellSize, canvas.height.toFloat(), paint)
        for (y in 0..rows) canvas.drawLine(0f, y * cellSize, canvas.width.toFloat(), y * cellSize, paint)

        for (y in 0 until rows) {
            for (x in 0 until cols) {
                if (grid[y][x] != 0) drawBlock(canvas, x, y, colors[grid[y][x]])
            }
        }

        val shape = shapes[currentPieceType][currentRotation % shapes[currentPieceType].size]
        for (y in shape.indices) {
            for (x in shape[y].indices) {
                if (shape[y][x] != 0) drawBlock(canvas, currentPieceX + x, currentPieceY + y, colors[currentPieceType + 1], true)
            }
        }
    }

    private fun drawBlock(canvas: Canvas, x: Int, y: Int, color: Int, isCurrent: Boolean = false) {
        val left = x * cellSize + 4
        val top = y * cellSize + 4
        val right = (x + 1) * cellSize - 4
        val bottom = (y + 1) * cellSize - 4
        
        paint.reset()
        paint.isAntiAlias = true
        paint.color = color
        if (isCurrent) paint.setShadowLayer(15f, 0f, 0f, color)
        canvas.drawRoundRect(RectF(left, top, right, bottom), 12f, 12f, paint)
        paint.clearShadowLayer()

        paint.color = Color.WHITE
        paint.alpha = 60
        canvas.drawRoundRect(RectF(left + 2, top + 2, right - 2, top + 10), 4f, 4f, paint)
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

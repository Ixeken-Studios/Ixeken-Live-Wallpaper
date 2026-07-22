package com.ixeken.gakuu.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.MotionEvent
import android.view.SurfaceHolder
import kotlin.random.Random

class ConwayWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {
    
    private val paint = Paint().apply { isAntiAlias = true }
    
    private val cols = 36
    private var rows = 64
    private var cellSize = 0f
    
    private var grid = Array(rows) { BooleanArray(cols) { false } }
    private var nextGrid = Array(rows) { BooleanArray(cols) { false } }
    
    private var lastUpdate = 0L
    private val updateInterval = 220L
    private var stagnancyCounter = 0
    private var previousHash = 0

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        resetGrid(holder.surfaceFrame.width(), holder.surfaceFrame.height())
        reseedGrid()
    }

    private fun resetGrid(width: Int, height: Int) {
        cellSize = width.toFloat() / cols.toFloat()
        rows = (height / cellSize).toInt()
        grid = Array(rows) { BooleanArray(cols) { false } }
        nextGrid = Array(rows) { BooleanArray(cols) { false } }
    }

    private fun reseedGrid() {
        for (y in 0 until rows) {
            for (x in 0 until cols) {
                grid[y][x] = Random.nextFloat() < 0.22f // 22% inicial de células vivas
            }
        }
        stagnancyCounter = 0
    }

    override fun onUpdatePhysics() {
        val now = System.currentTimeMillis()
        if (now - lastUpdate >= updateInterval) {
            updateLogic()
            lastUpdate = now
        }
    }

    private fun updateLogic() {
        var aliveCount = 0
        var currentHash = 0
        
        for (y in 0 until rows) {
            for (x in 0 until cols) {
                val neighbors = countNeighbors(x, y)
                val isAlive = grid[y][x]
                
                nextGrid[y][x] = if (isAlive) {
                    neighbors == 2 || neighbors == 3
                } else {
                    neighbors == 3
                }
                
                if (nextGrid[y][x]) {
                    aliveCount++
                    currentHash += (x + 1) * (y + 1)
                }
            }
        }
        
        // Intercambiar matrices
        val temp = grid
        grid = nextGrid
        nextGrid = temp
        
        // Detección de tablero vacío o estancado
        if (aliveCount == 0) {
            reseedGrid()
        } else if (currentHash == previousHash) {
            stagnancyCounter++
            if (stagnancyCounter > 15) { // Estancado demasiado tiempo
                reseedGrid()
            }
        } else {
            stagnancyCounter = 0
        }
        previousHash = currentHash
    }

    private fun countNeighbors(x: Int, y: Int): Int {
        var count = 0
        for (dy in -1..1) {
            for (dx in -1..1) {
                if (dx == 0 && dy == 0) continue
                // Bordes toroidales (efecto dona infinito)
                val nx = (x + dx + cols) % cols
                val ny = (y + dy + rows) % rows
                if (grid[ny][nx]) count++
            }
        }
        return count
    }

    override fun onDraw(canvas: Canvas) {
        // Limpiar lienzo negro estilo matriz de datos cibernética
        canvas.drawColor(Color.parseColor("#090712"))
        
        // Células de neón cian
        paint.reset()
        paint.isAntiAlias = true
        paint.color = Color.parseColor("#00FFCC") // Cian neón
        paint.style = Paint.Style.FILL
        paint.setShadowLayer(8f, 0f, 0f, Color.parseColor("#00FFCC"))
        
        for (y in 0 until rows) {
            for (x in 0 until cols) {
                if (grid[y][x]) {
                    val rect = RectF(
                        x * cellSize + 2f,
                        y * cellSize + 2f,
                        (x + 1) * cellSize - 2f,
                        (y + 1) * cellSize - 2f
                    )
                    canvas.drawRoundRect(rect, 4f, 4f, paint)
                }
            }
        }
        paint.clearShadowLayer()
    }

    override fun onTouchEvent(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_DOWN || event.action == MotionEvent.ACTION_MOVE) {
            val gx = (event.x / cellSize).toInt().coerceIn(0, cols - 1)
            val gy = (event.y / cellSize).toInt().coerceIn(0, rows - 1)
            
            // Sembrar un Planeador/Deslizador (Glider) al tocar
            spawnGlider(gx, gy)
        }
    }

    private fun spawnGlider(cx: Int, cy: Int) {
        val gliderOffsets = arrayOf(
            Pair(0, -1),
            Pair(1, 0),
            Pair(-1, 1),
            Pair(0, 1),
            Pair(1, 1)
        )
        for (offset in gliderOffsets) {
            val nx = (cx + offset.first + cols) % cols
            val ny = (cy + offset.second + rows) % rows
            grid[ny][nx] = true
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        super.onSurfaceChanged(holder, format, width, height)
        resetGrid(width, height)
        reseedGrid()
    }
}

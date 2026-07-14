package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.*
import android.view.SurfaceHolder
import java.io.File

class PatternWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private val paint = Paint().apply {
        isAntiAlias = true
        color = Color.WHITE
        strokeWidth = 4f
        style = Paint.Style.STROKE
    }

    private var layoutSize = 2 // 1, 2, 3
    private var slotIcons = listOf("circle", "star", "heart", "cross")
    private var cellSize = 120f
    private var speed = 2f
    private var rotateEnabled = true

    private var offsetX = 0f
    private var offsetY = 0f
    private var rotationAngle = 0f

    private val bitmapCache = mutableMapOf<String, Bitmap>()

    override fun onCreate(holder: SurfaceHolder) {
        super.onCreate(holder)
        loadSettings()
    }

    private fun loadSettings() {
        layoutSize = prefs.getInt("pattern_layout_size", 2)
        val defaultSlots = when (layoutSize) {
            1 -> "heart"
            3 -> "circle,star,heart,cross,triangle,square,star,heart,circle"
            else -> "circle,star,heart,cross"
        }
        val slotsStr = prefs.getString("pattern_slot_icons", defaultSlots) ?: defaultSlots
        slotIcons = slotsStr.split(",")

        val density = prefs.getString("pattern_density", "medium") ?: "medium"
        cellSize = when (density) {
            "small" -> 80f
            "large" -> 180f
            else -> 120f
        }

        speed = prefs.getInt("pattern_speed", 2).toFloat()
        rotateEnabled = prefs.getBoolean("pattern_rotate", true)

        // Clear cache and pre-decode bitmaps on this thread safely
        bitmapCache.clear()
        for (icon in slotIcons) {
            if (icon.isNotEmpty() && !isGenericShape(icon)) {
                loadBitmap(icon)
            }
        }
    }

    private fun isGenericShape(icon: String): Boolean {
        return icon == "circle" || icon == "square" || icon == "triangle" || 
               icon == "cross" || icon == "star" || icon == "heart"
    }

    private fun loadBitmap(path: String): Bitmap? {
        if (bitmapCache.containsKey(path)) return bitmapCache[path]
        return try {
            val file = File(path)
            if (file.exists()) {
                val bitmap = BitmapFactory.decodeFile(path)
                if (bitmap != null) {
                    val w = bitmap.width
                    val h = bitmap.height
                    val maxDim = 128f
                    val scale = if (w > h) maxDim / w else maxDim / h
                    val targetW = (w * scale).toInt().coerceAtLeast(1)
                    val targetH = (h * scale).toInt().coerceAtLeast(1)
                    val scaled = Bitmap.createScaledBitmap(bitmap, targetW, targetH, true)
                    bitmapCache[path] = scaled
                    scaled
                } else null
            } else null
        } catch (e: Exception) {
            null
        }
    }

    override fun onUpdatePhysics() {
        val step = speed * 0.5f
        offsetX = (offsetX + step) % (cellSize * layoutSize)
        offsetY = (offsetY + step) % (cellSize * layoutSize)

        if (rotateEnabled) {
            rotationAngle = (rotationAngle + 1f) % 360f
        }
    }

    override fun onDraw(canvas: Canvas) {
        // Draw background color
        canvas.drawColor(Color.parseColor("#0F0F1B"))

        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        val cols = (w / cellSize).toInt() + 2
        val rows = (h / cellSize).toInt() + 2

        paint.color = Color.WHITE
        paint.alpha = 77 // ~30% transparency

        for (c in (-layoutSize - 1)..cols) {
            for (r in (-layoutSize - 1)..rows) {
                val px = c * cellSize + offsetX
                val py = r * cellSize + offsetY

                // Grid slot index determination (wrapping layout index)
                val gridCol = ((c % layoutSize) + layoutSize) % layoutSize
                val gridRow = ((r % layoutSize) + layoutSize) % layoutSize
                val slotIndex = gridRow * layoutSize + gridCol

                if (slotIndex >= 0 && slotIndex < slotIcons.size) {
                    val iconKey = slotIcons[slotIndex]
                    val cx = px + cellSize / 2f
                    val cy = py + cellSize / 2f

                    canvas.save()
                    if (rotateEnabled) {
                        canvas.translate(cx, cy)
                        canvas.rotate(rotationAngle)
                        canvas.translate(-cx, -cy)
                    }

                    drawSlot(canvas, iconKey, cx, cy, cellSize * 0.5f)
                    canvas.restore()
                }
            }
        }
    }

    private fun drawSlot(canvas: Canvas, iconKey: String, cx: Float, cy: Float, size: Float) {
        val cached = bitmapCache[iconKey]
        if (cached != null) {
            val imgW = cached.width.toFloat()
            val imgH = cached.height.toFloat()
            val imgAspect = imgW / imgH
            var destW = size
            var destH = size
            if (imgAspect > 1f) {
                destH = size / imgAspect
            } else {
                destW = size * imgAspect
            }
            val rect = RectF(cx - destW / 2f, cy - destH / 2f, cx + destW / 2f, cy + destH / 2f)
            val bmpPaint = Paint().apply { isAntiAlias = true }
            canvas.drawBitmap(cached, null, rect, bmpPaint)
        } else {
            // Draw generic shape fallback
            drawGeometricShape(canvas, iconKey, cx, cy, size, paint)
        }
    }

    private fun drawGeometricShape(canvas: Canvas, shape: String, cx: Float, cy: Float, size: Float, p: Paint) {
        p.style = Paint.Style.STROKE
        p.strokeWidth = size * 0.1f
        when (shape) {
            "circle" -> canvas.drawCircle(cx, cy, size * 0.4f, p)
            "square" -> canvas.drawRect(cx - size * 0.35f, cy - size * 0.35f, cx + size * 0.35f, cy + size * 0.35f, p)
            "triangle" -> {
                val path = Path().apply {
                    moveTo(cx, cy - size * 0.4f)
                    lineTo(cx + size * 0.4f, cy + size * 0.4f)
                    lineTo(cx - size * 0.4f, cy + size * 0.4f)
                    close()
                }
                canvas.drawPath(path, p)
            }
            "cross" -> {
                canvas.drawLine(cx - size * 0.3f, cy, cx + size * 0.3f, cy, p)
                canvas.drawLine(cx, cy - size * 0.3f, cx, cy + size * 0.3f, p)
            }
            "star" -> {
                val path = Path()
                val innerR = size * 0.15f
                val outerR = size * 0.4f
                for (i in 0 until 10) {
                    val angle = (i * 36f - 90f) * Math.PI.toFloat() / 180f
                    val r = if (i % 2 == 0) outerR else innerR
                    val x = cx + r * Math.cos(angle.toDouble()).toFloat()
                    val y = cy + r * Math.sin(angle.toDouble()).toFloat()
                    if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                }
                path.close()
                canvas.drawPath(path, p)
            }
            "heart" -> {
                val path = Path()
                val w = size * 0.8f
                val h = size * 0.8f
                path.moveTo(cx, cy + h * 0.35f)
                path.cubicTo(
                    cx - w * 0.5f, cy - h * 0.25f,
                    cx - w * 0.5f, cy - h * 0.7f,
                    cx, cy - h * 0.3f
                )
                path.cubicTo(
                    cx + w * 0.5f, cy - h * 0.7f,
                    cx + w * 0.5f, cy - h * 0.25f,
                    cx, cy + h * 0.35f
                )
                path.close()
                canvas.drawPath(path, p)
            }
            else -> {
                canvas.drawCircle(cx, cy, size * 0.4f, p)
            }
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        super.onSurfaceChanged(holder, format, width, height)
        loadSettings()
    }
}

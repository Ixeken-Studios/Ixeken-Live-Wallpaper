package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.MotionEvent
import kotlin.math.cos
import kotlin.math.sin

class JuliaWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {

    private var juliaCx = -0.7f
    private var juliaCy = 0.27015f
    private var time = 0f

    private val paint = Paint().apply { style = Paint.Style.FILL }
    private val rect = RectF()

    override val frameIntervalMs = 33L // ~30 FPS

    override fun onUpdatePhysics() {
        time += 0.03f
        // Automatic complex constant morphing
        juliaCx = -0.7f + 0.12f * sin(time)
        juliaCy = 0.27015f + 0.08f * cos(time * 2.0f)
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()

        canvas.drawColor(Color.parseColor("#040209"))

        val cols = 45
        val rows = 80
        val cellW = w / cols
        val cellH = h / rows

        val cReal = juliaCx
        val cImag = juliaCy

        val colorScheme = prefs.getString("julia_color_scheme", "cosmic") ?: "cosmic"

        for (y in 0 until rows) {
            val zImagStart = 3.0f * (y.toFloat() / rows) - 1.5f
            for (x in 0 until cols) {
                val zRealStart = 2.0f * (x.toFloat() / cols) - 1.0f

                var zReal = zRealStart
                var zImag = zImagStart
                var iter = 0
                val maxIter = 15

                while (iter < maxIter) {
                    val tempReal = zReal * zReal - zImag * zImag + cReal
                    val tempImag = 2.0f * zReal * zImag + cImag
                    zReal = tempReal
                    zImag = tempImag

                    if (zReal * zReal + zImag * zImag > 4.0f) {
                        break
                    }
                    iter++
                }

                if (iter > 0) {
                    val intensity = iter.toFloat() / maxIter
                    val pulse = sin(time * 0.8f) * 0.08f
                    val finalIntensity = (intensity + pulse).coerceIn(0f, 1f)

                    val color = when (colorScheme) {
                        "fire" -> {
                            if (finalIntensity < 0.25f) {
                                val factor = finalIntensity / 0.25f
                                val r = (45 * (1f - factor) + 185 * factor).toInt()
                                val g = (2 * (1f - factor) + 28 * factor).toInt()
                                val b = (2 * (1f - factor) + 28 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else if (finalIntensity < 0.65f) {
                                val factor = (finalIntensity - 0.25f) / 0.40f
                                val r = (185 * (1f - factor) + 234 * factor).toInt()
                                val g = (28 * (1f - factor) + 88 * factor).toInt()
                                val b = (28 * (1f - factor) + 12 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else {
                                val factor = (finalIntensity - 0.65f) / 0.35f
                                val r = (234 * (1f - factor) + 250 * factor).toInt()
                                val g = (88 * (1f - factor) + 204 * factor).toInt()
                                val b = (12 * (1f - factor) + 21 * factor).toInt()
                                Color.rgb(r, g, b)
                            }
                        }
                        "matrix" -> {
                            if (finalIntensity < 0.25f) {
                                val factor = finalIntensity / 0.25f
                                val r = (2 * (1f - factor) + 21 * factor).toInt()
                                val g = (44 * (1f - factor) + 128 * factor).toInt()
                                val b = (34 * (1f - factor) + 61 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else if (finalIntensity < 0.65f) {
                                val factor = (finalIntensity - 0.25f) / 0.40f
                                val r = (21 * (1f - factor) + 34 * factor).toInt()
                                val g = (128 * (1f - factor) + 197 * factor).toInt()
                                val b = (61 * (1f - factor) + 94 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else {
                                val factor = (finalIntensity - 0.65f) / 0.35f
                                val r = (34 * (1f - factor) + 134 * factor).toInt()
                                val g = (197 * (1f - factor) + 239 * factor).toInt()
                                val b = (94 * (1f - factor) + 172 * factor).toInt()
                                Color.rgb(r, g, b)
                            }
                        }
                        "ocean" -> {
                            if (finalIntensity < 0.25f) {
                                val factor = finalIntensity / 0.25f
                                val r = (15 * (1f - factor) + 29 * factor).toInt()
                                val g = (23 * (1f - factor) + 78 * factor).toInt()
                                val b = (42 * (1f - factor) + 216 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else if (finalIntensity < 0.65f) {
                                val factor = (finalIntensity - 0.25f) / 0.40f
                                val r = (29 * (1f - factor) + 13 * factor).toInt()
                                val g = (78 * (1f - factor) + 148 * factor).toInt()
                                val b = (216 * (1f - factor) + 136 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else {
                                val factor = (finalIntensity - 0.65f) / 0.35f
                                val r = (13 * (1f - factor) + 56 * factor).toInt()
                                val g = (148 * (1f - factor) + 189 * factor).toInt()
                                val b = (136 * (1f - factor) + 248 * factor).toInt()
                                Color.rgb(r, g, b)
                            }
                        }
                        "cosmic" -> {
                            if (finalIntensity < 0.25f) {
                                val factor = finalIntensity / 0.25f
                                val r = (15 * (1f - factor) + 91 * factor).toInt()
                                val g = (11 * (1f - factor) + 33 * factor).toInt()
                                val b = (38 * (1f - factor) + 182 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else if (finalIntensity < 0.65f) {
                                val factor = (finalIntensity - 0.25f) / 0.40f
                                val r = (91 * (1f - factor) + 236 * factor).toInt()
                                val g = (33 * (1f - factor) + 72 * factor).toInt()
                                val b = (182 * (1f - factor) + 153 * factor).toInt()
                                Color.rgb(r, g, b)
                            } else {
                                val factor = (finalIntensity - 0.65f) / 0.35f
                                val r = (236 * (1f - factor) + 6 * factor).toInt()
                                val g = (72 * (1f - factor) + 182 * factor).toInt()
                                val b = (153 * (1f - factor) + 212 * factor).toInt()
                                Color.rgb(r, g, b)
                            }
                        }
                        else -> {
                            Color.WHITE
                        }
                    }

                    paint.color = color
                    paint.alpha = (finalIntensity * 242).toInt().coerceIn(0, 255)

                    rect.set(x * cellW, y * cellH, (x + 1) * cellW + 0.5f, (y + 1) * cellH + 0.5f)
                    canvas.drawRect(rect, paint)
                }
            }
        }
    }

    override fun onTouchEvent(event: MotionEvent) {
        // Automatic updates only
    }
}

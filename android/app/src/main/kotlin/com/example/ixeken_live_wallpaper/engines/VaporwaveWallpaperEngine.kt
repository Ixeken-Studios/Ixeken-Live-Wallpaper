package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import kotlin.math.pow

class VaporwaveWallpaperEngine(context: Context) : BaseWallpaperEngine(context) {
    
    private var time = 0f
    private val paint = Paint().apply { isAntiAlias = true }
    
    override fun onUpdatePhysics() {
        time += 0.015f
    }

    override fun onDraw(canvas: Canvas) {
        val w = canvas.width.toFloat()
        val h = canvas.height.toFloat()
        val horizon = h * 0.48f
        
        // 1. Dibujar cielo degradado (Cyberpunk Sunset)
        val skyPaint = Paint().apply {
            shader = LinearGradient(0f, 0f, 0f, horizon,
                intArrayOf(Color.parseColor("#1D0030"), Color.parseColor("#A80077"), Color.parseColor("#FF5E62")),
                null, Shader.TileMode.CLAMP)
        }
        canvas.drawRect(0f, 0f, w, horizon, skyPaint)

        // 2. Dibujar sol de neón con franjas retro
        val sunRadius = w * 0.28f
        val sunCx = w / 2f
        val sunCy = horizon - 50f
        
        canvas.save()
        // Clip circular para el sol
        canvas.clipRect(sunCx - sunRadius, sunCy - sunRadius, sunCx + sunRadius, sunCy + sunRadius)
        
        val sunPaint = Paint().apply {
            isAntiAlias = true
            shader = LinearGradient(0f, sunCy - sunRadius, 0f, sunCy + sunRadius,
                intArrayOf(Color.parseColor("#FFD97D"), Color.parseColor("#FF1493")),
                null, Shader.TileMode.CLAMP)
        }
        canvas.drawCircle(sunCx, sunCy, sunRadius, sunPaint)
        
        // Dibujar las franjas negras típicas retro (cortes horizontales)
        val stripePaint = Paint().apply { color = Color.parseColor("#A80077") }
        var stripeY = sunCy + 20f
        var stripeHeight = 6f
        while (stripeY < sunCy + sunRadius) {
            canvas.drawRect(sunCx - sunRadius, stripeY, sunCx + sunRadius, stripeY + stripeHeight, stripePaint)
            stripeY += stripeHeight + 12f
            stripeHeight += 4f // Franjas más gruesas conforme bajan
        }
        canvas.restore()

        // 3. Dibujar suelo degradado oscuro
        val groundPaint = Paint().apply {
            shader = LinearGradient(0f, horizon, 0f, h,
                intArrayOf(Color.parseColor("#090014"), Color.parseColor("#000000")),
                null, Shader.TileMode.CLAMP)
        }
        canvas.drawRect(0f, horizon, w, h, groundPaint)

        // 4. Dibujar Rejilla 3D (Grid)
        paint.reset()
        paint.isAntiAlias = true
        paint.color = Color.parseColor("#FF007F") // Rosa neón
        paint.strokeWidth = 2.5f
        paint.style = Paint.Style.STROKE
        
        // Líneas radiales en perspectiva desde el horizonte
        val numVerticalLines = 14
        for (i in 0..numVerticalLines) {
            val ratio = i.toFloat() / numVerticalLines.toFloat()
            // Posición final abajo de la pantalla
            val targetX = (ratio - 0.5f) * w * 3f + (w / 2f)
            canvas.drawLine(w / 2f, horizon, targetX, h, paint)
        }
        
        // Líneas horizontales con perspectiva exponencial móvil
        val gridPhase = (time * 0.8f) % 1.0f
        val groundHeight = h - horizon
        
        val numHorizontalLines = 12
        for (i in 0..numHorizontalLines) {
            val progress = (i.toFloat() - gridPhase) / numHorizontalLines.toFloat()
            if (progress < 0) continue
            
            // Usamos una función cuadrática para que el espaciado aumente rápidamente al acercarse
            val expProgress = progress.pow(2.4f)
            val gridY = horizon + expProgress * groundHeight
            
            // Atenuación de opacidad (niebla vaporwave) al acercarse al horizonte
            paint.alpha = (progress * 255).toInt().coerceIn(0, 255)
            // Grosor de línea más delgado al fondo y grueso al frente
            paint.strokeWidth = progress * 3.5f + 0.5f
            
            canvas.drawLine(0f, gridY, w, gridY, paint)
        }
    }
}

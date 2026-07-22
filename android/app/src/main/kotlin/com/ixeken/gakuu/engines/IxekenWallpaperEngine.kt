package com.ixeken.gakuu.engines

import android.graphics.Canvas
import android.view.SurfaceHolder

/**
 * Interfaz base para cualquier nuevo fondo animado.
 * Implementar esta clase permite añadir nuevos fondos de forma modular.
 */
interface IxekenWallpaperEngine {
    /** Se llama cuando el motor se crea o se activa */
    fun onCreate(holder: SurfaceHolder)
    
    /** Lógica de dibujo en el canvas */
    fun onDraw(canvas: Canvas)
    
    /** Control de ciclo de vida (pantalla encendida/apagada) */
    fun onVisibilityChanged(visible: Boolean)
    
    /** Se llama cuando el tamaño de la superficie cambia */
    fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int)
    
    /** Limpieza de recursos (Bitmaps, MediaPlayer, etc.) */
    fun onDestroy()
    
    /** (Opcional) Manejo de toques en la pantalla */
    fun onTouchEvent(event: android.view.MotionEvent) {}

    /** (Opcional) Liberación de memoria bajo presión del sistema */
    fun onTrimMemory(level: Int) {}

    /** (Opcional) Vinculación del host del motor */
    fun setEngineHost(host: android.service.wallpaper.WallpaperService.Engine) {}
}

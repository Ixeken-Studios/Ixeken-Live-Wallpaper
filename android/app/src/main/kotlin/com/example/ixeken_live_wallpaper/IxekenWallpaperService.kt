package com.example.ixeken_live_wallpaper

import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import android.content.Context
import android.os.Build
import android.view.Choreographer
import java.util.Calendar
import kotlin.concurrent.thread

class IxekenWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine {
        return IxekenEngine()
    }

    inner class IxekenEngine : Engine() {
        private var mediaPlayer: MediaPlayer? = null
        private var isVideo = false
        private var currentMediaPath: String? = null
        
        private var currentBitmap: Bitmap? = null
        private var previousBitmap: Bitmap? = null
        private var nextPreloadedBitmap: Bitmap? = null
        
        private var fadeAlpha = 255
        private var isAnimating = false
        private val mainHandler = Handler(Looper.getMainLooper())
        private val paint = Paint().apply { 
            isFilterBitmap = true
            isDither = true
        }
        
        // Filtro para oscurecimiento (Dim)
        private val dimPaint = Paint().apply {
            colorFilter = PorterDuffColorFilter(Color.argb(100, 0, 0, 0), PorterDuff.Mode.SRC_ATOP)
        }

        private val prefs: SharedPreferences = getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        private var playlist: List<String> = emptyList()
        private var currentIndex = -1

        private val frameCallback = object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                if (isAnimating) {
                    fadeAlpha += 42 
                    if (fadeAlpha >= 255) {
                        fadeAlpha = 255
                        isAnimating = false
                        drawFrame()
                        previousBitmap?.recycle()
                        previousBitmap = null
                    } else {
                        drawFrame()
                        Choreographer.getInstance().postFrameCallback(this)
                    }
                }
            }
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            updateCurrentPlaylist()
            preloadNext()
        }

        private fun updateCurrentPlaylist() {
            val useDayNight = prefs.getBoolean("useDayNightMode", false)
            val key = if (useDayNight) {
                if (isDayTime()) "playlist_day" else "playlist_night"
            } else {
                "playlist"
            }
            
            val savedList = prefs.getString(key, "")
            val newList = if (!savedList.isNullOrEmpty()) savedList.split("||") else emptyList()
            
            // Si la playlist cambió drásticamente, resetear índice
            if (newList != playlist) {
                playlist = newList
                currentIndex = -1 
            }
        }

        private fun isDayTime(): Boolean {
            val now = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val start = prefs.getInt("dayStartHour", 6)
            val end = prefs.getInt("nightStartHour", 18)
            return if (start < end) {
                now in start until end
            } else {
                now >= start || now < end
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            
            if (visible) {
                updateCurrentPlaylist()
                drawFrame()
                if (isVideo) mediaPlayer?.start()
            } else {
                // El cambio ocurre siempre al apagar la pantalla por petición del usuario
                applyRotation()
                if (isVideo) mediaPlayer?.pause()
            }
        }

        private fun applyRotation() {
            if (playlist.isEmpty()) return
            
            currentIndex = (currentIndex + 1) % playlist.size
            val nextPath = playlist[currentIndex]
            val nextIsVideo = nextPath.endsWith(".mp4") || nextPath.endsWith(".mkv")

            if (nextIsVideo) {
                currentMediaPath = nextPath
                isVideo = true
                clearBitmaps()
                setupMediaPlayer()
            } else {
                isVideo = false
                releaseMediaPlayer()
                
                previousBitmap = currentBitmap
                if (nextPreloadedBitmap != null && currentMediaPath == nextPath) {
                    currentBitmap = nextPreloadedBitmap
                    nextPreloadedBitmap = null
                    startFadeAnimation()
                } else {
                    currentMediaPath = nextPath
                    thread {
                        val bitmap = loadAndScaleBitmap(currentMediaPath)
                        mainHandler.post {
                            currentBitmap = bitmap
                            startFadeAnimation()
                        }
                    }
                }
                preloadNext()
            }
        }

        private fun clearBitmaps() {
            previousBitmap?.recycle()
            previousBitmap = null
            currentBitmap?.recycle()
            currentBitmap = null
            nextPreloadedBitmap?.recycle()
            nextPreloadedBitmap = null
        }

        private fun startFadeAnimation() {
            if (previousBitmap != null && currentBitmap != null) {
                fadeAlpha = 0
                isAnimating = true
                Choreographer.getInstance().removeFrameCallback(frameCallback)
                Choreographer.getInstance().postFrameCallback(frameCallback)
            } else {
                fadeAlpha = 255
                isAnimating = false
                drawFrame()
            }
        }

        private fun preloadNext() {
            if (playlist.isEmpty()) return
            val peekIndex = (currentIndex + 1) % playlist.size
            val peekPath = playlist[peekIndex]
            
            if (!peekPath.endsWith(".mp4") && !peekPath.endsWith(".mkv")) {
                thread {
                    val bitmap = loadAndScaleBitmap(peekPath)
                    mainHandler.post {
                        if (nextPreloadedBitmap != bitmap) {
                            nextPreloadedBitmap?.recycle()
                            nextPreloadedBitmap = bitmap
                        }
                    }
                }
            }
        }

        private fun loadAndScaleBitmap(path: String?): Bitmap? {
            if (path == null) return null
            try {
                val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(path, options)
                
                val frame = surfaceHolder.surfaceFrame
                val targetW = if (frame.width() > 0) frame.width() else 1080
                val targetH = if (frame.height() > 0) frame.height() else 1920

                options.inSampleSize = calculateInSampleSize(options, targetW, targetH)
                options.inJustDecodeBounds = false
                options.inPreferredConfig = Bitmap.Config.ARGB_8888 
                
                val decoded = BitmapFactory.decodeFile(path, options) ?: return null
                return createCenterCropBitmap(decoded, targetW, targetH)
            } catch (e: Exception) {
                return null
            }
        }

        private fun createCenterCropBitmap(src: Bitmap, width: Int, height: Int): Bitmap {
            val srcWidth = src.width
            val srcHeight = src.height
            val scale = Math.max(width.toFloat() / srcWidth, height.toFloat() / srcHeight)
            val newWidth = (srcWidth * scale).toInt()
            val newHeight = (srcHeight * scale).toInt()
            
            val result = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(result)
            val x = (width - newWidth) / 2f
            val y = (height - newHeight) / 2f
            
            val p = Paint().apply { isFilterBitmap = true }
            canvas.drawBitmap(src, null, android.graphics.RectF(x, y, x + newWidth, y + newHeight), p)
            
            src.recycle()
            return result
        }

        private fun setupMediaPlayer() {
            releaseMediaPlayer()
            try {
                mediaPlayer = MediaPlayer().apply {
                    setDataSource(currentMediaPath)
                    setSurface(surfaceHolder.surface)
                    isLooping = true
                    setVolume(0f, 0f)
                    prepare()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun releaseMediaPlayer() {
            mediaPlayer?.apply {
                if (isPlaying) stop()
                release()
            }
            mediaPlayer = null
        }

        private fun drawFrame() {
            val holder = surfaceHolder
            val canvas: Canvas? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                holder.lockHardwareCanvas()
            } else {
                holder.lockCanvas()
            }
            
            if (canvas == null) return
            
            val isDimEnabled = prefs.getBoolean("isDimEnabled", false)

            try {
                if (!isVideo) {
                    if (isAnimating && previousBitmap != null) {
                        paint.alpha = 255
                        canvas.drawBitmap(previousBitmap!!, 0f, 0f, paint)
                        paint.alpha = fadeAlpha
                        canvas.drawBitmap(currentBitmap!!, 0f, 0f, paint)
                    } else if (currentBitmap != null) {
                        paint.alpha = 255
                        canvas.drawBitmap(currentBitmap!!, 0f, 0f, paint)
                    }
                    
                    // Aplicar efecto de oscurecimiento si está activo
                    if (isDimEnabled) {
                        // Dibujar una capa negra translúcida sobre el fondo (40% de opacidad)
                        canvas.drawColor(Color.argb(110, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
                    }
                }
            } finally {
                holder.unlockCanvasAndPost(canvas)
            }
        }

        private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
            val (height: Int, width: Int) = options.outHeight to options.outWidth
            var inSampleSize = 1
            if (height > reqHeight || width > reqWidth) {
                val halfHeight: Int = height / 2
                val halfWidth: Int = width / 2
                while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                    inSampleSize *= 2
                }
            }
            return inSampleSize
        }

        override fun onDestroy() {
            super.onDestroy()
            Choreographer.getInstance().removeFrameCallback(frameCallback)
            clearBitmaps()
            releaseMediaPlayer()
        }
    }
}

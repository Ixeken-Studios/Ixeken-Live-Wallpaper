package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.content.SharedPreferences
import android.graphics.*
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import android.view.Choreographer
import android.view.SurfaceHolder
import java.util.*
import kotlin.concurrent.thread

class CarouselWallpaperEngine(private val context: Context) : IxekenWallpaperEngine {
    
    private val prefs: SharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val paint = Paint().apply { isFilterBitmap = true; isDither = true }
    private val dimPaint = Paint().apply {
        colorFilter = PorterDuffColorFilter(Color.argb(110, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
    }

    private var mediaPlayer: MediaPlayer? = null
    private var isVideo = false
    private var currentMediaPath: String? = null
    private var currentBitmap: Bitmap? = null
    private var previousBitmap: Bitmap? = null
    private var nextPreloadedBitmap: Bitmap? = null
    
    private var fadeAlpha = 255
    private var isAnimating = false
    private var playlist: List<String> = emptyList()
    private var currentIndex = -1
    private var currentHolder: SurfaceHolder? = null

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isAnimating) {
                fadeAlpha += 42
                if (fadeAlpha >= 255) {
                    fadeAlpha = 255
                    isAnimating = false
                    drawCurrentFrame()
                    previousBitmap?.recycle()
                    previousBitmap = null
                } else {
                    drawCurrentFrame()
                    Choreographer.getInstance().postFrameCallback(this)
                }
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        updateCurrentPlaylist()
        preloadNext()
        drawCurrentFrame()
    }

    private fun updateCurrentPlaylist() {
        val useDayNight = prefs.getBoolean("useDayNightMode", false)
        val key = if (useDayNight) {
            if (isDayTime()) "playlist_day" else "playlist_night"
        } else {
            "playlist"
        }
        val savedList = prefs.getString(key, "")
        playlist = if (!savedList.isNullOrEmpty()) savedList.split("||") else emptyList()
    }

    private fun isDayTime(): Boolean {
        val now = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val start = prefs.getInt("dayStartHour", 6)
        val end = prefs.getInt("nightStartHour", 18)
        return if (start < end) now in start until end else now >= start || now < end
    }

    override fun onVisibilityChanged(visible: Boolean) {
        if (visible) {
            updateCurrentPlaylist()
            drawCurrentFrame()
            if (isVideo) mediaPlayer?.start()
        } else {
            applyRotation() // Siempre al apagar por requerimiento v1.0
            if (isVideo) mediaPlayer?.pause()
        }
    }

    private fun applyRotation() {
        if (playlist.isEmpty()) return
        currentIndex = (currentIndex + 1) % playlist.size
        val nextPath = playlist[currentIndex]
        isVideo = nextPath.endsWith(".mp4") || nextPath.endsWith(".mkv")

        if (isVideo) {
            currentMediaPath = nextPath
            clearBitmaps()
            setupMediaPlayer()
        } else {
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
                    mainHandler.post { currentBitmap = bitmap; startFadeAnimation() }
                }
            }
            preloadNext()
        }
    }

    private fun startFadeAnimation() {
        fadeAlpha = 0
        isAnimating = true
        Choreographer.getInstance().removeFrameCallback(frameCallback)
        Choreographer.getInstance().postFrameCallback(frameCallback)
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
        return try {
            val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, options)
            val frame = currentHolder?.surfaceFrame ?: Rect(0,0,1080,1920)
            options.inSampleSize = calculateInSampleSize(options, frame.width(), frame.height())
            options.inJustDecodeBounds = false
            val decoded = BitmapFactory.decodeFile(path, options) ?: return null
            createCenterCropBitmap(decoded, frame.width(), frame.height())
        } catch (e: Exception) { null }
    }

    private fun createCenterCropBitmap(src: Bitmap, width: Int, height: Int): Bitmap {
        val scale = Math.max(width.toFloat() / src.width, height.toFloat() / src.height)
        val nw = (src.width * scale).toInt()
        val nh = (src.height * scale).toInt()
        val result = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(result)
        canvas.drawBitmap(src, null, RectF((width - nw) / 2f, (height - nh) / 2f, (width + nw) / 2f, (height + nh) / 2f), paint)
        src.recycle()
        return result
    }

    private fun setupMediaPlayer() {
        releaseMediaPlayer()
        try {
            mediaPlayer = MediaPlayer().apply {
                setDataSource(currentMediaPath)
                setSurface(currentHolder?.surface)
                isLooping = true
                setVolume(0f, 0f)
                prepare()
            }
        } catch (e: Exception) {}
    }

    private fun releaseMediaPlayer() {
        mediaPlayer?.apply { if (isPlaying) stop(); release() }
        mediaPlayer = null
    }

    private fun drawCurrentFrame() {
        val canvas = if (android.os.Build.VERSION.SDK_INT >= 26) currentHolder?.lockHardwareCanvas() else currentHolder?.lockCanvas()
        if (canvas == null) return
        try {
            onDraw(canvas)
        } finally {
            currentHolder?.unlockCanvasAndPost(canvas)
        }
    }

    override fun onDraw(canvas: Canvas) {
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
            if (prefs.getBoolean("isDimEnabled", false)) {
                canvas.drawColor(Color.argb(110, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
            }
        }
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        drawCurrentFrame()
    }

    override fun onDestroy() {
        Choreographer.getInstance().removeFrameCallback(frameCallback)
        clearBitmaps()
        releaseMediaPlayer()
    }

    private fun clearBitmaps() {
        previousBitmap?.recycle(); previousBitmap = null
        currentBitmap?.recycle(); currentBitmap = null
        nextPreloadedBitmap?.recycle(); nextPreloadedBitmap = null
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, rw: Int, rh: Int): Int {
        var s = 1
        if (options.outHeight > rh || options.outWidth > rw) {
            val hh = options.outHeight / 2; val hw = options.outWidth / 2
            while (hh / s >= rh && hw / s >= rw) s *= 2
        }
        return s
    }
}

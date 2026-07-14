package com.example.ixeken_live_wallpaper.engines

import android.content.Context
import android.content.SharedPreferences
import android.graphics.*
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import java.io.File
import android.os.Handler
import android.os.Looper
import android.view.Choreographer
import android.view.SurfaceHolder
import java.util.*
import kotlin.concurrent.thread

class CarouselWallpaperEngine(private val context: Context) : IxekenWallpaperEngine, SensorEventListener {
    
    private val prefs: SharedPreferences = context.getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val bgExecutor = java.util.concurrent.Executors.newSingleThreadExecutor()
    private val paint = Paint().apply { isFilterBitmap = true; isDither = true }
    private val dimPaint = Paint().apply {
        colorFilter = PorterDuffColorFilter(Color.argb(110, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
    }

    private var mediaPlayer: ExoPlayer? = null
    private var isVideo = false
    private var currentMediaPath: String? = null
    private var currentBitmap: Bitmap? = null
    private var previousBitmap: Bitmap? = null
    private var nextPreloadedBitmap: Bitmap? = null
    private var preloadedPath: String? = null
    
    private var fadeAlpha = 255
    private var isAnimating = false
    private var animationStartTime = 0L
    private val animationDurationMs = 500L // Transición suave de 500ms
    private var playlist: List<String> = emptyList()
    private var currentIndex = -1
    private var nextIndex = -1
    private var currentHolder: SurfaceHolder? = null
    private var isDestroyed = false
    private var isVisible = false
    private var carouselChangeMode = "on_visibility"
    private var carouselChangeInterval = 60

    private val changeRunnable = object : Runnable {
        override fun run() {
            if (isVisible && !isDestroyed && carouselChangeMode == "timer") {
                applyRotation()
                val intervalMs = carouselChangeInterval * 1000L
                mainHandler.postDelayed(this, intervalMs)
            }
        }
    }

    private var sensorManager: SensorManager? = null
    private var rotationSensor: Sensor? = null
    private var isParallaxEnabled = false
    private var targetOffsetX = 0f
    private var targetOffsetY = 0f
    private var smoothOffsetX = 0f
    private var smoothOffsetY = 0f

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            var continueCallback = false
            if (isAnimating) {
                val elapsed = System.currentTimeMillis() - animationStartTime
                val progress = elapsed.toFloat() / animationDurationMs
                if (progress >= 1f) {
                    fadeAlpha = 255
                    isAnimating = false
                    // Reciclado seguro: evitar liberar si es la misma instancia activa o la precalentada
                    if (previousBitmap != null && previousBitmap != currentBitmap && previousBitmap != nextPreloadedBitmap) {
                        previousBitmap?.recycle()
                    }
                    previousBitmap = null
                } else {
                    fadeAlpha = (progress * 255).toInt().coerceIn(0, 255)
                }
                continueCallback = true
            }
            
            if (isParallaxEnabled) {
                smoothOffsetX = smoothOffsetX * 0.9f + targetOffsetX * 0.1f
                smoothOffsetY = smoothOffsetY * 0.9f + targetOffsetY * 0.1f
                continueCallback = true
            }
            
            drawCurrentFrame()
            
            if (isVisible && continueCallback) {
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    override fun onCreate(holder: SurfaceHolder) {
        currentHolder = holder
        isParallaxEnabled = prefs.getBoolean("isParallaxEnabled", false)
        carouselChangeMode = prefs.getString("carousel_change_mode", "on_visibility") ?: "on_visibility"
        carouselChangeInterval = prefs.getInt("carousel_change_interval", 60)
        if (isParallaxEnabled) {
            sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
            rotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                ?: sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        }
        updateCurrentPlaylist()
        drawCurrentFrame()
    }

    private fun registerSensor() {
        if (isParallaxEnabled && sensorManager != null && rotationSensor != null) {
            sensorManager?.registerListener(this, rotationSensor, SensorManager.SENSOR_DELAY_GAME)
        }
    }

    private fun unregisterSensor() {
        if (isParallaxEnabled && sensorManager != null) {
            sensorManager?.unregisterListener(this)
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return
        var targetX = 0f
        var targetY = 0f
        
        if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR) {
            val rotationMatrix = FloatArray(9)
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            val orientation = FloatArray(3)
            SensorManager.getOrientation(rotationMatrix, orientation)
            targetX = -orientation[2]
            targetY = -orientation[1]
        } else if (event.sensor.type == Sensor.TYPE_ACCELEROMETER) {
            targetX = event.values[0] / 9.8f
            targetY = (event.values[1] - 5f) / 9.8f
        }
        
        val maxOffset = 60f
        targetOffsetX = targetX.coerceIn(-1f, 1f) * maxOffset
        targetOffsetY = targetY.coerceIn(-1f, 1f) * maxOffset
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun updateCurrentPlaylist() {
        val syncSystemTheme = prefs.getBoolean("syncWithSystemTheme", false)
        val useDayNight = prefs.getBoolean("useDayNightMode", false)
        
        val key = when {
            syncSystemTheme -> {
                if (isSystemNightMode()) "playlist_night" else "playlist_day"
            }
            useDayNight -> {
                if (isDayTime()) "playlist_day" else "playlist_night"
            }
            else -> "playlist"
        }
        val savedList = prefs.getString(key, "")
        val newPlaylist = if (!savedList.isNullOrEmpty()) savedList.split("||") else emptyList()
        
        if (newPlaylist != playlist) {
            playlist = newPlaylist
            currentIndex = -1
            nextIndex = getNextIndex()
            clearBitmaps()
            preloadNext(nextIndex)
        }
    }

    private fun getNextIndex(): Int {
        if (playlist.isEmpty()) return -1
        if (playlist.size == 1) return 0
        val isRandom = prefs.getBoolean("isRandom", false)
        return if (isRandom) {
            var next = kotlin.random.Random.nextInt(playlist.size)
            var attempts = 0
            while (next == currentIndex && attempts < 10) {
                next = kotlin.random.Random.nextInt(playlist.size)
                attempts++
            }
            next
        } else {
            (currentIndex + 1) % playlist.size
        }
    }

    private fun isDayTime(): Boolean {
        val now = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        val start = prefs.getInt("dayStartHour", 6)
        val end = prefs.getInt("nightStartHour", 18)
        return if (start < end) now in start until end else now >= start || now < end
    }

    private fun isSystemNightMode(): Boolean {
        val uiMode = context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
        return uiMode == android.content.res.Configuration.UI_MODE_NIGHT_YES
    }

    override fun onVisibilityChanged(visible: Boolean) {
        isVisible = visible
        if (visible) {
            updateCurrentPlaylist()
            carouselChangeMode = prefs.getString("carousel_change_mode", "on_visibility") ?: "on_visibility"
            carouselChangeInterval = prefs.getInt("carousel_change_interval", 60)
            
            // Cargar de inmediato si no hay contenido activo para evitar pantalla negra inicial
            if (currentBitmap == null && mediaPlayer == null && playlist.isNotEmpty()) {
                applyRotation()
            }
            
            drawCurrentFrame()
            if (isVideo) mediaPlayer?.play()
            registerSensor()
            
            mainHandler.removeCallbacks(changeRunnable)
            if (carouselChangeMode == "timer") {
                val intervalMs = carouselChangeInterval * 1000L
                mainHandler.postDelayed(changeRunnable, intervalMs)
            }
            
            if (isAnimating || isParallaxEnabled) {
                Choreographer.getInstance().removeFrameCallback(frameCallback)
                Choreographer.getInstance().postFrameCallback(frameCallback)
            }
        } else {
            unregisterSensor()
            mainHandler.removeCallbacks(changeRunnable)
            if (carouselChangeMode == "on_visibility") {
                applyRotation()
            }
            if (isVideo) mediaPlayer?.pause()
        }
    }

    private fun applyRotation() {
        if (playlist.isEmpty()) return
        
        if (nextIndex < 0 || nextIndex >= playlist.size) {
            nextIndex = getNextIndex()
        }
        if (nextIndex == -1) return
        
        currentIndex = nextIndex
        val nextPath = playlist[currentIndex]
        val nextIsVideo = nextPath.endsWith(".mp4") || nextPath.endsWith(".mkv")
        if (nextPath == currentMediaPath && (currentBitmap != null || (nextIsVideo && mediaPlayer != null))) {
            return
        }
        isVideo = nextIsVideo

        if (isVideo) {
            currentMediaPath = nextPath
            clearBitmaps()
            setupMediaPlayer()
            nextIndex = getNextIndex()
        } else {
            releaseMediaPlayer()
            val usePreloaded = nextPreloadedBitmap != null && preloadedPath == nextPath
            if (usePreloaded) {
                previousBitmap = currentBitmap
                currentBitmap = nextPreloadedBitmap
                nextPreloadedBitmap = null
                preloadedPath = null
                currentMediaPath = nextPath
                startFadeAnimation()
            } else {
                currentMediaPath = nextPath
                bgExecutor.submit {
                    val bitmap = loadAndScaleBitmap(currentMediaPath)
                    mainHandler.post { 
                        if (!isDestroyed) {
                            if (bitmap != null) {
                                previousBitmap = currentBitmap
                                currentBitmap = bitmap
                                startFadeAnimation()
                            }
                        } else {
                            bitmap?.recycle()
                        }
                    }
                }
            }
            
            nextIndex = getNextIndex()
            preloadNext(nextIndex)
        }
    }

    private fun startFadeAnimation() {
        fadeAlpha = 0
        isAnimating = true
        animationStartTime = System.currentTimeMillis()
        Choreographer.getInstance().removeFrameCallback(frameCallback)
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    private fun preloadNext(index: Int) {
        if (playlist.isEmpty()) return
        if (index < 0 || index >= playlist.size) return
        val peekPath = playlist[index]
        if (!peekPath.endsWith(".mp4") && !peekPath.endsWith(".mkv")) {
            bgExecutor.submit {
                val bitmap = loadAndScaleBitmap(peekPath)
                mainHandler.post { 
                    if (!isDestroyed) {
                        if (nextPreloadedBitmap != bitmap) {
                            nextPreloadedBitmap?.recycle()
                            nextPreloadedBitmap = bitmap 
                            preloadedPath = peekPath
                        }
                    } else {
                        bitmap?.recycle()
                    }
                }
            }
        }
    }

    private fun applyDimToBitmap(src: Bitmap): Bitmap {
        if (!prefs.getBoolean("isDimEnabled", false)) return src
        return try {
            val result = Bitmap.createBitmap(src.width, src.height, src.config ?: Bitmap.Config.ARGB_8888)
            val canvas = Canvas(result)
            val p = Paint().apply { isFilterBitmap = true }
            canvas.drawBitmap(src, 0f, 0f, p)
            val dimIntensity = prefs.getFloat("dim_intensity", 0.43f)
            val alpha = (dimIntensity * 255).toInt().coerceIn(0, 255)
            canvas.drawColor(Color.argb(alpha, 0, 0, 0), PorterDuff.Mode.SRC_OVER)
            src.recycle()
            result
        } catch (e: Exception) {
            src
        }
    }

    private fun loadAndScaleBitmap(path: String?): Bitmap? {
        if (path == null) return null
        return try {
            val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, options)
            val frame = currentHolder?.surfaceFrame ?: Rect(0,0,1080,1920)
            var w = frame.width()
            var h = frame.height()
            if (w <= 0 || h <= 0) {
                w = 1080
                h = 1920
            }
            val targetW = if (isParallaxEnabled) (w * 1.1f).toInt() else w
            val targetH = if (isParallaxEnabled) (h * 1.1f).toInt() else h
            
            options.inSampleSize = calculateInSampleSize(options, targetW, targetH)
            options.inJustDecodeBounds = false
            val decoded = BitmapFactory.decodeFile(path, options) ?: return null
            val cropped = createCenterCropBitmap(decoded, targetW, targetH)
            applyDimToBitmap(cropped)
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
        val path = currentMediaPath ?: return
        try {
            mediaPlayer = ExoPlayer.Builder(context).build().apply {
                setVideoSurfaceHolder(currentHolder)
                repeatMode = Player.REPEAT_MODE_ALL
                volume = 0f
                setMediaItem(MediaItem.fromUri(Uri.fromFile(File(path))))
                prepare()
                playWhenReady = isVisible
            }
        } catch (e: Exception) {}
    }

    private fun releaseMediaPlayer() {
        mediaPlayer?.release()
        mediaPlayer = null
    }

    private fun drawCurrentFrame() {
        if (!isVisible) return
        val holder = currentHolder ?: return
        if (!holder.surface.isValid) return
        val canvas = try {
            if (android.os.Build.VERSION.SDK_INT >= 26) holder.lockHardwareCanvas() else holder.lockCanvas()
        } catch (e: Exception) {
            try { holder.lockCanvas() } catch (ex: Exception) { null }
        } ?: return
        try {
            onDraw(canvas)
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
    }

    override fun onDraw(canvas: Canvas) {
        // Limpiar el fondo con un color negro base para evitar remanentes o parpadeos
        canvas.drawColor(Color.BLACK)
        
        canvas.save()
        if (isParallaxEnabled) {
            canvas.translate(smoothOffsetX, smoothOffsetY)
        }
        
        val frame = currentHolder?.surfaceFrame ?: Rect(0,0,1080,1920)
        val screenW = frame.width().toFloat()
        val screenH = frame.height().toFloat()
        
        if (!isVideo) {
            val curr = currentBitmap
            val prev = previousBitmap
            if (isAnimating && prev != null && !prev.isRecycled) {
                paint.alpha = 255
                drawBitmapCentered(canvas, prev, screenW, screenH)
                if (curr != null && !curr.isRecycled) {
                    paint.alpha = fadeAlpha
                    drawBitmapCentered(canvas, curr, screenW, screenH)
                }
            } else if (curr != null && !curr.isRecycled) {
                paint.alpha = 255
                drawBitmapCentered(canvas, curr, screenW, screenH)
            }
        }
        canvas.restore()
    }

    private fun drawBitmapCentered(canvas: Canvas, bitmap: Bitmap, screenW: Float, screenH: Float) {
        val dx = (screenW - bitmap.width) / 2f
        val dy = (screenH - bitmap.height) / 2f
        canvas.drawBitmap(bitmap, dx, dy, paint)
    }

    override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        currentHolder = holder
        if (isVideo) {
            try {
                mediaPlayer?.setVideoSurfaceHolder(holder)
            } catch (e: Exception) {}
        }
        drawCurrentFrame()
    }

    override fun onDestroy() {
        isDestroyed = true
        mainHandler.removeCallbacks(changeRunnable)
        Choreographer.getInstance().removeFrameCallback(frameCallback)
        clearBitmaps()
        releaseMediaPlayer()
        bgExecutor.shutdown()
    }

    override fun onTrimMemory(level: Int) {
        if (level >= android.content.ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW) {
            val pre = nextPreloadedBitmap
            val prev = previousBitmap
            
            nextPreloadedBitmap = null
            preloadedPath = null
            previousBitmap = null
            
            if (pre != null && !pre.isRecycled && pre !== currentBitmap) {
                pre.recycle()
            }
            if (prev != null && !prev.isRecycled && prev !== currentBitmap) {
                prev.recycle()
            }
        }
    }

    private fun clearBitmaps() {
        val prev = previousBitmap
        val curr = currentBitmap
        val pre = nextPreloadedBitmap
        
        previousBitmap = null
        currentBitmap = null
        nextPreloadedBitmap = null
        preloadedPath = null
        
        if (prev != null && !prev.isRecycled) {
            prev.recycle()
        }
        if (curr != null && !curr.isRecycled && curr !== prev) {
            curr.recycle()
        }
        if (pre != null && !pre.isRecycled && pre !== curr && pre !== prev) {
            pre.recycle()
        }
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

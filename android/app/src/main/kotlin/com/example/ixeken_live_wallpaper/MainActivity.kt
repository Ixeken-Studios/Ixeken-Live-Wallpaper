package com.example.ixeken_live_wallpaper

import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ixeken.wallpaper/media"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            
            when (call.method) {
                "updatePlaylist" -> {
                    val playlist = call.argument<List<String>>("playlist")
                    val type = call.argument<String>("type") ?: "general"
                    if (playlist != null) {
                        val storageDir = File(filesDir, "wallpapers/$type")
                        if (!storageDir.exists()) {
                            storageDir.mkdirs()
                        }
                        
                        val copiedPaths = mutableListOf<String>()
                        val failedPaths = mutableListOf<String>()
                        
                        for (path in playlist) {
                            val originalFile = File(path)
                            if (!originalFile.exists()) {
                                continue
                            }
                            
                            if (!isValidImageOrVideo(originalFile)) {
                                failedPaths.add(originalFile.name)
                                continue
                            }
                            
                            val destFile = File(storageDir, originalFile.name)
                            
                            if (originalFile.absolutePath != destFile.absolutePath) {
                                try {
                                    originalFile.inputStream().use { input ->
                                        destFile.outputStream().use { output ->
                                            input.copyTo(output)
                                        }
                                    }
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                    failedPaths.add(originalFile.name)
                                    continue
                                }
                            }
                            copiedPaths.add(destFile.absolutePath)
                        }
                        
                        val copiedSet = copiedPaths.map { File(it).name }.toSet()
                        storageDir.listFiles()?.forEach { file ->
                            if (!copiedSet.contains(file.name)) {
                                file.delete()
                            }
                        }
                        
                        val key = when(type) {
                            "day" -> "playlist_day"
                            "night" -> "playlist_night"
                            else -> "playlist"
                        }
                        editor.putString(key, copiedPaths.joinToString("||")).commit()
                        
                        performDiskCleanup()
                        
                        val intent = Intent(IxekenWallpaperService.ACTION_SETTINGS_CHANGED)
                        intent.setPackage(packageName)
                        sendBroadcast(intent)
                        
                        if (failedPaths.isNotEmpty()) {
                            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                                .invokeMethod("onPlaylistError", failedPaths)
                        }
                        
                        result.success(copiedPaths)
                    } else {
                        result.error("INVALID_ARGS", "Playlist is null", null)
                    }
                }
                "applySingleWallpaper" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        val originalFile = File(path)
                        if (originalFile.exists()) {
                            if (isValidImageOrVideo(originalFile)) {
                                val storageDir = File(filesDir, "wallpapers/general")
                                if (!storageDir.exists()) {
                                    storageDir.mkdirs()
                                }
                                val destFile = File(storageDir, originalFile.name)
                                if (originalFile.absolutePath != destFile.absolutePath) {
                                    try {
                                        originalFile.inputStream().use { input ->
                                            destFile.outputStream().use { output ->
                                                input.copyTo(output)
                                            }
                                        }
                                    } catch (e: Exception) {
                                        e.printStackTrace()
                                        result.error("COPY_FAILED", "Failed to copy file", e.message)
                                        return@setMethodCallHandler
                                    }
                                }
                                
                                editor.putString("playlist", destFile.absolutePath)
                                    .putString("selected_engine", "carousel")
                                    .putBoolean("useDayNightMode", false)
                                    .putBoolean("syncWithSystemTheme", false)
                                    .commit()
                                
                                performDiskCleanup()
                                
                                val intent = Intent(IxekenWallpaperService.ACTION_SETTINGS_CHANGED)
                                intent.setPackage(packageName)
                                sendBroadcast(intent)
                                
                                result.success(true)
                            } else {
                                result.error("INVALID_FILE", "File is corrupt or not supported", null)
                            }
                        } else {
                            result.error("FILE_NOT_FOUND", "File does not exist", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Path is null", null)
                    }
                }
                "updateSettings" -> {
                    val changeOnVisible = call.argument<Boolean>("changeOnVisible") ?: true
                    val useDayNightMode = call.argument<Boolean>("useDayNightMode") ?: false
                    val dayStartHour = call.argument<Int>("dayStartHour") ?: 6
                    val nightStartHour = call.argument<Int>("nightStartHour") ?: 18
                    val isDimEnabled = call.argument<Boolean>("isDimEnabled") ?: false
                    val dimIntensity = call.argument<Double>("dimIntensity") ?: 0.43
                    val selectedEngine = call.argument<String>("selectedEngine") ?: "carousel"
                    val isRandom = call.argument<Boolean>("isRandom") ?: false
                    val tetrisStyle = call.argument<String>("tetrisStyle") ?: "neon"
                    val syncWithSystemTheme = call.argument<Boolean>("syncWithSystemTheme") ?: false
                    val isParallaxEnabled = call.argument<Boolean>("isParallaxEnabled") ?: false
                    val carouselChangeMode = call.argument<String>("carouselChangeMode") ?: "on_visibility"
                    val carouselChangeInterval = call.argument<Int>("carouselChangeInterval") ?: 60
                    
                    editor.putBoolean("changeOnVisible", changeOnVisible)
                        .putBoolean("useDayNightMode", useDayNightMode)
                        .putInt("dayStartHour", dayStartHour)
                        .putInt("nightStartHour", nightStartHour)
                        .putBoolean("isDimEnabled", isDimEnabled)
                        .putFloat("dim_intensity", dimIntensity.toFloat())
                        .putString("selected_engine", selectedEngine)
                        .putBoolean("isRandom", isRandom)
                        .putString("tetris_style", tetrisStyle)
                        .putBoolean("syncWithSystemTheme", syncWithSystemTheme)
                        .putBoolean("isParallaxEnabled", isParallaxEnabled)
                        .putString("carousel_change_mode", carouselChangeMode)
                        .putInt("carousel_change_interval", carouselChangeInterval)
                        .commit()
                    
                    val intent = Intent(IxekenWallpaperService.ACTION_SETTINGS_CHANGED)
                    intent.setPackage(packageName)
                    sendBroadcast(intent)
                    
                    result.success(true)
                }
                "openWallpaperPicker" -> {
                    try {
                        val intent = Intent(android.app.WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
                        intent.putExtra(android.app.WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT, 
                            android.content.ComponentName(this, IxekenWallpaperService::class.java))
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(android.app.WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
                            startActivity(intent)
                            result.success(true)
                        } catch (ex: Exception) {
                            result.error("PICKER_ERROR", ex.message, null)
                        }
                    }
                }
                "launchUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, android.net.Uri.parse(url))
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LAUNCH_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "URL is null", null)
                    }
                }
                "clearWallpaper" -> {
                    try {
                        val wm = android.app.WallpaperManager.getInstance(this)
                        wm.clear()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLEAR_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isValidImageOrVideo(file: File): Boolean {
        if (!file.exists() || file.length() == 0L) return false
        val path = file.absolutePath
        return if (path.endsWith(".mp4", ignoreCase = true) || path.endsWith(".mkv", ignoreCase = true)) {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(path)
                val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                duration != null
            } catch (e: Exception) {
                false
            } finally {
                try { retriever.release() } catch (e: Exception) {}
            }
        } else {
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFile(path, options)
            options.outWidth > 0 && options.outHeight > 0
        }
    }

    private fun performDiskCleanup() {
        val prefs = getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        val activeFiles = mutableSetOf<String>()
        
        val playlist = prefs.getString("playlist", "") ?: ""
        val playlistDay = prefs.getString("playlist_day", "") ?: ""
        val playlistNight = prefs.getString("playlist_night", "") ?: ""
        
        val allPaths = playlist.split("||") + playlistDay.split("||") + playlistNight.split("||")
        for (path in allPaths) {
            if (path.isNotEmpty()) {
                activeFiles.add(File(path).absolutePath)
            }
        }
        
        val wallpapersDir = File(filesDir, "wallpapers")
        if (wallpapersDir.exists() && wallpapersDir.isDirectory) {
            wallpapersDir.walkTopDown().forEach { file ->
                if (file.isFile) {
                    if (!activeFiles.contains(file.absolutePath)) {
                        file.delete()
                    }
                }
            }
        }
    }
}

package com.example.ixeken_live_wallpaper

import android.content.Context
import android.content.Intent
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
                        // Copiar archivos a almacenamiento interno permanente
                        val storageDir = File(filesDir, "wallpapers/$type")
                        if (!storageDir.exists()) {
                            storageDir.mkdirs()
                        }
                        
                        val copiedPaths = mutableListOf<String>()
                        
                        for (path in playlist) {
                            val originalFile = File(path)
                            if (!originalFile.exists()) {
                                continue
                            }
                            
                            val destFile = File(storageDir, originalFile.name)
                            
                            // Si el archivo de origen no está ya en el destino, copiarlo
                            if (originalFile.absolutePath != destFile.absolutePath) {
                                try {
                                    originalFile.inputStream().use { input ->
                                        destFile.outputStream().use { output ->
                                            input.copyTo(output)
                                        }
                                    }
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                    continue
                                }
                            }
                            copiedPaths.add(destFile.absolutePath)
                        }
                        
                        // Limpieza de archivos antiguos no referenciados
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
                        editor.putString(key, copiedPaths.joinToString("||")).apply()
                        
                        // Notificar cambio
                        sendBroadcast(Intent(IxekenWallpaperService.ACTION_SETTINGS_CHANGED))
                        
                        result.success(copiedPaths)
                    } else {
                        result.error("INVALID_ARGS", "Playlist is null", null)
                    }
                }
                "updateSettings" -> {
                    val changeOnVisible = call.argument<Boolean>("changeOnVisible") ?: true
                    val useDayNightMode = call.argument<Boolean>("useDayNightMode") ?: false
                    val dayStartHour = call.argument<Int>("dayStartHour") ?: 6
                    val nightStartHour = call.argument<Int>("nightStartHour") ?: 18
                    val isDimEnabled = call.argument<Boolean>("isDimEnabled") ?: false
                    val selectedEngine = call.argument<String>("selectedEngine") ?: "carousel"
                    val isRandom = call.argument<Boolean>("isRandom") ?: false
                    val tetrisStyle = call.argument<String>("tetrisStyle") ?: "neon"
                    
                    editor.putBoolean("changeOnVisible", changeOnVisible)
                        .putBoolean("useDayNightMode", useDayNightMode)
                        .putInt("dayStartHour", dayStartHour)
                        .putInt("nightStartHour", nightStartHour)
                        .putBoolean("isDimEnabled", isDimEnabled)
                        .putString("selected_engine", selectedEngine)
                        .putBoolean("isRandom", isRandom)
                        .putString("tetris_style", tetrisStyle)
                        .commit() // Usamos commit para asegurar que el dato esté escrito antes del broadcast
                    
                    // Enviar señal de actualización inmediata al servicio
                    val intent = Intent(IxekenWallpaperService.ACTION_SETTINGS_CHANGED)
                    intent.setPackage(packageName) // Asegurar que solo nuestra app lo reciba
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
                        result.error("PICKER_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

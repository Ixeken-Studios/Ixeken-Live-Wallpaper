package com.example.ixeken_live_wallpaper

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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
                    val type = call.argument<String>("type") ?: "general" // general, day, night
                    if (playlist != null) {
                        val key = when(type) {
                            "day" -> "playlist_day"
                            "night" -> "playlist_night"
                            else -> "playlist"
                        }
                        editor.putString(key, playlist.joinToString("||")).apply()
                        result.success(true)
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
                    
                    editor.putBoolean("changeOnVisible", changeOnVisible)
                        .putBoolean("useDayNightMode", useDayNightMode)
                        .putInt("dayStartHour", dayStartHour)
                        .putInt("nightStartHour", nightStartHour)
                        .putBoolean("isDimEnabled", isDimEnabled)
                        .apply()
                    result.success(true)
                }
                "openWallpaperPicker" -> {
                    try {
                        val intent = android.content.Intent(android.app.WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
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

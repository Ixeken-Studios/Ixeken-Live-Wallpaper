package com.example.ixeken_live_wallpaper

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.res.Configuration
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import com.example.ixeken_live_wallpaper.engines.*

class IxekenWallpaperService : WallpaperService() {

    companion object {
        const val ACTION_SETTINGS_CHANGED = "com.ixeken.wallpaper.SETTINGS_CHANGED"
    }

    private val activeHosts = mutableListOf<IxekenEngineHost>()

    override fun onCreateEngine(): Engine {
        return IxekenEngineHost()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        activeHosts.forEach { host ->
            host.trimMemory(level)
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val prefs = getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
        val syncSystemTheme = prefs.getBoolean("syncWithSystemTheme", false)
        if (syncSystemTheme) {
            val intent = Intent(ACTION_SETTINGS_CHANGED)
            intent.setPackage(packageName)
            sendBroadcast(intent)
        }
    }

    inner class IxekenEngineHost : Engine() {
        private var activeEngine: IxekenWallpaperEngine? = null
        private lateinit var prefs: SharedPreferences
        
        private val settingsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ACTION_SETTINGS_CHANGED) {
                    // Forzar recarga del motor en el hilo principal
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        loadEngine(surfaceHolder)
                    }
                }
            }
        }

        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            activeHosts.add(this)
            prefs = getSharedPreferences("WallpaperPrefs", Context.MODE_PRIVATE)
            
            // Registrar el receptor de mensajes de la App
            val filter = IntentFilter(ACTION_SETTINGS_CHANGED)
            if (android.os.Build.VERSION.SDK_INT >= 33) {
                registerReceiver(settingsReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(settingsReceiver, filter)
            }
            
            loadEngine(surfaceHolder)
        }

        private fun isLockScreenOnly(): Boolean {
            if (android.os.Build.VERSION.SDK_INT >= 34) {
                val flags = try { getWallpaperFlags() } catch (e: Exception) { 0 }
                if (flags != 0) {
                    val isLock = (flags and android.app.WallpaperManager.FLAG_LOCK) != 0
                    val isSystem = (flags and android.app.WallpaperManager.FLAG_SYSTEM) != 0
                    if (isLock && !isSystem) {
                        return true
                    }
                }
            }
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? android.app.KeyguardManager
            return keyguardManager?.isKeyguardLocked == true
        }

        private fun loadEngine(holder: SurfaceHolder) {
            // 1. Limpieza profunda del motor anterior
            activeEngine?.onVisibilityChanged(false)
            activeEngine?.onDestroy()
            activeEngine = null
            
            // 2. Leer nueva configuración
            val isLock = isLockScreenOnly()
            val engineKey = if (isLock) "selected_engine_lock" else "selected_engine"
            var type = prefs.getString(engineKey, "same")
            if (type.isNullOrEmpty() || type == "same") {
                type = prefs.getString("selected_engine", "carousel")
            }
            
            // 3. Instanciar nuevo motor
            activeEngine = when (type) {
                "carousel" -> CarouselWallpaperEngine(this@IxekenWallpaperService)
                "particles" -> ParticlesWallpaperEngine(this@IxekenWallpaperService)
                "tetris" -> TetrisWallpaperEngine(this@IxekenWallpaperService)
                "matrix" -> MatrixWallpaperEngine(this@IxekenWallpaperService)
                "plexus" -> PlexusWallpaperEngine(this@IxekenWallpaperService)
                "liquid" -> LiquidGradientWallpaperEngine(this@IxekenWallpaperService)
                "starfield" -> StarfieldWallpaperEngine(this@IxekenWallpaperService)
                "vaporwave" -> VaporwaveWallpaperEngine(this@IxekenWallpaperService)
                "conway" -> ConwayWallpaperEngine(this@IxekenWallpaperService)
                "fluids" -> FluidSwarmWallpaperEngine(this@IxekenWallpaperService)
                "pattern" -> PatternWallpaperEngine(this@IxekenWallpaperService)
                "floral" -> FloralWallpaperEngine(this@IxekenWallpaperService)
                "bokeh" -> BokehWallpaperEngine(this@IxekenWallpaperService)
                "quantum" -> QuantumWallpaperEngine(this@IxekenWallpaperService)
                "aura" -> AuraWallpaperEngine(this@IxekenWallpaperService)
                else -> CarouselWallpaperEngine(this@IxekenWallpaperService)
            }
            
            // 4. Inicializar y activar
            activeEngine?.setEngineHost(this)
            activeEngine?.onCreate(holder)
            if (isVisible) {
                activeEngine?.onVisibilityChanged(true)
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            activeEngine?.onVisibilityChanged(visible)
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            activeEngine?.onSurfaceChanged(holder, format, width, height)
        }

        override fun onTouchEvent(event: android.view.MotionEvent) {
            super.onTouchEvent(event)
            activeEngine?.onTouchEvent(event)
        }

        fun trimMemory(level: Int) {
            activeEngine?.onTrimMemory(level)
        }

        override fun onDestroy() {
            super.onDestroy()
            activeHosts.remove(this)
            try {
                unregisterReceiver(settingsReceiver)
            } catch (e: Exception) {}
            activeEngine?.onDestroy()
            activeEngine = null
        }
    }
}

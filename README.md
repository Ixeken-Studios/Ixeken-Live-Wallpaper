# Ixeken Live Wallpaper v1.1 🚀

**Ixeken Live Wallpaper** es una aplicación modular para Android que permite gestionar múltiples tipos de fondos animados desde una única interfaz Flutter.

## ✨ Características Principales

- **🔄 Carrusel Inteligente**: Fotos y videos con modo Día/Noche.
- **🌌 Ixeken Particles**: Motor de partículas flotantes optimizado por GPU.
- **🕹️ Ixeken Tetris AI**: Un fondo retro que juega al Tetris automáticamente.
- **🛠️ Arquitectura Modular**: Añade nuevos fondos simplemente creando un archivo Kotlin.

---

## 👨‍💻 Guía para Desarrolladores: Crear Nuevos Fondos

El proyecto está diseñado para que cualquier desarrollador pueda añadir un nuevo tipo de fondo animado siguiendo estos pasos:

### 1. Crear el Motor en Kotlin
Crea una nueva clase en `android/app/src/main/kotlin/com/example/ixeken_live_wallpaper/engines/` que implemente la interfaz `IxekenWallpaperEngine`.

```kotlin
class MiNuevoMotor(private val context: Context) : IxekenWallpaperEngine {
    override fun onCreate(holder: SurfaceHolder) { /* Inicializar */ }
    override fun onDraw(canvas: Canvas) { /* Dibujar aquí */ }
    override fun onVisibilityChanged(visible: Boolean) { /* Pausar/Reanudar */ }
    override fun onDestroy() { /* Liberar memoria */ }
}
```

### 2. Registrar el Motor en el Servicio
Añade tu motor al selector en `IxekenWallpaperService.kt`:

```kotlin
activeEngine = when (type) {
    "carousel" -> CarouselWallpaperEngine(this)
    "mi_motor" -> MiNuevoMotor(this) // <--- Añade esto
    else -> CarouselWallpaperEngine(this)
}
```

### 3. Habilitarlo en la Interfaz (Flutter)
Añade el ID de tu motor al mapa `_engines` en `lib/main.dart`:

```dart
final Map<String, String> _engines = {
  'carousel': 'Carrusel de Medios',
  'mi_motor': 'Mi Increíble Fondo ✨', // <--- Añade esto
};
```

---

## 🚀 Instalación y Uso

1. **Compilar**: Ejecuta `flutter build apk`.
2. **Seleccionar**: Abre la app y elige el motor en el menú desplegable superior.
3. **Activar**: Pulsa "ACTIVAR FONDO".

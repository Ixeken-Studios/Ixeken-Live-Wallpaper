# Ixeken Live Wallpaper 🚀

An interactive, modular Android Live Wallpaper engine application offering real-time custom animated backgrounds, hardware-accelerated particle physics, automated retro game engines, media carousels with day/night automation, dynamic Material 3 Expressive theme palettes, custom Google Fonts typography, and total offline privacy.

[<img src="https://img.shields.io/badge/Download-Latest_Release-003171?style=for-the-badge&logo=android&logoColor=white" height="45">](https://github.com/Ixeken-Studios/Ixeken-Live-Wallpaper/releases/latest)
[<img src="https://img.shields.io/badge/License-MIT-6A994E?style=for-the-badge&logo=open-source-initiative&logoColor=white" height="45">](LICENSE)

---

## ✨ Key Features

### 🎬 Interactive Native Engines
- **Media Carousel Engine**: Dynamic rotation of custom photos and video wallpapers with smooth crossfade transitions. Supports day/night schedule filters and screen-off rotation logic.
- **Ixeken Matrix Digital Rain**: Falling green and custom glyph cascades with randomized speed and glyph mutations.
- **Fluid & Particle Simulation Engine**: Hardware-accelerated interactive particle arrays, plexus constellations, and liquid glowing metaballs reacting dynamically to touch input and gyro parallax.
- **Tetris Simulation**: Autonomous retro Tetris game playing endlessly on your wallpaper with line clearing and block fitting.
- **Vaporwave 3D Grid & Starfield**: 3D starfields and retro-wave grid landscapes.
- **Conway's Game of Life & Quantum Energy**: Cellular automata and magnetic interactive nodes.

### 🎨 Dynamic Material 3 Theme Engine
- **6 Curated Theme Palettes**: Ixeken Dark, Ixeken Light, Cherry, Earthy, Amoled (Pure Pitch Black), and Elegance.
- **Material You Dynamic Accents**: Automatic color syncing with device system wallpaper accents using `dynamic_color`.

### 🔤 Custom Typography & Tactile Scaling
- **Google Fonts Integration**: Support for Outfit, Inter, Rubik, Space Grotesk, Ubuntu, Nunito, and System Default typography.
- **Tactile Font Size Slider**: Custom slider controls with real-time font scale propagation across all screens.

### ⚡ Power & Battery Optimization
- **Lock-Screen Render Regulator**: Automatically caps wallpaper rendering to 1 FPS when the display is on the lock screen to conserve battery.
- **Half-FPS Battery Saver**: Optional energy saver mode that halves rendering frequency dynamically.

### 🔒 Absolute Local Privacy
- **100% Offline & Device-Local**: All imported media, settings, and playlists remain strictly on your local device storage with zero tracking, telemetry, or external server uploads.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Configuration Dashboard | Flutter 3.x / Dart 3.x |
| Native Engine Layer | Kotlin 2.x & Android NDK |
| Audio & Video Engine | AndroidX Media3 / ExoPlayer 1.3.1 |
| Rendering Pipeline | Android `Choreographer` + `lockHardwareCanvas` |
| Local Persistence | `shared_preferences` |
| Design System | Material 3 / Google Fonts / Dynamic Color |

---

## 👨‍💻 Developer Guide: Adding Custom Native Engines

The architecture is designed to be easily extensible. To create a new live wallpaper engine:

### 1. Inherit from `BaseWallpaperEngine`
Create a new Kotlin class inside `android/app/src/main/kotlin/com/example/ixeken_live_wallpaper/engines/`:

```kotlin
class MyCustomEngine(context: Context) : BaseWallpaperEngine(context) {
    override fun onUpdatePhysics(deltaTimeSec: Float) {
        // Update physics and object positions here
    }

    override fun onDraw(canvas: Canvas) {
        // Draw graphics onto hardware canvas here
    }
}
```

### 2. Register Engine in `IxekenWallpaperService.kt`
Add your engine to the service factory branch:

```kotlin
activeEngine = when (type) {
    "carousel" -> CarouselWallpaperEngine(this)
    "my_custom_engine" -> MyCustomEngine(this)
    else -> CarouselWallpaperEngine(this)
}
```

### 3. Expose in Flutter Dashboard (`l10n.dart`)
Declare the localized title and description in `lib/l10n.dart` to make it accessible in the UI.

---

## 📦 Building & Installation

1. **Clone Repository**:
   ```bash
   git clone https://github.com/Ixeken-Studios/Ixeken-Live-Wallpaper.git
   cd Ixeken-Live-Wallpaper
   ```

2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build Optimized Release APKs**:
   ```bash
   flutter build apk --release --split-per-abi
   ```

4. **Build Android App Bundle (Google Play)**:
   ```bash
   flutter build appbundle --release
   ```

---

## 📄 License & Credits

This project is open source and available under the [MIT License](LICENSE). Developed by **Ixeken Studios**. Built with Flutter, Kotlin, and AndroidX Media3.

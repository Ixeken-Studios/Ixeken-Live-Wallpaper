# Ixeken Live Wallpaper v1.0 🚀

**Ixeken Live Wallpaper** es una aplicación de fondo de pantalla animado para Android que permite crear un carrusel infinito de fotos y videos locales con transiciones fluidas
## ✨ Características Principales

- **🔄 Carrusel Infinito**: Soporte para listas ilimitadas de imágenes y videos locales.
- **🕒 Modo Día/Noche Inteligente**: Configura galerías diferentes para el día y la noche con horarios personalizables.
- **🌚 Filtro de Visibilidad (Dim)**: Oscurecimiento opcional del fondo para mejorar la legibilidad de los iconos en el launcher.
- **🔋 Optimización para HyperOS/Xiaomi**: 
  - Gestión eficiente de memoria mediante pre-procesado de imágenes.
  - Carga asíncrona para evitar bloqueos del sistema.
  - Soporte para disparadores de visibilidad (cambio al encender o apagar la pantalla).

## 🛠️ Stack Tecnológico

- **Frontend**: Flutter (Material 3 con estética Dark Mode).
- **Backend Nativo**: Kotlin utilizando `WallpaperService` y `Hardware Canvas`.
- **Comunicación**: MethodChannels para sincronización de estados y comandos.

## 🚀 Instalación y Uso

1. **Compilar**: Ejecuta `flutter build apk` para generar el instalador.
2. **Gestionar**: Abre la app y añade tus fotos/videos favoritos a las galerías correspondientes.
3. **Personalizar**: Ajusta el modo Día/Noche y los filtros visuales.
4. **Aplicar**: Pulsa el botón "Aplicar v1.0" y selecciona "Ixeken Live Wallpaper" en el selector nativo de Android.

## 📂 Estructura del Proyecto

- `lib/`: Interfaz de usuario y gestión de estados en Flutter.
- `android/app/src/main/kotlin/`: Implementación del motor nativo y servicios de fondo.
- `android/app/src/main/res/xml/`: Configuración obligatoria del Live Wallpaper.


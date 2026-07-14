import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WallpaperManager {
  static const MethodChannel _channel = MethodChannel('com.ixeken.wallpaper/media');

  /// Envía la lista de rutas absolutas al lado nativo.
  /// Retorna la lista de nuevas rutas en el almacenamiento interno o null si hay un error.
  /// [type] puede ser 'general', 'day', o 'night'.
  static Future<List<String>?> updatePlaylist(List<String> filePaths, {String type = 'general'}) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('updatePlaylist', {
        'playlist': filePaths,
        'type': type,
      });
      return result?.cast<String>();
    } on PlatformException catch (e) {
      debugPrint("Error al actualizar la playlist para tipo $type: '${e.message}'.");
      return null;
    }
  }

  /// Actualiza la configuración global.
  static Future<bool> updateSettings({
    required bool changeOnVisible,
    bool useDayNightMode = false,
    int dayStartHour = 6,
    int nightStartHour = 18,
    bool isDimEnabled = false,
    double dimIntensity = 0.43,
    String selectedEngine = 'carousel',
    bool isRandom = false,
    String tetrisStyle = 'neon',
    bool syncWithSystemTheme = false,
    bool isParallaxEnabled = false,
    String carouselChangeMode = 'on_visibility',
    int carouselChangeInterval = 60,
    bool isHalfFpsEnabled = false,
    int patternLayoutSize = 2,
    List<String> patternSlotIcons = const ['circle', 'star', 'heart', 'cross'],
    double patternSpeed = 2.0,
    String patternDensity = 'medium',
    bool patternRotate = true,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('updateSettings', {
        'changeOnVisible': changeOnVisible,
        'useDayNightMode': useDayNightMode,
        'dayStartHour': dayStartHour,
        'nightStartHour': nightStartHour,
        'isDimEnabled': isDimEnabled,
        'dimIntensity': dimIntensity,
        'selectedEngine': selectedEngine,
        'isRandom': isRandom,
        'tetrisStyle': tetrisStyle,
        'syncWithSystemTheme': syncWithSystemTheme,
        'isParallaxEnabled': isParallaxEnabled,
        'carouselChangeMode': carouselChangeMode,
        'carouselChangeInterval': carouselChangeInterval,
        'isHalfFpsEnabled': isHalfFpsEnabled,
        'patternLayoutSize': patternLayoutSize,
        'patternSlotIcons': patternSlotIcons.join(','), // Pass as comma-separated string
        'patternSpeed': patternSpeed,
        'patternDensity': patternDensity,
        'patternRotate': patternRotate,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error al actualizar configuración: '${e.message}'.");
      return false;
    }
  }

  /// Establece un único fondo específico de la galería del usuario.
  static Future<bool> applySingleWallpaper(String filePath) async {
    try {
      final bool result = await _channel.invokeMethod('applySingleWallpaper', {
        'path': filePath,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error al aplicar fondo individual: '${e.message}'.");
      return false;
    }
  }

  /// Abre el selector de fondos de pantalla de Android.
  static Future<bool> openWallpaperPicker() async {
    try {
      final bool result = await _channel.invokeMethod('openWallpaperPicker');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error al abrir el selector: '${e.message}'.");
      return false;
    }
  }

  /// Quita el fondo de pantalla actual de la aplicación y restablece el fondo de
  /// pantalla predeterminado del sistema operativo Android.
  ///
  /// Retorna un valor booleano indicando si la operación fue exitosa.
  static Future<bool> clearWallpaper() async {
    try {
      final bool result = await _channel.invokeMethod('clearWallpaper');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error al quitar el wallpaper: '${e.message}'.");
      return false;
    }
  }

  /// Abre una URL en el navegador nativo.
  static Future<bool> launchUrl(String url) async {
    try {
      final bool result = await _channel.invokeMethod('launchUrl', {'url': url});
      return result;
    } on PlatformException catch (e) {
      debugPrint("Error al abrir URL '$url': '${e.message}'.");
      return false;
    }
  }
}

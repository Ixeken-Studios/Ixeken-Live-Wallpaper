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
      print("Error al actualizar la playlist ($type): '${e.message}'.");
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
    String selectedEngine = 'carousel',
    bool isRandom = false,
    String tetrisStyle = 'neon',
  }) async {
    try {
      final bool result = await _channel.invokeMethod('updateSettings', {
        'changeOnVisible': changeOnVisible,
        'useDayNightMode': useDayNightMode,
        'dayStartHour': dayStartHour,
        'nightStartHour': nightStartHour,
        'isDimEnabled': isDimEnabled,
        'selectedEngine': selectedEngine,
        'isRandom': isRandom,
        'tetrisStyle': tetrisStyle,
      });
      return result;
    } on PlatformException catch (e) {
      print("Error al actualizar configuración: '${e.message}'.");
      return false;
    }
  }

  /// Abre el selector de fondos de pantalla de Android.
  static Future<bool> openWallpaperPicker() async {
    try {
      final bool result = await _channel.invokeMethod('openWallpaperPicker');
      return result;
    } on PlatformException catch (e) {
      print("Error al abrir el selector: '${e.message}'.");
      return false;
    }
  }
}

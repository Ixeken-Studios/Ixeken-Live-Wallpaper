import 'package:flutter/services.dart';

class WallpaperManager {
  static const MethodChannel _channel = MethodChannel('com.ixeken.wallpaper/media');

  /// Envía la lista de rutas absolutas al lado nativo.
  /// [type] puede ser 'general', 'day', o 'night'.
  static Future<bool> updatePlaylist(List<String> filePaths, {String type = 'general'}) async {
    try {
      final bool result = await _channel.invokeMethod('updatePlaylist', {
        'playlist': filePaths,
        'type': type,
      });
      return result;
    } on PlatformException catch (e) {
      print("Error al actualizar la playlist ($type): '${e.message}'.");
      return false;
    }
  }

  /// Actualiza la configuración global.
  static Future<bool> updateSettings({
    required bool changeOnVisible,
    bool useDayNightMode = false,
    int dayStartHour = 6,
    int nightStartHour = 18,
    bool isDimEnabled = false,
  }) async {
    try {
      final bool result = await _channel.invokeMethod('updateSettings', {
        'changeOnVisible': changeOnVisible,
        'useDayNightMode': useDayNightMode,
        'dayStartHour': dayStartHour,
        'nightStartHour': nightStartHour,
        'isDimEnabled': isDimEnabled,
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

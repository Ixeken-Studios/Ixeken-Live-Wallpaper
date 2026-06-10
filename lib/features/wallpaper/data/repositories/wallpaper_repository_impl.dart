import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/local_wallpaper.dart';
import '../../domain/entities/wallpaper_config.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../models/local_wallpaper_model.dart';
import '../models/wallpaper_config_model.dart';

/// @nodoc
/// Implementación concreta de [WallpaperRepository] utilizando [SharedPreferences].
///
/// Permite almacenar los metadatos de wallpapers y la configuración en formato JSON.
/// Esta implementación es fácilmente reemplazable por Isar o Hive en el futuro.
class WallpaperRepositoryImpl implements WallpaperRepository {
  static const String _keyWallpapers = 'wallpapers_playlist_json';
  static const String _keyConfig = 'wallpaper_config_json';

  final SharedPreferences _prefs;

  /// Constructor que requiere una instancia de [SharedPreferences].
  WallpaperRepositoryImpl(this._prefs);

  @override
  Future<List<LocalWallpaper>> getAllWallpapers() async {
    final List<String>? jsonList = _prefs.getStringList(_keyWallpapers);
    if (jsonList == null) return [];

    return jsonList.map((item) {
      final Map<String, dynamic> json = jsonDecode(item) as Map<String, dynamic>;
      return LocalWallpaperModel.fromJson(json).toEntity();
    }).toList();
  }

  @override
  Future<List<LocalWallpaper>> getActiveWallpapers() async {
    final wallpapers = await getAllWallpapers();
    return wallpapers.where((element) => element.isActive).toList();
  }

  @override
  Future<void> saveWallpaper(LocalWallpaper wallpaper) async {
    final wallpapers = await getAllWallpapers();
    final model = LocalWallpaperModel.fromEntity(wallpaper);

    final index = wallpapers.indexWhere((element) => element.id == wallpaper.id);
    if (index != -1) {
      wallpapers[index] = model;
    } else {
      wallpapers.add(model);
    }

    await _saveList(wallpapers);
  }

  @override
  Future<void> saveAllWallpapers(List<LocalWallpaper> wallpapers) async {
    final models = wallpapers.map((w) => LocalWallpaperModel.fromEntity(w)).toList();
    await _saveList(models);
  }

  @override
  Future<void> deleteWallpaper(int id) async {
    final wallpapers = await getAllWallpapers();
    wallpapers.removeWhere((element) => element.id == id);
    await _saveList(wallpapers);
  }

  @override
  Future<WallpaperConfig> getConfig() async {
    final String? jsonStr = _prefs.getString(_keyConfig);
    if (jsonStr == null) {
      // Configuración predeterminada: Estrategia secuencial sin parámetros extra
      return const WallpaperConfig(
        strategyId: 'sequential',
        extraParams: {},
      );
    }

    final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return WallpaperConfigModel.fromJson(json).toEntity();
  }

  @override
  Future<void> saveConfig(WallpaperConfig config) async {
    final model = WallpaperConfigModel.fromEntity(config);
    final String jsonStr = jsonEncode(model.toJson());
    await _prefs.setString(_keyConfig, jsonStr);
  }

  Future<void> _saveList(List<LocalWallpaper> list) async {
    final List<String> jsonList = list.map((item) {
      final model = LocalWallpaperModel.fromEntity(item);
      return jsonEncode(model.toJson());
    }).toList();

    await _prefs.setStringList(_keyWallpapers, jsonList);
  }
}

import '../entities/local_wallpaper.dart';
import '../entities/wallpaper_config.dart';

/// @nodoc
/// Contrato abstracto para el repositorio de datos de wallpapers.
/// Define las operaciones de persistencia necesarias para gestionar playlists y configuraciones.
abstract class WallpaperRepository {
  /// Obtiene todos los wallpapers almacenados en la base de datos local.
  Future<List<LocalWallpaper>> getAllWallpapers();

  /// Obtiene únicamente los wallpapers marcados como activos.
  Future<List<LocalWallpaper>> getActiveWallpapers();

  /// Guarda o actualiza un wallpaper local.
  Future<void> saveWallpaper(LocalWallpaper wallpaper);

  /// Guarda una lista completa de wallpapers (playlist).
  Future<void> saveAllWallpapers(List<LocalWallpaper> wallpapers);

  /// Elimina un wallpaper de la base de datos por su identificador único.
  Future<void> deleteWallpaper(int id);

  /// Obtiene la configuración actual del rotador de wallpapers.
  Future<WallpaperConfig> getConfig();

  /// Guarda o actualiza la configuración del rotador.
  Future<void> saveConfig(WallpaperConfig config);
}

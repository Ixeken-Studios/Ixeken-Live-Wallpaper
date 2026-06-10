import '../entities/local_wallpaper.dart';
import '../entities/current_state.dart';

/// @nodoc
/// Interfaz para el patrón Estrategia de selección de wallpapers.
/// Permite definir reglas personalizadas para decidir cuál será el siguiente wallpaper a renderizar.
abstract class WallpaperSelectionStrategy {
  /// Identificador único de esta estrategia (ej. 'sequential', 'shuffle').
  String get id;

  /// Selecciona el siguiente wallpaper a mostrar basándose en la lista disponible y el estado actual.
  /// Retorna `null` si la lista está vacía.
  LocalWallpaper? selectNext(List<LocalWallpaper> list, CurrentState state);
}

import 'local_wallpaper.dart';

/// @nodoc
/// Representa el estado actual del dispositivo y la app utilizado por las estrategias de selección.
class CurrentState {
  /// Wallpaper que se encuentra activo actualmente en pantalla (si existe).
  final LocalWallpaper? currentWallpaper;

  /// Fecha y hora actual del dispositivo para lógicas temporales.
  final DateTime dateTime;

  /// Brillo o tema actual del sistema ('light', 'dark' o 'unknown').
  final String systemTheme;

  /// Constructor constante.
  const CurrentState({
    this.currentWallpaper,
    required this.dateTime,
    required this.systemTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentState &&
          runtimeType == other.runtimeType &&
          currentWallpaper == other.currentWallpaper &&
          dateTime == other.dateTime &&
          systemTheme == other.systemTheme;

  @override
  int get hashCode =>
      currentWallpaper.hashCode ^ dateTime.hashCode ^ systemTheme.hashCode;
}

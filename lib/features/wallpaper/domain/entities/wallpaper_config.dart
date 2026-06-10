/// @nodoc
/// Entidad de configuración centralizada para el comportamiento del rotador de wallpapers.
class WallpaperConfig {
  /// Identificador único de la estrategia de selección activa (ej. 'sequential', 'shuffle').
  final String strategyId;

  /// Mapa flexible para almacenar parámetros de personalización expandibles.
  final Map<String, dynamic> extraParams;

  /// Constructor constante.
  const WallpaperConfig({
    required this.strategyId,
    required this.extraParams,
  });

  /// Retorna una copia de la configuración actual con campos opcionalmente modificados.
  WallpaperConfig copyWith({
    String? strategyId,
    Map<String, dynamic>? extraParams,
  }) {
    return WallpaperConfig(
      strategyId: strategyId ?? this.strategyId,
      extraParams: extraParams ?? Map<String, dynamic>.from(this.extraParams),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperConfig &&
          runtimeType == other.runtimeType &&
          strategyId == other.strategyId &&
          extraParams == other.extraParams;

  @override
  int get hashCode => strategyId.hashCode ^ extraParams.hashCode;
}

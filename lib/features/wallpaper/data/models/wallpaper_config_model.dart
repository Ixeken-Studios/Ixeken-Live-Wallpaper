import '../../domain/entities/wallpaper_config.dart';

/// @nodoc
/// Modelo de datos para [WallpaperConfig] con soporte para serialización y persistencia.
///
/// Nota: Para usar con Hive, descomentar las anotaciones `@HiveType` y `@HiveField`.
/// Para usar con Isar, añadir la anotación `@Collection`.
// @HiveType(typeId: 1)
class WallpaperConfigModel extends WallpaperConfig {
  /// Constructor constante.
  const WallpaperConfigModel({
    required super.strategyId,
    required super.extraParams,
  });

  /// Crea un modelo a partir de una entidad del dominio.
  factory WallpaperConfigModel.fromEntity(WallpaperConfig entity) {
    return WallpaperConfigModel(
      strategyId: entity.strategyId,
      extraParams: entity.extraParams,
    );
  }

  /// Convierte el modelo a su entidad del dominio correspondiente.
  WallpaperConfig toEntity() {
    return WallpaperConfig(
      strategyId: strategyId,
      extraParams: extraParams,
    );
  }

  /// Deserializa el modelo desde un mapa JSON.
  factory WallpaperConfigModel.fromJson(Map<String, dynamic> json) {
    return WallpaperConfigModel(
      strategyId: json['strategyId'] as String,
      extraParams: Map<String, dynamic>.from(json['extraParams'] as Map),
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'strategyId': strategyId,
      'extraParams': extraParams,
    };
  }
}

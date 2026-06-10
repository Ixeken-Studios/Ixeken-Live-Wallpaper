import '../../domain/entities/local_wallpaper.dart';

/// @nodoc
/// Modelo de datos para [LocalWallpaper] con soporte para serialización y persistencia.
///
/// Nota: Para usar con Hive, descomentar las anotaciones `@HiveType` y `@HiveField`.
/// Para usar con Isar, añadir `@Collection` y cambiar `id` por `Id? id;`.
// @HiveType(typeId: 0)
class LocalWallpaperModel extends LocalWallpaper {
  /// Constructor constante.
  const LocalWallpaperModel({
    required super.id,
    required super.localPath,
    required super.orderIndex,
    required super.isActive,
  });

  /// Crea un modelo a partir de una entidad del dominio.
  factory LocalWallpaperModel.fromEntity(LocalWallpaper entity) {
    return LocalWallpaperModel(
      id: entity.id,
      localPath: entity.localPath,
      orderIndex: entity.orderIndex,
      isActive: entity.isActive,
    );
  }

  /// Convierte el modelo a su entidad del dominio correspondiente.
  LocalWallpaper toEntity() {
    return LocalWallpaper(
      id: id,
      localPath: localPath,
      orderIndex: orderIndex,
      isActive: isActive,
    );
  }

  /// Deserializa el modelo desde un mapa JSON.
  factory LocalWallpaperModel.fromJson(Map<String, dynamic> json) {
    return LocalWallpaperModel(
      id: json['id'] as int,
      localPath: json['localPath'] as String,
      orderIndex: json['orderIndex'] as int,
      isActive: json['isActive'] as bool,
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localPath': localPath,
      'orderIndex': orderIndex,
      'isActive': isActive,
    };
  }
}

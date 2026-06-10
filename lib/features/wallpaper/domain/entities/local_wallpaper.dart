/// @nodoc
/// Entidad que representa un wallpaper local importado en el dispositivo.
class LocalWallpaper {
  /// Identificador único para el wallpaper.
  final int id;

  /// Ruta de acceso absoluta al archivo local en el almacenamiento interno de la app.
  final String localPath;

  /// Índice numérico que define el orden de aparición en la secuencia.
  final int orderIndex;

  /// Indica si el wallpaper está activo dentro de la rotación actual.
  final bool isActive;

  /// Constructor constante para promover la inmutabilidad de la entidad.
  const LocalWallpaper({
    required this.id,
    required this.localPath,
    required this.orderIndex,
    required this.isActive,
  });

  /// Retorna una copia de la entidad actual con campos opcionalmente modificados.
  LocalWallpaper copyWith({
    int? id,
    String? localPath,
    int? orderIndex,
    bool? isActive,
  }) {
    return LocalWallpaper(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalWallpaper &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          localPath == other.localPath &&
          orderIndex == other.orderIndex &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^ localPath.hashCode ^ orderIndex.hashCode ^ isActive.hashCode;
}

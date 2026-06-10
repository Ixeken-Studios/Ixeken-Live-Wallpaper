import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// @nodoc
/// Servicio encargado de importar y comprimir imágenes locales para optimizar el consumo de RAM.
class ImageImportService {
  static const MethodChannel _channel = MethodChannel('com.ixeken.wallpaper/media');
  
  final String? _overrideDirectoryPath;

  /// Constructor. Permite inyectar una ruta de directorio personalizada (útil para pruebas unitarias).
  ImageImportService({String? overrideDirectoryPath})
      : _overrideDirectoryPath = overrideDirectoryPath;

  /// Obtiene la ruta del almacenamiento interno permanente de la app.
  Future<String> _getAppDirectory() async {
    if (_overrideDirectoryPath != null) {
      return _overrideDirectoryPath;
    }
    try {
      final String? path = await _channel.invokeMethod<String>('getAppDirectory');
      if (path == null) {
        throw const OSError('No se pudo obtener la ruta del directorio de la aplicación.');
      }
      return path;
    } on PlatformException catch (e) {
      throw OSError('Error de canal de plataforma: ${e.message}');
    }
  }

  /// Importa una imagen desde una URI temporal (ej. Photo Picker), la comprime y la
  /// guarda permanentemente en el almacenamiento local privado de la aplicación.
  ///
  /// Redimensiona la imagen a un ancho máximo de 1080px (manteniendo el aspecto)
  /// para evitar picos de memoria Out-Of-Memory (OOM).
  Future<File> importAndCompressImage(String pickerPath) async {
    final inputFile = File(pickerPath);
    if (!await inputFile.exists()) {
      throw FileSystemException('El archivo de origen no existe.', pickerPath);
    }

    // 1. Obtener directorio de destino
    final appDir = await _getAppDirectory();
    final targetDirectory = Directory('$appDir/wallpapers_processed');
    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    // 2. Leer bytes de la imagen original
    final Uint8List originalBytes = await inputFile.readAsBytes();

    // 3. Decodificar y redimensionar la imagen a un ancho de 1080px usando ui.instantiateImageCodec.
    // Esto se ejecuta de forma optimizada en los hilos nativos del motor gráfico de Flutter.
    final ui.Codec codec = await ui.instantiateImageCodec(
      originalBytes,
      targetWidth: 1080,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    // 4. Convertir a formato PNG comprimido
    final ByteData? byteData = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw const FormatException('Fallo al comprimir y codificar los bytes de la imagen.');
    }

    final Uint8List compressedBytes = byteData.buffer.asUint8List();

    // 5. Guardar permanentemente en el almacenamiento local de la app
    final String fileName = 'wallpaper_${DateTime.now().microsecondsSinceEpoch}.png';
    final File destinationFile = File('${targetDirectory.path}/$fileName');
    await destinationFile.writeAsBytes(compressedBytes);

    // Liberar recursos de la GPU
    resizedImage.dispose();

    return destinationFile;
  }
}

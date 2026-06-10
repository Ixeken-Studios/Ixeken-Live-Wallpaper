import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'image_processor.dart';

/// @nodoc
/// Procesador que aplica un filtro de desenfoque Gaussiano nativo sobre una imagen.
///
/// Utiliza el motor gráfico de Flutter (Canvas y ImageFilter) para un procesamiento
/// optimizado por hardware sin dependencias adicionales.
class BlurProcessor implements ImageProcessor {
  /// Intensidad del desenfoque (radio sigma).
  final double sigma;

  /// Constructor.
  BlurProcessor({required this.sigma});

  @override
  Future<File> process(File input) async {
    if (sigma <= 0) return input;

    final Uint8List bytes = await input.readAsBytes();
    
    // Decodificar la imagen original
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    // Crear un lienzo virtual para dibujar con desenfoque
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Paint paint = ui.Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

    // Dibujar la imagen sobre el canvas aplicando el filtro de blur
    canvas.drawImage(originalImage, ui.Offset.zero, paint);
    
    final ui.Picture picture = recorder.endRecording();
    final ui.Image blurredImage = await picture.toImage(
      originalImage.width,
      originalImage.height,
    );

    // Convertir el canvas renderizado de vuelta a bytes PNG
    final ByteData? byteData = await blurredImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw const FormatException('Fallo al exportar la imagen desenfocada.');
    }

    final Uint8List blurredBytes = byteData.buffer.asUint8List();

    // Guardar el archivo resultante en el mismo directorio con el prefijo "blurred_"
    final String directoryPath = input.parent.path;
    final String fileName = 'blurred_${DateTime.now().microsecondsSinceEpoch}.png';
    final File outputFile = File('$directoryPath/$fileName');
    await outputFile.writeAsBytes(blurredBytes);

    // Liberar recursos nativos
    originalImage.dispose();
    blurredImage.dispose();

    return outputFile;
  }
}

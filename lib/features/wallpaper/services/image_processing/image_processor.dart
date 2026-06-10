import 'dart:io';

/// @nodoc
/// Interfaz abstracta para procesar imágenes en el pipeline estético.
///
/// Permite encadenar transformaciones visuales (filtros, desenfoques, colorizaciones)
/// sobre archivos físicos antes de establecerlos como fondo de pantalla.
abstract class ImageProcessor {
  /// Procesa el archivo de imagen [input] y retorna un nuevo [File] con los cambios aplicados.
  Future<File> process(File input);
}

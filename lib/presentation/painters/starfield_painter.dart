import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para la animación de viaje estelar (Starfield).
class StarfieldPainter extends CustomPainter {
  /// Lista de estrellas activas.
  final List<StarState> stars;

  /// Velocidad del viaje estelar.
  final double speed;

  /// Constructor.
  StarfieldPainter(this.stars, this.speed);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF030206));
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    for (var s in stars) {
      final x2d = (s.x / s.z) * cx + cx;
      final y2d = (s.y / s.z) * cy + cy;
      
      final px2d = (s.x / s.prevZ) * cx + cx;
      final py2d = (s.y / s.prevZ) * cy + cy;
      
      if (x2d < 0 || x2d > size.width || y2d < 0 || y2d > size.height) {
        continue;
      }
      
      final thickness = (1.0 - (s.z / 500.0)) * 3.5 + 0.8;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = thickness;
        
      if (speed > 8.0) {
        canvas.drawLine(Offset(px2d, py2d), Offset(x2d, y2d), paint);
      } else {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x2d, y2d), thickness * 0.7, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// @nodoc
/// Modela el estado de una estrella en el Starfield.
class StarState {
  /// Coordenada espacial X.
  double x;

  /// Coordenada espacial Y.
  double y;

  /// Coordenada espacial Z (profundidad).
  double z;

  /// Coordenada espacial Z previa (para dibujar líneas de movimiento).
  double prevZ;

  /// Color de la estrella.
  final Color color;
  
  /// Constructor.
  StarState({required this.x, required this.y, required this.z, required this.prevZ, required this.color});
}

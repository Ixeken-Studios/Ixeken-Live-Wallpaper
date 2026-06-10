import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para la animación de Gradiente Líquido.
class LiquidGradientPainter extends CustomPainter {
  /// Tiempo acumulado para la animación.
  final double time;

  /// Constructor.
  LiquidGradientPainter(this.time);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF080512));
    
    final x1 = size.width * 0.35 + math.sin(time) * (size.width * 0.18);
    final y1 = size.height * 0.3 + math.cos(time * 0.9) * (size.height * 0.12);
    drawBlob(canvas, x1, y1, size.width * 0.65, const Color(0xFF6366F1), 0.33);
    
    final x2 = size.width * 0.65 + math.cos(time * 1.1) * (size.width * 0.2);
    final y2 = size.height * 0.7 + math.sin(time * 0.8) * (size.height * 0.15);
    drawBlob(canvas, x2, y2, size.width * 0.75, const Color(0xFFEC4899), 0.28);
    
    final x3 = size.width * 0.5 + math.sin(time * 0.7) * (size.width * 0.22);
    final y3 = size.height * 0.5 + math.cos(time * 1.3) * (size.height * 0.18);
    drawBlob(canvas, x3, y3, size.width * 0.6, const Color(0xFF06B6D4), 0.26);
    
    final x4 = size.width * 0.6 + math.cos(time * 0.6) * (size.width * 0.25);
    final y4 = size.height * 0.4 + math.sin(time * 0.7) * (size.height * 0.2);
    drawBlob(canvas, x4, y4, size.width * 0.7, const Color(0xFF8B5CF6), 0.3);
  }
  
  /// Dibuja una mancha de color radial difusa.
  void drawBlob(ui.Canvas canvas, double x, double y, double radius, Color color, double opacity) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x, y),
        radius,
        [color.withValues(alpha: opacity), Colors.transparent],
      );
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

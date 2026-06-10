import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para la animación estética de Vaporwave.
class VaporwavePainter extends CustomPainter {
  /// Tiempo acumulado para la oscilación de la rejilla.
  final double time;

  /// Constructor.
  VaporwavePainter(this.time);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final w = size.width;
    final h = size.height;
    if (w == 0 || h == 0) return;
    
    final horizon = h * 0.48;
    
    // Sky
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, horizon),
        [const Color(0xFF1D0030), const Color(0xFFA80077), const Color(0xFFFF5E62)],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, w, horizon), skyPaint);
    
    // Sun
    final sunRadius = w * 0.28;
    final sunCx = w / 2;
    final sunCy = horizon - 20;
    
    canvas.save();
    canvas.clipRect(ui.Rect.fromLTWH(sunCx - sunRadius, sunCy - sunRadius, sunRadius * 2, sunRadius * 2));
    
    final sunPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(sunCx, sunCy - sunRadius),
        Offset(sunCx, sunCy + sunRadius),
        [const Color(0xFFFFD97D), const Color(0xFFFF1493)],
      );
    canvas.drawCircle(Offset(sunCx, sunCy), sunRadius, sunPaint);
    
    final stripePaint = Paint()..color = const Color(0xFFA80077);
    double stripeY = sunCy + 10;
    double stripeH = 3.0;
    while (stripeY < sunCy + sunRadius) {
      canvas.drawRect(ui.Rect.fromLTWH(sunCx - sunRadius, stripeY, sunRadius * 2, stripeH), stripePaint);
      stripeY += stripeH + 6.0;
      stripeH += 1.5;
    }
    canvas.restore();
    
    // Ground
    final groundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, horizon),
        Offset(0, h),
        [const Color(0xFF090014), Colors.black],
      );
    canvas.drawRect(ui.Rect.fromLTWH(0, horizon, w, h - horizon), groundPaint);
    
    // Grid lines
    final paintGrid = Paint()
      ..color = const Color(0xFFFF007F)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
      
    final numVerticalLines = 10;
    for (int i = 0; i <= numVerticalLines; i++) {
      final ratio = i / numVerticalLines;
      final targetX = (ratio - 0.5) * w * 3 + (w / 2);
      canvas.drawLine(Offset(w / 2, horizon), Offset(targetX, h), paintGrid);
    }
    
    final gridPhase = (time * 0.8) % 1.0;
    final groundHeight = h - horizon;
    final numHorizontalLines = 10;
    for (int i = 0; i <= numHorizontalLines; i++) {
      final progress = (i - gridPhase) / numHorizontalLines;
      if (progress < 0) continue;
      
      final expProgress = math.pow(progress, 2.2);
      final gridY = horizon + expProgress * groundHeight;
      
      paintGrid.color = const Color(0xFFFF007F).withValues(alpha: progress.clamp(0.0, 1.0));
      paintGrid.strokeWidth = progress * 2.0 + 0.3;
      canvas.drawLine(Offset(0, gridY), Offset(w, gridY), paintGrid);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

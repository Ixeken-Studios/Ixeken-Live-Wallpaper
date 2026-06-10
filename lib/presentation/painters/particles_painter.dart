import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para el fondo animado de partículas flotantes.
class ParticlesPainter extends CustomPainter {
  /// Lista de estados de las partículas.
  final List<ParticleState> particles;

  /// Constructor.
  ParticlesPainter(this.particles);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0F0F1B));
    
    final paint = Paint()..isAntiAlias = true;
    for (var p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      
      if (p.x < 0 || p.x > size.width) p.vx *= -1;
      if (p.y < 0 || p.y > size.height) p.vy *= -1;
      
      p.x = p.x.clamp(0.0, size.width);
      p.y = p.y.clamp(0.0, size.height);
      
      paint.color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// @nodoc
/// Modela el estado físico y visual de una partícula individual.
class ParticleState {
  /// Coordenada horizontal.
  double x;

  /// Coordenada vertical.
  double y;

  /// Velocidad en eje X.
  double vx;

  /// Velocidad en eje Y.
  double vy;

  /// Radio de la partícula.
  final double radius;

  /// Color de dibujo de la partícula.
  final Color color;
  
  /// Constructor.
  ParticleState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

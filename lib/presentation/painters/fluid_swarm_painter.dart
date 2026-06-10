import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante para la simulación física de enjambre de fluidos.
class FluidSwarmPainter extends CustomPainter {
  /// Lista de partículas del fluido.
  final List<FluidParticleState> particles;

  /// Constructor.
  FluidSwarmPainter(this.particles);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF06050F));
    
    final paintLine = Paint()..isAntiAlias = true;
    final paintHead = Paint()..isAntiAlias = true..style = PaintingStyle.fill;
    
    for (var p in particles) {
      paintLine.color = p.color.withValues(alpha: 0.5);
      paintLine.strokeWidth = p.radius * 0.8;
      canvas.drawLine(Offset(p.px, p.py), Offset(p.x, p.y), paintLine);
      
      paintHead.color = p.color.withValues(alpha: 0.9);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paintHead);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// @nodoc
/// Modela el estado de una partícula física de fluido interactivo.
class FluidParticleState {
  /// Posición X actual.
  double x;

  /// Posición Y actual.
  double y;

  /// Posición X previa (para dibujar estelas).
  double px;

  /// Posición Y previa (para dibujar estelas).
  double py;

  /// Velocidad en eje X.
  double vx;

  /// Velocidad en eje Y.
  double vy;

  /// Radio de la partícula.
  final double radius;

  /// Color de dibujo de la partícula.
  final Color color;
  
  /// Constructor.
  FluidParticleState({
    required this.x,
    required this.y,
    required this.px,
    required this.py,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

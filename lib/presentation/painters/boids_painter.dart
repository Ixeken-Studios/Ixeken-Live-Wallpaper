import 'package:flutter/material.dart';
import 'dart:math' as math;

class Boid {
  double x;
  double y;
  double vx;
  double vy;
  final List<Offset> history = [];

  Boid({required this.x, required this.y, required this.vx, required this.vy});
}

class BoidsPainter extends CustomPainter {
  final List<Boid> boids;

  BoidsPainter(this.boids);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF04060E), BlendMode.srcOver);

    final paint = Paint()..style = PaintingStyle.fill;
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (var b in boids) {
      // Dibujar estela de partículas de luz (luces que se disipan)
      for (int i = 0; i < b.history.length; i++) {
        final pos = b.history[i];
        final factor = i / b.history.length; // 0 (antiguo) a 1 (reciente)
        
        particlePaint.color = const Color(0xFF00FFCC)
            .withValues(alpha: factor * 0.28);
        final r = factor * 3.5;
        
        canvas.drawCircle(pos, r, particlePaint);
      }

      // Dibujar boid con flecha estilizada
      final angle = math.atan2(b.vy, b.vx);
      final speed = math.sqrt(b.vx * b.vx + b.vy * b.vy);
      
      canvas.save();
      canvas.translate(b.x, b.y);
      canvas.rotate(angle);

      final path = Path()
        ..moveTo(7, 0)
        ..lineTo(-6, -5)
        ..lineTo(-4, 0)
        ..lineTo(-6, 5)
        ..close();

      // Color cambia de azul-cian a verde-neón según velocidad
      paint.color = Color.lerp(
        const Color(0xFF6366F1), // Azul Indigo
        const Color(0xFF00FFCC), // Verde menta brillante
        (speed / 4.0).clamp(0.0, 1.0),
      )!;

      // Sutil brillo detrás del boid
      final glowPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(Offset.zero, 6.0, glowPaint);

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BoidsPainter oldDelegate) => true;
}

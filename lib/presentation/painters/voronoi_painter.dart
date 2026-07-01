import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoronoiPoint {
  double x;
  double y;
  double vx;
  double vy;
  Color color;

  VoronoiPoint({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  });
}

class VoronoiPainter extends CustomPainter {
  final List<VoronoiPoint> points;
  final double time;

  VoronoiPainter(this.points, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo espacial negro limpio
    canvas.drawColor(const Color(0xFF030206), BlendMode.srcOver);

    if (points.isEmpty) return;

    // Dibujar las líneas finas de interconexión (constelación)
    final linePaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final dx = points[i].x - points[j].x;
        final dy = points[i].y - points[j].y;
        final dist = math.sqrt(dx * dx + dy * dy);
        
        // Conectar solo si están cerca, con desvanecimiento por distancia
        if (dist < 140.0) {
          final factor = (1.0 - (dist / 140.0)).clamp(0.0, 1.0);
          linePaint.color = Colors.white.withValues(alpha: factor * 0.25);
          canvas.drawLine(
            Offset(points[i].x, points[i].y),
            Offset(points[j].x, points[j].y),
            linePaint,
          );
        }
      }
    }

    // Dibujar los astros (estrellas) con brillo suave
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var p in points) {
      // Glow estelar
      glowPaint.color = Colors.white.withValues(alpha: 0.15);
      canvas.drawCircle(Offset(p.x, p.y), 9.0, glowPaint);
      
      glowPaint.color = p.color.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(p.x, p.y), 4.5, glowPaint);

      // Núcleo blanco brillante
      canvas.drawCircle(Offset(p.x, p.y), 1.5, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant VoronoiPainter oldDelegate) => true;
}

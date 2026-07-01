import 'package:flutter/material.dart';
import 'dart:math' as math;

class PachinkoBall {
  double x;
  double y;
  double vx;
  double vy;
  Color color;

  PachinkoBall({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  });
}

class PachinkoPin {
  final double x;
  final double y;
  final double radius;

  PachinkoPin({required this.x, required this.y, this.radius = 4.0});
}

class PachinkoSpark {
  double x;
  double y;
  double vx;
  double vy;
  double alpha;
  Color color;

  PachinkoSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.alpha,
    required this.color,
  });
}

class PachinkoPainter extends CustomPainter {
  final List<PachinkoBall> balls;
  final List<PachinkoPin> pins;
  final List<PachinkoSpark> sparks;

  PachinkoPainter({
    required this.balls,
    required this.pins,
    required this.sparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF030308), BlendMode.srcOver);

    // Dibujar los pines (pins) fijos
    final pinPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    final pinGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    for (var pin in pins) {
      canvas.drawCircle(Offset(pin.x, pin.y), pin.radius + 1.5, pinGlow);
      canvas.drawCircle(Offset(pin.x, pin.y), pin.radius, pinPaint);
    }

    // Dibujar las chispas físicas de colisión
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (var spark in sparks) {
      sparkPaint.color = spark.color.withValues(alpha: spark.alpha);
      canvas.drawCircle(Offset(spark.x, spark.y), 1.8, sparkPaint);
    }

    // Dibujar las canicas de neón
    final ballPaint = Paint()..style = PaintingStyle.fill;
    final ballGlow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    for (var ball in balls) {
      ballGlow.color = ball.color.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(ball.x, ball.y), 9.0, ballGlow);

      ballPaint.color = ball.color;
      canvas.drawCircle(Offset(ball.x, ball.y), 5.0, ballPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PachinkoPainter oldDelegate) => true;
}

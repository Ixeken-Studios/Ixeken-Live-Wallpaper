import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FloralPainter extends CustomPainter {
  final List<PetalState> petals;
  final double windX;
  final double windY;

  FloralPainter({required this.petals, this.windX = 0.0, this.windY = 0.0});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0F0F1B));

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (var p in petals) {
      p.x += p.vx + windX * p.windSensitivity;
      p.y += p.vy + windY * p.windSensitivity;

      p.swayTime += p.swaySpeed;
      final double sway = math.sin(p.swayTime) * p.swayAmplitude;
      final double drawX = p.x + sway;

      p.angle += p.rotationSpeed;

      if (p.y > size.height + 20) {
        p.y = -20;
        p.x = math.Random().nextDouble() * size.width;
        p.swayTime = math.Random().nextDouble() * 10;
      }
      if (p.x < -20) {
        p.x = size.width + 20;
      } else if (p.x > size.width + 20) {
        p.x = -20;
      }

      canvas.save();
      canvas.translate(drawX, p.y);
      canvas.rotate(p.angle);
      
      final double scaleX = math.cos(p.swayTime * 0.5).abs() * 0.6 + 0.4;
      canvas.scale(scaleX * p.scale, p.scale);

      paint.color = p.color;

      final path = Path();
      path.moveTo(0, -10);
      path.quadraticBezierTo(10, -5, 5, 10);
      path.quadraticBezierTo(0, 15, -5, 10);
      path.quadraticBezierTo(-10, -5, 0, -10);
      path.close();

      canvas.drawPath(path, paint);

      final veinPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = true;

      final veinPath = Path();
      veinPath.moveTo(0, 10);
      veinPath.quadraticBezierTo(2, 0, 0, -5);
      canvas.drawPath(veinPath, veinPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PetalState {
  double x;
  double y;
  double vx;
  double vy;
  double scale;
  double angle;
  double rotationSpeed;
  double swayTime;
  double swaySpeed;
  double swayAmplitude;
  double windSensitivity;
  Color color;

  PetalState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.scale,
    required this.angle,
    required this.rotationSpeed,
    required this.swayTime,
    required this.swaySpeed,
    required this.swayAmplitude,
    required this.windSensitivity,
    required this.color,
  });

  factory PetalState.random(double width, double height) {
    final rand = math.Random();
    
    final colors = [
      const Color(0xFFFFB7B2), 
      const Color(0xFFFFC6FF), 
      const Color(0xFFFF85A1), 
      const Color(0xFFF7CAD0), 
      const Color(0xFFF9BEC7), 
    ];

    return PetalState(
      x: rand.nextDouble() * width,
      y: rand.nextDouble() * height - height, 
      vx: (rand.nextDouble() - 0.5) * 0.4, 
      vy: rand.nextDouble() * 0.8 + 0.6,    
      scale: rand.nextDouble() * 0.7 + 0.5,
      angle: rand.nextDouble() * math.pi * 2,
      rotationSpeed: (rand.nextDouble() - 0.5) * 0.02,
      swayTime: rand.nextDouble() * 10,
      swaySpeed: rand.nextDouble() * 0.03 + 0.015,
      swayAmplitude: rand.nextDouble() * 15 + 8,
      windSensitivity: rand.nextDouble() * 0.5 + 0.7,
      color: colors[rand.nextInt(colors.length)],
    );
  }
}

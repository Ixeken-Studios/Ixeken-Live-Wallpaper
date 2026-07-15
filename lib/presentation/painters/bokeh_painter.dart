import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BokehPainter extends CustomPainter {
  final List<BokehState> lights;
  final double animationVal;

  BokehPainter({required this.lights, required this.animationVal});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // Elegant dark violet-blue background
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0A0915));

    for (var b in lights) {
      // Slow float movement
      b.x += b.vx;
      b.y += b.vy;

      // Bounce off boundaries slightly beyond screen to keep it smooth
      if (b.x < -b.radius) {
        b.x = size.width + b.radius;
      } else if (b.x > size.width + b.radius) {
        b.x = -b.radius;
      }

      if (b.y < -b.radius) {
        b.y = size.height + b.radius;
      } else if (b.y > size.height + b.radius) {
        b.y = -b.radius;
      }

      // Smooth pulsing effect over time
      b.pulseTime += b.pulseSpeed;
      final double pulse = math.sin(b.pulseTime) * 0.2 + 0.8; // range [0.6, 1.0]
      final double currentRadius = b.radius * pulse;

      // Draw glowing radial gradient bokeh circle
      final Paint paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;

      // Define radial gradient to simulate a glowing light bulb
      final gradient = ui.Gradient.radial(
        Offset(b.x, b.y),
        currentRadius,
        [
          b.color.withValues(alpha: b.alpha * 0.7),
          b.color.withValues(alpha: b.alpha * 0.35),
          b.color.withValues(alpha: 0.0),
        ],
        [0.0, 0.4, 1.0],
      );
      paint.shader = gradient;

      canvas.drawCircle(Offset(b.x, b.y), currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BokehState {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double alpha;
  double pulseTime;
  double pulseSpeed;
  Color color;

  BokehState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.alpha,
    required this.pulseTime,
    required this.pulseSpeed,
    required this.color,
  });

  factory BokehState.random(double width, double height) {
    final rand = math.Random();
    
    // Aesthetic neon/pastel tones (warm amber, gold, lavender violet, soft cyan)
    final colors = [
      const Color(0xFFFFB347), // Soft amber orange
      const Color(0xFFB39DDB), // Lavender violet
      const Color(0xFFFFD54F), // Pale golden yellow
      const Color(0xFF4DD0E1), // Cyan/Teal
      const Color(0xFFF48FB1), // Warm rose pink
    ];

    return BokehState(
      x: rand.nextDouble() * width,
      y: rand.nextDouble() * height,
      vx: (rand.nextDouble() - 0.5) * 0.35,
      vy: (rand.nextDouble() - 0.5) * 0.35,
      radius: rand.nextDouble() * 60 + 35, // Medium to large circles
      alpha: rand.nextDouble() * 0.25 + 0.15, // Highly translucent
      pulseTime: rand.nextDouble() * 10,
      pulseSpeed: rand.nextDouble() * 0.02 + 0.01,
      color: colors[rand.nextInt(colors.length)],
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AuraPainter extends CustomPainter {
  final List<AuraBlobState> blobs;
  final Offset? touchPoint;

  AuraPainter({required this.blobs, this.touchPoint});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // Holographic deep night canvas
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF07050E));

    for (var b in blobs) {
      // Flow toward touch point or wander
      if (touchPoint != null) {
        final double dx = touchPoint!.dx - b.x;
        final double dy = touchPoint!.dy - b.y;
        final double dist = math.sqrt(dx * dx + dy * dy);
        
        if (dist > 1.0) {
          // Attract blobs smoothly
          b.vx += (dx / dist) * 0.08;
          b.vy += (dy / dist) * 0.08;
        }
      } else {
        // Natural wandering noise/inertia
        b.vx += (math.Random().nextDouble() - 0.5) * 0.05;
        b.vy += (math.Random().nextDouble() - 0.5) * 0.05;
      }

      // Max speed limit
      b.vx = b.vx.clamp(-1.2, 1.2);
      b.vy = b.vy.clamp(-1.2, 1.2);

      b.x += b.vx;
      b.y += b.vy;

      // Friction
      b.vx *= 0.99;
      b.vy *= 0.99;

      // Keep inside bounds
      if (b.x < -b.radius * 0.5) b.x = size.width + b.radius * 0.5;
      if (b.x > size.width + b.radius * 0.5) b.x = -b.radius * 0.5;
      if (b.y < -b.radius * 0.5) b.y = size.height + b.radius * 0.5;
      if (b.y > size.height + b.radius * 0.5) b.y = -b.radius * 0.5;

      // Pulse radius slightly over time
      b.pulsePhase += 0.005;
      final double currentRadius = b.radius * (1.0 + math.sin(b.pulsePhase) * 0.08);

      // Draw large radial blob with high translucency blending
      final Paint blobPaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen; // Screens together to create holographic mix

      final gradient = ui.Gradient.radial(
        Offset(b.x, b.y),
        currentRadius,
        [
          b.color.withValues(alpha: 0.35),
          b.color.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
      blobPaint.shader = gradient;

      canvas.drawCircle(Offset(b.x, b.y), currentRadius, blobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AuraBlobState {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double pulsePhase;
  Color color;

  AuraBlobState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.pulsePhase,
    required this.color,
  });

  factory AuraBlobState.random(double width, double height) {
    final rand = math.Random();
    
    // Curated high contrast holographic color spectrum
    final colors = [
      const Color(0xFFFF007F), // Vivid hot pink
      const Color(0xFF7F00FF), // Violet purple
      const Color(0xFF00F0FF), // Neon cyan
      const Color(0xFFFFD700), // Vibrant gold
    ];

    return AuraBlobState(
      x: rand.nextDouble() * width,
      y: rand.nextDouble() * height,
      vx: (rand.nextDouble() - 0.5) * 0.4,
      vy: (rand.nextDouble() - 0.5) * 0.4,
      radius: rand.nextDouble() * 100 + 130, // Large blobs
      pulsePhase: rand.nextDouble() * 10,
      color: colors[rand.nextInt(colors.length)],
    );
  }
}

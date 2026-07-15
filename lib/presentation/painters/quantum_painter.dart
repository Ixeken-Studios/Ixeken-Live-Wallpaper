import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class QuantumPainter extends CustomPainter {
  final List<QuantumNodeState> nodes;
  final Offset? gravityPoint;

  QuantumPainter({required this.nodes, this.gravityPoint});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // Deep dark quantum space background
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF03020A));

    final paintNode = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // 1. Update positions and apply gravity
    for (var n in nodes) {
      if (gravityPoint != null) {
        // Draw gravity pull vector
        final double dx = gravityPoint!.dx - n.x;
        final double dy = gravityPoint!.dy - n.y;
        final double dist = math.sqrt(dx * dx + dy * dy);
        
        if (dist > 1.0 && dist < 300) {
          // Attract nodes
          final double force = (300 - dist) / 300 * 0.45;
          n.vx += (dx / dist) * force;
          n.vy += (dy / dist) * force;
        }
      }

      // Add speed limits
      n.vx = n.vx.clamp(-2.5, 2.5);
      n.vy = n.vy.clamp(-2.5, 2.5);

      n.x += n.vx;
      n.y += n.vy;

      // Friction
      n.vx *= 0.98;
      n.vy *= 0.98;

      // Bounce off screen boundaries
      if (n.x < 0 || n.x > size.width) {
        n.vx *= -1;
        n.x = n.x.clamp(0, size.width);
      }
      if (n.y < 0 || n.y > size.height) {
        n.vy *= -1;
        n.y = n.y.clamp(0, size.height);
      }
    }

    // 2. Draw connections (lines)
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final n1 = nodes[i];
        final n2 = nodes[j];
        
        final double dx = n2.x - n1.x;
        final double dy = n2.y - n1.y;
        final double dist = math.sqrt(dx * dx + dy * dy);

        if (dist < 100) {
          final double alpha = (1.0 - (dist / 100)).clamp(0.0, 1.0);
          paintLine.strokeWidth = 1.2 * alpha;
          
          // Draw connection with linear gradient connecting node colors
          paintLine.shader = ui.Gradient.linear(
            Offset(n1.x, n1.y),
            Offset(n2.x, n2.y),
            [
              n1.color.withValues(alpha: alpha * 0.6),
              n2.color.withValues(alpha: alpha * 0.6),
            ],
          );

          canvas.drawLine(Offset(n1.x, n1.y), Offset(n2.x, n2.y), paintLine);
        }
      }
    }

    // 3. Draw nodes
    for (var n in nodes) {
      // Node core
      paintNode.shader = null;
      paintNode.color = n.color;
      canvas.drawCircle(Offset(n.x, n.y), n.radius, paintNode);

      // Node aura glow
      final glowPaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;
      
      final glowGrad = ui.Gradient.radial(
        Offset(n.x, n.y),
        n.radius * 3.5,
        [n.color.withValues(alpha: 0.35), Colors.transparent],
      );
      glowPaint.shader = glowGrad;
      canvas.drawCircle(Offset(n.x, n.y), n.radius * 3.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QuantumNodeState {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  Color color;

  QuantumNodeState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  factory QuantumNodeState.random(double width, double height) {
    final rand = math.Random();
    
    // Cyber blue, electric purple, neon magenta colors
    final colors = [
      const Color(0xFF00E5FF), // Electric cyan
      const Color(0xFFD500F9), // Cyber purple
      const Color(0xFF651FFF), // Deep purple
      const Color(0xFF00E676), // Bright green
    ];

    return QuantumNodeState(
      x: rand.nextDouble() * width,
      y: rand.nextDouble() * height,
      vx: (rand.nextDouble() - 0.5) * 1.5,
      vy: (rand.nextDouble() - 0.5) * 1.5,
      radius: rand.nextDouble() * 2.5 + 2.0,
      color: colors[rand.nextInt(colors.length)],
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformsPainter extends CustomPainter {
  final double time;

  WaveformsPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF030107), BlendMode.srcOver);

    // Rejilla de fondo retro neon con desvanecimiento radial desde el centro
    final gridPaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);

    for (double x = 0; x < size.width; x += 35) {
      final dx = (x - center.dx).abs();
      final alpha = (1.0 - (dx / (size.width / 2))).clamp(0.0, 1.0) * 0.2;
      gridPaint.color = const Color(0xFF1E1435).withValues(alpha: alpha);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 35) {
      final dy = (y - center.dy).abs();
      final alpha = (1.0 - (dy / (size.height / 2))).clamp(0.0, 1.0) * 0.2;
      gridPaint.color = const Color(0xFF1E1435).withValues(alpha: alpha);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final waveColors = [
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF8B5CF6), // Purple
    ];

    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      
      // Aplicar gradiente lineal a la línea de la onda
      final lineGrad = LinearGradient(
        colors: [
          waveColors[i],
          waveColors[(i + 1) % 3],
          waveColors[i],
        ],
      );
      
      final paint = Paint()
        ..shader = lineGrad.createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);

      final waveOffset = i * math.pi / 3;
      final speedFactor = 1.0 + (i * 0.15);
      final baseHeight = size.height / 2;

      for (double x = 0; x < size.width; x += 3) {
        final angle = (x / size.width) * 3.5 * math.pi + (time * speedFactor) + waveOffset;
        final y = baseHeight +
            math.sin(angle) * 75.0 * math.sin(time * 0.4 + waveOffset) +
            math.cos(angle * 1.3) * 25.0;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);

      // Dibujar partículas brillantes viajeras a lo largo de las curvas
      for (int pIdx = 0; pIdx < 4; pIdx++) {
        final progress = (time * 0.05 + pIdx / 4.0) % 1.0;
        final px = progress * size.width;
        final angle = (px / size.width) * 3.5 * math.pi + (time * speedFactor) + waveOffset;
        final py = baseHeight +
            math.sin(angle) * 75.0 * math.sin(time * 0.4 + waveOffset) +
            math.cos(angle * 1.3) * 25.0;
        
        // Aura brillante
        particlePaint.color = waveColors[i].withValues(alpha: 0.35);
        canvas.drawCircle(Offset(px, py), 6.5, particlePaint);
        // Núcleo blanco
        particlePaint.color = Colors.white;
        canvas.drawCircle(Offset(px, py), 2.2, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveformsPainter oldDelegate) => oldDelegate.time != time;
}

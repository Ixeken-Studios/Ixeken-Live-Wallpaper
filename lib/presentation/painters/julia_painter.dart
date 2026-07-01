import 'package:flutter/material.dart';
import 'dart:math' as math;

class JuliaPainter extends CustomPainter {
  final double cx;
  final double cy;
  final double time;
  final String colorScheme;

  JuliaPainter({
    required this.cx,
    required this.cy,
    required this.time,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF040209), BlendMode.srcOver);

    final cellW = size.width / 40.0;
    final cellH = size.height / 70.0;
    final paint = Paint()..style = PaintingStyle.fill;

    final double cReal = cx;
    final double cImag = cy;

    for (int y = 0; y < 70; y++) {
      final double zImagStart = 3.0 * (y / 70.0) - 1.5;
      for (int x = 0; x < 40; x++) {
        final double zRealStart = 2.0 * (x / 40.0) - 1.0;

        double zReal = zRealStart;
        double zImag = zImagStart;
        int iter = 0;
        const maxIter = 15;

        while (iter < maxIter) {
          final tempReal = zReal * zReal - zImag * zImag + cReal
              + math.sin(time * 0.05) * 0.01; // Sutil animación oscilatoria implícita
          final tempImag = 2.0 * zReal * zImag + cImag;
          zReal = tempReal;
          zImag = tempImag;

          if (zReal * zReal + zImag * zImag > 4.0) {
            break;
          }
          iter++;
        }

        if (iter > 0) {
          final intensity = iter / maxIter;
          final pulse = math.sin(time * 0.8) * 0.08;
          final finalIntensity = (intensity + pulse).clamp(0.0, 1.0);

          Color color;
          switch (colorScheme) {
            case 'fire':
              if (finalIntensity < 0.25) {
                color = Color.lerp(const Color(0xFF2D0202), const Color(0xFFB91C1C), finalIntensity / 0.25)!;
              } else if (finalIntensity < 0.65) {
                color = Color.lerp(const Color(0xFFB91C1C), const Color(0xFFEA580C), (finalIntensity - 0.25) / 0.40)!;
              } else {
                color = Color.lerp(const Color(0xFFEA580C), const Color(0xFFFACC15), (finalIntensity - 0.65) / 0.35)!;
              }
              break;
            case 'matrix':
              if (finalIntensity < 0.25) {
                color = Color.lerp(const Color(0xFF022C22), const Color(0xFF15803D), finalIntensity / 0.25)!;
              } else if (finalIntensity < 0.65) {
                color = Color.lerp(const Color(0xFF15803D), const Color(0xFF22C55E), (finalIntensity - 0.25) / 0.40)!;
              } else {
                color = Color.lerp(const Color(0xFF22C55E), const Color(0xFF86EFAC), (finalIntensity - 0.65) / 0.35)!;
              }
              break;
            case 'ocean':
              if (finalIntensity < 0.25) {
                color = Color.lerp(const Color(0xFF0F172A), const Color(0xFF1D4ED8), finalIntensity / 0.25)!;
              } else if (finalIntensity < 0.65) {
                color = Color.lerp(const Color(0xFF1D4ED8), const Color(0xFF0D9488), (finalIntensity - 0.25) / 0.40)!;
              } else {
                color = Color.lerp(const Color(0xFF0D9488), const Color(0xFF38BDF8), (finalIntensity - 0.65) / 0.35)!;
              }
              break;
            case 'cosmic':
            default:
              if (finalIntensity < 0.25) {
                color = Color.lerp(const Color(0xFF0F0B26), const Color(0xFF5B21B6), finalIntensity / 0.25)!;
              } else if (finalIntensity < 0.65) {
                color = Color.lerp(const Color(0xFF5B21B6), const Color(0xFFEC4899), (finalIntensity - 0.25) / 0.40)!;
              } else {
                color = Color.lerp(const Color(0xFFEC4899), const Color(0xFF06B6D4), (finalIntensity - 0.65) / 0.35)!;
              }
              break;
          }

          paint.color = color.withValues(alpha: finalIntensity * 0.95);

          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW + 0.5, cellH + 0.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant JuliaPainter oldDelegate) =>
      oldDelegate.cx != cx || oldDelegate.cy != cy || oldDelegate.time != time || oldDelegate.colorScheme != colorScheme;
}

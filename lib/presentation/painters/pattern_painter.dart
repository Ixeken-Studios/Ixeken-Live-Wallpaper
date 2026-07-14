import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  final double animationTime;
  final int layoutSize; // 1, 2, 3
  final List<String> slotIcons; // length = layoutSize * layoutSize
  final double cellSize; // 80, 120, 180
  final double speed; // 1.0 to 5.0
  final bool rotate;
  final Map<String, ui.Image> decodedImages;

  PatternPainter({
    required this.animationTime,
    required this.layoutSize,
    required this.slotIcons,
    required this.cellSize,
    required this.speed,
    required this.rotate,
    required this.decodedImages,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // Draw background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0F0F1B),
    );

    // Calculate displacement based on time and speed
    final double displacement = animationTime * speed * 20.0;
    final double offsetX = displacement % (cellSize * layoutSize);
    final double offsetY = displacement % (cellSize * layoutSize);

    final int cols = (size.width / cellSize).ceil() + 2;
    final int rows = (size.height / cellSize).ceil() + 2;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    for (int c = -layoutSize - 1; c < cols; c++) {
      for (int r = -layoutSize - 1; r < rows; r++) {
        // Calculate dynamic coordinate
        final double px = c * cellSize + offsetX;
        final double py = r * cellSize + offsetY;

        // Grid slot index determination (wrapping around the layout size)
        final int gridCol = ((c % layoutSize) + layoutSize) % layoutSize;
        final int gridRow = ((r % layoutSize) + layoutSize) % layoutSize;
        final int slotIndex = gridRow * layoutSize + gridCol;

        if (slotIndex >= 0 && slotIndex < slotIcons.length) {
          final String iconKey = slotIcons[slotIndex];
          final Offset center = Offset(px + cellSize / 2, py + cellSize / 2);

          canvas.save();
          if (rotate) {
            final double angle = animationTime * 0.5;
            canvas.translate(center.dx, center.dy);
            canvas.rotate(angle);
            canvas.translate(-center.dx, -center.dy);
          }

          _drawSlot(canvas, iconKey, center, cellSize * 0.5, paint);
          canvas.restore();
        }
      }
    }
  }

  void _drawSlot(ui.Canvas canvas, String iconKey, Offset center, double size, Paint paint) {
    if (decodedImages.containsKey(iconKey)) {
      final ui.Image img = decodedImages[iconKey]!;
      
      double destW = size;
      double destH = size;
      final double imgAspect = img.width / img.height;
      if (imgAspect > 1.0) {
        destH = size / imgAspect;
      } else {
        destW = size * imgAspect;
      }
      
      final Rect destRect = Rect.fromCenter(center: center, width: destW, height: destH);
      final Rect srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      
      final imagePaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.medium;
      canvas.drawImageRect(img, srcRect, destRect, imagePaint);
    } else {
      _drawGeometricShape(canvas, iconKey, center, size, paint);
    }
  }

  void _drawGeometricShape(ui.Canvas canvas, String shape, Offset center, double size, Paint paint) {
    switch (shape) {
      case 'circle':
        canvas.drawCircle(center, size * 0.4, paint);
        break;
      case 'square':
        canvas.drawRect(Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.7), paint);
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(center.dx, center.dy - size * 0.4)
          ..lineTo(center.dx + size * 0.4, center.dy + size * 0.4)
          ..lineTo(center.dx - size * 0.4, center.dy + size * 0.4)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 'cross':
        canvas.drawLine(Offset(center.dx - size * 0.3, center.dy), Offset(center.dx + size * 0.3, center.dy), paint);
        canvas.drawLine(Offset(center.dx, center.dy - size * 0.3), Offset(center.dx, center.dy + size * 0.3), paint);
        break;
      case 'star':
        final path = Path();
        final double innerRadius = size * 0.15;
        final double outerRadius = size * 0.4;
        for (int i = 0; i < 10; i++) {
          final double angle = (i * 36 - 90) * math.pi / 180.0;
          final double r = i.isEven ? outerRadius : innerRadius;
          final double x = center.dx + r * math.cos(angle);
          final double y = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
      case 'heart':
      default:
        final path = Path();
        final double w = size * 0.8;
        final double h = size * 0.8;
        path.moveTo(center.dx, center.dy + h * 0.35);
        path.cubicTo(
          center.dx - w * 0.5, center.dy - h * 0.25,
          center.dx - w * 0.5, center.dy - h * 0.7,
          center.dx, center.dy - h * 0.3
        );
        path.cubicTo(
          center.dx + w * 0.5, center.dy - h * 0.7,
          center.dx + w * 0.5, center.dy - h * 0.25,
          center.dx, center.dy + h * 0.35
        );
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.animationTime != animationTime ||
        oldDelegate.layoutSize != layoutSize ||
        oldDelegate.slotIcons != slotIcons ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.speed != speed ||
        oldDelegate.rotate != rotate ||
        oldDelegate.decodedImages != decodedImages;
  }
}

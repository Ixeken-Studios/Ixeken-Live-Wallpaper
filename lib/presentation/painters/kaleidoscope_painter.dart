import 'package:flutter/material.dart';
import 'dart:math' as math;

class KaleidoscopeItem {
  double radius;
  double angle;
  double size;
  double speedRadius;
  double speedAngle;
  Color color;
  int type; // 0: circle, 1: triangle, 2: rect

  KaleidoscopeItem({
    required this.radius,
    required this.angle,
    required this.size,
    required this.speedRadius,
    required this.speedAngle,
    required this.color,
    required this.type,
  });
}

class KaleidoscopePainter extends CustomPainter {
  final List<KaleidoscopeItem> items;
  final double gyroAngle;

  KaleidoscopePainter({required this.items, required this.gyroAngle});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFF020104), BlendMode.srcOver);

    // Parámetros de mosaico hexagonal (Honeycomb Tiling)
    final double R = size.width * 0.45; // Radio del hexágono
    final double H = R * math.sqrt(3) / 2; // Altura del triángulo
    final double hexWidth = R * math.sqrt(3);
    final double hexHeight = R * 1.5;

    final int cols = (size.width / hexWidth).ceil() + 2;
    final int rows = (size.height / hexHeight).ceil() + 2;

    const double sectorAngle = math.pi / 3; // 60 grados para 6 sectores por hexágono

    // Dibujar la rejilla de hexágonos reflectantes continuos
    for (int r = -1; r < rows; r++) {
      final double y = r * hexHeight;
      for (int c = -1; c < cols; c++) {
        // Desfase horizontal para filas impares
        final double x = c * hexWidth + ((r % 2 != 0) ? hexWidth / 2 : 0.0);

        canvas.save();
        canvas.translate(x, y);

        // Dibujar 6 sectores simétricos en cada hexágono
        for (int i = 0; i < 6; i++) {
          canvas.save();
          canvas.rotate(i * sectorAngle + gyroAngle);

          if (i % 2 == 1) {
            canvas.scale(1.0, -1.0);
          }

          // Dibujar mosaicos cristalinos de colores dentro del sector
          final polyPaint = Paint()..style = PaintingStyle.fill;
          final sectorItems = items.where((item) => item.angle >= 0 && item.angle <= sectorAngle).toList();
          sectorItems.sort((a, b) => a.angle.compareTo(b.angle));

          for (int j = 0; j < sectorItems.length; j++) {
            final itemA = sectorItems[j];
            final itemB = sectorItems[(j + 1) % sectorItems.length];

            final posA = Offset(itemA.radius * math.cos(itemA.angle), itemA.radius * math.sin(itemA.angle));
            final posB = Offset(itemB.radius * math.cos(itemB.angle), itemB.radius * math.sin(itemB.angle));

            final path = Path()
              ..moveTo(0, 0)
              ..lineTo(posA.dx, posA.dy)
              ..lineTo(posB.dx, posB.dy)
              ..close();

            // Mezcla de colores en gradiente radial translúcido
            final grad = RadialGradient(
              colors: [
                itemA.color.withValues(alpha: 0.28),
                itemB.color.withValues(alpha: 0.06),
              ],
            );
            polyPaint.shader = grad.createShader(Rect.fromPoints(posA, posB));
            canvas.drawPath(path, polyPaint);
          }

          // Dibujar líneas finas estructurales de espejo tallado
          final linePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;

          for (int j = 0; j < sectorItems.length; j++) {
            final itemA = sectorItems[j];
            final itemB = sectorItems[(j + 1) % sectorItems.length];

            final posA = Offset(itemA.radius * math.cos(itemA.angle), itemA.radius * math.sin(itemA.angle));
            final posB = Offset(itemB.radius * math.cos(itemB.angle), itemB.radius * math.sin(itemB.angle));

            linePaint.color = Color.lerp(itemA.color, itemB.color, 0.5)!.withValues(alpha: 0.45);
            canvas.drawLine(posA, posB, linePaint);
            
            // Reflejo radial
            linePaint.color = itemA.color.withValues(alpha: 0.2);
            canvas.drawLine(Offset.zero, posA, linePaint);
          }

          // Dibujar núcleos móviles (gemas brillantes)
          final nodePaint = Paint()..style = PaintingStyle.fill;
          for (var item in sectorItems) {
            final px = item.radius * math.cos(item.angle);
            final py = item.radius * math.sin(item.angle);

            nodePaint.color = item.color.withValues(alpha: 0.6);
            canvas.drawCircle(Offset(px, py), item.size / 2.5 + 1.0, nodePaint);

            nodePaint.color = Colors.white;
            canvas.drawCircle(Offset(px, py), 1.5, nodePaint);
          }

          canvas.restore();
        }
        canvas.restore();
      }
    }

    // Dibujar viñeta difusa para dar profundidad y realismo óptico de caleidoscopio
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
        stops: const [0.35, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant KaleidoscopePainter oldDelegate) => true;
}

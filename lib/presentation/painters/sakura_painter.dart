import 'package:flutter/material.dart';
import 'dart:math' as math;

class SakuraPetal {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double angle;
  double rotateSpeed;

  SakuraPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.angle,
    required this.rotateSpeed,
  });
}

class SakuraPainter extends CustomPainter {
  final List<SakuraPetal> petals;
  final double windX;

  SakuraPainter(this.petals, this.windX);

  @override
  void paint(Canvas canvas, Size size) {
    final bgGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFECEF),
        const Color(0xFFFEF3C7),
        const Color(0xFFFDF2F8),
      ],
    );
    final bgPaint = Paint()..shader = bgGrad.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final sunPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.25), 65.0, sunPaint);

    final trunkPaint = Paint()
      ..color = const Color(0xFF38101E)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final trunkPath = Path();
    final baseW = size.width * 0.75;
    
    trunkPath.moveTo(baseW, size.height);
    trunkPath.quadraticBezierTo(
      baseW - 15,
      size.height * 0.72,
      baseW - 45,
      size.height * 0.65,
    );
    canvas.drawPath(trunkPath, trunkPaint);

    trunkPaint.strokeWidth = 4.0;
    final branch1 = Path()
      ..moveTo(baseW - 45, size.height * 0.65)
      ..quadraticBezierTo(baseW - 90, size.height * 0.60, baseW - 120, size.height * 0.53);
    canvas.drawPath(branch1, trunkPaint);

    final branch2 = Path()
      ..moveTo(baseW - 45, size.height * 0.65)
      ..quadraticBezierTo(baseW + 5, size.height * 0.58, baseW + 25, size.height * 0.52);
    canvas.drawPath(branch2, trunkPaint);

    final blossomGlow = Paint()..style = PaintingStyle.fill;
    final colors = [
      const Color(0xFFFDA4AF).withValues(alpha: 0.3),
      const Color(0xFFF472B6).withValues(alpha: 0.25),
      const Color(0xFFFDF2F8).withValues(alpha: 0.4),
    ];

    blossomGlow.color = colors[0];
    canvas.drawCircle(Offset(baseW - 120, size.height * 0.53), 50.0, blossomGlow);
    blossomGlow.color = colors[1];
    canvas.drawCircle(Offset(baseW + 25, size.height * 0.52), 55.0, blossomGlow);
    blossomGlow.color = colors[2];
    canvas.drawCircle(Offset(baseW - 45, size.height * 0.45), 65.0, blossomGlow);

    final petalPaint = Paint()..style = PaintingStyle.fill;

    for (var p in petals) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.angle);
      
      final double scaleX = math.sin(p.angle * 2.5).abs().clamp(0.15, 1.0);
      canvas.scale(scaleX, 1.0);

      final path = Path();
      path.moveTo(0, -p.size);
      path.cubicTo(-p.size, -p.size, -p.size, p.size, 0, p.size * 1.5);
      path.cubicTo(p.size, p.size, p.size, -p.size, 0, -p.size);
      path.close();

      final petalGrad = RadialGradient(
        colors: [
          const Color(0xFFFEE2E2),
          const Color(0xFFF472B6),
        ],
      );
      petalPaint.shader = petalGrad.createShader(
        Rect.fromCircle(center: Offset.zero, radius: p.size * 1.5),
      );

      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SakuraPainter oldDelegate) => true;
}

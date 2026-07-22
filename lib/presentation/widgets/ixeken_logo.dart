import 'package:flutter/material.dart';

/// Logo original de Ixeken Studios (para "Made by Ixeken")
class IxekenLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const IxekenLogo({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size * (108.0 / 98.0),
      child: CustomPaint(
        painter: _IxekenLogoPainter(effectiveColor),
      ),
    );
  }
}

/// Nuevo Logo de la aplicación Gakuu
class GakuuLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const GakuuLogo({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GakuuLogoPainter(effectiveColor),
      ),
    );
  }
}

class _IxekenLogoPainter extends CustomPainter {
  final Color color;

  _IxekenLogoPainter(this.color);

  static final List<({String d, bool isEvenOdd})> _pathDatas = [
    (d: "M48.56,60.69C55.22,60.69 60.61,55.3 60.61,48.64C60.61,41.99 55.22,36.6 48.56,36.6C41.91,36.6 36.52,41.99 36.52,48.64C36.52,55.3 41.91,60.69 48.56,60.69Z", isEvenOdd: false),
    (d: "M48.56,24.13C62.09,24.13 73.08,35.11 73.08,48.64C73.08,62.17 62.09,73.16 48.56,73.16C35.03,73.16 24.05,62.17 24.05,48.64C24.05,35.11 35.03,24.13 48.56,24.13ZM48.56,30.26C58.71,30.26 66.95,38.49 66.95,48.64C66.95,58.79 58.71,67.03 48.56,67.03C38.42,67.03 30.18,58.79 30.18,48.64C30.18,38.49 38.42,30.26 48.56,30.26Z", isEvenOdd: true),
    (d: "M11.72,36.94H2.99V64.99H11.72V36.94Z", isEvenOdd: false),
    (d: "M93.84,36.94H85.11V64.99H93.84V36.94Z", isEvenOdd: false),
    (d: "M26.4,40.84H10.77V45.48H26.4V40.84Z", isEvenOdd: false),
    (d: "M26.4,48.64H10.77V53.29H26.4V48.64Z", isEvenOdd: false),
    (d: "M30.53,56.63H10.77V61.27H30.53V56.63Z", isEvenOdd: false),
    (d: "M85.96,40.47H70.62V45.11H85.96V40.47Z", isEvenOdd: false),
    (d: "M85.96,48.64H70.62V53.29H85.96V48.64Z", isEvenOdd: false),
    (d: "M85.96,56.63H68.39V61.27H85.96V56.63Z", isEvenOdd: false),
    (d: "M24.57,99.47L13.33,92.03L35.82,64.16L41.44,67.88L24.57,99.47Z", isEvenOdd: true),
    (d: "M72.5,99.47L83.73,92.03L61.71,64.87L56.09,68.59L72.5,99.47Z", isEvenOdd: true),
    (d: "M83.73,10.84L73.54,2.03L55.49,28.05L60.58,32.46L83.73,10.84Z", isEvenOdd: true),
    (d: "M13.33,10.84L23.52,2.03L41.58,28.05L36.48,32.46L13.33,10.84Z", isEvenOdd: true),
    (d: "M2.99,28.26L9.45,17.07L29.36,34.03L27.64,37.01L2.99,28.26Z", isEvenOdd: true),
    (d: "M9.55,82.29L3.09,71.1L28.45,61.93L30.17,64.91L9.55,82.29Z", isEvenOdd: true),
    (d: "M87.38,17.07L93.84,28.26L69.2,37.01L67.48,34.03L87.38,17.07Z", isEvenOdd: true),
    (d: "M93.84,71.29L87.38,82.48L66.42,64.91L68.14,61.93L93.84,71.29Z", isEvenOdd: true),
    (d: "M53.29,68.75H43.81V107.9H53.29V68.75Z", isEvenOdd: false),
    (d: "M62.03,100.96H35.41V107.9H62.03V100.96Z", isEvenOdd: false),
    (d: "M59.61,107.9H37.7L44.23,97.28H53.08L59.61,107.9Z", isEvenOdd: true),
    (d: "M4.9,9.81C7.61,9.81 9.81,7.61 9.81,4.9C9.81,2.19 7.61,-0 4.9,-0C2.2,-0 0,2.19 0,4.9C0,7.61 2.2,9.81 4.9,9.81Z", isEvenOdd: false),
    (d: "M92.22,9.81C94.93,9.81 97.12,7.61 97.12,4.9C97.12,2.19 94.93,-0 92.22,-0C89.51,-0 87.32,2.19 87.32,4.9C87.32,7.61 89.51,9.81 92.22,9.81Z", isEvenOdd: false),
    (d: "M4.9,101.21C7.61,101.21 9.81,99.02 9.81,96.31C9.81,93.6 7.61,91.41 4.9,91.41C2.2,91.41 0,93.6 0,96.31C0,99.02 2.2,101.21 4.9,101.21Z", isEvenOdd: false),
    (d: "M92.22,101.21C94.93,101.21 97.12,99.02 97.12,96.31C97.12,93.6 94.93,91.41 92.22,91.41C89.51,91.41 87.32,93.6 87.32,96.31C87.32,99.02 89.51,101.21 92.22,101.21Z", isEvenOdd: false),
    (d: "M48.56,16.93L56.29,26.03H40.84L48.56,16.93Z", isEvenOdd: true),
  ];

  static final List<Path> _cachedPaths = _pathDatas.map((item) {
    return _parseSvgPath(item.d, isEvenOdd: item.isEvenOdd);
  }).toList();

  static Path _parseSvgPath(String d, {required bool isEvenOdd}) {
    final path = Path();
    if (isEvenOdd) {
      path.fillType = PathFillType.evenOdd;
    }
    final regExp = RegExp(r'([a-zA-Z])|([-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?)');
    final matches = regExp.allMatches(d).toList();

    String? cmd;
    int i = 0;

    double getNum() {
      if (i < matches.length && matches[i].group(1) == null) {
        final val = double.parse(matches[i].group(0)!);
        i++;
        return val;
      }
      return 0.0;
    }

    double currentX = 0;
    double currentY = 0;

    while (i < matches.length) {
      final m = matches[i];
      final matchStr = m.group(0)!;
      if (m.group(1) != null) {
        cmd = matchStr;
        i++;
      }

      if (cmd == 'M' || cmd == 'm') {
        final x = getNum();
        final y = getNum();
        if (cmd == 'm') {
          currentX += x;
          currentY += y;
          path.relativeMoveTo(x, y);
        } else {
          currentX = x;
          currentY = y;
          path.moveTo(x, y);
        }
      } else if (cmd == 'C' || cmd == 'c') {
        final x1 = getNum();
        final y1 = getNum();
        final x2 = getNum();
        final y2 = getNum();
        final x = getNum();
        final y = getNum();
        if (cmd == 'c') {
          path.relativeCubicTo(x1, y1, x2, y2, x, y);
          currentX += x;
          currentY += y;
        } else {
          path.cubicTo(x1, y1, x2, y2, x, y);
          currentX = x;
          currentY = y;
        }
      } else if (cmd == 'H' || cmd == 'h') {
        final x = getNum();
        if (cmd == 'h') {
          currentX += x;
          path.relativeLineTo(x, 0);
        } else {
          currentX = x;
          path.lineTo(x, currentY);
        }
      } else if (cmd == 'V' || cmd == 'v') {
        final y = getNum();
        if (cmd == 'v') {
          currentY += y;
          path.relativeLineTo(0, y);
        } else {
          currentY = y;
          path.lineTo(currentX, y);
        }
      } else if (cmd == 'L' || cmd == 'l') {
        final x = getNum();
        final y = getNum();
        if (cmd == 'l') {
          currentX += x;
          currentY += y;
          path.relativeLineTo(x, y);
        } else {
          currentX = x;
          currentY = y;
          path.lineTo(x, y);
        }
      } else if (cmd == 'Z' || cmd == 'z') {
        path.close();
      } else {
        i++;
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 98.0;
    final scaleY = size.height / 108.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final path in _cachedPaths) {
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IxekenLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _GakuuLogoPainter extends CustomPainter {
  final Color color;

  _GakuuLogoPainter(this.color);

  static final List<({String d, bool isEvenOdd, bool isCutout})> _pathDatas = [
    (d: "M0,0h192v192h-192zM13.9,13.9h164.2v164.2h-164.2z", isEvenOdd: true, isCutout: false),
    (d: "M21,21h150v150h-150zM34.9,34.9h122.2v122.2h-122.2z", isEvenOdd: true, isCutout: false),
    (d: "M21,21h75v150h-75z", isEvenOdd: false, isCutout: false),
    (d: "M96,33h63v126h-63z", isEvenOdd: false, isCutout: false),
    (d: "M33,33h63v63h-63z", isEvenOdd: false, isCutout: true),
    (d: "M96,96h63v63h-63z", isEvenOdd: false, isCutout: true),
  ];

  static final List<({Path path, bool isCutout})> _cachedPaths = _pathDatas.map((item) {
    return (path: _parseSvgPath(item.d, isEvenOdd: item.isEvenOdd), isCutout: item.isCutout);
  }).toList();

  static Path _parseSvgPath(String d, {required bool isEvenOdd}) {
    final path = Path();
    if (isEvenOdd) {
      path.fillType = PathFillType.evenOdd;
    }
    final regExp = RegExp(r'([a-zA-Z])|([-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?)');
    final matches = regExp.allMatches(d).toList();

    String? cmd;
    int i = 0;

    double getNum() {
      if (i < matches.length && matches[i].group(1) == null) {
        final val = double.parse(matches[i].group(0)!);
        i++;
        return val;
      }
      return 0.0;
    }

    double currentX = 0;
    double currentY = 0;

    while (i < matches.length) {
      final m = matches[i];
      final matchStr = m.group(0)!;
      if (m.group(1) != null) {
        cmd = matchStr;
        i++;
      }

      if (cmd == 'M' || cmd == 'm') {
        final x = getNum();
        final y = getNum();
        if (cmd == 'm') {
          currentX += x;
          currentY += y;
          path.relativeMoveTo(x, y);
        } else {
          currentX = x;
          currentY = y;
          path.moveTo(x, y);
        }
      } else if (cmd == 'H' || cmd == 'h') {
        final x = getNum();
        if (cmd == 'h') {
          currentX += x;
          path.relativeLineTo(x, 0);
        } else {
          currentX = x;
          path.lineTo(x, currentY);
        }
      } else if (cmd == 'V' || cmd == 'v') {
        final y = getNum();
        if (cmd == 'v') {
          currentY += y;
          path.relativeLineTo(0, y);
        } else {
          currentY = y;
          path.lineTo(currentX, y);
        }
      } else if (cmd == 'L' || cmd == 'l') {
        final x = getNum();
        final y = getNum();
        if (cmd == 'l') {
          currentX += x;
          currentY += y;
          path.relativeLineTo(x, y);
        } else {
          currentX = x;
          currentY = y;
          path.lineTo(x, y);
        }
      } else if (cmd == 'Z' || cmd == 'z') {
        path.close();
      } else {
        i++;
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 192.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paintMain = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final paintCutout = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.saveLayer(Rect.fromLTWH(0, 0, 192, 192), Paint());

    for (final item in _cachedPaths) {
      if (!item.isCutout) {
        canvas.drawPath(item.path, paintMain);
      } else {
        canvas.drawPath(item.path, paintCutout);
      }
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GakuuLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para la animación de lluvia de caracteres estilo Matrix.
class MatrixRainPainter extends CustomPainter {
  /// Tiempo acumulado.
  final double time;

  /// Lista de estados de las columnas verticales.
  final List<MatrixColumnState> columns;

  /// Constructor.
  MatrixRainPainter(this.time, this.columns);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF020402));
    
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final charSize = size.width / 14.0;
    
    for (var col in columns) {
      if (col.yPos * charSize > size.height + (col.length * charSize)) {
        col.reset();
      } else {
        col.yPos += col.speed;
      }
      
      if (math.Random().nextDouble() > 0.95) {
        col.mutate();
      }
      
      final headIdx = col.yPos.toInt();
      for (int j = 0; j < col.length; j++) {
        final charIdx = headIdx - j;
        if (charIdx < 0) continue;
        
        final yVal = charIdx * charSize + charSize / 2;
        if (yVal > size.height + charSize) continue;
        
        final char = col.chars[charIdx % col.chars.length];
        final fraction = 1.0 - (j / col.length);
        final opacity = fraction.clamp(0.0, 1.0);
        
        final color = j == 0 
            ? Colors.white 
            : const Color(0xFF10B981).withValues(alpha: opacity);
        
        textPainter.text = TextSpan(
          text: char,
          style: TextStyle(
            color: color, 
            fontSize: charSize * 0.82, 
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            shadows: j == 0 ? [
              const Shadow(color: Color(0xFF34D399), blurRadius: 6)
            ] : null,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(col.xOffset - textPainter.width / 2, yVal - textPainter.height / 2));
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// @nodoc
/// Representa el estado de una columna de caracteres en la lluvia de Matrix.
class MatrixColumnState {
  /// Desplazamiento horizontal de la columna.
  final double xOffset;

  /// Posición vertical actual en caracteres.
  double yPos;

  /// Velocidad de caída.
  final double speed;

  /// Cantidad de caracteres en el rastro.
  final int length;

  /// Lista de caracteres cargados para dibujar.
  final List<String> chars;
  
  /// Constructor.
  MatrixColumnState({
    required this.xOffset,
    required this.yPos,
    required this.speed,
    required this.length,
    required this.chars,
  });
  
  /// Reinicia la columna arriba de la pantalla.
  void reset() {
    yPos = -math.Random().nextDouble() * 10;
  }
  
  /// Altera un carácter aleatorio en la columna para dinamismo.
  void mutate() {
    if (chars.isNotEmpty) {
      chars[math.Random().nextInt(chars.length)] = 
          "0123456789日ハミヒヘホマミムメモヤユヨラリルレロ"[math.Random().nextInt(27)];
    }
  }
}

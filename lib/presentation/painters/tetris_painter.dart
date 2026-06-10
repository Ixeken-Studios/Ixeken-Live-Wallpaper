import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante de la simulación del juego de Tetris.
class TetrisPainter extends CustomPainter {
  /// Tiempo acumulado.
  final double time;

  /// Cuadrícula lógica del juego.
  final List<List<int>> grid;

  /// Estilo estético ('retro', 'pastel', 'neon', 'outline').
  final String style;

  /// Pieza activa controlada por la IA.
  final TetrisPiece activePiece;
  
  /// Constructor.
  TetrisPainter(this.time, this.grid, this.style, this.activePiece);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final isRetro = style == 'retro';
    
    final bgPaint = Paint();
    if (isRetro) {
      bgPaint.color = const Color(0xFF8BAC0F);
    } else {
      bgPaint.shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [const Color(0xFF080810), const Color(0xFF121220)],
      );
    }
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    final cols = 10;
    final cellSize = size.width / cols;
    final rows = (size.height / cellSize).toInt();
    
    final gridPaint = Paint()
      ..color = isRetro ? const Color(0xFF306230) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    gridPaint.color = gridPaint.color.withValues(alpha: isRetro ? 0.12 : 0.05);
    for (int x = 0; x <= cols; x++) {
      canvas.drawLine(Offset(x * cellSize, 0), Offset(x * cellSize, size.height), gridPaint);
    }
    for (int y = 0; y <= rows; y++) {
      canvas.drawLine(Offset(0, y * cellSize), Offset(size.width, y * cellSize), gridPaint);
    }
    
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        if (grid[y][x] != 0) {
          drawBlock(canvas, x, y, grid[y][x], cellSize, style);
        }
      }
    }
    
    final shape = activePiece.shape;
    for (int py = 0; py < shape.length; py++) {
      for (int px = 0; px < shape[py].length; px++) {
        if (shape[py][px] != 0) {
          drawBlock(canvas, activePiece.x + px, activePiece.y + py, activePiece.type + 1, cellSize, style, isCurrent: true);
        }
      }
    }
  }
  
  /// Dibuja un bloque o celda de Tetris según el estilo seleccionado.
  void drawBlock(ui.Canvas canvas, int x, int y, int colorIndex, double cellSize, String style, {bool isCurrent = false}) {
    final colors = style == 'retro' 
        ? [
            Colors.transparent,
            const Color(0xFF9BBC0F), const Color(0xFF8BAC0F),
            const Color(0xFF306230), const Color(0xFF0F380F),
            const Color(0xFF8BAC0F), const Color(0xFF306230),
            const Color(0xFF9BBC0F)
          ]
        : style == 'pastel'
            ? [
                Colors.transparent,
                const Color(0xFFFFB7B2), const Color(0xFFFFDAC1),
                const Color(0xFFE2F0CB), const Color(0xFFB5EAD7),
                const Color(0xFFC7CEEA), const Color(0xFFFFC6FF),
                const Color(0xFFFF9AA2)
              ]
            : [
                Colors.transparent,
                const Color(0xFF00F0F0), const Color(0xFF3B82F6),
                const Color(0xFFF59E0B), const Color(0xFFFBBF24),
                const Color(0xFF10B981), const Color(0xFF8B5CF6),
                const Color(0xFFEF4444)
              ];
    
    final color = colors[colorIndex.clamp(0, colors.length - 1)];
    final rect = ui.Rect.fromLTWH(x * cellSize + 0.8, y * cellSize + 0.8, cellSize - 1.6, cellSize - 1.6);
    final rrect = ui.RRect.fromRectAndRadius(rect, Radius.circular(style == 'pastel' ? 4.0 : style == 'retro' ? 0.0 : 6.0));
    
    final paint = Paint()..isAntiAlias = true;
    
    if (style == 'retro') {
      paint.color = color;
      paint.style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);
      
      paint.color = const Color(0xFF0F380F);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      canvas.drawRect(rect, paint);
    } else if (style == 'pastel') {
      paint.color = color;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(rrect, paint);
    } else if (style == 'outline') {
      paint.color = color;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.8;
      canvas.drawRRect(rrect, paint);
    } else {
      paint.color = color;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(rrect, paint);
      
      final highlightRect = ui.Rect.fromLTWH(x * cellSize + 1.6, y * cellSize + 1.6, cellSize - 3.2, 2.5);
      final highlightRRect = ui.RRect.fromRectAndRadius(highlightRect, const Radius.circular(1.0));
      paint.color = Colors.white.withValues(alpha: 0.25);
      canvas.drawRRect(highlightRRect, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// @nodoc
/// Modela una pieza del juego de Tetris.
class TetrisPiece {
  /// Posición X en la cuadrícula.
  int x;

  /// Posición Y en la cuadrícula.
  int y;

  /// Tipo de pieza (índice de forma).
  int type;

  /// Matriz que define la forma de la pieza.
  List<List<int>> shape;
  
  /// Constructor.
  TetrisPiece({required this.x, required this.y, required this.type, required this.shape});
}

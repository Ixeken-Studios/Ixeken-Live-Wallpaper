import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// @nodoc
/// Dibujante personalizado para el autómata celular del Juego de la Vida de Conway.
class ConwayPainter extends CustomPainter {
  /// Cuadrícula de células vivas/muertas.
  final List<List<bool>> grid;

  /// Constructor.
  ConwayPainter(this.grid);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF090712));
    
    final cellW = size.width / 30; // 30 cols
    final cellH = size.height / 50; // 50 rows
    
    final paintCell = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFF00FFCC)
      ..style = PaintingStyle.fill;
      
    for (int y = 0; y < grid.length; y++) {
      if (y * cellH > size.height) break;
      for (int x = 0; x < grid[y].length; x++) {
        if (x * cellW > size.width) break;
        
        if (grid[y][x]) {
          final rect = ui.Rect.fromLTWH(x * cellW + 0.5, y * cellH + 0.5, cellW - 1.0, cellH - 1.0);
          canvas.drawRRect(ui.RRect.fromRectAndRadius(rect, const Radius.circular(2.0)), paintCell);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'particles_painter.dart';

/// @nodoc
/// Dibujante personalizado para la red conectada de Plexus.
class PlexusPainter extends CustomPainter {
  /// Nodos o partículas de la red.
  final List<ParticleState> nodes;

  /// Constructor.
  PlexusPainter(this.nodes);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0A0F1D));
    
    final paintNode = Paint()..isAntiAlias = true..color = const Color(0xFF00D2FF).withValues(alpha: 0.7);
    final paintLine = Paint()..isAntiAlias = true..strokeWidth = 0.8;
    
    for (var n in nodes) {
      n.x += n.vx;
      n.y += n.vy;
      
      if (n.x < 0 || n.x > size.width) n.vx *= -1;
      if (n.y < 0 || n.y > size.height) n.vy *= -1;
      
      n.x = n.x.clamp(0.0, size.width);
      n.y = n.y.clamp(0.0, size.height);
      
      canvas.drawCircle(Offset(n.x, n.y), n.radius, paintNode);
    }
    
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dx = nodes[i].x - nodes[j].x;
        final dy = nodes[i].y - nodes[j].y;
        final dist = math.sqrt(dx*dx + dy*dy);
        
        if (dist < 60) {
          final alpha = (1.0 - (dist / 60.0)).clamp(0.0, 1.0);
          paintLine.color = const Color(0xFF00D2FF).withValues(alpha: alpha * 0.3);
          canvas.drawLine(Offset(nodes[i].x, nodes[i].y), Offset(nodes[j].x, nodes[j].y), paintLine);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

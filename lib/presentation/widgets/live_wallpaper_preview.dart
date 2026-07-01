import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../painters/painters.dart';

class LiveWallpaperPreview extends StatefulWidget {
  final String engineId;
  final bool isDimEnabled;
  final double dimIntensity;
  final String tetrisStyle;
  final List<String>? playlist;
  final String juliaColorScheme;
  
  const LiveWallpaperPreview({
    super.key, 
    required this.engineId, 
    required this.isDimEnabled,
    required this.dimIntensity,
    required this.tetrisStyle,
    this.playlist,
    this.juliaColorScheme = 'cosmic',
  });

  @override
  void paint(BuildContext context) {}

  @override
  State<LiveWallpaperPreview> createState() => _LiveWallpaperPreviewState();
}

class _LiveWallpaperPreviewState extends State<LiveWallpaperPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<ParticleState> _particles = [];
  final List<ParticleState> _plexusNodes = [];
  final List<MatrixColumnState> _matrixCols = [];
  
  // Starfield Warp State
  final List<StarState> _stars = [];
  bool _isWarping = false;
  double _starSpeed = 6.0;

  // Conway Grid State
  List<List<bool>> _conwayGrid = [];
  int _conwayTimer = 0;
  int _conwayStagnancyCounter = 0;
  int _conwayPreviousHash = 0;

  // Fluid Swarm State
  final List<FluidParticleState> _fluidParticles = [];
  double _fluidTime = 0.0;
  ui.Offset? _touchPos;
  
  // Vaporwave State
  double _vaporwaveTime = 0.0;

  // Tetris Grid State
  List<List<int>> _tetrisGrid = [];
  late TetrisPiece _activePiece;
  double _tetrisTime = 0.0;
  
  final List<List<List<int>>> _tetrisShapes = [
    [[1, 1, 1, 1]], // I
    [[1, 0, 0], [1, 1, 1]], // J
    [[0, 0, 1], [1, 1, 1]], // L
    [[1, 1], [1, 1]], // O
    [[0, 1, 1], [1, 1, 0]], // S
    [[0, 1, 0], [1, 1, 1]], // T
    [[1, 1, 0], [0, 1, 1]], // Z
  ];

  // 7 New Wallpapers State
  final List<VoronoiPoint> _voronoiPoints = [];
  final List<Boid> _boids = [];
  double _juliaCx = -0.7;
  double _juliaCy = 0.27015;
  final List<SakuraPetal> _sakuraPetals = [];
  double _windX = 0.0;
  final List<PachinkoBall> _pachinkoBalls = [];
  final List<PachinkoPin> _pachinkoPins = [];
  final List<PachinkoSpark> _pachinkoSparks = [];
  final List<KaleidoscopeItem> _kaleidoscopeItems = [];
  double _gyroAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    
    _initParticles();
    _initPlexus();
    _initMatrix();
    _initTetris();
    _initStars();
    _initConway();
    _initFluids();
    _initVoronoi();
    _initBoids();
    _initSakura();
    _initPachinko();
    _initKaleidoscope();
    
    _controller.addListener(() {
      _animateTetris();
      _animateStarfield();
      _animateConway();
      _animateFluids();
      _animateVaporwave();
      _animateVoronoi();
      _animateBoids();
      _animateSakura();
      _animatePachinko();
      _animateKaleidoscope();
      _animateJulia();
    });
  }

  void _initParticles() {
    final rand = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(ParticleState(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        vx: (rand.nextDouble() - 0.5) * 1.6,
        vy: (rand.nextDouble() - 0.5) * 1.6,
        radius: rand.nextDouble() * 5 + 1.5,
        color: Color.fromRGBO(
          rand.nextInt(50) + 100,
          rand.nextInt(50) + 150,
          255,
          rand.nextDouble() * 0.4 + 0.3,
        ),
      ));
    }
  }

  void _initPlexus() {
    final rand = math.Random();
    for (int i = 0; i < 20; i++) {
      _plexusNodes.add(ParticleState(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        vx: (rand.nextDouble() - 0.5) * 0.9,
        vy: (rand.nextDouble() - 0.5) * 0.9,
        radius: 2.0,
        color: const Color(0xFF00D2FF),
      ));
    }
  }

  void _initMatrix() {
    final rand = math.Random();
    final columnsCount = 14;
    for (int i = 0; i < columnsCount; i++) {
      final length = rand.nextInt(7) + 6;
      final speed = rand.nextDouble() * 0.12 + 0.05;
      final List<String> charsList = List.generate(40, (_) => "0123456789日ハミヒヘホマミムメモヤユヨラリルレロ"[rand.nextInt(27)]);
      _matrixCols.add(MatrixColumnState(
        xOffset: (i * 200 / columnsCount) + (200 / columnsCount / 2),
        yPos: -rand.nextDouble() * 15,
        speed: speed,
        length: length,
        chars: charsList,
      ));
    }
  }

  void _initTetris() {
    _tetrisGrid = List.generate(18, (_) => List.generate(10, (_) => 0));
    _spawnTetrisPiece();
  }

  void _spawnTetrisPiece() {
    final rand = math.Random();
    final type = rand.nextInt(7);
    _activePiece = TetrisPiece(
      x: rand.nextInt(6),
      y: 0,
      type: type,
      shape: _tetrisShapes[type],
    );
  }

  void _initStars() {
    final rand = math.Random();
    _stars.clear();
    for (int i = 0; i < 60; i++) {
      _stars.add(StarState(
        x: (rand.nextDouble() - 0.5) * 200,
        y: (rand.nextDouble() - 0.5) * 350,
        z: rand.nextDouble() * 500 + 10,
        prevZ: 0.0,
        color: Color.fromRGBO(
          rand.nextInt(55) + 200,
          rand.nextInt(55) + 200,
          255,
          rand.nextDouble() * 0.5 + 0.5,
        ),
      )..prevZ = 0.0);
    }
    for (var s in _stars) {
      s.prevZ = s.z;
    }
  }

  void _initConway() {
    _conwayGrid = List.generate(50, (_) => List.generate(30, (_) => false));
    _reseedConway();
  }

  void _reseedConway() {
    final rand = math.Random();
    for (int y = 0; y < 50; y++) {
      for (int x = 0; x < 30; x++) {
        _conwayGrid[y][x] = rand.nextDouble() < 0.22;
      }
    }
    _conwayStagnancyCounter = 0;
  }

  void _initFluids() {
    final rand = math.Random();
    _fluidParticles.clear();
    final colors = [
      const Color(0xFF06B6D4),
      const Color(0xFF3B82F6),
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];
    for (int i = 0; i < 80; i++) {
      _fluidParticles.add(FluidParticleState(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        px: 0.0,
        py: 0.0,
        vx: (rand.nextDouble() - 0.5) * 2.0,
        vy: (rand.nextDouble() - 0.5) * 2.0,
        radius: rand.nextDouble() * 3.0 + 1.2,
        color: colors[rand.nextInt(colors.length)],
      )..px = rand.nextDouble() * 200..py = rand.nextDouble() * 350);
    }
  }

  void _animateTetris() {
    if (!mounted || widget.engineId != 'tetris') return;
    
    _tetrisTime += 0.22;
    if (_tetrisTime >= 1.0) {
      _tetrisTime = 0.0;
      
      if (_activePiece.y == 3) {
        final rand = math.Random();
        if (rand.nextBool()) {
          final dir = rand.nextBool() ? 1 : -1;
          if (!_checkCollision(_activePiece.x + dir, _activePiece.y, _activePiece.shape)) {
            _activePiece.x += dir;
          }
        }
      }
      
      if (!_checkCollision(_activePiece.x, _activePiece.y + 1, _activePiece.shape)) {
        setState(() {
          _activePiece.y++;
        });
      } else {
        _lockPiece();
        _clearLines();
        setState(() {
          _spawnTetrisPiece();
        });
      }
    }
  }

  void _animateStarfield() {
    if (!mounted || widget.engineId != 'starfield') return;
    final targetSpeed = _isWarping ? 25.0 : 4.5;
    _starSpeed += (targetSpeed - _starSpeed) * 0.12;
    
    setState(() {
      for (var s in _stars) {
        s.prevZ = s.z;
        s.z -= _starSpeed;
        if (s.z <= 0) {
          final rand = math.Random();
          s.z = 500.0;
          s.prevZ = 500.0;
          s.x = (rand.nextDouble() - 0.5) * 200;
          s.y = (rand.nextDouble() - 0.5) * 350;
        }
      }
    });
  }

  void _animateConway() {
    if (!mounted || widget.engineId != 'conway') return;
    _conwayTimer++;
    if (_conwayTimer >= 10) { 
      _conwayTimer = 0;
      
      final nextGrid = List.generate(50, (_) => List.generate(30, (_) => false));
      int aliveCount = 0;
      int currentHash = 0;
      
      for (int y = 0; y < 50; y++) {
        for (int x = 0; x < 30; x++) {
          final neighbors = _countConwayNeighbors(x, y);
          final isAlive = _conwayGrid[y][x];
          nextGrid[y][x] = isAlive ? (neighbors == 2 || neighbors == 3) : (neighbors == 3);
          
          if (nextGrid[y][x]) {
            aliveCount++;
            currentHash += (x + 1) * (y + 1);
          }
        }
      }
      
      setState(() {
        _conwayGrid = nextGrid;
      });
      
      if (aliveCount == 0) {
        _reseedConway();
      } else if (currentHash == _conwayPreviousHash) {
        _conwayStagnancyCounter++;
        if (_conwayStagnancyCounter > 18) {
          _reseedConway();
        }
      } else {
        _conwayStagnancyCounter = 0;
      }
      _conwayPreviousHash = currentHash;
    }
  }

  int _countConwayNeighbors(int x, int y) {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = (x + dx + 30) % 30;
        final ny = (y + dy + 50) % 50;
        if (_conwayGrid[ny][nx]) count++;
      }
    }
    return count;
  }

  void _animateFluids() {
    if (!mounted || widget.engineId != 'fluids') return;
    _fluidTime += 0.012;
    
    setState(() {
      for (var p in _fluidParticles) {
        p.px = p.x;
        p.py = p.y;
        
        p.vx *= 0.95;
        p.vy *= 0.95;
        
        p.vx += math.sin(_fluidTime + p.y * 0.02) * 0.06;
        p.vy += math.cos(_fluidTime + p.x * 0.02) * 0.06;
        
        if (_touchPos != null) {
          final dx = _touchPos!.dx - p.x;
          final dy = _touchPos!.dy - p.y;
          final dist = math.sqrt(dx*dx + dy*dy);
          if (dist > 1.0 && dist < 120.0) {
            final force = (1.0 - (dist / 120.0)) * 1.6;
            p.vx += (dx / dist) * force * 0.45;
            p.vy += (dy / dist) * force * 0.45;
            p.vx += (dy / dist) * force * 1.1;
            p.vy -= (dx / dist) * force * 1.1;
          }
        }
        
        p.x += p.vx;
        p.y += p.vy;
        
        if (p.x < 0) { p.x = 0; p.vx *= -0.5; }
        if (p.x > 200) { p.x = 200; p.vx *= -0.5; }
        if (p.y < 0) { p.y = 0; p.vy *= -0.5; }
        if (p.y > 350) { p.y = 350; p.vy *= -0.5; }
      }
    });
  }

  void _animateVaporwave() {
    if (!mounted || widget.engineId != 'vaporwave') return;
    setState(() {
      _vaporwaveTime += 0.015;
    });
  }

  void _initVoronoi() {
    final rand = math.Random();
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF8B5CF6),
    ];
    for (int i = 0; i < 12; i++) {
      _voronoiPoints.add(VoronoiPoint(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        vx: (rand.nextDouble() - 0.5) * 1.5,
        vy: (rand.nextDouble() - 0.5) * 1.5,
        color: colors[rand.nextInt(colors.length)],
      ));
    }
  }

  void _animateVoronoi() {
    if (!mounted || widget.engineId != 'voronoi') return;
    setState(() {
      for (var p in _voronoiPoints) {
        p.x += p.vx;
        p.y += p.vy;
        if (p.x < 0 || p.x > 200) p.vx *= -1;
        if (p.y < 0 || p.y > 350) p.vy *= -1;
      }
    });
  }

  void _initBoids() {
    final rand = math.Random();
    _boids.clear();
    for (int i = 0; i < 45; i++) {
      _boids.add(Boid(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        vx: (rand.nextDouble() - 0.5) * 4,
        vy: (rand.nextDouble() - 0.5) * 4,
      ));
    }
  }

  void _animateBoids() {
    if (!mounted || widget.engineId != 'boids') return;
    final rand = math.Random();
    setState(() {
      for (var b in _boids) {
        b.history.add(Offset(b.x, b.y));
        if (b.history.length > 8) b.history.removeAt(0);

        double avgX = 0;
        double avgY = 0;
        double avgVx = 0;
        double avgVy = 0;
        int count = 0;

        for (var other in _boids) {
          if (other != b) {
            final dist = math.sqrt((b.x - other.x) * (b.x - other.x) + (b.y - other.y) * (b.y - other.y));
            if (dist < 40.0) {
              avgX += other.x;
              avgY += other.y;
              avgVx += other.vx;
              avgVy += other.vy;
              count++;
            }
          }
        }

        if (count > 0) {
          avgX /= count;
          avgY /= count;
          avgVx /= count;
          avgVy /= count;

          b.vx += (avgX - b.x) * 0.002;
          b.vy += (avgY - b.y) * 0.002;
          b.vx += (avgVx - b.vx) * 0.015;
          b.vy += (avgVy - b.vy) * 0.015;
        }

        b.vx += (rand.nextDouble() - 0.5) * 0.45;
        b.vy += (rand.nextDouble() - 0.5) * 0.45;

        if (b.x < 15) b.vx += 0.35;
        if (b.x > 185) b.vx -= 0.35;
        if (b.y < 15) b.vy += 0.35;
        if (b.y > 335) b.vy -= 0.35;

        final speed = math.sqrt(b.vx * b.vx + b.vy * b.vy);
        if (speed > 5.5) {
          b.vx = (b.vx / speed) * 5.5;
          b.vy = (b.vy / speed) * 5.5;
        } else if (speed < 1.5) {
          b.vx = (b.vx / speed) * 2.0;
          b.vy = (b.vy / speed) * 2.0;
        }

        b.x += b.vx;
        b.y += b.vy;
      }
    });
  }

  void _initSakura() {
    final rand = math.Random();
    for (int i = 0; i < 20; i++) {
      _sakuraPetals.add(SakuraPetal(
        x: rand.nextDouble() * 200,
        y: rand.nextDouble() * 350,
        size: rand.nextDouble() * 3.5 + 2.0,
        speedY: rand.nextDouble() * 0.8 + 0.6,
        speedX: (rand.nextDouble() - 0.5) * 0.5,
        angle: rand.nextDouble() * 2 * math.pi,
        rotateSpeed: (rand.nextDouble() - 0.5) * 0.05,
      ));
    }
  }

  void _animateSakura() {
    if (!mounted || widget.engineId != 'sakura') return;
    setState(() {
      for (var p in _sakuraPetals) {
        p.y += p.speedY;
        p.x += p.speedX + _windX;
        p.angle += p.rotateSpeed;

        if (p.y > 350) {
          final rand = math.Random();
          p.y = -10;
          p.x = rand.nextDouble() * 200;
        }
        if (p.x < -10) p.x = 210;
        if (p.x > 210) p.x = -10;
      }
      _windX = _windX * 0.95 + 0.05 * math.sin(_controller.value * 2 * math.pi) * 0.5;
    });
  }

  void _initPachinko() {
    _pachinkoPins.clear();
    for (int row = 0; row < 9; row++) {
      final y = 60.0 + row * 32.0;
      final pinsInRow = 6 + (row % 2);
      final spacing = 200.0 / (pinsInRow + 1);
      for (int col = 0; col < pinsInRow; col++) {
        _pachinkoPins.add(PachinkoPin(x: spacing * (col + 1), y: y, radius: 4.5));
      }
    }
  }

  void _animatePachinko() {
    if (!mounted || widget.engineId != 'pachinko') return;
    final rand = math.Random();
    
    if (rand.nextDouble() < 0.04 && _pachinkoBalls.length < 8) {
      final colors = [const Color(0xFF38BDF8), const Color(0xFFF43F5E), const Color(0xFF10B981)];
      _pachinkoBalls.add(PachinkoBall(
        x: 60.0 + rand.nextDouble() * 80.0,
        y: 10,
        vx: (rand.nextDouble() - 0.5) * 1.0,
        vy: 1.0,
        color: colors[rand.nextInt(colors.length)],
      ));
    }

    setState(() {
      // 1. Actualizar física de canicas
      for (int i = _pachinkoBalls.length - 1; i >= 0; i--) {
        final b = _pachinkoBalls[i];
        b.vy += 0.12;
        b.x += b.vx;
        b.y += b.vy;

        for (var pin in _pachinkoPins) {
          final dx = b.x - pin.x;
          final dy = b.y - pin.y;
          final distSq = dx * dx + dy * dy;
          final radiusSum = pin.radius + 6.0;
          if (distSq < radiusSum * radiusSum) {
            final dist = math.sqrt(distSq);
            b.x = pin.x + (dx / dist) * radiusSum;
            b.y = pin.y + (dy / dist) * radiusSum;

            final nx = dx / dist;
            final ny = dy / dist;
            final dot = b.vx * nx + b.vy * ny;
            b.vx = (b.vx - 2 * dot * nx) * 0.65;
            b.vy = (b.vy - 2 * dot * ny) * 0.65;
            b.vx += (rand.nextDouble() - 0.5) * 0.4;

            for (int k = 0; k < 4; k++) {
              final angle = rand.nextDouble() * 2 * math.pi;
              final speed = rand.nextDouble() * 1.5 + 0.5;
              _pachinkoSparks.add(PachinkoSpark(
                x: pin.x + nx * radiusSum,
                y: pin.y + ny * radiusSum,
                vx: math.cos(angle) * speed,
                vy: math.sin(angle) * speed - 0.5,
                alpha: 1.0,
                color: b.color,
              ));
            }
          }
        }

        if (b.x < 8) { b.x = 8; b.vx *= -0.7; }
        if (b.x > 192) { b.x = 192; b.vx *= -0.7; }

        if (b.y > 360) {
          _pachinkoBalls.removeAt(i);
        }
      }

      // 2. Actualizar física de chispas
      for (int i = _pachinkoSparks.length - 1; i >= 0; i--) {
        final s = _pachinkoSparks[i];
        s.x += s.vx;
        s.y += s.vy;
        s.vy += 0.04; // gravedad de la chispa
        s.alpha -= 0.05; // desvanecimiento gradual
        if (s.alpha <= 0) {
          _pachinkoSparks.removeAt(i);
        }
      }
    });
  }

  void _initKaleidoscope() {
    final rand = math.Random();
    final colors = [
      const Color(0xFFF43F5E),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    for (int i = 0; i < 24; i++) {
      _kaleidoscopeItems.add(KaleidoscopeItem(
        radius: rand.nextDouble() * 150.0 + 10.0,
        angle: rand.nextDouble() * (2 * math.pi / 8.0),
        size: rand.nextDouble() * 12.0 + 4.0,
        speedRadius: (rand.nextDouble() - 0.5) * 0.6,
        speedAngle: (rand.nextDouble() - 0.5) * 0.005,
        color: colors[rand.nextInt(colors.length)],
        type: rand.nextInt(3),
      ));
    }
  }

  void _animateKaleidoscope() {
    if (!mounted || widget.engineId != 'kaleidoscope') return;
    setState(() {
      const sectorAngle = 2 * math.pi / 8.0;
      for (var item in _kaleidoscopeItems) {
        item.radius += item.speedRadius;
        item.angle += item.speedAngle;

        if (item.radius < 5.0 || item.radius > 170.0) {
          item.speedRadius *= -1.0;
        }

        if (item.angle < 0) {
          item.angle = 0;
          item.speedAngle *= -1.0;
        } else if (item.angle > sectorAngle) {
          item.angle = sectorAngle;
          item.speedAngle *= -1.0;
        }
      }
      _gyroAngle = math.sin(_controller.value * 2 * math.pi) * 0.25;
    });
  }

  void _animateJulia() {
    if (!mounted || widget.engineId != 'julia') return;
    setState(() {
      final angle = _controller.value * 2 * math.pi;
      _juliaCx = -0.7 + 0.12 * math.sin(angle);
      _juliaCy = 0.27015 + 0.08 * math.cos(angle * 2.0);
    });
  }

  void _handleTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    if (widget.engineId == 'conway') {
      final cellW = 200.0 / 30;
      final cellH = 350.0 / 50;
      final gx = (pos.dx / cellW).toInt().clamp(0, 29);
      final gy = (pos.dy / cellH).toInt().clamp(0, 49);
      _spawnConwayGlider(gx, gy);
    } else if (widget.engineId == 'starfield') {
      setState(() {
        _isWarping = true;
      });
    } else if (widget.engineId == 'fluids') {
      setState(() {
        _touchPos = pos;
      });
    } else if (widget.engineId == 'julia') {
      // Julia reacciona automáticamente ahora, touch ignorado o ripple sutil
    } else if (widget.engineId == 'sakura') {
      setState(() {
        _windX = 2.0;
      });
    } else if (widget.engineId == 'pachinko') {
      final colors = [const Color(0xFF38BDF8), const Color(0xFFF43F5E), const Color(0xFF10B981)];
      final rand = math.Random();
      setState(() {
        _pachinkoBalls.add(PachinkoBall(
          x: pos.dx,
          y: pos.dy,
          vx: (rand.nextDouble() - 0.5) * 1.5,
          vy: -1.0,
          color: colors[rand.nextInt(colors.length)],
        ));
      });
    } else if (widget.engineId == 'voronoi') {
      setState(() {
        for (var p in _voronoiPoints) {
          final dx = p.x - pos.dx;
          final dy = p.y - pos.dy;
          final dist = math.sqrt(dx*dx + dy*dy);
          if (dist < 100.0) {
            p.vx = (dx / dist) * 2.5;
            p.vy = (dy / dist) * 2.5;
          }
        }
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final pos = details.localPosition;
    if (widget.engineId == 'fluids') {
      setState(() {
        _touchPos = pos;
      });
    } else if (widget.engineId == 'conway') {
      final cellW = 200.0 / 30;
      final cellH = 350.0 / 50;
      final gx = (pos.dx / cellW).toInt().clamp(0, 29);
      final gy = (pos.dy / cellH).toInt().clamp(0, 49);
      setState(() {
        _conwayGrid[gy][gx] = true;
      });
    } else if (widget.engineId == 'julia') {
      setState(() {
        _juliaCx = (pos.dx / 200.0) * 2.0 - 1.0;
        _juliaCy = (pos.dy / 350.0) * 3.0 - 1.5;
      });
    } else if (widget.engineId == 'boids') {
      setState(() {
        for (var b in _boids) {
          final dx = pos.dx - b.x;
          final dy = pos.dy - b.y;
          final dist = math.sqrt(dx*dx + dy*dy);
          if (dist > 1.0 && dist < 120.0) {
            b.vx += (dx / dist) * 0.4;
            b.vy += (dy / dist) * 0.4;
          }
        }
      });
    }
  }

  void _handleTouchEnd() {
    setState(() {
      _isWarping = false;
      _touchPos = null;
    });
  }

  void _spawnConwayGlider(int cx, int cy) {
    final gliderOffsets = [
      const Offset(0, -1),
      const Offset(1, 0),
      const Offset(-1, 1),
      const Offset(0, 1),
      const Offset(1, 1)
    ];
    setState(() {
      for (var offset in gliderOffsets) {
        final nx = (cx + offset.dx.toInt() + 30) % 30;
        final ny = (cy + offset.dy.toInt() + 50) % 50;
        _conwayGrid[ny][nx] = true;
      }
    });
  }

  bool _checkCollision(int nx, int ny, List<List<int>> shape) {
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) {
          int tx = nx + x;
          int ty = ny + y;
          if (tx < 0 || tx >= 10 || ty >= 18 || (ty >= 0 && _tetrisGrid[ty][tx] != 0)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _lockPiece() {
    final shape = _activePiece.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) {
          int ty = _activePiece.y + y;
          int tx = _activePiece.x + x;
          if (ty >= 0 && ty < 18) {
            _tetrisGrid[ty][tx] = _activePiece.type + 1;
          }
        }
      }
    }
    if (_activePiece.y <= 1) {
      _tetrisGrid = List.generate(18, (_) => List.generate(10, (_) => 0));
    }
  }

  void _clearLines() {
    for (int y = 17; y >= 0; y--) {
      if (_tetrisGrid[y].every((val) => val != 0)) {
        for (int moveY = y; moveY > 0; moveY--) {
          _tetrisGrid[moveY] = List.from(_tetrisGrid[moveY - 1]);
        }
        _tetrisGrid[0] = List.generate(10, (_) => 0);
        _clearLines();
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          CustomPainter painter;
          
          switch (widget.engineId) {
            case 'particles':
              painter = ParticlesPainter(_particles);
              break;
            case 'matrix':
              painter = MatrixRainPainter(_controller.value * 2 * math.pi, _matrixCols);
              break;
            case 'plexus':
              painter = PlexusPainter(_plexusNodes);
              break;
            case 'liquid':
              painter = LiquidGradientPainter(_controller.value * 2 * math.pi);
              break;
            case 'tetris':
              painter = TetrisPainter(_controller.value, _tetrisGrid, widget.tetrisStyle, _activePiece);
              break;
            case 'starfield':
              painter = StarfieldPainter(_stars, _starSpeed);
              break;
            case 'vaporwave':
              painter = VaporwavePainter(_vaporwaveTime);
              break;
            case 'conway':
              painter = ConwayPainter(_conwayGrid);
              break;
            case 'fluids':
              painter = FluidSwarmPainter(_fluidParticles);
              break;
            case 'voronoi':
              painter = VoronoiPainter(_voronoiPoints, _controller.value);
              break;
            case 'waveforms':
              painter = WaveformsPainter(_controller.value * 2 * math.pi);
              break;
            case 'boids':
              painter = BoidsPainter(_boids);
              break;
            case 'julia':
              painter = JuliaPainter(cx: _juliaCx, cy: _juliaCy, time: _controller.value, colorScheme: widget.juliaColorScheme);
              break;
            case 'sakura':
              painter = SakuraPainter(_sakuraPetals, _windX);
              break;
            case 'pachinko':
              painter = PachinkoPainter(balls: _pachinkoBalls, pins: _pachinkoPins, sparks: _pachinkoSparks);
              break;
            case 'kaleidoscope':
              painter = KaleidoscopePainter(items: _kaleidoscopeItems, gyroAngle: _gyroAngle);
              break;
            default:
              final playlist = widget.playlist;
              if (playlist == null || playlist.isEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            Theme.of(context).colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.08,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                        itemBuilder: (_, __) => const Center(child: Text('.', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.photo_library_outlined, size: 48, color: Colors.white54),
                    ),
                  ],
                );
              }
              
              return _CarouselPreview(
                playlist: playlist,
                animationValue: _controller.value,
              );
          }
          
          return GestureDetector(
            onTapDown: _handleTapDown,
            onPanStart: (details) => _handlePanUpdate(details as dynamic),
            onPanUpdate: _handlePanUpdate,
            onPanEnd: (_) => _handleTouchEnd(),
            onTapUp: (_) => _handleTouchEnd(),
            onTapCancel: () => _handleTouchEnd(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: painter),
                if (widget.isDimEnabled)
                  Container(color: Colors.black.withValues(alpha: widget.dimIntensity)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CarouselPreview extends StatefulWidget {
  final List<String> playlist;
  final double animationValue;

  const _CarouselPreview({
    required this.playlist,
    required this.animationValue,
  });

  @override
  State<_CarouselPreview> createState() => _CarouselPreviewState();
}

class _CarouselPreviewState extends State<_CarouselPreview> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  String? _currentPath;
  String? _prevPath;
  bool _isNewImageLoaded = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _currentIndex = _calculateIndex();
    if (widget.playlist.isNotEmpty) {
      _currentPath = widget.playlist[_currentIndex];
    }
    _fadeController.value = 1.0;
  }

  int _calculateIndex() {
    if (widget.playlist.isEmpty) return 0;
    return ((widget.animationValue * widget.playlist.length).toInt()) % widget.playlist.length;
  }

  @override
  void didUpdateWidget(covariant _CarouselPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playlist.isEmpty) {
      _currentPath = null;
      _prevPath = null;
      return;
    }
    final newIndex = _calculateIndex();
    if (newIndex != _currentIndex) {
      _prevPath = _currentPath;
      _currentIndex = newIndex;
      _currentPath = widget.playlist[_currentIndex];
      _isNewImageLoaded = false;
      _fadeController.reset();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prev = _prevPath;
    final curr = _currentPath;

    if (curr == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (prev != null)
          Image.file(
            File(prev),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeController.value,
              child: child,
            );
          },
          child: Image.file(
            File(curr),
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                if (!_isNewImageLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isNewImageLoaded = true;
                      });
                      _fadeController.forward(from: 0.0).then((_) {
                        if (mounted) {
                          setState(() {
                            _prevPath = null;
                          });
                        }
                      });
                    }
                  });
                }
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (context, error, stackTrace) {
              final isVideo = curr.toLowerCase().endsWith('.mp4') ||
                  curr.toLowerCase().endsWith('.mov') ||
                  curr.toLowerCase().endsWith('.mkv');
              return Container(
                color: Theme.of(context).colorScheme.surface,
                alignment: Alignment.center,
                child: Icon(
                  isVideo ? Icons.video_collection_outlined : Icons.broken_image_outlined,
                  size: 48,
                  color: Colors.white54,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

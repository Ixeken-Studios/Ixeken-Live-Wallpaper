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
  
  const LiveWallpaperPreview({
    super.key, 
    required this.engineId, 
    required this.isDimEnabled,
    required this.dimIntensity,
    required this.tetrisStyle,
    this.playlist,
  });

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
    
    _controller.addListener(() {
      _animateTetris();
      _animateStarfield();
      _animateConway();
      _animateFluids();
      _animateVaporwave();
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
              
              final index = ((_controller.value * playlist.length).toInt()) % playlist.length;
              final currentPath = playlist[index];
              
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: Image.file(
                  File(currentPath),
                  key: ValueKey<String>(currentPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    final isVideo = currentPath.toLowerCase().endsWith('.mp4') ||
                                    currentPath.toLowerCase().endsWith('.mov') ||
                                    currentPath.toLowerCase().endsWith('.mkv');
                    return Container(
                      key: ValueKey<String>('error_$currentPath'),
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

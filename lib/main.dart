import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallpaper_manager.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  runApp(const IxekenApp());
}

class IxekenApp extends StatelessWidget {
  const IxekenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ixeken Live Wallpaper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Playlists
  List<String> _playlistGeneral = [];
  List<String> _playlistDay = [];
  List<String> _playlistNight = [];

  // Settings
  bool _useDayNightMode = false;
  bool _isDimEnabled = false;
  bool _isRandom = false;
  String _tetrisStyle = 'neon';
  int _dayStartHour = 6;
  int _nightStartHour = 18;
  String _selectedEngine = 'carousel';

  final Map<String, String> _engines = {
    'carousel': 'Carrusel de Medios',
    'particles': 'Ixeken Particles 🌌',
    'tetris': 'Ixeken Tetris AI 🕹️',
    'matrix': 'Matrix Code Rain 💾',
    'plexus': 'Ixeken Plexus 🕸️',
    'liquid': 'Liquid Gradient 🌊',
    'starfield': 'Túnel de Estrellas ✨',
    'vaporwave': 'Retro Vaporwave 🌅',
    'conway': 'Game of Life 🦠',
    'fluids': 'Swarm Fluids 💨',
  };

  final Map<String, String> _engineDescriptions = {
    'particles': 'Un fondo dinámico con partículas de neón que flotan y rebotan suavemente por toda tu pantalla. Optimizado para un consumo mínimo de batería.',
    'tetris': 'Revive el clásico con una IA que juega automáticamente. Las piezas buscan huecos inteligentemente para completar líneas y mantener el tablero limpio.',
    'matrix': 'La icónica lluvia de caracteres digitales. Transforma tu pantalla en una terminal de datos con estelas de neón verde sobre negro profundo.',
    'plexus': 'Una red neuronal de puntos conectados por líneas dinámicas. El sistema detecta la proximidad de los nodos para crear una malla tecnológica en tiempo real.',
    'liquid': 'Colores profundos que fluyen y se mezclan lentamente, creando una atmósfera minimalista y relajante que cambia de forma orgánica.',
    'starfield': 'Viaja a través del hiperespacio en 3D. Toca la pantalla para activar el hiperimpulsor y ver las estrellas estirarse a velocidad luz.',
    'vaporwave': 'Un atardecer retro de los 80s con rejillas púrpuras en perspectiva 3D desplazándose de forma infinita hacia adelante.',
    'conway': 'El Juego de la Vida de Conway. Células de neón cian que viven, mueren y evolucionan de forma autónoma. ¡Toca la pantalla para sembrar vida!',
    'fluids': 'Enjambre interactivo de partículas que fluyen como remolinos de humo. El enjambre reacciona dinámicamente siguiendo el arrastre de tus dedos.',
  };

  final Map<String, IconData> _engineIcons = {
    'particles': Icons.blur_on,
    'tetris': Icons.grid_view_rounded,
    'matrix': Icons.code,
    'plexus': Icons.hub_outlined,
    'liquid': Icons.water_drop_outlined,
    'starfield': Icons.auto_awesome_motion_outlined,
    'vaporwave': Icons.wb_sunny_outlined,
    'conway': Icons.coronavirus_outlined,
    'fluids': Icons.waves_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _playlistGeneral = prefs.getStringList('playlist_general') ?? [];
      _playlistDay = prefs.getStringList('playlist_day') ?? [];
      _playlistNight = prefs.getStringList('playlist_night') ?? [];
      _useDayNightMode = prefs.getBool('use_day_night') ?? false;
      _isDimEnabled = prefs.getBool('is_dim') ?? false;
      _isRandom = prefs.getBool('is_random') ?? false;
      _tetrisStyle = prefs.getString('tetris_style') ?? 'neon';
      _dayStartHour = prefs.getInt('day_start') ?? 6;
      _nightStartHour = prefs.getInt('night_start') ?? 18;
      _selectedEngine = prefs.getString('selected_engine') ?? 'carousel';
    });
  }

  Future<void> _savePersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('playlist_general', _playlistGeneral);
    await prefs.setStringList('playlist_day', _playlistDay);
    await prefs.setStringList('playlist_night', _playlistNight);
    await prefs.setBool('use_day_night', _useDayNightMode);
    await prefs.setBool('is_dim', _isDimEnabled);
    await prefs.setBool('is_random', _isRandom);
    await prefs.setString('tetris_style', _tetrisStyle);
    await prefs.setInt('day_start', _dayStartHour);
    await prefs.setInt('night_start', _nightStartHour);
    await prefs.setString('selected_engine', _selectedEngine);
  }

  Future<void> _pickFiles(String type) async {
    if (Platform.isAndroid) {
      await [Permission.storage, Permission.photos, Permission.videos].request();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null) {
      setState(() {
        final paths = result.paths.whereType<String>();
        if (type == 'general') _playlistGeneral.addAll(paths);
        if (type == 'day') _playlistDay.addAll(paths);
        if (type == 'night') _playlistNight.addAll(paths);
      });
      await _savePersistedData();
    }
  }

  Future<void> _applySettings() async {
    await _savePersistedData();
    
    await WallpaperManager.updateSettings(
      changeOnVisible: false,
      useDayNightMode: _useDayNightMode,
      dayStartHour: _dayStartHour,
      nightStartHour: _nightStartHour,
      isDimEnabled: _isDimEnabled,
      selectedEngine: _selectedEngine,
      isRandom: _isRandom,
      tetrisStyle: _tetrisStyle,
    );

    bool success = true;
    if (_selectedEngine == 'carousel') {
      if (_useDayNightMode) {
        final newDay = await WallpaperManager.updatePlaylist(_playlistDay, type: 'day');
        final newNight = await WallpaperManager.updatePlaylist(_playlistNight, type: 'night');
        if (newDay != null && newNight != null) {
          setState(() {
            _playlistDay = newDay;
            _playlistNight = newNight;
          });
        } else {
          success = false;
        }
      } else {
        final newGeneral = await WallpaperManager.updatePlaylist(_playlistGeneral, type: 'general');
        if (newGeneral != null) {
          setState(() {
            _playlistGeneral = newGeneral;
          });
        } else {
          success = false;
        }
      }
      if (success) {
        await _savePersistedData();
      }
    }

    if (success) {
      await WallpaperManager.openWallpaperPicker();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fondo aplicado correctamente'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ixeken Live Wallpaper', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildEngineSelector(),
            if (_selectedEngine == 'carousel') ...[
              _buildSettingsSection(),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
              _useDayNightMode ? _buildDayNightPlaylists() : _buildGeneralPlaylist(),
            ] else 
              _buildEnginePreview(_selectedEngine),
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _applySettings,
        label: const Text('ACTIVAR FONDO'),
        icon: const Icon(Icons.wallpaper),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildEngineSelector() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: Colors.deepPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedEngine,
              isExpanded: true,
              dropdownColor: Colors.black87,
              items: _engines.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Row(
                  children: [
                    Icon(_engineIcons[e.key] ?? Icons.auto_awesome, size: 20, color: Colors.deepPurpleAccent),
                    const SizedBox(width: 12),
                    Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedEngine = val);
                  _savePersistedData();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnginePreview(String engineId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 9 / 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: LiveWallpaperPreview(
                engineId: engineId,
                isDimEnabled: _isDimEnabled,
                tetrisStyle: _tetrisStyle,
              ),
            ),
          ),
          if (engineId == 'tetris') ...[
            const SizedBox(height: 16),
            const Text(
              'Estilo Visual de Tetris',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildStyleChip('Neon Glow', 'neon'),
                _buildStyleChip('Retro Gameboy', 'retro'),
                _buildStyleChip('Pastel Minimal', 'pastel'),
                _buildStyleChip('Cyberpunk Outline', 'outline'),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(
            _engineDescriptions[engineId] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String label, String value) {
    final isSelected = _tetrisStyle == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepPurple.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurpleAccent : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) {
          setState(() => _tetrisStyle = value);
          _savePersistedData();
        }
      },
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Modo Inteligente (Día/Noche)'),
              subtitle: const Text('Cambia la galería según la hora'),
              value: _useDayNightMode,
              activeColor: Colors.amber,
              onChanged: (val) {
                setState(() => _useDayNightMode = val);
                _savePersistedData();
              },
            ),
            if (_useDayNightMode) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ActionChip(
                        avatar: const Icon(Icons.wb_sunny_outlined, size: 16),
                        label: Text('Día: ${_dayStartHour}:00'),
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _dayStartHour, minute: 0));
                          if (time != null) {
                            setState(() => _dayStartHour = time.hour);
                            _savePersistedData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ActionChip(
                        avatar: const Icon(Icons.nightlight_outlined, size: 16),
                        label: Text('Noche: ${_nightStartHour}:00'),
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _nightStartHour, minute: 0));
                          if (time != null) {
                            setState(() => _nightStartHour = time.hour);
                            _savePersistedData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: const Text('Oscurecer fondo (Dim)'),
              subtitle: const Text('Para resaltar los iconos del sistema'),
              value: _isDimEnabled,
              onChanged: (val) {
                setState(() => _isDimEnabled = val);
                _savePersistedData();
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: const Text('Orden aleatorio (Random)'),
              subtitle: const Text('Muestra las imágenes sin un orden fijo'),
              value: _isRandom,
              activeColor: Colors.deepPurpleAccent,
              onChanged: (val) {
                setState(() => _isRandom = val);
                _savePersistedData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralPlaylist() {
    return _buildMediaList('Mi Galería', _playlistGeneral, () => _pickFiles('general'), (idx) {
      setState(() => _playlistGeneral.removeAt(idx));
      _savePersistedData();
    });
  }

  Widget _buildDayNightPlaylists() {
    return Column(
      children: [
        _buildMediaList('Galería Día ☀️', _playlistDay, () => _pickFiles('day'), (idx) {
          setState(() => _playlistDay.removeAt(idx));
          _savePersistedData();
        }),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Divider()),
        _buildMediaList('Galería Noche 🌙', _playlistNight, () => _pickFiles('night'), (idx) {
          setState(() => _playlistNight.removeAt(idx));
          _savePersistedData();
        }),
      ],
    );
  }

  Widget _buildMediaList(String title, List<String> list, VoidCallback onAdd, Function(int) onDelete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
              Row(
                children: [
                  if (list.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => list.clear());
                        _savePersistedData();
                      },
                      icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.redAccent),
                      label: const Text('Limpiar', style: TextStyle(color: Colors.redAccent)),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onAdd, 
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir'),
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (list.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.collections_outlined, size: 48, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  Text('Añade fotos o videos aquí', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final path = list[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => const Icon(Icons.movie, color: Colors.blueGrey)),
                  ),
                  title: Text(path.split('/').last, maxLines: 1, style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20), 
                    onPressed: () => onDelete(index)),
                ),
              );
            },
          ),
      ],
    );
  }
}

class LiveWallpaperPreview extends StatefulWidget {
  final String engineId;
  final bool isDimEnabled;
  final String tetrisStyle;
  
  const LiveWallpaperPreview({
    super.key, 
    required this.engineId, 
    required this.isDimEnabled,
    required this.tetrisStyle,
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
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple.shade900, Colors.black],
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
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Vista Previa del Carrusel',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
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
                  Container(color: Colors.black.withOpacity(0.43)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LiquidGradientPainter extends CustomPainter {
  final double time;
  LiquidGradientPainter(this.time);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF080512));
    
    final x1 = size.width * 0.35 + math.sin(time) * (size.width * 0.18);
    final y1 = size.height * 0.3 + math.cos(time * 0.9) * (size.height * 0.12);
    drawBlob(canvas, x1, y1, size.width * 0.65, const Color(0xFF6366F1), 0.33);
    
    final x2 = size.width * 0.65 + math.cos(time * 1.1) * (size.width * 0.2);
    final y2 = size.height * 0.7 + math.sin(time * 0.8) * (size.height * 0.15);
    drawBlob(canvas, x2, y2, size.width * 0.75, const Color(0xFFEC4899), 0.28);
    
    final x3 = size.width * 0.5 + math.sin(time * 0.7) * (size.width * 0.22);
    final y3 = size.height * 0.5 + math.cos(time * 1.3) * (size.height * 0.18);
    drawBlob(canvas, x3, y3, size.width * 0.6, const Color(0xFF06B6D4), 0.26);
    
    final x4 = size.width * 0.6 + math.cos(time * 0.6) * (size.width * 0.25);
    final y4 = size.height * 0.4 + math.sin(time * 0.7) * (size.height * 0.2);
    drawBlob(canvas, x4, y4, size.width * 0.7, const Color(0xFF8B5CF6), 0.3);
  }
  
  void drawBlob(ui.Canvas canvas, double x, double y, double radius, Color color, double opacity) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x, y),
        radius,
        [color.withOpacity(opacity), Colors.transparent],
      );
    canvas.drawCircle(Offset(x, y), radius, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MatrixRainPainter extends CustomPainter {
  final double time;
  final List<MatrixColumnState> columns;
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
            : const Color(0xFF10B981).withOpacity(opacity);
        
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

class MatrixColumnState {
  final double xOffset;
  double yPos;
  final double speed;
  final int length;
  final List<String> chars;
  
  MatrixColumnState({
    required this.xOffset,
    required this.yPos,
    required this.speed,
    required this.length,
    required this.chars,
  });
  
  void reset() {
    yPos = -math.Random().nextDouble() * 10;
  }
  
  void mutate() {
    if (chars.isNotEmpty) {
      chars[math.Random().nextInt(chars.length)] = 
          "0123456789日ハミヒヘホマミムメモヤユヨラリルレロ"[math.Random().nextInt(27)];
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final List<ParticleState> particles;
  ParticlesPainter(this.particles);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0F0F1B));
    
    final paint = Paint()..isAntiAlias = true;
    for (var p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      
      if (p.x < 0 || p.x > size.width) p.vx *= -1;
      if (p.y < 0 || p.y > size.height) p.vy *= -1;
      
      p.x = p.x.clamp(0.0, size.width);
      p.y = p.y.clamp(0.0, size.height);
      
      paint.color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleState {
  double x;
  double y;
  double vx;
  double vy;
  final double radius;
  final Color color;
  
  ParticleState({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

class PlexusPainter extends CustomPainter {
  final List<ParticleState> nodes;
  PlexusPainter(this.nodes);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0A0F1D));
    
    final paintNode = Paint()..isAntiAlias = true..color = const Color(0xFF00D2FF).withOpacity(0.7);
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
          paintLine.color = const Color(0xFF00D2FF).withOpacity(alpha * 0.3);
          canvas.drawLine(Offset(nodes[i].x, nodes[i].y), Offset(nodes[j].x, nodes[j].y), paintLine);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TetrisPainter extends CustomPainter {
  final double time;
  final List<List<int>> grid;
  final String style;
  final TetrisPiece activePiece;
  
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
    
    gridPaint.color = gridPaint.color.withOpacity(isRetro ? 0.12 : 0.05);
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
      paint.color = Colors.white.withOpacity(0.25);
      canvas.drawRRect(highlightRRect, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TetrisPiece {
  int x;
  int y;
  int type;
  List<List<int>> shape;
  
  TetrisPiece({required this.x, required this.y, required this.type, required this.shape});
}

// ------------------------------------------
// PINTORES ADICIONALES (NUEVOS FONDOS)
// ------------------------------------------

class StarfieldPainter extends CustomPainter {
  final List<StarState> stars;
  final double speed;
  StarfieldPainter(this.stars, this.speed);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF030206));
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    for (var s in stars) {
      final x2d = (s.x / s.z) * cx + cx;
      final y2d = (s.y / s.z) * cy + cy;
      
      final px2d = (s.x / s.prevZ) * cx + cx;
      final py2d = (s.y / s.prevZ) * cy + cy;
      
      if (x2d < 0 || x2d > size.width || y2d < 0 || y2d > size.height) {
        continue;
      }
      
      final thickness = (1.0 - (s.z / 500.0)) * 3.5 + 0.8;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = thickness;
        
      if (speed > 8.0) {
        canvas.drawLine(Offset(px2d, py2d), Offset(x2d, y2d), paint);
      } else {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x2d, y2d), thickness * 0.7, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VaporwavePainter extends CustomPainter {
  final double time;
  VaporwavePainter(this.time);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.48;
    
    // Sky
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, horizon),
        [const Color(0xFF1D0030), const Color(0xFFA80077), const Color(0xFFFF5E62)],
      );
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, w, horizon), skyPaint);
    
    // Sun
    final sunRadius = w * 0.28;
    final sunCx = w / 2;
    final sunCy = horizon - 20;
    
    canvas.save();
    canvas.clipRect(ui.Rect.fromLTWH(sunCx - sunRadius, sunCy - sunRadius, sunRadius * 2, sunRadius * 2));
    
    final sunPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(sunCx, sunCy - sunRadius),
        Offset(sunCx, sunCy + sunRadius),
        [const Color(0xFFFFD97D), const Color(0xFFFF1493)],
      );
    canvas.drawCircle(Offset(sunCx, sunCy), sunRadius, sunPaint);
    
    final stripePaint = Paint()..color = const Color(0xFFA80077);
    double stripeY = sunCy + 10;
    double stripeH = 3.0;
    while (stripeY < sunCy + sunRadius) {
      canvas.drawRect(ui.Rect.fromLTWH(sunCx - sunRadius, stripeY, sunRadius * 2, stripeH), stripePaint);
      stripeY += stripeH + 6.0;
      stripeH += 1.5;
    }
    canvas.restore();
    
    // Ground
    final groundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, horizon),
        Offset(0, h),
        [const Color(0xFF090014), Colors.black],
      );
    canvas.drawRect(ui.Rect.fromLTWH(0, horizon, w, h - horizon), groundPaint);
    
    // Grid lines
    final paintGrid = Paint()
      ..color = const Color(0xFFFF007F)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
      
    final numVerticalLines = 10;
    for (int i = 0; i <= numVerticalLines; i++) {
      final ratio = i / numVerticalLines;
      final targetX = (ratio - 0.5) * w * 3 + (w / 2);
      canvas.drawLine(Offset(w / 2, horizon), Offset(targetX, h), paintGrid);
    }
    
    final gridPhase = (time * 0.8) % 1.0;
    final groundHeight = h - horizon;
    final numHorizontalLines = 10;
    for (int i = 0; i <= numHorizontalLines; i++) {
      final progress = (i - gridPhase) / numHorizontalLines;
      if (progress < 0) continue;
      
      final expProgress = math.pow(progress, 2.2);
      final gridY = horizon + expProgress * groundHeight;
      
      paintGrid.color = const Color(0xFFFF007F).withOpacity(progress.clamp(0.0, 1.0));
      paintGrid.strokeWidth = progress * 2.0 + 0.3;
      canvas.drawLine(Offset(0, gridY), Offset(w, gridY), paintGrid);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConwayPainter extends CustomPainter {
  final List<List<bool>> grid;
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

class FluidSwarmPainter extends CustomPainter {
  final List<FluidParticleState> particles;
  FluidSwarmPainter(this.particles);
  
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF06050F));
    
    final paintLine = Paint()..isAntiAlias = true;
    final paintHead = Paint()..isAntiAlias = true..style = PaintingStyle.fill;
    
    for (var p in particles) {
      paintLine.color = p.color.withOpacity(0.5);
      paintLine.strokeWidth = p.radius * 0.8;
      canvas.drawLine(Offset(p.px, p.py), Offset(p.x, p.y), paintLine);
      
      paintHead.color = p.color.withOpacity(0.9);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paintHead);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarState {
  double x;
  double y;
  double z;
  double prevZ;
  final Color color;
  StarState({required this.x, required this.y, required this.z, required this.prevZ, required this.color});
}

class FluidParticleState {
  double x;
  double y;
  double px;
  double py;
  double vx;
  double vy;
  final double radius;
  final Color color;
  FluidParticleState({
    required this.x,
    required this.y,
    required this.px,
    required this.py,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });
}

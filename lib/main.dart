import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallpaper_manager.dart';
import 'dart:io';

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
  };

  final Map<String, String> _engineDescriptions = {
    'particles': 'Un fondo dinámico con partículas de neón que flotan y rebotan suavemente por toda tu pantalla. Optimizado para un consumo mínimo de batería.',
    'tetris': 'Revive el clásico con una IA que juega automáticamente. Las piezas buscan huecos inteligentemente para completar líneas y mantener el tablero limpio.',
    'matrix': 'La icónica lluvia de caracteres digitales. Transforma tu pantalla en una terminal de datos con estelas de neón verde sobre negro profundo.',
    'plexus': 'Una red neuronal de puntos conectados por líneas dinámicas. El sistema detecta la proximidad de los nodos para crear una malla tecnológica en tiempo real.',
    'liquid': 'Colores profundos que fluyen y se mezclan lentamente, creando una atmósfera minimalista y relajante que cambia de forma orgánica.',
  };

  final Map<String, IconData> _engineIcons = {
    'particles': Icons.blur_on,
    'tetris': Icons.grid_view_rounded,
    'matrix': Icons.code,
    'plexus': Icons.hub_outlined,
    'liquid': Icons.water_drop_outlined,
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
    );

    bool success = true;
    if (_selectedEngine == 'carousel') {
      if (_useDayNightMode) {
        await WallpaperManager.updatePlaylist(_playlistDay, type: 'day');
        await WallpaperManager.updatePlaylist(_playlistNight, type: 'night');
      } else {
        success = await WallpaperManager.updatePlaylist(_playlistGeneral, type: 'general');
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple.shade900, Colors.black],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                      itemBuilder: (_, __) => const Center(child: Text('.', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_engineIcons[engineId], size: 80, color: Colors.white),
                      const SizedBox(height: 24),
                      Text(
                        _engines[engineId]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _engineDescriptions[engineId] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7), height: 1.5),
          ),
        ],
      ),
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

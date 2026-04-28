import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
    }
  }

  Future<void> _applySettings() async {
    await WallpaperManager.updateSettings(
      changeOnVisible: false, // Forzado a false internamente
      useDayNightMode: _useDayNightMode,
      dayStartHour: _dayStartHour,
      nightStartHour: _nightStartHour,
      isDimEnabled: _isDimEnabled,
    );

    bool success = true;
    if (_useDayNightMode) {
      await WallpaperManager.updatePlaylist(_playlistDay, type: 'day');
      await WallpaperManager.updatePlaylist(_playlistNight, type: 'night');
    } else {
      success = await WallpaperManager.updatePlaylist(_playlistGeneral, type: 'general');
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
            _buildSettingsSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            _useDayNightMode ? _buildDayNightPlaylists() : _buildGeneralPlaylist(),
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
              onChanged: (val) => setState(() => _useDayNightMode = val),
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
                          if (time != null) setState(() => _dayStartHour = time.hour);
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
                          if (time != null) setState(() => _nightStartHour = time.hour);
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
              onChanged: (val) => setState(() => _isDimEnabled = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralPlaylist() {
    return _buildMediaList('Mi Galería', _playlistGeneral, () => _pickFiles('general'), (idx) => _playlistGeneral.removeAt(idx));
  }

  Widget _buildDayNightPlaylists() {
    return Column(
      children: [
        _buildMediaList('Galería Día ☀️', _playlistDay, () => _pickFiles('day'), (idx) => _playlistDay.removeAt(idx)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Divider()),
        _buildMediaList('Galería Noche 🌙', _playlistNight, () => _pickFiles('night'), (idx) => _playlistNight.removeAt(idx)),
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
              FilledButton.icon(
                onPressed: onAdd, 
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
                style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
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
                    onPressed: () => setState(() => onDelete(index))),
                ),
              );
            },
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'wallpaper_manager.dart';
import 'l10n.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

// Paletas de Diseño
const Color kLavenderHaze = Color(0xFF92A9E1);
const Color kSoftGraphite = Color(0xFF222222);
const Color kSoftGraphiteCard = Color(0xFF2C2C2E);
const Color kLavenderAccent = Color(0xFF728FCE);

const Color kVanillaCloud = Color(0xFFFDF8F2);
const Color kVanillaCloudCard = Color(0xFFF4EDE4);
const Color kStreamBlue = Color(0xFF1E56CD);
const Color kStreamBlueAccent = Color(0xFF16429E);

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const IxekenApp());
}

class IxekenApp extends StatelessWidget {
  const IxekenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          onGenerateTitle: (context) => L10n.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          localizationsDelegates: const [
            L10nDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: kStreamBlue,
            scaffoldBackgroundColor: kVanillaCloud,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kStreamBlue,
              brightness: Brightness.light,
              surface: kVanillaCloud,
              primary: kStreamBlue,
              secondary: kStreamBlueAccent,
            ),
            cardColor: kVanillaCloudCard,
            dividerColor: Colors.black12,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: kLavenderHaze,
            scaffoldBackgroundColor: kSoftGraphite,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kLavenderHaze,
              brightness: Brightness.dark,
              surface: kSoftGraphite,
              primary: kLavenderHaze,
              secondary: kLavenderAccent,
            ),
            cardColor: kSoftGraphiteCard,
            dividerColor: Colors.white12,
          ),
          home: const HomePage(),
        );
      },
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
  bool _syncWithSystemTheme = false;
  bool _isParallaxEnabled = false;
  int _currentTab = 0;
  String _searchQuery = '';
  double _dimIntensity = 0.43;
  String _carouselChangeMode = 'on_visibility';
  int _carouselChangeInterval = 60;
  String _appThemeMode = 'system';

  Map<String, String> getEngines(BuildContext context) {
    final l = L10n.of(context);
    return {
      'carousel': l.engineCarousel,
      'particles': '${l.engineParticles} 🌌',
      'tetris': '${l.engineTetris} 🕹️',
      'matrix': '${l.engineMatrix} 💾',
      'plexus': '${l.enginePlexus} 🕸️',
      'liquid': '${l.engineLiquid} 🌊',
      'starfield': '${l.engineStarfield} ✨',
      'vaporwave': '${l.engineVaporwave} 🌅',
      'conway': '${l.engineConway} 🦠',
      'fluids': '${l.engineFluids} 💨',
    };
  }

  Map<String, String> getEngineDescriptions(BuildContext context) {
    final l = L10n.of(context);
    return {
      'carousel': l.descCarousel,
      'particles': l.descParticles,
      'matrix': l.descMatrix,
      'plexus': l.descPlexus,
      'liquid': l.descLiquid,
      'tetris': l.descTetris,
      'starfield': l.descStarfield,
      'vaporwave': l.descVaporwave,
      'conway': l.descConway,
      'fluids': l.descFluids,
    };
  }

  final Map<String, IconData> _engineIcons = {
    'carousel': Icons.photo_library_outlined,
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
    const MethodChannel('com.ixeken.wallpaper/media').setMethodCallHandler((call) async {
      if (call.method == 'onPlaylistError') {
        final List<dynamic> failed = call.arguments;
        if (mounted && failed.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context).skippedFiles(failed.length)),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('app_theme_mode') ?? 'system';
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
      _syncWithSystemTheme = prefs.getBool('sync_with_system_theme') ?? false;
      _isParallaxEnabled = prefs.getBool('is_parallax') ?? false;
      _dimIntensity = prefs.getDouble('dim_intensity') ?? 0.43;
      _carouselChangeMode = prefs.getString('carousel_change_mode') ?? 'on_visibility';
      _carouselChangeInterval = prefs.getInt('carousel_change_interval') ?? 60;
      _appThemeMode = savedMode;
    });

    if (savedMode == 'light') {
      themeModeNotifier.value = ThemeMode.light;
    } else if (savedMode == 'dark') {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.system;
    }
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
    await prefs.setBool('sync_with_system_theme', _syncWithSystemTheme);
    await prefs.setBool('is_parallax', _isParallaxEnabled);
    await prefs.setDouble('dim_intensity', _dimIntensity);
    await prefs.setString('carousel_change_mode', _carouselChangeMode);
    await prefs.setInt('carousel_change_interval', _carouselChangeInterval);
    await prefs.setString('app_theme_mode', _appThemeMode);
  }

  Future<void> _pickFiles(String type) async {
    if (Platform.isAndroid) {
      await [Permission.photos].request();
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> result = await picker.pickMultiImage();

    if (result.isNotEmpty) {
      final List<String> newPaths = result.map((file) => file.path).toList();

      final List<String> currentList;
      if (type == 'general') {
        currentList = List.from(_playlistGeneral)..addAll(newPaths);
      } else if (type == 'day') {
        currentList = List.from(_playlistDay)..addAll(newPaths);
      } else {
        currentList = List.from(_playlistNight)..addAll(newPaths);
      }

      final updatedPaths = await WallpaperManager.updatePlaylist(currentList, type: type);
      if (updatedPaths != null) {
        setState(() {
          if (type == 'general') _playlistGeneral = updatedPaths;
          if (type == 'day') _playlistDay = updatedPaths;
          if (type == 'night') _playlistNight = updatedPaths;
        });
        await _savePersistedData();
      }
    }
  }

  List<String> _getCombinedPlaylist() {
    final all = <String>{..._playlistGeneral, ..._playlistDay, ..._playlistNight};
    return all.toList();
  }

  Future<void> _applySettings() async {
    await _savePersistedData();
    
    if (_selectedEngine == 'carousel') {
      if (_syncWithSystemTheme || _useDayNightMode) {
        await WallpaperManager.updatePlaylist(_playlistDay, type: 'day');
        await WallpaperManager.updatePlaylist(_playlistNight, type: 'night');
      } else {
        await WallpaperManager.updatePlaylist(_playlistGeneral, type: 'general');
      }
    }
    
    await WallpaperManager.updateSettings(
      changeOnVisible: false,
      useDayNightMode: _useDayNightMode,
      dayStartHour: _dayStartHour,
      nightStartHour: _nightStartHour,
      isDimEnabled: _isDimEnabled,
      dimIntensity: _dimIntensity,
      selectedEngine: _selectedEngine,
      isRandom: _isRandom,
      tetrisStyle: _tetrisStyle,
      syncWithSystemTheme: _syncWithSystemTheme,
      isParallaxEnabled: _isParallaxEnabled,
      carouselChangeMode: _carouselChangeMode,
      carouselChangeInterval: _carouselChangeInterval,
    );

    await WallpaperManager.openWallpaperPicker();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context).wallpaperApplied),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTab == 0
              ? l.titleAdjust
              : _currentTab == 1
                  ? l.titleLibrary
                  : l.titleOptions,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildCustomizerTab(),
          _buildGalleryTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavigationBar(),
    );
  }

  Widget _buildFloatingNavigationBar() {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 8),
          height: 72,
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.85) : Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.edit_note_outlined, l.tabAdjust),
                _buildNavItem(1, Icons.collections_outlined, l.tabLibrary),
                _buildNavItem(2, Icons.settings_outlined, l.tabOptions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : (isDark ? Colors.white60 : Colors.black45);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizerTab() {
    final l = L10n.of(context);
    final engines = getEngines(context);
    final engineDescs = getEngineDescriptions(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LiveWallpaperPreview(
                    engineId: _selectedEngine,
                    isDimEnabled: _isDimEnabled,
                    dimIntensity: _dimIntensity,
                    tetrisStyle: _tetrisStyle,
                    playlist: _getCombinedPlaylist(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.activeWallpaper(engines[_selectedEngine] ?? _selectedEngine),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              engineDescs[_selectedEngine] ?? l.descCarousel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black54,
              ),
            ),
            const Divider(height: 32),
            if (_selectedEngine == 'carousel') ...[
              _buildCarouselControls(),
            ] else if (_selectedEngine == 'tetris') ...[
              _buildTetrisControls(),
            ] else ...[
              _buildGenericControls(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _applySettings,
                label: Text(l.btnApplySystem),
                icon: const Icon(Icons.wallpaper),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bool success = await WallpaperManager.clearWallpaper();
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.wallpaperRestored),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.wallpaperRestoreError),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                label: Text(l.btnRestoreDefault),
                icon: const Icon(Icons.delete_forever_outlined),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselControls() {
    final l = L10n.of(context);
    return Column(
      children: [
        if (_syncWithSystemTheme) ...[
          _buildPlaylistEditor('day', l.carouselDayLight),
          const SizedBox(height: 12),
          _buildPlaylistEditor('night', l.carouselNightDark),
        ] else if (_useDayNightMode) ...[
          _buildPlaylistEditor('day', l.carouselDay),
          const SizedBox(height: 12),
          _buildPlaylistEditor('night', l.carouselNight),
        ] else ...[
          _buildPlaylistEditor('general', l.carouselGeneral),
        ],
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          title: Text(l.optDim),
          subtitle: Text(l.optDimSub),
          value: _isDimEnabled,
          onChanged: (val) {
            setState(() => _isDimEnabled = val);
            _savePersistedData();
          },
        ),
        if (_isDimEnabled) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.brightness_medium_outlined, 
                  size: 16, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black45,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _dimIntensity,
                    min: 0.1,
                    max: 0.9,
                    divisions: 16,
                    label: '${(_dimIntensity * 100).round()}%',
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _dimIntensity = val);
                    },
                    onChangeEnd: (val) async {
                      await _savePersistedData();
                    },
                  ),
                ),
                Text(
                  '${(_dimIntensity * 100).round()}%', 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          title: Text(l.optParallax),
          subtitle: Text(l.optParallaxSub),
          value: _isParallaxEnabled,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() => _isParallaxEnabled = val);
            _savePersistedData();
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          title: Text(l.optRandom),
          subtitle: Text(l.optRandomSub),
          value: _isRandom,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() => _isRandom = val);
            _savePersistedData();
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          title: Text(l.optSyncTheme),
          subtitle: Text(l.optSyncThemeSub),
          value: _syncWithSystemTheme,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() {
              _syncWithSystemTheme = val;
              if (val) _useDayNightMode = false;
            });
            _savePersistedData();
          },
        ),
        if (!_syncWithSystemTheme) ...[
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l.optDayNight),
            subtitle: Text(l.optDayNightSub),
            value: _useDayNightMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() => _useDayNightMode = val);
              _savePersistedData();
            },
          ),
          if (_useDayNightMode) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionChip(
                      avatar: const Icon(Icons.wb_sunny_outlined, size: 16),
                      label: Text('${l.dayLabel}: $_dayStartHour:00'),
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
                      label: Text('${l.nightLabel}: $_nightStartHour:00'),
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
          ],
        ],
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          title: Text(l.optChangeCondition),
          subtitle: Text(_carouselChangeMode == 'on_visibility' 
              ? l.changeOnLock 
              : l.changeOnTime),
          trailing: DropdownButton<String>(
            value: _carouselChangeMode,
            onChanged: (val) async {
              if (val != null) {
                setState(() => _carouselChangeMode = val);
                await _savePersistedData();
                await WallpaperManager.updateSettings(
                  changeOnVisible: false,
                  useDayNightMode: _useDayNightMode,
                  dayStartHour: _dayStartHour,
                  nightStartHour: _nightStartHour,
                  isDimEnabled: _isDimEnabled,
                  dimIntensity: _dimIntensity,
                  selectedEngine: _selectedEngine,
                  isRandom: _isRandom,
                  tetrisStyle: _tetrisStyle,
                  syncWithSystemTheme: _syncWithSystemTheme,
                  isParallaxEnabled: _isParallaxEnabled,
                  carouselChangeMode: _carouselChangeMode,
                  carouselChangeInterval: _carouselChangeInterval,
                );
              }
            },
            items: [
              DropdownMenuItem(
                value: 'on_visibility',
                child: Text(l.changeOnLock),
              ),
              DropdownMenuItem(
                value: 'timer',
                child: Text(l.changeOnTime),
              ),
            ],
          ),
        ),
        if (_carouselChangeMode == 'timer') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.optChangeInterval, style: const TextStyle(fontSize: 14)),
                DropdownButton<int>(
                  value: _carouselChangeInterval,
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() => _carouselChangeInterval = val);
                      await _savePersistedData();
                      await WallpaperManager.updateSettings(
                        changeOnVisible: false,
                        useDayNightMode: _useDayNightMode,
                        dayStartHour: _dayStartHour,
                        nightStartHour: _nightStartHour,
                        isDimEnabled: _isDimEnabled,
                        dimIntensity: _dimIntensity,
                        selectedEngine: _selectedEngine,
                        isRandom: _isRandom,
                        tetrisStyle: _tetrisStyle,
                        syncWithSystemTheme: _syncWithSystemTheme,
                        isParallaxEnabled: _isParallaxEnabled,
                        carouselChangeMode: _carouselChangeMode,
                        carouselChangeInterval: _carouselChangeInterval,
                      );
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 15, child: Text(l.formatSeconds(15))),
                    DropdownMenuItem(value: 30, child: Text(l.formatSeconds(30))),
                    DropdownMenuItem(value: 60, child: Text(l.formatMinute)),
                    DropdownMenuItem(value: 300, child: Text(l.formatMinutes(5))),
                    DropdownMenuItem(value: 900, child: Text(l.formatMinutes(15))),
                    DropdownMenuItem(value: 1800, child: Text(l.formatMinutes(30))),
                    DropdownMenuItem(value: 3600, child: Text(l.formatHour)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTetrisControls() {
    final l = L10n.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: Text(l.optDim),
          subtitle: Text(l.optDimSub),
          value: _isDimEnabled,
          onChanged: (val) {
            setState(() => _isDimEnabled = val);
            _savePersistedData();
          },
        ),
        if (_isDimEnabled) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.brightness_medium_outlined, size: 16, color: Colors.white60),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _dimIntensity,
                    min: 0.1,
                    max: 0.9,
                    divisions: 16,
                    label: '${(_dimIntensity * 100).round()}%',
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _dimIntensity = val);
                    },
                    onChangeEnd: (val) async {
                      await _savePersistedData();
                    },
                  ),
                ),
                Text(
                  '${(_dimIntensity * 100).round()}%', 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Divider(indent: 16, endIndent: 16),
        const SizedBox(height: 8),
        Text(
          l.tetrisStyle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary),
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
    );
  }

  Widget _buildGenericControls() {
    final l = L10n.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: Text(l.optDim),
          subtitle: Text(l.optDimSub),
          value: _isDimEnabled,
          onChanged: (val) {
            setState(() => _isDimEnabled = val);
            _savePersistedData();
          },
        ),
        if (_isDimEnabled) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.brightness_medium_outlined, size: 16, color: Colors.white60),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _dimIntensity,
                    min: 0.1,
                    max: 0.9,
                    divisions: 16,
                    label: '${(_dimIntensity * 100).round()}%',
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _dimIntensity = val);
                    },
                    onChangeEnd: (val) async {
                      await _savePersistedData();
                    },
                  ),
                ),
                Text(
                  '${(_dimIntensity * 100).round()}%', 
                  style: TextStyle(
                    fontSize: 12, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_selectedEngine == 'particles') ...[
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(l.optParallax),
            subtitle: Text(l.optParallaxSub),
            value: _isParallaxEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() => _isParallaxEnabled = val);
              _savePersistedData();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildStyleChip(String label, String value) {
    final isSelected = _tetrisStyle == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : (isDark ? Colors.white70 : Colors.black87),
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

  Widget _buildGalleryTab() {
    final l = L10n.of(context);
    final enginesMap = getEngines(context);
    final filteredEngines = enginesMap.entries.where((e) {
      final name = e.value.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white.withOpacity(0.5) : Colors.black54;
    final iconColor = isDark ? Colors.white.withOpacity(0.5) : Colors.black54;
    final clearIconColor = isDark ? Colors.white60 : Colors.black54;
    final fillColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: l.searchHint,
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.search, color: iconColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: clearIconColor),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filteredEngines.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l.headerWallpapers, 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600
                            ? (MediaQuery.of(context).size.width / 220).floor()
                            : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: filteredEngines.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEngines[index];
                        return _buildEngineCard(entry.key, entry.value);
                      },
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngineCard(String engineId, String title) {
    final l = L10n.of(context);
    final engineDescs = getEngineDescriptions(context);
    final description = engineDescs[engineId] ?? '';
    final isActive = _selectedEngine == engineId;
    return Card(
      color: Colors.white.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : (Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.black.withOpacity(0.05)), 
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: LiveWallpaperPreview(
              engineId: engineId,
              isDimEnabled: false,
              dimIntensity: 0.43,
              tetrisStyle: _tetrisStyle,
              playlist: _getCombinedPlaylist(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 2),
                Text(
                  description.substring(0, math.min(35, description.length)),
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            _selectedEngine = engineId;
                          });
                          await _savePersistedData();
                          await WallpaperManager.updateSettings(
                            changeOnVisible: false,
                            useDayNightMode: _useDayNightMode,
                            dayStartHour: _dayStartHour,
                            nightStartHour: _nightStartHour,
                            isDimEnabled: _isDimEnabled,
                            dimIntensity: _dimIntensity,
                            selectedEngine: _selectedEngine,
                            isRandom: _isRandom,
                            tetrisStyle: _tetrisStyle,
                            syncWithSystemTheme: _syncWithSystemTheme,
                            isParallaxEnabled: _isParallaxEnabled,
                            carouselChangeMode: _carouselChangeMode,
                            carouselChangeInterval: _carouselChangeInterval,
                          );
                          await WallpaperManager.openWallpaperPicker();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isActive 
                                ? Theme.of(context).colorScheme.primary 
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                          ),
                          backgroundColor: isActive 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.black45 : Colors.white.withOpacity(0.7)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isActive ? l.active : l.activate, 
                          style: TextStyle(
                            fontSize: 11, 
                            color: isActive 
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).colorScheme.primary) 
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFileFromPlaylist(String type, String path) async {
    final List<String> currentList;
    if (type == 'general') {
      currentList = List.from(_playlistGeneral)..remove(path);
    } else if (type == 'day') {
      currentList = List.from(_playlistDay)..remove(path);
    } else {
      currentList = List.from(_playlistNight)..remove(path);
    }

    final updatedPaths = await WallpaperManager.updatePlaylist(currentList, type: type);
    setState(() {
      if (type == 'general') _playlistGeneral = updatedPaths ?? currentList;
      if (type == 'day') _playlistDay = updatedPaths ?? currentList;
      if (type == 'night') _playlistNight = updatedPaths ?? currentList;
    });
    await _savePersistedData();

    if (_selectedEngine == 'carousel') {
      await WallpaperManager.updateSettings(
        changeOnVisible: false,
        useDayNightMode: _useDayNightMode,
        dayStartHour: _dayStartHour,
        nightStartHour: _nightStartHour,
        isDimEnabled: _isDimEnabled,
        dimIntensity: _dimIntensity,
        selectedEngine: _selectedEngine,
        isRandom: _isRandom,
        tetrisStyle: _tetrisStyle,
        syncWithSystemTheme: _syncWithSystemTheme,
        isParallaxEnabled: _isParallaxEnabled,
        carouselChangeMode: _carouselChangeMode,
        carouselChangeInterval: _carouselChangeInterval,
      );
    }
  }

  Widget _buildPlaylistEditor(String type, String title) {
    final List<String> playlist;
    if (type == 'general') {
      playlist = _playlistGeneral;
    } else if (type == 'day') {
      playlist = _playlistDay;
    } else {
      playlist = _playlistNight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13, 
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 145,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: playlist.length + 1,
            itemBuilder: (context, index) {
              if (index == playlist.length) {
                return Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.02) 
                        : Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white.withOpacity(0.08) 
                            : Colors.black.withOpacity(0.08),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _pickFiles(type),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 24, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 4),
                          Text(
                            L10n.of(context).add, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 11, 
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final path = playlist[index];
              final isVideo = path.endsWith('.mp4') || path.endsWith('.mkv');
              final filename = path.split('/').last;

              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                child: Card(
                  color: Colors.white.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black26,
                              child: Center(
                                child: Icon(
                                  isVideo ? Icons.videocam : Icons.image_not_supported_outlined,
                                  color: Colors.white30,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isVideo)
                        const Positioned(
                          top: 4,
                          left: 4,
                          child: Icon(Icons.videocam, size: 14, color: Colors.white70),
                        ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeFileFromPlaylist(type, path),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        right: 4,
                        bottom: 4,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          child: Text(
                            filename,
                            style: const TextStyle(fontSize: 8, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    final l = L10n.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.preferences, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.appTheme),
                    subtitle: Text(
                      _appThemeMode == 'system'
                          ? l.themeSyncSystem
                          : _appThemeMode == 'light'
                              ? l.themeLight
                              : l.themeDark,
                    ),
                    trailing: DropdownButton<String>(
                      value: _appThemeMode,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Theme.of(context).cardColor,
                      onChanged: (val) async {
                        if (val != null) {
                          setState(() {
                            _appThemeMode = val;
                          });
                          if (val == 'light') {
                            themeModeNotifier.value = ThemeMode.light;
                          } else if (val == 'dark') {
                            themeModeNotifier.value = ThemeMode.dark;
                          } else {
                            themeModeNotifier.value = ThemeMode.system;
                          }
                          await _savePersistedData();
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'system',
                          child: Text(l.themeOptSystem),
                        ),
                        DropdownMenuItem(
                          value: 'light',
                          child: Text(l.themeOptLight),
                        ),
                        DropdownMenuItem(
                          value: 'dark',
                          child: Text(l.themeOptDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l.sysPermissions, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(l.managePermissions),
                subtitle: Text(l.configPermissionsSub),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black45,
                ),
                onTap: () => _showPermissionsBottomSheet(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(l.aboutApp, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.sourceCode),
                    subtitle: Text(l.sourceCodeSub),
                    onTap: () => WallpaperManager.launchUrl('https://github.com/Ixeken-Studios/Ixeken-Live-Wallpaper'),
                  ),
                  Divider(height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.developedBy),
                    subtitle: const Text('Ixeken Studios'),
                  ),
                  Divider(height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.privacyPolicy),
                    subtitle: Text(l.readPrivacy),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l.privacyPolicy),
                          content: SingleChildScrollView(
                            child: Text(
                              l.privacyContent,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l.understood),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  void _showPermissionsBottomSheet(BuildContext context) {
    bool photosGranted = false;
    bool batteryIgnored = false;
    bool isSensorsExpanded = false;
    bool isStabilityExpanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final l = L10n.of(context);
            Future<void> checkPermissions() async {
              final photos = await Permission.photos.isGranted;
              final battery = await Permission.ignoreBatteryOptimizations.isGranted;
              setSheetState(() {
                photosGranted = photos;
                batteryIgnored = battery;
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final photos = await Permission.photos.isGranted;
              final battery = await Permission.ignoreBatteryOptimizations.isGranted;
              if (photos != photosGranted || battery != batteryIgnored) {
                setSheetState(() {
                  photosGranted = photos;
                  batteryIgnored = battery;
                });
              }
            });

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardColor = Theme.of(context).cardColor;
            final primaryColor = Theme.of(context).colorScheme.primary;

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 36,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.permManageTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        l.permManageDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.storage, color: primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.permGallery,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l.permGallerySub,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              photosGranted
                                  ? Icon(Icons.check_circle, color: primaryColor, size: 28)
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: isDark ? Colors.black : Colors.white,
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        elevation: 0,
                                      ),
                                      onPressed: () async {
                                        final status = await Permission.photos.request();
                                        if (status.isPermanentlyDenied) {
                                          openAppSettings();
                                        }
                                        await checkPermissions();
                                      },
                                      child: Text(
                                        l.allow,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.palette_outlined, color: primaryColor),
                              ),
                              title: Text(
                                l.permOptionalService,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                l.permOptionalSub,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              trailing: Icon(
                                isSensorsExpanded ? Icons.expand_less : Icons.expand_more,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onTap: () {
                                setSheetState(() {
                                  isSensorsExpanded = !isSensorsExpanded;
                                });
                              },
                            ),
                            if (isSensorsExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.sensors, color: primaryColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l.permParallax,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              l.permParallaxSub,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white54 : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.check_circle, color: primaryColor, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.bolt, color: primaryColor),
                              ),
                              title: Text(
                                l.permStability,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                l.permStabilitySub,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              trailing: Icon(
                                isStabilityExpanded ? Icons.expand_less : Icons.expand_more,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onTap: () {
                                setSheetState(() {
                                  isStabilityExpanded = !isStabilityExpanded;
                                });
                              },
                            ),
                            if (isStabilityExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.battery_alert, color: primaryColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l.permBattery,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              l.permBatterySub,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white54 : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      batteryIgnored
                                          ? Icon(Icons.check_circle, color: primaryColor, size: 24)
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: isDark ? Colors.black : Colors.white,
                                                shape: const StadiumBorder(),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                elevation: 0,
                                              ),
                                              onPressed: () async {
                                                final status = await Permission.ignoreBatteryOptimizations.request();
                                                if (status.isPermanentlyDenied) {
                                                  openAppSettings();
                                                }
                                                await checkPermissions();
                                              },
                                              child: Text(
                                                l.ignore,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextButton.icon(
                        onPressed: () => openAppSettings(),
                        icon: const Icon(Icons.settings_applications, color: Colors.redAccent),
                        label: Text(
                          l.revokeSettings,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }
}

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
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                  Container(color: Colors.black.withOpacity(widget.dimIntensity)),
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
    if (w == 0 || h == 0) return;
    
    final horizon = h * 0.48;
    
    // Sky
    final skyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, horizon),
        [const Color(0xFF1D0030), const Color(0xFFA80077), const Color(0xFFFF5E62)],
        [0.0, 0.5, 1.0],
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

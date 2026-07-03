import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'wallpaper_manager.dart';
import 'l10n.dart';
import 'presentation/widgets/customizer_tab.dart';
import 'presentation/widgets/gallery_tab.dart';
import 'presentation/widgets/settings_tab.dart';
import 'presentation/widgets/permissions_sheet.dart';
import 'presentation/widgets/appearance_screen.dart';
import 'presentation/widgets/wallpaper_detail_screen.dart';
import 'dart:io';

// Paletas de Diseño
final ValueNotifier<String> themeStyleNotifier = ValueNotifier('ixeken_dark');
final ValueNotifier<String> fontFamilyNotifier = ValueNotifier('system');
final ValueNotifier<int> fontSizeIndexNotifier = ValueNotifier(4);

ThemeData buildThemeData(String themeStyle, String fontFamily, int fontSizeIndex) {
  Color primary;
  Color secondary;
  Color background;
  
  switch (themeStyle) {
    case 'ixeken_light':
      primary = const Color(0xFF003171);
      secondary = const Color(0xFFF3F4F4);
      background = const Color(0xFFD6E8FF);
      break;
    case 'cherry':
      primary = const Color(0xFF7B0D1E);
      secondary = const Color(0xFFF8E5EE);
      background = const Color(0xFFE2B4C3);
      break;
    case 'earthy':
      primary = const Color(0xFF6A994E);
      secondary = const Color(0xFFFFFCF2);
      background = const Color(0xFFF0F4E8);
      break;
    case 'amoled':
      primary = const Color(0xFFF3F4F4);
      secondary = const Color(0xFF1C1C1E);
      background = const Color(0xFF000000);
      break;
    case 'elegance':
      primary = const Color(0xFFE5E5E5);
      secondary = const Color(0xFF3D348B);
      background = const Color(0xFF000000);
      break;
    case 'ixeken_dark':
    default:
      primary = const Color(0xFFF3F4F4);
      secondary = const Color(0xFF003171);
      background = const Color(0xFF001229);
      break;
  }

  final isLightTheme = themeStyle == 'ixeken_light' || themeStyle == 'cherry' || themeStyle == 'earthy';
  final brightness = isLightTheme ? Brightness.light : Brightness.dark;

  TextTheme textTheme;
  switch (fontFamily) {
    case 'inter':
      textTheme = GoogleFonts.interTextTheme();
      break;
    case 'rubik':
      textTheme = GoogleFonts.rubikTextTheme();
      break;
    case 'space_grotesk':
      textTheme = GoogleFonts.spaceGroteskTextTheme();
      break;
    case 'ubuntu':
      textTheme = GoogleFonts.ubuntuTextTheme();
      break;
    case 'gs_sans_flex':
    case 'gs_flex':
      textTheme = GoogleFonts.outfitTextTheme();
      break;
    case 'system':
    default:
      textTheme = GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(),
        displayMedium: GoogleFonts.outfit(),
        displaySmall: GoogleFonts.outfit(),
        headlineLarge: GoogleFonts.outfit(),
        headlineMedium: GoogleFonts.outfit(),
        headlineSmall: GoogleFonts.outfit(),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      );
      break;
  }

  final double fontSizeFactor = 0.8 + (fontSizeIndex * 0.05);
  textTheme = textTheme.apply(
    fontSizeFactor: fontSizeFactor,
    bodyColor: isLightTheme ? Colors.black87 : Colors.white,
    displayColor: isLightTheme ? Colors.black87 : Colors.white,
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  ).copyWith(
    surface: background,
    primary: primary,
    secondary: secondary,
    onSurface: isLightTheme ? Colors.black87 : Colors.white,
  );

  return ThemeData(
    brightness: brightness,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    colorScheme: colorScheme,
    cardColor: secondary,
    dividerColor: isLightTheme ? Colors.black12 : Colors.white12,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primary.withValues(alpha: 0.5);
        }
        return null;
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return null;
      }),
    ),
  );
}

void main() {
  runApp(const IxekenApp());
}

class IxekenApp extends StatelessWidget {
  const IxekenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeStyleNotifier,
      builder: (context, currentStyle, child) {
        return ValueListenableBuilder<String>(
          valueListenable: fontFamilyNotifier,
          builder: (context, currentFont, child) {
            return ValueListenableBuilder<int>(
              valueListenable: fontSizeIndexNotifier,
              builder: (context, currentIndex, child) {
                final theme = buildThemeData(currentStyle, currentFont, currentIndex);
                return MaterialApp(
                  onGenerateTitle: (context) => L10n.of(context).appTitle,
                  debugShowCheckedModeBanner: false,
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
                  theme: theme,
                  home: const HomePage(),
                );
              },
            );
          },
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
  bool _isHalfFpsEnabled = false;

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
    final savedMode = prefs.getString('app_theme_mode') ?? 'ixeken_dark';
    final savedFontSizeIndex = prefs.getInt('app_font_size_index') ?? 4;
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
      _isHalfFpsEnabled = prefs.getBool('is_half_fps') ?? false;
      fontFamilyNotifier.value = prefs.getString('app_font_family') ?? 'system';
      themeStyleNotifier.value = savedMode;
      fontSizeIndexNotifier.value = savedFontSizeIndex;
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
    await prefs.setBool('sync_with_system_theme', _syncWithSystemTheme);
    await prefs.setBool('is_parallax', _isParallaxEnabled);
    await prefs.setDouble('dim_intensity', _dimIntensity);
    await prefs.setString('carousel_change_mode', _carouselChangeMode);
    await prefs.setInt('carousel_change_interval', _carouselChangeInterval);
    await prefs.setString('app_theme_mode', _appThemeMode);
    await prefs.setBool('is_half_fps', _isHalfFpsEnabled);
    await prefs.setString('app_font_family', fontFamilyNotifier.value);
    await prefs.setInt('app_font_size_index', fontSizeIndexNotifier.value);
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
      isHalfFpsEnabled: _isHalfFpsEnabled,
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
              ? l.titleLibrary
              : _currentTab == 1
                  ? l.titleAdjust
                  : l.titleOptions,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Stack-based floating nav bar: correct pattern for floating bottom bars.
      // Using bottomNavigationBar with SafeArea>Align>Container causes the body
      // to collapse because Scaffold uses the slot's intrinsic height (which
      // Align reports as 0) to compute available body space.
      body: Stack(
        children: [
           IndexedStack(
            index: _currentTab,
            children: [
              GalleryTab(
                searchQuery: _searchQuery,
                selectedEngine: _selectedEngine,
                tetrisStyle: _tetrisStyle,
                combinedPlaylist: _getCombinedPlaylist(),
                engines: getEngines(context),
                engineDescriptions: getEngineDescriptions(context),
                onSearchQueryChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onSelectEngine: (engineId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallpaperDetailScreen(
                        engineId: engineId,
                        isDimEnabled: _isDimEnabled,
                        dimIntensity: _dimIntensity,
                        tetrisStyle: _tetrisStyle,
                        playlist: _getCombinedPlaylist(),
                        engines: getEngines(context),
                        engineDescriptions: getEngineDescriptions(context),
                        syncWithSystemTheme: _syncWithSystemTheme,
                        useDayNightMode: _useDayNightMode,
                        dayStartHour: _dayStartHour,
                        nightStartHour: _nightStartHour,
                        isParallaxEnabled: _isParallaxEnabled,
                        isRandom: _isRandom,
                        carouselChangeMode: _carouselChangeMode,
                        carouselChangeInterval: _carouselChangeInterval,
                        isHalfFpsEnabled: _isHalfFpsEnabled,
                        playlistGeneral: _playlistGeneral,
                        playlistDay: _playlistDay,
                        playlistNight: _playlistNight,
                        onDimEnabledChanged: (val) {
                          setState(() => _isDimEnabled = val);
                          _savePersistedData();
                        },
                        onDimIntensityChanged: (val) {
                          setState(() => _dimIntensity = val);
                        },
                        onDimIntensityChangeEnd: (val) async {
                          await _savePersistedData();
                        },
                        onParallaxEnabledChanged: (val) {
                          setState(() => _isParallaxEnabled = val);
                          _savePersistedData();
                        },
                        onRandomChanged: (val) {
                          setState(() => _isRandom = val);
                          _savePersistedData();
                        },
                        onSyncThemeChanged: (val) {
                          setState(() {
                            _syncWithSystemTheme = val;
                            if (val) _useDayNightMode = false;
                          });
                          _savePersistedData();
                        },
                        onDayNightModeChanged: (val) {
                          setState(() => _useDayNightMode = val);
                          _savePersistedData();
                        },
                        onDayStartHourChanged: (val) {
                          setState(() => _dayStartHour = val);
                          _savePersistedData();
                        },
                        onNightStartHourChanged: (val) {
                          setState(() => _nightStartHour = val);
                          _savePersistedData();
                        },
                        onCarouselChangeModeChanged: (val) async {
                          setState(() => _carouselChangeMode = val);
                          await _savePersistedData();
                        },
                        onCarouselChangeIntervalChanged: (val) async {
                          setState(() => _carouselChangeInterval = val);
                          await _savePersistedData();
                        },
                        onHalfFpsEnabledChanged: (val) {
                          setState(() => _isHalfFpsEnabled = val);
                          _savePersistedData();
                        },
                        onPickFiles: (type) => _pickFiles(type),
                        onRemoveFile: (type, path) => _removeFileFromPlaylist(type, path),
                        onApplyEngine: (id) async {
                          setState(() {
                            _selectedEngine = id;
                          });
                          await _savePersistedData();
                          await _applySettings();
                        },
                      ),
                    ),
                  );
                },
              ),
              CustomizerTab(
                selectedEngine: _selectedEngine,
                isDimEnabled: _isDimEnabled,
                dimIntensity: _dimIntensity,
                tetrisStyle: _tetrisStyle,
                playlist: _getCombinedPlaylist(),
                engines: getEngines(context),
                engineDescriptions: getEngineDescriptions(context),
                syncWithSystemTheme: _syncWithSystemTheme,
                useDayNightMode: _useDayNightMode,
                dayStartHour: _dayStartHour,
                nightStartHour: _nightStartHour,
                isParallaxEnabled: _isParallaxEnabled,
                isRandom: _isRandom,
                carouselChangeMode: _carouselChangeMode,
                carouselChangeInterval: _carouselChangeInterval,
                isHalfFpsEnabled: _isHalfFpsEnabled,
                playlistGeneral: _playlistGeneral,
                playlistDay: _playlistDay,
                playlistNight: _playlistNight,
                onDimEnabledChanged: (val) {
                  setState(() => _isDimEnabled = val);
                  _savePersistedData();
                },
                onDimIntensityChanged: (val) {
                  setState(() => _dimIntensity = val);
                },
                onDimIntensityChangeEnd: (val) async {
                  await _savePersistedData();
                },
                onParallaxEnabledChanged: (val) {
                  setState(() => _isParallaxEnabled = val);
                  _savePersistedData();
                },
                onRandomChanged: (val) {
                  setState(() => _isRandom = val);
                  _savePersistedData();
                },
                onSyncThemeChanged: (val) {
                  setState(() {
                    _syncWithSystemTheme = val;
                    if (val) _useDayNightMode = false;
                  });
                  _savePersistedData();
                },
                onDayNightModeChanged: (val) {
                  setState(() => _useDayNightMode = val);
                  _savePersistedData();
                },
                onDayStartHourChanged: (val) {
                  setState(() => _dayStartHour = val);
                  _savePersistedData();
                },
                onNightStartHourChanged: (val) {
                  setState(() => _nightStartHour = val);
                  _savePersistedData();
                },
                onCarouselChangeModeChanged: (val) async {
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
                    isHalfFpsEnabled: _isHalfFpsEnabled,
                  );
                },
                onCarouselChangeIntervalChanged: (val) async {
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
                    isHalfFpsEnabled: _isHalfFpsEnabled,
                  );
                },
                onHalfFpsEnabledChanged: (val) {
                  setState(() => _isHalfFpsEnabled = val);
                  _savePersistedData();
                },
                onPickFiles: (type) => _pickFiles(type),
                onRemoveFile: (type, path) => _removeFileFromPlaylist(type, path),
                onApplySettings: _applySettings,
                onRestoreDefault: () async {
                  final bool success = await WallpaperManager.clearWallpaper();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(L10n.of(context).wallpaperRestored),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(L10n.of(context).wallpaperRestoreError),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                onTetrisStyleChanged: (val) {
                  setState(() => _tetrisStyle = val);
                  _savePersistedData();
                },
              ),
              SettingsTab(
                onShowAppearance: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppearanceScreen(
                        appThemeMode: _appThemeMode,
                        onAppThemeModeChanged: (val) async {
                          setState(() {
                            _appThemeMode = val;
                          });
                          themeStyleNotifier.value = val;
                          await _savePersistedData();
                        },
                        currentFont: fontFamilyNotifier.value,
                        onFontChanged: (val) async {
                          fontFamilyNotifier.value = val;
                          await _savePersistedData();
                        },
                        fontSizeIndex: fontSizeIndexNotifier.value,
                        onFontSizeIndexChanged: (val) async {
                          fontSizeIndexNotifier.value = val;
                          await _savePersistedData();
                        },
                      ),
                    ),
                  );
                },
                onShowPermissions: () => _showPermissionsBottomSheet(context),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigationBar() {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).cardColor; // Secondary

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 8),
          height: 72,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment((_currentTab - 1) * 1.0, 0.0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavItem(0, Icons.bar_chart_outlined, l.tabLibrary)),
                  Expanded(child: _buildNavItem(1, Icons.home_outlined, l.tabAdjust)),
                  Expanded(child: _buildNavItem(2, Icons.tune_outlined, l.tabOptions)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).cardColor;
    final color = isSelected 
        ? secondaryColor 
        : primaryColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
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
        isHalfFpsEnabled: _isHalfFpsEnabled,
      );
    }
  }


  void _showPermissionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return const PermissionsSheet();
      },
    );
  }
}

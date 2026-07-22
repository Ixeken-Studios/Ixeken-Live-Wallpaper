import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallpaper_manager.dart';
import 'l10n.dart';
import 'presentation/widgets/customizer_tab.dart';
import 'presentation/widgets/gallery_tab.dart';
import 'presentation/widgets/settings_tab.dart';
import 'presentation/widgets/permissions_sheet.dart';
import 'presentation/widgets/appearance_screen.dart';
import 'presentation/widgets/wallpaper_detail_screen.dart';
import 'services/github_update_service.dart';
import 'dart:io';

// Paletas de Diseño
final ValueNotifier<String> themeStyleNotifier = ValueNotifier('ixeken_light');
final ValueNotifier<String> fontFamilyNotifier = ValueNotifier('gs_flex');
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

  final baseTheme = ThemeData(brightness: brightness).textTheme;
  TextTheme textTheme;
  switch (fontFamily) {
    case 'inter':
      textTheme = GoogleFonts.interTextTheme(baseTheme);
      break;
    case 'rubik':
      textTheme = GoogleFonts.rubikTextTheme(baseTheme);
      break;
    case 'geomini':
      textTheme = baseTheme.apply(fontFamily: 'Geomini');
      break;
    case 'ubuntu':
      textTheme = GoogleFonts.ubuntuTextTheme(baseTheme);
      break;
    case 'gs_sans_flex':
    case 'gs_flex':
      textTheme = GoogleFonts.outfitTextTheme(baseTheme);
      break;
    case 'system':
    default:
      final nunitoTheme = GoogleFonts.nunitoTextTheme(baseTheme);
      textTheme = nunitoTheme.copyWith(
        displayLarge: GoogleFonts.outfit(textStyle: nunitoTheme.displayLarge),
        displayMedium: GoogleFonts.outfit(textStyle: nunitoTheme.displayMedium),
        displaySmall: GoogleFonts.outfit(textStyle: nunitoTheme.displaySmall),
        headlineLarge: GoogleFonts.outfit(textStyle: nunitoTheme.headlineLarge),
        headlineMedium: GoogleFonts.outfit(textStyle: nunitoTheme.headlineMedium),
        headlineSmall: GoogleFonts.outfit(textStyle: nunitoTheme.headlineSmall),
        titleLarge: GoogleFonts.outfit(textStyle: nunitoTheme.titleLarge, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(textStyle: nunitoTheme.titleMedium, fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.outfit(textStyle: nunitoTheme.titleSmall, fontWeight: FontWeight.bold),
      );
      break;
  }

  textTheme = textTheme.apply(
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
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: background,
      surfaceTintColor: background,
      elevation: 8,
      modalElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        side: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
    ),
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
                  builder: (context, child) {
                    final mediaQueryData = MediaQuery.of(context);
                    final double scale = 0.8 + (currentIndex * 0.05);
                    return MediaQuery(
                      data: mediaQueryData.copyWith(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: child!,
                    );
                  },
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
  String _selectedEngineLock = 'same';
  bool _syncWithSystemTheme = false;
  bool _isParallaxEnabled = false;
  int _currentTab = 0;
  String _searchQuery = '';
  double _dimIntensity = 0.35;
  String _carouselChangeMode = 'on_visibility';
  int _carouselChangeInterval = 60;
  String _appThemeMode = 'ixeken_light';
  bool _isHalfFpsEnabled = false;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  // Pattern Settings
  int _patternLayoutSize = 2;
  List<String> _patternSlotIcons = ['circle', 'star', 'heart', 'cross'];
  double _patternSpeed = 2.0;
  String _patternDensity = 'medium';
  bool _patternRotate = true;

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
      'pattern': '${l.enginePattern} 🖼️',
      'floral': '${l.engineFloral} 🌸',
      'bokeh': '${l.engineBokeh} ✨',
      'quantum': '${l.engineQuantum} ⚛️',
      'aura': '${l.engineAura} 🌈',
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
      'pattern': l.descPattern,
      'floral': l.descFloral,
      'bokeh': l.descBokeh,
      'quantum': l.descQuantum,
      'aura': l.descAura,
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
    final savedMode = prefs.getString('app_theme_mode') ?? 'ixeken_light';
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
      _selectedEngineLock = prefs.getString('selected_engine_lock') ?? 'same';
      _syncWithSystemTheme = prefs.getBool('sync_with_system_theme') ?? false;
      _isParallaxEnabled = prefs.getBool('is_parallax') ?? false;
      _dimIntensity = prefs.getDouble('dim_intensity') ?? 0.35;
      _carouselChangeMode = prefs.getString('carousel_change_mode') ?? 'on_visibility';
      _carouselChangeInterval = prefs.getInt('carousel_change_interval') ?? 60;
      _appThemeMode = savedMode;
      _isHalfFpsEnabled = prefs.getBool('is_half_fps') ?? false;
      fontFamilyNotifier.value = prefs.getString('app_font_family') ?? 'gs_flex';
      themeStyleNotifier.value = savedMode;
      fontSizeIndexNotifier.value = savedFontSizeIndex;

      _patternLayoutSize = prefs.getInt('pattern_layout_size') ?? 2;
      _patternSlotIcons = prefs.getStringList('pattern_slot_icons') ?? ['circle', 'star', 'heart', 'cross'];
      _patternSpeed = prefs.getDouble('pattern_speed') ?? 2.0;
      _patternDensity = prefs.getString('pattern_density') ?? 'medium';
      _patternRotate = prefs.getBool('pattern_rotate') ?? true;
    });

    final checkUpdateOnStart = prefs.getBool('check_update_on_start') ?? false;
    if (checkUpdateOnStart) {
      _checkUpdateOnStartup();
    }
  }

  Future<void> _checkUpdateOnStartup() async {
    final result = await GitHubUpdateService.checkForUpdates();
    if (!mounted) return;
    if (result is NewVersionResult) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New update available: ${result.version}'),
          action: SnackBarAction(
            label: 'Download',
            onPressed: () => WallpaperManager.launchUrl(result.downloadUrl),
          ),
          duration: const Duration(seconds: 10),
        ),
      );
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
    await prefs.setString('selected_engine_lock', _selectedEngineLock);
    await prefs.setBool('sync_with_system_theme', _syncWithSystemTheme);
    await prefs.setBool('is_parallax', _isParallaxEnabled);
    await prefs.setDouble('dim_intensity', _dimIntensity);
    await prefs.setString('carousel_change_mode', _carouselChangeMode);
    await prefs.setInt('carousel_change_interval', _carouselChangeInterval);
    await prefs.setString('app_theme_mode', _appThemeMode);
    await prefs.setBool('is_half_fps', _isHalfFpsEnabled);
    await prefs.setString('app_font_family', fontFamilyNotifier.value);
    await prefs.setInt('app_font_size_index', fontSizeIndexNotifier.value);

    await prefs.setInt('pattern_layout_size', _patternLayoutSize);
    await prefs.setStringList('pattern_slot_icons', _patternSlotIcons);
    await prefs.setDouble('pattern_speed', _patternSpeed);
    await prefs.setString('pattern_density', _patternDensity);
    await prefs.setBool('pattern_rotate', _patternRotate);
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
      patternLayoutSize: _patternLayoutSize,
      patternSlotIcons: _patternSlotIcons,
      patternSpeed: _patternSpeed,
      patternDensity: _patternDensity,
      patternRotate: _patternRotate,
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
    final showSearchField = _currentTab == 0 && _isSearchActive;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: showSearchField
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearchActive = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null,
        title: showSearchField
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              )
            : Text(
                _currentTab == 0
                    ? l.titleLibrary
                    : _currentTab == 1
                        ? l.titleAdjust
                        : l.titleOptions,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          if (_currentTab == 0 && !_isSearchActive)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            ),
          if (showSearchField && _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
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
                  setState(() {
                    _useDayNightMode = val;
                    if (val) _syncWithSystemTheme = false;
                  });
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
                            _currentTab = 1;
                          });
                          await _savePersistedData();
                          await _applySettings();
                          if (context.mounted && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        onTetrisStyleChanged: (val) {
                          setState(() => _tetrisStyle = val);
                          _savePersistedData();
                        },
                        patternLayoutSize: _patternLayoutSize,
                        patternSlotIcons: _patternSlotIcons,
                        patternSpeed: _patternSpeed,
                        patternDensity: _patternDensity,
                        patternRotate: _patternRotate,
                        onPatternLayoutSizeChanged: (val) {
                          setState(() {
                            _patternLayoutSize = val;
                            // resize list
                            final int targetLength = val * val;
                            if (_patternSlotIcons.length < targetLength) {
                              _patternSlotIcons.addAll(List.generate(targetLength - _patternSlotIcons.length, (_) => 'circle'));
                            } else if (_patternSlotIcons.length > targetLength) {
                              _patternSlotIcons = _patternSlotIcons.sublist(0, targetLength);
                            }
                          });
                          _savePersistedData();
                        },
                        onPatternSlotIconChanged: (idx, val) {
                          setState(() => _patternSlotIcons[idx] = val);
                          _savePersistedData();
                        },
                        onPatternSpeedChanged: (val) {
                          setState(() => _patternSpeed = val);
                          _savePersistedData();
                        },
                        onPatternDensityChanged: (val) {
                          setState(() => _patternDensity = val);
                          _savePersistedData();
                        },
                        onPatternRotateChanged: (val) {
                          setState(() => _patternRotate = val);
                          _savePersistedData();
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
                  setState(() {
                    _useDayNightMode = val;
                    if (val) _syncWithSystemTheme = false;
                  });
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
                    patternLayoutSize: _patternLayoutSize,
                    patternSlotIcons: _patternSlotIcons,
                    patternSpeed: _patternSpeed,
                    patternDensity: _patternDensity,
                    patternRotate: _patternRotate,
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
                    patternLayoutSize: _patternLayoutSize,
                    patternSlotIcons: _patternSlotIcons,
                    patternSpeed: _patternSpeed,
                    patternDensity: _patternDensity,
                    patternRotate: _patternRotate,
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
                patternLayoutSize: _patternLayoutSize,
                patternSlotIcons: _patternSlotIcons,
                patternSpeed: _patternSpeed,
                patternDensity: _patternDensity,
                patternRotate: _patternRotate,
                onPatternLayoutSizeChanged: (val) {
                  setState(() {
                    _patternLayoutSize = val;
                    final int targetLength = val * val;
                    if (_patternSlotIcons.length < targetLength) {
                      _patternSlotIcons.addAll(List.generate(targetLength - _patternSlotIcons.length, (_) => 'circle'));
                    } else if (_patternSlotIcons.length > targetLength) {
                      _patternSlotIcons = _patternSlotIcons.sublist(0, targetLength);
                    }
                  });
                  _savePersistedData();
                },
                onPatternSlotIconChanged: (idx, val) {
                  setState(() => _patternSlotIcons[idx] = val);
                  _savePersistedData();
                },
                onPatternSpeedChanged: (val) {
                  setState(() => _patternSpeed = val);
                  _savePersistedData();
                },
                onPatternDensityChanged: (val) {
                  setState(() => _patternDensity = val);
                  _savePersistedData();
                },
                onPatternRotateChanged: (val) {
                  setState(() => _patternRotate = val);
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
                selectedEngineLock: _selectedEngineLock,
                onLockEngineChanged: (val) async {
                  setState(() {
                    _selectedEngineLock = val;
                  });
                  await _savePersistedData();
                  await _applySettings(); // Notificar al servicio nativo
                },
                engines: getEngines(context),
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
    final secondaryColor = Theme.of(context).cardColor;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20, top: 8),
          height: 64,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment((_currentTab - 1) * 1.0, 0.0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  heightFactor: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildNavItem(0, Icons.collections_bookmark_outlined, l.tabLibrary)),
                    Expanded(child: _buildNavItem(1, Icons.home_outlined, l.tabAdjust)),
                    Expanded(child: _buildNavItem(2, Icons.tune_outlined, l.tabOptions)),
                  ],
                ),
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
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
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

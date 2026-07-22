import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customizer_tab.dart';
import 'live_wallpaper_preview.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final String engineId;
  final bool isDimEnabled;
  final double dimIntensity;
  final String tetrisStyle;
  final List<String> playlist;
  final Map<String, String> engines;
  final Map<String, String> engineDescriptions;
  final bool syncWithSystemTheme;
  final bool useDayNightMode;
  final int dayStartHour;
  final int nightStartHour;
  final bool isParallaxEnabled;
  final bool isRandom;
  final String carouselChangeMode;
  final int carouselChangeInterval;
  final bool isHalfFpsEnabled;
  final List<String> playlistGeneral;
  final List<String> playlistDay;
  final List<String> playlistNight;

  // Callbacks
  final ValueChanged<bool> onDimEnabledChanged;
  final ValueChanged<double> onDimIntensityChanged;
  final ValueChanged<double> onDimIntensityChangeEnd;
  final ValueChanged<bool> onParallaxEnabledChanged;
  final ValueChanged<bool> onRandomChanged;
  final ValueChanged<bool> onSyncThemeChanged;
  final ValueChanged<bool> onDayNightModeChanged;
  final ValueChanged<int> onDayStartHourChanged;
  final ValueChanged<int> onNightStartHourChanged;
  final ValueChanged<String> onCarouselChangeModeChanged;
  final ValueChanged<int> onCarouselChangeIntervalChanged;
  final ValueChanged<bool> onHalfFpsEnabledChanged;
  final Function(String) onPickFiles;
  final Function(String, String) onRemoveFile;
  final Function(String) onApplyEngine;
  final ValueChanged<String> onTetrisStyleChanged;

  // Pattern Settings
  final int patternLayoutSize;
  final List<String> patternSlotIcons;
  final double patternSpeed;
  final String patternDensity;
  final bool patternRotate;

  // Pattern Callbacks
  final ValueChanged<int> onPatternLayoutSizeChanged;
  final Function(int, String) onPatternSlotIconChanged;
  final ValueChanged<double> onPatternSpeedChanged;
  final ValueChanged<String> onPatternDensityChanged;
  final ValueChanged<bool> onPatternRotateChanged;

  const WallpaperDetailScreen({
    super.key,
    required this.engineId,
    required this.isDimEnabled,
    required this.dimIntensity,
    required this.tetrisStyle,
    required this.playlist,
    required this.engines,
    required this.engineDescriptions,
    required this.syncWithSystemTheme,
    required this.useDayNightMode,
    required this.dayStartHour,
    required this.nightStartHour,
    required this.isParallaxEnabled,
    required this.isRandom,
    required this.carouselChangeMode,
    required this.carouselChangeInterval,
    required this.isHalfFpsEnabled,
    required this.playlistGeneral,
    required this.playlistDay,
    required this.playlistNight,
    required this.onDimEnabledChanged,
    required this.onDimIntensityChanged,
    required this.onDimIntensityChangeEnd,
    required this.onParallaxEnabledChanged,
    required this.onRandomChanged,
    required this.onSyncThemeChanged,
    required this.onDayNightModeChanged,
    required this.onDayStartHourChanged,
    required this.onNightStartHourChanged,
    required this.onCarouselChangeModeChanged,
    required this.onCarouselChangeIntervalChanged,
    required this.onHalfFpsEnabledChanged,
    required this.onPickFiles,
    required this.onRemoveFile,
    required this.onApplyEngine,
    required this.onTetrisStyleChanged,
    required this.patternLayoutSize,
    required this.patternSlotIcons,
    required this.patternSpeed,
    required this.patternDensity,
    required this.patternRotate,
    required this.onPatternLayoutSizeChanged,
    required this.onPatternSlotIconChanged,
    required this.onPatternSpeedChanged,
    required this.onPatternDensityChanged,
    required this.onPatternRotateChanged,
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  late bool _isDimEnabled;
  late double _dimIntensity;
  late String _tetrisStyle;
  late bool _isParallaxEnabled;
  late bool _isHalfFpsEnabled;
  late bool _useDayNightMode;
  late int _dayStartHour;
  late int _nightStartHour;
  late String _carouselChangeMode;
  late int _carouselChangeInterval;

  // Pattern settings
  late int _patternLayoutSize;
  late List<String> _patternSlotIcons;
  late double _patternSpeed;
  late String _patternDensity;
  late bool _patternRotate;

  @override
  void initState() {
    super.initState();
    _isDimEnabled = widget.isDimEnabled;
    _dimIntensity = widget.dimIntensity;
    _tetrisStyle = widget.tetrisStyle;
    _isParallaxEnabled = widget.isParallaxEnabled;
    _isHalfFpsEnabled = widget.isHalfFpsEnabled;
    _useDayNightMode = widget.useDayNightMode;
    _dayStartHour = widget.dayStartHour;
    _nightStartHour = widget.nightStartHour;
    _carouselChangeMode = widget.carouselChangeMode;
    _carouselChangeInterval = widget.carouselChangeInterval;

    _patternLayoutSize = widget.patternLayoutSize;
    _patternSlotIcons = List.from(widget.patternSlotIcons);
    _patternSpeed = widget.patternSpeed;
    _patternDensity = widget.patternDensity;
    _patternRotate = widget.patternRotate;
  }

  void _openFullscreenPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              LiveWallpaperPreview(
                engineId: widget.engineId,
                isDimEnabled: _isDimEnabled,
                dimIntensity: _dimIntensity,
                tetrisStyle: _tetrisStyle,
                playlist: widget.playlist,
                isAnimActive: true,
                patternLayoutSize: _patternLayoutSize,
                patternSlotIcons: _patternSlotIcons,
                patternSpeed: _patternSpeed,
                patternDensity: _patternDensity,
                patternRotate: _patternRotate,
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPillButton(
                      label: 'Back',
                      icon: Icons.chevron_left,
                      iconBefore: true,
                      isActive: false,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildPillButton(
                      label: 'Apply',
                      icon: Icons.check,
                      iconBefore: false,
                      isActive: true,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onApplyEngine(widget.engineId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required bool iconBefore,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).cardColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : secondaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconBefore) ...[
              Icon(
                icon,
                color: isActive ? secondaryColor : primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? secondaryColor : primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (!iconBefore) ...[
              const SizedBox(width: 6),
              Icon(
                icon,
                color: isActive ? secondaryColor : primaryColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPillButton(
              label: 'Back',
              icon: Icons.chevron_left,
              iconBefore: true,
              isActive: false,
              onTap: () => Navigator.pop(context),
            ),
            Row(
              children: [
                _buildPillButton(
                  label: 'Preview',
                  icon: Icons.visibility_outlined,
                  iconBefore: false,
                  isActive: false,
                  onTap: _openFullscreenPreview,
                ),
                const SizedBox(width: 8),
                _buildPillButton(
                  label: 'Apply',
                  icon: Icons.check,
                  iconBefore: false,
                  isActive: true,
                  onTap: () => widget.onApplyEngine(widget.engineId),
                ),
              ],
            ),
          ],
        ),
      ),
      body: CustomizerTab(
        selectedEngine: widget.engineId,
        isDimEnabled: _isDimEnabled,
        dimIntensity: _dimIntensity,
        tetrisStyle: _tetrisStyle,
        playlist: widget.playlist,
        engines: widget.engines,
        engineDescriptions: widget.engineDescriptions,
        syncWithSystemTheme: widget.syncWithSystemTheme,
        useDayNightMode: _useDayNightMode,
        dayStartHour: _dayStartHour,
        nightStartHour: _nightStartHour,
        isParallaxEnabled: _isParallaxEnabled,
        isRandom: widget.isRandom,
        carouselChangeMode: _carouselChangeMode,
        carouselChangeInterval: _carouselChangeInterval,
        isHalfFpsEnabled: _isHalfFpsEnabled,
        playlistGeneral: widget.playlistGeneral,
        playlistDay: widget.playlistDay,
        playlistNight: widget.playlistNight,
        onDimEnabledChanged: (val) {
          setState(() => _isDimEnabled = val);
          widget.onDimEnabledChanged(val);
        },
        onDimIntensityChanged: (val) {
          setState(() => _dimIntensity = val);
          widget.onDimIntensityChanged(val);
        },
        onDimIntensityChangeEnd: (val) {
          widget.onDimIntensityChangeEnd(val);
        },
        onParallaxEnabledChanged: (val) {
          setState(() => _isParallaxEnabled = val);
          widget.onParallaxEnabledChanged(val);
        },
        onRandomChanged: widget.onRandomChanged,
        onSyncThemeChanged: widget.onSyncThemeChanged,
        onDayNightModeChanged: (val) {
          setState(() => _useDayNightMode = val);
          widget.onDayNightModeChanged(val);
        },
        onDayStartHourChanged: (val) {
          setState(() => _dayStartHour = val);
          widget.onDayStartHourChanged(val);
        },
        onNightStartHourChanged: (val) {
          setState(() => _nightStartHour = val);
          widget.onNightStartHourChanged(val);
        },
        onCarouselChangeModeChanged: (val) {
          setState(() => _carouselChangeMode = val);
          widget.onCarouselChangeModeChanged(val);
        },
        onCarouselChangeIntervalChanged: (val) {
          setState(() => _carouselChangeInterval = val);
          widget.onCarouselChangeIntervalChanged(val);
        },
        onHalfFpsEnabledChanged: (val) {
          setState(() => _isHalfFpsEnabled = val);
          widget.onHalfFpsEnabledChanged(val);
        },
        onPickFiles: widget.onPickFiles,
        onRemoveFile: widget.onRemoveFile,
        onApplySettings: () => widget.onApplyEngine(widget.engineId),
        onRestoreDefault: () {},
        onTetrisStyleChanged: (val) {
          setState(() => _tetrisStyle = val);
          widget.onTetrisStyleChanged(val);
        },
        patternLayoutSize: _patternLayoutSize,
        patternSlotIcons: _patternSlotIcons,
        patternSpeed: _patternSpeed,
        patternDensity: _patternDensity,
        patternRotate: _patternRotate,
        onPatternLayoutSizeChanged: (val) {
          setState(() {
            _patternLayoutSize = val;
            // Resize list accordingly
            final int targetLength = val * val;
            if (_patternSlotIcons.length < targetLength) {
              _patternSlotIcons.addAll(List.generate(targetLength - _patternSlotIcons.length, (_) => 'circle'));
            } else if (_patternSlotIcons.length > targetLength) {
              _patternSlotIcons = _patternSlotIcons.sublist(0, targetLength);
            }
          });
          widget.onPatternLayoutSizeChanged(val);
        },
        onPatternSlotIconChanged: (index, val) {
          setState(() {
            _patternSlotIcons[index] = val;
          });
          widget.onPatternSlotIconChanged(index, val);
        },
        onPatternSpeedChanged: (val) {
          setState(() => _patternSpeed = val);
          widget.onPatternSpeedChanged(val);
        },
        onPatternDensityChanged: (val) {
          setState(() => _patternDensity = val);
          widget.onPatternDensityChanged(val);
        },
        onPatternRotateChanged: (val) {
          setState(() => _patternRotate = val);
          widget.onPatternRotateChanged(val);
        },
        isDetailView: true,
      ),
    );
  }
}

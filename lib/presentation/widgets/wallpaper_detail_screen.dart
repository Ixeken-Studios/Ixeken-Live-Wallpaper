import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customizer_tab.dart';
import 'live_wallpaper_preview.dart';
import '../../wallpaper_manager.dart';

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
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
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
                isDimEnabled: widget.isDimEnabled,
                dimIntensity: widget.dimIntensity,
                tetrisStyle: widget.tetrisStyle,
                playlist: widget.playlist,
                isAnimActive: true,
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
        isDimEnabled: widget.isDimEnabled,
        dimIntensity: widget.dimIntensity,
        tetrisStyle: widget.tetrisStyle,
        playlist: widget.playlist,
        engines: widget.engines,
        engineDescriptions: widget.engineDescriptions,
        syncWithSystemTheme: widget.syncWithSystemTheme,
        useDayNightMode: widget.useDayNightMode,
        dayStartHour: widget.dayStartHour,
        nightStartHour: widget.nightStartHour,
        isParallaxEnabled: widget.isParallaxEnabled,
        isRandom: widget.isRandom,
        carouselChangeMode: widget.carouselChangeMode,
        carouselChangeInterval: widget.carouselChangeInterval,
        isHalfFpsEnabled: widget.isHalfFpsEnabled,
        playlistGeneral: widget.playlistGeneral,
        playlistDay: widget.playlistDay,
        playlistNight: widget.playlistNight,
        onDimEnabledChanged: widget.onDimEnabledChanged,
        onDimIntensityChanged: widget.onDimIntensityChanged,
        onDimIntensityChangeEnd: widget.onDimIntensityChangeEnd,
        onParallaxEnabledChanged: widget.onParallaxEnabledChanged,
        onRandomChanged: widget.onRandomChanged,
        onSyncThemeChanged: widget.onSyncThemeChanged,
        onDayNightModeChanged: widget.onDayNightModeChanged,
        onDayStartHourChanged: widget.onDayStartHourChanged,
        onNightStartHourChanged: widget.onNightStartHourChanged,
        onCarouselChangeModeChanged: widget.onCarouselChangeModeChanged,
        onCarouselChangeIntervalChanged: widget.onCarouselChangeIntervalChanged,
        onHalfFpsEnabledChanged: widget.onHalfFpsEnabledChanged,
        onPickFiles: widget.onPickFiles,
        onRemoveFile: widget.onRemoveFile,
        onApplySettings: () => widget.onApplyEngine(widget.engineId),
        onRestoreDefault: () {},
        onTetrisStyleChanged: (val) {},
        isDetailView: true,
      ),
    );
  }
}

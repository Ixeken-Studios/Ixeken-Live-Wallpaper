import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n.dart';
import 'package:image_picker/image_picker.dart';
import 'live_wallpaper_preview.dart';

class CustomizerTab extends StatefulWidget {
  final String selectedEngine;
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
  final VoidCallback onApplySettings;
  final VoidCallback onRestoreDefault;
  final ValueChanged<String> onTetrisStyleChanged;

  final bool isDetailView;

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

  const CustomizerTab({
    super.key,
    required this.selectedEngine,
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
    required this.onApplySettings,
    required this.onRestoreDefault,
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
    this.isDetailView = false,
  });

  @override
  State<CustomizerTab> createState() => _CustomizerTabState();
}

class _CustomizerTabState extends State<CustomizerTab> {
  String _activeSubTab = 'gallery'; // 'gallery' or 'options'
  String _activePlaylistType = 'general'; // 'general', 'day', 'night'
  List<String> get _currentSubPlaylist {
    if (widget.syncWithSystemTheme) {
      if (_activePlaylistType == 'night') return widget.playlistNight;
      if (_activePlaylistType == 'day') return widget.playlistDay;
      return widget.playlistGeneral;
    } else if (widget.useDayNightMode) {
      if (_activePlaylistType == 'day') return widget.playlistDay;
      if (_activePlaylistType == 'night') return widget.playlistNight;
      return widget.playlistGeneral;
    } else {
      return widget.playlistGeneral;
    }
  }

  void _openFullScreenPreview(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) => GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Positioned.fill(
                  child: LiveWallpaperPreview(
                    engineId: widget.selectedEngine,
                    isDimEnabled: widget.isDimEnabled,
                    dimIntensity: widget.dimIntensity,
                    tetrisStyle: widget.tetrisStyle,
                    playlist: _currentSubPlaylist,
                    isAnimActive: true,
                    patternLayoutSize: widget.patternLayoutSize,
                    patternSlotIcons: widget.patternSlotIcons,
                    patternSpeed: widget.patternSpeed,
                    patternDensity: widget.patternDensity,
                    patternRotate: widget.patternRotate,
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_left,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final screenWidth = MediaQuery.of(context).size.width;
    final previewHeight = screenWidth > 600 ? 400.0 : 330.0;

    final engineTitle = widget.engines[widget.selectedEngine] ?? widget.selectedEngine;
    final engineDesc = widget.engineDescriptions[widget.selectedEngine] ?? l.descCarousel;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!widget.isDetailView) ...[
                const SizedBox(height: 12),
                // Top Bar Header with Clear Wallpaper & Preview buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clear Wallpaper button (Reddish accent)
                    GestureDetector(
                      onTap: widget.onRestoreDefault,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Title in Center
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          engineTitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: onSurfaceColor,
                          ),
                        ),
                      ),
                    ),
                    // Preview button
                    GestureDetector(
                      onTap: () => _openFullScreenPreview(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Preview',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.visibility_outlined, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Featured Photo Carousel Card (Polaroid Style)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: previewHeight,
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: LiveWallpaperPreview(
                            engineId: widget.selectedEngine,
                            isDimEnabled: widget.isDimEnabled,
                            dimIntensity: widget.dimIntensity,
                            tetrisStyle: widget.tetrisStyle,
                            playlist: _currentSubPlaylist,
                            isAnimActive: true,
                            patternLayoutSize: widget.patternLayoutSize,
                            patternSlotIcons: widget.patternSlotIcons,
                            patternSpeed: widget.patternSpeed,
                            patternDensity: widget.patternDensity,
                            patternRotate: widget.patternRotate,
                          ),
                        ),
                        if (widget.isDetailView)
                          Positioned(
                            left: 12,
                            bottom: -12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                engineTitle,
                                style: TextStyle(
                                  color: cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        engineDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurfaceColor,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.isDetailView) ...[
                const SizedBox(height: 8),
                // Apply Wallpaper Button (Borderless TextButton contrasting with theme background)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: widget.onApplySettings,
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    label: Text(
                      'Apply wallpaper',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Body Content: Carousel vs Non-Carousel Engines
              if (widget.selectedEngine == 'carousel') ...[
                // Sub-Navigation Pills (Gallery vs Options)
                Row(
                  children: [
                    Expanded(
                      child: _buildSubTabPill(
                        context,
                        label: l.tabSubGallery,
                        icon: Icons.photo_library_outlined,
                        isSelected: _activeSubTab == 'gallery',
                        onTap: () => setState(() => _activeSubTab = 'gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSubTabPill(
                        context,
                        label: l.tabSubOptions,
                        icon: Icons.settings_outlined,
                        isSelected: _activeSubTab == 'options',
                        onTap: () => setState(() => _activeSubTab = 'options'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_activeSubTab == 'gallery') ...[
                  // Playlist Category Sub-Pills (Dark mode, General, Light mode / Day, Night)
                  _buildPlaylistSubPills(context),
                  const SizedBox(height: 16),
                  // 3-Column Media Grid
                  _buildGridPlaylistEditor(context),
                  const SizedBox(height: 24),
                  // Switches for Carousel / Modes
                  _buildSwitchCard(
                    context: context,
                    title: 'Activate dark/light mode',
                    subtitle: 'Enables dark and light mode photo playlist',
                    icon: Icons.dark_mode_outlined,
                    value: widget.syncWithSystemTheme,
                    onChanged: widget.onSyncThemeChanged,
                  ),
                  _buildSwitchCard(
                    context: context,
                    title: 'Day/Night mode',
                    subtitle: 'Displays images based on scheduled hours',
                    icon: Icons.wb_twilight_outlined,
                    value: widget.useDayNightMode,
                    onChanged: widget.onDayNightModeChanged,
                  ),
                  if (widget.useDayNightMode) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeChip(
                            context,
                            label: 'Day: ${widget.dayStartHour}:00',
                            icon: Icons.wb_sunny_outlined,
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: widget.dayStartHour, minute: 0),
                              );
                              if (time != null) {
                                widget.onDayStartHourChanged(time.hour);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeChip(
                            context,
                            label: 'Night: ${widget.nightStartHour}:00',
                            icon: Icons.nightlight_outlined,
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: widget.nightStartHour, minute: 0),
                              );
                              if (time != null) {
                                widget.onNightStartHourChanged(time.hour);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  _buildCarouselOptions(context),
                ],
              ] else ...[
                // Non-carousel engines display controls directly
                if (widget.selectedEngine == 'tetris') ...[
                  _buildTetrisControls(context),
                ] else if (widget.selectedEngine == 'pattern') ...[
                  _buildPatternControls(context),
                ] else ...[
                  _buildGenericControls(context),
                ],
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? cardColor : primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? cardColor : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistSubPills(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    List<Map<String, String>> pills = [];
    if (widget.syncWithSystemTheme) {
      pills = [
        {'id': 'night', 'label': 'Dark mode'},
        {'id': 'general', 'label': 'General'},
        {'id': 'day', 'label': 'Light mode'},
      ];
    } else if (widget.useDayNightMode) {
      pills = [
        {'id': 'day', 'label': 'Day'},
        {'id': 'general', 'label': 'General'},
        {'id': 'night', 'label': 'Night'},
      ];
    } else {
      pills = [
        {'id': 'general', 'label': 'General'},
      ];
    }

    return Row(
      children: pills.asMap().entries.map((entry) {
        final index = entry.key;
        final p = entry.value;
        final isSelected = _activePlaylistType == p['id'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == pills.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _activePlaylistType = p['id']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  p['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? cardColor : primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridPlaylistEditor(BuildContext context) {
    final List<String> currentList;
    if (_activePlaylistType == 'day') {
      currentList = widget.playlistDay;
    } else if (_activePlaylistType == 'night') {
      currentList = widget.playlistNight;
    } else {
      currentList = widget.playlistGeneral;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: currentList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // First slot: Add image button card
          return GestureDetector(
            onTap: () => widget.onPickFiles(_activePlaylistType),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        }

        final path = currentList[index - 1];
        final isVideo = path.endsWith('.mp4') || path.endsWith('.mkv');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).cardColor,
                      child: Center(
                        child: Icon(
                          isVideo ? Icons.videocam : Icons.image_not_supported_outlined,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -10,
                child: Center(
                  child: GestureDetector(
                    onTap: () => widget.onRemoveFile(_activePlaylistType, path),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailingContent,
  }) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurfaceColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  onChanged(val);
                },
                activeColor: primaryColor,
              ),
            ],
          ),
          if (value && trailingContent != null) ...[
            const SizedBox(height: 12),
            trailingContent,
          ],
        ],
      ),
    );
  }

  Widget _buildCarouselOptions(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: widget.isDimEnabled,
          onChanged: widget.onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined,
                size: 18,
                color: onSurfaceColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: widget.dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(widget.dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: widget.onDimIntensityChanged,
                  onChangeEnd: widget.onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.dimIntensity * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        _buildSwitchCard(
          context: context,
          title: l.optParallax,
          subtitle: l.optParallaxSub,
          icon: Icons.sensors_outlined,
          value: widget.isParallaxEnabled,
          onChanged: widget.onParallaxEnabledChanged,
        ),
        _buildSwitchCard(
          context: context,
          title: l.optRandom,
          subtitle: l.optRandomSub,
          icon: Icons.shuffle,
          value: widget.isRandom,
          onChanged: widget.onRandomChanged,
        ),
        const SizedBox(height: 8),
        _buildDropdownCard<String>(
          context: context,
          title: l.optChangeCondition,
          subtitle: widget.carouselChangeMode == 'on_visibility'
              ? l.changeOnLock
              : l.changeOnTime,
          icon: Icons.swap_horiz_outlined,
          value: widget.carouselChangeMode,
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
          onChanged: (val) {
            if (val != null) {
              widget.onCarouselChangeModeChanged(val);
            }
          },
        ),
        if (widget.carouselChangeMode == 'timer') ...[
          _buildDropdownCard<int>(
            context: context,
            title: l.optChangeInterval,
            subtitle: '',
            icon: Icons.hourglass_empty_outlined,
            value: widget.carouselChangeInterval,
            items: [
              DropdownMenuItem(value: 15, child: Text(l.formatSeconds(15))),
              DropdownMenuItem(value: 30, child: Text(l.formatSeconds(30))),
              DropdownMenuItem(value: 60, child: Text(l.formatMinute)),
              DropdownMenuItem(value: 300, child: Text(l.formatMinutes(5))),
              DropdownMenuItem(value: 900, child: Text(l.formatMinutes(15))),
              DropdownMenuItem(value: 1800, child: Text(l.formatMinutes(30))),
              DropdownMenuItem(value: 3600, child: Text(l.formatHour)),
            ],
            onChanged: (val) {
              if (val != null) {
                widget.onCarouselChangeIntervalChanged(val);
              }
            },
          ),
        ],
        _buildFpsControl(context),
      ],
    );
  }

  Widget _buildDropdownCard<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: onSurfaceColor,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: onSurfaceColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                borderRadius: BorderRadius.circular(14),
                dropdownColor: cardColor,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  onChanged(val);
                },
                items: items,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTactileSlider({
    required BuildContext context,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required Color primaryColor,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withValues(alpha: 0.15),
        trackHeight: 6,
        thumbColor: primaryColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: primaryColor.withValues(alpha: 0.12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  Widget _buildTetrisControls(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: widget.isDimEnabled,
          onChanged: widget.onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: widget.dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(widget.dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: widget.onDimIntensityChanged,
                  onChangeEnd: widget.onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.dimIntensity * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        _buildDropdownCard<String>(
          context: context,
          title: l.tetrisStyle,
          subtitle: widget.tetrisStyle == 'neon'
              ? 'Neon Glow'
              : widget.tetrisStyle == 'retro'
                  ? 'Retro Gameboy'
                  : widget.tetrisStyle == 'pastel'
                      ? 'Pastel Minimal'
                      : 'Cyberpunk Outline',
          icon: Icons.palette_outlined,
          value: widget.tetrisStyle,
          items: const [
            DropdownMenuItem(value: 'neon', child: Text('Neon Glow')),
            DropdownMenuItem(value: 'retro', child: Text('Retro Gameboy')),
            DropdownMenuItem(value: 'pastel', child: Text('Pastel Minimal')),
            DropdownMenuItem(value: 'outline', child: Text('Cyberpunk Outline')),
          ],
          onChanged: (val) {
            if (val != null) {
              widget.onTetrisStyleChanged(val);
            }
          },
        ),
        _buildFpsControl(context),
      ],
    );
  }

  Widget _buildGenericControls(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: widget.isDimEnabled,
          onChanged: widget.onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: widget.dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(widget.dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: widget.onDimIntensityChanged,
                  onChangeEnd: widget.onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.dimIntensity * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (widget.selectedEngine == 'particles') ...[
          _buildSwitchCard(
            context: context,
            title: l.optParallax,
            subtitle: l.optParallaxSub,
            icon: Icons.sensors_outlined,
            value: widget.isParallaxEnabled,
            onChanged: widget.onParallaxEnabledChanged,
          ),
        ],
        _buildFpsControl(context),
      ],
    );
  }

  Widget _buildStyleChip(BuildContext context, String label, String value) {
    final isSelected = widget.tetrisStyle == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) {
          widget.onTetrisStyleChanged(value);
        }
      },
    );
  }

  Widget _buildFpsControl(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optLowerFps,
          subtitle: l.optLowerFpsSub,
          icon: Icons.battery_saver_outlined,
          value: widget.isHalfFpsEnabled,
          onChanged: widget.onHalfFpsEnabledChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.fpsBatterySaverNotice,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: onSurfaceColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternControls(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Diseño del Mosaico",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLayoutButton(context, 1, "1x1"),
            const SizedBox(width: 8),
            _buildLayoutButton(context, 2, "2x2"),
            const SizedBox(width: 8),
            _buildLayoutButton(context, 3, "3x3"),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Personalizar Celdas (Toca para cambiar)",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.15),
              ),
            ),
            child: _buildGridCells(context),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Tamaño de los Iconos (Densidad)",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDensityButton(context, "small", "Pequeño"),
            const SizedBox(width: 8),
            _buildDensityButton(context, "medium", "Mediano"),
            const SizedBox(width: 8),
            _buildDensityButton(context, "large", "Grande"),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Velocidad de Movimiento",
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
            ),
            Text(
              widget.patternSpeed.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        Slider(
          value: widget.patternSpeed,
          min: 1.0,
          max: 5.0,
          divisions: 4,
          onChanged: widget.onPatternSpeedChanged,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            "Rotación de Iconos",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
          ),
          subtitle: const Text(
            "Los iconos rotarán suavemente mientras se desplazan",
            style: TextStyle(fontSize: 12),
          ),
          value: widget.patternRotate,
          onChanged: widget.onPatternRotateChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGridCells(BuildContext context) {
    const double buttonSize = 72.0;
    final int size = widget.patternLayoutSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(size, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(size, (c) {
            final int index = r * size + c;
            final String iconKey = (index < widget.patternSlotIcons.length) ? widget.patternSlotIcons[index] : 'circle';

            return GestureDetector(
              onTap: () => _showIconSelector(context, index),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: _renderSlotPreview(iconKey),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _renderSlotPreview(String iconKey) {
    if (iconKey.startsWith('/') || iconKey.contains('content://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(iconKey),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, size: 28),
        ),
      );
    }

    switch (iconKey) {
      case 'circle':
        return const Icon(Icons.circle_outlined, size: 30);
      case 'square':
        return const Icon(Icons.crop_square_outlined, size: 30);
      case 'triangle':
        return const Icon(Icons.change_history_outlined, size: 30);
      case 'cross':
        return const Icon(Icons.close_outlined, size: 30);
      case 'star':
        return const Icon(Icons.star_outline_rounded, size: 30);
      case 'heart':
      default:
        return const Icon(Icons.favorite_border_rounded, size: 30);
    }
  }

  void _showIconSelector(BuildContext context, int slotIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Seleccionar Icono",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.photo_library_outlined, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: const Text("Elegir de la Galería", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Usa cualquier imagen o icono de tu biblioteca"),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                    if (file != null) {
                      widget.onPatternSlotIconChanged(slotIndex, file.path);
                    }
                  },
                ),
                const Divider(height: 24),
                Text(
                  "Presets Geométricos (Sin Copyright)",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGenericItem(context, slotIndex, "heart", Icons.favorite_border_rounded),
                    _buildGenericItem(context, slotIndex, "star", Icons.star_outline_rounded),
                    _buildGenericItem(context, slotIndex, "circle", Icons.circle_outlined),
                    _buildGenericItem(context, slotIndex, "square", Icons.crop_square_outlined),
                    _buildGenericItem(context, slotIndex, "triangle", Icons.change_history_outlined),
                    _buildGenericItem(context, slotIndex, "cross", Icons.close_outlined),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenericItem(BuildContext context, int slotIndex, String iconKey, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.onPatternSlotIconChanged(slotIndex, iconKey);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildLayoutButton(BuildContext context, int size, String label) {
    final bool isSelected = widget.patternLayoutSize == size;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => widget.onPatternLayoutSizeChanged(size),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDensityButton(BuildContext context, String val, String label) {
    final bool isSelected = widget.patternDensity == val;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => widget.onPatternDensityChanged(val),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

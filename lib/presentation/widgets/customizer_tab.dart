import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n.dart';
import 'live_wallpaper_preview.dart';

class CustomizerTab extends StatelessWidget {
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
    this.isDetailView = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.15),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LiveWallpaperPreview(
                    engineId: selectedEngine,
                    isDimEnabled: isDimEnabled,
                    dimIntensity: dimIntensity,
                    tetrisStyle: tetrisStyle,
                    playlist: playlist,
                    isAnimActive: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDetailView 
                  ? (engines[selectedEngine] ?? selectedEngine)
                  : l.activeWallpaper(engines[selectedEngine] ?? selectedEngine),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              engineDescriptions[selectedEngine] ?? l.descCarousel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black54,
              ),
            ),
            const Divider(height: 32),
            if (selectedEngine == 'carousel') ...[
              _buildCarouselControls(context),
            ] else if (selectedEngine == 'tetris') ...[
              _buildTetrisControls(context),
            ] else ...[
              _buildGenericControls(context),
            ],
            if (!isDetailView) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onApplySettings,
                  label: Text(l.btnApplySystem),
                  icon: const Icon(Icons.wallpaper),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRestoreDefault,
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
            ],
            const SizedBox(height: 120),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.08) 
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
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
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Icon(
                        Icons.check, 
                        color: isDark ? Colors.black : Colors.white,
                        size: 18,
                      );
                    }
                    return const Icon(
                      Icons.close, 
                      color: Colors.white70,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (value && trailingContent != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              trailingContent,
            ],
          ],
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.08) 
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
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
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.04) 
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: cardColor,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    onChanged(val);
                  },
                  items: items,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildCarouselControls(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        if (syncWithSystemTheme) ...[
          _buildPlaylistEditor(context, 'day', l.carouselDayLight),
          const SizedBox(height: 12),
          _buildPlaylistEditor(context, 'night', l.carouselNightDark),
        ] else if (useDayNightMode) ...[
          _buildPlaylistEditor(context, 'day', l.carouselDay),
          const SizedBox(height: 12),
          _buildPlaylistEditor(context, 'night', l.carouselNight),
        ] else ...[
          _buildPlaylistEditor(context, 'general', l.carouselGeneral),
        ],
        const SizedBox(height: 12),
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: isDimEnabled,
          onChanged: onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined, 
                size: 18, 
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: onDimIntensityChanged,
                  onChangeEnd: onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(dimIntensity * 100).round()}%', 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
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
          value: isParallaxEnabled,
          onChanged: onParallaxEnabledChanged,
        ),
        _buildSwitchCard(
          context: context,
          title: l.optRandom,
          subtitle: l.optRandomSub,
          icon: Icons.shuffle,
          value: isRandom,
          onChanged: onRandomChanged,
        ),
        _buildSwitchCard(
          context: context,
          title: l.optDayNight,
          subtitle: l.optDayNightSub,
          icon: Icons.wb_twilight_outlined,
          value: useDayNightMode,
          onChanged: onDayNightModeChanged,
        ),
        if (useDayNightMode) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ActionChip(
                    avatar: const Icon(Icons.wb_sunny_outlined, size: 16),
                    label: Text('${l.dayLabel}: $dayStartHour:00'),
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: dayStartHour, minute: 0));
                      if (time != null) {
                        onDayStartHourChanged(time.hour);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionChip(
                    avatar: const Icon(Icons.nightlight_outlined, size: 16),
                    label: Text('${l.nightLabel}: $nightStartHour:00'),
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: nightStartHour, minute: 0));
                      if (time != null) {
                        onNightStartHourChanged(time.hour);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        _buildDropdownCard<String>(
          context: context,
          title: l.optChangeCondition,
          subtitle: carouselChangeMode == 'on_visibility' 
              ? l.changeOnLock 
              : l.changeOnTime,
          icon: Icons.swap_horiz_outlined,
          value: carouselChangeMode,
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
              onCarouselChangeModeChanged(val);
            }
          },
        ),
        if (carouselChangeMode == 'timer') ...[
          _buildDropdownCard<int>(
            context: context,
            title: l.optChangeInterval,
            subtitle: '',
            icon: Icons.hourglass_empty_outlined,
            value: carouselChangeInterval,
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
                onCarouselChangeIntervalChanged(val);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTetrisControls(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: isDimEnabled,
          onChanged: onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined, 
                size: 18, 
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: onDimIntensityChanged,
                  onChangeEnd: onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(dimIntensity * 100).round()}%', 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.tetrisStyle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStyleChip(context, 'Neon Glow', 'neon'),
            _buildStyleChip(context, 'Retro Gameboy', 'retro'),
            _buildStyleChip(context, 'Pastel Minimal', 'pastel'),
            _buildStyleChip(context, 'Cyberpunk Outline', 'outline'),
          ],
        ),
        _buildFpsControl(context),
      ],
    );
  }

  Widget _buildGenericControls(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optDim,
          subtitle: l.optDimSub,
          icon: Icons.brightness_medium_outlined,
          value: isDimEnabled,
          onChanged: onDimEnabledChanged,
          trailingContent: Row(
            children: [
              Icon(
                Icons.brightness_medium_outlined, 
                size: 18, 
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTactileSlider(
                  context: context,
                  value: dimIntensity,
                  min: 0.1,
                  max: 0.9,
                  divisions: 16,
                  label: '${(dimIntensity * 100).round()}%',
                  primaryColor: primaryColor,
                  onChanged: onDimIntensityChanged,
                  onChangeEnd: onDimIntensityChangeEnd,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(dimIntensity * 100).round()}%', 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        if (selectedEngine == 'particles') ...[
          _buildSwitchCard(
            context: context,
            title: l.optParallax,
            subtitle: l.optParallaxSub,
            icon: Icons.sensors_outlined,
            value: isParallaxEnabled,
            onChanged: onParallaxEnabledChanged,
          ),
        ],
        _buildFpsControl(context),
      ],
    );
  }

  Widget _buildStyleChip(BuildContext context, String label, String value) {
    final isSelected = tetrisStyle == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) {
          onTetrisStyleChanged(value);
        }
      },
    );
  }

  Widget _buildFpsControl(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitchCard(
          context: context,
          title: l.optLowerFps,
          subtitle: l.optLowerFpsSub,
          icon: Icons.battery_saver_outlined,
          value: isHalfFpsEnabled,
          onChanged: onHalfFpsEnabledChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: isDark
                      ? Colors.blueAccent
                      : primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.fpsBatterySaverNotice,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark
                          ? Colors.white70
                          : Colors.black87,
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


  Widget _buildPlaylistEditor(BuildContext context, String type, String title) {
    final List<String> playlistToUse;
    if (type == 'general') {
      playlistToUse = playlistGeneral;
    } else if (type == 'day') {
      playlistToUse = playlistDay;
    } else {
      playlistToUse = playlistNight;
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
            itemCount: playlistToUse.length + 1,
            itemBuilder: (context, index) {
              if (index == playlistToUse.length) {
                return Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withValues(alpha: 0.02) 
                        : Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white.withValues(alpha: 0.08) 
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onPickFiles(type),
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

              final path = playlistToUse[index];
              final isVideo = path.endsWith('.mp4') || path.endsWith('.mkv');
              final filename = path.split('/').last;

              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                child: Card(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
                          onTap: () => onRemoveFile(type, path),
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
}

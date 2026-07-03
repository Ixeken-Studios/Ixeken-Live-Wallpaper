import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n.dart';
import 'live_wallpaper_preview.dart';
import 'wallpaper_detail_screen.dart';

class GalleryTab extends StatelessWidget {
  final String searchQuery;
  final String selectedEngine;
  final String tetrisStyle;
  final List<String> combinedPlaylist;
  final Map<String, String> engines;
  final Map<String, String> engineDescriptions;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<String> onSelectEngine;

  const GalleryTab({
    super.key,
    required this.searchQuery,
    required this.selectedEngine,
    required this.tetrisStyle,
    required this.combinedPlaylist,
    required this.engines,
    required this.engineDescriptions,
    required this.onSearchQueryChanged,
    required this.onSelectEngine,
  });

  void _openCollectionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IxekenWallpapersCollectionScreen(
          selectedEngine: selectedEngine,
          tetrisStyle: tetrisStyle,
          combinedPlaylist: combinedPlaylist,
          engines: engines,
          engineDescriptions: engineDescriptions,
          onSelectEngine: onSelectEngine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final filteredEngines = engines.entries.where((e) {
      final name = e.value.toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black54;
    final iconColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black54;
    final clearIconColor = isDark ? Colors.white60 : Colors.black54;
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);

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
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: clearIconColor),
                      onPressed: () => onSearchQueryChanged(''),
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
            onChanged: onSearchQueryChanged,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (searchQuery.isEmpty) ...[
                    // Featured Photo Carousel Card
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => onSelectEngine('carousel'),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: LiveWallpaperPreview(
                                engineId: 'carousel',
                                isDimEnabled: false,
                                dimIntensity: 0.43,
                                tetrisStyle: tetrisStyle,
                                playlist: combinedPlaylist,
                                isAnimActive: false,
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.3),
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  engines['carousel'] ?? 'Photo carousel',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      engineDescriptions['carousel'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ixeken Wallpapers Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ixeken Wallpapers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openCollectionScreen(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Horizontal scroll of other wallpapers
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: engines.entries
                            .where((e) => e.key != 'carousel')
                            .map((e) => Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _buildEngineCard(context, e.key, e.value),
                                ))
                            .toList(),
                      ),
                    ),
                  ] else ...[
                    // Filtered engines grid
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
                        return _buildEngineCard(context, entry.key, entry.value);
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

  Widget _buildEngineCard(BuildContext context, String engineId, String title) {
    final description = engineDescriptions[engineId] ?? '';
    final isActive = selectedEngine == engineId;
    return GestureDetector(
      onTap: () => onSelectEngine(engineId),
      child: Card(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05)),
            width: isActive ? 2 : 1,
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
                tetrisStyle: tetrisStyle,
                playlist: combinedPlaylist,
                isAnimActive: false,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description.substring(0, math.min(25, description.length)),
                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IxekenWallpapersCollectionScreen extends StatelessWidget {
  final String selectedEngine;
  final String tetrisStyle;
  final List<String> combinedPlaylist;
  final Map<String, String> engines;
  final Map<String, String> engineDescriptions;
  final ValueChanged<String> onSelectEngine;

  const IxekenWallpapersCollectionScreen({
    super.key,
    required this.selectedEngine,
    required this.tetrisStyle,
    required this.combinedPlaylist,
    required this.engines,
    required this.engineDescriptions,
    required this.onSelectEngine,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: primaryColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ixeken Wallpapers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Text(
                'Collection',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 16),
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
                itemCount: engines.length,
                itemBuilder: (context, index) {
                  final entry = engines.entries.toList()[index];
                  return _buildCollectionCard(context, entry.key, entry.value);
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, String engineId, String title) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isActive = selectedEngine == engineId;
    return GestureDetector(
      onTap: () => onSelectEngine(engineId),
      child: Card(
        color: Colors.white.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: isActive
                ? primaryColor
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05)),
            width: isActive ? 2 : 1,
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
                tetrisStyle: tetrisStyle,
                playlist: combinedPlaylist,
                isAnimActive: false,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

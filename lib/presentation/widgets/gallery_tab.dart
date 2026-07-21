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

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final carouselHeight = isTablet ? 280.0 : 180.0;

    return SingleChildScrollView(
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                                  height: carouselHeight,
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: LiveWallpaperPreview(
                                    engineId: 'carousel',
                                    isDimEnabled: false,
                                    dimIntensity: 0.43,
                                    tetrisStyle: tetrisStyle,
                                    playlist: combinedPlaylist,
                                    isAnimActive: true,
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: -12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      engines['carousel'] ?? 'Photo carousel',
                                      style: TextStyle(
                                        color: Theme.of(context).cardColor,
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
                                engineDescriptions['carousel'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
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
                    // Horizontal scroll of other wallpapers (responsive rows for phone vs tablet)
                    Builder(
                      builder: (context) {
                        final collectionEngines = engines.entries.where((e) => e.key != 'carousel').toList();
                        if (isTablet) {
                          return SizedBox(
                            height: 440,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.65,
                              ),
                              itemCount: collectionEngines.length,
                              itemBuilder: (context, index) {
                                final entry = collectionEngines[index];
                                return _buildEngineCard(context, entry.key, entry.value);
                              },
                            ),
                          );
                        } else {
                          return SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: collectionEngines.length,
                              itemBuilder: (context, index) {
                                final entry = collectionEngines[index];
                                return Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _buildEngineCard(context, entry.key, entry.value),
                                );
                              },
                            ),
                          );
                        }
                      },
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
    );
  }

  Widget _buildEngineCard(BuildContext context, String engineId, String title) {
    final isActive = selectedEngine == engineId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelectEngine(engineId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isActive ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IgnorePointer(
                child: LiveWallpaperPreview(
                  engineId: engineId,
                  isDimEnabled: false,
                  dimIntensity: 0.43,
                  tetrisStyle: tetrisStyle,
                  playlist: combinedPlaylist,
                  isAnimActive: false,
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: -14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ixeken Wallpapers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Collection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final collectionEngines = engines.entries.where((e) => e.key != 'carousel').toList();
                  return GridView.builder(
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
                    itemCount: collectionEngines.length,
                    itemBuilder: (context, index) {
                      final entry = collectionEngines[index];
                      return _buildCollectionCard(context, entry.key, entry.value);
                    },
                  );
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
    final isActive = selectedEngine == engineId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelectEngine(engineId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: isActive ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: IgnorePointer(
                child: LiveWallpaperPreview(
                  engineId: engineId,
                  isDimEnabled: false,
                  dimIntensity: 0.43,
                  tetrisStyle: tetrisStyle,
                  playlist: combinedPlaylist,
                  isAnimActive: false,
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: -14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

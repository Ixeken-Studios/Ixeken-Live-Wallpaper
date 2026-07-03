import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n.dart';
import 'live_wallpaper_preview.dart';

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
    final l = L10n.of(context);
    final description = engineDescriptions[engineId] ?? '';
    final isActive = selectedEngine == engineId;
    return Card(
      color: Colors.white.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : (Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.black.withValues(alpha: 0.05)), 
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
              tetrisStyle: tetrisStyle,
              playlist: combinedPlaylist,
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
                  overflow: TextOverflow.ellipsis,
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
                        onPressed: () => onSelectEngine(engineId),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isActive 
                                ? Theme.of(context).colorScheme.primary 
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26),
                          ),
                          backgroundColor: isActive 
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.black45 : Colors.white.withValues(alpha: 0.7)),
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
}

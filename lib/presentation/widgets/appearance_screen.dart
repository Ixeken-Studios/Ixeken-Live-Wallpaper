import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n.dart';

class AppearanceScreen extends StatefulWidget {
  final String appThemeMode;
  final ValueChanged<String> onAppThemeModeChanged;
  final String currentFont;
  final ValueChanged<String> onFontChanged;

  const AppearanceScreen({
    super.key,
    required this.appThemeMode,
    required this.onAppThemeModeChanged,
    required this.currentFont,
    required this.onFontChanged,
  });

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  double _fontWeight = 400.0;
  double _letterSpacing = 0.0;

  @override
  void initState() {
    super.initState();
    // Default weights
  }

  void _showVariationsSheet() {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                          child: Icon(Icons.settings_suggest_outlined, color: primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.customizeGsFlex,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'GS Flex Variable Font Axes',
                                style: TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Font Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _fontWeight,
                            min: 100.0,
                            max: 900.0,
                            divisions: 8,
                            label: _fontWeight.round().toString(),
                            onChanged: (val) {
                              setModalState(() {
                                _fontWeight = val;
                              });
                              setState(() {});
                            },
                          ),
                        ),
                        Text(_fontWeight.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Letter Spacing', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _letterSpacing,
                            min: -2.0,
                            max: 4.0,
                            divisions: 12,
                            label: _letterSpacing.toStringAsFixed(1),
                            onChanged: (val) {
                              setModalState(() {
                                _letterSpacing = val;
                              });
                              setState(() {});
                            },
                          ),
                        ),
                        Text(_letterSpacing.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Typography Preview',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.values[((_fontWeight - 100) / 100).round().clamp(0, 8)],
                          letterSpacing: _letterSpacing,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSegmentedSelector<T>({
    required List<T> options,
    required T selectedValue,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedIndex = options.indexOf(selectedValue);
    final count = options.length;

    // alignX calculation: from -1.0 to 1.0
    final alignX = count > 1 ? -1.0 + (2.0 * selectedIndex) / (count - 1) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      padding: const EdgeInsets.all(4),
      height: 52,
      child: Stack(
        children: [
          // Sliding active pill
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment(alignX, 0.0),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : primaryColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Interactive Texts
          Row(
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelected(option);
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.white)
                            : (isDark ? Colors.white54 : Colors.black54),
                      ),
                      child: Text(labelBuilder(option)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appearance),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: cardColor,
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
                            child: Icon(Icons.dark_mode_outlined, color: primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l.themeModeTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSegmentedSelector<String>(
                        options: const ['system', 'light', 'dark'],
                        selectedValue: widget.appThemeMode,
                        labelBuilder: (val) {
                          if (val == 'system') return l.themeOptSystem;
                          if (val == 'light') return l.themeOptLight;
                          return l.themeOptDark;
                        },
                        onSelected: widget.onAppThemeModeChanged,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: cardColor,
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
                            child: Icon(Icons.font_download_outlined, color: primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l.fontStyleTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSegmentedSelector<String>(
                        options: const ['system', 'gs_flex', 'nunito'],
                        selectedValue: widget.currentFont,
                        labelBuilder: (val) {
                          if (val == 'system') return l.fontOptSystem;
                          if (val == 'gs_flex') return 'GS Flex';
                          return 'Nunito';
                        },
                        onSelected: widget.onFontChanged,
                      ),
                      if (widget.currentFont == 'gs_flex') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showVariationsSheet,
                            icon: const Icon(Icons.settings_suggest_outlined),
                            label: Text(l.customizeGsFlex),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n.dart';

class AppearanceScreen extends StatefulWidget {
  final String appThemeMode;
  final ValueChanged<String> onAppThemeModeChanged;
  final String currentFont;
  final ValueChanged<String> onFontChanged;
  final int fontSizeIndex;
  final ValueChanged<int> onFontSizeIndexChanged;

  const AppearanceScreen({
    super.key,
    required this.appThemeMode,
    required this.onAppThemeModeChanged,
    required this.currentFont,
    required this.onFontChanged,
    required this.fontSizeIndex,
    required this.onFontSizeIndexChanged,
  });

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  double _fontWeight = 400.0;
  double _letterSpacing = 0.0;
  late String _currentThemeMode;
  late String _currentFont;
  late int _currentFontSizeIndex;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.appThemeMode;
    _currentFont = widget.currentFont;
    _currentFontSizeIndex = widget.fontSizeIndex;
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                            max: 10.0,
                            divisions: 24,
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

  Widget _buildGridButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).cardColor; // Secondary

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : secondaryColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? secondaryColor : primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildGridButton(
              label: 'Ixeken light',
              isSelected: _currentThemeMode == 'ixeken_light',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'ixeken_light';
                });
                widget.onAppThemeModeChanged('ixeken_light');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Ixeken dark',
              isSelected: _currentThemeMode == 'ixeken_dark',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'ixeken_dark';
                });
                widget.onAppThemeModeChanged('ixeken_dark');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Cherry',
              isSelected: _currentThemeMode == 'cherry',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'cherry';
                });
                widget.onAppThemeModeChanged('cherry');
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGridButton(
              label: 'Amoled',
              isSelected: _currentThemeMode == 'amoled',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'amoled';
                });
                widget.onAppThemeModeChanged('amoled');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Elegance',
              isSelected: _currentThemeMode == 'elegance',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'elegance';
                });
                widget.onAppThemeModeChanged('elegance');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Earthy',
              isSelected: _currentThemeMode == 'earthy',
              onTap: () {
                setState(() {
                  _currentThemeMode = 'earthy';
                });
                widget.onAppThemeModeChanged('earthy');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildGridButton(
              label: 'System',
              isSelected: _currentFont == 'system',
              onTap: () {
                setState(() {
                  _currentFont = 'system';
                });
                widget.onFontChanged('system');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Inter',
              isSelected: _currentFont == 'inter',
              onTap: () {
                setState(() {
                  _currentFont = 'inter';
                });
                widget.onFontChanged('inter');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Rubik',
              isSelected: _currentFont == 'rubik',
              onTap: () {
                setState(() {
                  _currentFont = 'rubik';
                });
                widget.onFontChanged('rubik');
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGridButton(
              label: 'Space Grotesk',
              isSelected: _currentFont == 'space_grotesk',
              onTap: () {
                setState(() {
                  _currentFont = 'space_grotesk';
                });
                widget.onFontChanged('space_grotesk');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'Ubuntu',
              isSelected: _currentFont == 'ubuntu',
              onTap: () {
                setState(() {
                  _currentFont = 'ubuntu';
                });
                widget.onFontChanged('ubuntu');
              },
            ),
            const SizedBox(width: 8),
            _buildGridButton(
              label: 'GS Sans Flex',
              isSelected: _currentFont == 'gs_sans_flex' || _currentFont == 'gs_flex',
              onTap: () {
                setState(() {
                  _currentFont = 'gs_sans_flex';
                });
                widget.onFontChanged('gs_sans_flex');
              },
            ),
          ],
        ),
      ],
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
                            child: Icon(Icons.brush_outlined, color: primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l.themeModeTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildThemeGrid(),
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
                            child: Icon(Icons.text_fields_outlined, color: primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l.fontStyleTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFontGrid(),
                      if (_currentFont == 'gs_sans_flex' || _currentFont == 'gs_flex') ...[
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
                            child: Icon(Icons.format_size_outlined, color: primaryColor),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Font Size',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                          thumbColor: primaryColor,
                          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
                          activeTickMarkColor: primaryColor,
                          inactiveTickMarkColor: primaryColor.withValues(alpha: 0.4),
                        ),
                        child: Slider(
                          value: _currentFontSizeIndex.toDouble(),
                          min: 0,
                          max: 8,
                          divisions: 8,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _currentFontSizeIndex = val.round();
                            });
                            widget.onFontSizeIndexChanged(val.round());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(9, (index) {
                            final isMiddle = index == 4;
                            return Text(
                              isMiddle ? '|' : '•',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isMiddle ? FontWeight.bold : FontWeight.normal,
                                color: primaryColor.withValues(alpha: 0.6),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_info_screen.dart';
import 'ixeken_logo.dart';
import '../../l10n.dart';

class SettingsTab extends StatelessWidget {
  final VoidCallback onShowAppearance;
  final VoidCallback onShowPermissions;
  final String selectedEngineLock;
  final ValueChanged<String> onLockEngineChanged;
  final Map<String, String> engines;

  const SettingsTab({
    super.key,
    required this.onShowAppearance,
    required this.onShowPermissions,
    required this.selectedEngineLock,
    required this.onLockEngineChanged,
    required this.engines,
  });

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.preferences,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: cardColor,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: onSurfaceColor.withValues(alpha: isDark ? 0.08 : 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: primaryColor,
                    ),
                  ),
                  title: Text(
                    l.appearance,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l.appearanceSub),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                  onTap: onShowAppearance,
                ),
              ),
              const SizedBox(height: 12),
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: onSurfaceColor.withValues(alpha: isDark ? 0.08 : 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.lockScreenWallpaper,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l.lockScreenSub,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: onSurfaceColor.withValues(alpha: 0.6),
                                  ),
                                ),
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
                          child: DropdownButton<String>(
                            value: selectedEngineLock,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                            borderRadius: BorderRadius.circular(14),
                            dropdownColor: cardColor,
                            onChanged: (val) {
                              if (val != null) {
                                HapticFeedback.selectionClick();
                                onLockEngineChanged(val);
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'same',
                                child: Text(l.sameAsHome),
                              ),
                              ...engines.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              )),
                            ],
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
                ),
              ),
            Text(
              l.sysPermissions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  l.managePermissions,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(l.configPermissionsSub),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black45,
                ),
                onTap: onShowPermissions,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.aboutApp,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: IxekenLogo(
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                title: const Text(
                  'Ixeken Live Wallpaper',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: const Text(
                  'v1.2.0',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black45,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppInfoScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    ),
    );
  }
}

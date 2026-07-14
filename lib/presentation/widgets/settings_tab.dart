import 'package:flutter/material.dart';
import '../../l10n.dart';
import '../../wallpaper_manager.dart';

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
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(l.appearance),
                  subtitle: Text(l.appearanceSub),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                  onTap: onShowAppearance,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).cardColor,
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
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lock Screen Wallpaper',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Select a different engine for the lock screen',
                                  style: TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedEngineLock,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: Theme.of(context).cardColor,
                            onChanged: (val) {
                              if (val != null) {
                                onLockEngineChanged(val);
                              }
                            },
                            items: [
                              const DropdownMenuItem(
                                value: 'same',
                                child: Text('Same as Home Screen'),
                              ),
                              ...engines.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              )),
                            ],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
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
                title: Text(l.managePermissions),
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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.sourceCode),
                    subtitle: Text(l.sourceCodeSub),
                    onTap: () => WallpaperManager.launchUrl('https://github.com/Ixeken-Studios/Ixeken-Live-Wallpaper'),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.developedBy),
                    subtitle: const Text('Ixeken Studios'),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
                    title: Text(l.privacyPolicy),
                    subtitle: Text(l.readPrivacy),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l.privacyPolicy),
                          content: SingleChildScrollView(
                            child: Text(l.privacyContent),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l.understood),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
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

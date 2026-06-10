import 'package:flutter/material.dart';
import '../../l10n.dart';
import '../../wallpaper_manager.dart';

class SettingsTab extends StatelessWidget {
  final VoidCallback onShowAppearance;
  final VoidCallback onShowPermissions;

  const SettingsTab({
    super.key,
    required this.onShowAppearance,
    required this.onShowPermissions,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              const SizedBox(height: 16),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

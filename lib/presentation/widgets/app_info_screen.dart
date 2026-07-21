import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ixeken_logo.dart';
import '../../l10n.dart';
import '../../wallpaper_manager.dart';
import '../../services/github_update_service.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  bool _checkUpdateOnStart = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkUpdateOnStart = prefs.getBool('check_update_on_start') ?? false;
    });
  }

  void _showInternetConfirmDialog(BuildContext context, {required VoidCallback onConfirm}) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.wifi_outlined, color: primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.internetConfirmTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l.internetConfirmDesc,
          style: TextStyle(
            fontSize: 13,
            color: onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l.btnCancel,
              style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l.btnProceed, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCheckUpdate(bool val) async {
    if (val) {
      _showInternetConfirmDialog(context, onConfirm: () async {
        final prefs = await SharedPreferences.getInstance();
        setState(() => _checkUpdateOnStart = true);
        await prefs.setBool('check_update_on_start', true);
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() => _checkUpdateOnStart = false);
      await prefs.setBool('check_update_on_start', false);
    }
  }

  void _performCheckForUpdates(BuildContext context) {
    _showInternetConfirmDialog(context, onConfirm: () async {
      final l = L10n.of(context);
      final primaryColor = Theme.of(context).colorScheme.primary;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(l.checkingUpdates),
            ],
          ),
          duration: const Duration(seconds: 10),
        ),
      );

      final result = await GitHubUpdateService.checkForUpdates();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      switch (result) {
        case NewVersionResult(:final version, :final downloadUrl, :final changelog):
          _showNewVersionBottomSheet(context, version: version, downloadUrl: downloadUrl, changelog: changelog);
          break;
        case UpToDateResult():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.latestVersionMsg(GitHubUpdateService.currentAppVersion)),
              backgroundColor: primaryColor,
            ),
          );
          break;
        case FutureVersionResult():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.prereleaseVersionMsg),
              backgroundColor: primaryColor,
            ),
          );
          break;
        case ErrorResult(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l.errorCheckUpdates} ${message.isNotEmpty ? "($message)" : ""}'),
              backgroundColor: Colors.redAccent,
            ),
          );
          break;
      }
    });
  }

  void _showNewVersionBottomSheet(BuildContext context, {required String version, required String downloadUrl, String? changelog}) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.system_update, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.newVersionTitle(version),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.newVersionSub,
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (changelog != null && changelog.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l.releaseNotes,
                    style: TextStyle(fontWeight: FontWeight.bold, color: onSurface),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        changelog,
                        style: TextStyle(fontSize: 13, height: 1.4, color: onSurface.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      WallpaperManager.launchUrl(downloadUrl);
                    },
                    icon: const Icon(Icons.download),
                    label: Text(l.btnDownloadApk, style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangelogItem(BuildContext context, String title, String description) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangelog(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.article_outlined, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.viewChangelog} v${GitHubUpdateService.currentAppVersion}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.releaseHighlights,
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChangelogItem(context, l.clOverhaulTitle, l.clOverhaulDesc),
                        _buildChangelogItem(context, l.clThemesTitle, l.clThemesDesc),
                        _buildChangelogItem(context, l.clUpdatesTitle, l.clUpdatesDesc),
                        _buildChangelogItem(context, l.clWallpapersTitle, l.clWallpapersDesc),
                        _buildChangelogItem(context, l.clPerformanceTitle, l.clPerformanceDesc),
                      ],
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
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      enableDrag: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.shield_outlined, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.privacyPolicy,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.readPrivacy,
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      l.privacyContent,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l.understood,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

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
                  color: cardColor,
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
                      l.back,
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.appTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.code, color: primaryColor),
                    ),
                    title: Text(l.viewRepo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l.viewRepoSub, style: const TextStyle(fontSize: 12)),
                    trailing: Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.5)),
                    onTap: () => WallpaperManager.launchUrl('https://github.com/Ixeken-Studios/Ixeken-Live-Wallpaper'),
                  ),
                  Divider(height: 1, color: onSurfaceColor.withValues(alpha: 0.08)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.article_outlined, color: primaryColor),
                    ),
                    title: Text(l.viewChangelog, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.5)),
                    onTap: () => _showChangelog(context),
                  ),
                  Divider(height: 1, color: onSurfaceColor.withValues(alpha: 0.08)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.sync, color: primaryColor),
                    ),
                    title: Text(l.checkUpdates, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.5)),
                    onTap: () => _performCheckForUpdates(context),
                  ),
                  Divider(height: 1, color: onSurfaceColor.withValues(alpha: 0.08)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.rocket_launch_outlined, color: primaryColor),
                    ),
                    title: Text(l.checkUpdateStart, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l.checkUpdateStartSub, style: const TextStyle(fontSize: 11)),
                    trailing: Switch(
                      value: _checkUpdateOnStart,
                      onChanged: _toggleCheckUpdate,
                      activeColor: primaryColor,
                    ),
                  ),
                  Divider(height: 1, color: onSurfaceColor.withValues(alpha: 0.08)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.shield_outlined, color: primaryColor),
                    ),
                    title: Text(l.privacyPolicy, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.5)),
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  Divider(height: 1, color: onSurfaceColor.withValues(alpha: 0.08)),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IxekenLogo(size: 20, color: primaryColor),
                      ),
                    ),
                    title: Text(l.createdBy, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l.madeInMexico, style: const TextStyle(fontSize: 12)),
                    trailing: Icon(Icons.chevron_right, color: onSurfaceColor.withValues(alpha: 0.5)),
                    onTap: () => WallpaperManager.launchUrl('https://github.com/Ixeken-Studios'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n.dart';

class PermissionsSheet extends StatelessWidget {
  const PermissionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    bool photosGranted = false;
    bool batteryIgnored = false;
    bool isSensorsExpanded = false;
    bool isStabilityExpanded = false;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        final l = L10n.of(context);
        Future<void> checkPermissions() async {
          final photos = await Permission.photos.isGranted;
          final battery = await Permission.ignoreBatteryOptimizations.isGranted;
          setSheetState(() {
            photosGranted = photos;
            batteryIgnored = battery;
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final photos = await Permission.photos.isGranted;
          final battery = await Permission.ignoreBatteryOptimizations.isGranted;
          if (photos != photosGranted || battery != batteryIgnored) {
            setSheetState(() {
              photosGranted = photos;
              batteryIgnored = battery;
            });
          }
        });

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = Theme.of(context).cardColor;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 36,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.permManageTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l.permManageDesc,
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceColor.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withValues(alpha: isDark ? 0.08 : 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.storage, color: primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.permGallery,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.permGallerySub,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            photosGranted
                                ? Icon(Icons.check_circle, color: primaryColor, size: 28)
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: cardColor,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      final status = await Permission.photos.request();
                                      if (status.isPermanentlyDenied) {
                                        openAppSettings();
                                      }
                                      await checkPermissions();
                                    },
                                    child: Text(
                                      l.allow,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withValues(alpha: isDark ? 0.08 : 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.wifi_outlined, color: primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.permInternet,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.permInternetSub,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.check_circle, color: primaryColor, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.palette_outlined, color: primaryColor),
                            ),
                            title: Text(
                              l.permOptionalService,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              l.permOptionalSub,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: Icon(
                              isSensorsExpanded ? Icons.expand_less : Icons.expand_more,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onTap: () {
                              setSheetState(() {
                                isSensorsExpanded = !isSensorsExpanded;
                              });
                            },
                          ),
                          if (isSensorsExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.sensors, color: primaryColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.permParallax,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            l.permParallaxSub,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white54 : Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.check_circle, color: primaryColor, size: 24),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.bolt, color: primaryColor),
                            ),
                            title: Text(
                              l.permStability,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              l.permStabilitySub,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: Icon(
                              isStabilityExpanded ? Icons.expand_less : Icons.expand_more,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onTap: () {
                              setSheetState(() {
                                isStabilityExpanded = !isStabilityExpanded;
                              });
                            },
                          ),
                          if (isStabilityExpanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.battery_alert, color: primaryColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.permBattery,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            l.permBatterySub,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white54 : Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    batteryIgnored
                                        ? Icon(Icons.check_circle, color: primaryColor, size: 24)
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: isDark ? Colors.black : Colors.white,
                                              shape: const StadiumBorder(),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              elevation: 0,
                                            ),
                                            onPressed: () async {
                                              final status = await Permission.ignoreBatteryOptimizations.request();
                                              if (status.isPermanentlyDenied) {
                                                openAppSettings();
                                              }
                                              await checkPermissions();
                                            },
                                            child: Text(
                                              l.ignore,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
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
                  const Divider(height: 32, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings_applications, color: Colors.redAccent),
                      label: Text(
                        l.revokeSettings,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'dart:io';

sealed class UpdateResult {
  const UpdateResult();
}

class UpToDateResult extends UpdateResult {
  const UpToDateResult();
}

class NewVersionResult extends UpdateResult {
  final String version;
  final String downloadUrl;
  final String? changelog;

  const NewVersionResult({
    required this.version,
    required this.downloadUrl,
    this.changelog,
  });
}

class FutureVersionResult extends UpdateResult {
  const FutureVersionResult();
}

class ErrorResult extends UpdateResult {
  final String message;
  const ErrorResult([this.message = '']);
}

class GitHubUpdateService {
  static const String repositoryOwner = 'Ixeken-Studios';
  static const String repositoryName = 'gakuu-app';
  static const String currentAppVersion = '1.2.0';

  static int compareVersions(String current, String latest) {
    final cleanCurrent = current.replaceAll(RegExp(r'^[vV]'), '').trim();
    final cleanLatest = latest.replaceAll(RegExp(r'^[vV]'), '').trim();
    if (cleanCurrent == cleanLatest) return 0;

    final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = currentParts.length > latestParts.length ? currentParts.length : latestParts.length;
    for (int i = 0; i < maxLength; i++) {
      final currVal = i < currentParts.length ? currentParts[i] : 0;
      final latVal = i < latestParts.length ? latestParts[i] : 0;
      if (currVal > latVal) return 1;
      if (latVal > currVal) return -1;
    }
    return 0;
  }

  static Future<UpdateResult> checkForUpdates() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      
      final url = Uri.parse('https://api.github.com/repos/$repositoryOwner/$repositoryName/releases/latest');
      final request = await client.getUrl(url);
      request.headers.set('Accept', 'application/vnd.github+json');
      request.headers.set('User-Agent', 'Ixeken-Live-Wallpaper');

      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        final tagName = json['tag_name'] as String? ?? '';
        final htmlUrl = json['html_url'] as String? ?? '';
        final body = json['body'] as String?;

        String apkUrl = htmlUrl;
        if (json.containsKey('assets') && json['assets'] is List) {
          final assets = json['assets'] as List;
          for (final asset in assets) {
            if (asset is Map<String, dynamic>) {
              final name = asset['name'] as String? ?? '';
              if (name.toLowerCase().endsWith('.apk')) {
                apkUrl = asset['browser_download_url'] as String? ?? htmlUrl;
                break;
              }
            }
          }
        }

        final comparison = compareVersions(currentAppVersion, tagName);
        if (comparison < 0) {
          return NewVersionResult(
            version: tagName,
            downloadUrl: apkUrl,
            changelog: body,
          );
        } else if (comparison > 0) {
          return const FutureVersionResult();
        } else {
          return const UpToDateResult();
        }
      } else {
        return ErrorResult('HTTP ${response.statusCode}');
      }
    } catch (e) {
      return ErrorResult(e.toString());
    }
  }
}

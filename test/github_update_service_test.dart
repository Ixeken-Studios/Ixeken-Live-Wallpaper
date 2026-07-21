import 'package:flutter_test/flutter_test.dart';
import 'package:ixeken_live_wallpaper/services/github_update_service.dart';

void main() {
  group('GitHubUpdateService Version Comparison Tests', () {
    test('Same versions should return 0', () {
      expect(GitHubUpdateService.compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(GitHubUpdateService.compareVersions('v1.0.0', '1.0.0'), equals(0));
      expect(GitHubUpdateService.compareVersions('V1.2', 'v1.2.0'), equals(0));
    });

    test('Newer latest version should return -1', () {
      expect(GitHubUpdateService.compareVersions('1.0.0', '1.0.1'), equals(-1));
      expect(GitHubUpdateService.compareVersions('1.0.0', 'v1.1.0'), equals(-1));
      expect(GitHubUpdateService.compareVersions('v1.0.0', 'v2.0.0'), equals(-1));
    });

    test('Current version ahead of latest should return 1', () {
      expect(GitHubUpdateService.compareVersions('1.1.0', '1.0.0'), equals(1));
      expect(GitHubUpdateService.compareVersions('v2.0.0', 'v1.9.9'), equals(1));
    });
  });
}

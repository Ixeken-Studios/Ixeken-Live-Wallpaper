import 'package:flutter_test/flutter_test.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/current_state.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/local_wallpaper.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/wallpaper_config.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/strategies/sequential_strategy.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/strategies/shuffle_strategy.dart';

void main() {
  group('SequentialStrategy Tests', () {
    final strategy = SequentialStrategy();
    final w1 = const LocalWallpaper(id: 1, localPath: '/path/1.png', orderIndex: 10, isActive: true);
    final w2 = const LocalWallpaper(id: 2, localPath: '/path/2.png', orderIndex: 20, isActive: true);
    final w3 = const LocalWallpaper(id: 3, localPath: '/path/3.png', orderIndex: 5, isActive: true);
    final list = [w1, w2, w3];

    test('should return null when playlist is empty', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([], state), isNull);
    });

    test('should return the only element when playlist size is 1', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([w1], state), equals(w1));
    });

    test('should return element with lowest orderIndex when current is null', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      // Lowest order index is w3 (5)
      expect(strategy.selectNext(list, state), equals(w3));
    });

    test('should return next element based on orderIndex', () {
      final state = CurrentState(
        currentWallpaper: w3,
        dateTime: DateTime.now(),
        systemTheme: 'light',
      );
      expect(strategy.selectNext(list, state), equals(w1));
    });

    test('should wrap around to first element when current is the last one', () {
      final state = CurrentState(
        currentWallpaper: w2,
        dateTime: DateTime.now(),
        systemTheme: 'light',
      );
      expect(strategy.selectNext(list, state), equals(w3));
    });
  });

  group('ShuffleStrategy Tests', () {
    final strategy = ShuffleStrategy();
    final w1 = const LocalWallpaper(id: 1, localPath: '/path/1.png', orderIndex: 1, isActive: true);
    final w2 = const LocalWallpaper(id: 2, localPath: '/path/2.png', orderIndex: 2, isActive: true);
    final w3 = const LocalWallpaper(id: 3, localPath: '/path/3.png', orderIndex: 3, isActive: true);
    final list = [w1, w2, w3];

    test('should return null when list is empty', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([], state), isNull);
    });

    test('should return the only element when list size is 1', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([w1], state), equals(w1));
    });

    test('should return a different element from current when multiple options exist', () {
      final state = CurrentState(
        currentWallpaper: w2,
        dateTime: DateTime.now(),
        systemTheme: 'dark',
      );
      for (int i = 0; i < 20; i++) {
        final result = strategy.selectNext(list, state);
        expect(result, isNotNull);
        expect(result!.id, isNot(equals(w2.id)));
      }
    });
  });

  group('WallpaperConfig Tests', () {
    test('should instantiate correct properties', () {
      const config = WallpaperConfig(
        strategyId: 'sequential',
        extraParams: {'key': 'val'},
      );
      expect(config.strategyId, 'sequential');
      expect(config.extraParams['key'], 'val');
    });
  });
}

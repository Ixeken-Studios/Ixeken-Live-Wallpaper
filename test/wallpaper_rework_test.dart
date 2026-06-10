import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/current_state.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/local_wallpaper.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/entities/wallpaper_config.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/strategies/sequential_strategy.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/domain/strategies/shuffle_strategy.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/data/models/local_wallpaper_model.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/data/models/wallpaper_config_model.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/data/repositories/wallpaper_repository_impl.dart';
import 'package:ixeken_live_wallpaper/features/wallpaper/services/background/background_wallpaper_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain - SequentialStrategy', () {
    final strategy = SequentialStrategy();
    final wallpaper1 = const LocalWallpaper(id: 1, localPath: '/path/1.png', orderIndex: 10, isActive: true);
    final wallpaper2 = const LocalWallpaper(id: 2, localPath: '/path/2.png', orderIndex: 20, isActive: true);
    final wallpaper3 = const LocalWallpaper(id: 3, localPath: '/path/3.png', orderIndex: 5, isActive: true);
    final list = [wallpaper1, wallpaper2, wallpaper3]; // orderIndices: 5 (id:3), 10 (id:1), 20 (id:2)

    test('retorna null si la lista está vacía', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([], state), isNull);
    });

    test('retorna el único elemento si la lista tiene tamaño 1', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([wallpaper1], state), equals(wallpaper1));
    });

    test('retorna el elemento con menor orderIndex si no hay wallpaper actual', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      // El de menor índice es wallpaper3 (orderIndex: 5)
      expect(strategy.selectNext(list, state), equals(wallpaper3));
    });

    test('retorna el siguiente elemento según orderIndex', () {
      // Si el actual es wallpaper3 (index 5), el siguiente debe ser wallpaper1 (index 10)
      final state = CurrentState(
        currentWallpaper: wallpaper3,
        dateTime: DateTime.now(),
        systemTheme: 'light',
      );
      expect(strategy.selectNext(list, state), equals(wallpaper1));
    });

    test('hace wrap-around al primer elemento si el actual es el último', () {
      // Si el actual es wallpaper2 (index 20), el siguiente debe regresar a wallpaper3 (index 5)
      final state = CurrentState(
        currentWallpaper: wallpaper2,
        dateTime: DateTime.now(),
        systemTheme: 'light',
      );
      expect(strategy.selectNext(list, state), equals(wallpaper3));
    });
  });

  group('Domain - ShuffleStrategy', () {
    final strategy = ShuffleStrategy();
    final wallpaper1 = const LocalWallpaper(id: 1, localPath: '/path/1.png', orderIndex: 1, isActive: true);
    final wallpaper2 = const LocalWallpaper(id: 2, localPath: '/path/2.png', orderIndex: 2, isActive: true);
    final wallpaper3 = const LocalWallpaper(id: 3, localPath: '/path/3.png', orderIndex: 3, isActive: true);
    final list = [wallpaper1, wallpaper2, wallpaper3];

    test('retorna null si la lista está vacía', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([], state), isNull);
    });

    test('retorna el único elemento si la lista tiene tamaño 1', () {
      final state = CurrentState(dateTime: DateTime.now(), systemTheme: 'dark');
      expect(strategy.selectNext([wallpaper1], state), equals(wallpaper1));
    });

    test('retorna un wallpaper que no es el actual si hay múltiples opciones', () {
      final state = CurrentState(
        currentWallpaper: wallpaper2,
        dateTime: DateTime.now(),
        systemTheme: 'dark',
      );
      // Debe retornar wallpaper1 o wallpaper3, pero nunca wallpaper2
      for (int i = 0; i < 20; i++) {
        final result = strategy.selectNext(list, state);
        expect(result, isNotNull);
        expect(result!.id, isNot(equals(wallpaper2.id)));
      }
    });
  });

  group('Data - Models Serialization', () {
    test('LocalWallpaperModel de/serializa JSON correctamente', () {
      final model = const LocalWallpaperModel(id: 42, localPath: '/test.png', orderIndex: 3, isActive: true);
      final json = model.toJson();
      expect(json['id'], 42);
      expect(json['localPath'], '/test.png');
      expect(json['orderIndex'], 3);
      expect(json['isActive'], true);

      final fromJson = LocalWallpaperModel.fromJson(json);
      expect(fromJson.id, 42);
      expect(fromJson.localPath, '/test.png');
      expect(fromJson.orderIndex, 3);
      expect(fromJson.isActive, true);
    });

    test('WallpaperConfigModel de/serializa JSON correctamente', () {
      final model = const WallpaperConfigModel(strategyId: 'shuffle', extraParams: {'blur': 5.0});
      final json = model.toJson();
      expect(json['strategyId'], 'shuffle');
      expect(json['extraParams']['blur'], 5.0);

      final fromJson = WallpaperConfigModel.fromJson(json);
      expect(fromJson.strategyId, 'shuffle');
      expect(fromJson.extraParams['blur'], 5.0);
    });
  });

  group('Data - WallpaperRepositoryImpl', () {
    late SharedPreferences prefs;
    late WallpaperRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = WallpaperRepositoryImpl(prefs);
    });

    test('guarda y recupera la configuración correctamente', () async {
      final config = const WallpaperConfig(strategyId: 'shuffle', extraParams: {'some': 'value'});
      await repository.saveConfig(config);

      final loaded = await repository.getConfig();
      expect(loaded.strategyId, 'shuffle');
      expect(loaded.extraParams['some'], 'value');
    });

    test('guarda, lista y elimina wallpapers correctamente', () async {
      final w1 = const LocalWallpaper(id: 1, localPath: '/1.png', orderIndex: 1, isActive: true);
      final w2 = const LocalWallpaper(id: 2, localPath: '/2.png', orderIndex: 2, isActive: false);

      await repository.saveWallpaper(w1);
      await repository.saveWallpaper(w2);

      final all = await repository.getAllWallpapers();
      expect(all.length, 2);
      expect(all.any((w) => w.id == 1), true);

      final active = await repository.getActiveWallpapers();
      expect(active.length, 1);
      expect(active.first.id, 1);

      await repository.deleteWallpaper(1);
      final afterDelete = await repository.getAllWallpapers();
      expect(afterDelete.length, 1);
      expect(afterDelete.first.id, 2);
    });
  });

  group('Background - BackgroundWallpaperService', () {
    late SharedPreferences prefs;
    late WallpaperRepositoryImpl repository;
    late BackgroundWallpaperService service;
    final List<MethodCall> methodCalls = [];

    setUp(() async {
      methodCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.ixeken.wallpaper/media'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return true;
        },
      );

      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = WallpaperRepositoryImpl(prefs);
      service = BackgroundWallpaperService(
        repository: repository,
        strategies: [SequentialStrategy(), ShuffleStrategy()],
      );
    });

    test('cambia al siguiente wallpaper secuencial y actualiza la configuración', () async {
      // 1. Guardar wallpapers
      final w1 = const LocalWallpaper(id: 10, localPath: '/10.png', orderIndex: 1, isActive: true);
      final w2 = const LocalWallpaper(id: 20, localPath: '/20.png', orderIndex: 2, isActive: true);
      await repository.saveAllWallpapers([w1, w2]);

      // 2. Guardar configuración inicial (secuencial, inicializado sin actual)
      await repository.saveConfig(const WallpaperConfig(strategyId: 'sequential', extraParams: {}));

      // 3. Primer cambio: sin actual previo, selecciona el primero (w1)
      await service.onScreenStateChanged(systemTheme: 'dark', time: DateTime.now());

      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'applySingleWallpaper');
      expect(methodCalls.first.arguments['path'], '/10.png');

      // Verificar que el id seleccionado actual está guardado
      var updatedConfig = await repository.getConfig();
      expect(updatedConfig.extraParams['current_wallpaper_id'], 10);

      // 4. Segundo cambio: con w1 actual, debe seleccionar w2
      methodCalls.clear();
      await service.onScreenStateChanged(systemTheme: 'dark', time: DateTime.now());

      expect(methodCalls.length, 1);
      expect(methodCalls.first.arguments['path'], '/20.png');

      updatedConfig = await repository.getConfig();
      expect(updatedConfig.extraParams['current_wallpaper_id'], 20);
    });
  });
}

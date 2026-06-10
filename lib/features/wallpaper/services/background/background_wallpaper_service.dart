import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../../domain/entities/current_state.dart';
import '../../domain/entities/local_wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../../domain/strategies/sequential_strategy.dart';
import '../../domain/strategies/wallpaper_selection_strategy.dart';

/// @nodoc
/// Servicio que se ejecuta en segundo plano para manejar los eventos del sistema.
///
/// Es completamente desacoplado ("ciego") de la interfaz de usuario de Flutter.
/// Reacciona a eventos de bloqueo/desbloqueo de pantalla gaticulados desde la plataforma nativa,
/// ejecuta la estrategia de selección configurada en la base de datos local y llama
/// al canal nativo con la ruta absoluta del nuevo wallpaper.
class BackgroundWallpaperService {
  static const MethodChannel _channel = MethodChannel('com.ixeken.wallpaper/media');

  final WallpaperRepository _repository;
  final List<WallpaperSelectionStrategy> _strategies;

  /// Constructor que inyecta el repositorio y las estrategias disponibles.
  BackgroundWallpaperService({
    required WallpaperRepository repository,
    required List<WallpaperSelectionStrategy> strategies,
  })  : _repository = repository,
        _strategies = strategies;

  /// Método principal que se invoca cuando el dispositivo detecta un evento de pantalla
  /// (como SCREEN_ON o SCREEN_OFF).
  ///
  /// [systemTheme] indica si el sistema está en 'light' o 'dark'.
  /// [time] es la hora actual del dispositivo enviada por el servicio.
  Future<void> onScreenStateChanged({
    required String systemTheme,
    required DateTime time,
  }) async {
    // 1. Cargar la configuración actual de rotación
    final config = await _repository.getConfig();

    // 2. Obtener los wallpapers activos para la rotación
    final List<LocalWallpaper> activeWallpapers = await _repository.getActiveWallpapers();
    if (activeWallpapers.isEmpty) {
      return;
    }

    // 3. Resolver la estrategia activa seleccionada por el usuario
    final WallpaperSelectionStrategy selectionStrategy = _strategies.firstWhere(
      (strategy) => strategy.id == config.strategyId,
      orElse: () => SequentialStrategy(), // Fallback por defecto a secuencial
    );

    // 4. Determinar el wallpaper actual para alimentar el estado
    final int? currentWallpaperId = config.extraParams['current_wallpaper_id'] as int?;
    LocalWallpaper? currentWallpaper;
    if (currentWallpaperId != null) {
      final index = activeWallpapers.indexWhere((w) => w.id == currentWallpaperId);
      if (index != -1) {
        currentWallpaper = activeWallpapers[index];
      }
    }

    final currentState = CurrentState(
      currentWallpaper: currentWallpaper,
      dateTime: time,
      systemTheme: systemTheme,
    );

    // 5. Aplicar la estrategia para seleccionar el siguiente wallpaper
    final LocalWallpaper? nextWallpaper = selectionStrategy.selectNext(
      activeWallpapers,
      currentState,
    );

    if (nextWallpaper == null) {
      return;
    }

    // 6. Actualizar la configuración persistiendo el ID del wallpaper actual
    final updatedConfig = config.copyWith(
      extraParams: {
        ...config.extraParams,
        'current_wallpaper_id': nextWallpaper.id,
      },
    );
    await _repository.saveConfig(updatedConfig);

    // 7. Invocar el canal de plataforma para renderizar el fondo nativo
    await _applyWallpaperToNative(nextWallpaper.localPath);
  }

  /// Envía la ruta del archivo comprimido al motor nativo para su visualización.
  Future<void> _applyWallpaperToNative(String localPath) async {
    try {
      await _channel.invokeMethod('applySingleWallpaper', {
        'path': localPath,
      });
    } on PlatformException catch (e) {
      // Registrar error silenciosamente en segundo plano sin interrumpir el servicio
      developer.log('Error al aplicar wallpaper nativo desde background: ${e.message}');
    }
  }
}

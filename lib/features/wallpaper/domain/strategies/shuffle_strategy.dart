import 'dart:math';
import '../entities/local_wallpaper.dart';
import '../entities/current_state.dart';
import 'wallpaper_selection_strategy.dart';

/// @nodoc
/// Estrategia que selecciona un wallpaper de forma aleatoria, evitando repetir el actual.
class ShuffleStrategy implements WallpaperSelectionStrategy {
  final Random _random;

  /// Constructor que permite opcionalmente inyectar una instancia de [Random] para pruebas.
  ShuffleStrategy({Random? random}) : _random = random ?? Random();

  @override
  String get id => 'shuffle';

  @override
  LocalWallpaper? selectNext(List<LocalWallpaper> list, CurrentState state) {
    if (list.isEmpty) return null;
    if (list.length == 1) return list.first;

    final current = state.currentWallpaper;
    
    // Filtrar para excluir el wallpaper actual
    final candidates = list.where((element) => element.id != current?.id).toList();

    // Si todos fueron filtrados (ej. la lista sólo contenía al actual), usamos la lista original
    final selectionPool = candidates.isNotEmpty ? candidates : list;

    final nextIndex = _random.nextInt(selectionPool.length);
    return selectionPool[nextIndex];
  }
}

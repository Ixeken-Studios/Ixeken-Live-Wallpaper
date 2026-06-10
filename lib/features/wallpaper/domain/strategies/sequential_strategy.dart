import '../entities/local_wallpaper.dart';
import '../entities/current_state.dart';
import 'wallpaper_selection_strategy.dart';

/// @nodoc
/// Estrategia que selecciona secuencialmente el siguiente wallpaper basándose en el [orderIndex].
class SequentialStrategy implements WallpaperSelectionStrategy {
  @override
  String get id => 'sequential';

  @override
  LocalWallpaper? selectNext(List<LocalWallpaper> list, CurrentState state) {
    if (list.isEmpty) return null;
    if (list.size == 1) return list.first;

    // Ordenar por el índice de orden definido
    final sortedList = List<LocalWallpaper>.from(list)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final current = state.currentWallpaper;
    if (current == null) {
      return sortedList.first;
    }

    // Buscar el elemento actual en la lista ordenada
    final currentIndex = sortedList.indexWhere((element) => element.id == current.id);

    if (currentIndex == -1) {
      // Si el actual no existe en la lista, retornar el primero
      return sortedList.first;
    }

    // Calcular el siguiente índice y retornar con wrap-around
    final nextIndex = (currentIndex + 1) % sortedList.length;
    return sortedList[nextIndex];
  }
}

extension on List {
  int get size => length;
}

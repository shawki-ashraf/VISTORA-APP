import 'package:bloc/bloc.dart';
import 'package:mira_fashon/features/favorite/data/favorate_repo.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteInitial());

  final FavoriteRepo _favoriteRepo = FavoriteRepo();

  List<String> favoriteIds = [];

  /// 🔥 Load realtime favorites
  void loadFavorites() {
    emit(FavoriteLoading());

    _favoriteRepo.getFavorites().listen(
      (ids) {
        favoriteIds = ids;
        emit(FavoriteLoaded(List.from(favoriteIds)));
      },
      onError: (error) {
        emit(FavoriteError(error.toString()));
      },
    );
  }

  /// ❤️ Toggle favorite
  Future<void> toggleFavorite(String productId) async {
    try {
      if (favoriteIds.contains(productId)) {
        await _favoriteRepo.removeFromFavorite(productId);
        favoriteIds.remove(productId);
      } else {
        await _favoriteRepo.addToFavorite(productId);
        favoriteIds.add(productId);
      }

      emit(FavoriteLoaded(List.from(favoriteIds)));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  /// 💡 Check favorite
  bool isFavorite(String productId) {
    return favoriteIds.contains(productId);
  }
}

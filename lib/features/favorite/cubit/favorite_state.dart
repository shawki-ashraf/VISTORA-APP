part of 'favorite_cubit.dart';

sealed class FavoriteState {}

final class FavoriteInitial extends FavoriteState {}

final class FavoriteLoading extends FavoriteState {}

final class FavoriteLoaded extends FavoriteState {
  final List<String> favoriteProductIds;

  FavoriteLoaded(this.favoriteProductIds);
}

final class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError(this.message);
}

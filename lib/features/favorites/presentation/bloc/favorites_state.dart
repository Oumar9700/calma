import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoaded extends FavoritesState {
  final List<Favorite> favorites;
  const FavoritesLoaded(this.favorites);

  bool isFavoriteDish(String dishId) =>
      favorites.any((f) => f.dishId == dishId);

  bool isFavoriteVendor(String vendorId) =>
      favorites.any((f) => f.isVendor && f.vendorId == vendorId);

  String? getFavoriteId({String? dishId, String? vendorId}) {
    final match = favorites.where((f) =>
        (dishId != null && f.dishId == dishId) ||
        (vendorId != null && f.isVendor && f.vendorId == vendorId));
    return match.isEmpty ? null : match.first.id;
  }

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}

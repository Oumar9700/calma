import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  final String userId;
  const LoadFavorites(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFavorite extends FavoritesEvent {
  final String userId;
  final String? dishId;
  final String? vendorId;
  const ToggleFavorite({
    required this.userId,
    this.dishId,
    this.vendorId,
  });
  @override
  List<Object?> get props => [userId, dishId, vendorId];
}

class FavoritesUpdated extends FavoritesEvent {
  final List<Favorite> favorites;
  const FavoritesUpdated(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

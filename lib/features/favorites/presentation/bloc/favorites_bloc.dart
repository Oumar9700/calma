import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;
  StreamSubscription? _favoritesSubscription;

  FavoritesBloc(this._repository) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FavoritesUpdated>(_onFavoritesUpdated);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _repository
        .watchFavorites(event.userId)
        .listen((favorites) => add(FavoritesUpdated(favorites)));
  }

  void _onFavoritesUpdated(
    FavoritesUpdated event,
    Emitter<FavoritesState> emit,
  ) {
    emit(FavoritesLoaded(event.favorites));
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final existingId = await _repository.getFavoriteId(
      userId: event.userId,
      dishId: event.dishId,
      vendorId: event.vendorId,
    );

    if (existingId != null) {
      await _repository.removeFavorite(
        userId: event.userId,
        favoriteId: existingId,
      );
    } else {
      await _repository.addFavorite(
        userId: event.userId,
        dishId: event.dishId,
        vendorId: event.vendorId,
      );
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}

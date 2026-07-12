import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDataSource _dataSource;

  FavoritesRepositoryImpl(this._dataSource);

  @override
  Stream<List<Favorite>> watchFavorites(String userId) =>
      _dataSource.watchFavorites(userId);

  @override
  Future<void> addFavorite({
    required String userId,
    String? dishId,
    String? vendorId,
  }) =>
      _dataSource.addFavorite(userId: userId, dishId: dishId, vendorId: vendorId);

  @override
  Future<void> removeFavorite({
    required String userId,
    required String favoriteId,
  }) =>
      _dataSource.removeFavorite(userId, favoriteId);

  @override
  Future<String?> getFavoriteId({
    required String userId,
    String? dishId,
    String? vendorId,
  }) =>
      _dataSource.getFavoriteId(userId: userId, dishId: dishId, vendorId: vendorId);
}

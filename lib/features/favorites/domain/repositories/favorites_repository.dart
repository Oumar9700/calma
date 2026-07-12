import '../entities/favorite.dart';

abstract class FavoritesRepository {
  Stream<List<Favorite>> watchFavorites(String userId);
  Future<void> addFavorite({
    required String userId,
    String? dishId,
    String? vendorId,
  });
  Future<void> removeFavorite({
    required String userId,
    required String favoriteId,
  });
  Future<String?> getFavoriteId({
    required String userId,
    String? dishId,
    String? vendorId,
  });
}

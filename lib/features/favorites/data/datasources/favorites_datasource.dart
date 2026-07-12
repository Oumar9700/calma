import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite.dart';

class FavoritesDataSource {
  final FirebaseFirestore _firestore;

  FavoritesDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _userFavorites(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  Stream<List<Favorite>> watchFavorites(String userId) {
    return _userFavorites(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return Favorite(
                id: doc.id,
                userId: userId,
                dishId: data['dishId'] as String?,
                vendorId: data['vendorId'] as String?,
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }

  Future<void> addFavorite({
    required String userId,
    String? dishId,
    String? vendorId,
  }) async {
    await _userFavorites(userId).add({
      'dishId': dishId,
      'vendorId': vendorId,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeFavorite(String userId, String favoriteId) async {
    await _userFavorites(userId).doc(favoriteId).delete();
  }

  Future<String?> getFavoriteId({
    required String userId,
    String? dishId,
    String? vendorId,
  }) async {
    Query<Map<String, dynamic>> query = _userFavorites(userId);
    if (dishId != null) query = query.where('dishId', isEqualTo: dishId);
    if (vendorId != null) query = query.where('vendorId', isEqualTo: vendorId);
    final snap = await query.limit(1).get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }
}

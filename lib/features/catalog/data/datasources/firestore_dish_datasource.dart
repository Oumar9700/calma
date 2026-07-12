import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/dish_category.dart';

class FirestoreDishDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDishDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _dishes =>
      _firestore.collection('dishes');

  Future<String> createDish(Dish dish) async {
    final ref = await _dishes.add(_toMap(dish));
    return ref.id;
  }

  Future<void> updateDish(Dish dish) async {
    await _dishes.doc(dish.id).update(_toMap(dish));
  }

  Future<void> deleteDish(String dishId) async {
    await _dishes.doc(dishId).delete();
  }

  Future<void> toggleActive(String dishId, {required bool isActive}) async {
    await _dishes.doc(dishId).update({'isActive': isActive});
  }

  Stream<List<Dish>> watchVendorDishes(String vendorId) {
    return _dishes
        .where('vendorId', isEqualTo: vendorId)
        .snapshots()
        .map((snap) {
          final dishes = snap.docs.map(_fromDoc).toList();
          dishes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return dishes;
        });
  }

  Future<List<Dish>> fetchActiveDishes() async {
    final snap = await _dishes.where('isActive', isEqualTo: true).get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<List<Dish>> fetchVendorDishes(String vendorId) async {
    final snap = await _dishes
        .where('vendorId', isEqualTo: vendorId)
        .get();
    final dishes = snap.docs.map(_fromDoc).toList();
    dishes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return dishes;
  }

  Future<Dish?> getDish(String dishId) async {
    final doc = await _dishes.doc(dishId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Map<String, dynamic> _toMap(Dish d) => {
        'vendorId': d.vendorId,
        'name': d.name,
        'countryOfOrigin': d.countryOfOrigin,
        'region': d.region,
        'description': d.description,
        'category': d.category.name,
        'photoUrls': d.photoUrls,
        'price': d.price,
        'dailyMaxQuantity': d.dailyMaxQuantity,
        'preorderEnabled': d.preorderEnabled,
        'prepTimeMinutes': d.prepTimeMinutes,
        'isActive': d.isActive,
        'averageRating': d.averageRating,
        'reviewCount': d.reviewCount,
        'availableDays': d.availableDays,
        'createdAt': Timestamp.fromDate(d.createdAt),
      };

  Dish _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Dish(
      id: doc.id,
      vendorId: data['vendorId'] as String,
      name: data['name'] as String,
      countryOfOrigin: data['countryOfOrigin'] as String?,
      region: data['region'] as String?,
      description: data['description'] as String?,
      category: DishCategory.fromString(data['category'] as String? ?? 'other'),
      photoUrls: List<String>.from(data['photoUrls'] as List? ?? []),
      price: (data['price'] as num).toDouble(),
      dailyMaxQuantity: data['dailyMaxQuantity'] as int?,
      preorderEnabled: data['preorderEnabled'] as bool? ?? false,
      prepTimeMinutes: data['prepTimeMinutes'] as int?,
      isActive: data['isActive'] as bool? ?? true,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      availableDays: List<String>.from(data['availableDays'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

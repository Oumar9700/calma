import '../../domain/entities/dish.dart';
import '../../domain/entities/dish_category.dart';
import '../../domain/repositories/dish_repository.dart';
import '../datasources/firestore_dish_datasource.dart';

class DishRepositoryImpl implements DishRepository {
  final FirestoreDishDataSource _dataSource;

  DishRepositoryImpl(this._dataSource);

  @override
  Future<String> createDish(Dish dish) => _dataSource.createDish(dish);

  @override
  Future<void> updateDish(Dish dish) => _dataSource.updateDish(dish);

  @override
  Future<void> deleteDish(String dishId) => _dataSource.deleteDish(dishId);

  @override
  Future<void> toggleDishActive(String dishId, {required bool isActive}) =>
      _dataSource.toggleActive(dishId, isActive: isActive);

  @override
  Stream<List<Dish>> watchVendorDishes(String vendorId) =>
      _dataSource.watchVendorDishes(vendorId);

  @override
  Future<List<Dish>> fetchActiveDishes({
    String? countryOfOrigin,
    DishCategory? category,
    bool availableToday = false,
    double? minRating,
    String? searchQuery,
    String? availableDay,
    String? orderType,
  }) async {
    var result = await _dataSource.fetchActiveDishes();
    if (countryOfOrigin != null) {
      result = result.where((d) => d.countryOfOrigin == countryOfOrigin).toList();
    }
    if (category != null) {
      result = result.where((d) => d.category == category).toList();
    }
    if (availableToday) {
      result = result.where((d) => d.isAvailableToday).toList();
    }
    if (availableDay != null) {
      result = result.where((d) => d.availableDays.contains(availableDay)).toList();
    }
    if (orderType != null) {
      result = result.where((d) {
        switch (orderType) {
          case 'direct':
            return d.directOrderEnabled;
          case 'preorder':
            return d.preorderEnabled;
          case 'both':
            return d.directOrderEnabled && d.preorderEnabled;
          default:
            return true;
        }
      }).toList();
    }
    if (minRating != null) {
      result = result.where((d) => d.averageRating >= minRating).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              (d.countryOfOrigin?.toLowerCase().contains(q) ?? false) ||
              (d.region?.toLowerCase().contains(q) ?? false) ||
              (d.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return result;
  }

  @override
  Future<List<Dish>> fetchVendorDishes(String vendorId) =>
      _dataSource.fetchVendorDishes(vendorId);

  @override
  Future<Dish?> getDish(String dishId) => _dataSource.getDish(dishId);
}

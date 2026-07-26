import '../entities/dish.dart';
import '../entities/dish_category.dart';

abstract class DishRepository {
  Future<String> createDish(Dish dish);
  Future<void> updateDish(Dish dish);
  Future<void> deleteDish(String dishId);
  Future<void> toggleDishActive(String dishId, {required bool isActive});
  Stream<List<Dish>> watchVendorDishes(String vendorId);
  Future<List<Dish>> fetchActiveDishes({
    String? countryOfOrigin,
    DishCategory? category,
    bool availableToday = false,
    double? minRating,
    String? searchQuery,
    String? availableDay,
    String? orderType,
  });
  Future<List<Dish>> fetchVendorDishes(String vendorId);
  Future<Dish?> getDish(String dishId);
}

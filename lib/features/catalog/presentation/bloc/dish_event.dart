import 'package:equatable/equatable.dart';
import '../../domain/entities/dish.dart';

abstract class DishEvent extends Equatable {
  const DishEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorDishes extends DishEvent {
  final String vendorId;
  const LoadVendorDishes(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

class CreateDish extends DishEvent {
  final Dish dish;
  const CreateDish(this.dish);
  @override
  List<Object?> get props => [dish];
}

class UpdateDish extends DishEvent {
  final Dish dish;
  const UpdateDish(this.dish);
  @override
  List<Object?> get props => [dish];
}

class DeleteDish extends DishEvent {
  final String dishId;
  const DeleteDish(this.dishId);
  @override
  List<Object?> get props => [dishId];
}

class ToggleDishActive extends DishEvent {
  final String dishId;
  final bool isActive;
  const ToggleDishActive(this.dishId, {required this.isActive});
  @override
  List<Object?> get props => [dishId, isActive];
}

class DishesUpdated extends DishEvent {
  final List<Dish> dishes;
  const DishesUpdated(this.dishes);
  @override
  List<Object?> get props => [dishes];
}

class DishesStreamFailed extends DishEvent {
  final String message;
  const DishesStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

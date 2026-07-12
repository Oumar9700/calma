import 'package:equatable/equatable.dart';
import '../../domain/entities/dish.dart';

abstract class DishState extends Equatable {
  const DishState();
  @override
  List<Object?> get props => [];
}

class DishInitial extends DishState {
  const DishInitial();
}

class DishLoading extends DishState {
  const DishLoading();
}

class DishLoaded extends DishState {
  final List<Dish> dishes;
  const DishLoaded(this.dishes);
  @override
  List<Object?> get props => [dishes];
}

// Uniquement pour les échecs de LECTURE du stream Firestore
class DishError extends DishState {
  final String message;
  const DishError(this.message);
  @override
  List<Object?> get props => [message];
}

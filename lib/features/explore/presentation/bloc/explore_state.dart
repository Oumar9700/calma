import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../domain/entities/explore_filter.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreLoaded extends ExploreState {
  final List<Dish> dishes;
  final ExploreFilter filter;
  final bool isGridView;

  const ExploreLoaded({
    required this.dishes,
    this.filter = ExploreFilter.empty,
    this.isGridView = false,
  });

  ExploreLoaded copyWith({
    List<Dish>? dishes,
    ExploreFilter? filter,
    bool? isGridView,
  }) {
    return ExploreLoaded(
      dishes: dishes ?? this.dishes,
      filter: filter ?? this.filter,
      isGridView: isGridView ?? this.isGridView,
    );
  }

  @override
  List<Object?> get props => [dishes, filter, isGridView];
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);
  @override
  List<Object?> get props => [message];
}

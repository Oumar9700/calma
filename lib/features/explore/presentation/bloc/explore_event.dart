import 'package:equatable/equatable.dart';
import '../../domain/entities/explore_filter.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();
  @override
  List<Object?> get props => [];
}

class LoadDishes extends ExploreEvent {
  final ExploreFilter filter;
  const LoadDishes({this.filter = ExploreFilter.empty});
  @override
  List<Object?> get props => [filter];
}

class UpdateFilter extends ExploreEvent {
  final ExploreFilter filter;
  const UpdateFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class ToggleViewMode extends ExploreEvent {
  const ToggleViewMode();
}

class ClearFilters extends ExploreEvent {
  const ClearFilters();
}

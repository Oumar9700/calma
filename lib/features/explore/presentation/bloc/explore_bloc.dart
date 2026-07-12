import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/domain/repositories/dish_repository.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final DishRepository _dishRepository;

  ExploreBloc(this._dishRepository) : super(const ExploreInitial()) {
    on<LoadDishes>(_onLoadDishes);
    on<UpdateFilter>(_onUpdateFilter);
    on<ToggleViewMode>(_onToggleViewMode);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadDishes(LoadDishes event, Emitter<ExploreState> emit) async {
    emit(const ExploreLoading());
    try {
      final dishes = await _dishRepository.fetchActiveDishes(
        countryOfOrigin: event.filter.countryOfOrigin,
        category: event.filter.category,
        availableToday: event.filter.availableToday,
        minRating: event.filter.minRating,
        searchQuery: event.filter.searchQuery,
      );
      emit(ExploreLoaded(dishes: dishes, filter: event.filter));
    } catch (e) {
      emit(ExploreError('Impossible de charger les plats : $e'));
    }
  }

  Future<void> _onUpdateFilter(
    UpdateFilter event,
    Emitter<ExploreState> emit,
  ) async {
    final current = state is ExploreLoaded ? state as ExploreLoaded : null;
    emit(const ExploreLoading());
    try {
      final dishes = await _dishRepository.fetchActiveDishes(
        countryOfOrigin: event.filter.countryOfOrigin,
        category: event.filter.category,
        availableToday: event.filter.availableToday,
        minRating: event.filter.minRating,
        searchQuery: event.filter.searchQuery,
      );
      emit(ExploreLoaded(
        dishes: dishes,
        filter: event.filter,
        isGridView: current?.isGridView ?? false,
      ));
    } catch (e) {
      emit(ExploreError('Erreur lors du filtrage : $e'));
    }
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<ExploreState> emit) {
    if (state is ExploreLoaded) {
      final current = state as ExploreLoaded;
      emit(current.copyWith(isGridView: !current.isGridView));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<ExploreState> emit,
  ) async {
    add(const LoadDishes());
  }
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dish_repository.dart';
import 'dish_action_message.dart';
import 'dish_event.dart';
import 'dish_state.dart';

class DishBloc extends Bloc<DishEvent, DishState> {
  final DishRepository _repository;
  StreamSubscription? _dishesSubscription;

  final _actionController = StreamController<DishActionMessage>.broadcast();
  Stream<DishActionMessage> get actionMessages => _actionController.stream;

  DishBloc(this._repository) : super(const DishInitial()) {
    on<LoadVendorDishes>(_onLoadVendorDishes);
    on<CreateDish>(_onCreateDish);
    on<UpdateDish>(_onUpdateDish);
    on<DeleteDish>(_onDeleteDish);
    on<ToggleDishActive>(_onToggleDishActive);
    on<DishesUpdated>(_onDishesUpdated);
    on<DishesStreamFailed>(_onDishesStreamFailed);
  }

  void _onLoadVendorDishes(LoadVendorDishes event, Emitter<DishState> emit) {
    emit(const DishLoading());
    _dishesSubscription?.cancel();
    _dishesSubscription = _repository
        .watchVendorDishes(event.vendorId)
        .listen(
          (dishes) => add(DishesUpdated(dishes)),
          onError: (e) => add(DishesStreamFailed(e.toString())),
        );
  }

  void _onDishesUpdated(DishesUpdated event, Emitter<DishState> emit) {
    emit(DishLoaded(event.dishes));
  }

  void _onDishesStreamFailed(DishesStreamFailed event, Emitter<DishState> emit) {
    emit(DishError('Lecture impossible : ${event.message}'));
  }

  Future<void> _onCreateDish(CreateDish event, Emitter<DishState> emit) async {
    try {
      await _repository.createDish(event.dish);
      _actionController.add(
        const DishActionMessage('Plat créé', DishActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        DishActionMessage('Erreur lors de la création : $e', DishActionResult.error),
      );
    }
  }

  Future<void> _onUpdateDish(UpdateDish event, Emitter<DishState> emit) async {
    try {
      await _repository.updateDish(event.dish);
      _actionController.add(
        const DishActionMessage('Plat mis à jour', DishActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        DishActionMessage('Erreur lors de la mise à jour : $e', DishActionResult.error),
      );
    }
  }

  Future<void> _onDeleteDish(DeleteDish event, Emitter<DishState> emit) async {
    try {
      await _repository.deleteDish(event.dishId);
      _actionController.add(
        const DishActionMessage('Plat supprimé', DishActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        DishActionMessage('Erreur lors de la suppression : $e', DishActionResult.error),
      );
    }
  }

  Future<void> _onToggleDishActive(
    ToggleDishActive event,
    Emitter<DishState> emit,
  ) async {
    try {
      await _repository.toggleDishActive(event.dishId, isActive: event.isActive);
    } catch (e) {
      _actionController.add(
        DishActionMessage('Erreur : $e', DishActionResult.error),
      );
    }
  }

  @override
  Future<void> close() {
    _dishesSubscription?.cancel();
    _actionController.close();
    return super.close();
  }
}

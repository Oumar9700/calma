import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/preorder_slot.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_action_message.dart';
import 'vendor_order_event.dart';
import 'vendor_order_state.dart';

class VendorOrderBloc extends Bloc<VendorOrderEvent, VendorOrderState> {
  final OrderRepository _repository;

  StreamSubscription? _ordersSubscription;
  StreamSubscription? _slotsSubscription;

  List<Order> _orders = [];
  List<PreorderSlot> _slots = [];

  final _actionController = StreamController<OrderActionMessage>.broadcast();
  Stream<OrderActionMessage> get actionMessages => _actionController.stream;

  VendorOrderBloc(this._repository) : super(const VendorOrderInitial()) {
    on<LoadVendorOrders>(_onLoadVendorOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<CreatePreorderSlot>(_onCreatePreorderSlot);
    on<ToggleSlotActive>(_onToggleSlotActive);
    on<LoadVendorSlots>(_onLoadVendorSlots);
    on<VendorOrdersUpdatedInternal>(_onVendorOrdersUpdated);
    on<VendorOrdersStreamFailedInternal>(_onVendorOrdersStreamFailed);
    on<VendorSlotsUpdatedInternal>(_onVendorSlotsUpdated);
    on<VendorSlotsStreamFailedInternal>(_onVendorSlotsStreamFailed);
  }

  void _onLoadVendorOrders(
      LoadVendorOrders event, Emitter<VendorOrderState> emit) {
    emit(const VendorOrderLoading());
    _orders = [];
    _slots = [];

    _ordersSubscription?.cancel();
    _ordersSubscription = _repository
        .watchVendorOrders(event.vendorId)
        .listen(
          (orders) => add(VendorOrdersUpdatedInternal(orders)),
          onError: (e) => add(VendorOrdersStreamFailedInternal(e.toString())),
        );

    _slotsSubscription?.cancel();
    _slotsSubscription = _repository
        .watchVendorSlots(event.vendorId)
        .listen(
          (slots) => add(VendorSlotsUpdatedInternal(slots)),
          onError: (e) => add(VendorSlotsStreamFailedInternal(e.toString())),
        );
  }

  void _onVendorOrdersUpdated(
      VendorOrdersUpdatedInternal event, Emitter<VendorOrderState> emit) {
    _orders = event.orders;
    emit(VendorOrderLoaded(orders: _orders, slots: _slots));
  }

  void _onVendorOrdersStreamFailed(
      VendorOrdersStreamFailedInternal event, Emitter<VendorOrderState> emit) {
    emit(VendorOrderError('Lecture commandes impossible : ${event.message}'));
  }

  void _onVendorSlotsUpdated(
      VendorSlotsUpdatedInternal event, Emitter<VendorOrderState> emit) {
    _slots = event.slots;
    emit(VendorOrderLoaded(orders: _orders, slots: _slots));
  }

  void _onVendorSlotsStreamFailed(
      VendorSlotsStreamFailedInternal event, Emitter<VendorOrderState> emit) {
    emit(VendorOrderError('Lecture planning impossible : ${event.message}'));
  }

  void _onLoadVendorSlots(
      LoadVendorSlots event, Emitter<VendorOrderState> emit) {
    _slotsSubscription?.cancel();
    _slotsSubscription = _repository
        .watchVendorSlots(event.vendorId)
        .listen(
          (slots) => add(VendorSlotsUpdatedInternal(slots)),
          onError: (e) => add(VendorSlotsStreamFailedInternal(e.toString())),
        );
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<VendorOrderState> emit) async {
    try {
      await _repository.updateOrderStatus(event.orderId, event.status,
          note: event.note);
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur mise à jour statut : $e', OrderActionResult.error),
      );
    }
  }

  Future<void> _onCreatePreorderSlot(
      CreatePreorderSlot event, Emitter<VendorOrderState> emit) async {
    try {
      await _repository.createPreorderSlot(event.slot);
      _actionController.add(
        const OrderActionMessage('Slot créé', OrderActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur création slot : $e', OrderActionResult.error),
      );
    }
  }

  Future<void> _onToggleSlotActive(
      ToggleSlotActive event, Emitter<VendorOrderState> emit) async {
    try {
      await _repository.toggleSlotActive(event.slotId,
          isActive: event.isActive);
    } catch (e) {
      _actionController.add(
        OrderActionMessage('Erreur : $e', OrderActionResult.error),
      );
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _slotsSubscription?.cancel();
    _actionController.close();
    return super.close();
  }
}

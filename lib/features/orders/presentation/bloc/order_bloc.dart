import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_action_message.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;
  StreamSubscription? _ordersSubscription;

  final _actionController = StreamController<OrderActionMessage>.broadcast();
  Stream<OrderActionMessage> get actionMessages => _actionController.stream;

  // Expose created order id after CreateOrder
  String? lastCreatedOrderId;

  OrderBloc(this._repository) : super(const OrderInitial()) {
    on<LoadBuyerOrders>(_onLoadBuyerOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UploadPaymentCapture>(_onUploadPaymentCapture);
    on<CancelOrder>(_onCancelOrder);
    on<ReportProblem>(_onReportProblem);
    on<BuyerOrdersUpdated>(_onOrdersUpdated);
    on<BuyerOrdersStreamFailed>(_onOrdersStreamFailed);
  }

  void _onLoadBuyerOrders(LoadBuyerOrders event, Emitter<OrderState> emit) {
    emit(const OrderLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository
        .watchBuyerOrders(event.buyerId)
        .listen(
          (orders) => add(BuyerOrdersUpdated(orders)),
          onError: (e) => add(BuyerOrdersStreamFailed(e.toString())),
        );
  }

  void _onOrdersUpdated(BuyerOrdersUpdated event, Emitter<OrderState> emit) {
    emit(OrderLoaded(event.orders));
  }

  void _onOrdersStreamFailed(
      BuyerOrdersStreamFailed event, Emitter<OrderState> emit) {
    emit(OrderError('Lecture impossible : ${event.message}'));
  }

  Future<void> _onCreateOrder(
      CreateOrder event, Emitter<OrderState> emit) async {
    try {
      final id = await _repository.createOrder(event.order);
      lastCreatedOrderId = id;
      _actionController.add(
        const OrderActionMessage('Commande envoyée', OrderActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur lors de la commande : $e', OrderActionResult.error),
      );
    }
  }

  Future<void> _onUploadPaymentCapture(
      UploadPaymentCapture event, Emitter<OrderState> emit) async {
    try {
      await _repository.uploadPaymentCapture(event.orderId, event.filePath);
      _actionController.add(
        const OrderActionMessage(
            'Capture envoyée', OrderActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur lors de l\'envoi : $e', OrderActionResult.error),
      );
    }
  }

  Future<void> _onCancelOrder(
      CancelOrder event, Emitter<OrderState> emit) async {
    try {
      await _repository.cancelOrder(event.orderId, isLate: event.isLate);
      _actionController.add(
        const OrderActionMessage('Commande annulée', OrderActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur lors de l\'annulation : $e', OrderActionResult.error),
      );
    }
  }

  Future<void> _onReportProblem(
      ReportProblem event, Emitter<OrderState> emit) async {
    try {
      await _repository.reportProblem(event.orderId, event.description);
      _actionController.add(
        const OrderActionMessage('Problème signalé', OrderActionResult.success),
      );
    } catch (e) {
      _actionController.add(
        OrderActionMessage(
            'Erreur lors du signalement : $e', OrderActionResult.error),
      );
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _actionController.close();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadBuyerOrders extends OrderEvent {
  final String buyerId;
  const LoadBuyerOrders(this.buyerId);
  @override
  List<Object?> get props => [buyerId];
}

class CreateOrder extends OrderEvent {
  final Order order;
  const CreateOrder(this.order);
  @override
  List<Object?> get props => [order];
}

class UploadPaymentCapture extends OrderEvent {
  final String orderId;
  final String filePath;
  const UploadPaymentCapture(this.orderId, this.filePath);
  @override
  List<Object?> get props => [orderId, filePath];
}

class CancelOrder extends OrderEvent {
  final String orderId;
  final bool isLate;
  const CancelOrder(this.orderId, {this.isLate = false});
  @override
  List<Object?> get props => [orderId, isLate];
}

class ReportProblem extends OrderEvent {
  final String orderId;
  final String description;
  const ReportProblem(this.orderId, this.description);
  @override
  List<Object?> get props => [orderId, description];
}

// Internal stream update events (non-private so BLoC can register handlers)
class BuyerOrdersUpdated extends OrderEvent {
  final List<Order> orders;
  const BuyerOrdersUpdated(this.orders);
  @override
  List<Object?> get props => [orders];
}

class BuyerOrdersStreamFailed extends OrderEvent {
  final String message;
  const BuyerOrdersStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

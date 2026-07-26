import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/preorder_slot.dart';

abstract class VendorOrderState extends Equatable {
  const VendorOrderState();
  @override
  List<Object?> get props => [];
}

class VendorOrderInitial extends VendorOrderState {
  const VendorOrderInitial();
}

class VendorOrderLoading extends VendorOrderState {
  const VendorOrderLoading();
}

class VendorOrderLoaded extends VendorOrderState {
  final List<Order> orders;
  final List<PreorderSlot> slots;
  const VendorOrderLoaded({required this.orders, required this.slots});
  @override
  List<Object?> get props => [orders, slots];
}

class VendorOrderError extends VendorOrderState {
  final String message;
  const VendorOrderError(this.message);
  @override
  List<Object?> get props => [message];
}

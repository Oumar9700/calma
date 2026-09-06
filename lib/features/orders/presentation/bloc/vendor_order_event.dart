import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/preorder_slot.dart';

abstract class VendorOrderEvent extends Equatable {
  const VendorOrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorOrders extends VendorOrderEvent {
  final String vendorId;
  const LoadVendorOrders(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

class UpdateOrderStatus extends VendorOrderEvent {
  final String orderId;
  final OrderStatus status;
  final String? note;
  final String? confirmationCode;
  const UpdateOrderStatus(this.orderId, this.status,
      {this.note, this.confirmationCode});
  @override
  List<Object?> get props => [orderId, status, note, confirmationCode];
}

class CreatePreorderSlot extends VendorOrderEvent {
  final PreorderSlot slot;
  const CreatePreorderSlot(this.slot);
  @override
  List<Object?> get props => [slot];
}

class ToggleSlotActive extends VendorOrderEvent {
  final String slotId;
  final bool isActive;
  const ToggleSlotActive(this.slotId, {required this.isActive});
  @override
  List<Object?> get props => [slotId, isActive];
}

class BulkAcceptPreorderGroup extends VendorOrderEvent {
  final List<String> orderIds;
  const BulkAcceptPreorderGroup(this.orderIds);
  @override
  List<Object?> get props => [orderIds];
}

class DeactivateSlotWithCancellations extends VendorOrderEvent {
  final String slotId;
  final List<String> orderIds;
  const DeactivateSlotWithCancellations(this.slotId, this.orderIds);
  @override
  List<Object?> get props => [slotId, orderIds];
}

class LoadVendorSlots extends VendorOrderEvent {
  final String vendorId;
  const LoadVendorSlots(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

// Internal stream update events (non-private so VendorOrderBloc can register handlers)
class VendorOrdersUpdatedInternal extends VendorOrderEvent {
  final List<Order> orders;
  const VendorOrdersUpdatedInternal(this.orders);
  @override
  List<Object?> get props => [orders];
}

class VendorOrdersStreamFailedInternal extends VendorOrderEvent {
  final String message;
  const VendorOrdersStreamFailedInternal(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorSlotsUpdatedInternal extends VendorOrderEvent {
  final List<PreorderSlot> slots;
  const VendorSlotsUpdatedInternal(this.slots);
  @override
  List<Object?> get props => [slots];
}

class VendorSlotsStreamFailedInternal extends VendorOrderEvent {
  final String message;
  const VendorSlotsStreamFailedInternal(this.message);
  @override
  List<Object?> get props => [message];
}

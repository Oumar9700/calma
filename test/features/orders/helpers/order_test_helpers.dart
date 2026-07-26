import 'package:bloc_test/bloc_test.dart';
import 'package:calma/features/orders/domain/entities/order.dart';
import 'package:calma/features/orders/domain/entities/order_status.dart';
import 'package:calma/features/orders/domain/entities/order_type.dart';
import 'package:calma/features/orders/domain/entities/preorder_slot.dart';
import 'package:calma/features/orders/domain/repositories/order_repository.dart';
import 'package:calma/features/orders/presentation/bloc/order_bloc.dart';
import 'package:calma/features/orders/presentation/bloc/order_event.dart';
import 'package:calma/features/orders/presentation/bloc/order_state.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_bloc.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_event.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_state.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockOrderRepository extends Mock implements OrderRepository {}

class MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

class MockVendorOrderBloc extends MockBloc<VendorOrderEvent, VendorOrderState>
    implements VendorOrderBloc {}

// ── Fakes ─────────────────────────────────────────────────────────────────

class FakeOrderEvent extends Fake implements OrderEvent {}

class FakeOrderState extends Fake implements OrderState {}

class FakeVendorOrderEvent extends Fake implements VendorOrderEvent {}

class FakeVendorOrderState extends Fake implements VendorOrderState {}

// ── Factories ─────────────────────────────────────────────────────────────

Order makeOrder({
  String id = 'order-001',
  String buyerId = 'buyer-uid-123',
  String vendorId = 'vendor-uid-123',
  String dishId = 'dish-001',
  String dishName = 'Foufou de manioc',
  double dishPrice = 5.0,
  int quantity = 2,
  OrderStatus status = OrderStatus.pending,
  OrderType type = OrderType.direct,
}) {
  final now = DateTime(2024, 6, 1);
  return Order(
    id: id,
    buyerId: buyerId,
    vendorId: vendorId,
    dishId: dishId,
    dishName: dishName,
    dishPrice: dishPrice,
    quantity: quantity,
    status: status,
    type: type,
    createdAt: now,
    updatedAt: now,
  );
}

PreorderSlot makeSlot({
  String id = 'slot-001',
  String vendorId = 'vendor-uid-123',
  String dishId = 'dish-001',
  String dishName = 'Foufou de manioc',
  double price = 5.0,
  int maxQuantity = 10,
  int bookedQuantity = 0,
  bool isActive = true,
}) {
  return PreorderSlot(
    id: id,
    vendorId: vendorId,
    dishId: dishId,
    dishName: dishName,
    price: price,
    date: DateTime(2024, 7, 1),
    maxQuantity: maxQuantity,
    bookedQuantity: bookedQuantity,
    isActive: isActive,
  );
}

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/preorder_slot.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/firestore_order_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreOrderDataSource _datasource;

  OrderRepositoryImpl(this._datasource);

  @override
  Future<String> createOrder(Order order) => _datasource.createOrder(order);

  @override
  Future<void> cancelOrder(String orderId, {bool isLate = false}) =>
      _datasource.cancelOrder(orderId, isLate: isLate);

  @override
  Future<void> uploadPaymentCapture(String orderId, String localFilePath) =>
      _datasource.uploadPaymentCapture(orderId, localFilePath);

  @override
  Stream<List<Order>> watchBuyerOrders(String buyerId) =>
      _datasource.watchBuyerOrders(buyerId);

  @override
  Future<Order?> getOrder(String orderId) => _datasource.getOrder(orderId);

  @override
  Future<void> reportProblem(String orderId, String description) =>
      _datasource.reportProblem(orderId, description);

  @override
  Stream<List<Order>> watchVendorOrders(String vendorId) =>
      _datasource.watchVendorOrders(vendorId);

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? note,
  }) =>
      _datasource.updateOrderStatus(orderId, newStatus, note: note);

  @override
  Future<String> createPreorderSlot(PreorderSlot slot) =>
      _datasource.createPreorderSlot(slot);

  @override
  Future<void> toggleSlotActive(String slotId, {required bool isActive}) =>
      _datasource.toggleSlotActive(slotId, isActive: isActive);

  @override
  Stream<List<PreorderSlot>> watchVendorSlots(String vendorId) =>
      _datasource.watchVendorSlots(vendorId);

  @override
  Future<List<PreorderSlot>> fetchAvailableSlots(String dishId) =>
      _datasource.fetchAvailableSlots(dishId);
}

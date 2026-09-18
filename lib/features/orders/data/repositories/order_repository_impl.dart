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
  Stream<Order?> watchOrder(String orderId) =>
      _datasource.watchOrder(orderId);

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
    String? confirmationCode,
  }) =>
      _datasource.updateOrderStatus(orderId, newStatus,
          note: note, confirmationCode: confirmationCode);

  @override
  Future<void> bulkAcceptGroup(List<String> orderIds, String dishId, DateTime date) =>
      _datasource.bulkAcceptGroup(orderIds, dishId, date);

  @override
  Future<void> bulkRejectGroup(List<String> orderIds, String dishId, DateTime date) =>
      _datasource.bulkRejectGroup(orderIds, dishId, date);

  @override
  Future<int> countPreordersForDate(String dishId, DateTime date) =>
      _datasource.countPreordersForDate(dishId, date);

  @override
  Future<String> createPreorderSlot(PreorderSlot slot) =>
      _datasource.createPreorderSlot(slot);

  @override
  Future<void> toggleSlotActive(String slotId, {required bool isActive}) =>
      _datasource.toggleSlotActive(slotId, isActive: isActive);

  @override
  Future<void> deactivateSlotWithCancellations(String slotId, List<String> orderIds) =>
      _datasource.deactivateSlotWithCancellations(slotId, orderIds);

  @override
  Stream<List<PreorderSlot>> watchVendorSlots(String vendorId) =>
      _datasource.watchVendorSlots(vendorId);

  @override
  Future<List<PreorderSlot>> fetchAvailableSlots(String dishId) =>
      _datasource.fetchAvailableSlots(dishId);
}

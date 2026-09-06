import '../entities/order.dart';
import '../entities/order_status.dart';
import '../entities/preorder_slot.dart';

abstract class OrderRepository {
  // ── Buyer ────────────────────────────────────────────────────────────────
  Future<String> createOrder(Order order);
  Future<void> cancelOrder(String orderId, {bool isLate = false});
  Future<void> uploadPaymentCapture(String orderId, String localFilePath);
  Stream<List<Order>> watchBuyerOrders(String buyerId);
  Stream<Order?> watchOrder(String orderId);
  Future<Order?> getOrder(String orderId);
  Future<void> reportProblem(String orderId, String description);

  // ── Vendor ───────────────────────────────────────────────────────────────
  Stream<List<Order>> watchVendorOrders(String vendorId);
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? note,
    String? confirmationCode,
  });

  // ── Preorder slots (vendor) ───────────────────────────────────────────────
  Future<int> countPreordersForDate(String dishId, DateTime date);
  Future<String> createPreorderSlot(PreorderSlot slot);
  Future<void> toggleSlotActive(String slotId, {required bool isActive});
  Future<void> deactivateSlotWithCancellations(String slotId, List<String> orderIds);
  Stream<List<PreorderSlot>> watchVendorSlots(String vendorId);
  Future<List<PreorderSlot>> fetchAvailableSlots(String dishId);
}

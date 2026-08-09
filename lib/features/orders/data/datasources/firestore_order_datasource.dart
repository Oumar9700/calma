import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../../../shared/services/storage_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/entities/preorder_slot.dart';

class FirestoreOrderDataSource {
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  FirestoreOrderDataSource(this._firestore, this._storage);

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _slots =>
      _firestore.collection('preorder_slots');

  // ── Buyer ────────────────────────────────────────────────────────────────

  Future<String> createOrder(Order order) async {
    if (order.slotId == null) {
      final ref = await _orders.add(_orderToMap(order));
      return ref.id;
    }
    // Créneau : transaction atomique pour vérifier le quota et incrémenter
    final slotRef = _slots.doc(order.slotId);
    String orderId = '';
    await _firestore.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) throw Exception('Créneau introuvable');
      final data = slotSnap.data()!;
      final booked = data['bookedQuantity'] as int? ?? 0;
      final max = data['maxQuantity'] as int? ?? 0;
      if (booked >= max) throw Exception('Ce créneau est complet');
      final orderRef = _orders.doc();
      orderId = orderRef.id;
      tx.set(orderRef, _orderToMap(order));
      tx.update(slotRef, {'bookedQuantity': FieldValue.increment(1)});
    });
    return orderId;
  }

  Future<void> cancelOrder(String orderId, {bool isLate = false}) async {
    final snap = await _orders.doc(orderId).get();
    final data = snap.data();
    final batch = _firestore.batch();

    batch.update(_orders.doc(orderId), {
      'status': OrderStatus.cancelled.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      if (isLate) 'isLateCancellation': true,
    });

    // Décrémente le bookedQuantity si liée à un créneau
    final slotId = data?['slotId'] as String?;
    if (slotId != null) {
      batch.update(_slots.doc(slotId), {
        'bookedQuantity': FieldValue.increment(-1),
      });
    }

    if (isLate) {
      final buyerId = data?['buyerId'] as String?;
      if (buyerId != null) {
        batch.update(_firestore.collection('users').doc(buyerId), {
          'lateCancellationCount': FieldValue.increment(1),
        });
      }
    }

    await batch.commit();
  }

  Future<void> uploadPaymentCapture(
      String orderId, String localFilePath) async {
    final file = File(localFilePath);
    final url = await _storage.uploadOrderCapture(orderId, file);

    await _orders.doc(orderId).update({
      'paymentCaptureUrl': url,
      'status': OrderStatus.awaitingConfirmation.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<Order>> watchBuyerOrders(String buyerId) {
    return _orders
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  Stream<Order?> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map(
          (doc) => doc.exists ? _orderFromDoc(doc) : null,
        );
  }

  Future<Order?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return _orderFromDoc(doc);
  }

  Future<void> reportProblem(String orderId, String description) async {
    final snap = await _orders.doc(orderId).get();
    final data = snap.data();
    await _firestore.collection('order_reports').add({
      'orderId': orderId,
      'buyerId': data?['buyerId'],
      'vendorId': data?['vendorId'],
      'description': description,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Vendor ───────────────────────────────────────────────────────────────

  Stream<List<Order>> watchVendorOrders(String vendorId) {
    return _orders
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList());
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? note,
  }) async {
    final data = <String, dynamic>{
      'status': newStatus.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (note != null) data['vendorNote'] = note;
    await _orders.doc(orderId).update(data);
  }

  // ── Preorder slots ────────────────────────────────────────────────────────

  Future<String> createPreorderSlot(PreorderSlot slot) async {
    final ref = await _slots.add(_slotToMap(slot));
    return ref.id;
  }

  Future<void> toggleSlotActive(String slotId, {required bool isActive}) async {
    await _slots.doc(slotId).update({'isActive': isActive});
  }

  Stream<List<PreorderSlot>> watchVendorSlots(String vendorId) {
    return _slots
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_slotFromDoc).toList());
  }

  Future<List<PreorderSlot>> fetchAvailableSlots(String dishId) async {
    final snap = await _slots
        .where('dishId', isEqualTo: dishId)
        .where('isActive', isEqualTo: true)
        .get();
    final slots = snap.docs.map(_slotFromDoc).toList();
    return slots.where((s) => !s.isFull && s.date.isAfter(DateTime.now())).toList();
  }

  // ── Mappers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _orderToMap(Order o) => {
        'buyerId': o.buyerId,
        'vendorId': o.vendorId,
        'dishId': o.dishId,
        'dishName': o.dishName,
        'dishPrice': o.dishPrice,
        'dishPhotoUrl': o.dishPhotoUrl,
        'quantity': o.quantity,
        'note': o.note,
        'status': o.status.name,
        'type': o.type.name,
        'createdAt': Timestamp.fromDate(o.createdAt),
        'updatedAt': Timestamp.fromDate(o.updatedAt),
        'preorderDate':
            o.preorderDate != null ? Timestamp.fromDate(o.preorderDate!) : null,
        'slotId': o.slotId,
        'paymentCaptureUrl': o.paymentCaptureUrl,
        'vendorNote': o.vendorNote,
        'lateCancellationCount': o.lateCancellationCount,
      };

  Order _orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Order(
      id: doc.id,
      buyerId: d['buyerId'] as String,
      vendorId: d['vendorId'] as String,
      dishId: d['dishId'] as String,
      dishName: d['dishName'] as String,
      dishPrice: (d['dishPrice'] as num).toDouble(),
      dishPhotoUrl: d['dishPhotoUrl'] as String?,
      quantity: d['quantity'] as int,
      note: d['note'] as String?,
      status: OrderStatusExtension.fromString(d['status'] as String? ?? 'pending'),
      type: OrderTypeExtension.fromString(d['type'] as String? ?? 'direct'),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
      preorderDate: d['preorderDate'] != null
          ? (d['preorderDate'] as Timestamp).toDate()
          : null,
      slotId: d['slotId'] as String?,
      paymentCaptureUrl: d['paymentCaptureUrl'] as String?,
      vendorNote: d['vendorNote'] as String?,
      lateCancellationCount: d['lateCancellationCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _slotToMap(PreorderSlot s) => {
        'vendorId': s.vendorId,
        'dishId': s.dishId,
        'dishName': s.dishName,
        'dishPhotoUrl': s.dishPhotoUrl,
        'price': s.price,
        'date': Timestamp.fromDate(s.date),
        'maxQuantity': s.maxQuantity,
        'bookedQuantity': s.bookedQuantity,
        'isActive': s.isActive,
      };

  PreorderSlot _slotFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PreorderSlot(
      id: doc.id,
      vendorId: d['vendorId'] as String,
      dishId: d['dishId'] as String,
      dishName: d['dishName'] as String,
      dishPhotoUrl: d['dishPhotoUrl'] as String?,
      price: (d['price'] as num).toDouble(),
      date: (d['date'] as Timestamp).toDate(),
      maxQuantity: d['maxQuantity'] as int,
      bookedQuantity: d['bookedQuantity'] as int? ?? 0,
      isActive: d['isActive'] as bool? ?? true,
    );
  }
}

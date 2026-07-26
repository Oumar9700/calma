import 'package:equatable/equatable.dart';
import 'order_status.dart';
import 'order_type.dart';

class Order extends Equatable {
  final String id;
  final String buyerId;
  final String vendorId;
  final String dishId;
  final String dishName;
  final double dishPrice;
  final String? dishPhotoUrl;
  final int quantity;
  final String? note;
  final OrderStatus status;
  final OrderType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? preorderDate;
  final String? slotId;
  final String? paymentCaptureUrl;
  final String? vendorNote;
  final int lateCancellationCount;

  const Order({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.dishId,
    required this.dishName,
    required this.dishPrice,
    this.dishPhotoUrl,
    required this.quantity,
    this.note,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.preorderDate,
    this.slotId,
    this.paymentCaptureUrl,
    this.vendorNote,
    this.lateCancellationCount = 0,
  });

  double get totalPrice => dishPrice * quantity;

  Order copyWith({
    String? id,
    String? buyerId,
    String? vendorId,
    String? dishId,
    String? dishName,
    double? dishPrice,
    String? dishPhotoUrl,
    int? quantity,
    String? note,
    OrderStatus? status,
    OrderType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? preorderDate,
    String? slotId,
    String? paymentCaptureUrl,
    String? vendorNote,
    int? lateCancellationCount,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      vendorId: vendorId ?? this.vendorId,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      dishPrice: dishPrice ?? this.dishPrice,
      dishPhotoUrl: dishPhotoUrl ?? this.dishPhotoUrl,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preorderDate: preorderDate ?? this.preorderDate,
      slotId: slotId ?? this.slotId,
      paymentCaptureUrl: paymentCaptureUrl ?? this.paymentCaptureUrl,
      vendorNote: vendorNote ?? this.vendorNote,
      lateCancellationCount:
          lateCancellationCount ?? this.lateCancellationCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        buyerId,
        vendorId,
        dishId,
        dishName,
        dishPrice,
        dishPhotoUrl,
        quantity,
        note,
        status,
        type,
        createdAt,
        updatedAt,
        preorderDate,
        slotId,
        paymentCaptureUrl,
        vendorNote,
        lateCancellationCount,
      ];
}

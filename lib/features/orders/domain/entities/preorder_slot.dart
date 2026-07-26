import 'package:equatable/equatable.dart';

class PreorderSlot extends Equatable {
  final String id;
  final String vendorId;
  final String dishId;
  final String dishName;
  final String? dishPhotoUrl;
  final double price;
  final DateTime date;
  final int maxQuantity;
  final int bookedQuantity;
  final bool isActive;

  const PreorderSlot({
    required this.id,
    required this.vendorId,
    required this.dishId,
    required this.dishName,
    this.dishPhotoUrl,
    required this.price,
    required this.date,
    required this.maxQuantity,
    required this.bookedQuantity,
    required this.isActive,
  });

  int get availableQuantity => maxQuantity - bookedQuantity;

  bool get isFull => availableQuantity <= 0;

  PreorderSlot copyWith({
    String? id,
    String? vendorId,
    String? dishId,
    String? dishName,
    String? dishPhotoUrl,
    double? price,
    DateTime? date,
    int? maxQuantity,
    int? bookedQuantity,
    bool? isActive,
  }) {
    return PreorderSlot(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      dishPhotoUrl: dishPhotoUrl ?? this.dishPhotoUrl,
      price: price ?? this.price,
      date: date ?? this.date,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      bookedQuantity: bookedQuantity ?? this.bookedQuantity,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vendorId,
        dishId,
        dishName,
        dishPhotoUrl,
        price,
        date,
        maxQuantity,
        bookedQuantity,
        isActive,
      ];
}

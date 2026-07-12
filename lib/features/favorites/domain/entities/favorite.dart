import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final String? dishId;
  final String? vendorId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    this.dishId,
    this.vendorId,
    required this.createdAt,
  });

  bool get isDish => dishId != null;
  bool get isVendor => vendorId != null && dishId == null;

  @override
  List<Object?> get props => [id, userId, dishId, vendorId, createdAt];
}

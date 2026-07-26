import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  completed,
  cancelled,
  rejected,
  awaitingCapture,
  awaitingConfirmation,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.accepted:
        return 'Acceptée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.completed:
        return 'Terminée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.rejected:
        return 'Refusée';
      case OrderStatus.awaitingCapture:
        return 'Capture requise';
      case OrderStatus.awaitingConfirmation:
        return 'Confirmation en attente';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF97316);
      case OrderStatus.accepted:
        return const Color(0xFF3B82F6);
      case OrderStatus.preparing:
        return const Color(0xFFF59E0B);
      case OrderStatus.ready:
        return const Color(0xFF22C55E);
      case OrderStatus.completed:
        return const Color(0xFF9CA3AF);
      case OrderStatus.cancelled:
        return const Color(0xFF9CA3AF);
      case OrderStatus.rejected:
        return const Color(0xFFEF4444);
      case OrderStatus.awaitingCapture:
        return const Color(0xFFF97316);
      case OrderStatus.awaitingConfirmation:
        return const Color(0xFF3B82F6);
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

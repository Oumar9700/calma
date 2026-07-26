import 'package:calma/features/orders/domain/entities/order.dart';
import 'package:calma/features/orders/domain/entities/order_status.dart';
import 'package:calma/features/orders/domain/entities/order_type.dart';
import 'package:calma/features/orders/domain/entities/preorder_slot.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order({
  OrderStatus status = OrderStatus.pending,
  OrderType type = OrderType.direct,
  double price = 5.0,
  int qty = 2,
}) {
  final now = DateTime(2024, 6, 1);
  return Order(
    id: 'o1',
    buyerId: 'buyer',
    vendorId: 'vendor',
    dishId: 'd1',
    dishName: 'Foufou',
    dishPrice: price,
    quantity: qty,
    status: status,
    type: type,
    createdAt: now,
    updatedAt: now,
  );
}

PreorderSlot _slot({int max = 10, int booked = 0, bool active = true}) {
  return PreorderSlot(
    id: 's1',
    vendorId: 'vendor',
    dishId: 'd1',
    dishName: 'Foufou',
    price: 5.0,
    date: DateTime(2024, 7, 1),
    maxQuantity: max,
    bookedQuantity: booked,
    isActive: active,
  );
}

void main() {
  // ════════════════════════════════════════════════════════════════════════
  // Order entity
  // ════════════════════════════════════════════════════════════════════════

  group('Order.totalPrice', () {
    test('calcule prix × quantité', () {
      expect(_order(price: 5.0, qty: 3).totalPrice, 15.0);
    });

    test('quantité 1 → prix unitaire', () {
      expect(_order(price: 7.5, qty: 1).totalPrice, 7.5);
    });
  });

  group('Order equality (Equatable)', () {
    test('même id → égaux', () {
      final a = _order();
      final b = _order();
      expect(a, equals(b));
    });

    test('ids différents → non égaux', () {
      final now = DateTime(2024, 6, 1);
      final a = Order(
        id: 'o1',
        buyerId: 'b',
        vendorId: 'v',
        dishId: 'd',
        dishName: 'n',
        dishPrice: 5,
        quantity: 1,
        status: OrderStatus.pending,
        type: OrderType.direct,
        createdAt: now,
        updatedAt: now,
      );
      final b = a.copyWith(id: 'o2');
      expect(a, isNot(equals(b)));
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // PreorderSlot entity
  // ════════════════════════════════════════════════════════════════════════

  group('PreorderSlot.availableQuantity', () {
    test('retourne max - booked', () {
      expect(_slot(max: 10, booked: 3).availableQuantity, 7);
    });

    test('plein → 0', () {
      expect(_slot(max: 5, booked: 5).availableQuantity, 0);
    });
  });

  group('PreorderSlot.isFull', () {
    test('bookedQuantity < maxQuantity → false', () {
      expect(_slot(max: 10, booked: 9).isFull, isFalse);
    });

    test('bookedQuantity == maxQuantity → true', () {
      expect(_slot(max: 5, booked: 5).isFull, isTrue);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // OrderStatus extension
  // ════════════════════════════════════════════════════════════════════════

  group('OrderStatus.label', () {
    test('pending → En attente', () {
      expect(OrderStatus.pending.label, 'En attente');
    });

    test('accepted → Acceptée', () {
      expect(OrderStatus.accepted.label, 'Acceptée');
    });

    test('preparing → En préparation', () {
      expect(OrderStatus.preparing.label, 'En préparation');
    });

    test('ready → Prête', () {
      expect(OrderStatus.ready.label, 'Prête');
    });

    test('completed → Terminée', () {
      expect(OrderStatus.completed.label, 'Terminée');
    });

    test('cancelled → Annulée', () {
      expect(OrderStatus.cancelled.label, 'Annulée');
    });

    test('rejected → Refusée', () {
      expect(OrderStatus.rejected.label, 'Refusée');
    });

    test('awaitingCapture → Capture requise', () {
      expect(OrderStatus.awaitingCapture.label, 'Capture requise');
    });

    test('awaitingConfirmation → Confirmation en attente', () {
      expect(OrderStatus.awaitingConfirmation.label, 'Confirmation en attente');
    });
  });

  group('OrderStatusExtension.fromString', () {
    test('round-trip pour tous les statuts', () {
      for (final s in OrderStatus.values) {
        expect(OrderStatusExtension.fromString(s.name), s);
      }
    });

    test('valeur inconnue → pending par défaut', () {
      expect(OrderStatusExtension.fromString('unknown_xyz'), OrderStatus.pending);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // OrderType extension
  // ════════════════════════════════════════════════════════════════════════

  group('OrderTypeExtension.fromString', () {
    test('direct → OrderType.direct', () {
      expect(OrderTypeExtension.fromString('direct'), OrderType.direct);
    });

    test('preorder → OrderType.preorder', () {
      expect(OrderTypeExtension.fromString('preorder'), OrderType.preorder);
    });

    test('valeur inconnue → direct par défaut', () {
      expect(OrderTypeExtension.fromString('xyz'), OrderType.direct);
    });
  });
}

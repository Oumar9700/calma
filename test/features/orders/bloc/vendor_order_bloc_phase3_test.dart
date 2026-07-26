// Tests Phase 3 — VendorOrderBloc, cas supplémentaires
import 'dart:async';

import 'package:calma/features/orders/domain/entities/order.dart';
import 'package:calma/features/orders/domain/entities/order_status.dart';
import 'package:calma/features/orders/domain/entities/preorder_slot.dart';
import 'package:calma/features/orders/presentation/bloc/order_action_message.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_bloc.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_event.dart';
import 'package:calma/features/orders/presentation/bloc/vendor_order_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/order_test_helpers.dart';

void main() {
  late MockOrderRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeVendorOrderEvent());
    registerFallbackValue(FakeVendorOrderState());
    registerFallbackValue(makeOrder());
    registerFallbackValue(makeSlot());
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    mockRepo = MockOrderRepository();
  });

  // ════════════════════════════════════════════════════════════════════════
  // Transitions de statut métier — vendeur accepte/refuse/avance une commande
  // ════════════════════════════════════════════════════════════════════════

  group('UpdateOrderStatus — transitions métier', () {
    final transitions = [
      (OrderStatus.awaitingConfirmation, OrderStatus.accepted),
      (OrderStatus.awaitingConfirmation, OrderStatus.rejected),
      (OrderStatus.accepted, OrderStatus.preparing),
      (OrderStatus.preparing, OrderStatus.ready),
      (OrderStatus.ready, OrderStatus.completed),
    ];

    for (final (from, to) in transitions) {
      test('${from.name} → ${to.name} appelle updateOrderStatus', () async {
        when(() => mockRepo.updateOrderStatus(
              any(),
              any(),
              note: any(named: 'note'),
            )).thenAnswer((_) async {});

        final bloc = VendorOrderBloc(mockRepo);
        final sub = bloc.actionMessages.listen((_) {});

        bloc.add(UpdateOrderStatus('order-001', to));
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockRepo.updateOrderStatus('order-001', to,
            note: any(named: 'note'))).called(1);

        await sub.cancel();
        await bloc.close();
      });
    }

    test('acceptation avec note vendeur → note transmise au repository', () async {
      String? capturedNote;
      when(() => mockRepo.updateOrderStatus(
            any(),
            any(),
            note: any(named: 'note'),
          )).thenAnswer((inv) async {
        capturedNote = inv.namedArguments[#note] as String?;
      });

      final bloc = VendorOrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(const UpdateOrderStatus(
        'order-001',
        OrderStatus.accepted,
        note: 'Prêt à 12h30',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(capturedNote, 'Prêt à 12h30');

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Slots de précommande — comportement Planning
  // ════════════════════════════════════════════════════════════════════════

  group('Slots de précommande', () {
    test('ToggleSlotActive désactive un slot actif', () async {
      when(() => mockRepo.toggleSlotActive(
            any(),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async {});

      final bloc = VendorOrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(const ToggleSlotActive('slot-001', isActive: false));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.toggleSlotActive('slot-001', isActive: false))
          .called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('ToggleSlotActive réactive un slot', () async {
      when(() => mockRepo.toggleSlotActive(
            any(),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async {});

      final bloc = VendorOrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(const ToggleSlotActive('slot-002', isActive: true));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.toggleSlotActive('slot-002', isActive: true))
          .called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('ToggleSlotActive échec → actionMessages error', () async {
      when(() => mockRepo.toggleSlotActive(
            any(),
            isActive: any(named: 'isActive'),
          )).thenThrow(Exception('permission-denied'));

      final bloc = VendorOrderBloc(mockRepo);
      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const ToggleSlotActive('slot-001', isActive: false));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });

    test('CreatePreorderSlot passe les données du slot au repository', () async {
      PreorderSlot? captured;
      when(() => mockRepo.createPreorderSlot(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as PreorderSlot;
        return 'new-slot-id';
      });

      final slot = makeSlot(
        vendorId: 'vendor-abc',
        dishName: 'Attiéké poisson',
        maxQuantity: 15,
      );

      final bloc = VendorOrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(CreatePreorderSlot(slot));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(captured?.vendorId, 'vendor-abc');
      expect(captured?.dishName, 'Attiéké poisson');
      expect(captured?.maxQuantity, 15);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // État combiné orders + slots
  // ════════════════════════════════════════════════════════════════════════

  group('État combiné commandes + planning', () {
    test('orders et slots mis à jour indépendamment', () async {
      final ordersCtrl = StreamController<List<Order>>.broadcast();
      final slotsCtrl = StreamController<List<PreorderSlot>>.broadcast();

      when(() => mockRepo.watchVendorOrders(any()))
          .thenAnswer((_) => ordersCtrl.stream);
      when(() => mockRepo.watchVendorSlots(any()))
          .thenAnswer((_) => slotsCtrl.stream);

      final bloc = VendorOrderBloc(mockRepo);
      final states = <VendorOrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadVendorOrders('vendor-1'));
      await Future.delayed(const Duration(milliseconds: 20));

      ordersCtrl.add([makeOrder(id: 'o1'), makeOrder(id: 'o2')]);
      await Future.delayed(const Duration(milliseconds: 20));

      slotsCtrl.add([makeSlot(id: 's1')]);
      await Future.delayed(const Duration(milliseconds: 20));

      final final_ = states.whereType<VendorOrderLoaded>().last;
      expect(final_.orders.length, 2);
      expect(final_.slots.length, 1);

      await sub.cancel();
      await ordersCtrl.close();
      await slotsCtrl.close();
      await bloc.close();
    });

    test('VendorOrderLoaded initial a orders vide et slots vide', () async {
      final ordersCtrl = StreamController<List<Order>>.broadcast();
      final slotsCtrl = StreamController<List<PreorderSlot>>.broadcast();

      when(() => mockRepo.watchVendorOrders(any()))
          .thenAnswer((_) => ordersCtrl.stream);
      when(() => mockRepo.watchVendorSlots(any()))
          .thenAnswer((_) => slotsCtrl.stream);

      final bloc = VendorOrderBloc(mockRepo);
      final states = <VendorOrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadVendorOrders('vendor-1'));
      await Future.delayed(const Duration(milliseconds: 20));

      ordersCtrl.add([]);
      slotsCtrl.add([]);
      await Future.delayed(const Duration(milliseconds: 40));

      final loaded = states.whereType<VendorOrderLoaded>().last;
      expect(loaded.orders, isEmpty);
      expect(loaded.slots, isEmpty);

      await sub.cancel();
      await ordersCtrl.close();
      await slotsCtrl.close();
      await bloc.close();
    });

    test('rechargement (second LoadVendorOrders) repart de zéro', () async {
      final ctrl = StreamController<List<Order>>.broadcast();
      final slotsCtrl = StreamController<List<PreorderSlot>>.broadcast();

      when(() => mockRepo.watchVendorOrders(any()))
          .thenAnswer((_) => ctrl.stream);
      when(() => mockRepo.watchVendorSlots(any()))
          .thenAnswer((_) => slotsCtrl.stream);

      final bloc = VendorOrderBloc(mockRepo);
      final states = <VendorOrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadVendorOrders('vendor-1'));
      await Future.delayed(const Duration(milliseconds: 20));

      ctrl.add([makeOrder(id: 'o1'), makeOrder(id: 'o2')]);
      await Future.delayed(const Duration(milliseconds: 20));

      // Second load → VendorOrderLoading repart de zéro
      bloc.add(const LoadVendorOrders('vendor-2'));
      await Future.delayed(const Duration(milliseconds: 20));

      // On vérifie qu'un VendorOrderLoading a été émis après le second load
      final loadingStates = states.whereType<VendorOrderLoading>().toList();
      expect(loadingStates.length, greaterThanOrEqualTo(2));

      await sub.cancel();
      await ctrl.close();
      await slotsCtrl.close();
      await bloc.close();
    });
  });
}

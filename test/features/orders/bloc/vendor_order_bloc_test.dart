import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
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
  // LoadVendorOrders
  // ════════════════════════════════════════════════════════════════════════

  group('LoadVendorOrders', () {
    final order1 = makeOrder(id: 'o1');
    final slot1 = makeSlot(id: 's1');

    blocTest<VendorOrderBloc, VendorOrderState>(
      'émet VendorOrderLoading puis VendorOrderLoaded avec commandes et slots',
      build: () {
        when(() => mockRepo.watchVendorOrders('vendor-uid-123'))
            .thenAnswer((_) => Stream.value(<Order>[order1]));
        when(() => mockRepo.watchVendorSlots('vendor-uid-123'))
            .thenAnswer((_) => Stream.value(<PreorderSlot>[slot1]));
        return VendorOrderBloc(mockRepo);
      },
      act: (b) => b.add(const LoadVendorOrders('vendor-uid-123')),
      wait: const Duration(milliseconds: 100),
      // Both streams emit → VendorOrderLoading + at least 2 VendorOrderLoaded
      // (one for orders, one for slots). We verify the final loaded state.
      expect: () => [
        isA<VendorOrderLoading>(),
        isA<VendorOrderLoaded>(),
        isA<VendorOrderLoaded>().having(
          (s) => s.orders,
          'orders',
          contains(order1),
        ).having(
          (s) => s.slots,
          'slots',
          contains(slot1),
        ),
      ],
    );

    test('met à jour les commandes quand le stream orders émet', () async {
      final ordersController = StreamController<List<Order>>.broadcast();
      final slotsController = StreamController<List<PreorderSlot>>.broadcast();

      when(() => mockRepo.watchVendorOrders(any()))
          .thenAnswer((_) => ordersController.stream);
      when(() => mockRepo.watchVendorSlots(any()))
          .thenAnswer((_) => slotsController.stream);

      final bloc = VendorOrderBloc(mockRepo);
      final states = <VendorOrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadVendorOrders('vendor-uid-123'));
      await Future.delayed(const Duration(milliseconds: 30));

      ordersController.add([order1]);
      await Future.delayed(const Duration(milliseconds: 30));

      final loaded = states.whereType<VendorOrderLoaded>().last;
      expect(loaded.orders, contains(order1));

      await sub.cancel();
      await ordersController.close();
      await slotsController.close();
      await bloc.close();
    });

    blocTest<VendorOrderBloc, VendorOrderState>(
      'erreur stream orders → VendorOrderError',
      build: () {
        when(() => mockRepo.watchVendorOrders(any()))
            .thenAnswer((_) => Stream.error(Exception('permission-denied')));
        when(() => mockRepo.watchVendorSlots(any()))
            .thenAnswer((_) => const Stream.empty());
        return VendorOrderBloc(mockRepo);
      },
      act: (b) => b.add(const LoadVendorOrders('vendor-uid-123')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<VendorOrderLoading>(),
        isA<VendorOrderError>(),
      ],
    );
  });

  // ════════════════════════════════════════════════════════════════════════
  // UpdateOrderStatus
  // ════════════════════════════════════════════════════════════════════════

  group('UpdateOrderStatus', () {
    blocTest<VendorOrderBloc, VendorOrderState>(
      'succès → state inchangé (stream Firestore met à jour)',
      build: () {
        when(() => mockRepo.updateOrderStatus(
              any(),
              any(),
              note: any(named: 'note'),
            )).thenAnswer((_) async {});
        return VendorOrderBloc(mockRepo);
      },
      act: (b) => b.add(
        const UpdateOrderStatus('order-001', OrderStatus.accepted),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (_) {
        verify(() => mockRepo.updateOrderStatus(
              any(),
              any(),
              note: any(named: 'note'),
            )).called(1);
      },
    );

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.updateOrderStatus(
            any(),
            any(),
            note: any(named: 'note'),
          )).thenThrow(Exception('offline'));

      final bloc = VendorOrderBloc(mockRepo);
      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const UpdateOrderStatus('order-001', OrderStatus.accepted));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // CreatePreorderSlot
  // ════════════════════════════════════════════════════════════════════════

  group('CreatePreorderSlot', () {
    blocTest<VendorOrderBloc, VendorOrderState>(
      'succès → state inchangé, repository appelé',
      build: () {
        when(() => mockRepo.createPreorderSlot(any()))
            .thenAnswer((_) async => 'slot-001');
        return VendorOrderBloc(mockRepo);
      },
      act: (b) => b.add(CreatePreorderSlot(makeSlot())),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (_) {
        verify(() => mockRepo.createPreorderSlot(any())).called(1);
      },
    );

    test('succès → actionMessages reçoit success', () async {
      when(() => mockRepo.createPreorderSlot(any()))
          .thenAnswer((_) async => 'slot-001');
      final bloc = VendorOrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreatePreorderSlot(makeSlot()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.success);
      expect(messages.first.text, contains('Slot'));

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.createPreorderSlot(any()))
          .thenThrow(Exception('network'));
      final bloc = VendorOrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreatePreorderSlot(makeSlot()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // ToggleSlotActive
  // ════════════════════════════════════════════════════════════════════════

  group('ToggleSlotActive', () {
    blocTest<VendorOrderBloc, VendorOrderState>(
      'succès → state inchangé (stream Firestore met à jour)',
      build: () {
        when(() => mockRepo.toggleSlotActive(
              any(),
              isActive: any(named: 'isActive'),
            )).thenAnswer((_) async {});
        return VendorOrderBloc(mockRepo);
      },
      act: (b) => b.add(const ToggleSlotActive('slot-001', isActive: false)),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
    );
  });
}

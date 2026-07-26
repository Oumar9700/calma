import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:calma/features/orders/domain/entities/order.dart';
import 'package:calma/features/orders/domain/entities/order_status.dart';
import 'package:calma/features/orders/presentation/bloc/order_action_message.dart';
import 'package:calma/features/orders/presentation/bloc/order_bloc.dart';
import 'package:calma/features/orders/presentation/bloc/order_event.dart';
import 'package:calma/features/orders/presentation/bloc/order_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/order_test_helpers.dart';

void main() {
  late MockOrderRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeOrderEvent());
    registerFallbackValue(FakeOrderState());
    registerFallbackValue(makeOrder());
  });

  setUp(() {
    mockRepo = MockOrderRepository();
  });

  // ════════════════════════════════════════════════════════════════════════
  // LoadBuyerOrders
  // ════════════════════════════════════════════════════════════════════════

  group('LoadBuyerOrders', () {
    final order1 = makeOrder(id: 'o1');
    final order2 = makeOrder(id: 'o2', status: OrderStatus.accepted);

    blocTest<OrderBloc, OrderState>(
      'émet OrderLoading puis OrderLoaded quand le stream retourne des commandes',
      build: () {
        when(() => mockRepo.watchBuyerOrders('buyer-uid-123'))
            .thenAnswer((_) => Stream.value(<Order>[order1, order2]));
        return OrderBloc(mockRepo);
      },
      act: (b) => b.add(const LoadBuyerOrders('buyer-uid-123')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>().having(
          (s) => s.orders,
          'orders',
          containsAll([order1, order2]),
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'émet OrderLoaded avec liste vide quand le stream est vide',
      build: () {
        when(() => mockRepo.watchBuyerOrders(any()))
            .thenAnswer((_) => Stream.value(<Order>[]));
        return OrderBloc(mockRepo);
      },
      act: (b) => b.add(const LoadBuyerOrders('buyer-uid-123')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>().having((s) => s.orders, 'orders', isEmpty),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'erreur Firestore → OrderError avec message lisible',
      build: () {
        when(() => mockRepo.watchBuyerOrders(any()))
            .thenAnswer((_) => Stream.error(Exception('permission-denied')));
        return OrderBloc(mockRepo);
      },
      act: (b) => b.add(const LoadBuyerOrders('buyer-uid-123')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderError>().having(
          (s) => s.message,
          'message',
          contains('permission-denied'),
        ),
      ],
    );

    test(
      'met à jour dynamiquement quand le stream émet plusieurs fois',
      () async {
        final controller = StreamController<List<Order>>.broadcast();
        when(() => mockRepo.watchBuyerOrders(any()))
            .thenAnswer((_) => controller.stream);

        final bloc = OrderBloc(mockRepo);
        final states = <OrderState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadBuyerOrders('buyer-uid-123'));
        await Future.delayed(const Duration(milliseconds: 30));

        controller.add([order1]);
        await Future.delayed(const Duration(milliseconds: 30));

        controller.add([order1, order2]);
        await Future.delayed(const Duration(milliseconds: 30));

        expect(states[0], isA<OrderLoading>());
        expect((states[1] as OrderLoaded).orders.length, 1);
        expect((states[2] as OrderLoaded).orders.length, 2);

        await sub.cancel();
        await controller.close();
        await bloc.close();
      },
    );
  });

  // ════════════════════════════════════════════════════════════════════════
  // CreateOrder
  // ════════════════════════════════════════════════════════════════════════

  group('CreateOrder', () {
    blocTest<OrderBloc, OrderState>(
      'succès → state BLoC inchangé',
      build: () {
        when(() => mockRepo.createOrder(any()))
            .thenAnswer((_) async => 'order-001');
        return OrderBloc(mockRepo);
      },
      act: (b) => b.add(CreateOrder(makeOrder())),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (b) {
        verify(() => mockRepo.createOrder(any())).called(1);
      },
    );

    test('succès → actionMessages reçoit success', () async {
      when(() => mockRepo.createOrder(any()))
          .thenAnswer((_) async => 'order-001');
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreateOrder(makeOrder()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.result, OrderActionResult.success);
      expect(messages.first.text, contains('Commande'));

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.createOrder(any()))
          .thenThrow(Exception('network error'));
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreateOrder(makeOrder()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });

    test('succès → lastCreatedOrderId stocke le nouvel id', () async {
      when(() => mockRepo.createOrder(any()))
          .thenAnswer((_) async => 'new-order-id');
      final bloc = OrderBloc(mockRepo);

      final sub = bloc.actionMessages.listen((_) {});
      bloc.add(CreateOrder(makeOrder()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.lastCreatedOrderId, 'new-order-id');

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // CancelOrder
  // ════════════════════════════════════════════════════════════════════════

  group('CancelOrder', () {
    test('succès → actionMessages reçoit success', () async {
      when(() => mockRepo.cancelOrder(any(), isLate: any(named: 'isLate')))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const CancelOrder('order-001'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.success);

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.cancelOrder(any(), isLate: any(named: 'isLate')))
          .thenThrow(Exception('offline'));
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const CancelOrder('order-001'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // ReportProblem
  // ════════════════════════════════════════════════════════════════════════

  group('ReportProblem', () {
    test('succès → actionMessages reçoit success', () async {
      when(() => mockRepo.reportProblem(any(), any()))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const ReportProblem('order-001', 'Plat incorrect'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.success);
      expect(messages.first.text, contains('Problème'));

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.reportProblem(any(), any()))
          .thenThrow(Exception('network'));
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const ReportProblem('order-001', 'Plat incorrect'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Invariant
  // ════════════════════════════════════════════════════════════════════════

  test(
    'INVARIANT — CreateOrder/CancelOrder/ReportProblem ne changent jamais le state BLoC',
    () async {
      when(() => mockRepo.createOrder(any()))
          .thenAnswer((_) async => 'new-id');
      when(() => mockRepo.cancelOrder(any(), isLate: any(named: 'isLate')))
          .thenAnswer((_) async {});
      when(() => mockRepo.reportProblem(any(), any()))
          .thenAnswer((_) async {});

      final bloc = OrderBloc(mockRepo);
      final states = <OrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(CreateOrder(makeOrder()));
      bloc.add(const CancelOrder('x'));
      bloc.add(const ReportProblem('x', 'problem'));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, isEmpty,
          reason: 'Aucun de ces events ne doit changer le state BLoC');

      await sub.cancel();
      await bloc.close();
    },
  );
}

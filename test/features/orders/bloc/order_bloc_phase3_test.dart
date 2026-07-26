// Tests Phase 3 — fonctionnalités non couvertes dans order_bloc_test.dart
import 'dart:async';

import 'package:calma/features/orders/domain/entities/order.dart';
import 'package:calma/features/orders/domain/entities/order_status.dart';
import 'package:calma/features/orders/domain/entities/order_type.dart';
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
  // UploadPaymentCapture
  // ════════════════════════════════════════════════════════════════════════

  group('UploadPaymentCapture', () {
    test('succès → actionMessages reçoit success', () async {
      when(() => mockRepo.uploadPaymentCapture(any(), any()))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const UploadPaymentCapture('order-001', '/tmp/capture.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.result, OrderActionResult.success);

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit error', () async {
      when(() => mockRepo.uploadPaymentCapture(any(), any()))
          .thenThrow(Exception('storage-unavailable'));
      final bloc = OrderBloc(mockRepo);

      final messages = <OrderActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const UploadPaymentCapture('order-001', '/tmp/capture.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, OrderActionResult.error);

      await sub.cancel();
      await bloc.close();
    });

    test('UploadPaymentCapture ne modifie pas le state BLoC', () async {
      when(() => mockRepo.uploadPaymentCapture(any(), any()))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);

      final states = <OrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UploadPaymentCapture('order-001', '/path/img.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Commande directe — flux complet (create → upload)
  // ════════════════════════════════════════════════════════════════════════

  group('Flux commande directe avec capture paiement', () {
    test(
      'CreateOrder puis UploadPaymentCapture → deux success dans actionMessages',
      () async {
        when(() => mockRepo.createOrder(any()))
            .thenAnswer((_) async => 'order-001');
        when(() => mockRepo.uploadPaymentCapture('order-001', any()))
            .thenAnswer((_) async {});

        final bloc = OrderBloc(mockRepo);
        final messages = <OrderActionMessage>[];
        final sub = bloc.actionMessages.listen(messages.add);

        bloc.add(CreateOrder(makeOrder(status: OrderStatus.awaitingCapture)));
        await Future.delayed(const Duration(milliseconds: 50));

        // Après création, on dispatch l'upload comme le fait la UI
        bloc.add(const UploadPaymentCapture('order-001', '/tmp/proof.jpg'));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(messages.length, 2);
        expect(messages[0].result, OrderActionResult.success); // create
        expect(messages[1].result, OrderActionResult.success); // upload

        verify(() => mockRepo.createOrder(any())).called(1);
        verify(() => mockRepo.uploadPaymentCapture('order-001', any())).called(1);

        await sub.cancel();
        await bloc.close();
      },
    );

    test(
      'order créé avec status awaitingCapture pour commande directe',
      () async {
        Order? captured;
        when(() => mockRepo.createOrder(any())).thenAnswer((inv) async {
          captured = inv.positionalArguments[0] as Order;
          return 'new-id';
        });

        final bloc = OrderBloc(mockRepo);
        final sub = bloc.actionMessages.listen((_) {});

        bloc.add(CreateOrder(makeOrder(
          status: OrderStatus.awaitingCapture,
          type: OrderType.direct,
        )));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(captured?.status, OrderStatus.awaitingCapture);
        expect(captured?.type, OrderType.direct);

        await sub.cancel();
        await bloc.close();
      },
    );
  });

  // ════════════════════════════════════════════════════════════════════════
  // Précommande — flux complet
  // ════════════════════════════════════════════════════════════════════════

  group('Flux précommande', () {
    test('order précommande créé avec type preorder et awaitingCapture', () async {
      Order? captured;
      when(() => mockRepo.createOrder(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as Order;
        return 'preorder-id';
      });

      final bloc = OrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(CreateOrder(makeOrder(
        status: OrderStatus.awaitingCapture,
        type: OrderType.preorder,
      )));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(captured?.type, OrderType.preorder);
      expect(captured?.status, OrderStatus.awaitingCapture);

      await sub.cancel();
      await bloc.close();
    });

    test('lastCreatedOrderId disponible après createOrder pour précommande', () async {
      when(() => mockRepo.createOrder(any()))
          .thenAnswer((_) async => 'preorder-123');

      final bloc = OrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(CreateOrder(makeOrder(type: OrderType.preorder)));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.lastCreatedOrderId, 'preorder-123');

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // CancelOrder — annulation tardive
  // ════════════════════════════════════════════════════════════════════════

  group('CancelOrder isLate', () {
    test('annulation tardive → cancelOrder appelé avec isLate: true', () async {
      when(() => mockRepo.cancelOrder(any(), isLate: any(named: 'isLate')))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(const CancelOrder('order-001', isLate: true));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.cancelOrder('order-001', isLate: true)).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('annulation normale → cancelOrder appelé avec isLate: false', () async {
      when(() => mockRepo.cancelOrder(any(), isLate: any(named: 'isLate')))
          .thenAnswer((_) async {});
      final bloc = OrderBloc(mockRepo);
      final sub = bloc.actionMessages.listen((_) {});

      bloc.add(const CancelOrder('order-001'));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.cancelOrder('order-001', isLate: false)).called(1);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Rechargement du stream (double LoadBuyerOrders)
  // ════════════════════════════════════════════════════════════════════════

  group('LoadBuyerOrders — rechargement', () {
    test('second LoadBuyerOrders annule le premier stream', () async {
      final ctrl1 = StreamController<List<Order>>.broadcast();
      final ctrl2 = StreamController<List<Order>>.broadcast();

      var callCount = 0;
      when(() => mockRepo.watchBuyerOrders(any())).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? ctrl1.stream : ctrl2.stream;
      });

      final bloc = OrderBloc(mockRepo);
      final states = <OrderState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadBuyerOrders('buyer-1'));
      await Future.delayed(const Duration(milliseconds: 20));

      // Second load → cancel le premier stream
      bloc.add(const LoadBuyerOrders('buyer-2'));
      await Future.delayed(const Duration(milliseconds: 20));

      // Emit sur ctrl2 → visible
      ctrl2.add([makeOrder(id: 'from-ctrl2')]);
      await Future.delayed(const Duration(milliseconds: 20));

      final loaded = states.whereType<OrderLoaded>().last;
      expect(loaded.orders.first.id, 'from-ctrl2');

      await sub.cancel();
      await ctrl1.close();
      await ctrl2.close();
      await bloc.close();
    });
  });
}

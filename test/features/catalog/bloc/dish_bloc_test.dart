import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:calma/features/catalog/domain/entities/dish.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_action_message.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_bloc.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_event.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockDishRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(FakeDishEvent());
    registerFallbackValue(FakeDishState());
    registerFallbackValue(makeDish());
  });

  setUp(() {
    mockRepo = MockDishRepository();
  });

  // ════════════════════════════════════════════════════════════════════════
  // LoadVendorDishes
  // ════════════════════════════════════════════════════════════════════════

  group('LoadVendorDishes', () {
    final dish1 = makeDish(id: 'd1', name: 'Foufou');
    final dish2 = makeDish(id: 'd2', name: 'Alloco', isActive: false);

    blocTest<DishBloc, DishState>(
      'émet DishLoading puis DishLoaded quand le stream retourne des plats',
      build: () {
        when(() => mockRepo.watchVendorDishes('vendor-uid-123'))
            .thenAnswer((_) => Stream.value(<Dish>[dish1, dish2]));
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(const LoadVendorDishes('vendor-uid-123')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<DishLoading>(),
        isA<DishLoaded>().having(
          (s) => s.dishes,
          'dishes',
          containsAll([dish1, dish2]),
        ),
      ],
    );

    blocTest<DishBloc, DishState>(
      'émet DishLoaded avec liste vide quand le stream est vide',
      build: () {
        when(() => mockRepo.watchVendorDishes(any()))
            .thenAnswer((_) => Stream.value(<Dish>[]));
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(const LoadVendorDishes('vendor-uid-123')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<DishLoading>(),
        isA<DishLoaded>().having((s) => s.dishes, 'dishes', isEmpty),
      ],
    );

    blocTest<DishBloc, DishState>(
      'erreur Firestore → DishError avec message lisible',
      build: () {
        when(() => mockRepo.watchVendorDishes(any()))
            .thenAnswer((_) => Stream.error(Exception('permission-denied')));
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(const LoadVendorDishes('vendor-uid-123')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<DishLoading>(),
        isA<DishError>().having(
          (s) => s.message,
          'message',
          contains('permission-denied'),
        ),
      ],
    );

    blocTest<DishBloc, DishState>(
      'double LoadVendorDishes annule le premier stream (dedup DishLoading)',
      build: () {
        int callCount = 0;
        when(() => mockRepo.watchVendorDishes(any())).thenAnswer((_) {
          callCount++;
          // Premier stream : ne jamais émettre
          if (callCount == 1) return const Stream.empty();
          // Deuxième stream : émettre un plat
          return Stream.value(<Dish>[makeDish()]);
        });
        return DishBloc(mockRepo);
      },
      act: (b) {
        b.add(const LoadVendorDishes('uid'));
        b.add(const LoadVendorDishes('uid'));
      },
      wait: const Duration(milliseconds: 100),
      // BLoC déduplique DishLoading (même state) → on ne voit qu'un DishLoading
      expect: () => [
        isA<DishLoading>(),
        isA<DishLoaded>(),
      ],
    );

    test(
      'met à jour dynamiquement quand le stream Firestore émet plusieurs fois',
      () async {
        final controller = StreamController<List<Dish>>.broadcast();
        when(() => mockRepo.watchVendorDishes(any()))
            .thenAnswer((_) => controller.stream);

        final bloc = DishBloc(mockRepo);
        final states = <DishState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadVendorDishes('vendor-uid-123'));
        await Future.delayed(const Duration(milliseconds: 30));

        // Première émission du stream
        final dish1 = makeDish(id: 'd1', name: 'Plat 1');
        controller.add([dish1]);
        await Future.delayed(const Duration(milliseconds: 30));

        // Deuxième émission (plat ajouté)
        final dish2 = makeDish(id: 'd2', name: 'Plat 2');
        controller.add([dish1, dish2]);
        await Future.delayed(const Duration(milliseconds: 30));

        expect(states[0], isA<DishLoading>());
        expect((states[1] as DishLoaded).dishes.length, 1);
        expect((states[2] as DishLoaded).dishes.length, 2);

        await sub.cancel();
        await controller.close();
        await bloc.close();
      },
    );
  });

  // ════════════════════════════════════════════════════════════════════════
  // CreateDish
  // ════════════════════════════════════════════════════════════════════════

  group('CreateDish', () {
    blocTest<DishBloc, DishState>(
      'succès → actionMessages émet success, BLoC state inchangé',
      build: () {
        when(() => mockRepo.createDish(any()))
            .thenAnswer((_) async => 'dish-001');
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(CreateDish(makeDish())),
      wait: const Duration(milliseconds: 50),
      // Aucun changement de state BLoC — c'est le stream Firestore qui met à jour
      expect: () => [],
      verify: (b) {
        verify(() => mockRepo.createDish(any())).called(1);
      },
    );

    test('succès → actionMessages reçoit DishActionResult.success', () async {
      when(() => mockRepo.createDish(any())).thenAnswer((_) async => 'dish-001');
      final bloc = DishBloc(mockRepo);

      final messages = <DishActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreateDish(makeDish()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.result, DishActionResult.success);
      expect(messages.first.text, contains('créé'));

      await sub.cancel();
      await bloc.close();
    });

    test('échec → actionMessages reçoit DishActionResult.error', () async {
      when(() => mockRepo.createDish(any()))
          .thenThrow(Exception('network error'));
      final bloc = DishBloc(mockRepo);

      final messages = <DishActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(CreateDish(makeDish()));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.length, 1);
      expect(messages.first.result, DishActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // DeleteDish
  // ════════════════════════════════════════════════════════════════════════

  group('DeleteDish', () {
    blocTest<DishBloc, DishState>(
      'succès → actionMessages émet success',
      build: () {
        when(() => mockRepo.deleteDish(any())).thenAnswer((_) async {});
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(const DeleteDish('d1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (_) {
        // actionMessages testé dans le test dédié ci-dessous
      },
    );

    test('succès → actionMessages reçoit DishActionResult.success', () async {
      when(() => mockRepo.deleteDish(any())).thenAnswer((_) async {});
      final bloc = DishBloc(mockRepo);

      final messages = <DishActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const DeleteDish('d1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, DishActionResult.success);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // ToggleDishActive
  // ════════════════════════════════════════════════════════════════════════

  group('ToggleDishActive', () {
    blocTest<DishBloc, DishState>(
      'succès → aucun changement de state (stream Firestore met à jour)',
      build: () {
        when(() =>
                mockRepo.toggleDishActive(any(), isActive: any(named: 'isActive')))
            .thenAnswer((_) async {});
        return DishBloc(mockRepo);
      },
      act: (b) => b.add(const ToggleDishActive('d1', isActive: false)),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
    );

    test('échec → actionMessages reçoit DishActionResult.error', () async {
      when(() =>
              mockRepo.toggleDishActive(any(), isActive: any(named: 'isActive')))
          .thenThrow(Exception('offline'));
      final bloc = DishBloc(mockRepo);

      final messages = <DishActionMessage>[];
      final sub = bloc.actionMessages.listen(messages.add);

      bloc.add(const ToggleDishActive('d1', isActive: false));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(messages.first.result, DishActionResult.error);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  // Invariant critique
  // ════════════════════════════════════════════════════════════════════════

  test(
    'INVARIANT — CreateDish/Delete/Toggle ne changent jamais le state BLoC '
    '(seul le stream Firestore met à jour DishLoaded)',
    () async {
      when(() => mockRepo.createDish(any())).thenAnswer((_) async => 'new-id');
      when(() => mockRepo.deleteDish(any())).thenAnswer((_) async {});
      when(() =>
              mockRepo.toggleDishActive(any(), isActive: any(named: 'isActive')))
          .thenAnswer((_) async {});

      final bloc = DishBloc(mockRepo);
      final states = <DishState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(CreateDish(makeDish()));
      bloc.add(const DeleteDish('x'));
      bloc.add(const ToggleDishActive('x', isActive: false));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, isEmpty,
          reason: 'Aucun de ces events ne doit changer le state BLoC');

      await sub.cancel();
      await bloc.close();
    },
  );
}

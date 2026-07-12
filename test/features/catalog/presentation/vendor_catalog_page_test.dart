import 'dart:async';

import 'package:calma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calma/features/auth/presentation/bloc/auth_state.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_action_message.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_bloc.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_event.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_state.dart';
import 'package:calma/features/catalog/presentation/pages/vendor_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

// ── Wrapper de test ────────────────────────────────────────────────────────

// Surface largement suffisante pour éviter les overflows de rendu en tests
const _testSize = Size(1080, 1920);

Widget _buildApp(MockDishBloc dishBloc, MockAuthBloc authBloc) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider<DishBloc>.value(value: dishBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: const VendorCatalogPage(),
        ),
      ),
      GoRoute(path: '/app/vendor/dishes/add', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/app/vendor/preview', builder: (_, __) => const SizedBox()),
    ],
  );
  return ScreenUtilInit(
    designSize: _testSize,
    builder: (_, __) => MaterialApp.router(routerConfig: router),
  );
}

Future<void> pump(WidgetTester tester, MockDishBloc d, MockAuthBloc a) async {
  await tester.binding.setSurfaceSize(_testSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_buildApp(d, a));
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MockDishBloc dishBloc;
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(FakeDishEvent());
    registerFallbackValue(FakeDishState());
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    dishBloc = MockDishBloc();
    authBloc = MockAuthBloc();
    when(() => dishBloc.actionMessages)
        .thenAnswer((_) => const Stream<DishActionMessage>.empty());
    when(() => authBloc.state).thenReturn(Authenticated(testUser));
    when(() => authBloc.stream)
        .thenAnswer((_) => Stream.value(Authenticated(testUser)));
  });

  // ════════════════════════════════════════════════════════════════════════
  // 1. LoadVendorDishes dispatché au montage
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('1. LoadVendorDishes est dispatché au montage avec le bon UID',
      (tester) async {
    when(() => dishBloc.state).thenReturn(const DishInitial());
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);

    verify(() => dishBloc.add(LoadVendorDishes(testUser.uid))).called(1);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 2. DishLoading → spinner visible
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('2. Affiche un spinner quand DishLoading', (tester) async {
    when(() => dishBloc.state).thenReturn(const DishLoading());
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 3. DishLoaded([]) → état vide
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('3. DishLoaded([]) → "boutique est vide"', (tester) async {
    when(() => dishBloc.state).thenReturn(const DishLoaded([]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('vide'), findsAtLeastNWidgets(1));
  });

  // ════════════════════════════════════════════════════════════════════════
  // 4. DishLoaded([dish actif]) → nom visible
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('4. DishLoaded([dish]) → nom du plat visible', (tester) async {
    final dish = makeDish(name: 'Foufou de manioc', isActive: true);
    when(() => dishBloc.state).thenReturn(DishLoaded([dish]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Foufou de manioc'), findsAtLeastNWidgets(1));
  });

  // ════════════════════════════════════════════════════════════════════════
  // 5. Onglet "Actifs" filtre les plats inactifs
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('5. Onglet "Actifs" ne montre pas les plats inactifs',
      (tester) async {
    final dish = makeDish(name: 'Plat inactif', isActive: false);
    when(() => dishBloc.state).thenReturn(DishLoaded([dish]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    // Onglet "Tous" → plat visible
    expect(find.text('Plat inactif'), findsOneWidget);

    // Tap sur "Actifs"
    await tester.tap(find.text('Actifs'));
    await tester.pumpAndSettle();

    expect(find.text('Plat inactif'), findsNothing);
    expect(find.textContaining('catégorie'), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 6. DishError → message d'erreur (pas "boutique vide")
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('6. DishError → message d\'erreur visible', (tester) async {
    when(() => dishBloc.state).thenReturn(
      const DishError('Lecture impossible : permission-denied'),
    );
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.textContaining('Impossible de charger'), findsOneWidget);
    expect(find.textContaining('permission-denied'), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 7. BlocBuilder réagit au changement DishLoading → DishLoaded
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('7. BlocBuilder réagit à DishInitial → DishLoaded',
      (tester) async {
    final dish = makeDish(name: 'Jollof Rice');
    final controller = StreamController<DishState>.broadcast();

    when(() => dishBloc.state).thenReturn(const DishInitial());
    when(() => dishBloc.stream).thenAnswer((_) => controller.stream);

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    // DishInitial → spinner visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Transition vers DishLoaded
    controller.add(DishLoaded([dish]));
    await tester.pumpAndSettle();

    expect(find.text('Jollof Rice'), findsAtLeastNWidgets(1));

    await controller.close();
  });

  // ════════════════════════════════════════════════════════════════════════
  // 8. Compteur de plats dans le header
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('8. Header affiche le bon nombre de plats', (tester) async {
    final dishes = [
      makeDish(id: 'd1', name: 'Plat A'),
      makeDish(id: 'd2', name: 'Plat B'),
      makeDish(id: 'd3', name: 'Plat C'),
    ];
    when(() => dishBloc.state).thenReturn(DishLoaded(dishes));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.textContaining('3 plats'), findsOneWidget);
  });
}

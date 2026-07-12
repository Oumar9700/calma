import 'package:bloc_test/bloc_test.dart';
import 'package:calma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calma/features/auth/presentation/bloc/auth_state.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_action_message.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_bloc.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_event.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_state.dart';
import 'package:calma/features/catalog/presentation/pages/vendor_shop_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

const _testSize = Size(1080, 1920);

Widget _buildPreviewApp(MockDishBloc dishBloc, MockAuthBloc authBloc) {
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
          child: const VendorShopPreviewPage(),
        ),
      ),
      GoRoute(path: '/app/settings/profile', builder: (_, __) => const SizedBox()),
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
  await tester.pumpWidget(_buildPreviewApp(d, a));
}

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
  // 1. DishLoaded avec plat actif → visible
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('1. DishLoaded → plat actif visible', (tester) async {
    final dish = makeDish(name: 'Alloco au poulet', isActive: true);
    when(() => dishBloc.state).thenReturn(DishLoaded([dish]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.text('Alloco au poulet'), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 2. Plat inactif → NON affiché
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('2. Plat inactif → non affiché dans l\'aperçu', (tester) async {
    final dish = makeDish(name: 'Plat caché', isActive: false);
    when(() => dishBloc.state).thenReturn(DishLoaded([dish]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.text('Plat caché'), findsNothing);
    expect(find.textContaining('Aucun plat actif'), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 3. DishInitial → message vide
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('3. DishInitial → affiche "aucun plat actif"', (tester) async {
    when(() => dishBloc.state).thenReturn(const DishInitial());
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    expect(find.textContaining('Aucun plat actif'), findsOneWidget);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 4. FIX — dispatche LoadVendorDishes si DishInitial
  // ════════════════════════════════════════════════════════════════════════

  testWidgets(
      '4. [FIX] Dispatche LoadVendorDishes si DishInitial (stream pas encore actif)',
      (tester) async {
    when(() => dishBloc.state).thenReturn(const DishInitial());
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);

    verify(() => dishBloc.add(LoadVendorDishes(testUser.uid))).called(1);
  });

  // ════════════════════════════════════════════════════════════════════════
  // 5. Ne redispatche PAS si déjà chargé
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('5. Ne dispatche PAS LoadVendorDishes si DishLoaded',
      (tester) async {
    when(() => dishBloc.state).thenReturn(DishLoaded([makeDish()]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);

    verifyNever(() => dishBloc.add(any()));
  });

  // ════════════════════════════════════════════════════════════════════════
  // 6. Infos vendeur affichées
  // ════════════════════════════════════════════════════════════════════════

  testWidgets('6. Nom du vendeur affiché (shopName ou fullName)',
      (tester) async {
    when(() => dishBloc.state).thenReturn(const DishLoaded([]));
    when(() => dishBloc.stream)
        .thenAnswer((_) => const Stream<DishState>.empty());

    await pump(tester, dishBloc, authBloc);
    await tester.pump();

    final hasName = find.textContaining('Awa').evaluate().isNotEmpty ||
        find.textContaining('Diallo').evaluate().isNotEmpty;
    expect(hasName, isTrue, reason: 'Le nom du vendeur doit être affiché');
  });
}

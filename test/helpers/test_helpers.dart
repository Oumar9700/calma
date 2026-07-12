import 'package:bloc_test/bloc_test.dart';
import 'package:calma/features/auth/domain/entities/app_user.dart';
import 'package:calma/features/auth/domain/entities/user_role.dart';
import 'package:calma/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calma/features/auth/presentation/bloc/auth_event.dart';
import 'package:calma/features/auth/presentation/bloc/auth_state.dart';
import 'package:calma/features/catalog/domain/entities/dish.dart';
import 'package:calma/features/catalog/domain/entities/dish_category.dart';
import 'package:calma/features/catalog/domain/repositories/dish_repository.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_bloc.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_event.dart';
import 'package:calma/features/catalog/presentation/bloc/dish_state.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockDishRepository extends Mock implements DishRepository {}

class MockDishBloc extends MockBloc<DishEvent, DishState> implements DishBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// ── Fakes (pour mocktail registerFallbackValue) ────────────────────────────

class FakeDishEvent extends Fake implements DishEvent {}
class FakeDishState extends Fake implements DishState {}
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeAuthState extends Fake implements AuthState {}

// ── Données de test ────────────────────────────────────────────────────────

final testUser = AppUser(
  uid: 'vendor-uid-123',
  email: 'test@calma.fr',
  firstName: 'Awa',
  lastName: 'Diallo',
  role: UserRole.vendor,
  createdAt: DateTime(2024, 1, 1),
  regions: const [],
  specialties: const [],
  paymentMethods: const [],
  availableDays: const [],
);

Dish makeDish({
  String id = 'dish-001',
  String vendorId = 'vendor-uid-123',
  String name = 'Foufou de manioc',
  bool isActive = true,
}) =>
    Dish(
      id: id,
      vendorId: vendorId,
      name: name,
      category: DishCategory.mainDish,
      photoUrls: const [],
      price: 5.0,
      availableDays: const ['lundi', 'mardi'],
      createdAt: DateTime(2024, 6, 1),
      isActive: isActive,
    );

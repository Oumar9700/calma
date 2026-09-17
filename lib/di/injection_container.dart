import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/catalog/data/datasources/firestore_dish_datasource.dart';
import '../features/catalog/data/repositories/dish_repository_impl.dart';
import '../features/catalog/domain/repositories/dish_repository.dart';
import '../features/catalog/presentation/bloc/dish_bloc.dart';
import '../features/explore/presentation/bloc/explore_bloc.dart';
import '../features/favorites/data/datasources/favorites_datasource.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../features/orders/data/datasources/firestore_order_datasource.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/presentation/bloc/order_bloc.dart';
import '../features/orders/presentation/bloc/vendor_order_bloc.dart';
import '../shared/blocs/theme/theme_bloc.dart';
import '../shared/services/address_service.dart';
import '../shared/services/notification_service.dart';
import '../shared/services/storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjection() async {
  final firestore = FirebaseFirestore.instance;

  // ── Data sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );

  sl.registerLazySingleton<FirestoreDishDataSource>(
    () => FirestoreDishDataSource(firestore),
  );

  sl.registerLazySingleton<FavoritesDataSource>(
    () => FavoritesDataSource(firestore),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<FirebaseAuthDataSource>()),
  );

  sl.registerLazySingleton<DishRepository>(
    () => DishRepositoryImpl(sl<FirestoreDishDataSource>()),
  );

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesDataSource>()),
  );

  // ── Data sources (orders) ─────────────────────────────────────────────────
  sl.registerLazySingleton<FirestoreOrderDataSource>(
    () => FirestoreOrderDataSource(firestore, sl<StorageService>()),
  );

  // ── Repositories (orders) ─────────────────────────────────────────────────
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<FirestoreOrderDataSource>()),
  );

  // ── Services ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<AddressService>(() => GpsAddressService());

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc());
  sl.registerFactory<DishBloc>(() => DishBloc(sl<DishRepository>()));
  sl.registerFactory<ExploreBloc>(() => ExploreBloc(sl<DishRepository>()));
  sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(sl<FavoritesRepository>()));
  sl.registerFactory<OrderBloc>(() => OrderBloc(sl<OrderRepository>()));
  sl.registerFactory<VendorOrderBloc>(() => VendorOrderBloc(sl<OrderRepository>()));
}

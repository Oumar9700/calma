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
import '../shared/blocs/theme/theme_bloc.dart';
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

  // ── Services ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc());
  sl.registerFactory<DishBloc>(() => DishBloc(sl<DishRepository>()));
  sl.registerFactory<ExploreBloc>(() => ExploreBloc(sl<DishRepository>()));
  sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(sl<FavoritesRepository>()));
}

import 'package:get_it/get_it.dart';
import '../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupInjection() async {
  // Data sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<FirebaseAuthDataSource>()),
  );

  // BLoCs — factory pour créer une nouvelle instance à chaque fois
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
}

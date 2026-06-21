import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RoleUpdated>(_onRoleUpdated);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await emit.forEach<AppUser?>(
      _repository.watchAuthState(),
      onData: (user) =>
          user != null ? Authenticated(user) : const Unauthenticated(),
      onError: (_, __) => const Unauthenticated(),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const Unauthenticated());
  }

  Future<void> _onRoleUpdated(
    RoleUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    final current = (state as Authenticated).user;
    try {
      await _repository.updateProfile(role: event.role);
      emit(Authenticated(current.copyWith(role: event.role)));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
      emit(Authenticated(current));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;
    final current = (state as Authenticated).user;
    try {
      await _repository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        photoUrl: event.photoUrl,
        role: event.role,
        countryOfOrigin: event.countryOfOrigin,
        city: event.city,
        campus: event.campus,
        shopName: event.shopName,
        shopDescription: event.shopDescription,
        regions: event.regions,
        specialties: event.specialties,
        paymentMethods: event.paymentMethods,
        availableDays: event.availableDays,
        approximateLocation: event.approximateLocation,
        coverPhotoUrl: event.coverPhotoUrl,
      );
      final updated = current.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        photoUrl: event.photoUrl,
        role: event.role,
        countryOfOrigin: event.countryOfOrigin,
        city: event.city,
        campus: event.campus,
        shopName: event.shopName,
        shopDescription: event.shopDescription,
        regions: event.regions,
        specialties: event.specialties,
        paymentMethods: event.paymentMethods,
        availableDays: event.availableDays,
        approximateLocation: event.approximateLocation,
        coverPhotoUrl: event.coverPhotoUrl,
      );
      emit(ProfileUpdateSuccess(updated));
      emit(Authenticated(updated));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
      emit(Authenticated(current));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.deleteAccount();
      emit(const Unauthenticated());
    } catch (e) {
      if (state is! Unauthenticated) {
        emit(AuthError(_extractMessage(e)));
      }
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.sendPasswordResetEmail(event.email);
      emit(const PasswordResetSent());
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  String _extractMessage(Object e) {
    final s = e.toString();
    if (s.startsWith('Instance of')) return 'Une erreur est survenue.';
    return s;
  }
}

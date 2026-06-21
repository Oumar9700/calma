import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  @override
  List<Object?> get props => [email, firstName, lastName];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RoleUpdated extends AuthEvent {
  final UserRole role;
  const RoleUpdated(this.role);
  @override
  List<Object?> get props => [role];
}

class ProfileUpdateRequested extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? photoUrl;
  final UserRole? role;
  final String? countryOfOrigin;
  final String? city;
  final String? campus;
  final String? shopName;
  final String? shopDescription;
  final List<String>? regions;
  final List<String>? specialties;
  final List<String>? paymentMethods;
  final List<String>? availableDays;
  final String? approximateLocation;
  final String? coverPhotoUrl;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.phone,
    this.photoUrl,
    this.role,
    this.countryOfOrigin,
    this.city,
    this.campus,
    this.shopName,
    this.shopDescription,
    this.regions,
    this.specialties,
    this.paymentMethods,
    this.availableDays,
    this.approximateLocation,
    this.coverPhotoUrl,
  });
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

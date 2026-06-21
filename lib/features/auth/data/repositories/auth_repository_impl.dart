import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Stream<AppUser?> watchAuthState() => _dataSource.watchAuthState();

  @override
  Future<AppUser> login({required String email, required String password}) =>
      _dataSource.login(email: email, password: password);

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) =>
      _dataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _dataSource.sendPasswordResetEmail(email);

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    UserRole? role,
    String? countryOfOrigin,
    String? city,
    String? campus,
    String? shopName,
    String? shopDescription,
    List<String>? regions,
    List<String>? specialties,
    List<String>? paymentMethods,
    List<String>? availableDays,
    String? approximateLocation,
    String? coverPhotoUrl,
  }) =>
      _dataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        photoUrl: photoUrl,
        role: role,
        countryOfOrigin: countryOfOrigin,
        city: city,
        campus: campus,
        shopName: shopName,
        shopDescription: shopDescription,
        regions: regions,
        specialties: specialties,
        paymentMethods: paymentMethods,
        availableDays: availableDays,
        approximateLocation: approximateLocation,
        coverPhotoUrl: coverPhotoUrl,
      );

  @override
  Future<AppUser?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<void> deleteAccount() => _dataSource.deleteAccount();

  @override
  Future<AppUser> signInWithGoogle() => _dataSource.signInWithGoogle();
}

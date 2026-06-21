import '../entities/app_user.dart';
import '../entities/user_role.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
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
  });
  Future<AppUser?> getCurrentUser();
  Future<void> deleteAccount();
  Future<AppUser> signInWithGoogle();
}

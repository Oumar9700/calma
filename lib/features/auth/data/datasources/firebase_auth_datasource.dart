import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<AppUser?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchUserDocument(firebaseUser.uid);
    });
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthFailure();
      return await _fetchUserDocument(user.uid) ??
          _userFromFirebase(user, '', '');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw const AuthFailure();

      await firebaseUser.updateDisplayName('$firstName $lastName');

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        role: UserRole.buyer,
        referralCode: const Uuid().v4().substring(0, 8).toUpperCase(),
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(appUser.toFirestore());

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    UserRole? role,
    String? countryOfOrigin,
    String? city,
    String? campus,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const UserNotFoundFailure();

    final updates = <String, dynamic>{};
    if (firstName != null) updates['firstName'] = firstName.trim();
    if (lastName != null) updates['lastName'] = lastName.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (role != null) updates['role'] = role.firestoreValue;
    if (countryOfOrigin != null) updates['countryOfOrigin'] = countryOfOrigin;
    if (city != null) updates['city'] = city.trim();
    if (campus != null) updates['campus'] = campus.trim();

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(updates);
    }

    if (firstName != null || lastName != null) {
      final first = firstName ?? '';
      final last = lastName ?? '';
      await user.updateDisplayName('$first $last'.trim());
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUserDocument(user.uid);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const UserNotFoundFailure();

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .delete();
    await user.delete();
  }

  Future<AppUser?> _fetchUserDocument(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromFirestore(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  AppUser _userFromFirebase(
    User firebaseUser,
    String firstName,
    String lastName,
  ) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const EmailAlreadyUsedFailure();
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return const InvalidCredentialsFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      default:
        return AuthFailure(e.message ?? 'Erreur d\'authentification.');
    }
  }
}

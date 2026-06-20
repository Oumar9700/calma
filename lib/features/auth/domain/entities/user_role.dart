enum UserRole {
  buyer,
  vendor,
  both;

  String get firestoreValue => name;

  static UserRole fromFirestore(String? value) {
    switch (value) {
      case 'vendor':
        return UserRole.vendor;
      case 'both':
        return UserRole.both;
      default:
        return UserRole.buyer;
    }
  }
}

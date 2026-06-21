enum UserRole {
  buyer,
  vendor,
  both;

  String get firestoreValue => name;
  bool get isVendor => this == UserRole.vendor || this == UserRole.both;
  bool get isBuyer => this == UserRole.buyer || this == UserRole.both;

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

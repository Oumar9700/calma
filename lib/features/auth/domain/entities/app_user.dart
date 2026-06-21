import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? phone;
  final UserRole role;
  final String? countryOfOrigin;
  final String? city;
  final String? campus;
  final int cancellationCount;
  final bool isAmbassador;
  final String? referralCode;
  final String? referredBy;
  final DateTime createdAt;
  final bool isEmailVerified;

  // Champs vendeur
  final String? shopName;
  final String? shopDescription;
  final List<String> regions;
  final List<String> specialties;
  final List<String> paymentMethods;
  final List<String> availableDays;
  final String? approximateLocation;
  final String? coverPhotoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.phone,
    this.role = UserRole.buyer,
    this.countryOfOrigin,
    this.city,
    this.campus,
    this.cancellationCount = 0,
    this.isAmbassador = false,
    this.referralCode,
    this.referredBy,
    required this.createdAt,
    this.isEmailVerified = false,
    this.shopName,
    this.shopDescription,
    this.regions = const [],
    this.specialties = const [],
    this.paymentMethods = const [],
    this.availableDays = const [],
    this.approximateLocation,
    this.coverPhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  bool get isVendor => role == UserRole.vendor || role == UserRole.both;
  bool get isBuyer => role == UserRole.buyer || role == UserRole.both;

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phone,
    UserRole? role,
    String? countryOfOrigin,
    String? city,
    String? campus,
    int? cancellationCount,
    bool? isAmbassador,
    String? referralCode,
    String? referredBy,
    bool? isEmailVerified,
    String? shopName,
    String? shopDescription,
    List<String>? regions,
    List<String>? specialties,
    List<String>? paymentMethods,
    List<String>? availableDays,
    String? approximateLocation,
    String? coverPhotoUrl,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      city: city ?? this.city,
      campus: campus ?? this.campus,
      cancellationCount: cancellationCount ?? this.cancellationCount,
      isAmbassador: isAmbassador ?? this.isAmbassador,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      regions: regions ?? this.regions,
      specialties: specialties ?? this.specialties,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      availableDays: availableDays ?? this.availableDays,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'phone': phone,
      'role': role.firestoreValue,
      'countryOfOrigin': countryOfOrigin,
      'city': city,
      'campus': campus,
      'cancellationCount': cancellationCount,
      'isAmbassador': isAmbassador,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'shopName': shopName,
      'shopDescription': shopDescription,
      'regions': regions,
      'specialties': specialties,
      'paymentMethods': paymentMethods,
      'availableDays': availableDays,
      'approximateLocation': approximateLocation,
      'coverPhotoUrl': coverPhotoUrl,
    };
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    List<String> strList(dynamic v) =>
        (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return AppUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      role: UserRole.fromFirestore(data['role'] as String?),
      countryOfOrigin: data['countryOfOrigin'] as String?,
      city: data['city'] as String?,
      campus: data['campus'] as String?,
      cancellationCount: data['cancellationCount'] as int? ?? 0,
      isAmbassador: data['isAmbassador'] as bool? ?? false,
      referralCode: data['referralCode'] as String?,
      referredBy: data['referredBy'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      shopName: data['shopName'] as String?,
      shopDescription: data['shopDescription'] as String?,
      regions: strList(data['regions']),
      specialties: strList(data['specialties']),
      paymentMethods: strList(data['paymentMethods']),
      availableDays: strList(data['availableDays']),
      approximateLocation: data['approximateLocation'] as String?,
      coverPhotoUrl: data['coverPhotoUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [uid, email, firstName, lastName, role];
}

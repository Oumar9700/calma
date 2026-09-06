import 'package:equatable/equatable.dart';
import 'dish_category.dart';

class Dish extends Equatable {
  final String id;
  final String vendorId;
  final String name;
  final String? countryOfOrigin;
  final String? region;
  final String? description;
  final DishCategory category;
  final List<String> photoUrls;
  final double price;
  final int? dailyMaxQuantity;
  final bool preorderEnabled;
  final int? preorderDeadlineDays;
  final int? preorderMinimum;
  final int? preorderClosingHoursBeforeDate;
  final List<DateTime> preorderFixedDates;
  final bool directOrderEnabled;
  final int? prepTimeMinutes;
  final bool isActive;
  final double averageRating;
  final int reviewCount;
  final List<String> availableDays;
  final DateTime createdAt;

  const Dish({
    required this.id,
    required this.vendorId,
    required this.name,
    this.countryOfOrigin,
    this.region,
    this.description,
    required this.category,
    required this.photoUrls,
    required this.price,
    this.dailyMaxQuantity,
    this.preorderEnabled = false,
    this.preorderDeadlineDays,
    this.preorderMinimum,
    this.preorderClosingHoursBeforeDate,
    this.preorderFixedDates = const [],
    this.directOrderEnabled = true,
    this.prepTimeMinutes,
    this.isActive = true,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    required this.availableDays,
    required this.createdAt,
  });

  bool get isAvailableToday {
    const days = [
      'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
    ];
    final today = days[DateTime.now().weekday - 1];
    return availableDays.contains(today);
  }

  Dish copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? countryOfOrigin,
    String? region,
    String? description,
    DishCategory? category,
    List<String>? photoUrls,
    double? price,
    int? dailyMaxQuantity,
    bool? preorderEnabled,
    int? preorderDeadlineDays,
    int? preorderMinimum,
    int? preorderClosingHoursBeforeDate,
    List<DateTime>? preorderFixedDates,
    bool? directOrderEnabled,
    int? prepTimeMinutes,
    bool? isActive,
    double? averageRating,
    int? reviewCount,
    List<String>? availableDays,
    DateTime? createdAt,
  }) {
    return Dish(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      region: region ?? this.region,
      description: description ?? this.description,
      category: category ?? this.category,
      photoUrls: photoUrls ?? this.photoUrls,
      price: price ?? this.price,
      dailyMaxQuantity: dailyMaxQuantity ?? this.dailyMaxQuantity,
      preorderEnabled: preorderEnabled ?? this.preorderEnabled,
      preorderDeadlineDays: preorderDeadlineDays ?? this.preorderDeadlineDays,
      preorderMinimum: preorderMinimum ?? this.preorderMinimum,
      preorderClosingHoursBeforeDate: preorderClosingHoursBeforeDate ?? this.preorderClosingHoursBeforeDate,
      preorderFixedDates: preorderFixedDates ?? this.preorderFixedDates,
      directOrderEnabled: directOrderEnabled ?? this.directOrderEnabled,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      isActive: isActive ?? this.isActive,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      availableDays: availableDays ?? this.availableDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, vendorId, name, countryOfOrigin, region, description,
        category, photoUrls, price, dailyMaxQuantity, preorderEnabled,
        preorderDeadlineDays, preorderMinimum, preorderClosingHoursBeforeDate,
        preorderFixedDates, directOrderEnabled, prepTimeMinutes, isActive,
        averageRating, reviewCount, availableDays, createdAt,
      ];
}

import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/dish_category.dart';

enum OrderTypeFilter { direct, preorder, both }

class ExploreFilter extends Equatable {
  final String? countryOfOrigin;
  final DishCategory? category;
  final bool availableToday;
  final double? minRating;
  final String? searchQuery;
  final String? availableDay;
  final OrderTypeFilter? orderType;

  const ExploreFilter({
    this.countryOfOrigin,
    this.category,
    this.availableToday = false,
    this.minRating,
    this.searchQuery,
    this.availableDay,
    this.orderType,
  });

  bool get hasActiveFilters =>
      countryOfOrigin != null ||
      category != null ||
      availableToday ||
      minRating != null ||
      availableDay != null ||
      orderType != null;

  int get activeFilterCount {
    var count = 0;
    if (countryOfOrigin != null) count++;
    if (category != null) count++;
    if (availableToday) count++;
    if (minRating != null) count++;
    if (availableDay != null) count++;
    if (orderType != null) count++;
    return count;
  }

  ExploreFilter copyWith({
    String? countryOfOrigin,
    DishCategory? category,
    bool? availableToday,
    double? minRating,
    String? searchQuery,
    String? availableDay,
    OrderTypeFilter? orderType,
    bool clearCountry = false,
    bool clearCategory = false,
    bool clearRating = false,
    bool clearSearch = false,
    bool clearDay = false,
    bool clearOrderType = false,
  }) {
    return ExploreFilter(
      countryOfOrigin: clearCountry ? null : (countryOfOrigin ?? this.countryOfOrigin),
      category: clearCategory ? null : (category ?? this.category),
      availableToday: availableToday ?? this.availableToday,
      minRating: clearRating ? null : (minRating ?? this.minRating),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      availableDay: clearDay ? null : (availableDay ?? this.availableDay),
      orderType: clearOrderType ? null : (orderType ?? this.orderType),
    );
  }

  static const empty = ExploreFilter();

  @override
  List<Object?> get props =>
      [countryOfOrigin, category, availableToday, minRating, searchQuery, availableDay, orderType];
}

import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/dish_category.dart';

class ExploreFilter extends Equatable {
  final String? countryOfOrigin;
  final DishCategory? category;
  final bool availableToday;
  final double? minRating;
  final String? searchQuery;

  const ExploreFilter({
    this.countryOfOrigin,
    this.category,
    this.availableToday = false,
    this.minRating,
    this.searchQuery,
  });

  bool get hasActiveFilters =>
      countryOfOrigin != null ||
      category != null ||
      availableToday ||
      minRating != null;

  int get activeFilterCount {
    var count = 0;
    if (countryOfOrigin != null) count++;
    if (category != null) count++;
    if (availableToday) count++;
    if (minRating != null) count++;
    return count;
  }

  ExploreFilter copyWith({
    String? countryOfOrigin,
    DishCategory? category,
    bool? availableToday,
    double? minRating,
    String? searchQuery,
    bool clearCountry = false,
    bool clearCategory = false,
    bool clearRating = false,
    bool clearSearch = false,
  }) {
    return ExploreFilter(
      countryOfOrigin: clearCountry ? null : (countryOfOrigin ?? this.countryOfOrigin),
      category: clearCategory ? null : (category ?? this.category),
      availableToday: availableToday ?? this.availableToday,
      minRating: clearRating ? null : (minRating ?? this.minRating),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  static const empty = ExploreFilter();

  @override
  List<Object?> get props =>
      [countryOfOrigin, category, availableToday, minRating, searchQuery];
}

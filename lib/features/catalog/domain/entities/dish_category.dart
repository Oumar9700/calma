enum DishCategory {
  mainDish,
  dessert,
  snack,
  drink,
  other;

  String get label => switch (this) {
        DishCategory.mainDish => 'Plat principal',
        DishCategory.dessert => 'Dessert',
        DishCategory.snack => 'Snack',
        DishCategory.drink => 'Boisson',
        DishCategory.other => 'Autre',
      };

  static DishCategory fromString(String value) => DishCategory.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DishCategory.other,
      );
}

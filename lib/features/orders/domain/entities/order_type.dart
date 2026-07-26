enum OrderType {
  direct,
  preorder,
}

extension OrderTypeExtension on OrderType {
  String get label {
    switch (this) {
      case OrderType.direct:
        return 'Commande directe';
      case OrderType.preorder:
        return 'Précommande';
    }
  }

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderType.direct,
    );
  }
}

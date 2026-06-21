import 'package:flutter/material.dart';

extension AppBuildContext on BuildContext {
  // Couleurs dynamiques via le ColorScheme du thème actif
  Color get colorPrimary => Theme.of(this).colorScheme.primary;
  Color get colorOnPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get colorOnSurface => Theme.of(this).colorScheme.onSurface;
  Color get colorOnSurfaceVariant =>
      Theme.of(this).colorScheme.onSurfaceVariant;
  Color get colorSurface => Theme.of(this).colorScheme.surface;
  Color get colorSurfaceContainerHighest =>
      Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get colorBorder => Theme.of(this).colorScheme.outline;
  Color get colorError => Theme.of(this).colorScheme.error;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

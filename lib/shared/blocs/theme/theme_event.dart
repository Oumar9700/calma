import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeLoaded extends ThemeEvent {
  const ThemeLoaded();
}

class ThemeModeChanged extends ThemeEvent {
  final ThemeMode mode;
  const ThemeModeChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ThemePrimaryColorChanged extends ThemeEvent {
  final Color color;
  const ThemePrimaryColorChanged(this.color);
  @override
  List<Object?> get props => [color.value];
}

// Alias gardé pour ne pas casser le code existant
class ThemeChanged extends ThemeModeChanged {
  const ThemeChanged(super.mode);
}

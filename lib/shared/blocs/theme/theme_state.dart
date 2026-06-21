import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ThemeState extends Equatable {
  final ThemeMode mode;
  final Color primaryColor;

  const ThemeState({
    this.mode = ThemeMode.system,
    this.primaryColor = AppColors.primary,
  });

  ThemeState copyWith({ThemeMode? mode, Color? primaryColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  @override
  List<Object?> get props => [mode, primaryColor.value];
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _keyMode = 'theme_mode';
  static const _keyColor = 'theme_primary_color';

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeLoaded>(_onLoaded);
    on<ThemeModeChanged>(_onModeChanged);
    on<ThemePrimaryColorChanged>(_onColorChanged);
  }

  Future<void> _onLoaded(ThemeLoaded event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _modeFromString(prefs.getString(_keyMode));
    final colorValue = prefs.getInt(_keyColor);
    final color =
        colorValue != null ? Color(colorValue) : state.primaryColor;
    emit(ThemeState(mode: mode, primaryColor: color));
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(mode: event.mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, _modeToString(event.mode));
  }

  Future<void> _onColorChanged(
    ThemePrimaryColorChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(primaryColor: event.color));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyColor, event.color.value);
  }

  ThemeMode _modeFromString(String? v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _modeToString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}

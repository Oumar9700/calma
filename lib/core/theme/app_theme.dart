import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static const String _fontFamily = 'PlusJakartaSans';

  static ThemeData light({Color primary = AppColors.primary}) =>
      _buildTheme(Brightness.light, primary);
  static ThemeData dark({Color primary = AppColors.primary}) =>
      _buildTheme(Brightness.dark, primary);

  static ThemeData _buildTheme(Brightness brightness, Color primary) {
    final bool isLight = brightness == Brightness.light;

    final Color textPrimary = isLight ? AppColors.textPrimary : Colors.white;
    final Color textSecondary =
        isLight ? AppColors.textSecondary : const Color(0xFFB0AAAA);
    final Color textTertiary =
        isLight ? AppColors.textTertiary : const Color(0xFF787878);

    // Dérivés dynamiques de la couleur primaire
    final Color primaryLight = Color.lerp(primary, Colors.white, 0.35)!;
    final Color primaryDark = Color.lerp(primary, Colors.black, 0.35)!;
    final Color onPrimary =
        primary.computeLuminance() > 0.4 ? Colors.black : Colors.white;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: _fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            height: 1.2),
        headlineLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        headlineSmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        titleLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        titleMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        bodyLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.5),
        bodyMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.5),
        bodySmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textTertiary,
            height: 1.5),
        labelLarge: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary),
        labelMedium: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary),
        labelSmall: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: textTertiary),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnPrimary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textOnPrimary,
        error: AppColors.error,
        onError: Colors.white,
        surface: isLight ? AppColors.surface : AppColors.darkSurface,
        onSurface: isLight ? AppColors.textPrimary : Colors.white,
        onSurfaceVariant:
            isLight ? AppColors.textSecondary : const Color(0xFFB0AAAA),
        surfaceContainerHighest:
            isLight ? AppColors.surfaceVariant : AppColors.darkCard,
        outline: isLight ? AppColors.border : AppColors.darkBorder,
        outlineVariant: isLight ? AppColors.divider : AppColors.darkBorder,
      ),
      scaffoldBackgroundColor:
          isLight ? AppColors.background : AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.background : AppColors.darkBackground,
        foregroundColor: isLight ? AppColors.textPrimary : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.textPrimary : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? Colors.white : AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight ? AppColors.border : AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.surfaceVariant : AppColors.darkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLight ? AppColors.border : AppColors.darkBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: TextStyle(
            fontFamily: _fontFamily, fontSize: 14, color: textTertiary),
        labelStyle: TextStyle(
            fontFamily: _fontFamily, fontSize: 14, color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight ? Colors.white : AppColors.darkCard,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w400),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.divider : AppColors.darkBorder,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isLight ? AppColors.surfaceVariant : AppColors.darkCard,
        selectedColor: primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
              color: isLight ? AppColors.border : AppColors.darkBorder),
        ),
      ),
    );
  }
}

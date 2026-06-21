import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.primary;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 22.w,
        height: 22.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: _foregroundColor,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            AppSpacing.hGapSm,
          ],
          Text(label, style: _textStyle(context)),
          if (suffixIcon != null) ...[
            AppSpacing.hGapSm,
            suffixIcon!,
          ],
        ],
      );
      if (isFullWidth) {
        child = SizedBox(width: double.infinity, child: child);
      }
    }

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return SizedBox(
          width: width ?? (isFullWidth ? double.infinity : null),
          height: height ?? 52.h,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: disabled
                  ? _backgroundColor.withValues(alpha: 0.5)
                  : _backgroundColor,
              foregroundColor: _foregroundColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonVariant.outlined:
        return SizedBox(
          width: width ?? (isFullWidth ? double.infinity : null),
          height: height ?? 52.h,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: _foregroundColor,
              side: BorderSide(
                color: disabled
                    ? AppColors.border
                    : _foregroundColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              ),
            ),
            child: child,
          ),
        );

      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          child: child,
        );

      case AppButtonVariant.secondary:
        return SizedBox(
          width: width ?? (isFullWidth ? double.infinity : null),
          height: height ?? 52.h,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              ),
            ),
            child: child,
          ),
        );
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.danger:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.outlined:
        return AppColors.primary;
      case AppButtonVariant.ghost:
        return AppColors.primary;
      default:
        return Colors.white;
    }
  }

  TextStyle _textStyle(BuildContext context) {
    return TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: _foregroundColor,
    );
  }
}

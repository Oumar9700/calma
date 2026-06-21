import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/blocs/theme/theme_bloc.dart';
import '../../../../shared/blocs/theme/theme_event.dart';
import '../../../../shared/blocs/theme/theme_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class _ColorPreset {
  final String name;
  final Color color;
  const _ColorPreset(this.name, this.color);
}

const List<_ColorPreset> _presets = [
  _ColorPreset('Terracotta', Color(0xFFC85C3A)),
  _ColorPreset('Forêt', Color(0xFF3D6B4F)),
  _ColorPreset('Océan', Color(0xFF2563EB)),
  _ColorPreset('Améthyste', Color(0xFF7C3AED)),
  _ColorPreset('Or', Color(0xFFD4A853)),
  _ColorPreset('Rose', Color(0xFFE11D6A)),
  _ColorPreset('Ardoise', Color(0xFF475569)),
  _ColorPreset('Indigo', Color(0xFF4F46E5)),
  _ColorPreset('Corail', Color(0xFFFF6B6B)),
  _ColorPreset('Olive', Color(0xFF78890A)),
  _ColorPreset('Canard', Color(0xFF0D9488)),
  _ColorPreset('Prune', Color(0xFF9B2335)),
];

class ThemeCustomizationPage extends StatelessWidget {
  const ThemeCustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return AppScaffold(
          body: ListView(
            padding:
                AppSpacing.pagePadding.copyWith(top: 16.h, bottom: 40.h),
            children: [
              // Header
              Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back,
                      color: context.colorOnSurface, size: 24.w),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Apparence',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurface,
                  ),
                ),
              ]),
              SizedBox(height: 28.h),

              // Prévisualisation
              _PreviewCard(primary: state.primaryColor),
              SizedBox(height: 28.h),

              // Mode clair/sombre/auto
              _SectionTitle('Mode d\'affichage'),
              SizedBox(height: 12.h),
              _ModeSelector(current: state.mode),
              SizedBox(height: 28.h),

              // Couleur principale
              _SectionTitle('Couleur principale'),
              SizedBox(height: 4.h),
              Text(
                'Utilisée sur les boutons, icônes actifs et éléments interactifs.',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colorOnSurfaceVariant,
                    height: 1.4),
              ),
              SizedBox(height: 16.h),
              _ColorGrid(
                presets: _presets,
                selected: state.primaryColor,
                onSelect: (color) => context
                    .read<ThemeBloc>()
                    .add(ThemePrimaryColorChanged(color)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Preview card ────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final Color primary;
  const _PreviewCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSub = isDark ? const Color(0xFFB0AAAA) : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aperçu',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: textSub)),
          SizedBox(height: 14.h),
          Row(children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                  color: primary, borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.restaurant_menu, color: Colors.white, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Thiéboudiène de Mama',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
              SizedBox(height: 2.h),
              Text('5,50 € · Dakar',
                  style: TextStyle(fontSize: 12.sp, color: textSub)),
            ]),
          ]),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8.r)),
                child: Center(
                  child: Text('Commander',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: primary.computeLuminance() > 0.4
                              ? Colors.black
                              : Colors.white)),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              height: 36.h,
              width: 36.h,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.favorite_border, color: primary, size: 18.w),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── Mode selector ───────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  final ThemeMode current;
  const _ModeSelector({required this.current});

  static const _modes = [
    (ThemeMode.system, Icons.brightness_auto_outlined, 'Automatique'),
    (ThemeMode.light, Icons.light_mode_outlined, 'Clair'),
    (ThemeMode.dark, Icons.dark_mode_outlined, 'Sombre'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _modes.map((entry) {
        final (mode, icon, label) = entry;
        final isActive = current == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<ThemeBloc>().add(ThemeModeChanged(mode)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: mode != ThemeMode.dark ? 8.w : 0),
              padding:
                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: isActive
                    ? context.colorPrimary.withValues(alpha: 0.1)
                    : context.colorSurface,
                border: Border.all(
                  color: isActive
                      ? context.colorPrimary
                      : context.colorBorder,
                  width: isActive ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(children: [
                Icon(icon,
                    size: 22.w,
                    color: isActive
                        ? context.colorPrimary
                        : context.colorOnSurfaceVariant),
                SizedBox(height: 6.h),
                Text(label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.sp,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? context.colorPrimary
                          : context.colorOnSurfaceVariant,
                    )),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Color grid ──────────────────────────────────────────────────────────────

class _ColorGrid extends StatelessWidget {
  final List<_ColorPreset> presets;
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorGrid({
    required this.presets,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: presets.map((preset) {
        final isSelected =
            preset.color.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(preset.color),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: preset.color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: context.colorOnSurface, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: preset.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check,
                        color: preset.color.computeLuminance() > 0.4
                            ? Colors.black
                            : Colors.white,
                        size: 22.w)
                    : null,
              ),
              SizedBox(height: 6.h),
              Text(
                preset.name,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.sp,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isSelected
                      ? context.colorOnSurface
                      : context.colorOnSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: context.colorOnSurface,
      ),
    );
  }
}

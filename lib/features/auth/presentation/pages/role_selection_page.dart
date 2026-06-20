import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  UserRole _selected = UserRole.buyer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(AppRoutes.home);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AppScaffold(
        body: Padding(
          padding: AppSpacing.pagePadding.copyWith(top: 32.h, bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comment souhaitez-vous\nutiliser CALMA ?',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Vous pouvez changer ce choix à tout moment dans les paramètres.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 36.h),
              _RoleCard(
                role: UserRole.buyer,
                title: 'Acheteur',
                subtitle: 'Je cherche des plats faits maison',
                icon: Icons.shopping_bag_outlined,
                selected: _selected == UserRole.buyer,
                onTap: () => setState(() => _selected = UserRole.buyer),
              ),
              AppSpacing.gapLg,
              _RoleCard(
                role: UserRole.vendor,
                title: 'Vendeur',
                subtitle: 'Je veux cuisiner et vendre mes plats',
                icon: Icons.storefront_outlined,
                selected: _selected == UserRole.vendor,
                onTap: () => setState(() => _selected = UserRole.vendor),
              ),
              AppSpacing.gapLg,
              _RoleCard(
                role: UserRole.both,
                title: 'Les deux',
                subtitle: 'Je veux acheter et vendre',
                icon: Icons.swap_horiz_rounded,
                selected: _selected == UserRole.both,
                onTap: () => setState(() => _selected = UserRole.both),
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton.primary(
                  label: 'Continuer',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    context.read<AuthBloc>().add(RoleUpdated(_selected));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              ),
              child: Icon(
                icon,
                size: 26.w,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22.w,
              ),
          ],
        ),
      ),
    );
  }
}

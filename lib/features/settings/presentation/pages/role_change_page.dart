import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class RoleChangePage extends StatefulWidget {
  const RoleChangePage({super.key});

  @override
  State<RoleChangePage> createState() => _RoleChangePageState();
}

class _RoleChangePageState extends State<RoleChangePage> {
  late UserRole _selected;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    _selected =
        state is Authenticated ? state.user.role : UserRole.buyer;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rôle mis à jour.')),
          );
          context.pop();
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: AppScaffold(
        body: Padding(
          padding: AppSpacing.pagePadding.copyWith(top: 16.h, bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back,
                      color: context.colorOnSurface, size: 24.w),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Mon rôle',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurface,
                  ),
                ),
              ]),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 40.w),
                child: Text(
                  'Choisissez comment vous souhaitez utiliser CALMA.',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                      height: 1.4),
                ),
              ),
              SizedBox(height: 28.h),

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
                  label: 'Enregistrer',
                  isLoading: state is AuthLoading,
                  onPressed: () =>
                      context.read<AuthBloc>().add(RoleUpdated(_selected)),
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
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: selected
              ? context.colorPrimary.withValues(alpha: 0.08)
              : context.colorSurface,
          borderRadius:
              BorderRadius.circular(AppSpacing.borderRadiusLg),
          border: Border.all(
            color: selected ? context.colorPrimary : context.colorBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: selected
                  ? context.colorPrimary.withValues(alpha: 0.12)
                  : context.colorSurfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
            child: Icon(icon,
                size: 24.w,
                color: selected
                    ? context.colorPrimary
                    : context.colorOnSurfaceVariant),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnSurface,
                    )),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorOnSurfaceVariant)),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle,
                color: context.colorPrimary, size: 22.w),
        ]),
      ),
    );
  }
}

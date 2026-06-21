import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const AppScaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = state.user;
        return AppScaffold(
          body: ListView(
            padding: AppSpacing.pagePadding.copyWith(top: 24.h, bottom: 40.h),
            children: [
              // Header profil
              _ProfileHeader(user: user),
              SizedBox(height: 28.h),

              // Stats rapides
              _StatsRow(user: user),
              SizedBox(height: 28.h),

              // Mon compte
              _ProfileSection(
                title: 'Mon compte',
                items: [
                  _ProfileItem(
                    icon: Icons.edit_outlined,
                    label: 'Modifier le profil',
                    onTap: () => context.push(AppRoutes.editProfile),
                  ),
                  if (user.isVendor) ...[
                    _ProfileItem(
                      icon: Icons.storefront_outlined,
                      label: 'Ma boutique',
                      onTap: () {},
                      badge: user.shopName != null ? null : 'À compléter',
                    ),
                    _ProfileItem(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Mes plats',
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.schedule_outlined,
                      label: 'Mon planning',
                      onTap: () {},
                    ),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // Activité
              _ProfileSection(
                title: 'Activité',
                items: [
                  _ProfileItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Mes commandes',
                    onTap: () => context.go(AppRoutes.orders),
                  ),
                  _ProfileItem(
                    icon: Icons.forum_outlined,
                    label: 'Mes publications',
                    onTap: () => context.go(AppRoutes.posts),
                  ),
                  if (user.isAmbassador)
                    _ProfileItem(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Ambassadeur',
                      onTap: () {},
                      badge: 'Actif',
                      badgeColor: AppColors.success,
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // Paramètres
              _ProfileSection(
                title: 'Paramètres',
                items: [
                  _ProfileItem(
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        _Avatar(user: user, size: 72.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colorOnSurfaceVariant,
                ),
              ),
              SizedBox(height: 6.h),
              _RoleBadge(user: user),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: Icon(Icons.settings_outlined,
              size: 22.w, color: context.colorOnSurfaceVariant),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppUser user;
  final double size;
  const _Avatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: user.photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _InitialsAvatar(user: user, size: size),
          errorWidget: (_, __, ___) => _InitialsAvatar(user: user, size: size),
        ),
      );
    }
    return _InitialsAvatar(user: user, size: size);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final AppUser user;
  final double size;
  const _InitialsAvatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: (size * 0.35).sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final AppUser user;
  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    final label = switch (user.role.name) {
      'vendor' => 'Vendeur',
      'both' => 'Acheteur & Vendeur',
      _ => 'Acheteur',
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppUser user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colorBorder),
      ),
      child: Row(
        children: [
          _StatCell(value: '0', label: 'Commandes'),
          _Divider(),
          _StatCell(value: user.countryOfOrigin ?? '—', label: 'Pays'),
          _Divider(),
          _StatCell(
            value: user.campus ?? user.city ?? '—',
            label: 'Campus',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.colorOnSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: context.colorOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      color: context.colorBorder,
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;
  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: context.colorOnSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colorBorder),
          ),
          child: Column(
            children: items
                .map((item) => item._build(context))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  Widget _build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20.w, color: context.colorOnSurface),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: context.colorOnSurface,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.accent)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: badgeColor ?? AppColors.accent,
                ),
              ),
            )
          : Icon(Icons.chevron_right,
              size: 18.w, color: context.colorOnSurfaceVariant),
      onTap: onTap,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
    );
  }
}

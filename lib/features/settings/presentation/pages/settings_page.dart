import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/blocs/theme/theme_state.dart';
import '../../../../shared/blocs/theme/theme_bloc.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user =
            authState is Authenticated ? authState.user : null;

        return AppScaffold(
          body: ListView(
            padding: AppSpacing.pagePadding
                .copyWith(top: 16.h, bottom: 32.h),
            children: [
              Text('Paramètres',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurface,
                  )),
              SizedBox(height: 24.h),

              // ── Compte ────────────────────────────────────────────────
              _Section(title: 'Compte', items: [
                _Item(
                  icon: Icons.person_outline,
                  label: 'Modifier le profil',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _Item(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Mon rôle',
                  subtitle: user != null
                      ? _roleLabel(user.role.name)
                      : null,
                  onTap: () => context.push(AppRoutes.roleChange),
                ),
              ]),

              // ── Apparence ─────────────────────────────────────────────
              _AppearanceSection(),

              // ── Langue ────────────────────────────────────────────────
              _Section(title: 'Langue', items: [
                _Item(
                  icon: Icons.language_outlined,
                  label: 'Français (FR)',
                  trailing: _Badge('Bientôt'),
                  onTap: null,
                ),
              ]),

              // ── Notifications ─────────────────────────────────────────
              _Section(title: 'Notifications', items: [
                _Item(
                  icon: Icons.notifications_outlined,
                  label: 'Préférences de notification',
                  onTap: () {},
                ),
              ]),

              // ── Zone danger ───────────────────────────────────────────
              _Section(title: 'Zone de danger', items: [
                _Item(
                  icon: Icons.logout,
                  label: 'Se déconnecter',
                  color: AppColors.error,
                  onTap: () => _confirmLogout(context),
                ),
                _Item(
                  icon: Icons.delete_forever_outlined,
                  label: 'Supprimer le compte',
                  color: AppColors.error,
                  onTap: () => _confirmDelete(context),
                ),
              ]),

              SizedBox(height: 16.h),
              Center(
                child: Text('CALMA v1.0.0',
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorOnSurfaceVariant)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _roleLabel(String role) => switch (role) {
        'vendor' => 'Vendeur',
        'both' => 'Acheteur & Vendeur',
        _ => 'Acheteur',
      };

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text('Déconnecter',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
            'Action irréversible. Toutes vos données seront supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          BlocListener<AuthBloc, AuthState>(
            listener: (c, state) {
              if (state is Unauthenticated) Navigator.pop(c);
            },
            child: TextButton(
              onPressed: () => context
                  .read<AuthBloc>()
                  .add(const DeleteAccountRequested()),
              child: Text('Supprimer',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Apparence (avec aperçu couleur) ─────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final modeLabel = switch (themeState.mode) {
          ThemeMode.light => 'Clair',
          ThemeMode.dark => 'Sombre',
          _ => 'Automatique',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, 'Apparence'),
            Container(
              decoration: BoxDecoration(
                color: context.colorSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.colorBorder),
              ),
              child: ListTile(
                leading: Icon(Icons.palette_outlined,
                    size: 20.w, color: context.colorOnSurface),
                title: Text('Thème et couleurs',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colorOnSurface,
                    )),
                subtitle: Text(modeLabel,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorOnSurfaceVariant)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  // Aperçu de la couleur sélectionnée
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: themeState.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.chevron_right,
                      size: 18.w,
                      color: context.colorOnSurfaceVariant),
                ]),
                onTap: () => context.push(AppRoutes.themeSettings),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

Widget _sectionHeader(BuildContext context, String title) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8.h, top: 20.h),
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
  );
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, title),
        Container(
          decoration: BoxDecoration(
            color: context.colorSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colorBorder),
          ),
          child: Column(
              children: items.map((i) => i._build(context)).toList()),
        ),
      ],
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Item({
    required this.icon,
    required this.label,
    this.subtitle,
    this.color,
    this.trailing,
    this.onTap,
  });

  Widget _build(BuildContext context) {
    final fg = color ?? context.colorOnSurface;
    return ListTile(
      leading: Icon(icon, size: 20.w, color: fg),
      title: Text(label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: fg,
          )),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colorOnSurfaceVariant))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right,
                  size: 18.w, color: context.colorOnSurfaceVariant)
              : null),
      onTap: onTap,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.accent)),
    );
  }
}

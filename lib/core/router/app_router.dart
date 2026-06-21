import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/role_change_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/theme_customization_page.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthStateNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.uri.path;

      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.onboarding ||
          location == AppRoutes.splash ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.roleSelection ||
          location == AppRoutes.profileSetup;

      if (authState is AuthInitial || authState is AuthLoading) return null;

      if (authState is Unauthenticated) {
        if (!isAuthRoute) return AppRoutes.onboarding;
        return null;
      }

      if (authState is Authenticated) {
        if (location == AppRoutes.splash || location == AppRoutes.onboarding) {
          return AppRoutes.home;
        }
        if (location == AppRoutes.login || location == AppRoutes.register) {
          return AppRoutes.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Accueil', icon: Icons.home_outlined),
          ),
          GoRoute(
            path: AppRoutes.explore,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Explorer', icon: Icons.search_outlined),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Commandes', icon: Icons.receipt_long_outlined),
          ),
          GoRoute(
            path: AppRoutes.posts,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Publications', icon: Icons.forum_outlined),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'theme',
                builder: (context, state) =>
                    const ThemeCustomizationPage(),
              ),
              GoRoute(
                path: 'role',
                builder: (context, state) => const RoleChangePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PlaceholderPage({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Disponible en Phase 2',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }
}

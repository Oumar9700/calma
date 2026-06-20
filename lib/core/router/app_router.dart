import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
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
          location == AppRoutes.roleSelection;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

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
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Accueil'),
          ),
          GoRoute(
            path: AppRoutes.explore,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Explorer'),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Commandes'),
          ),
          GoRoute(
            path: AppRoutes.posts,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Publications'),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) =>
                const _PlaceholderPage(label: 'Profil'),
          ),
        ],
      ),
    ],
  );
}

// Notifie GoRouter quand l'état auth change
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(label, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

// Export pour compatibilité — sera remplacé dans main par buildRouter(authBloc)
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashPage(),
    ),
  ],
);

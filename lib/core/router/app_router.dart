import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../shared/widgets/app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  redirect: _redirect,
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
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _PlaceholderPage(label: 'Accueil'),
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
          builder: (context, state) => const _PlaceholderPage(label: 'Profil'),
        ),
      ],
    ),
  ],
);

String? _redirect(BuildContext context, GoRouterState state) {
  // La logique de redirect sera enrichie en Phase 1 avec AuthBloc
  return null;
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

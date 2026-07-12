import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/catalog/domain/repositories/dish_repository.dart';
import '../../features/catalog/presentation/bloc/dish_bloc.dart';
import '../../features/catalog/presentation/pages/add_edit_dish_page.dart';
import '../../features/catalog/presentation/pages/dish_detail_page.dart';
import '../../features/catalog/presentation/pages/vendor_shop_preview_page.dart';
import '../../features/explore/presentation/bloc/explore_bloc.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/explore/presentation/pages/vendor_profile_page.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
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
      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupPage(),
      ),

      // ── Vendor profile (public, hors shell) ──────────────────────────────
      GoRoute(
        path: '/vendor/:vendorId',
        builder: (_, state) => RepositoryProvider.value(
          value: sl<AuthRepository>(),
          child: RepositoryProvider.value(
            value: sl<DishRepository>(),
            child: BlocProvider(
              create: (_) => sl<FavoritesBloc>(),
              child: VendorProfilePage(
                vendorId: state.pathParameters['vendorId']!,
              ),
            ),
          ),
        ),
      ),

      // ── Shell (bottom nav) ───────────────────────────────────────────────
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<DishBloc>()),
            BlocProvider(create: (_) => sl<ExploreBloc>()),
            BlocProvider(create: (_) => sl<FavoritesBloc>()),
            RepositoryProvider.value(value: sl<DishRepository>()),
            RepositoryProvider.value(value: sl<AuthRepository>()),
          ],
          child: AppShell(child: child),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.explore,
            builder: (_, __) => const ExplorePage(),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, __) => const _PlaceholderPage(
              label: 'Commandes',
              icon: Icons.receipt_long_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.posts,
            builder: (_, __) => const _PlaceholderPage(
              label: 'Publications',
              icon: Icons.forum_outlined,
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),

          // ── Settings ───────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, __) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, __) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'theme',
                builder: (_, __) => const ThemeCustomizationPage(),
              ),
              GoRoute(
                path: 'role',
                builder: (_, __) => const RoleChangePage(),
              ),
            ],
          ),

          // ── Vendor routes (inside shell) ───────────────────────────────
          GoRoute(
            path: AppRoutes.vendorAddDish,
            builder: (_, __) => const AddEditDishPage(),
          ),
          GoRoute(
            path: '/app/vendor/dishes/:dishId/edit',
            builder: (context, state) {
              final dishId = state.pathParameters['dishId']!;
              return FutureBuilder(
                future: sl<DishRepository>().getDish(dishId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return AddEditDishPage(dish: snap.data);
                },
              );
            },
          ),
          GoRoute(
            path: AppRoutes.vendorShopPreview,
            builder: (_, __) => const VendorShopPreviewPage(),
          ),

          // ── Dish detail (buyer) ───────────────────────────────────────
          GoRoute(
            path: AppRoutes.dishDetail,
            builder: (context, state) {
              final dishId = state.pathParameters['dishId']!;
              return FutureBuilder(
                future: sl<DishRepository>().getDish(dishId),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final dish = snap.data;
                  if (dish == null) {
                    return Scaffold(
                      appBar: AppBar(),
                      body: const Center(child: Text('Plat introuvable')),
                    );
                  }
                  return DishDetailPage(dish: dish);
                },
              );
            },
          ),

          // ── Favorites ─────────────────────────────────────────────────
          GoRoute(
            path: '/app/favorites',
            builder: (_, __) => const FavoritesPage(),
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
            Icon(icon,
                size: 48,
                color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Disponible en Phase 3',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

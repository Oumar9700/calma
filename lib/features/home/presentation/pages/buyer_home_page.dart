import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../../catalog/domain/repositories/dish_repository.dart';
import '../../../catalog/presentation/widgets/dish_card.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  List<Dish>? _featuredDishes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<FavoritesBloc>().add(LoadFavorites(authState.user.uid));
    }
  }

  Future<void> _loadDishes() async {
    try {
      final dishes = await context
          .read<DishRepository>()
          .fetchActiveDishes(availableToday: true);
      if (mounted) {
        setState(() {
          _featuredDishes = dishes.take(10).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: RefreshIndicator(
        color: context.colorPrimary,
        onRefresh: _loadDishes,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(user: user)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                child: Row(
                  children: [
                    Text(
                      'Disponibles aujourd\'hui',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.explore),
                      child: Text(
                        'Voir tout',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_featuredDishes == null || _featuredDishes!.isEmpty)
              SliverToBoxAdapter(
                child: _EmptyToday(
                  onExplore: () => context.go(AppRoutes.explore),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.60,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = _featuredDishes![index];
                      return DishCard(
                        dish: dish,
                        onTap: () => context.push(
                          AppRoutes.dishDetail
                              .replaceFirst(':dishId', dish.id),
                        ),
                        trailing: _FavBtn(dishId: dish.id, userId: user?.uid),
                      );
                    },
                    childCount: _featuredDishes!.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser? user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
            ? 'Bon après-midi'
            : 'Bonsoir';

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting${user != null ? ', ${user!.firstName}' : ''}',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurface,
                  ),
                ),
                Text(
                  'Que voulez-vous manger aujourd\'hui ?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.colorOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (user?.photoUrl != null)
            CircleAvatar(
              radius: 22.r,
              backgroundImage: CachedNetworkImageProvider(user!.photoUrl!),
            )
          else if (user != null)
            CircleAvatar(
              radius: 22.r,
              backgroundColor: context.colorPrimary.withValues(alpha: 0.15),
              child: Text(
                user!.initials,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavBtn extends StatelessWidget {
  final String dishId;
  final String? userId;
  const _FavBtn({required this.dishId, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId == null) return const SizedBox();
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFav = state is FavoritesLoaded && state.isFavoriteDish(dishId);
        return GestureDetector(
          onTap: () => context.read<FavoritesBloc>().add(
                ToggleFavorite(userId: userId!, dishId: dishId),
              ),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? Colors.red : context.colorOnSurfaceVariant,
            size: 20,
          ),
        );
      },
    );
  }
}

class _EmptyToday extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyToday({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_outlined, size: 56, color: context.colorBorder),
          const SizedBox(height: 16),
          Text(
            'Aucun plat disponible aujourd\'hui',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Découvrez tous les plats du marketplace',
            style:
                TextStyle(fontSize: 14, color: context.colorOnSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onExplore,
            child: Text(
              'Explorer',
              style: TextStyle(color: context.colorPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/catalog/domain/entities/dish.dart';
import '../../../../features/catalog/domain/repositories/dish_repository.dart';
import '../../../../features/catalog/presentation/widgets/dish_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<FavoritesBloc>().add(LoadFavorites(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back,
                            color: context.colorOnSurface, size: 24.w),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Mes favoris',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colorOnSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TabBar(
                    controller: _tabCtrl,
                    labelColor: context.colorPrimary,
                    unselectedLabelColor: context.colorOnSurfaceVariant,
                    indicatorColor: context.colorPrimary,
                    labelStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Plats'),
                      Tab(text: 'Vendeurs'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is! FavoritesLoaded) {
                    return const Center(
                      child: Text('Impossible de charger les favoris'),
                    );
                  }

                  final dishFavs = state.favorites.where((f) => f.isDish).toList();
                  final vendorFavs = state.favorites.where((f) => f.isVendor).toList();

                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      dishFavs.isEmpty
                          ? _EmptyFavs(
                              icon: Icons.restaurant_outlined,
                              label: 'Aucun plat favori',
                              action: 'Explorer les plats',
                              onAction: () => context.go(AppRoutes.explore),
                            )
                          : _DishFavsList(dishIds: dishFavs.map((f) => f.dishId!).toList()),
                      vendorFavs.isEmpty
                          ? _EmptyFavs(
                              icon: Icons.storefront_outlined,
                              label: 'Aucun vendeur favori',
                              action: 'Découvrir des vendeurs',
                              onAction: () => context.go(AppRoutes.explore),
                            )
                          : _VendorFavsList(
                              vendorIds: vendorFavs.map((f) => f.vendorId!).toList()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishFavsList extends StatelessWidget {
  final List<String> dishIds;
  const _DishFavsList({required this.dishIds});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<DishRepository>();
    return FutureBuilder<List<Dish?>>(
      future: Future.wait(dishIds.map((id) => repo.getDish(id))),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dishes = (snap.data ?? []).whereType<Dish>().toList();
        if (dishes.isEmpty) {
          return _EmptyFavs(
            icon: Icons.restaurant_outlined,
            label: 'Aucun plat favori',
            action: 'Explorer les plats',
            onAction: () => context.go(AppRoutes.explore),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          itemCount: dishes.length,
          itemBuilder: (context, i) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: DishListTile(dish: dishes[i]),
          ),
        );
      },
    );
  }
}

class _VendorFavsList extends StatelessWidget {
  final List<String> vendorIds;
  const _VendorFavsList({required this.vendorIds});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AuthRepository>();
    return FutureBuilder<List<AppUser?>>(
      future: Future.wait(vendorIds.map((id) => repo.getUserById(id))),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final vendors = (snap.data ?? []).whereType<AppUser>().toList();
        if (vendors.isEmpty) {
          return _EmptyFavs(
            icon: Icons.storefront_outlined,
            label: 'Aucun vendeur favori',
            action: 'Découvrir des vendeurs',
            onAction: () => context.go(AppRoutes.explore),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          itemCount: vendors.length,
          itemBuilder: (context, i) => _VendorTile(vendor: vendors[i]),
        );
      },
    );
  }
}

class _VendorTile extends StatelessWidget {
  final AppUser vendor;
  const _VendorTile({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendor/${vendor.uid}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.colorBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: context.colorPrimary.withValues(alpha: 0.12),
              backgroundImage: vendor.photoUrl != null
                  ? CachedNetworkImageProvider(vendor.photoUrl!)
                  : null,
              child: vendor.photoUrl == null
                  ? Text(
                      vendor.initials,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorPrimary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.shopName ?? vendor.fullName,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnSurface,
                    ),
                  ),
                  if (vendor.countryOfOrigin != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Cuisine de ${vendor.countryOfOrigin}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20.w, color: context.colorOnSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavs extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;
  final VoidCallback onAction;

  const _EmptyFavs({
    required this.icon,
    required this.label,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: context.colorBorder),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: TextStyle(color: context.colorPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

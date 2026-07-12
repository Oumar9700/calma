import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/dish.dart';
import '../bloc/dish_action_message.dart';
import '../bloc/dish_bloc.dart';
import '../bloc/dish_event.dart';
import '../bloc/dish_state.dart';
import '../widgets/dish_card.dart';

class VendorCatalogPage extends StatefulWidget {
  const VendorCatalogPage({super.key});

  @override
  State<VendorCatalogPage> createState() => _VendorCatalogPageState();
}

class _VendorCatalogPageState extends State<VendorCatalogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription<DishActionMessage>? _actionSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<DishBloc>().add(LoadVendorDishes(authState.user.uid));
    }
    _actionSub = context.read<DishBloc>().actionMessages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.text),
          backgroundColor: msg.result == DishActionResult.success
              ? AppColors.success
              : AppColors.error,
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _actionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(tabController: _tabController),
            Expanded(
              child: BlocBuilder<DishBloc, DishState>(
                builder: (context, state) {
                  final dishes = state is DishLoaded ? state.dishes : <Dish>[];
                  final isLoading = state is DishLoading || state is DishInitial;

                  return Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _DishList(
                            dishes: dishes,
                            filter: (d) => true,
                            label: 'Tous les plats',
                            onAdd: () => context.push(AppRoutes.vendorAddDish),
                          ),
                          _DishList(
                            dishes: dishes,
                            filter: (d) => d.isActive,
                            label: 'Plats actifs',
                            onAdd: () => context.push(AppRoutes.vendorAddDish),
                          ),
                        ],
                      ),
                      if (isLoading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state is DishError)
                        Positioned.fill(
                          child: ColoredBox(
                            color: context.colorScheme.surface,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_off_outlined,
                                        size: 48.w,
                                        color: context.colorOnSurfaceVariant),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'Impossible de charger vos plats',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.colorOnSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      state.message,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: context.colorOnSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.vendorAddDish),
        backgroundColor: context.colorPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un plat'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TabController tabController;
  const _Header({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ma boutique',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                    BlocBuilder<DishBloc, DishState>(
                      builder: (context, state) {
                        final count =
                            state is DishLoaded ? state.dishes.length : 0;
                        return Text(
                          '$count plat${count > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.vendorShopPreview),
                icon: Icon(Icons.storefront_outlined, size: 16.w),
                label: const Text('Aperçu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorPrimary,
                  side: BorderSide(color: context.colorPrimary),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TabBar(
            controller: tabController,
            labelColor: context.colorPrimary,
            unselectedLabelColor: context.colorOnSurfaceVariant,
            indicatorColor: context.colorPrimary,
            labelStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Tous'),
              Tab(text: 'Actifs'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DishList extends StatelessWidget {
  final List<Dish> dishes;
  final bool Function(Dish d) filter;
  final String label;
  final VoidCallback onAdd;

  const _DishList({
    required this.dishes,
    required this.filter,
    required this.label,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = dishes.where(filter).toList();

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final dish = filtered[index];
            return DishListTile(
              dish: dish,
              onTap: () => context.push(
                AppRoutes.vendorEditDish.replaceFirst(':dishId', dish.id),
              ),
              actions: [
                _ToggleButton(dish: dish),
                SizedBox(width: 4.w),
                _DeleteButton(dish: dish),
              ],
            );
          },
        ),
        if (filtered.isEmpty)
          Positioned.fill(
            child: dishes.isEmpty
                ? _EmptyState(onAdd: onAdd)
                : Center(
                    child: Text(
                      'Aucun plat dans cette catégorie',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final Dish dish;
  const _ToggleButton({required this.dish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<DishBloc>().add(
            ToggleDishActive(dish.id, isActive: !dish.isActive),
          ),
      child: Icon(
        dish.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
        size: 28.w,
        color: dish.isActive ? AppColors.success : context.colorBorder,
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final Dish dish;
  const _DeleteButton({required this.dish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context, dish),
      child: Icon(
        Icons.delete_outline,
        size: 22.w,
        color: context.colorOnSurfaceVariant,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Dish dish) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text('${dish.name} sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DishBloc>().add(DeleteDish(dish.id));
            },
            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64.w,
              color: context.colorBorder,
            ),
            SizedBox(height: 16.h),
            Text(
              'Votre boutique est vide',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: context.colorOnSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ajoutez votre premier plat pour commencer à vendre.',
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colorOnSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            AppButton.primary(label: 'Ajouter un plat', onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}

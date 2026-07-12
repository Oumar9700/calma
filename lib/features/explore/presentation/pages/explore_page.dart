import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../catalog/presentation/widgets/dish_card.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/explore_filter.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../widgets/filter_bottom_sheet.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ExploreBloc>().add(const LoadDishes());
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<FavoritesBloc>().add(LoadFavorites(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _searchCtrl,
              onSearch: (q) {
                final current = context.read<ExploreBloc>().state;
                final filter = current is ExploreLoaded
                    ? current.filter
                    : ExploreFilter.empty;
                context.read<ExploreBloc>().add(
                      UpdateFilter(
                        q.isEmpty
                            ? filter.copyWith(clearSearch: true)
                            : filter.copyWith(searchQuery: q),
                      ),
                    );
              },
              onFilter: () {
                final current = context.read<ExploreBloc>().state;
                final filter = current is ExploreLoaded
                    ? current.filter
                    : ExploreFilter.empty;
                FilterBottomSheet.show(
                  context,
                  initial: filter,
                  onApply: (f) {
                    final search = filter.searchQuery;
                    context.read<ExploreBloc>().add(
                          UpdateFilter(f.copyWith(searchQuery: search)),
                        );
                  },
                );
              },
            ),
            _ActiveFiltersRow(),
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  if (state is ExploreLoading || state is ExploreInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ExploreError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_outlined,
                              size: 48, color: context.colorBorder),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: TextStyle(
                                  color: context.colorOnSurfaceVariant)),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context
                                .read<ExploreBloc>()
                                .add(const LoadDishes()),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is ExploreLoaded) {
                    if (state.dishes.isEmpty) {
                      return _EmptyResults(
                        hasFilters: state.filter.hasActiveFilters,
                        onClear: () => context
                            .read<ExploreBloc>()
                            .add(const ClearFilters()),
                      );
                    }
                    return state.isGridView
                        ? _GridView(dishes: state.dishes)
                        : _ListView(dishes: state.dishes);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilter;

  const _SearchBar({
    required this.controller,
    required this.onSearch,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: context.colorSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Plat, pays, vendeur...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: context.colorOnSurfaceVariant,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: context.colorOnSurfaceVariant, size: 20.w),
                  suffixIcon: controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onSearch('');
                          },
                          child: Icon(Icons.clear,
                              size: 18.w,
                              color: context.colorOnSurfaceVariant),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              final filter = state is ExploreLoaded ? state.filter : ExploreFilter.empty;
              final count = filter.activeFilterCount;
              return Stack(
                children: [
                  GestureDetector(
                    onTap: onFilter,
                    child: Container(
                      width: 44.h,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: count > 0
                            ? context.colorPrimary
                            : context.colorSurfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: count > 0 ? Colors.white : context.colorOnSurface,
                        size: 20.w,
                      ),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(width: 8.w),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              final isGrid = state is ExploreLoaded && state.isGridView;
              return GestureDetector(
                onTap: () => context.read<ExploreBloc>().add(const ToggleViewMode()),
                child: Container(
                  width: 44.h,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: context.colorSurfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: context.colorOnSurface,
                    size: 20.w,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        if (state is! ExploreLoaded) return const SizedBox();
        final filter = state.filter;
        if (!filter.hasActiveFilters) return const SizedBox();

        final chips = <Widget>[];
        if (filter.countryOfOrigin != null) {
          chips.add(_FilterChip(
            label: filter.countryOfOrigin!,
            onRemove: () => context.read<ExploreBloc>().add(
                  UpdateFilter(filter.copyWith(clearCountry: true)),
                ),
          ));
        }
        if (filter.category != null) {
          chips.add(_FilterChip(
            label: filter.category!.label,
            onRemove: () => context.read<ExploreBloc>().add(
                  UpdateFilter(filter.copyWith(clearCategory: true)),
                ),
          ));
        }
        if (filter.availableToday) {
          chips.add(_FilterChip(
            label: 'Aujourd\'hui',
            onRemove: () => context.read<ExploreBloc>().add(
                  UpdateFilter(filter.copyWith(availableToday: false)),
                ),
          ));
        }
        if (filter.minRating != null) {
          chips.add(_FilterChip(
            label: '${filter.minRating}+ ★',
            onRemove: () => context.read<ExploreBloc>().add(
                  UpdateFilter(filter.copyWith(clearRating: true)),
                ),
          ));
        }

        return SizedBox(
          height: 36.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: chips,
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.colorPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colorPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: context.colorPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.w, color: context.colorPrimary),
          ),
        ],
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  final List dishes;
  const _GridView({required this.dishes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.60,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return DishCard(
          dish: dish,
          onTap: () => context.push(
            AppRoutes.dishDetail.replaceFirst(':dishId', dish.id),
          ),
          trailing: _FavoriteButton(dishId: dish.id),
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List dishes;
  const _ListView({required this.dishes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: DishListTile(
            dish: dish,
            onTap: () => context.push(
              AppRoutes.dishDetail.replaceFirst(':dishId', dish.id),
            ),
            actions: [_FavoriteButton(dishId: dish.id)],
          ),
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String dishId;
  const _FavoriteButton({required this.dishId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFav = state is FavoritesLoaded && state.isFavoriteDish(dishId);
        return GestureDetector(
          onTap: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is! Authenticated) return;
            context.read<FavoritesBloc>().add(
                  ToggleFavorite(userId: authState.user.uid, dishId: dishId),
                );
          },
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

class _EmptyResults extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;
  const _EmptyResults({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: context.colorBorder),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Aucun plat ne correspond' : 'Aucun plat disponible',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Essayez de modifier vos filtres'
                : 'Revenez plus tard !',
            style: TextStyle(fontSize: 14, color: context.colorOnSurfaceVariant),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Effacer les filtres',
                style: TextStyle(color: context.colorPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

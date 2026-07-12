import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../../catalog/domain/repositories/dish_repository.dart';
import '../../../catalog/presentation/widgets/dish_card.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class VendorProfilePage extends StatelessWidget {
  final String vendorId;
  const VendorProfilePage({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.read<AuthRepository>().getUserById(vendorId),
        context.read<DishRepository>().fetchVendorDishes(vendorId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(color: context.colorOnSurface),
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: Text(
                'Vendeur introuvable',
                style: TextStyle(color: context.colorOnSurfaceVariant),
              ),
            ),
          );
        }
        final results = snapshot.data!;
        final vendor = results[0] as AppUser?;
        final dishes = (results[1] as List<Dish>)
            .where((d) => d.isActive)
            .toList();

        if (vendor == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(color: context.colorOnSurface),
              backgroundColor: Colors.transparent,
            ),
            body: Center(
              child: Text(
                'Vendeur introuvable',
                style: TextStyle(color: context.colorOnSurfaceVariant),
              ),
            ),
          );
        }

        return _VendorProfileContent(vendor: vendor, dishes: dishes);
      },
    );
  }
}

class _VendorProfileContent extends StatelessWidget {
  final AppUser vendor;
  final List<Dish> dishes;

  const _VendorProfileContent({
    required this.vendor,
    required this.dishes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _CoverSliverAppBar(vendor: vendor),
          SliverToBoxAdapter(
            child: _VendorInfo(vendor: vendor),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Row(
                children: [
                  Text(
                    'Plats disponibles',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colorOnSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${dishes.length} plat${dishes.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (dishes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Center(
                  child: Text(
                    'Aucun plat disponible pour le moment',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.60,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => DishCard(dish: dishes[index]),
                  childCount: dishes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverSliverAppBar extends StatelessWidget {
  final AppUser vendor;
  const _CoverSliverAppBar({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: context.colorSurface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colorOnSurface),
        onPressed: () => context.pop(),
      ),
      actions: [
        BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            final isFav =
                state is FavoritesLoaded && state.isFavoriteVendor(vendor.uid);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.red : context.colorOnSurface,
              ),
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is! Authenticated) return;
                context.read<FavoritesBloc>().add(
                      ToggleFavorite(
                        userId: authState.user.uid,
                        vendorId: vendor.uid,
                      ),
                    );
              },
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: vendor.coverPhotoUrl != null
            ? CachedNetworkImage(
                imageUrl: vendor.coverPhotoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _DefaultCover(vendor: vendor),
              )
            : _DefaultCover(vendor: vendor),
      ),
    );
  }
}

class _DefaultCover extends StatelessWidget {
  final AppUser vendor;
  const _DefaultCover({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorPrimary.withValues(alpha: 0.15),
      child: Icon(
        Icons.storefront_outlined,
        size: 64.w,
        color: context.colorPrimary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _VendorInfo extends StatelessWidget {
  final AppUser vendor;
  const _VendorInfo({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36.r,
                backgroundColor: context.colorPrimary.withValues(alpha: 0.15),
                backgroundImage: vendor.photoUrl != null
                    ? CachedNetworkImageProvider(vendor.photoUrl!)
                    : null,
                child: vendor.photoUrl == null
                    ? Text(
                        vendor.initials,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colorPrimary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.shopName ?? vendor.fullName,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      vendor.fullName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                    if (vendor.countryOfOrigin != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Cuisine de ${vendor.countryOfOrigin}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (vendor.shopDescription?.isNotEmpty == true) ...[
            SizedBox(height: 16.h),
            Text(
              vendor.shopDescription!,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colorOnSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (vendor.specialties.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: vendor.specialties
                  .map((s) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: context.colorPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colorPrimary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          SizedBox(height: 16.h),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: _formatDays(vendor.availableDays),
          ),
          if (vendor.approximateLocation?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: vendor.approximateLocation!,
            ),
          ],
          if (vendor.paymentMethods.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.payment_outlined,
              label: vendor.paymentMethods.join(' · '),
            ),
          ],
          SizedBox(height: 16.h),
          Divider(color: context.colorBorder),
        ],
      ),
    );
  }

  String _formatDays(List<String> days) {
    if (days.isEmpty) return 'Jours non précisés';
    const abbrev = {
      'lundi': 'Lun',
      'mardi': 'Mar',
      'mercredi': 'Mer',
      'jeudi': 'Jeu',
      'vendredi': 'Ven',
      'samedi': 'Sam',
      'dimanche': 'Dim',
    };
    return days.map((d) => abbrev[d] ?? d).join(', ');
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.w, color: context.colorOnSurfaceVariant),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.colorOnSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

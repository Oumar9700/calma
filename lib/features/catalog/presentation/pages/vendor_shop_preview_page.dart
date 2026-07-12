import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/dish.dart';
import '../bloc/dish_bloc.dart';
import '../bloc/dish_event.dart';
import '../bloc/dish_state.dart';
import '../widgets/dish_card.dart';

class VendorShopPreviewPage extends StatefulWidget {
  const VendorShopPreviewPage({super.key});

  @override
  State<VendorShopPreviewPage> createState() => _VendorShopPreviewPageState();
}

class _VendorShopPreviewPageState extends State<VendorShopPreviewPage> {
  @override
  void initState() {
    super.initState();
    // Si le BLoC est en état initial (l'utilisateur arrive ici sans être passé
    // par VendorCatalogPage), on déclenche le chargement du stream Firestore.
    final dishState = context.read<DishBloc>().state;
    if (dishState is DishInitial) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<DishBloc>().add(LoadVendorDishes(authState.user.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _CoverHeader(user: user),
          SliverToBoxAdapter(
            child: _VendorInfo(user: user),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Row(
                children: [
                  Text(
                    'Mes plats',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colorOnSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: Icon(Icons.edit_outlined, size: 16.w),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<DishBloc, DishState>(
            builder: (context, state) {
              final dishes = state is DishLoaded
                  ? state.dishes.where((d) => d.isActive).toList()
                  : <Dish>[];

              if (dishes.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Center(
                      child: Text(
                        'Aucun plat actif pour l\'instant',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  final AppUser user;
  const _CoverHeader({required this.user});

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
      title: const Text('Aperçu boutique'),
      flexibleSpace: FlexibleSpaceBar(
        background: user.coverPhotoUrl != null
            ? CachedNetworkImage(
                imageUrl: user.coverPhotoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: context.colorPrimary.withValues(alpha: 0.15),
                ),
              )
            : Container(
                color: context.colorPrimary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 64.w,
                  color: context.colorPrimary.withValues(alpha: 0.4),
                ),
              ),
      ),
    );
  }
}

class _VendorInfo extends StatelessWidget {
  final AppUser user;
  const _VendorInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: context.colorPrimary.withValues(alpha: 0.15),
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 18.sp,
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
                      user.shopName ?? user.fullName,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                    if (user.countryOfOrigin != null)
                      Text(
                        'Cuisine de ${user.countryOfOrigin}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (user.shopDescription?.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            Text(
              user.shopDescription!,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colorOnSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (user.specialties.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: user.specialties.map((s) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                  )).toList(),
            ),
          ],
          if (user.availableDays.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14.w, color: context.colorOnSurfaceVariant),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _formatDays(user.availableDays),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (user.paymentMethods.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.payment_outlined,
                    size: 14.w, color: context.colorOnSurfaceVariant),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    user.paymentMethods.join(' · '),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          Divider(color: context.colorBorder),
        ],
      ),
    );
  }

  String _formatDays(List<String> days) {
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

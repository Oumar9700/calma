import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/dish.dart';

class DishDetailPage extends StatelessWidget {
  final Dish dish;
  const DishDetailPage({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _HeroHeader(dish: dish),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleRow(dish: dish),
                  SizedBox(height: 8.h),
                  _MetaRow(dish: dish),
                  if (dish.description?.isNotEmpty == true) ...[
                    SizedBox(height: 16.h),
                    Text(
                      dish.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.colorOnSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Divider(color: context.colorBorder),
                  SizedBox(height: 12.h),
                  if (dish.availableDays.isNotEmpty) ...[
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDays(dish.availableDays),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (dish.prepTimeMinutes != null) ...[
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: '${dish.prepTimeMinutes} min de préparation',
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (dish.dailyMaxQuantity != null) ...[
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: '${dish.dailyMaxQuantity} portions disponibles/jour',
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (dish.preorderEnabled) ...[
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: dish.preorderDeadlineDays != null
                          ? 'Précommande — ${dish.preorderDeadlineDays} jour${dish.preorderDeadlineDays! > 1 ? 's' : ''} à l\'avance minimum'
                          : 'Précommande disponible',
                      color: context.colorPrimary,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  SizedBox(height: 16.h),
                  _VendorPickupSection(vendorId: dish.vendorId),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(dish: dish),
    );
  }

  static String _formatDays(List<String> days) {
    const abbrev = {
      'lundi': 'Lun',
      'mardi': 'Mar',
      'mercredi': 'Mer',
      'jeudi': 'Jeu',
      'vendredi': 'Ven',
      'samedi': 'Sam',
      'dimanche': 'Dim',
    };
    return days.map((d) => abbrev[d] ?? d).join(' · ');
  }
}

class _HeroHeader extends StatefulWidget {
  final Dish dish;
  const _HeroHeader({required this.dish});

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.dish.photoUrls;
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      backgroundColor: context.colorSurface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colorOnSurface),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: photos.isEmpty
            ? _Placeholder()
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: photos[i],
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _Placeholder(),
                    ),
                  ),
                  if (photos.length > 1)
                    Positioned(
                      bottom: 12.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: _currentPage == i ? 16.w : 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: _currentPage == i ? 0.95 : 0.5),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorSurfaceContainerHighest,
      child: Icon(Icons.restaurant_outlined,
          size: 64.w, color: context.colorBorder),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final Dish dish;
  const _TitleRow({required this.dish});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            dish.name,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: context.colorOnSurface,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          '${dish.price.toStringAsFixed(2)} €',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: context.colorPrimary,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Dish dish;
  const _MetaRow({required this.dish});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[dish.category.label];
    if (dish.countryOfOrigin != null) parts.insert(0, dish.countryOfOrigin!);

    return Row(
      children: [
        Text(
          parts.join(' · '),
          style: TextStyle(
            fontSize: 13.sp,
            color: context.colorOnSurfaceVariant,
          ),
        ),
        if (dish.reviewCount > 0) ...[
          const Spacer(),
          Icon(Icons.star_rounded, size: 14.w, color: const Color(0xFFF59E0B)),
          SizedBox(width: 2.w),
          Text(
            '${dish.averageRating.toStringAsFixed(1)} (${dish.reviewCount})',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colorOnSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16.w, color: c),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: c),
          ),
        ),
      ],
    );
  }
}

// ─── Adresse de retrait vendeur ──────────────────────────────────────────────

class _VendorPickupSection extends StatefulWidget {
  final String vendorId;
  const _VendorPickupSection({required this.vendorId});

  @override
  State<_VendorPickupSection> createState() => _VendorPickupSectionState();
}

class _VendorPickupSectionState extends State<_VendorPickupSection> {
  late final Future<_VendorPickupData?> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<AuthRepository>().getUserById(widget.vendorId).then((u) {
      if (u == null) return null;
      return _VendorPickupData(
        address: u.pickupAddress,
        instructions: u.meetingPoint,
        latitude: u.pickupLatitude,
        longitude: u.pickupLongitude,
      );
    });
  }

  Future<void> _openMap(_VendorPickupData data) async {
    Uri uri;
    if (data.latitude != null && data.longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${data.latitude},${data.longitude}');
    } else if (data.address != null) {
      final encoded = Uri.encodeComponent(data.address!);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    } else {
      return;
    }
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_VendorPickupData?>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null || (data.address == null && data.instructions == null)) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: context.colorSurfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colorBorder.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.place_outlined,
                      size: 15.w, color: context.colorPrimary),
                  SizedBox(width: 6.w),
                  Text(
                    'Point de retrait',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnSurface,
                    ),
                  ),
                ],
              ),
              if (data.address != null) ...[
                SizedBox(height: 8.h),
                Text(
                  data.address!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colorOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (data.instructions != null) ...[
                SizedBox(height: 4.h),
                Text(
                  data.instructions!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colorOnSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (data.address != null || (data.latitude != null && data.longitude != null)) ...[
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () => _openMap(data),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          size: 13.w, color: context.colorPrimary),
                      SizedBox(width: 4.w),
                      Text(
                        'Voir sur la carte',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colorPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _VendorPickupData {
  final String? address;
  final String? instructions;
  final double? latitude;
  final double? longitude;

  const _VendorPickupData({
    this.address,
    this.instructions,
    this.latitude,
    this.longitude,
  });
}

class _BottomBar extends StatelessWidget {
  final Dish dish;
  const _BottomBar({required this.dish});

  @override
  Widget build(BuildContext context) {
    final canOrderToday = dish.isAvailableToday && dish.directOrderEnabled;
    final canPreorder = dish.preorderEnabled;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
        child: canOrderToday
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: () => context.push(
                      AppRoutes.orderCreate
                          .replaceFirst(':dishId', dish.id),
                      extra: dish,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorPrimary,
                      minimumSize: Size(double.infinity, 52.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Commander — ${dish.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (canPreorder) ...[
                    SizedBox(height: 8.h),
                    OutlinedButton(
                      onPressed: () => context.push(
                        AppRoutes.preorderCreate
                            .replaceFirst(':dishId', dish.id),
                        extra: dish,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        side: BorderSide(
                            color: context.colorPrimary.withOpacity(0.6)),
                      ),
                      child: Text(
                        'Précommander',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!dish.directOrderEnabled && dish.preorderEnabled)
                    // Plat uniquement en précommande
                    const SizedBox.shrink()
                  else
                    Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: context.colorSurfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(
                          dish.directOrderEnabled
                              ? 'Non disponible aujourd\'hui'
                              : 'Commande directe non disponible',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.colorOnSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (canPreorder) ...[
                    SizedBox(height: 8.h),
                    FilledButton(
                      onPressed: () => context.push(
                        AppRoutes.preorderCreate
                            .replaceFirst(':dishId', dish.id),
                        extra: dish,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colorPrimary,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Précommander',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

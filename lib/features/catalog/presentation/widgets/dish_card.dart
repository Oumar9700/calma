import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dish.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStatus;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
    this.trailing,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.colorBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Photo(dish: dish, showStatus: showStatus),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: context.colorOnSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dish.reviewCount > 0) ...[
                        SizedBox(width: 8.w),
                        Icon(Icons.star_rounded,
                            size: 14.w, color: const Color(0xFFF59E0B)),
                        SizedBox(width: 2.w),
                        Text(
                          dish.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: context.colorOnSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (dish.countryOfOrigin != null) ...[
                        Text(
                          dish.countryOfOrigin!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                        Text(' · ',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: context.colorOnSurfaceVariant)),
                      ],
                      Text(
                        dish.category.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${dish.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: context.colorPrimary,
                          ),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  if (dish.availableDays.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    _DaysRow(days: dish.availableDays),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final Dish dish;
  final bool showStatus;
  const _Photo({required this.dish, required this.showStatus});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
          child: dish.photoUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: dish.photoUrls.first,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 140.h,
                    color: context.colorSurfaceContainerHighest,
                  ),
                  errorWidget: (_, __, ___) => _PlaceholderImage(height: 140.h),
                )
              : _PlaceholderImage(height: 140.h),
        ),
        if (showStatus)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: dish.isActive ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                dish.isActive ? 'Actif' : 'Inactif',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (dish.preorderEnabled)
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: context.colorPrimary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Précommande',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double height;
  const _PlaceholderImage({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: context.colorSurfaceContainerHighest,
      child: Icon(
        Icons.restaurant_outlined,
        size: 40.w,
        color: context.colorBorder,
      ),
    );
  }
}

class _DaysRow extends StatelessWidget {
  final List<String> days;
  const _DaysRow({required this.days});

  static const _abbrev = {
    'lundi': 'L',
    'mardi': 'M',
    'mercredi': 'Me',
    'jeudi': 'J',
    'vendredi': 'V',
    'samedi': 'S',
    'dimanche': 'D',
  };

  static const _order = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 2.h,
      children: _order.map((day) {
        final active = days.contains(day);
        return Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: active
                ? context.colorPrimary.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(
              color: active ? context.colorPrimary : context.colorBorder,
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: Text(
              _abbrev[day] ?? day[0].toUpperCase(),
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: active ? context.colorPrimary : context.colorOnSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DishListTile extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onTap;
  final List<Widget> actions;

  const DishListTile({
    super.key,
    required this.dish,
    this.onTap,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: dish.photoUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: dish.photoUrls.first,
                        width: 72.w,
                        height: 72.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _PlaceholderImage(height: 72.w),
                      )
                    : _PlaceholderImage(height: 72.w),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: context.colorOnSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: dish.isActive
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          dish.isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: dish.isActive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    dish.category.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        '${dish.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colorPrimary,
                        ),
                      ),
                      if (dish.prepTimeMinutes != null) ...[
                        SizedBox(width: 8.w),
                        Icon(Icons.schedule_outlined,
                            size: 12.w, color: context.colorOnSurfaceVariant),
                        SizedBox(width: 2.w),
                        Text(
                          '${dish.prepTimeMinutes} min',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                      ],
                      const Spacer(),
                      ...actions,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

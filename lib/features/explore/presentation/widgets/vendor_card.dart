import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../auth/domain/entities/app_user.dart';

class VendorCard extends StatelessWidget {
  final AppUser vendor;
  final int dishCount;
  final VoidCallback? onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.dishCount,
    this.onTap,
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
            _CoverImage(vendor: vendor),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor:
                            context.colorPrimary.withValues(alpha: 0.15),
                        backgroundImage: vendor.photoUrl != null
                            ? CachedNetworkImageProvider(vendor.photoUrl!)
                            : null,
                        child: vendor.photoUrl == null
                            ? Text(
                                vendor.initials,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.colorPrimary,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          vendor.shopName ?? vendor.fullName,
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
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (vendor.countryOfOrigin != null)
                    Text(
                      'Cuisine de ${vendor.countryOfOrigin}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined,
                          size: 12.w, color: context.colorOnSurfaceVariant),
                      SizedBox(width: 4.w),
                      Text(
                        '$dishCount plat${dishCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                      if (vendor.availableDays.isNotEmpty) ...[
                        Text(
                          ' · ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                        Icon(Icons.calendar_today_outlined,
                            size: 11.w, color: context.colorOnSurfaceVariant),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            _formatDays(vendor.availableDays),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.colorOnSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  String _formatDays(List<String> days) {
    const abbrev = {
      'lundi': 'L',
      'mardi': 'M',
      'mercredi': 'Me',
      'jeudi': 'J',
      'vendredi': 'V',
      'samedi': 'S',
      'dimanche': 'D',
    };
    return days.map((d) => abbrev[d] ?? d[0].toUpperCase()).join('-');
  }
}

class _CoverImage extends StatelessWidget {
  final AppUser vendor;
  const _CoverImage({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
      child: vendor.coverPhotoUrl != null
          ? CachedNetworkImage(
              imageUrl: vendor.coverPhotoUrl!,
              height: 100.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _Placeholder(),
            )
          : _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: double.infinity,
      color: context.colorPrimary.withValues(alpha: 0.1),
      child: Icon(
        Icons.storefront_outlined,
        size: 36.w,
        color: context.colorPrimary.withValues(alpha: 0.4),
      ),
    );
  }
}

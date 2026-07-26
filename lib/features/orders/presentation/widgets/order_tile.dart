import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../domain/entities/order.dart';
import 'order_status_chip.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderTile({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'fr').format(order.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.colorBorder.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Photo or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 52.w,
                height: 52.w,
                color: context.colorSurfaceContainerHighest,
                child: Icon(
                  Icons.restaurant_outlined,
                  size: 24.w,
                  color: context.colorBorder,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.dishName,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${order.totalPrice.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  OrderStatusChip(status: order.status),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: context.colorOnSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

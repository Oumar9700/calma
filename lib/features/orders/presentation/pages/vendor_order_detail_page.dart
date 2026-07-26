import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../bloc/order_action_message.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';
import '../widgets/order_status_chip.dart';

class VendorOrderDetailPage extends StatelessWidget {
  final Order order;
  const VendorOrderDetailPage({super.key, required this.order});

  static Future<void> show(BuildContext context, Order order) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VendorOrderBloc>(),
        child: VendorOrderDetailPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm', 'fr').format(order.createdAt);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colorBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.dishName,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${order.quantity} portion${order.quantity > 1 ? 's' : ''} — ${order.totalPrice.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colorPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colorOnSurfaceVariant,
                ),
              ),
              SizedBox(height: 12.h),
              // Type + date précommande
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: context.colorSurfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          order.type == OrderType.preorder
                              ? Icons.schedule_outlined
                              : Icons.bolt_outlined,
                          size: 13.w,
                          color: context.colorOnSurfaceVariant,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          order.type == OrderType.preorder
                              ? 'Précommande'
                              : 'Commande directe',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (order.type == OrderType.preorder && order.preorderDate != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13.w, color: context.colorOnSurfaceVariant),
                          SizedBox(width: 6.w),
                          Text(
                            DateFormat('EEEE d MMMM yyyy', 'fr')
                                .format(order.preorderDate!),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: context.colorOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (order.note != null) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: context.colorSurfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note du client',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order.note!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Payment capture for preorders needing confirmation
              if (order.paymentCaptureUrl != null) ...[
                SizedBox(height: 16.h),
                Text(
                  'Capture de paiement',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: order.paymentCaptureUrl!,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: 160.h,
                      color: context.colorSurfaceContainerHighest,
                      child: Center(
                        child: Text(
                          'Impossible de charger la capture',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              // Action buttons based on status
              _ActionButtons(order: order),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Order order;
  const _ActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return Column(
          children: [
            _PrimaryButton(
              label: 'Accepter',
              onPressed: () {
                context.read<VendorOrderBloc>().add(
                      UpdateOrderStatus(order.id, OrderStatus.accepted),
                    );
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10.h),
            _DangerButton(
              label: 'Refuser',
              onPressed: () => _rejectWithReason(context),
            ),
          ],
        );
      case OrderStatus.accepted:
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: context.colorPrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colorPrimary.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  size: 18.w, color: context.colorPrimary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'En attente du paiement de l\'acheteur. Vous serez notifié lorsqu\'il envoie la preuve.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colorOnSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      case OrderStatus.awaitingConfirmation:
        return Column(
          children: [
            _PrimaryButton(
              label: 'Confirmer le paiement reçu',
              onPressed: () {
                context.read<VendorOrderBloc>().add(
                      UpdateOrderStatus(order.id, OrderStatus.preparing),
                    );
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 10.h),
            _DangerButton(
              label: 'Signaler un problème de paiement',
              onPressed: () => _rejectWithReason(context),
            ),
          ],
        );
      case OrderStatus.preparing:
        return _PrimaryButton(
          label: 'Marquer comme prête',
          onPressed: () {
            context.read<VendorOrderBloc>().add(
                  UpdateOrderStatus(order.id, OrderStatus.ready),
                );
            Navigator.pop(context);
          },
        );
      case OrderStatus.ready:
        return _PrimaryButton(
          label: 'Marquer comme terminée',
          onPressed: () {
            context.read<VendorOrderBloc>().add(
                  UpdateOrderStatus(order.id, OrderStatus.completed),
                );
            Navigator.pop(context);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _rejectWithReason(BuildContext context) async {
    final controller = TextEditingController();
    final bloc = context.read<VendorOrderBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Raison du refus'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: 'Expliquez pourquoi vous refusez...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      bloc.add(UpdateOrderStatus(
        order.id,
        OrderStatus.rejected,
        note: controller.text.trim().isEmpty ? null : controller.text.trim(),
      ));
      bloc.actionMessages.first.then((msg) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.text),
            backgroundColor: msg.result == OrderActionResult.error
                ? context.colorError
                : null,
          ),
        );
      });
      Navigator.pop(context);
    }
    controller.dispose();
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colorPrimary,
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _DangerButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        side: BorderSide(color: context.colorError.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: context.colorError,
        ),
      ),
    );
  }
}

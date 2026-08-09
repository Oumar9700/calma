import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/repositories/order_repository.dart';
import '../bloc/order_action_message.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/status_timeline.dart';

class BuyerOrderDetailPage extends StatelessWidget {
  final String orderId;

  const BuyerOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Order?>(
      stream: sl<OrderRepository>().watchOrder(orderId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final order = snap.data;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Commande introuvable')),
          );
        }
        return _OrderDetailContent(order: order);
      },
    );
  }
}

class _OrderDetailContent extends StatefulWidget {
  final Order order;
  const _OrderDetailContent({required this.order});

  @override
  State<_OrderDetailContent> createState() => _OrderDetailContentState();
}

class _OrderDetailContentState extends State<_OrderDetailContent> {
  XFile? _captureFile;
  bool _isUploading = false;

  Order get order => widget.order;

  Future<void> _pickCapture() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && mounted) setState(() => _captureFile = file);
  }

  void _submitCapture() {
    if (_captureFile == null) return;
    setState(() => _isUploading = true);
    final bloc = context.read<OrderBloc>();
    StreamSubscription<OrderActionMessage>? sub;
    sub = bloc.actionMessages.listen((msg) {
      sub?.cancel();
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.text),
          backgroundColor:
              msg.result == OrderActionResult.error ? context.colorError : null,
        ),
      );
    });
    bloc.add(UploadPaymentCapture(order.id, _captureFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = order.status == OrderStatus.pending ||
        order.status == OrderStatus.accepted;
    final canReport = order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.completed &&
        order.status != OrderStatus.rejected;
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm', 'fr').format(order.createdAt);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Détail de la commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.orders);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              if (order.dishPhotoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: order.dishPhotoUrl!,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _PhotoPlaceholder(),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              // Dish info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.dishName,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  OrderStatusChip(status: order.status),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${order.quantity} × ${order.dishPrice.toStringAsFixed(2)} € = ${order.totalPrice.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.colorPrimary,
                  fontWeight: FontWeight.w600,
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
                        'Ma note',
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
              SizedBox(height: 16.h),
              // Order type + preorder date info row
              _OrderInfoRow(order: order),
              SizedBox(height: 20.h),
              // Status timeline
              Text(
                'Suivi de commande',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colorOnSurface,
                ),
              ),
              SizedBox(height: 12.h),
              StatusTimeline(currentStatus: order.status),
              SizedBox(height: 24.h),
              // Payment section — contextual per status
              _PaymentSection(
                order: order,
                captureFile: _captureFile,
                isUploading: _isUploading,
                onPick: _pickCapture,
                onSubmit: _submitCapture,
              ),
              // Vendor note if rejected
              if (order.vendorNote != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: context.colorError.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: context.colorError.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message du vendeur',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colorError,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order.vendorNote!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colorOnSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
              // Action buttons
              if (canCancel)
                _CancelButton(order: order),
              if (canReport) ...[
                SizedBox(height: 12.h),
                _ReportButton(orderId: order.id),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  final Order order;
  final XFile? captureFile;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onSubmit;

  const _PaymentSection({
    required this.order,
    required this.captureFile,
    required this.isUploading,
    required this.onPick,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Commande acceptée → demander le paiement
    if (order.status == OrderStatus.accepted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner informatif
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 18.w, color: const Color(0xFF16A34A)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande acceptée !',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Envoyez le paiement de ${order.totalPrice.toStringAsFixed(2)} € via Wero ou Revolut au vendeur, puis joignez une capture d\'écran de la transaction ci-dessous.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colorOnSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Joindre la preuve de paiement',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
          ),
          SizedBox(height: 10.h),
          if (captureFile == null)
            OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(Icons.add_photo_alternate_outlined, size: 18.w),
              label: const Text('Choisir une capture'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                side: BorderSide(color: context.colorBorder),
              ),
            )
          else ...[
            GestureDetector(
              onTap: onPick,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  File(captureFile!.path),
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _CapturePlaceholder(
                    onTap: onPick,
                    label: 'capture sélectionnée — appuyer pour changer',
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            FilledButton(
              onPressed: isUploading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: context.colorPrimary,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child: isUploading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: context.colorOnPrimary),
                    )
                  : Text(
                      'Envoyer la preuve de paiement',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
          SizedBox(height: 24.h),
        ],
      );
    }

    // Preuve envoyée → en attente vendeur
    if (order.status == OrderStatus.awaitingConfirmation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: context.colorPrimary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: context.colorPrimary.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    size: 18.w, color: context.colorPrimary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Preuve de paiement envoyée. En attente de validation par le vendeur.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.colorOnSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (order.paymentCaptureUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: order.paymentCaptureUrl!,
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _PhotoPlaceholder(),
              ),
            ),
          ],
          SizedBox(height: 24.h),
        ],
      );
    }

    // Autres statuts : rien
    return const SizedBox.shrink();
  }
}

class _CapturePlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _CapturePlaceholder({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 32.w, color: context.colorBorder),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: context.colorOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final Order order;
  const _OrderInfoRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final isPreorder = order.type == OrderType.preorder;
    return Container(
      padding: EdgeInsets.all(12.w),
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
                isPreorder ? Icons.schedule_outlined : Icons.bolt_outlined,
                size: 14.w,
                color: context.colorOnSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Text(
                isPreorder ? 'Précommande' : 'Commande directe',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: context.colorOnSurfaceVariant,
                ),
              ),
            ],
          ),
          if (isPreorder && order.preorderDate != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14.w, color: context.colorOnSurfaceVariant),
                SizedBox(width: 6.w),
                Text(
                  'Livraison : ${DateFormat('EEEE d MMMM yyyy', 'fr').format(order.preorderDate!)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colorOnSurface,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorSurfaceContainerHighest,
      child: Icon(Icons.restaurant_outlined,
          size: 48.w, color: context.colorBorder),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final Order order;
  const _CancelButton({required this.order});

  bool get _isLate {
    if (order.preorderDate == null) return false;
    return order.preorderDate!.difference(DateTime.now()).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLate)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: context.colorError.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.colorError.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16.w, color: context.colorError),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Annulation tardive : moins de 24h avant la date de livraison. Cette annulation sera comptabilisée.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.colorError,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        OutlinedButton(
          onPressed: () => _confirm(context),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            side: BorderSide(color: context.colorError.withOpacity(0.6)),
          ),
          child: Text(
            'Annuler la commande',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colorError,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final isLate = _isLate;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: Text(isLate
            ? 'Annulation tardive (moins de 24h avant livraison). Cette action sera enregistrée sur ton profil. Confirmer ?'
            : 'Cette action est irréversible. Êtes-vous sûr ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<OrderBloc>().add(CancelOrder(order.id, isLate: isLate));
      final sub = context.read<OrderBloc>().actionMessages.listen((msg) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.text),
            backgroundColor: msg.result == OrderActionResult.success
                ? null
                : context.colorError,
          ),
        );
        if (context.mounted) context.pop();
      });
      Future.delayed(const Duration(seconds: 5), sub.cancel);
    }
  }
}

class _ReportButton extends StatelessWidget {
  final String orderId;
  const _ReportButton({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showReportDialog(context),
      icon: Icon(Icons.flag_outlined,
          size: 16.w, color: context.colorOnSurfaceVariant),
      label: Text(
        'Signaler un problème',
        style: TextStyle(
          fontSize: 13.sp,
          color: context.colorOnSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Décrivez le problème rencontré...',
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
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty && context.mounted) {
      context
          .read<OrderBloc>()
          .add(ReportProblem(orderId, controller.text.trim()));
      context.read<OrderBloc>().actionMessages.first.then((msg) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.text)),
        );
      });
    }
    controller.dispose();
  }
}

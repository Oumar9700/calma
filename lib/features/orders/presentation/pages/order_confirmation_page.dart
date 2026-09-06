import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/repositories/order_repository.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;

  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Order?>(
      future: sl<OrderRepository>().getOrder(orderId),
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
        return _ConfirmationContent(order: order);
      },
    );
  }
}

class _ConfirmationContent extends StatelessWidget {
  final Order order;
  const _ConfirmationContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final isPreorder = order.type == OrderType.preorder;
    final isGroupBuy = isPreorder &&
        order.slotId == null &&
        order.preorderGroupMinimum != null;
    final dateStr = DateFormat('dd/MM/yyyy', 'fr').format(order.createdAt);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
          child: Column(
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48.w,
                  color: const Color(0xFF22C55E),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                isGroupBuy ? 'Réservation enregistrée !' : 'Commande envoyée !',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colorOnSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isGroupBuy
                    ? 'Votre place est réservée. Aucun paiement maintenant.'
                    : 'En attente d\'acceptation du vendeur',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.colorOnSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              _OrderSummaryCard(order: order, dateStr: dateStr),
              SizedBox(height: 16.h),
              isGroupBuy
                  ? _GroupBuyNextStepTip(order: order)
                  : _NextStepTip(isPreorder: isPreorder),
              SizedBox(height: 32.h),
              FilledButton(
                onPressed: () => context.go(AppRoutes.orders),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorPrimary,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Voir mes commandes',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  side: BorderSide(
                      color: context.colorBorder.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  "Retour à l'accueil",
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepTip extends StatelessWidget {
  final bool isPreorder;
  const _NextStepTip({required this.isPreorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colorPrimary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 14.w, color: context.colorPrimary),
              SizedBox(width: 6.w),
              Text(
                'Prochaines étapes',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _TipRow(
            icon: Icons.storefront_outlined,
            text: 'Le vendeur examine votre demande et accepte ou refuse.',
          ),
          SizedBox(height: 6.h),
          _TipRow(
            icon: Icons.payment_outlined,
            text: 'Si acceptée, vous recevrez une notification pour envoyer le paiement (Wero / Revolut).',
          ),
          SizedBox(height: 6.h),
          _TipRow(
            icon: Icons.no_meals_outlined,
            text: 'Rien à payer pour le moment — attendez l\'acceptation.',
          ),
          if (isPreorder) ...[
            SizedBox(height: 6.h),
            _TipRow(
              icon: Icons.calendar_today_outlined,
              text: 'La livraison aura lieu à la date que vous avez choisie.',
            ),
          ],
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13.w, color: context.colorOnSurfaceVariant),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.colorOnSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final Order order;
  final String dateStr;

  const _OrderSummaryCard({required this.order, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colorSurfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Plat', value: order.dishName),
          SizedBox(height: 8.h),
          _Row(label: 'Quantité', value: '${order.quantity}'),
          SizedBox(height: 8.h),
          _Row(
              label: 'Total',
              value: '${order.totalPrice.toStringAsFixed(2)} €',
              valueStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: context.colorPrimary,
              )),
          SizedBox(height: 8.h),
          _Row(label: 'Type', value: order.type.label),
          SizedBox(height: 8.h),
          _Row(label: 'Date', value: dateStr),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _Row({required this.label, required this.value, this.valueStyle});
  // ignore: unused_element — présent pour symétrie future

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: context.colorOnSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: context.colorOnSurface,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _GroupBuyNextStepTip extends StatelessWidget {
  final Order order;
  const _GroupBuyNextStepTip({required this.order});

  @override
  Widget build(BuildContext context) {
    final minimum = order.preorderGroupMinimum ?? 1;
    final closingTime = order.preorderGroupClosingTime;
    final fmtClosure = closingTime != null
        ? DateFormat('EEEE d MMM à HH:mm', 'fr').format(closingTime)
        : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border:
            Border.all(color: context.colorPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 14.w, color: context.colorPrimary),
              SizedBox(width: 6.w),
              Text(
                'Groupe d\'achat',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _TipRow(
            icon: Icons.money_off_outlined,
            text: 'Aucun paiement maintenant — votre place est réservée.',
          ),
          SizedBox(height: 6.h),
          _TipRow(
            icon: Icons.people_outline,
            text:
                'Si $minimum réservation${minimum > 1 ? 's sont atteintes' : ' est atteinte'}${fmtClosure != null ? ' avant $fmtClosure' : ''}, vous recevrez une notification pour payer.',
          ),
          SizedBox(height: 6.h),
          _TipRow(
            icon: Icons.cancel_outlined,
            text:
                'Si le minimum n\'est pas atteint à la clôture, votre réservation est annulée automatiquement.',
          ),
          if (fmtClosure != null) ...[
            SizedBox(height: 6.h),
            _TipRow(
              icon: Icons.access_time_outlined,
              text: 'Clôture : $fmtClosure',
            ),
          ],
        ],
      ),
    );
  }
}

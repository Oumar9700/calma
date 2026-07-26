import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../bloc/order_action_message.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrderCreatePage extends StatefulWidget {
  final Dish dish;

  const OrderCreatePage({super.key, required this.dish});

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  int _quantity = 1;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  int get _maxQuantity => widget.dish.dailyMaxQuantity ?? 20;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_quantity < _maxQuantity) setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _submitOrder() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final now = DateTime.now();
    final order = Order(
      id: '',
      buyerId: authState.user.uid,
      vendorId: widget.dish.vendorId,
      dishId: widget.dish.id,
      dishName: widget.dish.name,
      dishPrice: widget.dish.price,
      dishPhotoUrl:
          widget.dish.photoUrls.isNotEmpty ? widget.dish.photoUrls.first : null,
      quantity: _quantity,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      status: OrderStatus.pending,
      type: OrderType.direct,
      createdAt: now,
      updatedAt: now,
    );

    setState(() => _isLoading = true);

    final bloc = context.read<OrderBloc>();
    StreamSubscription<OrderActionMessage>? sub;
    sub = bloc.actionMessages.listen((msg) {
      sub?.cancel();
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (msg.result == OrderActionResult.success) {
        final createdId = bloc.lastCreatedOrderId;
        if (createdId != null) {
          context.go(
            AppRoutes.orderConfirmation.replaceFirst(':orderId', createdId),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.text),
            backgroundColor: context.colorError,
          ),
        );
      }
    });

    bloc.add(CreateOrder(order));
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final total = dish.price * _quantity;

    return BlocListener<OrderBloc, OrderState>(
      listener: (_, __) {},
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          title: const Text('Commander'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DishSummaryCard(dish: dish),
                SizedBox(height: 16.h),
                const HowItWorksCard(isPreorder: false),
                SizedBox(height: 24.h),
                Text(
                  'Quantité',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                QuantitySelector(
                  quantity: _quantity,
                  onDecrement: _decrement,
                  onIncrement: _increment,
                  atMin: _quantity <= 1,
                  atMax: _quantity >= _maxQuantity,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Note de personnalisation',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Allergies, épices, préférences...',
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                          BorderSide(color: context.colorBorder, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: context.colorBorder.withValues(alpha: 0.5),
                          width: 1),
                    ),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: FilledButton(
              onPressed: _isLoading ? null : _submitOrder,
              style: FilledButton.styleFrom(
                backgroundColor: context.colorPrimary,
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colorOnPrimary,
                      ),
                    )
                  : Text(
                      'Envoyer la demande — ${total.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget partagé : explication du flux ──────────────────────────────────

class HowItWorksCard extends StatelessWidget {
  final bool isPreorder;
  const HowItWorksCard({this.isPreorder = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border:
            Border.all(color: context.colorPrimary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14.w, color: context.colorPrimary),
              SizedBox(width: 6.w),
              Text(
                'Comment ça fonctionne ?',
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
          _Step(
            number: '1',
            icon: Icons.send_outlined,
            label: isPreorder
                ? 'Vous envoyez votre demande de précommande'
                : 'Vous envoyez votre demande de commande',
          ),
          SizedBox(height: 6.h),
          _Step(
            number: '2',
            icon: Icons.storefront_outlined,
            label: 'Le vendeur l\'accepte ou la refuse',
          ),
          SizedBox(height: 6.h),
          _Step(
            number: '3',
            icon: Icons.payment_outlined,
            label: 'Si acceptée, vous payez (Wero / Revolut) et envoyez la preuve',
          ),
          SizedBox(height: 6.h),
          _Step(
            number: '4',
            icon: Icons.check_circle_outline,
            label: 'Le vendeur confirme le paiement et prépare votre commande',
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final IconData icon;
  final String label;
  const _Step(
      {required this.number, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorPrimary.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: context.colorPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(icon, size: 14.w, color: context.colorOnSurfaceVariant),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
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

// ── Widgets partagés (utilisés aussi depuis preorder_create_page) ─────────

class DishSummaryCard extends StatelessWidget {
  final Dish dish;
  const DishSummaryCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color:
            context.colorSurfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 56.w,
              height: 56.w,
              color: context.colorSurfaceContainerHighest,
              child: Icon(Icons.restaurant_outlined,
                  size: 28.w, color: context.colorBorder),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${dish.price.toStringAsFixed(2)} € / portion',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colorPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool atMin;
  final bool atMax;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.atMin,
    required this.atMax,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CounterButton(
          icon: Icons.remove,
          onPressed: atMin ? null : onDecrement,
        ),
        SizedBox(width: 20.w),
        Text(
          '$quantity',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: context.colorOnSurface,
          ),
        ),
        SizedBox(width: 20.w),
        _CounterButton(
          icon: Icons.add,
          onPressed: atMax ? null : onIncrement,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
          side: BorderSide(
            color: onPressed == null
                ? context.colorBorder.withValues(alpha: 0.3)
                : context.colorBorder,
          ),
        ),
        child: Icon(icon,
            size: 18.w,
            color: onPressed == null
                ? context.colorOnSurfaceVariant.withValues(alpha: 0.4)
                : context.colorOnSurface),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/entities/preorder_slot.dart';
import '../../domain/repositories/order_repository.dart';
import '../bloc/order_action_message.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import 'order_create_page.dart'
    show DishSummaryCard, QuantitySelector, HowItWorksCard, LegalDisclaimer;

// ── Types de créneaux disponibles ──────────────────────────────────────────

sealed class _DateOption {
  DateTime get date;
}

final class _FreeDate extends _DateOption {
  @override
  final DateTime date;
  final int reservedCount;
  final DateTime closingTime;
  final int effectiveMinimum; // minimum du plat, vaut 1 si non défini
  _FreeDate(this.date,
      {this.reservedCount = 0,
      required this.closingTime,
      this.effectiveMinimum = 1});
}

final class _SlotDate extends _DateOption {
  @override
  final DateTime date;
  final PreorderSlot slot;
  _SlotDate(this.date, this.slot);
}

// ── Page ───────────────────────────────────────────────────────────────────

class PreorderCreatePage extends StatefulWidget {
  final Dish dish;

  const PreorderCreatePage({super.key, required this.dish});

  @override
  State<PreorderCreatePage> createState() => _PreorderCreatePageState();
}

class _PreorderCreatePageState extends State<PreorderCreatePage> {
  int _quantity = 1;
  final _noteController = TextEditingController();
  _DateOption? _selectedOption;
  bool _isLoading = false;

  List<_DateOption> _options = [];
  bool _loadingDates = true;

  int get _maxQuantity {
    final sel = _selectedOption;
    if (sel is _SlotDate) return sel.slot.availableQuantity;
    return widget.dish.dailyMaxQuantity ?? 20;
  }

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final repo = sl<OrderRepository>();
    final slots = await repo
        .fetchAvailableSlots(widget.dish.id)
        .catchError((_) => <PreorderSlot>[]);

    final slotDates = <DateTime>{};
    final slotOptions = <_SlotDate>[];
    for (final s in slots) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      slotDates.add(d);
      slotOptions.add(_SlotDate(d, s));
    }

    final rawFreeDates = _computeFreeDates(slotDates);

    // Charger les compteurs pour toutes les dates libres (affichage count/min)
    final freeDates = <_FreeDate>[];
    if (rawFreeDates.isNotEmpty) {
      final counts = await Future.wait(
        rawFreeDates.map((fd) => repo.countPreordersForDate(widget.dish.id, fd.date)),
      );
      for (var i = 0; i < rawFreeDates.length; i++) {
        freeDates.add(_FreeDate(
          rawFreeDates[i].date,
          reservedCount: counts[i],
          closingTime: rawFreeDates[i].closingTime,
          effectiveMinimum: rawFreeDates[i].effectiveMinimum,
        ));
      }
    }

    final all = <_DateOption>[...slotOptions, ...freeDates]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (mounted) {
      setState(() {
        _options = all;
        _loadingDates = false;
      });
    }
  }

  List<_FreeDate> _computeFreeDates(Set<DateTime> excludedDates) {
    final dish = widget.dish;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = dish.preorderDeadlineDays ?? 1;
    final closingHours =
        dish.preorderClosingHoursBeforeDate ?? (deadline * 24);

    final effectiveMin = dish.preorderMinimum ?? 1;
    _FreeDate buildFreeDate(DateTime date) => _FreeDate(
          date,
          closingTime: date.subtract(Duration(hours: closingHours)),
          effectiveMinimum: effectiveMin,
        );

    // Calcul depuis les jours de vente
    const dayMap = {
      'lundi': 1, 'mardi': 2, 'mercredi': 3, 'jeudi': 4,
      'vendredi': 5, 'samedi': 6, 'dimanche': 7,
    };
    final result = <_FreeDate>[];
    for (var i = 1; i <= 28; i++) {
      final d = now.add(Duration(days: i));
      final date = DateTime(d.year, d.month, d.day);
      if (excludedDates.contains(date)) continue;
      for (final day in dish.availableDays) {
        if (dayMap[day] == d.weekday) {
          final cutoff = date.subtract(Duration(hours: closingHours));
          if (!cutoff.isBefore(today)) result.add(buildFreeDate(date));
          break;
        }
      }
      if (result.length >= 8) break;
    }
    return result;
  }

  void _increment() {
    if (_quantity < _maxQuantity) setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _pickDate() async {
    if (_options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucun créneau disponible pour ce plat'),
          backgroundColor: context.colorError,
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Choisir une date',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            ..._options.map((opt) => _DateOptionTile(
                  option: opt,
                  isSelected: _selectedOption?.date == opt.date,
                  onTap: () {
                    setState(() {
                      _selectedOption = opt;
                      // Ajuste la quantité si max a changé
                      final max = opt is _SlotDate
                          ? opt.slot.availableQuantity
                          : widget.dish.dailyMaxQuantity ?? 20;
                      if (_quantity > max) _quantity = max;
                    });
                    Navigator.pop(ctx);
                  },
                )),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showPaymentInstructions() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez choisir une date'),
          backgroundColor: context.colorError,
        ),
      );
      return;
    }
    _submitPreorder();
  }

  void _submitPreorder() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final option = _selectedOption;
    if (option == null) return;
    
    final now = DateTime.now();
    final order = Order(
      id: '',
      buyerId: authState.user.uid,
      vendorId: widget.dish.vendorId,
      dishId: widget.dish.id,
      dishName: widget.dish.name,
      dishPrice: widget.dish.price,
      dishPhotoUrl: widget.dish.photoUrls.isNotEmpty
          ? widget.dish.photoUrls.first
          : null,
      quantity: _quantity,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      status: OrderStatus.pending,
      type: OrderType.preorder,
      createdAt: now,
      updatedAt: now,
      preorderDate: option.date,
      slotId: option is _SlotDate ? option.slot.id : null,
      preorderGroupMinimum: option is _FreeDate
          ? widget.dish.preorderMinimum
          : null,
      preorderGroupClosingTime: option is _FreeDate
          ? option.closingTime
          : null,
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
          title: const Text('Précommander'),
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
                const HowItWorksCard(isPreorder: true),
                SizedBox(height: 24.h),
                Text(
                  'Date de la précommande',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                _loadingDates
                    ? Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: context.colorBorder.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: context.colorBorder
                                    .withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 18.w,
                                  color: context.colorOnSurfaceVariant),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  _selectedOption != null
                                      ? DateFormat('EEEE d MMMM yyyy', 'fr')
                                          .format(_selectedOption!.date)
                                      : _options.isEmpty
                                          ? 'Aucune date disponible'
                                          : 'Choisir une date',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: _selectedOption != null
                                        ? context.colorOnSurface
                                        : context.colorOnSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (_selectedOption is _SlotDate) ...[
                                SizedBox(width: 8.w),
                                _QuotaBadge(
                                    slot: (_selectedOption as _SlotDate).slot),
                              ],
                              if (_selectedOption is _FreeDate) ...[
                                SizedBox(width: 8.w),
                                _GroupBuyBadge(
                                  reserved: (_selectedOption as _FreeDate).reservedCount,
                                  minimum: (_selectedOption as _FreeDate).effectiveMinimum,
                                ),
                              ],
                              SizedBox(width: 4.w),
                              Icon(Icons.chevron_right,
                                  size: 18.w,
                                  color: context.colorOnSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                // Info groupe d'achat quand une date libre est sélectionnée
                if (_selectedOption is _FreeDate &&
                    widget.dish.preorderMinimum != null) ...[
                  SizedBox(height: 10.h),
                  _GroupBuyInfoBanner(
                    freeDate: _selectedOption as _FreeDate,
                    minimum: widget.dish.preorderMinimum!,
                  ),
                ],
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
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LegalDisclaimer(),
                SizedBox(height: 8.h),
                FilledButton(
                  onPressed: (_isLoading || _options.isEmpty)
                      ? null
                      : _showPaymentInstructions,
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
                          widget.dish.preorderMinimum != null &&
                                  _selectedOption is _FreeDate
                              ? 'Réserver ma place'
                              : 'Envoyer la demande — ${total.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _DateOptionTile extends StatelessWidget {
  final _DateOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEEE d MMMM yyyy', 'fr').format(option.date);
    final isSlot = option is _SlotDate;
    final slot = isSlot ? (option as _SlotDate).slot : null;
    final isFree = option is _FreeDate;
    final free = isFree ? option as _FreeDate : null;

    Widget? subtitle;
    if (isSlot && slot != null) {
      subtitle = Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Row(
          children: [
            Icon(Icons.people_outline, size: 12.w, color: context.colorOnSurfaceVariant),
            SizedBox(width: 4.w),
            Text(
              '${slot.bookedQuantity}/${slot.maxQuantity} réservé${slot.bookedQuantity > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 11.sp, color: context.colorOnSurfaceVariant),
            ),
            SizedBox(width: 8.w),
            _QuotaBadge(slot: slot),
          ],
        ),
      );
    } else if (isFree && free != null) {
      final fmtClosure = DateFormat('d MMM, HH:mm', 'fr').format(free.closingTime);
      final effectiveMin = free.effectiveMinimum;
      subtitle = Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Row(
          children: [
            Icon(Icons.people_outline, size: 12.w, color: context.colorOnSurfaceVariant),
            SizedBox(width: 4.w),
            Text(
              '${free.reservedCount}/$effectiveMin portion${effectiveMin > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 11.sp, color: context.colorOnSurfaceVariant),
            ),
            SizedBox(width: 8.w),
            Text(
              'Clôture : $fmtClosure',
              style: TextStyle(fontSize: 11.sp, color: context.colorOnSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
      title: Text(
        fmt,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: context.colorOnSurface,
        ),
      ),
      subtitle: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(Icons.check_circle, color: context.colorPrimary, size: 20.w),
        ],
      ),
    );
  }
}

// Badge "X/min" pour les group buys — minimum == -1 → mode "compteur seul"
class _GroupBuyBadge extends StatelessWidget {
  final int reserved;
  final int minimum;
  const _GroupBuyBadge({required this.reserved, required this.minimum});

  @override
  Widget build(BuildContext context) {
    final label = minimum > 0 ? '$reserved/$minimum' : '$reserved';
    final reached = minimum > 0 && reserved >= minimum;
    final color = reached
        ? const Color(0xFF22C55E)
        : context.colorOnSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 10.r, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Bannière d'info groupe d'achat affichée sous la sélection de date
class _GroupBuyInfoBanner extends StatelessWidget {
  final _FreeDate freeDate;
  final int minimum;
  const _GroupBuyInfoBanner({required this.freeDate, required this.minimum});

  @override
  Widget build(BuildContext context) {
    final fmtClosure =
        DateFormat('EEEE d MMM à HH:mm', 'fr').format(freeDate.closingTime);
    final reached = freeDate.reservedCount >= minimum;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.colorPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, size: 14.r, color: context.colorPrimary),
              SizedBox(width: 6.w),
              Text(
                'Groupe d\'achat',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimary,
                ),
              ),
              const Spacer(),
              _GroupBuyBadge(
                  reserved: freeDate.reservedCount, minimum: minimum),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            reached
                ? 'Minimum atteint ! Le vendeur peut valider.'
                : 'Aucun paiement maintenant. Si $minimum portion${minimum > 1 ? 's sont' : ' est'} atteinte${minimum > 1 ? 's' : ''} avant la clôture, vous recevrez une notification.',
            style: TextStyle(
              fontSize: 12.sp,
              color: context.colorOnSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Clôture : $fmtClosure',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: context.colorOnSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  final PreorderSlot slot;
  const _QuotaBadge({required this.slot});

  @override
  Widget build(BuildContext context) {
    final fillRatio =
        slot.maxQuantity > 0 ? slot.bookedQuantity / slot.maxQuantity : 0.0;
    final Color color;
    final String label;

    if (slot.isFull) {
      color = context.colorError;
      label = 'Complet';
    } else if (fillRatio >= 0.7) {
      color = const Color(0xFFF97316);
      label = '${slot.availableQuantity} restante${slot.availableQuantity > 1 ? 's' : ''}';
    } else {
      color = const Color(0xFF22C55E);
      label = '${slot.availableQuantity} disponible${slot.availableQuantity > 1 ? 's' : ''}';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

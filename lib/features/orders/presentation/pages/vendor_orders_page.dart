import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_type.dart';
import '../../domain/entities/preorder_slot.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';
import '../bloc/vendor_order_state.dart';
import '../widgets/order_status_chip.dart';
import 'vendor_order_detail_page.dart';

class VendorOrdersPage extends StatefulWidget {
  final int initialTab;
  const VendorOrdersPage({super.key, this.initialTab = 0});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context
            .read<VendorOrderBloc>()
            .add(LoadVendorOrders(authState.user.uid));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Mes commandes vendeur'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Commandes'),
            Tab(text: 'Créneaux libres'),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<VendorOrderBloc, VendorOrderState>(
          builder: (context, state) {
            if (state is VendorOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VendorOrderError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14.sp, color: context.colorError),
                  ),
                ),
              );
            }
            final orders =
                state is VendorOrderLoaded ? state.orders : <Order>[];
            final slots =
                state is VendorOrderLoaded ? state.slots : <PreorderSlot>[];

            return TabBarView(
              controller: _tabController,
              children: [
                _OrdersTab(orders: orders),
                _PlanningTab(slots: slots, orders: orders),
              ],
            );
          },
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => context.push(AppRoutes.vendorCreateSlot),
            backgroundColor: context.colorPrimary,
            child:
                Icon(Icons.add, color: context.colorOnPrimary),
          );
        },
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<Order> orders;
  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Groupes de précommandes simples (group buy)
    final groupBuyOrders = orders
        .where((o) =>
            o.type == OrderType.preorder &&
            o.slotId == null &&
            o.preorderGroupMinimum != null &&
            o.status == OrderStatus.pending)
        .toList();

    // Grouper par (dishId, jour)
    final Map<String, List<Order>> groups = {};
    for (final o in groupBuyOrders) {
      if (o.preorderDate == null) continue;
      final day = DateFormat('yyyy-MM-dd').format(o.preorderDate!);
      final key = '${o.dishId}::$day';
      groups.putIfAbsent(key, () => []).add(o);
    }

    // Commandes individuelles (hors group buy pending)
    final individualOrders = orders
        .where((o) =>
            !(o.type == OrderType.preorder &&
                o.slotId == null &&
                o.preorderGroupMinimum != null &&
                o.status == OrderStatus.pending))
        .toList();

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56.w, color: context.colorBorder),
              SizedBox(height: 16.h),
              Text(
                'Aucune commande',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        if (groups.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Groupes précommandes',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final entry = groups.entries.elementAt(i);
                return _PreorderGroupTile(groupOrders: entry.value);
              },
              childCount: groups.length,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        ],
        if (individualOrders.isNotEmpty) ...[
          if (groups.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Text(
                  'Autres commandes',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurfaceVariant,
                  ),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _VendorOrderTile(order: individualOrders[i]),
              childCount: individualOrders.length,
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
      ],
    );
  }
}

class _PreorderGroupTile extends StatelessWidget {
  final List<Order> groupOrders;
  const _PreorderGroupTile({required this.groupOrders});

  @override
  Widget build(BuildContext context) {
    final first = groupOrders.first;
    final minimum = first.preorderGroupMinimum ?? 1;
    //final count = groupOrders.length;
    final count = groupOrders
        .where((o) => o.status == OrderStatus.pending)
        .fold<int>(0, (sum, o) => sum + o.quantity);
    final reached = count >= minimum;
    final dateStr = first.preorderDate != null
        ? DateFormat('EEEE d MMMM yyyy', 'fr').format(first.preorderDate!)
        : '—';
    final closingStr = first.preorderGroupClosingTime != null
        ? DateFormat('d MMM à HH:mm', 'fr')
            .format(first.preorderGroupClosingTime!)
        : null;

    final color = reached ? const Color(0xFF22C55E) : context.colorPrimary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: reached
              ? const Color(0xFF22C55E).withValues(alpha: 0.4)
              : context.colorBorder.withValues(alpha: 0.3),
          width: reached ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  first.dishName,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colorOnSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$count / $minimum',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            dateStr,
            style: TextStyle(
                fontSize: 12.sp, color: context.colorOnSurfaceVariant),
          ),
          if (closingStr != null)
            Text(
              'Clôture : $closingStr',
              style: TextStyle(
                  fontSize: 11.sp, color: context.colorOnSurfaceVariant),
            ),
          SizedBox(height: 12.h),
          if (reached)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<VendorOrderBloc>().add(
                            BulkAcceptPreorderGroup(
                              groupOrders
                                  .where((o) => o.status == OrderStatus.pending)
                                  .map((o) => o.id)
                                  .toList(),
                              dishId: first.dishId,
                              preorderDate: first.preorderDate!,
                            ),
                          );
                    },
                    icon: Icon(Icons.check_circle_outline, size: 16.r),
                    label: const Text('Valider'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      minimumSize: Size(0, 38.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Refuser ce groupe ?'),
                          content: Text(
                            'Toutes les ${groupOrders.where((o) => o.status == OrderStatus.pending).length} '
                            'réservation${groupOrders.where((o) => o.status == OrderStatus.pending).length > 1 ? 's' : ''} '
                            'seront annulées et les acheteurs notifiés.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Annuler'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(ctx).colorScheme.error,
                              ),
                              child: const Text('Refuser'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        context.read<VendorOrderBloc>().add(
                              BulkRejectPreorderGroup(
                                groupOrders
                                    .where((o) => o.status == OrderStatus.pending)
                                    .map((o) => o.id)
                                    .toList(),
                                dishId: first.dishId,
                                preorderDate: first.preorderDate!,
                              ),
                            );
                      }
                    },
                    icon: Icon(Icons.cancel_outlined, size: 16.r),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                      minimumSize: Size(0, 38.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'En attente : $count/${minimum} réservation${minimum > 1 ? 's' : ''} requise${minimum > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12.sp,
                color: context.colorOnSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class _VendorOrderTile extends StatelessWidget {
  final Order order;
  const _VendorOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final initials = order.buyerId.length >= 2
        ? order.buyerId.substring(0, 2).toUpperCase()
        : '?';
    final dateStr =
        DateFormat('dd/MM HH:mm', 'fr').format(order.createdAt);

    return InkWell(
      onTap: () => VendorOrderDetailPage.show(context, order),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: context.colorBorder.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: context.colorPrimary.withOpacity(0.15),
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorPrimary,
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
                        '${order.quantity} portion${order.quantity > 1 ? 's' : ''} · $dateStr',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colorOnSurfaceVariant,
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
            TextButton(
              onPressed: () => VendorOrderDetailPage.show(context, order),
              style: TextButton.styleFrom(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
                backgroundColor:
                    context.colorPrimary.withOpacity(0.08),
              ),
              child: Text(
                'Gérer',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colorPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningTab extends StatelessWidget {
  final List<PreorderSlot> slots;
  final List<Order> orders;
  const _PlanningTab({required this.slots, required this.orders});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcomingSlots = slots
        .where((s) => !s.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();
    final pastSlots = slots
        .where((s) => s.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bannière explicative
        Container(
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: context.colorPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colorPrimary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18.w, color: context.colorPrimary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Un créneau = une date non prévue (spontanée) où vous mettez un plat en précommande.\n'
                  'Uniquement pour les plats déjà ouverts aux précommandes\n'
                  'Appuyez sur + pour créer un nouveau créneau.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colorOnSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (slots.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 56.w, color: context.colorBorder),
                  SizedBox(height: 16.h),
                  Text(
                    'Aucun créneau planifié',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colorOnSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Créez votre premier créneau avec le bouton +',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 80.h, top: 4.h),
              children: [
                if (upcomingSlots.isNotEmpty) ...[
                  _SectionHeader(label: 'En cours / à venir'),
                  ...upcomingSlots.map((s) => _SlotTile(
                        slot: s,
                        slotOrders:
                            orders.where((o) => o.slotId == s.id).toList(),
                      )),
                ],
                if (pastSlots.isNotEmpty) ...[
                  _SectionHeader(label: 'Passés'),
                  ...pastSlots.map((s) => _SlotTile(
                        slot: s,
                        slotOrders:
                            orders.where((o) => o.slotId == s.id).toList(),
                      )),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: context.colorOnSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SlotTile extends StatefulWidget {
  final PreorderSlot slot;
  final List<Order> slotOrders;
  const _SlotTile({required this.slot, required this.slotOrders});

  @override
  State<_SlotTile> createState() => _SlotTileState();
}

class _SlotTileState extends State<_SlotTile> {
  PreorderSlot get slot => widget.slot;
  List<Order> get slotOrders => widget.slotOrders;

  Future<void> _handleToggle(bool v) async {
    if (!v) {
      final activeOrders = slotOrders
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.accepted ||
              o.status == OrderStatus.awaitingConfirmation)
          .toList();

      if (activeOrders.isNotEmpty) {
        final confirmed = await _showDeactivateDialog(activeOrders.length);
        if (!mounted || confirmed != true) return;
        context.read<VendorOrderBloc>().add(
              DeactivateSlotWithCancellations(
                slot.id,
                activeOrders.map((o) => o.id).toList(),
              ),
            );
        return;
      }
    }
    if (!mounted) return;
    context
        .read<VendorOrderBloc>()
        .add(ToggleSlotActive(slot.id, isActive: v));
  }

  Future<bool?> _showDeactivateDialog(int count) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver ce créneau ?'),
        content: Text(
          '$count réservation${count > 1 ? 's' : ''} active${count > 1 ? 's' : ''} ser${count > 1 ? 'ont' : 'a'} annulée${count > 1 ? 's' : ''} '
          'et les acheteurs seront notifiés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr').format(slot.date);
    final fillRatio = slot.maxQuantity > 0
        ? slot.bookedQuantity / slot.maxQuantity
        : 0.0;
    final isToday = _isSameDay(slot.date, DateTime.now());
    final isPast = slot.date.isBefore(DateTime.now()) && !isToday;

    Color progressColor;
    if (slot.isFull) {
      progressColor = context.colorError;
    } else if (fillRatio >= 0.7) {
      progressColor = const Color(0xFFF97316); // orange
    } else {
      progressColor = const Color(0xFF22C55E); // vert
    }

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: () => _showSlotDetail(context),
        child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isToday
                ? context.colorPrimary.withValues(alpha: 0.4)
                : context.colorBorder.withValues(alpha: 0.3),
            width: isToday ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    slot.dishName,
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
                SizedBox(width: 8.w),
                // Badge statut
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: (!slot.isActive
                            ? context.colorOnSurfaceVariant
                            : slot.isFull
                                ? context.colorError
                                : const Color(0xFF22C55E))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    !slot.isActive
                        ? 'Inactif'
                        : slot.isFull
                            ? 'Complet'
                            : 'Actif',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: !slot.isActive
                          ? context.colorOnSurfaceVariant
                          : slot.isFull
                              ? context.colorError
                              : const Color(0xFF22C55E),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(isToday ? Icons.today_outlined : Icons.calendar_today_outlined,
                    size: 13.w,
                    color: isToday ? context.colorPrimary : context.colorOnSurfaceVariant),
                SizedBox(width: 4.w),
                Text(
                  isToday ? 'Aujourd\'hui' : dateStr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    color: isToday ? context.colorPrimary : context.colorOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Barre de progression
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${slot.bookedQuantity} réservée${slot.bookedQuantity > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: context.colorOnSurface,
                            ),
                          ),
                          Text(
                            slot.isFull
                                ? 'Complet !'
                                : '${slot.availableQuantity} disponible${slot.availableQuantity > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: slot.isFull
                                  ? context.colorError
                                  : context.colorOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: fillRatio.clamp(0.0, 1.0),
                          backgroundColor:
                              context.colorSurfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 6.h,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${slot.maxQuantity} portion${slot.maxQuantity > 1 ? 's' : ''} au total',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Switch(
                  value: slot.isActive,
                  onChanged: isPast ? null : _handleToggle,
                  activeColor: context.colorPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showSlotDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SlotDetailSheet(slot: slot, slotOrders: slotOrders),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SlotDetailSheet extends StatelessWidget {
  final PreorderSlot slot;
  final List<Order> slotOrders;
  const _SlotDetailSheet({required this.slot, required this.slotOrders});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEEE d MMMM yyyy', 'fr').format(slot.date);
    final fillRatio =
        slot.maxQuantity > 0 ? slot.bookedQuantity / slot.maxQuantity : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.colorBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.dishName,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: context.colorOnSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.colorOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${slot.bookedQuantity}/${slot.maxQuantity}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: context.colorPrimary,
                        ),
                      ),
                      Text(
                        'réservations',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: fillRatio.clamp(0.0, 1.0),
                  backgroundColor: context.colorSurfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    slot.isFull
                        ? context.colorError
                        : fillRatio >= 0.7
                            ? const Color(0xFFF97316)
                            : const Color(0xFF22C55E),
                  ),
                  minHeight: 6.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: context.colorBorder.withValues(alpha: 0.3)),
            // Orders list
            Expanded(
              child: slotOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 40.w, color: context.colorBorder),
                          SizedBox(height: 12.h),
                          Text(
                            'Aucune réservation',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: context.colorOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                      itemCount: slotOrders.length,
                      itemBuilder: (_, i) {
                        final order = slotOrders[i];
                        final initials = order.buyerId.length >= 2
                            ? order.buyerId.substring(0, 2).toUpperCase()
                            : '?';
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: context.colorSurfaceContainerHighest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16.r,
                                backgroundColor:
                                    context.colorPrimary.withValues(alpha: 0.15),
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: context.colorPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  '${order.quantity} portion${order.quantity > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: context.colorOnSurface,
                                  ),
                                ),
                              ),
                              OrderStatusChip(status: order.status),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

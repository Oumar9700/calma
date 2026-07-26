import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../catalog/domain/entities/dish.dart';
import '../../../catalog/domain/repositories/dish_repository.dart';
import '../../domain/entities/preorder_slot.dart';
import '../bloc/order_action_message.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';

class VendorCreateSlotPage extends StatefulWidget {
  const VendorCreateSlotPage({super.key});

  @override
  State<VendorCreateSlotPage> createState() => _VendorCreateSlotPageState();
}

class _VendorCreateSlotPageState extends State<VendorCreateSlotPage> {
  Dish? _selectedDish;
  DateTime? _selectedDate;
  int _maxQuantity = 5;
  bool _isLoading = false;

  List<Dish> _dishes = [];
  bool _dishesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    try {
      final dishes = await sl<DishRepository>().fetchVendorDishes(authState.user.uid);
      if (mounted) {
        setState(() {
          _dishes = dishes.where((d) => d.isActive).toList();
          _dishesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dishesLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedDish == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un plat et une date'),
          backgroundColor: context.colorError,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    setState(() => _isLoading = true);

    final slot = PreorderSlot(
      id: '',
      vendorId: authState.user.uid,
      dishId: _selectedDish!.id,
      dishName: _selectedDish!.name,
      dishPhotoUrl: _selectedDish!.photoUrls.isNotEmpty
          ? _selectedDish!.photoUrls.first
          : null,
      price: _selectedDish!.price,
      date: _selectedDate!,
      maxQuantity: _maxQuantity,
      bookedQuantity: 0,
      isActive: true,
    );

    final bloc = context.read<VendorOrderBloc>();
    StreamSubscription<OrderActionMessage>? sub;
    sub = bloc.actionMessages.listen((msg) {
      sub?.cancel();
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.text),
          backgroundColor: msg.result == OrderActionResult.error
              ? context.colorError
              : null,
        ),
      );
      if (msg.result == OrderActionResult.success) context.pop();
    });

    bloc.add(CreatePreorderSlot(slot));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Créer un créneau'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _dishesLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Plat'),
                    SizedBox(height: 8.h),
                    _dishes.isEmpty
                        ? Text(
                            'Aucun plat actif trouvé',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.colorOnSurfaceVariant,
                            ),
                          )
                        : DropdownButtonFormField<Dish>(
                            value: _selectedDish,
                            hint: Text(
                              'Choisir un plat',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: context.colorOnSurfaceVariant,
                              ),
                            ),
                            items: _dishes
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        '${d.name} — ${d.price.toStringAsFixed(2)} €',
                                        style:
                                            TextStyle(fontSize: 14.sp),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDish = v),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: context.colorBorder.withOpacity(0.5)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 12.h),
                            ),
                          ),
                    SizedBox(height: 20.h),
                    _Label('Date'),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: context.colorBorder.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 18.w,
                                color: context.colorOnSurfaceVariant),
                            SizedBox(width: 10.w),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('EEEE d MMMM yyyy', 'fr')
                                      .format(_selectedDate!)
                                  : 'Choisir une date',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _selectedDate != null
                                    ? context.colorOnSurface
                                    : context.colorOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _Label('Quantité maximum'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _SmallButton(
                          icon: Icons.remove,
                          onPressed: _maxQuantity > 1
                              ? () =>
                                  setState(() => _maxQuantity--)
                              : null,
                        ),
                        SizedBox(width: 20.w),
                        Text(
                          '$_maxQuantity',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: context.colorOnSurface,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        _SmallButton(
                          icon: Icons.add,
                          onPressed: _maxQuantity < 50
                              ? () =>
                                  setState(() => _maxQuantity++)
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
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
                              'Créer le créneau',
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
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: context.colorOnSurface,
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _SmallButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38.w,
      height: 38.w,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
          side: BorderSide(
            color: onPressed == null
                ? context.colorBorder.withOpacity(0.3)
                : context.colorBorder,
          ),
        ),
        child: Icon(icon,
            size: 18.w,
            color: onPressed == null
                ? context.colorOnSurfaceVariant.withOpacity(0.4)
                : context.colorOnSurface),
      ),
    );
  }
}

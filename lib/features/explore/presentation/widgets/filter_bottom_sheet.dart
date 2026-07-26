import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../catalog/domain/entities/dish_category.dart';
import '../../domain/entities/explore_filter.dart';

const _kDays = [
  'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
];
const _kDayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

class FilterBottomSheet extends StatefulWidget {
  final ExploreFilter initial;
  final ValueChanged<ExploreFilter> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ExploreFilter initial,
    required ValueChanged<ExploreFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(initial: initial, onApply: onApply),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ExploreFilter _filter;
  final _countryCtrl = TextEditingController();

  static const _ratings = [3.0, 3.5, 4.0, 4.5];

  @override
  void initState() {
    super.initState();
    _filter = widget.initial;
    _countryCtrl.text = _filter.countryOfOrigin ?? '';
  }

  @override
  void dispose() {
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 20.h),
          Row(
            children: [
              Text(
                'Filtres',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colorOnSurface,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _filter = ExploreFilter.empty;
                  _countryCtrl.clear();
                }),
                child: Text(
                  'Réinitialiser',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _Label('Pays d\'origine'),
          SizedBox(height: 8.h),
          TextField(
            controller: _countryCtrl,
            decoration: InputDecoration(
              hintText: 'Ex: Bénin, Sénégal...',
              hintStyle: TextStyle(
                  fontSize: 14.sp, color: context.colorOnSurfaceVariant),
              filled: true,
              fillColor: context.colorSurfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (v) => setState(
              () => _filter = _filter.copyWith(
                countryOfOrigin: v.isEmpty ? null : v,
                clearCountry: v.isEmpty,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _Label('Catégorie'),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: DishCategory.values.map((cat) {
              final isSelected = _filter.category == cat;
              return GestureDetector(
                onTap: () => setState(
                  () => _filter = isSelected
                      ? _filter.copyWith(clearCategory: true)
                      : _filter.copyWith(category: cat),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorPrimary
                        : context.colorSurfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? context.colorPrimary
                          : context.colorBorder,
                    ),
                  ),
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : context.colorOnSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          _Label('Note minimale'),
          SizedBox(height: 8.h),
          Row(
            children: _ratings.map((r) {
              final isSelected = _filter.minRating == r;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => setState(
                    () => _filter = isSelected
                        ? _filter.copyWith(clearRating: true)
                        : _filter.copyWith(minRating: r),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colorPrimary
                          : context.colorSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? context.colorPrimary
                            : context.colorBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14.w,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFF59E0B)),
                        SizedBox(width: 4.w),
                        Text(
                          '$r+',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : context.colorOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.today_outlined,
                  size: 16.w, color: context.colorOnSurface),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Disponibles aujourd\'hui',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colorOnSurface,
                  ),
                ),
              ),
              Switch(
                value: _filter.availableToday,
                onChanged: (v) =>
                    setState(() => _filter = _filter.copyWith(availableToday: v)),
                activeColor: context.colorPrimary,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _Label('Disponible ce jour'),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: List.generate(_kDays.length, (i) {
              final day = _kDays[i];
              final isSelected = _filter.availableDay == day;
              return GestureDetector(
                onTap: () => setState(() => _filter = isSelected
                    ? _filter.copyWith(clearDay: true)
                    : _filter.copyWith(availableDay: day)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorPrimary
                        : context.colorSurfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? context.colorPrimary : context.colorBorder,
                    ),
                  ),
                  child: Text(
                    _kDayLabels[i],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : context.colorOnSurface,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20.h),
          _Label('Type de commande'),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _OrderTypeChip(
                label: 'Commande directe',
                icon: Icons.bolt_outlined,
                value: OrderTypeFilter.direct,
                selected: _filter.orderType,
                onTap: (v) => setState(() => _filter = _filter.orderType == v
                    ? _filter.copyWith(clearOrderType: true)
                    : _filter.copyWith(orderType: v)),
              ),
              _OrderTypeChip(
                label: 'Précommande',
                icon: Icons.schedule_outlined,
                value: OrderTypeFilter.preorder,
                selected: _filter.orderType,
                onTap: (v) => setState(() => _filter = _filter.orderType == v
                    ? _filter.copyWith(clearOrderType: true)
                    : _filter.copyWith(orderType: v)),
              ),
              _OrderTypeChip(
                label: 'Les deux',
                icon: Icons.swap_horiz_outlined,
                value: OrderTypeFilter.both,
                selected: _filter.orderType,
                onTap: (v) => setState(() => _filter = _filter.orderType == v
                    ? _filter.copyWith(clearOrderType: true)
                    : _filter.copyWith(orderType: v)),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.colorPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Appliquer les filtres',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final OrderTypeFilter value;
  final OrderTypeFilter? selected;
  final ValueChanged<OrderTypeFilter> onTap;

  const _OrderTypeChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorPrimary
              : context.colorSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? context.colorPrimary : context.colorBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.w,
              color: isSelected ? Colors.white : context.colorOnSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.colorOnSurface,
              ),
            ),
          ],
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
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: context.colorOnSurface,
      ),
    );
  }
}

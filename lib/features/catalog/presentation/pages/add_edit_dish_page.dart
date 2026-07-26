import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/dish_category.dart';
import '../bloc/dish_action_message.dart';
import '../bloc/dish_bloc.dart';
import '../bloc/dish_event.dart';

class AddEditDishPage extends StatefulWidget {
  final Dish? dish;
  const AddEditDishPage({super.key, this.dish});

  bool get isEditing => dish != null;

  @override
  State<AddEditDishPage> createState() => _AddEditDishPageState();
}

class _AddEditDishPageState extends State<AddEditDishPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  final _maxQtyCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _deadlineDaysCtrl = TextEditingController();

  DishCategory _category = DishCategory.mainDish;
  bool _preorderEnabled = false;
  bool _directOrderEnabled = true;
  bool _isActive = true;
  List<String> _availableDays = [];
  List<String> _photoUrls = [];
  bool _uploading = false;
  bool _saving = false;

  StreamSubscription<DishActionMessage>? _actionSub;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    if (d != null) {
      _nameCtrl.text = d.name;
      _descCtrl.text = d.description ?? '';
      _priceCtrl.text = d.price.toString();
      _prepCtrl.text = d.prepTimeMinutes?.toString() ?? '';
      _maxQtyCtrl.text = d.dailyMaxQuantity?.toString() ?? '';
      _countryCtrl.text = d.countryOfOrigin ?? '';
      _regionCtrl.text = d.region ?? '';
      _category = d.category;
      _preorderEnabled = d.preorderEnabled;
      _deadlineDaysCtrl.text = d.preorderDeadlineDays?.toString() ?? '';
      _directOrderEnabled = d.directOrderEnabled;
      _isActive = d.isActive;
      _availableDays = List.from(d.availableDays);
      _photoUrls = List.from(d.photoUrls);
    }

    // Dans AddEditDishPage, simplifie le listener :
    _actionSub = context.read<DishBloc>().actionMessages.listen((msg) {
      if (!mounted || !_saving) return;
      setState(() => _saving = false);
      if (msg.result == DishActionResult.success) {
        context.pop(); // pas de snackbar ici, VendorCatalogPage s'en charge déjà
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.text), backgroundColor: AppColors.error),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _prepCtrl.dispose();
    _maxQtyCtrl.dispose();
    _countryCtrl.dispose();
    _regionCtrl.dispose();
    _deadlineDaysCtrl.dispose();
    _actionSub?.cancel();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    setState(() => _uploading = true);
    try {
      final dishId = widget.dish?.id ?? 'new_${DateTime.now().millisecondsSinceEpoch}';
      final url = await sl<StorageService>().uploadDishPhoto(
        authState.user.uid,
        dishId,
        File(picked.path),
      );
      setState(() {
        _photoUrls.add(url);
        _uploading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur upload : $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_availableDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un jour de vente.')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final dish = Dish(
      id: widget.dish?.id ?? '',
      vendorId: authState.user.uid,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      countryOfOrigin:
          _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
      region: _regionCtrl.text.trim().isEmpty ? null : _regionCtrl.text.trim(),
      category: _category,
      photoUrls: _photoUrls,
      price: double.parse(_priceCtrl.text.trim().replaceAll(',', '.')),
      prepTimeMinutes: _prepCtrl.text.isEmpty ? null : int.tryParse(_prepCtrl.text),
      dailyMaxQuantity:
          _maxQtyCtrl.text.isEmpty ? null : int.tryParse(_maxQtyCtrl.text),
      preorderEnabled: _preorderEnabled,
      preorderDeadlineDays: _preorderEnabled && _deadlineDaysCtrl.text.trim().isNotEmpty
          ? int.tryParse(_deadlineDaysCtrl.text.trim())
          : null,
      directOrderEnabled: _directOrderEnabled,
      isActive: _isActive,
      availableDays: _availableDays,
      createdAt: widget.dish?.createdAt ?? DateTime.now(),
      averageRating: widget.dish?.averageRating ?? 0.0,
      reviewCount: widget.dish?.reviewCount ?? 0,
    );

    setState(() => _saving = true);

    if (widget.isEditing) {
      context.read<DishBloc>().add(UpdateDish(dish));
    } else {
      context.read<DishBloc>().add(CreateDish(dish));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back,
                          color: context.colorOnSurface, size: 24.w),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.isEditing ? 'Modifier le plat' : 'Ajouter un plat',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PhotoPicker(
                    photoUrls: _photoUrls,
                    uploading: _uploading,
                    onAdd: _pickPhoto,
                    onRemove: (url) => setState(() => _photoUrls.remove(url)),
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Informations'),
                  SizedBox(height: 12.h),
                  AppTextField(
                    label: 'Nom du plat *',
                    hint: 'Ex: Foufou de manioc',
                    controller: _nameCtrl,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Description',
                    hint: 'Décrivez votre plat...',
                    controller: _descCtrl,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  _CategoryPicker(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Pays d\'origine',
                          hint: 'Ex: Bénin',
                          controller: _countryCtrl,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppTextField(
                          label: 'Région',
                          hint: 'Ex: Côte',
                          controller: _regionCtrl,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Prix & disponibilité'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Prix (€) *',
                          hint: '0.00',
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (double.tryParse(v.replaceAll(',', '.')) == null) {
                              return 'Invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppTextField(
                          label: 'Préparation (min)',
                          hint: '30',
                          controller: _prepCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Quantité max / jour',
                    hint: 'Laisser vide = illimité',
                    controller: _maxQtyCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  _SwitchRow(
                    label: 'Commande directe activée',
                    value: _directOrderEnabled,
                    onChanged: (v) => setState(() => _directOrderEnabled = v),
                  ),
                  SizedBox(height: 12.h),
                  _SwitchRow(
                    label: 'Précommande activée',
                    value: _preorderEnabled,
                    onChanged: (v) => setState(() {
                      _preorderEnabled = v;
                      if (!v) _deadlineDaysCtrl.clear();
                    }),
                  ),
                  if (_preorderEnabled) ...[
                    SizedBox(height: 10.h),
                    AppTextField(
                      label: 'Délai de réservation (jours avant livraison)',
                      hint: 'Ex: 1 = commander au moins 1 jour avant',
                      controller: _deadlineDaysCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _SwitchRow(
                    label: 'Plat actif',
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Jours de vente *'),
                  SizedBox(height: 12.h),
                  _DayPicker(
                    selected: _availableDays,
                    onToggle: (day) {
                      setState(() {
                        if (_availableDays.contains(day)) {
                          _availableDays.remove(day);
                        } else {
                          _availableDays.add(day);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 32.h),
                  AppButton.primary(
                    label: widget.isEditing ? 'Enregistrer' : 'Ajouter le plat',
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: context.colorOnSurfaceVariant,
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final List<String> photoUrls;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _PhotoPicker({
    required this.photoUrls,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Photos du plat'),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...photoUrls.map((url) => _PhotoItem(
                    url: url,
                    onRemove: () => onRemove(url),
                  )),
              if (uploading)
                Container(
                  width: 100.w,
                  height: 100.h,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: context.colorSurfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: context.colorSurfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: context.colorBorder,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 28.w, color: context.colorPrimary),
                        SizedBox(height: 4.h),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const _PhotoItem({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4.h,
          right: 12.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final DishCategory selected;
  final ValueChanged<DishCategory> onChanged;
  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: context.colorOnSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: DishCategory.values.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
                    color: isSelected ? Colors.white : context.colorOnSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colorSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: context.colorOnSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.colorPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _DayPicker({required this.selected, required this.onToggle});

  static const _days = [
    ('lundi', 'Lun'),
    ('mardi', 'Mar'),
    ('mercredi', 'Mer'),
    ('jeudi', 'Jeu'),
    ('vendredi', 'Ven'),
    ('samedi', 'Sam'),
    ('dimanche', 'Dim'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _days.map(((String day, String abbrev) record) {
        final isSelected = selected.contains(record.$1);
        return GestureDetector(
          onTap: () => onToggle(record.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorPrimary
                  : context.colorSurfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? context.colorPrimary : context.colorBorder,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.$2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.colorOnSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

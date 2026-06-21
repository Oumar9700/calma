import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user_role.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _campusController = TextEditingController();
  final _phoneController = TextEditingController();

  // Vendeur
  final _shopNameController = TextEditingController();
  final _shopDescController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _selectedSpecialties = [];
  final List<String> _selectedPaymentMethods = [];
  final List<String> _selectedDays = [];

  static const _specialties = [
    'Plats africains',
    'Cuisine asiatique',
    'Plats caribéens',
    'Cuisine du Maghreb',
    'Pâtisseries',
    'Boissons / Jus',
    'Vegan / Végétarien',
  ];

  static const _paymentOptions = ['Wero', 'Revolut', 'Espèces', 'PayPal'];

  static const _days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _campusController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopDescController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  UserRole _currentRole() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) return state.user.role;
    return UserRole.buyer;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final role = _currentRole();
    if (role.isVendor) {
      if (_selectedDays.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sélectionnez au moins 2 jours de disponibilité.')),
        );
        return;
      }
      if (_selectedPaymentMethods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sélectionnez au moins un moyen de paiement.')),
        );
        return;
      }
    }

    context.read<AuthBloc>().add(ProfileUpdateRequested(
          countryOfOrigin: _countryController.text.trim(),
          city: _cityController.text.trim(),
          campus: _campusController.text.trim().isEmpty
              ? null
              : _campusController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          shopName: role.isVendor
              ? _shopNameController.text.trim()
              : null,
          shopDescription: role.isVendor
              ? _shopDescController.text.trim()
              : null,
          specialties: role.isVendor ? _selectedSpecialties : null,
          paymentMethods: role.isVendor ? _selectedPaymentMethods : null,
          availableDays: role.isVendor ? _selectedDays : null,
          approximateLocation: role.isVendor
              ? _locationController.text.trim()
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final role = _currentRole();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is ProfileUpdateSuccess) {
          context.go(AppRoutes.home);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: AppScaffold(
        body: SingleChildScrollView(
          padding: AppSpacing.pagePadding.copyWith(top: 24.h, bottom: 40.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.isVendor
                      ? 'Configurez votre boutique'
                      : 'Complétez votre profil',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colorOnSurface,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Ces informations nous aident à personnaliser votre expérience.',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: context.colorOnSurfaceVariant,
                      height: 1.5),
                ),
                SizedBox(height: 28.h),

                // Section commune
                _SectionLabel('Informations personnelles'),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Pays d\'origine',
                  hint: 'Ex : Bénin, Sénégal, Maroc...',
                  controller: _countryController,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Ville (Rennes)',
                  hint: 'Rennes',
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Campus / Résidence (optionnel)',
                  hint: 'Ex : Villejean, Beaulieu...',
                  controller: _campusController,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Téléphone (optionnel)',
                  hint: '+33 6 00 00 00 00',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),

                if (role.isVendor) ...[
                  SizedBox(height: 28.h),
                  _SectionLabel('Votre boutique'),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Nom de la boutique',
                    hint: 'Ex : La Cuisine de Fatou',
                    controller: _shopNameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Description',
                    hint: 'Décrivez vos plats et votre cuisine...',
                    controller: _shopDescController,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Localisation approximative',
                    hint: 'Ex : Quartier Villejean, Bus C4',
                    controller: _locationController,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Spécialités culinaires'),
                  SizedBox(height: 10.h),
                  _ChipSelector(
                    options: _specialties,
                    selected: _selectedSpecialties,
                    onToggle: (v) => setState(() {
                      _selectedSpecialties.contains(v)
                          ? _selectedSpecialties.remove(v)
                          : _selectedSpecialties.add(v);
                    }),
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Moyens de paiement acceptés'),
                  SizedBox(height: 10.h),
                  _ChipSelector(
                    options: _paymentOptions,
                    selected: _selectedPaymentMethods,
                    onToggle: (v) => setState(() {
                      _selectedPaymentMethods.contains(v)
                          ? _selectedPaymentMethods.remove(v)
                          : _selectedPaymentMethods.add(v);
                    }),
                  ),
                  SizedBox(height: 24.h),
                  _SectionLabel('Jours de disponibilité (min. 2)'),
                  SizedBox(height: 10.h),
                  _ChipSelector(
                    options: _days,
                    selected: _selectedDays,
                    onToggle: (v) => setState(() {
                      _selectedDays.contains(v)
                          ? _selectedDays.remove(v)
                          : _selectedDays.add(v);
                    }),
                  ),
                ],

                SizedBox(height: 32.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AppButton.primary(
                    label: 'Continuer',
                    isLoading: state is AuthLoading,
                    onPressed: state is AuthLoading ? null : _submit,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: context.colorOnSurface,
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onToggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : context.colorSurface,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : context.colorBorder,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.sp,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : context.colorOnSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

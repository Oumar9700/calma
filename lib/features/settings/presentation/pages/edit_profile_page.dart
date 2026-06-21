import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../di/injection_container.dart';
import '../../../../features/auth/domain/entities/app_user.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = sl<StorageService>();
  final _picker = ImagePicker();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _campusCtrl;
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _shopDescCtrl;
  late final TextEditingController _locationCtrl;

  List<String> _selectedSpecialties = [];
  List<String> _selectedPaymentMethods = [];
  List<String> _selectedDays = [];

  AppUser? _user;
  File? _avatarFile;
  File? _coverFile;
  bool _uploadingAvatar = false;
  bool _uploadingCover = false;
  bool _saving = false;

  static const _specialties = [
    'Plats africains', 'Cuisine asiatique', 'Plats caribéens',
    'Cuisine du Maghreb', 'Pâtisseries', 'Boissons / Jus', 'Vegan / Végétarien',
  ];
  static const _paymentOptions = ['Wero', 'Revolut', 'Espèces', 'PayPal'];
  static const _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    _user = state is Authenticated ? state.user : null;

    _firstNameCtrl = TextEditingController(text: _user?.firstName);
    _lastNameCtrl = TextEditingController(text: _user?.lastName);
    _phoneCtrl = TextEditingController(text: _user?.phone);
    _countryCtrl = TextEditingController(text: _user?.countryOfOrigin);
    _cityCtrl = TextEditingController(text: _user?.city);
    _campusCtrl = TextEditingController(text: _user?.campus);
    _shopNameCtrl = TextEditingController(text: _user?.shopName);
    _shopDescCtrl = TextEditingController(text: _user?.shopDescription);
    _locationCtrl = TextEditingController(text: _user?.approximateLocation);
    _selectedSpecialties = List.from(_user?.specialties ?? []);
    _selectedPaymentMethods = List.from(_user?.paymentMethods ?? []);
    _selectedDays = List.from(_user?.availableDays ?? []);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _campusCtrl.dispose();
    _shopNameCtrl.dispose();
    _shopDescCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _avatarFile = File(picked.path);
      _uploadingAvatar = true;
    });
    try {
      final url = await _storage.uploadAvatar(_user!.uid, _avatarFile!);
      context.read<AuthBloc>().add(ProfileUpdateRequested(photoUrl: url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur upload photo: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickCover() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _coverFile = File(picked.path);
      _uploadingCover = true;
    });
    try {
      final url = await _storage.uploadCoverPhoto(_user!.uid, _coverFile!);
      context.read<AuthBloc>().add(ProfileUpdateRequested(coverPhotoUrl: url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur upload couverture: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingCover = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.colorBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: context.colorOnSurface),
              title: Text('Galerie photo',
                  style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15.sp,
                      color: context.colorOnSurface)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined,
                  color: context.colorOnSurface),
              title: Text('Prendre une photo',
                  style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15.sp,
                      color: context.colorOnSurface)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    context.read<AuthBloc>().add(ProfileUpdateRequested(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          countryOfOrigin: _countryCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          campus: _campusCtrl.text.trim().isEmpty
              ? null
              : _campusCtrl.text.trim(),
          shopName:
              _user?.isVendor == true ? _shopNameCtrl.text.trim() : null,
          shopDescription:
              _user?.isVendor == true ? _shopDescCtrl.text.trim() : null,
          approximateLocation: _user?.isVendor == true
              ? _locationCtrl.text.trim()
              : null,
          specialties:
              _user?.isVendor == true ? _selectedSpecialties : null,
          paymentMethods:
              _user?.isVendor == true ? _selectedPaymentMethods : null,
          availableDays:
              _user?.isVendor == true ? _selectedDays : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          setState(() {
            _user = state.user;
            _saving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour.')),
          );
          context.pop();
        }
        if (state is AuthError) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error),
          );
        }
      },
      child: AppScaffold(
        body: SingleChildScrollView(
          padding:
              AppSpacing.pagePadding.copyWith(top: 16.h, bottom: 40.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back,
                        color: context.colorOnSurface, size: 24.w),
                  ),
                  SizedBox(width: 16.w),
                  Text('Modifier le profil',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnSurface,
                      )),
                ]),
                SizedBox(height: 24.h),

                // ── Photo de profil ──────────────────────────────────────
                Center(child: _AvatarPicker(
                  user: _user,
                  file: _avatarFile,
                  loading: _uploadingAvatar,
                  onTap: _pickAvatar,
                )),
                SizedBox(height: 24.h),

                // ── Photo de couverture (vendeur) ────────────────────────
                if (_user?.isVendor == true) ...[
                  _SectionLabel('Photo de couverture boutique'),
                  SizedBox(height: 10.h),
                  _CoverPicker(
                    user: _user,
                    file: _coverFile,
                    loading: _uploadingCover,
                    onTap: _pickCover,
                  ),
                  SizedBox(height: 24.h),
                ],

                // ── Champs personnels ────────────────────────────────────
                _SectionLabel('Informations générales'),
                AppSpacing.gapMd,
                Row(children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Prénom',
                      hint: 'Prénom',
                      controller: _firstNameCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: AppTextField(
                      label: 'Nom',
                      hint: 'Nom',
                      controller: _lastNameCtrl,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                  ),
                ]),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Téléphone (optionnel)',
                  hint: '+33 6 00 00 00 00',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Pays d\'origine',
                  hint: 'Ex : Bénin, Sénégal...',
                  controller: _countryCtrl,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Ville',
                  hint: 'Rennes',
                  controller: _cityCtrl,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapMd,
                AppTextField(
                  label: 'Campus / Résidence (optionnel)',
                  hint: 'Ex : Villejean...',
                  controller: _campusCtrl,
                  textInputAction: TextInputAction.next,
                ),

                // ── Champs vendeur ───────────────────────────────────────
                if (_user?.isVendor == true) ...[
                  SizedBox(height: 24.h),
                  _SectionLabel('Boutique'),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Nom de la boutique',
                    controller: _shopNameCtrl,
                    hint: 'Ex : La Cuisine de Fatou',
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Description',
                    controller: _shopDescCtrl,
                    hint: 'Décrivez vos plats...',
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  AppSpacing.gapMd,
                  AppTextField(
                    label: 'Localisation approximative',
                    controller: _locationCtrl,
                    hint: 'Ex : Villejean, arrêt Bus C4',
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 20.h),
                  _SectionLabel('Spécialités'),
                  SizedBox(height: 10.h),
                  _MultiChips(
                    options: _specialties,
                    selected: _selectedSpecialties,
                    onToggle: (v) => setState(() => _selectedSpecialties.contains(v)
                        ? _selectedSpecialties.remove(v)
                        : _selectedSpecialties.add(v)),
                  ),
                  SizedBox(height: 20.h),
                  _SectionLabel('Moyens de paiement'),
                  SizedBox(height: 10.h),
                  _MultiChips(
                    options: _paymentOptions,
                    selected: _selectedPaymentMethods,
                    onToggle: (v) => setState(() => _selectedPaymentMethods.contains(v)
                        ? _selectedPaymentMethods.remove(v)
                        : _selectedPaymentMethods.add(v)),
                  ),
                  SizedBox(height: 20.h),
                  _SectionLabel('Jours de disponibilité'),
                  SizedBox(height: 10.h),
                  _MultiChips(
                    options: _days,
                    selected: _selectedDays,
                    onToggle: (v) => setState(() => _selectedDays.contains(v)
                        ? _selectedDays.remove(v)
                        : _selectedDays.add(v)),
                  ),
                ],

                SizedBox(height: 32.h),
                AppButton.primary(
                  label: 'Enregistrer',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar picker ────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final AppUser? user;
  final File? file;
  final bool loading;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.user,
    required this.file,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: loading
              ? CircularProgressIndicator(strokeWidth: 2)
              : ClipOval(child: _avatarContent(context)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: context.colorPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: context.colorSurface, width: 2),
            ),
            child: Icon(Icons.camera_alt, color: Colors.white, size: 15.w),
          ),
        ),
      ],
    );
  }

  Widget _avatarContent(BuildContext context) {
    if (file != null) {
      return Image.file(file!, fit: BoxFit.cover, width: 90.w, height: 90.w);
    }
    if (user?.photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: user!.photoUrl!,
        fit: BoxFit.cover,
        width: 90.w,
        height: 90.w,
        errorWidget: (_, __, ___) => _initials(context),
      );
    }
    return _initials(context);
  }

  Widget _initials(BuildContext context) {
    return Container(
      color: context.colorPrimary,
      child: Center(
        child: Text(
          user?.initials ?? '?',
          style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Cover picker ─────────────────────────────────────────────────────────────

class _CoverPicker extends StatelessWidget {
  final AppUser? user;
  final File? file;
  final bool loading;
  final VoidCallback onTap;

  const _CoverPicker({
    required this.user,
    required this.file,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.colorBorder),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(file!, fit: BoxFit.cover, width: double.infinity),
      );
    }
    if (user?.coverPhotoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: user!.coverPhotoUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 32.w, color: context.colorOnSurfaceVariant),
        SizedBox(height: 8.h),
        Text('Ajouter une photo de couverture',
            style: TextStyle(
                fontSize: 13.sp, color: context.colorOnSurfaceVariant)),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: context.colorOnSurface));
  }
}

class _MultiChips extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _MultiChips(
      {required this.options,
      required this.selected,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((opt) {
        final sel = selected.contains(opt);
        return GestureDetector(
          onTap: () => onToggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: sel ? context.colorPrimary : context.colorSurface,
              border: Border.all(
                  color: sel ? context.colorPrimary : context.colorBorder),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(opt,
                style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.sp,
                    fontWeight:
                        sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? Colors.white : context.colorOnSurface)),
          ),
        );
      }).toList(),
    );
  }
}

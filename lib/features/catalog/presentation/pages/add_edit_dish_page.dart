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
  final _regionCtrl = TextEditingController();
  final _preorderMinimumCtrl = TextEditingController();
  final _preorderClosingHoursCtrl = TextEditingController();

  String? _selectedCountry;
  DishCategory _category = DishCategory.mainDish;
  bool _preorderEnabled = true;
  bool _directOrderEnabled = false;
  bool _isActive = true;
  List<String> _availableDays = [];
  List<String> _photoUrls = [];
  bool _uploading = false;
  bool _saving = false;

  StreamSubscription<DishActionMessage>? _actionSub;

  @override
  void initState() {
    super.initState();
    _preorderMinimumCtrl.text = '1';

    final d = widget.dish;
    if (d != null) {
      _nameCtrl.text = d.name;
      _descCtrl.text = d.description ?? '';
      _priceCtrl.text = d.price.toString();
      _prepCtrl.text = d.prepTimeMinutes?.toString() ?? '';
      _maxQtyCtrl.text = d.dailyMaxQuantity?.toString() ?? '';
      _selectedCountry = d.countryOfOrigin;
      _regionCtrl.text = d.region ?? '';
      _category = d.category;
      _preorderEnabled = d.preorderEnabled;
      _preorderMinimumCtrl.text = (d.preorderMinimum ?? 1).toString();
      _preorderClosingHoursCtrl.text =
          d.preorderClosingHoursBeforeDate?.toString() ?? '';
      _directOrderEnabled = d.directOrderEnabled;
      _isActive = d.isActive;
      _availableDays = List.from(d.availableDays);
      _photoUrls = List.from(d.photoUrls);
    }

    _actionSub = context.read<DishBloc>().actionMessages.listen((msg) {
      if (!mounted || !_saving) return;
      setState(() => _saving = false);
      if (msg.result == DishActionResult.success) {
        context.pop();
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
    _regionCtrl.dispose();
    _preorderMinimumCtrl.dispose();
    _preorderClosingHoursCtrl.dispose();
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
      final dishId = widget.dish?.id ??
          'new_${DateTime.now().millisecondsSinceEpoch}';
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

    if (!_preorderEnabled && !_directOrderEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activez au moins un mode de commande.'),
        ),
      );
      return;
    }

    if (_availableDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un jour.')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Délai calculé automatiquement depuis les heures de clôture
    final closingHours =
        int.tryParse(_preorderClosingHoursCtrl.text.trim());
    final deadlineDays =
        closingHours != null ? (closingHours / 24).ceil() : null;

    final dish = Dish(
      id: widget.dish?.id ?? '',
      vendorId: authState.user.uid,
      name: _nameCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      countryOfOrigin: _selectedCountry,
      region:
          _regionCtrl.text.trim().isEmpty ? null : _regionCtrl.text.trim(),
      category: _category,
      photoUrls: _photoUrls,
      price: double.parse(_priceCtrl.text.trim().replaceAll(',', '.')),
      prepTimeMinutes:
          _prepCtrl.text.isEmpty ? null : int.tryParse(_prepCtrl.text),
      dailyMaxQuantity:
          _maxQtyCtrl.text.isEmpty ? null : int.tryParse(_maxQtyCtrl.text),
      preorderEnabled: _preorderEnabled,
      preorderDeadlineDays: _preorderEnabled ? deadlineDays : null,
      preorderMinimum: _preorderEnabled
          ? (int.tryParse(_preorderMinimumCtrl.text.trim()) ?? 1)
          : null,
      preorderClosingHoursBeforeDate:
          _preorderEnabled ? closingHours : null,
      preorderFixedDates: const [],
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
    final anyModeActive = _preorderEnabled || _directOrderEnabled;

    return AppScaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
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
                  // ── Photos ────────────────────────────────────────────────
                  _PhotoPicker(
                    photoUrls: _photoUrls,
                    uploading: _uploading,
                    onAdd: _pickPhoto,
                    onRemove: (url) =>
                        setState(() => _photoUrls.remove(url)),
                  ),
                  SizedBox(height: 24.h),

                  // ── Informations ─────────────────────────────────────────
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
                        child: _CountryPickerField(
                          value: _selectedCountry,
                          onSelected: (c) =>
                              setState(() => _selectedCountry = c),
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

                  // ── Prix ─────────────────────────────────────────────────
                  _SectionLabel('Prix & préparation'),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Prix (€) *',
                          hint: '0.00',
                          controller: _priceCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (double.tryParse(
                                    v.replaceAll(',', '.')) ==
                                null) {
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
                  SizedBox(height: 24.h),

                  // ── Section Précommande ────────────────────────────────
                  _OrderSectionCard(
                    title: 'Précommande',
                    enabled: _preorderEnabled,
                    accentColor: context.colorPrimary,
                    onToggle: (v) => setState(() => _preorderEnabled = v),
                    children: [
                      // Minimum
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Minimum de précommandes',
                              hint: '1',
                              controller: _preorderMinimumCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _HelpIcon(
                            title: 'Minimum de groupe',
                            message:
                                'Le nombre minimum de réservations à atteindre avant que vous puissiez valider. '
                                'À 1 (défaut), vous acceptez chaque précommande individuellement. '
                                'À 3, il faudra au moins 3 réservations sur la même date pour que vous validiez le groupe.',
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Clôture
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Clôture des réservations (heures)',
                              hint: 'Ex: 24',
                              controller: _preorderClosingHoursCtrl,
                              keyboardType: TextInputType.number,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: Text(
                                  'h',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: context.colorOnSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _HelpIcon(
                            title: 'Clôture des réservations',
                            message:
                                'Nombre d\'heures avant la date de livraison à partir duquel vous n\'acceptez plus de nouvelles réservations. '
                                'Cela vous laisse le temps de préparer et livrer à temps. '
                                'Ex: 24h = les réservations ferment la veille de la livraison.',
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Jours de précommande
                      Row(
                        children: [
                          Text(
                            'Jours de précommande / livraison',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: context.colorOnSurface,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _HelpIcon(
                            title: 'Jours de précommande',
                            message:
                                'Les jours où vous livrez / remettez les plats aux clients. '
                                'Ces jours apparaîtront automatiquement sur le formulaire de réservation pour que le client choisisse sa date de livraison.',
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _DayPicker(
                        selected: _availableDays,
                        onToggle: (day) => setState(() {
                          if (_availableDays.contains(day)) {
                            _availableDays.remove(day);
                          } else {
                            _availableDays.add(day);
                          }
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Section Commande directe ───────────────────────────
                  _OrderSectionCard(
                    title: 'Commande directe',
                    enabled: _directOrderEnabled,
                    accentColor: AppColors.secondary,
                    onToggle: (v) =>
                        setState(() => _directOrderEnabled = v),
                    children: [
                      // Jours de commande directe
                      Row(
                        children: [
                          Text(
                            'Jours de commande directe',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: context.colorOnSurface,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _HelpIcon(
                            title: 'Commandes directes',
                            message:
                                'Jours où vous acceptez des commandes spontanées sur le moment. '
                                'Le client commande aujourd\'hui et peut récupérer son plat dans la journée. '
                                'Le bouton "Commander" ne s\'affichera sur votre plat que les jours sélectionnés ici.',
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _DayPicker(
                        selected: _availableDays,
                        onToggle: (day) => setState(() {
                          if (_availableDays.contains(day)) {
                            _availableDays.remove(day);
                          } else {
                            _availableDays.add(day);
                          }
                        }),
                      ),
                      SizedBox(height: 14.h),

                      // Quantité max / jour
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Quantité max / jour (optionnel)',
                              hint: 'Laisser vide = illimité',
                              controller: _maxQtyCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _HelpIcon(
                            title: 'Limite quotidienne',
                            message:
                                'Nombre maximum de commandes directes que vous acceptez par jour. '
                                'Une fois atteint, le plat n\'accepte plus de commandes pour ce jour. '
                                'Laissez vide pour ne pas limiter.',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Note si les deux modes actifs et jours partagés
                  if (anyModeActive && _preorderEnabled && _directOrderEnabled)
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14.w,
                            color: context.colorOnSurfaceVariant,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Les jours sélectionnés s\'appliquent aux deux modes de commande.',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: context.colorOnSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Plat actif ───────────────────────────────────────────
                  _SwitchRow(
                    label: 'Plat actif',
                    subtitle: 'Visible dans le catalogue',
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  SizedBox(height: 32.h),

                  // ── CTA ──────────────────────────────────────────────────
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

// ── Widgets internes ─────────────────────────────────────────────────────────

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

// Card expandable pour un mode de commande
class _OrderSectionCard extends StatelessWidget {
  final String title;
  final bool enabled;
  final Color accentColor;
  final ValueChanged<bool> onToggle;
  final List<Widget> children;

  const _OrderSectionCard({
    required this.title,
    required this.enabled,
    required this.accentColor,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: enabled
              ? accentColor.withValues(alpha: 0.35)
              : context.colorBorder.withValues(alpha: 0.5),
          width: enabled ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec switch
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? accentColor
                        : context.colorBorder,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? context.colorOnSurface
                          : context.colorOnSurfaceVariant,
                    ),
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeThumbColor: accentColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // Contenu (visible uniquement si activé)
          if (enabled)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: context.colorBorder, height: 1),
                  SizedBox(height: 14.h),
                  ...children,
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Text(
                'Désactivé',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.colorOnSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Icone d'aide avec dialog explicatif
class _HelpIcon extends StatelessWidget {
  final String title;
  final String message;
  const _HelpIcon({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 13.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: context.colorSurfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.help_outline,
          size: 16.w,
          color: context.colorOnSurfaceVariant,
        ),
      ),
    );
  }
}

// Sélecteur de pays avec recherche
class _CountryPickerField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onSelected;

  const _CountryPickerField({required this.value, required this.onSelected});

  static const List<String> _countries = [
    'Afghanistan', 'Afrique du Sud', 'Albanie', 'Algérie', 'Allemagne',
    'Andorre', 'Angola', 'Antigua-et-Barbuda', 'Arabie saoudite', 'Argentine',
    'Arménie', 'Australie', 'Autriche', 'Azerbaïdjan',
    'Bahamas', 'Bahreïn', 'Bangladesh', 'Barbade', 'Belgique', 'Belize',
    'Bénin', 'Bhoutan', 'Biélorussie', 'Birmanie', 'Bolivie',
    'Bosnie-Herzégovine', 'Botswana', 'Brésil', 'Brunei', 'Bulgarie',
    'Burkina Faso', 'Burundi',
    'Cambodge', 'Cameroun', 'Canada', 'Cap-Vert', 'Chili', 'Chine',
    'Chypre', 'Colombie', 'Comores', 'Congo',
    'Corée du Nord', 'Corée du Sud', 'Costa Rica', "Côte d'Ivoire",
    'Croatie', 'Cuba',
    'Danemark', 'Djibouti', 'Dominique',
    'Égypte', 'Émirats arabes unis', 'Équateur', 'Érythrée', 'Espagne',
    'Eswatini', 'Estonie', 'États-Unis', 'Éthiopie',
    'Fidji', 'Finlande', 'France',
    'Gabon', 'Gambie', 'Géorgie', 'Ghana', 'Grèce', 'Grenade',
    'Guatemala', 'Guinée', 'Guinée-Bissau', 'Guinée équatoriale', 'Guyana',
    'Haïti', 'Honduras', 'Hongrie',
    'Inde', 'Indonésie', 'Irak', 'Iran', 'Irlande', 'Islande',
    'Israël', 'Italie',
    'Jamaïque', 'Japon', 'Jordanie',
    'Kazakhstan', 'Kenya', 'Kirghizistan', 'Kiribati', 'Kosovo', 'Koweït',
    'Laos', 'Lesotho', 'Lettonie', 'Liban', 'Liberia', 'Libye',
    'Liechtenstein', 'Lituanie', 'Luxembourg',
    'Macédoine du Nord', 'Madagascar', 'Malaisie', 'Malawi', 'Maldives',
    'Mali', 'Malte', 'Maroc', 'Marshall', 'Maurice', 'Mauritanie', 'Mexique',
    'Micronésie', 'Moldavie', 'Monaco', 'Mongolie', 'Monténégro',
    'Mozambique',
    'Namibie', 'Nauru', 'Népal', 'Nicaragua', 'Niger', 'Nigéria',
    'Norvège', 'Nouvelle-Zélande',
    'Oman', 'Ouganda', 'Ouzbékistan',
    'Pakistan', 'Palaos', 'Palestine', 'Panama',
    'Papouasie-Nouvelle-Guinée', 'Paraguay', 'Pays-Bas', 'Pérou',
    'Philippines', 'Pologne', 'Portugal',
    'Qatar',
    'République centrafricaine', 'République démocratique du Congo',
    'République dominicaine', 'République tchèque', 'Roumanie',
    'Royaume-Uni', 'Russie', 'Rwanda',
    'Saint-Christophe-et-Niévès', 'Saint-Marin',
    'Saint-Vincent-et-les-Grenadines', 'Sainte-Lucie',
    'Îles Salomon', 'Salvador', 'Samoa', 'São Tomé-et-Príncipe',
    'Sénégal', 'Serbie', 'Seychelles', 'Sierra Leone', 'Singapour',
    'Slovaquie', 'Slovénie', 'Somalie', 'Soudan', 'Soudan du Sud',
    'Sri Lanka', 'Suède', 'Suisse', 'Suriname', 'Syrie',
    'Tadjikistan', 'Tanzanie', 'Tchad', 'Thaïlande', 'Timor oriental',
    'Togo', 'Tonga', 'Trinité-et-Tobago', 'Tunisie', 'Turkménistan',
    'Turquie', 'Tuvalu',
    'Ukraine', 'Uruguay',
    'Vanuatu', 'Vatican', 'Venezuela', 'Viêt Nam',
    'Yémen',
    'Zambie', 'Zimbabwe',
  ];

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => _CountrySearchSheet(
        countries: _countries,
        onSelected: (c) {
          Navigator.pop(sheetCtx);
          onSelected(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pays d\'origine',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: context.colorOnSurface,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _openPicker(context),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: context.colorSurfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.colorBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Sélectionner un pays',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: value != null
                          ? context.colorOnSurface
                          : context.colorOnSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.colorOnSurfaceVariant,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  final List<String> countries;
  final ValueChanged<String> onSelected;

  const _CountrySearchSheet({
    required this.countries,
    required this.onSelected,
  });

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  final _searchCtrl = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? widget.countries
            : widget.countries
                .where((c) => c.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, controller) => Column(
        children: [
          // Handle
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: context.colorBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Pays d\'origine',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: context.colorOnSurface,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search,
                    size: 18.w, color: context.colorOnSurfaceVariant),
                filled: true,
                fillColor: context.colorSurfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 10.h),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, color: context.colorBorder),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'Aucun pays trouvé',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: controller,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(
                        _filtered[i],
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      onTap: () => widget.onSelected(_filtered[i]),
                      dense: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    this.subtitle,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colorOnSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.colorOnSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.colorPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
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
                      border: Border.all(color: context.colorBorder),
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
      ],
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
                color:
                    isSelected ? context.colorPrimary : context.colorBorder,
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

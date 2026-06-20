import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Phase 1 : intégration AuthBloc
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding.copyWith(top: 24.h, bottom: 32.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.w),
              ),
              SizedBox(height: 24.h),
              Text(
                'Créer un compte',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Rejoignez la communauté CALMA',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Prénom',
                      hint: 'Votre prénom',
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requis';
                        return null;
                      },
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: AppTextField(
                      label: 'Nom',
                      hint: 'Votre nom',
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requis';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXl,
              AppTextField(
                label: 'Adresse email',
                hint: 'votre@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              AppSpacing.gapXl,
              AppTextField.password(
                label: 'Mot de passe',
                hint: 'Minimum 8 caractères',
                controller: _passwordController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
              ),
              AppSpacing.gapXxl,
              AppButton.primary(
                label: 'Créer mon compte',
                onPressed: _isLoading ? null : _register,
                isLoading: _isLoading,
              ),
              AppSpacing.gapXl,
              Text(
                'En vous inscrivant, vous acceptez nos Conditions d\'utilisation et la Politique de confidentialité.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà un compte ? ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

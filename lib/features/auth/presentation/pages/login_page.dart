import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Phase 1 : intégration AuthBloc
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go(AppRoutes.home);
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
              SizedBox(height: 16.h),
              Text(
                'Bon retour',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Connectez-vous à votre compte',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 36.h),
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
                hint: 'Votre mot de passe',
                controller: _passwordController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
              ),
              AppSpacing.gapMd,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapXxl,
              AppButton.primary(
                label: 'Se connecter',
                onPressed: _isLoading ? null : _login,
                isLoading: _isLoading,
              ),
              AppSpacing.gapXl,
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Ou avec',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              AppSpacing.gapXl,
              AppButton.outlined(
                label: 'Continuer avec Google',
                onPressed: () {},
                prefixIcon: Icon(Icons.g_mobiledata, size: 24.w, color: AppColors.primary),
              ),
              AppSpacing.gapMd,
              AppButton.outlined(
                label: 'Continuer avec Apple',
                onPressed: () {},
                prefixIcon: Icon(Icons.apple, size: 22.w, color: AppColors.primary),
              ),
              AppSpacing.gapXxl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte ? ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'S\'inscrire',
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Des plats qui rappellent chez vous',
      subtitle:
          'Trouvez des repas préparés avec amour par vos camarades étudiants.',
    ),
    _OnboardingSlide(
      title: 'Partagez votre cuisine',
      subtitle:
          'Vendez les plats de votre pays et faites découvrir votre culture.',
    ),
    _OnboardingSlide(
      title: 'Commandez facilement',
      subtitle: 'Commandez ou pré-commandez en quelques touches.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(
                  'Passer',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, index) => _SlideView(
                  slide: _slides[index],
                  index: index,
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.pagePadding.copyWith(bottom: 32.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == i ? 24.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapXxl,
                  AppButton.primary(
                    label: _currentPage == _slides.length - 1
                        ? 'Commencer'
                        : 'Continuer',
                    onPressed: _next,
                  ),
                  AppSpacing.gapMd,
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'J\'ai déjà un compte',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  final int index;

  const _SlideView({required this.slide, required this.index});

  static const List<Color> _bgColors = [
    Color(0xFFFFF0EB),
    Color(0xFFEBF4EF),
    Color(0xFFFFF8EC),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: _bgColors[index % _bgColors.length],
              shape: BoxShape.circle,
            ),
            child: Icon(
              [Icons.restaurant_menu, Icons.storefront, Icons.shopping_bag_outlined][index],
              size: 80.w,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            slide.title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            slide.subtitle,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  const _OnboardingSlide({required this.title, required this.subtitle});
}

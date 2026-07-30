import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to Sprout.ly', style: AppTextStyles.displayXL),
                  AppSpacing.gapSM,
                  Text(
                    'This is a placeholder onboarding screen. Use the buttons below to test app routing.',
                    style: AppTextStyles.bodyM,
                  ),
                  AppSpacing.gapXXL,
                  _buildActionButton(
                    context,
                    label: 'Masuk',
                    route: AppRoutes.login,
                  ),
                  AppSpacing.gapMD,
                  _buildActionButton(
                    context,
                    label: 'Daftar',
                    route: AppRoutes.register,
                  ),
                  AppSpacing.gapXXL,
                  _buildActionButton(
                    context,
                    label: 'Go to Home',
                    route: AppRoutes.home,
                  ),
                  AppSpacing.gapMD,
                  _buildActionButton(
                    context,
                    label: 'Go to Settings',
                    route: AppRoutes.settings,
                  ),
                  AppSpacing.gapMD,
                  _buildActionButton(
                    context,
                    label: 'Go to Profile',
                    route: AppRoutes.profile,
                  ),
                  AppSpacing.gapXXL,
                  _buildStepPlaceholder(
                    title: 'Step 1',
                    description: 'Use the buttons above to jump to the target screens.',
                  ),
                  AppSpacing.gapXXXL,
                  _buildStepPlaceholder(
                    title: 'Step 2',
                    description: 'Home, Settings, and Profile are all wired through GoRouter.',
                  ),
                  AppSpacing.gapXXXL,
                  _buildStepPlaceholder(
                    title: 'Step 3',
                    description: 'When testing, return to this page to verify onboarding navigation again.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label, required String route}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.peach500,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        onPressed: () => context.go(route),
        child: Text(
          label,
          style: AppTextStyles.headingL.copyWith(
            color: AppColors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStepPlaceholder({
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingM),
          AppSpacing.gapXS,
          Text(description, style: AppTextStyles.bodyM),
        ],
      ),
    );
  }
}

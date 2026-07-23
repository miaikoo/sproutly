import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';

class CreateBoardPage extends StatelessWidget {
  const CreateBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapSM,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(12))),
                      AppSpacing.gapHSM,
                      Expanded(child: Text('Buat Papan Aktivitas Baru', style: AppTextStyles.displayXL)),
                    ],
                  ),
                  AppSpacing.gapXL,
                  Center(child: Text('Papan apa yang ingin kamu buat?', style: AppTextStyles.displayL, textAlign: TextAlign.center)),
                  AppSpacing.gapXXL,

                  // First option card (Jadwal)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    decoration: BoxDecoration(
                      color: AppColors.teal100,
                      borderRadius: BorderRadius.all(AppRadius.lg),
                      border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.all(Radius.circular(16)))),
                        AppSpacing.gapXL,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text('Jadwal', style: AppTextStyles.displayL, textAlign: TextAlign.left)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapXXL,
                  Center(child: Text('Atau', style: AppTextStyles.displayM)),
                  AppSpacing.gapXXL,

                  // Second option card (First-Then)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    decoration: BoxDecoration(
                      color: AppColors.teal100,
                      borderRadius: BorderRadius.all(AppRadius.lg),
                      border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.all(Radius.circular(16)))),
                        AppSpacing.gapXL,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text('First-Then', style: AppTextStyles.displayL, textAlign: TextAlign.left)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapXXXL,

                  Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.peach500,
                        padding: const EdgeInsets.symmetric(horizontal: 128, vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text('Selanjutnya', style: AppTextStyles.headingL.copyWith(color: AppColors.white, fontSize: 24)),
                    ),
                  ),

                  AppSpacing.gapXL,

                  // Footer progress indicator
                  Center(
                    child: Container(
                      width: 144,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral800.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

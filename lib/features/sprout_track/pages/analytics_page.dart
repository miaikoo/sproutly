import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../widgets/child_progress_panel.dart';

/// The parent's SproutTrack dashboard. The charts themselves live in
/// [ChildProgressPanel] so the therapist's SproutLink view shows the same data.
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProvider);

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
                  _buildHeader(context),
                  AppSpacing.gapXL,
                  childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Gagal memuat profil anak: $e'),
                    data: (child) {
                      if (child == null) return Text('Profil anak belum tersedia.');
                      return ChildProgressPanel(
                        childId: child.id,
                        footer: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.peach500),
                            onPressed: () => context.push(AppRoutes.report),
                            child: Text(
                              'Lihat Laporan',
                              style: AppTextStyles.headingM.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AppSpacing.gapXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: const CustomIcon(
            assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
            size: 28,
            color: AppColors.neutral800,
          ),
        ),
        AppSpacing.gapHMD,
        Text('SproutTrack', style: AppTextStyles.displayL),
      ],
    );
  }
}

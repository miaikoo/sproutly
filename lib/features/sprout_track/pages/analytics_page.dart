import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                  child: _buildHeader(context, childAsync.valueOrNull?.name ?? 'Anak'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        childAsync.when(
                          loading: () => const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text('Gagal memuat profil anak: $e', style: AppTextStyles.bodyM),
                          ),
                          data: (child) {
                            if (child == null) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Text('Profil anak belum tersedia.', style: AppTextStyles.bodyM),
                              );
                            }
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String childName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behaviour Analytics',
              style: AppTextStyles.displayL.copyWith(
                color: const Color(0xFF353C3A),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ringkasan 7 hari terakhir · $childName',
              style: AppTextStyles.bodyM.copyWith(
                color: const Color(0xFF7A8A88),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF7EA29C),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}

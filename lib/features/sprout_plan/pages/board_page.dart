import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/bottom_nav.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      12,
      (i) => _BoardData(
        title: i % 3 == 0 ? 'Rutinitas Pagi' : (i % 3 == 1 ? 'Kesal' : 'Menunggu 5 menit'),
        background: i % 3 == 0
            ? AppColors.steel300
            : (i % 3 == 1 ? AppColors.cream100 : AppColors.cream300),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapSM,
                  Text('Papan saya', style: AppTextStyles.displayXL),
                  AppSpacing.gapMD,
                  _buildFilterChips(),
                  AppSpacing.gapXL,
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final d in items) SizedBox(width: 200, child: _BoardCard(data: d)),
                      SizedBox(
                        width: 200,
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.createBoard),
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColors.peach100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.peach500, width: 3),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 36, color: AppColors.textPrimary),
                                  AppSpacing.gapXS,
                                  Text('Tambah Papan', style: AppTextStyles.headingM),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapXXL,
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Aktivitas', 'Menunggu', 'Emosi'];
    return Row(
      children: filters
          .map(
            (label) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                backgroundColor: label == 'Semua' ? AppColors.teal700 : AppColors.teal500,
                label: Text(
                  label,
                  style: AppTextStyles.headingM.copyWith(color: AppColors.white),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
            ),
          )
          .toList(),
    );
  }

}

class _BoardData {
  const _BoardData({required this.title, required this.background});
  final String title;
  final Color background;
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.data});
  final _BoardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 152,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingM,
            ),
          ),
        ],
      ),
    );
  }
}


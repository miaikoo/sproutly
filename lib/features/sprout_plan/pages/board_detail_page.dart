import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/custom_icon.dart';

class BoardDetailPage extends ConsumerWidget {
  const BoardDetailPage({super.key, required this.scheduleId});

  final String scheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleByIdProvider(scheduleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat papan: $e')),
              data: (schedule) {
                if (schedule == null) {
                  return const Center(child: Text('Papan tidak ditemukan.'));
                }
                return _buildBody(context, schedule);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Schedule schedule) {
    final activities = [...schedule.activities]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final completedCount = activities.where((a) => a.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, schedule),
        Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            '$completedCount dari ${activities.length} aktivitas selesai',
            style: AppTextStyles.bodyM,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: AppSpacing.pagePadding,
            itemCount: activities.length,
            separatorBuilder: (_, __) => AppSpacing.gapMD,
            itemBuilder: (context, index) => _ActivityRow(
              scheduleId: schedule.id,
              activity: activities[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Schedule schedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
              size: 28,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(schedule.title, style: AppTextStyles.displayM)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.scheduleId, required this.activity});

  final String scheduleId;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.activityPath(scheduleId, activity.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral800.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(activity.icon, fit: BoxFit.contain),
            ),
            AppSpacing.gapHMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: AppTextStyles.headingS),
                  Text(DateFormat.Hm().format(activity.startTime), style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(
              activity.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: activity.completed ? AppColors.success : AppColors.neutral500,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/behaviour_log.dart';
import '../../../shared/widgets/custom_icon.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

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
                  padding: AppSpacing.pagePadding,
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
                      AppSpacing.gapHMD,
                      Text('Laporan Perkembangan', style: AppTextStyles.displayL),
                    ],
                  ),
                ),
                Expanded(
                  child: childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Gagal memuat profil anak: $e'),
                    data: (child) {
                      if (child == null) return const Text('Profil anak belum tersedia.');
                      return _buildList(ref, child.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(WidgetRef ref, String childId) {
    final logsAsync = ref.watch(logsForChildProvider(childId));
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    if (logsAsync.isLoading || schedulesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (logsAsync.hasError) {
      return Text('Gagal memuat laporan: ${logsAsync.error}');
    }

    final logs = logsAsync.value ?? [];
    if (logs.isEmpty) {
      return Padding(
        padding: AppSpacing.pagePadding,
        child: Text('Belum ada catatan aktivitas.', style: AppTextStyles.bodyM),
      );
    }

    final activitiesById = <String, Activity>{
      for (final schedule in schedulesAsync.value ?? [])
        for (final activity in schedule.activities) activity.id: activity,
    };

    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: logs.length,
      separatorBuilder: (_, __) => AppSpacing.gapSM,
      itemBuilder: (context, index) {
        final log = logs[index];
        final activity = activitiesById[log.activityId];
        return _ReportRow(log: log, activityTitle: activity?.title ?? 'Aktivitas');
      },
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.log, required this.activityTitle});

  final BehaviourLog log;
  final String activityTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activityTitle, style: AppTextStyles.headingS),
                Text(
                  DateFormat('d MMM y, HH:mm').format(log.timestamp),
                  style: AppTextStyles.caption,
                ),
                Text(
                  'Mood: ${log.mood.name} • Transisi: ${log.transitionDifficulty.name} • ${log.durationMinutes} menit',
                  style: AppTextStyles.bodyS,
                ),
              ],
            ),
          ),
          Icon(
            log.completed ? Icons.check_circle : Icons.cancel,
            color: log.completed ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }
}

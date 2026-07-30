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
import '../../../models/behaviour_log.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../widgets/child_progress_panel.dart';

/// One reporting period with the logs that fall in it.
typedef ReportPeriod = ({String label, List<BehaviourLog> logs});

/// Groups newest-first [logs] into calendar weeks, newest week first — the
/// "laporan berkala" of RF-12, rather than one flat list of every entry.
List<ReportPeriod> groupIntoWeeks(List<BehaviourLog> logs) {
  final byWeekStart = <DateTime, List<BehaviourLog>>{};

  for (final log in logs) {
    final day = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
    // Monday of that log's week.
    final weekStart = day.subtract(Duration(days: day.weekday - 1));
    byWeekStart.putIfAbsent(weekStart, () => []).add(log);
  }

  final starts = byWeekStart.keys.toList()..sort((a, b) => b.compareTo(a));
  final format = DateFormat('d MMM');

  return [
    for (final start in starts)
      (
        label: '${format.format(start)} – ${format.format(start.add(const Duration(days: 6)))}',
        logs: byWeekStart[start]!,
      ),
  ];
}

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
                      Expanded(
                        child: Text('Laporan Perkembangan', style: AppTextStyles.displayL),
                      ),
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

    final titlesById = {
      for (final schedule in schedulesAsync.value ?? [])
        for (final activity in schedule.activities) activity.id: activity.title,
    };

    final weeks = groupIntoWeeks(logs);

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final week = weeks[index];
        final completed = week.logs.where((l) => l.completed).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) AppSpacing.gapXL,
            Text(week.label, style: AppTextStyles.headingM),
            Text(
              '$completed dari ${week.logs.length} aktivitas selesai',
              style: AppTextStyles.caption,
            ),
            AppSpacing.gapSM,
            for (final log in week.logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BehaviourLogRow(
                  log: log,
                  activityTitle: titlesById[log.activityId] ?? 'Aktivitas',
                ),
              ),
          ],
        );
      },
    );
  }
}

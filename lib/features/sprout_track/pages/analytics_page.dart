import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/behaviour_log.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/custom_icon.dart';

const _moodLabels = {
  Mood.happy: '😊 Senang',
  Mood.calm: '😌 Tenang',
  Mood.neutral: '😐 Biasa',
  Mood.anxious: '😟 Cemas',
  Mood.upset: '😢 Sedih',
  Mood.meltdown: '😣 Meltdown',
};

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
                      if (child == null) return const Text('Profil anak belum tersedia.');
                      return _buildBody(context, ref, child.id);
                    },
                  ),
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

  Widget _buildBody(BuildContext context, WidgetRef ref, String childId) {
    final logsAsync = ref.watch(logsForChildProvider(childId));

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Gagal memuat data perkembangan: $e'),
      data: (logs) {
        if (logs.isEmpty) {
          return Text(
            'Belum ada aktivitas yang tercatat. Jalankan papan di SproutPlan untuk mulai mencatat perkembangan.',
            style: AppTextStyles.bodyM,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _completionCard(logs),
            AppSpacing.gapXL,
            Text('Suasana Hati', style: AppTextStyles.headingM),
            AppSpacing.gapSM,
            _moodBreakdown(logs),
            AppSpacing.gapXL,
            Text('Tren 7 Hari Terakhir', style: AppTextStyles.headingM),
            AppSpacing.gapSM,
            _weeklyTrend(logs),
            AppSpacing.gapXL,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.peach500),
                onPressed: () => context.push(AppRoutes.report),
                child: Text('Lihat Laporan', style: AppTextStyles.headingM.copyWith(color: AppColors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _completionCard(List<BehaviourLog> logs) {
    final completed = logs.where((l) => l.completed).length;
    final rate = logs.isEmpty ? 0 : (completed / logs.length * 100).round();

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(color: AppColors.teal100, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tingkat Penyelesaian Aktivitas', style: AppTextStyles.labelL),
          AppSpacing.gapXS,
          Text('$rate%', style: AppTextStyles.displayXL),
          Text('$completed dari ${logs.length} aktivitas', style: AppTextStyles.bodyS),
        ],
      ),
    );
  }

  Widget _moodBreakdown(List<BehaviourLog> logs) {
    final counts = <Mood, int>{};
    for (final log in logs) {
      counts[log.mood] = (counts[log.mood] ?? 0) + 1;
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((e) {
        final fraction = e.value / logs.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(width: 100, child: Text(_moodLabels[e.key] ?? e.key.name, style: AppTextStyles.bodyS)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 12,
                    backgroundColor: AppColors.neutral200,
                    color: AppColors.teal500,
                  ),
                ),
              ),
              AppSpacing.gapHXS,
              Text('${e.value}', style: AppTextStyles.bodyS),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _weeklyTrend(List<BehaviourLog> logs) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day - (6 - i)));

    final countsByDay = {
      for (final day in days)
        day: logs.where((l) => l.completed && _isSameDay(l.timestamp, day)).length,
    };
    final maxCount = countsByDay.values.fold(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final count = countsByDay[day] ?? 0;
          final height = maxCount == 0 ? 4.0 : 8 + (count / maxCount) * 80;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$count', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.teal500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(day), style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

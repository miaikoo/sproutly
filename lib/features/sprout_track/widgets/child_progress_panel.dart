import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/behaviour_log.dart';
import '../../../models/enums.dart';

const _moodLabels = {
  Mood.happy: '😊 Senang',
  Mood.calm: '😌 Tenang',
  Mood.neutral: '😐 Biasa',
  Mood.anxious: '😟 Cemas',
  Mood.upset: '😢 Sedih',
  Mood.meltdown: '😣 Meltdown',
};

/// Selectable reporting windows (RF-11 doc §6.4 step 3). `null` days means all
/// history.
const _ranges = <String, int?>{
  '7 hari': 7,
  '30 hari': 30,
  'Semua': null,
};

/// Keeps only logs inside the last [days]; all of them when [days] is null.
/// [now] is injected so the boundary is testable.
List<BehaviourLog> logsInRange(List<BehaviourLog> logs, int? days, DateTime now) {
  if (days == null) return logs;
  // Count whole days back from the start of today, so "7 hari" always covers
  // today plus the six days before it regardless of the time of day.
  final startOfToday = DateTime(now.year, now.month, now.day);
  final cutoff = startOfToday.subtract(Duration(days: days - 1));
  return logs.where((l) => !l.timestamp.isBefore(cutoff)).toList();
}

/// SproutTrack's dashboard for one child. Shared by the parent's Analytics page
/// and the therapist's SproutLink view, so both sides read the same numbers
/// (RF-11, RF-13).
class ChildProgressPanel extends ConsumerStatefulWidget {
  const ChildProgressPanel({
    super.key,
    required this.childId,
    this.historyLimit = 5,
    this.footer,
  });

  final String childId;

  /// How many recent entries to list under the charts.
  final int historyLimit;

  /// Optional action shown at the bottom, e.g. the parent's "Lihat Laporan".
  final Widget? footer;

  @override
  ConsumerState<ChildProgressPanel> createState() => _ChildProgressPanelState();
}

class _ChildProgressPanelState extends ConsumerState<ChildProgressPanel> {
  String _range = '7 hari';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsForChildProvider(widget.childId));

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Gagal memuat data perkembangan: $e', style: AppTextStyles.bodyM),
      data: (allLogs) {
        if (allLogs.isEmpty) {
          return Text(
            'Belum ada aktivitas yang tercatat. Jalankan papan di SproutPlan untuk mulai '
            'mencatat perkembangan.',
            style: AppTextStyles.bodyM,
          );
        }

        final days = _ranges[_range];
        final logs = logsInRange(allLogs, days, DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rangeChips(),
            AppSpacing.gapMD,
            if (logs.isEmpty)
              Text('Belum ada aktivitas dalam $_range terakhir.', style: AppTextStyles.bodyM)
            else ...[
              _completionCard(logs),
              AppSpacing.gapXL,
              Text('Suasana Hati', style: AppTextStyles.headingM),
              AppSpacing.gapSM,
              _moodBreakdown(logs),
              AppSpacing.gapXL,
              Text('Tren $_range Terakhir', style: AppTextStyles.headingM),
              AppSpacing.gapSM,
              _trend(logs, days ?? _spanInDays(logs)),
              AppSpacing.gapXL,
              Text('Riwayat Terbaru', style: AppTextStyles.headingM),
              AppSpacing.gapSM,
              _history(logs),
            ],
            if (widget.footer != null) ...[
              AppSpacing.gapXL,
              widget.footer!,
            ],
          ],
        );
      },
    );
  }

  /// Days covered by [logs], at least one so the chart never divides by zero.
  int _spanInDays(List<BehaviourLog> logs) {
    final oldest = logs.map((l) => l.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(oldest).inDays + 1;
  }

  Widget _rangeChips() {
    return Wrap(
      spacing: 8,
      children: _ranges.keys.map((label) {
        final isSelected = _range == label;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => setState(() => _range = label),
        );
      }).toList(),
    );
  }

  Widget _completionCard(List<BehaviourLog> logs) {
    final completed = logs.where((l) => l.completed).length;
    final rate = (completed / logs.length * 100).round();

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
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(_moodLabels[e.key] ?? e.key.name, style: AppTextStyles.bodyS),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: e.value / logs.length,
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

  Widget _trend(List<BehaviourLog> logs, int dayCount) {
    // Cap the bar count so a long range stays readable on a phone.
    final span = dayCount.clamp(1, 30);
    final today = DateTime.now();
    final days = List.generate(
      span,
      (i) => DateTime(today.year, today.month, today.day - (span - 1 - i)),
    );

    final countsByDay = {
      for (final day in days)
        day: logs.where((l) => l.completed && _isSameDay(l.timestamp, day)).length,
    };
    final maxCount = countsByDay.values.fold(0, (a, b) => a > b ? a : b);

    // Labels only fit on a short range.
    final showLabels = span <= 7;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          final count = countsByDay[day] ?? 0;
          final height = maxCount == 0 ? 4.0 : 8 + (count / maxCount) * 80;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: showLabels ? 4 : 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showLabels) Text('$count', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: AppColors.teal500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (showLabels)
                    Text(DateFormat('E').format(day), style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _history(List<BehaviourLog> logs) {
    final schedules = ref.watch(schedulesForChildProvider(widget.childId)).valueOrNull ?? [];
    final titlesById = {
      for (final schedule in schedules)
        for (final activity in schedule.activities) activity.id: activity.title,
    };

    final visible = logs.take(widget.historyLimit).toList();

    return Column(
      children: [
        for (final log in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BehaviourLogRow(
              log: log,
              activityTitle: titlesById[log.activityId] ?? 'Aktivitas',
            ),
          ),
        if (logs.length > visible.length)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+${logs.length - visible.length} catatan lain',
              style: AppTextStyles.caption,
            ),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// One behaviour log entry. Shared by the panel and the full report list.
class BehaviourLogRow extends StatelessWidget {
  const BehaviourLogRow({super.key, required this.log, required this.activityTitle});

  final BehaviourLog log;
  final String activityTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withValues(alpha: 0.1)),
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
                  'Mood: ${log.mood.name} • Transisi: ${log.transitionDifficulty.name} • '
                  '${log.durationMinutes} menit',
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

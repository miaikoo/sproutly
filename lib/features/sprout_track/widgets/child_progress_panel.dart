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
import '../progress_stats.dart';
import 'progress_charts.dart';

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

        final now = DateTime.now();
        final days = _ranges[_range];
        final logs = logsInRange(allLogs, days, now);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // One filter row above everything it scopes — never per-chart.
            _rangeChips(),
            AppSpacing.gapMD,
            if (logs.isEmpty)
              Text('Belum ada aktivitas dalam $_range terakhir.', style: AppTextStyles.bodyM)
            else ...[
              _headlineRow(logs, now, days),
              AppSpacing.gapXXL,
              _section(
                'Kemandirian per aktivitas',
                'Aktivitas yang sudah dikuasai muncul di atas.',
                MasteryBars(rows: activityMastery(logs, _activityTitles())),
              ),
              AppSpacing.gapXXL,
              _section(
                'Aktivitas per hari',
                null,
                DailyTrend(
                  days: dailyCompletions(logs, now, days ?? _spanInDays(logs)),
                  today: now,
                ),
              ),
              AppSpacing.gapXXL,
              _section(
                'Suasana hati',
                null,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DivergingBar(
                      split: moodPolarity(logs),
                      positiveLabel: 'Tenang',
                      middleLabel: 'Biasa',
                      negativeLabel: 'Perlu perhatian',
                    ),
                    AppSpacing.gapMD,
                    _moodBreakdown(logs),
                  ],
                ),
              ),
              AppSpacing.gapXXL,
              _section(
                'Perpindahan antar aktivitas',
                'Transisi adalah kesulitan yang paling sering muncul pada anak ASD.',
                DivergingBar(
                  split: transitionSplit(logs),
                  positiveLabel: 'Mudah',
                  middleLabel: 'Sedang',
                  negativeLabel: 'Sulit',
                ),
              ),
              AppSpacing.gapXXL,
              _section('Riwayat terbaru', null, _history(logs)),
            ],
            if (widget.footer != null) ...[
              AppSpacing.gapXXL,
              widget.footer!,
            ],
          ],
        );
      },
    );
  }

  Widget _section(String title, String? note, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingM),
        if (note != null) ...[
          AppSpacing.gapXXS,
          Text(note, style: AppTextStyles.caption),
        ],
        AppSpacing.gapSM,
        child,
      ],
    );
  }

  /// Completion and consistency side by side — the two figures the proposal's
  /// evaluation plan names (task completion rate, konsistensi rutinitas).
  Widget _headlineRow(List<BehaviourLog> logs, DateTime now, int? rangeDays) {
    final rate = completionRate(logs);
    final completed = logs.where((l) => l.completed).length;
    final active = activeDays(logs);
    final streak = currentStreak(logs, now);
    final span = rangeDays ?? _spanInDays(logs);

    final completion = StatTile(
      label: 'Tingkat penyelesaian',
      value: '${(rate * 100).round()}',
      unit: '%',
      detail: '$completed dari ${logs.length} aktivitas',
      meter: rate,
      tinted: true,
    );

    final consistency = StatTile(
      label: 'Konsistensi rutinitas',
      value: '$active',
      unit: '/ $span hari',
      detail: streak == 0
          ? 'Belum ada rangkaian hari berjalan.'
          : '$streak hari berturut-turut.',
      meter: span == 0 ? 0 : active / span,
    );

    return LayoutBuilder(builder: (context, constraints) {
      // Side by side once there is room; stacked on a phone.
      if (constraints.maxWidth < 520) {
        return Column(
          children: [completion, AppSpacing.gapMD, consistency],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: completion),
          AppSpacing.gapHMD,
          Expanded(child: consistency),
        ],
      );
    });
  }

  /// Activity id → title, drawn from the child's boards.
  Map<String, String> _activityTitles() {
    final schedules = ref.watch(schedulesForChildProvider(widget.childId)).valueOrNull ?? [];
    return {
      for (final schedule in schedules)
        for (final activity in schedule.activities) activity.id: activity.title,
    };
  }

  /// Days covered by [logs], at least one so a chart never divides by zero.
  int _spanInDays(List<BehaviourLog> logs) {
    if (logs.isEmpty) return 1;
    final oldest = logs.map((l) => l.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime.now().difference(oldest).inDays + 1;
  }

  /// The exact per-mood counts. This is the table view that makes the diverging
  /// bar's grey midpoint legal despite sitting under the 3:1 mark floor.
  Widget _moodBreakdown(List<BehaviourLog> logs) {
    final counts = <Mood, int>{};
    for (final log in logs) {
      counts[log.mood] = (counts[log.mood] ?? 0) + 1;
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _moodLabels[e.key] ?? e.key.name,
                    style: AppTextStyles.bodyS,
                  ),
                ),
                Text(
                  '${e.value}×',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _rangeChips() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _ranges.keys.map((label) {
        final isSelected = _range == label;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => setState(() => _range = label),
          labelStyle: AppTextStyles.bodyS.copyWith(
            color: isSelected ? AppColors.onFilled : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        );
      }).toList(),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: log.completed ? AppColors.successTint : AppColors.errorTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              log.completed ? Icons.check_rounded : Icons.close_rounded,
              color: log.completed ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          AppSpacing.gapHSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activityTitle, style: AppTextStyles.headingS),
                AppSpacing.gapXXS,
                // Plain Indonesian, not enum names: `meltdown` and `high` meant
                // nothing to a parent reading their own child's report.
                Text(
                  '${DateFormat('d MMM, HH:mm').format(log.timestamp)} · '
                  '${moodLabel(log.mood)} · '
                  'transisi ${transitionLabel(log.transitionDifficulty)} · '
                  '${log.durationMinutes} menit',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _moodPlain = {
  Mood.happy: 'senang',
  Mood.calm: 'tenang',
  Mood.neutral: 'biasa',
  Mood.anxious: 'cemas',
  Mood.upset: 'sedih',
  Mood.meltdown: 'kewalahan',
};

const _transitionPlain = {
  TransitionDifficulty.low: 'mudah',
  TransitionDifficulty.medium: 'sedang',
  TransitionDifficulty.high: 'sulit',
};

String moodLabel(Mood mood) => _moodPlain[mood] ?? mood.name;

String transitionLabel(TransitionDifficulty difficulty) =>
    _transitionPlain[difficulty] ?? difficulty.name;

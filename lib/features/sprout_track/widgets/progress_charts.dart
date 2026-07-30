import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../progress_stats.dart';

/// Chart marks for SproutTrack.
///
/// **Why there are no multi-colour series charts here.** The brand palette was
/// measured against the categorical checks and every hue sits at chroma
/// 0.012–0.092, under the 0.10 floor where a hue stops doing identity work. A
/// palette this deliberately muted cannot carry "tell these five series apart".
/// So every chart below is sequential (one hue), ordinal, or diverging — which
/// is also what the calm, low-distraction requirement wanted anyway.
///
/// The diverging vocabulary is one pair plus a neutral midpoint, validated as
/// two ordinal arms: teal500→teal700 and peach500→peach700 both pass monotone
/// lightness, ΔL ≥ 0.06 and the light-end contrast floor. The grey midpoint sits
/// at 2.47:1, under the 3:1 mark floor, so every diverging bar here ships
/// visible labels — that relief is required, not optional.
class ChartColors {
  ChartColors._();

  /// Settled / easy end.
  static const positive = AppColors.teal700;

  /// Reads as "neither". A true grey (channel spread 2) so it does not look like
  /// a third opinion.
  static const middle = AppColors.neutral500;

  /// Distressed / hard end. Warm, not alarm-red: this is information for a
  /// parent, not a verdict on their child.
  static const negative = AppColors.peach700;

  /// Single hue for magnitude bars. Nominal categories all take this one colour;
  /// shading each bar by its own value would spend the identity channel
  /// re-encoding what bar length already says.
  static const magnitude = AppColors.teal700;

  static const track = AppColors.neutral200;
}

/// A headline figure with its own supporting line. Used instead of a one-bar
/// chart, which is what a single number deserves.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.detail,
    this.meter,
    this.tinted = false,
  });

  final String label;
  final String value;
  final String? unit;
  final String detail;

  /// 0..1 — draws a track under the figure when the value is a share of a limit.
  final double? meter;

  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tinted ? AppColors.teal100 : AppColors.surface,
        borderRadius: AppRadius.card,
        border: tinted ? null : Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelL),
          AppSpacing.gapXS,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Proportional figures, not tabular: equal-width digits make a
              // large standalone number look loose.
              Text(value, style: AppTextStyles.timeL),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Text(
                  unit!,
                  style: AppTextStyles.headingM.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          if (meter != null) ...[
            AppSpacing.gapXS,
            ClipRRect(
              borderRadius: const BorderRadius.all(AppRadius.xs),
              child: LinearProgressIndicator(
                value: meter!.clamp(0, 1),
                minHeight: 8,
                backgroundColor: tinted ? AppColors.white : ChartColors.track,
                color: ChartColors.magnitude,
              ),
            ),
          ],
          AppSpacing.gapXS,
          Text(detail, style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Per-activity completion as horizontal bars — one hue, sorted, direct-labelled.
///
/// This is the daily-living-skills view: which routines the child is managing and
/// which still need support. The proposal is about DLS, and nothing in the app
/// showed this even though the data was already there.
class MasteryBars extends StatelessWidget {
  const MasteryBars({super.key, required this.rows, this.maxRows = 6});

  final List<ActivityMastery> rows;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(
        'Belum cukup data. Sebuah aktivitas muncul di sini setelah dijalankan '
        'minimal dua kali.',
        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
      );
    }

    final visible = rows.take(maxRows).toList();

    return Column(
      children: [
        for (final row in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Semantics(
              label: '${row.title}: ${row.done} dari ${row.total} selesai',
              child: Row(
                children: [
                  SizedBox(
                    width: 116,
                    child: Text(
                      row.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyS,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: row.rate,
                        minHeight: 10,
                        backgroundColor: ChartColors.track,
                        color: ChartColors.magnitude,
                      ),
                    ),
                  ),
                  AppSpacing.gapHSM,
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${row.done}/${row.total}',
                      // Tabular here: these align down the column.
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (rows.length > visible.length)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+${rows.length - visible.length} aktivitas lain',
              style: AppTextStyles.caption,
            ),
          ),
      ],
    );
  }
}

/// An ordered scale as one bar centred on its neutral middle.
///
/// Ships visible segment labels because the grey midpoint sits below the 3:1
/// mark-contrast floor, and a legend because two or more series are present.
class DivergingBar extends StatelessWidget {
  const DivergingBar({
    super.key,
    required this.split,
    required this.positiveLabel,
    required this.middleLabel,
    required this.negativeLabel,
  });

  final PolaritySplit split;
  final String positiveLabel;
  final String middleLabel;
  final String negativeLabel;

  @override
  Widget build(BuildContext context) {
    final total = split.settled + split.neutral + split.distressed;
    if (total == 0) {
      return Text('Belum ada data.', style: AppTextStyles.bodyS);
    }

    final segments = <({int count, Color color, String label})>[
      (count: split.settled, color: ChartColors.positive, label: positiveLabel),
      (count: split.neutral, color: ChartColors.middle, label: middleLabel),
      (count: split.distressed, color: ChartColors.negative, label: negativeLabel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: segments
              .where((s) => s.count > 0)
              .map((s) => '${s.label} ${s.count}')
              .join(', '),
          child: SizedBox(
            height: 22,
            child: Row(
              children: [
                for (var i = 0; i < segments.length; i++)
                  if (segments[i].count > 0) ...[
                    // A 2px surface gap separates fills — never a border drawn
                    // around the marks.
                    if (i > 0 && segments.take(i).any((s) => s.count > 0))
                      const SizedBox(width: 2),
                    Expanded(
                      flex: segments[i].count,
                      child: AnimatedContainer(
                        duration: AppTheme.motion(context, AppTheme.motionFast),
                        curve: AppTheme.motionCurve,
                        decoration: BoxDecoration(
                          color: segments[i].color,
                          borderRadius: const BorderRadius.all(AppRadius.xs),
                        ),
                        alignment: Alignment.center,
                        child: _SegmentLabel(count: segments[i].count),
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
        AppSpacing.gapXS,
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xxs,
          children: [
            for (final s in segments)
              if (s.count > 0) _LegendEntry(color: s.color, label: s.label),
          ],
        ),
      ],
    );
  }
}

/// The count inside a segment — but only when it fits, otherwise the segment
/// stays clean and the legend plus the detail rows carry the number.
class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final text = '$count';
      // ~7px per digit plus padding; below that a label would be clipped.
      final fits = constraints.maxWidth > text.length * 9 + 10;
      if (!fits) return const SizedBox.shrink();

      return Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onFilled,
          fontWeight: FontWeight.w700,
        ),
      );
    });
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(AppRadius.xs),
          ),
        ),
        AppSpacing.gapHXS,
        // Text wears text tokens — the swatch beside it carries the identity.
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

/// Completed activities per day. One hue, today emphasised.
class DailyTrend extends StatelessWidget {
  const DailyTrend({super.key, required this.days, required this.today});

  final List<DayCount> days;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final maxCount = days.fold(0, (a, d) => d.completed > a ? d.completed : a);
    // Labels only fit on a short range; past that the bars carry the shape and
    // the axis band would just collide with itself.
    final showLabels = days.length <= 7;

    return SizedBox(
      // Sized to include the axis band, so the card never grows a nested scroll.
      height: showLabels ? 132 : 104,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in days)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: showLabels ? 3 : 1),
                child: _TrendColumn(
                  entry: entry,
                  maxCount: maxCount,
                  isToday: sameDay(entry.day, today),
                  showLabels: showLabels,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendColumn extends StatelessWidget {
  const _TrendColumn({
    required this.entry,
    required this.maxCount,
    required this.isToday,
    required this.showLabels,
  });

  final DayCount entry;
  final int maxCount;
  final bool isToday;
  final bool showLabels;

  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final height = maxCount == 0 ? 4.0 : 6 + (entry.completed / maxCount) * 74;

    return Semantics(
      label: '${_weekdays[entry.day.weekday - 1]} '
          '${entry.day.day}: ${entry.completed} aktivitas',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLabels)
            Text(
              entry.completed == 0 ? '' : '${entry.completed}',
              style: AppTextStyles.caption,
            ),
          AppSpacing.gapXXS,
          AnimatedContainer(
            duration: AppTheme.motion(context, AppTheme.motionFast),
            curve: AppTheme.motionCurve,
            height: height,
            decoration: BoxDecoration(
              color: entry.completed == 0
                  ? ChartColors.track
                  : (isToday ? ChartColors.magnitude : AppColors.teal500),
              // Rounded data-end anchored to the baseline.
              borderRadius: const BorderRadius.vertical(top: AppRadius.xs),
            ),
          ),
          AppSpacing.gapXXS,
          if (showLabels)
            Text(
              _weekdays[entry.day.weekday - 1],
              style: AppTextStyles.caption.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

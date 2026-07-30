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
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/custom_icon.dart';
import 'board_editor.dart';
import '../../../shared/widgets/activity_image.dart';

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
                return _buildBody(context, ref, schedule);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Schedule schedule) {
    final isSchedule = schedule.type == BoardType.schedule;

    // Schedule boards run in clock order; the other board types carry meaning
    // in the order their cards were placed, so leave those untouched.
    final activities = isSchedule
        ? ([...schedule.activities]..sort((a, b) => a.startTime.compareTo(b.startTime)))
        : schedule.activities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref, schedule),
        Padding(
          padding: AppSpacing.pagePadding,
          child: Text(_subtitleFor(schedule, activities.length), style: AppTextStyles.bodyM),
        ),
        // Runnable board types get the SproutVoice guided run (doc §6.2).
        if (_isRunnable(schedule))
          Padding(
            padding: AppSpacing.pagePadding,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.peach500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => context.push(AppRoutes.runBoardPath(schedule.id)),
                icon: Icon(Icons.play_arrow, color: AppColors.white),
                label: Text(
                  'Mulai bersama anak',
                  style: AppTextStyles.headingM.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: AppSpacing.pagePadding,
            itemCount: activities.length,
            separatorBuilder: (_, _) => AppSpacing.gapMD,
            itemBuilder: (context, index) => _ActivityRow(
              scheduleId: schedule.id,
              activity: activities[index],
              showTime: isSchedule,
              showCompletion: schedule.type == BoardType.schedule ||
                  schedule.type == BoardType.firstThen,
            ),
          ),
        ),
      ],
    );
  }

  /// Schedule and first-then boards are sequences to work through. Waiting and
  /// emotion boards are references the parent shows in the moment.
  bool _isRunnable(Schedule schedule) =>
      (schedule.type == BoardType.schedule || schedule.type == BoardType.firstThen) &&
      schedule.activities.any((a) => !a.completed);

  String _subtitleFor(Schedule schedule, int cardCount) {
    switch (schedule.type) {
      case BoardType.schedule:
        final done = schedule.activities.where((a) => a.completed).length;
        return '$done dari $cardCount aktivitas selesai';
      case BoardType.waiting:
        final minutes = schedule.waitMinutes;
        return minutes == null
            ? 'Papan menunggu'
            : 'Papan menunggu • $minutes menit';
      case BoardType.firstThen:
      case BoardType.emotion:
        return '${boardTypeLabel(schedule.type)} • $cardCount kartu';
    }
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Schedule schedule) {
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.neutral800),
            onSelected: (value) => switch (value) {
              'rename' => _rename(context, ref, schedule),
              'delete' => _confirmDelete(context, ref, schedule),
              _ => null,
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Ubah nama papan')),
              PopupMenuItem(value: 'delete', child: Text('Hapus papan')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Schedule schedule) async {
    final title = await promptForTitle(context, current: schedule.title);
    if (title == null) return;
    await ref.read(scheduleServiceProvider).saveSchedule(schedule.copyWith(title: title));
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Schedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${schedule.title}?'),
        content: Text(
          'Papan ini akan dihapus permanen. Catatan perkembangan yang sudah tersimpan '
          'tidak terhapus.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(scheduleServiceProvider).deleteSchedule(schedule.id);
    if (context.mounted) context.pop();
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.scheduleId,
    required this.activity,
    required this.showTime,
    required this.showCompletion,
  });

  final String scheduleId;
  final Activity activity;

  /// Only schedule boards run to the clock.
  final bool showTime;

  /// Boards that are worked through show progress and open the single-activity
  /// page; waiting and emotion boards are read-only visual supports.
  final bool showCompletion;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withValues(alpha: 0.1)),
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
            child: ActivityImage(activity.icon),
          ),
          AppSpacing.gapHMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTextStyles.headingS),
                if (showTime)
                  Text(DateFormat.Hm().format(activity.startTime), style: AppTextStyles.caption),
              ],
            ),
          ),
          if (showCompletion)
            Icon(
              activity.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: activity.completed ? AppColors.success : AppColors.neutral500,
            ),
        ],
      ),
    );

    if (!showCompletion) return row;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.activityPath(scheduleId, activity.id)),
      child: row,
    );
  }
}

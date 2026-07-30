import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/child.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../sprout_plan/pages/board_editor.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                _Greeting(child: childAsync.valueOrNull),
                AppSpacing.gapXL,
                childAsync.when(
                  loading: () => const _PanelSkeleton(),
                  error: (e, _) => _Notice(
                    icon: Icons.cloud_off_outlined,
                    message: 'Gagal memuat profil anak.',
                    detail: '$e',
                  ),
                  data: (child) => child == null
                      ? const _Notice(
                          icon: Icons.person_outline,
                          message: 'Profil anak belum tersedia.',
                          detail: 'Daftarkan profil anak untuk mulai menyusun rutinitas.',
                        )
                      : _ChildSections(childId: child.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String greetingFor(DateTime now) {
    if (now.hour < 11) return 'Selamat pagi';
    if (now.hour < 15) return 'Selamat siang';
    if (now.hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

class Home extends HomePage {
  const Home({super.key});
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.child});

  final Child? child;

  @override
  Widget build(BuildContext context) {
    final name = child?.name;
    final photoUrl = child?.photoUrl ?? '';

    return Row(
      children: [
        _Avatar(photoUrl: photoUrl, radius: 28),
        AppSpacing.gapHMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(HomePage.greetingFor(DateTime.now()), style: AppTextStyles.caption),
              Text(
                name ?? 'Memuat…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayM,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: Icon(Icons.settings_outlined),
          tooltip: 'Pengaturan',
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.radius});

  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.teal100,
      child: ClipOval(
        child: photoUrl.isEmpty
            ? SvgPicture.asset(
                'assets/images/profile_pic.svg',
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              )
            : Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SvgPicture.asset(
                  'assets/images/profile_pic.svg',
                  width: radius * 2,
                  height: radius * 2,
                ),
              ),
      ),
    );
  }
}

/// The two data-backed sections: the activity in progress and the board grid.
class _ChildSections extends ConsumerWidget {
  const _ChildSections({required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    return schedulesAsync.when(
      loading: () => const _PanelSkeleton(),
      error: (e, _) => _Notice(
        icon: Icons.cloud_off_outlined,
        message: 'Gagal memuat papan.',
        detail: '$e',
      ),
      data: (schedules) {
        final pending = nextPendingActivity(schedules);
        final hasScheduleBoard = schedules.any((s) => s.type == BoardType.schedule);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Sedang dikerjakan'),
            AppSpacing.gapSM,
            if (pending == null)
              _Notice(
                icon: hasScheduleBoard ? Icons.check_circle_outline : Icons.event_note_outlined,
                message: hasScheduleBoard
                    ? 'Semua aktivitas hari ini sudah selesai.'
                    : 'Belum ada papan jadwal.',
                detail: hasScheduleBoard
                    ? 'Kerja bagus. Papan akan terisi lagi besok.'
                    : 'Buka menu Papan untuk menyusun rutinitas pertama.',
                action: hasScheduleBoard
                    ? null
                    : (
                        'Buat papan',
                        () => context.push(AppRoutes.createBoard),
                      ),
              )
            else
              _CurrentTaskCard(
                scheduleId: pending.scheduleId,
                scheduleTitle: pending.scheduleTitle,
                activity: pending.activity,
              ),
            AppSpacing.gapXXL,
            Row(
              children: [
                const Expanded(child: _SectionTitle('Papan saya')),
                if (schedules.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go(AppRoutes.board),
                    child: Text('Lihat semua'),
                  ),
              ],
            ),
            AppSpacing.gapSM,
            if (schedules.isEmpty)
              const _Notice(
                icon: Icons.dashboard_customize_outlined,
                message: 'Belum ada papan yang dibuat.',
                detail: 'Papan adalah kumpulan kartu bergambar yang menuntun anak '
                    'menjalani rutinitas.',
              )
            else
              _BoardGrid(schedules: schedules),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.headingL);
}

/// The earliest not-yet-completed activity across the child's schedule boards,
/// or null when every activity is done (or there are no schedule boards).
///
/// Only [BoardType.schedule] boards count: waiting, first-then and emotion
/// boards are visual supports the parent opens on demand, not timed routines.
({String scheduleId, String scheduleTitle, Activity activity})? nextPendingActivity(
  List<Schedule> schedules,
) {
  final pending = <({String scheduleId, String scheduleTitle, Activity activity})>[
    for (final schedule in schedules)
      if (schedule.type == BoardType.schedule)
        for (final activity in schedule.activities)
          if (!activity.completed)
            (scheduleId: schedule.id, scheduleTitle: schedule.title, activity: activity),
  ]..sort((a, b) => a.activity.startTime.compareTo(b.activity.startTime));

  return pending.isEmpty ? null : pending.first;
}

typedef _NoticeAction = (String label, VoidCallback onPressed);

/// Empty, error and done states. One shape for all three so the page reads
/// consistently instead of each state inventing its own layout.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.message,
    this.detail,
    this.action,
  });

  final IconData icon;
  final String message;
  final String? detail;
  final _NoticeAction? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          AppSpacing.gapHSM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppTextStyles.headingS),
                if (detail != null) ...[
                  AppSpacing.gapXXS,
                  Text(detail!, style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textSecondary,
                  )),
                ],
                if (action != null) ...[
                  AppSpacing.gapXS,
                  FilledButton(
                    onPressed: action!.$2,
                    child: Text(action!.$1),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shaped like the content it replaces, so nothing jumps when the
/// data arrives.
class _PanelSkeleton extends StatelessWidget {
  const _PanelSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: AppRadius.card,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Sedang dikerjakan'),
        AppSpacing.gapSM,
        block(104),
        AppSpacing.gapXXL,
        const _SectionTitle('Papan saya'),
        AppSpacing.gapSM,
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(child: block(150)),
              AppSpacing.gapHMD,
              Expanded(child: block(150)),
              AppSpacing.gapHMD,
              Expanded(child: block(150)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentTaskCard extends StatelessWidget {
  const _CurrentTaskCard({
    required this.scheduleId,
    required this.scheduleTitle,
    required this.activity,
  });

  final String scheduleId;
  final String scheduleTitle;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.teal100,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.activityPath(scheduleId, activity.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.button,
                ),
                child: ActivityImage(activity.icon),
              ),
              AppSpacing.gapHMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingL,
                    ),
                    AppSpacing.gapXXS,
                    Text(
                      // Time first: it is the thing a parent scans for.
                      '${DateFormat.Hm().format(activity.startTime)} · $scheduleTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapHXS,
              Icon(Icons.chevron_right, color: AppColors.teal900, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({required this.schedules});

  final List<Schedule> schedules;

  @override
  Widget build(BuildContext context) {
    // Home shows a preview, not the whole library — the Papan tab is for that.
    final visible = schedules.take(6).toList();

    return LayoutBuilder(builder: (context, constraints) {
      // Fixed-width tiles that wrap, so a tablet fits more per row instead of
      // stretching three tiles to fill the space.
      final columns = (constraints.maxWidth / 168).floor().clamp(2, 5);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.82,
        ),
        itemCount: visible.length,
        itemBuilder: (context, index) => BoardTile(schedule: visible[index]),
      );
    });
  }
}

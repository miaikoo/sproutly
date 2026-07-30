import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/activity.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../sprout_plan/pages/board_editor.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _backgroundColor = AppColors.background;
  static const _cardBackground = AppColors.teal100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(context, childAsync.valueOrNull?.name),
                  const SizedBox(height: 24),
                  childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Gagal memuat profil anak: $e', style: _bodyStyle),
                    data: (child) => child == null
                        ? Text('Profil anak belum tersedia.', style: _bodyStyle)
                        : _ChildSections(childId: child.id),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
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

  Widget _buildHeader(BuildContext context, String? childName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Avatar profile picture
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.neutral300,
                child: ClipOval(
                  child: SvgPicture.asset(
                    'assets/images/profile_pic.svg',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingFor(DateTime.now()),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      childName ?? '...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Settings Routing
        GestureDetector(
          onTap: () {
            context.push(AppRoutes.settings);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: const Icon(
              Icons.settings,
              color: AppColors.neutral800,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

const _bodyStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 16,
  fontFamily: 'Nunito',
  fontWeight: FontWeight.w400,
);

const _sectionTitleStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 20,
  fontFamily: 'Nunito',
  fontWeight: FontWeight.w600,
);

class Home extends HomePage {
  const Home({super.key});
}

/// The two data-backed sections: the activity in progress and the board grid.
class _ChildSections extends ConsumerWidget {
  const _ChildSections({required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesForChildProvider(childId));

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Gagal memuat papan: $e', style: _bodyStyle),
      data: (schedules) {
        final pending = nextPendingActivity(schedules);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sedang dikerjakan', style: _sectionTitleStyle),
            const SizedBox(height: 12),
            if (pending == null)
              _EmptyCard(
                message: schedules.any((s) => s.type == BoardType.schedule)
                    ? 'Semua aktivitas hari ini sudah selesai. Hebat!'
                    : 'Belum ada papan jadwal. Buat papan di menu Papan untuk mulai.',
              )
            else
              _CurrentTaskCard(
                scheduleId: pending.scheduleId,
                scheduleTitle: pending.scheduleTitle,
                activity: pending.activity,
              ),
            const SizedBox(height: 32),
            const Text('Papan saya', style: _sectionTitleStyle),
            const SizedBox(height: 16),
            if (schedules.isEmpty)
              _EmptyCard(message: 'Belum ada papan yang dibuat.')
            else
              _buildBoardGrid(schedules),
          ],
        );
      },
    );
  }

  Widget _buildBoardGrid(List<Schedule> schedules) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.80,
      ),
      itemCount: schedules.length,
      itemBuilder: (context, index) => _BoardCard(schedule: schedules[index]),
    );
  }
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePage._cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: _bodyStyle),
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
    return GestureDetector(
      onTap: () => context.push(AppRoutes.activityPath(scheduleId, activity.id)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: HomePage._cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(activity.icon, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheduleTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _bodyStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow chevron_right (mengikuti figma)
            const Icon(Icons.chevron_right, color: AppColors.neutral800, size: 32),
          ],
        ),
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.schedule});

  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    final thumbnail = schedule.activities.isNotEmpty ? schedule.activities.first.icon : null;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.boardDetailPath(schedule.id)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: boardColor(schedule.type),
                borderRadius: BorderRadius.circular(24),
              ),
              child: thumbnail != null
                  ? Image.asset(thumbnail, fit: BoxFit.contain)
                  : const Icon(Icons.event_note, color: AppColors.white, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            schedule.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

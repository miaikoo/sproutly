import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import '../../../core/data/reinforcement_policy.dart';
import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activity.dart';
import '../../../models/behaviour_log.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/custom_icon.dart';

const _moodOptions = {
  Mood.happy: ('😊', 'Senang'),
  Mood.neutral: ('😐', 'Biasa'),
  Mood.upset: ('😢', 'Sedih'),
};

const _transitionOptions = {
  TransitionDifficulty.low: 'Mudah',
  TransitionDifficulty.medium: 'Sedang',
  TransitionDifficulty.high: 'Sulit',
};

class ActivityDetailPage extends ConsumerStatefulWidget {
  const ActivityDetailPage({super.key, required this.scheduleId, required this.activityId});

  final String scheduleId;
  final String activityId;

  @override
  ConsumerState<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends ConsumerState<ActivityDetailPage> {
  Mood _mood = Mood.happy;
  TransitionDifficulty _difficulty = TransitionDifficulty.low;
  bool _isSaving = false;
  String? _spokenActivityId;

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleByIdProvider(widget.scheduleId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat aktivitas: $e')),
              data: (schedule) {
                final matches = schedule?.activities.where((a) => a.id == widget.activityId) ?? const [];
                final activity = matches.isEmpty ? null : matches.first;
                if (activity == null) {
                  return const Center(child: Text('Aktivitas tidak ditemukan.'));
                }
                return _buildBody(context, activity);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Activity activity) {
    if (!activity.completed && _spokenActivityId != activity.id) {
      _spokenActivityId = activity.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(voiceServiceProvider).speak('Sekarang saatnya ${activity.title}.');
      });
    }

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Expanded(child: Text(activity.title, style: AppTextStyles.displayM)),
            ],
          ),
          AppSpacing.gapXL,
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(activity.icon, fit: BoxFit.contain),
            ),
          ),
          AppSpacing.gapMD,
          Center(
            child: Text(
              'Jadwal: ${DateFormat.Hm().format(activity.startTime)}',
              style: AppTextStyles.bodyM,
            ),
          ),
          AppSpacing.gapXL,
          if (activity.completed)
            Center(
              child: Text('Aktivitas ini sudah diselesaikan.', style: AppTextStyles.headingM),
            )
          else ...[
            Text('Bagaimana perasaan anak?', style: AppTextStyles.headingM),
            AppSpacing.gapSM,
            _moodPicker(),
            AppSpacing.gapXL,
            Text('Seberapa sulit transisi ke aktivitas ini?', style: AppTextStyles.headingM),
            AppSpacing.gapSM,
            _difficultyPicker(),
            AppSpacing.gapXL,
            _completeButton(activity),
          ],
        ],
      ),
    );
  }

  Widget _moodPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moodOptions.entries.map((entry) {
        final isSelected = _mood == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _mood = entry.key),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isSelected ? AppColors.teal300 : AppColors.neutral200,
                child: Text(entry.value.$1, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 4),
              Text(entry.value.$2, style: AppTextStyles.caption),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _difficultyPicker() {
    return Row(
      children: _transitionOptions.entries.map((entry) {
        final isSelected = _difficulty == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _difficulty = entry.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal500 : AppColors.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.value,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM.copyWith(color: isSelected ? AppColors.white : AppColors.textPrimary),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _completeButton(Activity activity) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.peach500,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onPressed: _isSaving ? null : () => _markComplete(activity),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
              )
            : Text('Tandai Selesai', style: AppTextStyles.headingL.copyWith(color: AppColors.white)),
      ),
    );
  }

  Future<void> _markComplete(Activity activity) async {
    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      // Read history before writing this log, so today's entry doesn't skew the
      // level chosen for it.
      final recentLogs = await ref.read(logsForChildProvider(child.id).future);

      final logService = ref.read(behaviourLogServiceProvider);
      final log = BehaviourLog(
        id: logService.newLogId(),
        childId: child.id,
        activityId: activity.id,
        timestamp: DateTime.now(),
        mood: _mood,
        promptType: PromptType.visual,
        rewardId: null,
        transitionDifficulty: _difficulty,
        completed: true,
        durationMinutes: activity.endTime.difference(activity.startTime).inMinutes,
      );
      await logService.addLog(log);

      await ref.read(scheduleServiceProvider).setActivityCompleted(
            scheduleId: widget.scheduleId,
            activityId: widget.activityId,
            completed: true,
          );

      final level = levelFor(recentLogs: recentLogs, currentMood: _mood);
      unawaited(ref.read(voiceServiceProvider).speak(phraseFor(level)));

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

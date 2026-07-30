import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../../models/schedule.dart';
import 'board_editor.dart';

const _moodOptions = {
  Mood.happy: ('😊', 'Senang'),
  Mood.neutral: ('😐', 'Biasa'),
  Mood.upset: ('😢', 'Sedih'),
};

/// SproutVoice's guided run (RF-06, RF-07): walks the child through a board one
/// activity at a time, reading each step aloud, and celebrating between
/// activities. Doc §6.2.
class RunBoardPage extends ConsumerStatefulWidget {
  const RunBoardPage({super.key, required this.scheduleId});

  final String scheduleId;

  @override
  ConsumerState<RunBoardPage> createState() => _RunBoardPageState();
}

class _RunBoardPageState extends ConsumerState<RunBoardPage> {
  /// Activity ids to run, captured once when the board first loads. Marking an
  /// activity complete updates the stream, so recomputing this every build
  /// would drop activities out from under the parent mid-routine.
  List<String>? _runOrder;

  int _activityIndex = 0;
  int _stepIndex = 0;
  bool _isSaving = false;

  /// Set once the activity is marked done: the parent is being asked how it went.
  bool _askingMood = false;

  /// Set after the mood is known, so praise matches what actually happened.
  ReinforcementLevel? _celebrating;
  String _celebrationPhrase = '';

  /// Guards against re-speaking the same step on every rebuild.
  String? _spokenKey;

  /// Held directly rather than read in [dispose] — reading a provider while the
  /// scope is being torn down can throw, and leaving the child's device talking
  /// after the page closes is worse than a lint.
  late final VoiceService _voice = ref.read(voiceServiceProvider);

  @override
  void dispose() {
    _voice.stop();
    super.dispose();
  }

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
              error: (e, _) => Center(child: Text('Gagal memuat papan: $e')),
              data: (schedule) {
                if (schedule == null) {
                  return const Center(child: Text('Papan tidak ditemukan.'));
                }

                _runOrder ??= pendingRunOrder(schedule);
                final order = _runOrder!;

                if (order.isEmpty) {
                  return _AllDone(
                    message: 'Semua aktivitas di papan ini sudah selesai.',
                    onClose: () => context.pop(),
                  );
                }
                if (_activityIndex >= order.length) {
                  return _AllDone(
                    message: 'Rutinitas selesai. Kerja bagus!',
                    onClose: () => context.pop(),
                  );
                }

                final matches =
                    schedule.activities.where((a) => a.id == order[_activityIndex]);
                if (matches.isEmpty) {
                  // The activity vanished (board edited elsewhere) — skip it.
                  return _AllDone(
                    message: 'Aktivitas tidak ditemukan lagi.',
                    onClose: () => context.pop(),
                  );
                }

                final activity = matches.first;
                final isLast = _activityIndex == order.length - 1;

                final level = _celebrating;
                if (level != null) {
                  return _Celebration(
                    level: level,
                    phrase: _celebrationPhrase,
                    activityTitle: activity.title,
                    isLast: isLast,
                    onNext: _advance,
                    onReplay: () => _speak(_celebrationPhrase),
                  );
                }
                if (_askingMood) {
                  return _MoodPrompt(
                    activityTitle: activity.title,
                    isSaving: _isSaving,
                    onMoodPicked: (mood) => _finishActivity(activity, mood),
                  );
                }

                return _buildRunning(context, schedule, activity, order.length);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRunning(
    BuildContext context,
    Schedule schedule,
    Activity activity,
    int total,
  ) {
    final steps = activity.steps;
    final hasSteps = steps.isNotEmpty;
    final stepText = hasSteps ? steps[_stepIndex] : 'Ayo lakukan ${activity.title}.';
    final isLastStep = !hasSteps || _stepIndex == steps.length - 1;

    // Speak each step as it appears — this is the voice prompting itself.
    final key = '${activity.id}-$_stepIndex';
    if (_spokenKey != key) {
      _spokenKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak(stepText));
    }

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _confirmQuit(context),
                icon: const Icon(Icons.close, color: AppColors.neutral800),
              ),
              Expanded(
                child: Text(
                  'Aktivitas ${_activityIndex + 1} dari $total',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          AppSpacing.gapMD,
          Text(activity.title, style: AppTextStyles.displayM),
          AppSpacing.gapLG,
          Center(
            child: Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(activity.icon, fit: BoxFit.contain),
            ),
          ),
          AppSpacing.gapXL,
          if (hasSteps)
            Text(
              'Langkah ${_stepIndex + 1} dari ${steps.length}',
              style: AppTextStyles.caption,
            ),
          AppSpacing.gapXS,
          Text(stepText, style: AppTextStyles.headingL),
          const Spacer(),
          Row(
            children: [
              // Repeating the prompt is the most common thing a parent needs,
              // so it gets its own button rather than hiding in a menu.
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _speak(stepText),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Ulangi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              AppSpacing.gapHMD,
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.peach500,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: isLastStep ? _markDone : _nextStep,
                  child: Text(
                    isLastStep ? 'Selesai' : 'Langkah berikutnya',
                    style: AppTextStyles.headingM.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
          if (_stepIndex > 0)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => setState(() => _stepIndex--),
                child: const Text('Kembali ke langkah sebelumnya'),
              ),
            ),
          AppSpacing.gapMD,
        ],
      ),
    );
  }

  void _speak(String text) => _voice.speak(text);

  void _nextStep() => setState(() => _stepIndex++);

  /// Steps are done — ask how it went before praising, so the praise can match.
  void _markDone() => setState(() => _askingMood = true);

  /// Writes the log, then praises at a level chosen from the child's history and
  /// the mood just reported. Reinforcement is spoken as well as shown (RF-07).
  Future<void> _finishActivity(Activity activity, Mood mood) async {
    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      // Read history before writing this entry so it doesn't score itself.
      final recentLogs = await ref.read(logsForChildProvider(child.id).future);

      final logService = ref.read(behaviourLogServiceProvider);
      await logService.addLog(BehaviourLog(
        id: logService.newLogId(),
        childId: child.id,
        activityId: activity.id,
        timestamp: DateTime.now(),
        mood: mood,
        promptType: PromptType.voice,
        rewardId: null,
        // ponytail: a guided run asks for mood only — two questions per
        // activity is too much friction mid-routine. Log a single activity from
        // the board detail page when transition difficulty matters.
        transitionDifficulty: TransitionDifficulty.low,
        completed: true,
        durationMinutes: activity.endTime.difference(activity.startTime).inMinutes,
      ));

      await ref.read(scheduleServiceProvider).setActivityCompleted(
            scheduleId: widget.scheduleId,
            activityId: activity.id,
            completed: true,
          );

      final level = levelFor(recentLogs: recentLogs, currentMood: mood);
      final phrase = phraseFor(level);
      unawaited(_voice.speak(phrase));

      if (mounted) {
        setState(() {
          _askingMood = false;
          _celebrating = level;
          _celebrationPhrase = phrase;
        });
      }
    } catch (e) {
      if (mounted) showBoardSnack(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _advance() {
    setState(() {
      _celebrating = null;
      _celebrationPhrase = '';
      _stepIndex = 0;
      _activityIndex++;
    });
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hentikan rutinitas?'),
        content: const Text('Aktivitas yang sudah ditandai selesai tetap tersimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Lanjut')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hentikan')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      unawaited(_voice.stop());
      context.pop();
    }
  }
}

/// Ids of the activities still to do, in the order the board runs them.
/// Schedule boards run by clock time; other board types keep their card order.
List<String> pendingRunOrder(Schedule schedule) {
  final activities = schedule.type == BoardType.schedule
      ? ([...schedule.activities]..sort((a, b) => a.startTime.compareTo(b.startTime)))
      : schedule.activities;

  return [
    for (final activity in activities)
      if (!activity.completed) activity.id,
  ];
}

/// Asked between the last step and the praise, so the praise can react to it.
class _MoodPrompt extends StatelessWidget {
  const _MoodPrompt({
    required this.activityTitle,
    required this.isSaving,
    required this.onMoodPicked,
  });

  final String activityTitle;
  final bool isSaving;
  final ValueChanged<Mood> onMoodPicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(activityTitle, style: AppTextStyles.headingM),
          AppSpacing.gapXS,
          Text(
            'Bagaimana perasaan anak?',
            style: AppTextStyles.displayM,
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapXXL,
          if (isSaving)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _moodOptions.entries.map((entry) {
                return GestureDetector(
                  onTap: () => onMoodPicked(entry.key),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.neutral200,
                        child: Text(entry.value.$1, style: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(height: 6),
                      Text(entry.value.$2, style: AppTextStyles.bodyM),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _Celebration extends StatelessWidget {
  const _Celebration({
    required this.level,
    required this.phrase,
    required this.activityTitle,
    required this.isLast,
    required this.onNext,
    required this.onReplay,
  });

  final ReinforcementLevel level;
  final String phrase;
  final String activityTitle;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    // Gentle praise shouldn't arrive with confetti.
    final isGentle = level == ReinforcementLevel.gentle;

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: isGentle ? AppColors.neutral200 : AppColors.teal100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(isGentle ? '💛' : '🎉', style: const TextStyle(fontSize: 72)),
            ),
          ),
          AppSpacing.gapLG,
          Text(badgeFor(level), style: AppTextStyles.displayL, textAlign: TextAlign.center),
          AppSpacing.gapXS,
          Text(activityTitle, style: AppTextStyles.bodyM),
          AppSpacing.gapLG,
          Text(phrase, style: AppTextStyles.headingM, textAlign: TextAlign.center),
          AppSpacing.gapMD,
          TextButton.icon(
            onPressed: onReplay,
            icon: const Icon(Icons.volume_up),
            label: const Text('Dengarkan lagi'),
          ),
          AppSpacing.gapXL,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.peach500,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: onNext,
              child: Text(
                isLast ? 'Selesaikan rutinitas' : 'Aktivitas berikutnya',
                style: AppTextStyles.headingM.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDone extends StatelessWidget {
  const _AllDone({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 72)),
          AppSpacing.gapLG,
          Text(message, style: AppTextStyles.headingL, textAlign: TextAlign.center),
          AppSpacing.gapXL,
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.peach500,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: onClose,
            child: Text('Tutup', style: AppTextStyles.headingM.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/companion_progress.dart';
import '../../../core/data/reinforcement_policy.dart';
import '../../../core/services/behaviour_log_service.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/activity.dart';
import '../../../models/behaviour_log.dart';
import '../../../models/enums.dart';
import '../../../models/schedule.dart';
import '../../../shared/widgets/activity_image.dart';
import 'board_editor.dart';

const _moodOptions = {
  Mood.happy: ('😊', 'Senang'),
  Mood.neutral: ('😐', 'Biasa'),
  Mood.upset: ('😢', 'Sedih'),
};

enum _BoardFlowPhase {
  waitingCountdown,
  waitingChoice,
  emotionConfirm,
  emotionChoice,
  emotionRewardChoice,
  routine,
}

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

  Timer? _activityTimeoutTimer;
  String? _activeTimeoutActivityId;
  _BoardFlowPhase? _flowPhase;
  Timer? _waitingTimer;
  Duration _remainingWait = Duration.zero;

  /// Set once the activity is marked done: the parent is being asked how it went.
  bool _askingMood = false;

  /// Tracks if we are in the reward activity of an Emotion Board
  bool _isRewardPhase = false;

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
    _cancelActivityTimeout();
    _cancelWaitingTimer();
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
            // Roomier than the form pages: this is the screen the child looks
            // at, so it should use a tablet's width rather than sit in a
            // narrow column.
            constraints: const BoxConstraints(maxWidth: 900),
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat papan: $e')),
              data: (schedule) {
                if (schedule == null) {
                  return const Center(child: Text('Papan tidak ditemukan.'));
                }

                if (_runOrder == null) {
                  if (schedule.type == BoardType.waiting) {
                    _flowPhase = _BoardFlowPhase.waitingCountdown;
                  } else if (schedule.type == BoardType.emotion) {
                    _flowPhase = _BoardFlowPhase.emotionConfirm;
                  } else {
                    _flowPhase = _BoardFlowPhase.routine;
                  }
                  _runOrder = pendingRunOrder(schedule);
                }

                if (_flowPhase == _BoardFlowPhase.waitingCountdown) {
                  _startWaitingCountdown(schedule);
                  return _WaitingCountdown(
                    waitMinutes: schedule.waitMinutes ?? 5,
                    remaining: _remainingWait,
                    activity: schedule.activities.isNotEmpty ? schedule.activities.first : null,
                    onSkip: () {
                      _cancelWaitingTimer();
                      if (schedule.activities.isNotEmpty) {
                        _markIncomplete(schedule.activities.first, reason: 'skip');
                      } else {
                        setState(() {
                          _flowPhase = _BoardFlowPhase.waitingChoice;
                        });
                      }
                    },
                  );
                }
                
                if (_flowPhase == _BoardFlowPhase.waitingChoice) {
                  final choices = _waitingChoices(schedule);
                  if (choices.isEmpty) {
                    return _AllDone(
                      message: 'Tidak ada aktivitas yang dipilih untuk papan menunggu ini.',
                      onClose: () => context.pop(),
                    );
                  }
                  return _WaitingChoice(
                    activities: choices,
                    onPick: (activity) => _startChoiceActivity(activity),
                  );
                }

                if (_flowPhase == _BoardFlowPhase.emotionConfirm) {
                  if (schedule.activities.isEmpty) {
                    return _AllDone(
                      message: 'Tidak ada perasaan yang dipilih.',
                      onClose: () => context.pop(),
                    );
                  }
                  return _EmotionConfirm(
                    activity: schedule.activities.first,
                    onConfirm: () {
                      setState(() {
                        _flowPhase = _BoardFlowPhase.emotionChoice;
                      });
                    },
                  );
                }

                if (_flowPhase == _BoardFlowPhase.emotionChoice) {
                  if (schedule.activities.length < 3) {
                    return _AllDone(
                      message: 'Tidak ada pilihan aktivitas untuk meregulasi emosi.',
                      onClose: () => context.pop(),
                    );
                  }
                  return _EmotionChoice(
                    title: 'aku bisa...',
                    activities: [schedule.activities[1], schedule.activities[2]],
                    onPick: (activity) {
                      _isRewardPhase = false;
                      _startChoiceActivity(activity);
                    },
                  );
                }

                if (_flowPhase == _BoardFlowPhase.emotionRewardChoice) {
                  if (schedule.activities.length < 5) {
                    return _AllDone(
                      message: 'Tidak ada pilihan aktivitas reward.',
                      onClose: () => context.pop(),
                    );
                  }
                  return _EmotionChoice(
                    title: 'kemudian aku bisa melakukan...',
                    activities: [schedule.activities[3], schedule.activities[4]],
                    onPick: (activity) {
                      _isRewardPhase = true;
                      _startChoiceActivity(activity);
                    },
                  );
                }

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
    _startActivityTimeout(activity);

    final hasSteps = steps.isNotEmpty;
    final stepText = hasSteps ? steps[_stepIndex] : 'Ayo lakukan ${activity.title}.';
    final isLastStep = !hasSteps || _stepIndex == steps.length - 1;

    // Speak each step as it appears — this is the voice prompting itself.
    final key = '${activity.id}-$_stepIndex';
    if (_spokenKey != key) {
      _spokenKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) => _speak(stepText));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final wide = isWideLayout(constraints.biggest);
      final align = wide ? TextAlign.start : TextAlign.center;

      final picture = _picture(activity, constraints.biggest, wide: wide);
      final instructions = Column(
        crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: wide ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(activity.title, style: AppTextStyles.headingM.copyWith(
            color: AppColors.textSecondary,
          )),
          AppSpacing.gapXS,
          // The step is the sentence the child is being asked to act on, so it
          // is the largest thing on screen — larger than the activity name.
          Text(stepText, style: AppTextStyles.displayM, textAlign: align),
          if (hasSteps) ...[
            AppSpacing.gapMD,
            _StepDots(
              current: _stepIndex,
              total: steps.length,
              alignment: wide ? WrapAlignment.start : WrapAlignment.center,
            ),
          ],
        ],
      );

      return Padding(
        padding: AppSpacing.pagePadding,
        // Header and actions sit outside the scroll area, so the buttons stay
        // reachable and nothing can overflow when the tablet is rotated.
        child: Column(
          children: [
            Row(
              children: [
                // Quiet and cornered: the exit is for the parent, and it should
                // not compete with the activity for the child's attention.
                IconButton(
                  onPressed: () => _confirmQuit(context),
                  icon: Icon(Icons.close),
                  color: AppColors.textSecondary,
                  tooltip: 'Hentikan rutinitas',
                ),
                Expanded(
                  child: _ActivityProgress(
                    current: _activityIndex,
                    total: total,
                  ),
                ),
                const SizedBox(width: AppTheme.minTarget),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          picture,
                          AppSpacing.gapHXL,
                          Expanded(child: instructions),
                        ],
                      )
                    : Column(
                        children: [
                          AppSpacing.gapMD,
                          picture,
                          AppSpacing.gapXL,
                          instructions,
                        ],
                      ),
              ),
            ),
            AppSpacing.gapMD,
            Row(
              children: [
                // Repeating the prompt is the most common thing a parent needs,
                // so it gets its own button rather than hiding in a menu.
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _speak(stepText),
                    icon: Icon(Icons.volume_up_outlined),
                    label: Text('Ulangi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                AppSpacing.gapHMD,
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _markIncomplete(activity, reason: 'skip'),
                    icon: Icon(Icons.skip_next_outlined),
                    label: Text('Lewati'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapSM,
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: isLastStep ? _markDone : _nextStep,
                child: Text(isLastStep ? 'Selesai' : 'Langkah berikutnya'),
              ),
            ),
            // Reserve the row whether or not the back link is shown, so the
            // primary button never shifts under the parent's thumb mid-routine.
            SizedBox(
              height: AppTheme.minTarget,
              child: _stepIndex > 0
                  ? Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _stepIndex--),
                        icon: Icon(Icons.arrow_back, size: 18),
                        label: Text('Langkah sebelumnya'),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _picture(Activity activity, Size available, {required bool wide}) {
    final side = pictureSide(available, wide: wide);
    return Container(
      width: side,
      height: side,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.imagePlate,
        borderRadius: AppRadius.tile,
      ),
      child: ActivityImage(activity.icon),
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

      final reward = rewardByLevel[level]!;
      unawaited(
        ref.read(childServiceProvider).awardReward(child.id, points: reward, exp: reward),
      );

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
    _cancelActivityTimeout();
    setState(() {
      _celebrating = null;
      _celebrationPhrase = '';
      _stepIndex = 0;
      _activityIndex++;
      
      final schedule = ref.read(scheduleByIdProvider(widget.scheduleId)).valueOrNull;
      if (schedule != null) {
        if (schedule.type == BoardType.emotion && _flowPhase == _BoardFlowPhase.routine) {
          if (!_isRewardPhase && _activityIndex >= _runOrder!.length) {
            _flowPhase = _BoardFlowPhase.emotionRewardChoice;
          }
        } else if (schedule.type == BoardType.waiting && _flowPhase == _BoardFlowPhase.waitingCountdown) {
          _flowPhase = _BoardFlowPhase.waitingChoice;
        }
      }
    });
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hentikan rutinitas?'),
        content: Text('Aktivitas yang sudah ditandai selesai tetap tersimpan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Lanjut')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hentikan')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _cancelActivityTimeout();
      unawaited(_voice.stop());
      context.pop();
    }
  }

  void _startWaitingCountdown(Schedule schedule) {
    if (schedule.waitMinutes == null || _waitingTimer != null) return;

    final totalSeconds = (schedule.waitMinutes! * 60).clamp(1, 3600);
    _remainingWait = Duration(seconds: totalSeconds);
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingWait.inSeconds <= 1) {
          timer.cancel();
          _waitingTimer = null;
          _remainingWait = Duration.zero;
          
          if (schedule.activities.isNotEmpty) {
            _finishActivity(schedule.activities.first, Mood.neutral);
          } else {
            _flowPhase = _BoardFlowPhase.waitingChoice;
          }
        } else {
          _remainingWait -= const Duration(seconds: 1);
        }
      });
    });
  }

  void _cancelWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
    _remainingWait = Duration.zero;
  }

  List<Activity> _waitingChoices(Schedule schedule) {
    if (schedule.type != BoardType.waiting) return const [];
    return schedule.activities.skip(1).toList();
  }

  void _startChoiceActivity(Activity activity) {
    _cancelWaitingTimer();
    _flowPhase = _BoardFlowPhase.routine;
    _runOrder = [activity.id];
    _activityIndex = 0;
    _stepIndex = 0;
    _spokenKey = null;
    _askingMood = false;
    _celebrating = null;
    _celebrationPhrase = '';
    setState(() {});
  }

  void _startActivityTimeout(Activity activity) {
    final durationMinutes = activity.endTime.difference(activity.startTime).inMinutes;
    if (durationMinutes <= 0) return;
    if (_activeTimeoutActivityId == activity.id) return;

    _cancelActivityTimeout();
    _activeTimeoutActivityId = activity.id;

    _activityTimeoutTimer = Timer(Duration(minutes: durationMinutes), () {
      if (!mounted) return;
      _markIncomplete(activity, reason: 'timeout');
    });
  }

  void _cancelActivityTimeout() {
    _activityTimeoutTimer?.cancel();
    _activityTimeoutTimer = null;
    _activeTimeoutActivityId = null;
  }

  Future<void> _markIncomplete(Activity activity, {required String reason}) async {
    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      final logService = ref.read(behaviourLogServiceProvider);
      await logService.addLog(BehaviourLog(
        id: logService.newLogId(),
        childId: child.id,
        activityId: activity.id,
        timestamp: DateTime.now(),
        mood: Mood.neutral,
        promptType: PromptType.voice,
        rewardId: null,
        transitionDifficulty: TransitionDifficulty.low,
        completed: false,
        durationMinutes: 0,
      ));

      await ref.read(scheduleServiceProvider).setActivityCompleted(
            scheduleId: widget.scheduleId,
            activityId: activity.id,
            completed: false,
          );

      if (mounted) {
        setState(() {
          _askingMood = false;
          _celebrating = null;
          _celebrationPhrase = '';
          _stepIndex = 0;
          _activityIndex++;
          
          final schedule = ref.read(scheduleByIdProvider(widget.scheduleId)).valueOrNull;
          if (schedule != null) {
            if (schedule.type == BoardType.emotion && _flowPhase == _BoardFlowPhase.routine) {
              if (!_isRewardPhase && _activityIndex >= _runOrder!.length) {
                _flowPhase = _BoardFlowPhase.emotionRewardChoice;
              }
            } else if (schedule.type == BoardType.waiting && _flowPhase == _BoardFlowPhase.waitingCountdown) {
              _flowPhase = _BoardFlowPhase.waitingChoice;
            }
          }
        });
      }
    } catch (e) {
      // ignore errors
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// Side-by-side picture and instructions once there is clearly more width than
/// height — a tablet in landscape. A tablet in portrait is wide in pixels but
/// still taller than it is wide, so it stays stacked.
bool isWideLayout(Size available) =>
    available.width >= 600 && available.width > available.height * 1.2;

/// How big the activity picture should be. Grows with the space available so a
/// tablet doesn't show a child a phone-sized image, but stays bounded so it
/// never crowds out the instruction text.
double pictureSide(Size available, {required bool wide}) {
  final budget = wide ? available.width * 0.38 : available.width * 0.62;
  return budget.clamp(140.0, 340.0);
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

/// How far through the board, as a bar of segments rather than a sentence.
///
/// Predictability is the point of a visual schedule: seeing how much is left
/// lowers anxiety about the transition. A child who cannot read "Aktivitas 2
/// dari 4" can still read four segments with two filled.
class _ActivityProgress extends StatelessWidget {
  const _ActivityProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Aktivitas ${current + 1} dari $total',
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: AnimatedContainer(
                duration: AppTheme.motion(context, AppTheme.motionFast),
                curve: AppTheme.motionCurve,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= current ? AppColors.teal700 : AppColors.neutral200,
                  borderRadius: const BorderRadius.all(AppRadius.xs),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Steps within the current activity. Same reasoning as [_ActivityProgress],
/// one level down.
class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.current,
    required this.total,
    required this.alignment,
  });

  final int current;
  final int total;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Langkah ${current + 1} dari $total',
      child: Wrap(
        alignment: alignment,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: AppTheme.motion(context, AppTheme.motionFast),
              curve: AppTheme.motionCurve,
              width: i == current ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i < current
                    ? AppColors.teal500
                    : i == current
                        ? AppColors.teal700
                        : AppColors.neutral300,
                borderRadius: const BorderRadius.all(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
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
    return _CenteredScrollBody(
      children: [
        Text(activityTitle, style: AppTextStyles.headingM),
        AppSpacing.gapXS,
        Text(
          'Bagaimana perasaanmu?',
          style: AppTextStyles.displayM,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXXL,
        if (isSaving)
          const CircularProgressIndicator()
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              for (final entry in _moodOptions.entries)
                _MoodButton(
                  emoji: entry.value.$1,
                  label: entry.value.$2,
                  onTap: () => onMoodPicked(entry.key),
                ),
            ],
          ),
      ],
    );
  }
}

/// A mood choice. Ink-splash feedback and a real tap target — this used to be a
/// bare GestureDetector with no press state, so a parent could not tell whether
/// the tap had registered.
class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
                AppSpacing.gapXS,
                Text(label, style: AppTextStyles.headingS),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centres its children, but scrolls instead of overflowing when the screen is
/// too short — which is what happens on a rotated tablet or a landscape phone.
class _CenteredScrollBody extends StatelessWidget {
  const _CenteredScrollBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      );
    });
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

    return _CenteredScrollBody(
      children: [
        // The medal scales in once. Reward needs to feel like an event, but a
        // single settle — no bounce, nothing looping — keeps it calm enough for
        // a child who is sensitive to movement.
        TweenAnimationBuilder<double>(
          key: ValueKey(phrase),
          tween: Tween(begin: 0.82, end: 1),
          duration: AppTheme.motion(context, AppTheme.motionBase),
          curve: AppTheme.motionCurve,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: 156,
            height: 156,
            decoration: BoxDecoration(
              color: isGentle ? AppColors.olive100 : AppColors.teal100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(isGentle ? '💛' : '🎉', style: const TextStyle(fontSize: 68)),
            ),
          ),
        ),
        AppSpacing.gapLG,
        Text(badgeFor(level), style: AppTextStyles.displayL, textAlign: TextAlign.center),
        AppSpacing.gapXXS,
        Text(activityTitle, style: AppTextStyles.caption),
        AppSpacing.gapLG,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            phrase,
            style: AppTextStyles.headingL,
            textAlign: TextAlign.center,
          ),
        ),
        AppSpacing.gapXS,
        TextButton.icon(
          onPressed: onReplay,
          icon: Icon(Icons.volume_up_outlined, size: 18),
          label: Text('Dengarkan lagi'),
        ),
        AppSpacing.gapXL,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: onNext,
              child: Text(isLast ? 'Selesaikan rutinitas' : 'Aktivitas berikutnya'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AllDone extends StatelessWidget {
  const _AllDone({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _CenteredScrollBody(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.successTint,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: AppColors.success, size: 48),
        ),
        AppSpacing.gapLG,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            message,
            style: AppTextStyles.headingL,
            textAlign: TextAlign.center,
          ),
        ),
        AppSpacing.gapXL,
        FilledButton(
          onPressed: onClose,
          child: Text('Tutup'),
        ),
      ],
    );
  }
}

class _WaitingCountdown extends StatelessWidget {
  const _WaitingCountdown({
    required this.waitMinutes,
    required this.remaining,
    required this.activity,
    required this.onSkip,
  });

  final int waitMinutes;
  final Duration remaining;
  final Activity? activity;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (waitMinutes * 60).clamp(1, 3600);
    final progress = remaining.inSeconds / totalSeconds;
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final title = activity?.title ?? 'menunggu';

    return _CenteredScrollBody(
      children: [
        Text(title, style: AppTextStyles.displayL, textAlign: TextAlign.center),
        AppSpacing.gapSM,
        if (activity != null) ...[
          ActivityImage(activity!.icon),
          AppSpacing.gapSM,
        ],
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 24,
                backgroundColor: AppColors.neutral200,
                color: AppColors.teal500,
              ),
              Center(
                child: Text(
                  '$minutes:$seconds',
                  style: AppTextStyles.displayL.copyWith(fontSize: 48),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapXXL,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSkip,
            icon: const Icon(Icons.skip_next_outlined),
            label: const Text('Lewati'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingChoice extends StatelessWidget {
  const _WaitingChoice({
    required this.activities,
    required this.onPick,
  });

  final List<Activity> activities;
  final ValueChanged<Activity> onPick;

  @override
  Widget build(BuildContext context) {
    return _CenteredScrollBody(
      children: [
        const Text(
          'Waktu menunggu habis!',
          style: AppTextStyles.displayL,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapSM,
        const Text(
          'Sekarang kamu mau melakukan apa?',
          style: AppTextStyles.bodyM,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapLG,
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.teal500,
                  ),
                  onPressed: () => onPick(activity),
                  icon: SizedBox(
                    width: 32,
                    height: 32,
                    child: ActivityImage(activity.icon),
                  ),
                  label: Text(activity.title),
                ),
              ),
            )),
      ],
    );
  }
}

class _EmotionChoice extends StatelessWidget {
  const _EmotionChoice({
    required this.title,
    required this.activities,
    required this.onPick,
  });

  final String title;
  final List<Activity> activities;
  final ValueChanged<Activity> onPick;

  @override
  Widget build(BuildContext context) {
    return _CenteredScrollBody(
      children: [
        Text(title, style: AppTextStyles.displayL, textAlign: TextAlign.center),
        AppSpacing.gapSM,
        const Text(
          'Apa yang bisa membantumu merasa lebih baik?',
          style: AppTextStyles.bodyM,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapLG,
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.teal500,
                  ),
                  onPressed: () => onPick(activity),
                  icon: SizedBox(
                    width: 32,
                    height: 32,
                    child: ActivityImage(activity.icon),
                  ),
                  label: Text(activity.title),
                ),
              ),
            )),
      ],
    );
  }
}

class _EmotionConfirm extends StatelessWidget {
  const _EmotionConfirm({
    required this.activity,
    required this.onConfirm,
  });

  final Activity activity;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _CenteredScrollBody(
      children: [
        const Text(
          'Ketika aku merasa',
          style: AppTextStyles.displayL,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXL,
        ActivityImage(activity.icon),
        AppSpacing.gapSM,
        Text(
          activity.title,
          style: AppTextStyles.headingL,
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXXL,
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed: onConfirm,
            child: const Text('Lanjut'),
          ),
        ),
      ],
    );
  }
}

import '../../models/behaviour_log.dart';
import '../../models/enums.dart';

/// Statistics behind the SproutTrack charts. Kept separate from the widgets and
/// free of Flutter so every figure a parent or therapist reads is testable.

/// Moods that read as settled, and moods that read as distressed. `neutral` sits
/// between them and belongs to neither.
const _settledMoods = {Mood.happy, Mood.calm};
const _distressedMoods = {Mood.anxious, Mood.upset, Mood.meltdown};

/// A day and whether the child completed anything on it.
typedef DayCount = ({DateTime day, int completed});

/// Per-activity progress — the daily-living-skill view the proposal is actually
/// about. Answers "which skills are sticking", which nothing in the app showed
/// before even though the data was already being collected.
typedef ActivityMastery = ({String title, int done, int total, double rate});

/// Three-way split of an ordered scale, for a diverging bar.
typedef PolaritySplit = ({int settled, int neutral, int distressed});

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Share of logged activities that were completed, 0..1. Zero when nothing is
/// logged, so callers never divide by zero.
double completionRate(List<BehaviourLog> logs) {
  if (logs.isEmpty) return 0;
  return logs.where((l) => l.completed).length / logs.length;
}

/// Days in the window on which at least one activity was completed.
///
/// This is "konsistensi pelaksanaan rutinitas" from the proposal's evaluation
/// plan: doing a little every day matters more than doing a lot once.
int activeDays(List<BehaviourLog> logs) {
  return logs
      .where((l) => l.completed)
      .map((l) => startOfDay(l.timestamp))
      .toSet()
      .length;
}

/// Consecutive days up to today with at least one completed activity.
///
/// Counts back from today, and tolerates today being empty so the streak does
/// not appear broken first thing in the morning.
int currentStreak(List<BehaviourLog> logs, DateTime now) {
  final done = logs
      .where((l) => l.completed)
      .map((l) => startOfDay(l.timestamp))
      .toSet();
  if (done.isEmpty) return 0;

  final today = startOfDay(now);
  // Anchor on today if it has activity, otherwise on yesterday — mid-morning
  // should not read as "streak lost".
  var cursor = done.contains(today) ? today : today.subtract(const Duration(days: 1));
  if (!done.contains(cursor)) return 0;

  var streak = 0;
  while (done.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Completed activities per day for the [span] days ending today, oldest first.
List<DayCount> dailyCompletions(List<BehaviourLog> logs, DateTime now, int span) {
  final today = startOfDay(now);
  return [
    for (var i = span - 1; i >= 0; i--)
      () {
        final day = today.subtract(Duration(days: i));
        return (
          day: day,
          completed: logs.where((l) => l.completed && sameDay(l.timestamp, day)).length,
        );
      }(),
  ];
}

/// Per-activity completion, best first.
///
/// [titles] maps activity id to a readable name; ids with no match are dropped
/// rather than shown as "Aktivitas", because an unnamed row teaches nothing.
/// Activities attempted fewer than [minAttempts] times are also dropped — one
/// attempt is not a mastery signal, and a 0% or 100% bar off a single try
/// misleads.
List<ActivityMastery> activityMastery(
  List<BehaviourLog> logs,
  Map<String, String> titles, {
  int minAttempts = 2,
}) {
  final byTitle = <String, ({int done, int total})>{};

  for (final log in logs) {
    final title = titles[log.activityId];
    if (title == null) continue;
    final current = byTitle[title] ?? (done: 0, total: 0);
    byTitle[title] = (
      done: current.done + (log.completed ? 1 : 0),
      total: current.total + 1,
    );
  }

  final rows = <ActivityMastery>[
    for (final entry in byTitle.entries)
      if (entry.value.total >= minAttempts)
        (
          title: entry.key,
          done: entry.value.done,
          total: entry.value.total,
          rate: entry.value.done / entry.value.total,
        ),
  ];

  // Best first, then by attempts so a well-practised skill outranks a lucky one.
  rows.sort((a, b) {
    final byRate = b.rate.compareTo(a.rate);
    return byRate != 0 ? byRate : b.total.compareTo(a.total);
  });
  return rows;
}

/// Mood split for the diverging bar: settled ← neutral → distressed.
PolaritySplit moodPolarity(List<BehaviourLog> logs) {
  var settled = 0, neutral = 0, distressed = 0;
  for (final log in logs) {
    if (_settledMoods.contains(log.mood)) {
      settled++;
    } else if (_distressedMoods.contains(log.mood)) {
      distressed++;
    } else {
      neutral++;
    }
  }
  return (settled: settled, neutral: neutral, distressed: distressed);
}

/// Transition difficulty split — easy ← medium → hard.
///
/// Transitions between activities are the difficulty the proposal names first,
/// and the app has been recording this since the beginning without ever showing
/// it to anyone.
PolaritySplit transitionSplit(List<BehaviourLog> logs) {
  var easy = 0, medium = 0, hard = 0;
  for (final log in logs) {
    switch (log.transitionDifficulty) {
      case TransitionDifficulty.low:
        easy++;
      case TransitionDifficulty.medium:
        medium++;
      case TransitionDifficulty.high:
        hard++;
    }
  }
  return (settled: easy, neutral: medium, distressed: hard);
}

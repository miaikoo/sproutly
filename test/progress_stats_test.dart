import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/features/sprout_track/progress_stats.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  var seq = 0;

  BehaviourLog log({
    required DateTime at,
    bool completed = true,
    Mood mood = Mood.happy,
    TransitionDifficulty transition = TransitionDifficulty.low,
    String activityId = 'mandi',
  }) {
    seq++;
    return BehaviourLog(
      id: 'log-$seq',
      childId: 'child-1',
      activityId: activityId,
      timestamp: at,
      mood: mood,
      promptType: PromptType.voice,
      rewardId: null,
      transitionDifficulty: transition,
      completed: completed,
      durationMinutes: 15,
    );
  }

  final now = DateTime(2026, 7, 30, 14);
  DateTime daysAgo(int n) => DateTime(2026, 7, 30, 9).subtract(Duration(days: n));

  group('completionRate', () {
    test('is zero with no logs rather than dividing by zero', () {
      expect(completionRate([]), 0);
    });

    test('counts only completed entries', () {
      final rate = completionRate([
        log(at: now),
        log(at: now, completed: false),
        log(at: now),
        log(at: now),
      ]);
      expect(rate, 0.75);
    });
  });

  group('activeDays', () {
    test('counts distinct days, not entries', () {
      // Three activities on one day is one active day.
      expect(
        activeDays([log(at: daysAgo(0)), log(at: daysAgo(0)), log(at: daysAgo(1))]),
        2,
      );
    });

    test('ignores days where nothing was completed', () {
      expect(activeDays([log(at: daysAgo(0), completed: false)]), 0);
    });
  });

  group('currentStreak', () {
    test('counts consecutive days ending today', () {
      final streak = currentStreak(
        [log(at: daysAgo(0)), log(at: daysAgo(1)), log(at: daysAgo(2))],
        now,
      );
      expect(streak, 3);
    });

    test('survives an empty today by anchoring on yesterday', () {
      // Otherwise the streak would read as lost every morning.
      final streak = currentStreak([log(at: daysAgo(1)), log(at: daysAgo(2))], now);
      expect(streak, 2);
    });

    test('breaks on a genuine gap', () {
      final streak = currentStreak([log(at: daysAgo(0)), log(at: daysAgo(3))], now);
      expect(streak, 1);
    });

    test('is zero when the last activity is older than yesterday', () {
      expect(currentStreak([log(at: daysAgo(5))], now), 0);
    });

    test('is zero with no completed activity at all', () {
      expect(currentStreak([log(at: daysAgo(0), completed: false)], now), 0);
    });
  });

  group('dailyCompletions', () {
    test('returns one entry per day, oldest first, including empty days', () {
      final days = dailyCompletions([log(at: daysAgo(0)), log(at: daysAgo(2))], now, 3);

      expect(days, hasLength(3));
      expect(days.map((d) => d.completed), [1, 0, 1]);
      expect(days.first.day.isBefore(days.last.day), isTrue);
    });

    test('ignores incomplete activities', () {
      final days = dailyCompletions([log(at: daysAgo(0), completed: false)], now, 1);
      expect(days.single.completed, 0);
    });
  });

  group('activityMastery', () {
    final titles = {'mandi': 'Mandi', 'makan': 'Makan', 'belajar': 'Belajar'};

    test('groups by activity and sorts best first', () {
      final rows = activityMastery([
        log(at: now, activityId: 'mandi'),
        log(at: now, activityId: 'mandi'),
        log(at: now, activityId: 'makan'),
        log(at: now, activityId: 'makan', completed: false),
      ], titles);

      expect(rows.map((r) => r.title), ['Mandi', 'Makan']);
      expect(rows.first.rate, 1.0);
      expect(rows.last.rate, 0.5);
      expect(rows.last.done, 1);
      expect(rows.last.total, 2);
    });

    test('drops activities attempted only once', () {
      // A single try is not a mastery signal, and a lone 0% bar misleads.
      final rows = activityMastery([log(at: now, activityId: 'mandi')], titles);
      expect(rows, isEmpty);
    });

    test('drops ids with no known title instead of labelling them generically', () {
      final rows = activityMastery([
        log(at: now, activityId: 'sudah-dihapus'),
        log(at: now, activityId: 'sudah-dihapus'),
      ], titles);
      expect(rows, isEmpty);
    });

    test('merges ids that share a title', () {
      // Two boards can hold the same activity under different ids.
      final rows = activityMastery(
        [
          log(at: now, activityId: 'a'),
          log(at: now, activityId: 'b', completed: false),
        ],
        {'a': 'Mandi', 'b': 'Mandi'},
      );

      expect(rows, hasLength(1));
      expect(rows.single.total, 2);
      expect(rows.single.rate, 0.5);
    });

    test('keeps skipped or timed-out attempts visible while leaving them incomplete', () {
      final rows = activityMastery(
        [
          log(at: now, activityId: 'mandi', completed: false),
          log(at: now, activityId: 'mandi', completed: false),
        ],
        {'mandi': 'Mandi'},
      );

      expect(rows, hasLength(1));
      expect(rows.single.total, 2);
      expect(rows.single.done, 0);
      expect(rows.single.rate, 0.0);
    });

    test('breaks a rate tie by attempt count', () {
      final rows = activityMastery(
        [
          log(at: now, activityId: 'a'),
          log(at: now, activityId: 'a'),
          log(at: now, activityId: 'b'),
          log(at: now, activityId: 'b'),
          log(at: now, activityId: 'b'),
        ],
        {'a': 'Mandi', 'b': 'Makan'},
      );

      // Both are 100%, but Makan is better practised.
      expect(rows.map((r) => r.title), ['Makan', 'Mandi']);
    });
  });

  group('moodPolarity', () {
    test('splits settled, neutral and distressed', () {
      final split = moodPolarity([
        log(at: now, mood: Mood.happy),
        log(at: now, mood: Mood.calm),
        log(at: now, mood: Mood.neutral),
        log(at: now, mood: Mood.anxious),
        log(at: now, mood: Mood.upset),
        log(at: now, mood: Mood.meltdown),
      ]);

      expect(split.settled, 2);
      expect(split.neutral, 1);
      expect(split.distressed, 3);
    });

    test('is all zeroes with no logs', () {
      final split = moodPolarity([]);
      expect([split.settled, split.neutral, split.distressed], [0, 0, 0]);
    });
  });

  group('transitionSplit', () {
    test('maps low/medium/high onto the diverging arms', () {
      final split = transitionSplit([
        log(at: now, transition: TransitionDifficulty.low),
        log(at: now, transition: TransitionDifficulty.medium),
        log(at: now, transition: TransitionDifficulty.high),
        log(at: now, transition: TransitionDifficulty.high),
      ]);

      expect(split.settled, 1);
      expect(split.neutral, 1);
      expect(split.distressed, 2);
    });

    test('counts activities that were not completed too', () {
      // A hard transition matters most when the activity was abandoned.
      final split = transitionSplit([
        log(at: now, completed: false, transition: TransitionDifficulty.high),
      ]);
      expect(split.distressed, 1);
    });
  });
}

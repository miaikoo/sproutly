import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/features/sprout_track/pages/report_page.dart';
import 'package:sprout_ly_app/features/sprout_track/widgets/child_progress_panel.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  var seq = 0;

  BehaviourLog logAt(DateTime when, {bool completed = true}) {
    seq++;
    return BehaviourLog(
      id: 'log-$seq',
      childId: 'child-1',
      activityId: 'mandi',
      timestamp: when,
      mood: Mood.happy,
      promptType: PromptType.voice,
      rewardId: null,
      transitionDifficulty: TransitionDifficulty.low,
      completed: completed,
      durationMinutes: 15,
    );
  }

  group('logsInRange', () {
    final now = DateTime(2026, 7, 30, 14);

    test('null days keeps everything', () {
      final logs = [logAt(DateTime(2020, 1, 1)), logAt(now)];

      expect(logsInRange(logs, null, now), hasLength(2));
    });

    test('7 days covers today plus the six days before it', () {
      final logs = [
        logAt(now),
        logAt(DateTime(2026, 7, 24, 23, 59)), // day 7 of the window
        logAt(DateTime(2026, 7, 23, 23, 59)), // one day too old
      ];

      final kept = logsInRange(logs, 7, now);

      expect(kept, hasLength(2));
      expect(kept.any((l) => l.timestamp.day == 23), isFalse);
    });

    test('an early-morning log today is still inside the window', () {
      // Counting back from `now` rather than the start of today would drop this.
      final logs = [logAt(DateTime(2026, 7, 24, 1))];

      expect(logsInRange(logs, 7, now), hasLength(1));
    });

    test('everything outside the range gives an empty list, not an error', () {
      final logs = [logAt(DateTime(2026, 1, 1))];

      expect(logsInRange(logs, 7, now), isEmpty);
    });
  });

  group('groupIntoWeeks', () {
    test('splits logs into calendar weeks, newest week first', () {
      // 30 Jul 2026 is a Thursday; its week starts Mon 27 Jul.
      final logs = [
        logAt(DateTime(2026, 7, 30)),
        logAt(DateTime(2026, 7, 27)),
        logAt(DateTime(2026, 7, 26)), // Sunday — belongs to the previous week
      ];

      final weeks = groupIntoWeeks(logs);

      expect(weeks, hasLength(2));
      expect(weeks.first.logs, hasLength(2));
      expect(weeks.last.logs, hasLength(1));
    });

    test('a Monday and the Sunday before it land in different weeks', () {
      final weeks = groupIntoWeeks([
        logAt(DateTime(2026, 7, 27)), // Monday
        logAt(DateTime(2026, 7, 26)), // Sunday
      ]);

      expect(weeks, hasLength(2));
    });

    test('labels span Monday to Sunday', () {
      final weeks = groupIntoWeeks([logAt(DateTime(2026, 7, 30))]);

      expect(weeks.single.label, '27 Jul – 2 Aug');
    });

    test('no logs gives no periods', () {
      expect(groupIntoWeeks([]), isEmpty);
    });
  });
}

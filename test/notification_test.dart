import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/services/notification_service.dart';
import 'package:sprout_ly_app/models/activity.dart';
import 'package:sprout_ly_app/models/enums.dart';
import 'package:sprout_ly_app/models/schedule.dart';

void main() {
  final now = DateTime(2026, 7, 30, 8);

  Activity at(String id, int hour, {bool completed = false}) => Activity(
        id: id,
        title: 'Aktivitas $id',
        icon: 'assets/images/Mandi.png',
        category: ActivityCategory.selfCare,
        startTime: DateTime(2026, 7, 30, hour),
        endTime: DateTime(2026, 7, 30, hour, 15),
        completed: completed,
      );

  Schedule board(
    List<Activity> activities, {
    BoardType type = BoardType.schedule,
    String id = 'b',
    String title = 'Rutinitas Pagi',
  }) =>
      Schedule(
        id: id,
        childId: 'child-1',
        title: title,
        date: DateTime(2026, 7, 30),
        type: type,
        activities: activities,
      );

  group('notificationId', () {
    test('is stable for the same activity', () {
      expect(notificationId('b-0'), notificationId('b-0'));
    });

    test('differs between activities', () {
      expect(notificationId('b-0'), isNot(notificationId('b-1')));
    });

    test('always fits in a 32-bit signed int', () {
      // Android rejects ids outside this range, and Dart hashCodes can be
      // negative or wider on some platforms.
      for (final id in ['b-0', 'custom-1753800000000', 'aktivitas-panjang-sekali-x']) {
        expect(notificationId(id), greaterThanOrEqualTo(0));
        expect(notificationId(id), lessThanOrEqualTo(0x7FFFFFFF));
      }
    });
  });

  group('remindersFor', () {
    test('schedules future activities of a schedule board', () {
      final reminders = remindersFor(board([at('b-0', 12), at('b-1', 16)]), now);

      expect(reminders, hasLength(2));
      expect(reminders.first.when, DateTime(2026, 7, 30, 12));
      expect(reminders.first.title, 'Aktivitas b-0');
      expect(reminders.first.body, contains('Rutinitas Pagi'));
    });

    test('skips activities already in the past', () {
      // A reminder for 07:00 when it is already 08:00 would fire immediately.
      final reminders = remindersFor(board([at('b-0', 7), at('b-1', 12)]), now);

      expect(reminders.map((r) => r.title), ['Aktivitas b-1']);
    });

    test('skips completed activities', () {
      final reminders = remindersFor(board([at('b-0', 12, completed: true)]), now);

      expect(reminders, isEmpty);
    });

    test('an activity exactly now is not scheduled', () {
      final reminders = remindersFor(board([at('b-0', 8)]), now);

      expect(reminders, isEmpty);
    });

    test('non-schedule boards never get reminders', () {
      // Waiting, first-then and emotion boards have no clock time to fire at.
      for (final type in [BoardType.waiting, BoardType.firstThen, BoardType.emotion]) {
        expect(
          remindersFor(board([at('b-0', 12)], type: type), now),
          isEmpty,
          reason: '$type should not schedule reminders',
        );
      }
    });

    test('results are ordered by time, not by stored order', () {
      final reminders = remindersFor(board([at('b-0', 16), at('b-1', 12)]), now);

      expect(reminders.map((r) => r.when), [
        DateTime(2026, 7, 30, 12),
        DateTime(2026, 7, 30, 16),
      ]);
    });
  });

  group('remindersForAll', () {
    test('merges boards and orders by time across them', () {
      final reminders = remindersForAll([
        board([at('a-0', 18)], id: 'a', title: 'Sore'),
        board([at('b-0', 12)], id: 'b', title: 'Siang'),
      ], now);

      expect(reminders.map((r) => r.body), [
        contains('Siang'),
        contains('Sore'),
      ]);
    });

    test('ignores non-schedule boards while keeping the schedule ones', () {
      final reminders = remindersForAll([
        board([at('e-0', 12)], id: 'e', type: BoardType.emotion),
        board([at('b-0', 14)], id: 'b'),
      ], now);

      expect(reminders, hasLength(1));
      expect(reminders.single.when, DateTime(2026, 7, 30, 14));
    });

    test('no boards means nothing scheduled', () {
      expect(remindersForAll([], now), isEmpty);
    });

    test('ids are unique across boards so one never cancels another', () {
      final reminders = remindersForAll([
        board([at('a-0', 12), at('a-1', 13)], id: 'a'),
        board([at('b-0', 14), at('b-1', 15)], id: 'b'),
      ], now);

      final ids = reminders.map((r) => r.id).toSet();
      expect(ids, hasLength(reminders.length));
    });
  });
}

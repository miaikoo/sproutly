import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/features/sprout_plan/pages/run_board_page.dart';
import 'package:sprout_ly_app/models/activity.dart';
import 'package:sprout_ly_app/models/enums.dart';
import 'package:sprout_ly_app/models/schedule.dart';

void main() {
  Activity at(String id, int hour, {bool completed = false}) => Activity(
        id: id,
        title: id,
        icon: 'assets/images/Mandi.png',
        category: ActivityCategory.selfCare,
        startTime: DateTime(2026, 1, 1, hour),
        endTime: DateTime(2026, 1, 1, hour, 15),
        completed: completed,
      );

  Schedule board(List<Activity> activities, {BoardType type = BoardType.schedule}) => Schedule(
        id: 'b',
        childId: 'child-1',
        title: 'Papan',
        date: DateTime(2026, 1, 1),
        type: type,
        activities: activities,
      );

  group('pendingRunOrder', () {
    test('schedule boards run in clock order, not stored order', () {
      final order = pendingRunOrder(board([at('sore', 16), at('pagi', 7), at('siang', 12)]));

      expect(order, ['pagi', 'siang', 'sore']);
    });

    test('first-then boards keep their stored order', () {
      // "Pertama X, kemudian Y" would be nonsense re-sorted by time.
      final order = pendingRunOrder(
        board([at('kemudian', 16), at('pertama', 7)], type: BoardType.firstThen),
      );

      expect(order, ['kemudian', 'pertama']);
    });

    test('already-completed activities are left out', () {
      final order = pendingRunOrder(board([
        at('pagi', 7, completed: true),
        at('siang', 12),
      ]));

      expect(order, ['siang']);
    });

    test('a fully finished board yields an empty run', () {
      final order = pendingRunOrder(board([at('pagi', 7, completed: true)]));

      expect(order, isEmpty);
    });

    test('an empty board yields an empty run', () {
      expect(pendingRunOrder(board([])), isEmpty);
    });
  });
}

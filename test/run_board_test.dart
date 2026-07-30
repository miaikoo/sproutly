import 'dart:ui' show Size;

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

  group('isWideLayout', () {
    test('tablet landscape goes side-by-side', () {
      expect(isWideLayout(const Size(1280, 800)), isTrue);
      expect(isWideLayout(const Size(1024, 768)), isTrue);
    });

    test('tablet portrait stays stacked even though it is wide in pixels', () {
      // 800dp is past the width threshold, but the screen is still taller than
      // wide — splitting into columns there would waste the height.
      expect(isWideLayout(const Size(800, 1280)), isFalse);
      expect(isWideLayout(const Size(768, 1024)), isFalse);
    });

    test('phone portrait stays stacked', () {
      expect(isWideLayout(const Size(400, 800)), isFalse);
    });

    test('phone landscape is too narrow to split', () {
      expect(isWideLayout(const Size(800, 400)), isTrue);
      expect(isWideLayout(const Size(590, 400)), isFalse);
    });
  });

  group('pictureSide', () {
    test('a tablet gets a bigger picture than a phone', () {
      final phone = pictureSide(const Size(400, 800), wide: false);
      final tablet = pictureSide(const Size(800, 1280), wide: false);

      expect(tablet, greaterThan(phone));
    });

    test('never smaller than the floor or larger than the ceiling', () {
      expect(pictureSide(const Size(200, 400), wide: false), 140.0);
      expect(pictureSide(const Size(2000, 1200), wide: true), 340.0);
    });

    test('the wide layout leaves more room for the instruction text', () {
      // Side-by-side has to share the width with the text, so its picture is
      // never the larger of the two.
      for (final size in [
        const Size(700, 500),
        const Size(1024, 768),
        const Size(1280, 800),
      ]) {
        expect(
          pictureSide(size, wide: true),
          lessThanOrEqualTo(pictureSide(size, wide: false)),
          reason: 'at $size',
        );
      }

      // Below the ceiling the difference is real, not just clamped equality.
      const modest = Size(700, 500);
      expect(pictureSide(modest, wide: true), lessThan(pictureSide(modest, wide: false)));
    });
  });
}

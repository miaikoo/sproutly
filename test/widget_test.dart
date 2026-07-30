import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprout_ly_app/core/services/auth_providers.dart';
import 'package:sprout_ly_app/features/home/pages/home_page.dart';
import 'package:sprout_ly_app/models/activity.dart';
import 'package:sprout_ly_app/models/enums.dart';
import 'package:sprout_ly_app/models/schedule.dart';

void main() {
  testWidgets('HomePage does not render a floating bottom navigation card', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // Signed-out state keeps the page off Firebase: currentChildProvider
        // short-circuits to an empty stream when there is no auth user.
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) {
          return false;
        }

        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) {
          return false;
        }

        final borderRadius = decoration.borderRadius;
        return borderRadius is BorderRadius &&
            borderRadius.topLeft == const Radius.circular(64) &&
            borderRadius.topRight == const Radius.circular(64);
      }),
      findsNothing,
    );
  });

  test('greetingFor follows the time of day', () {
    expect(HomePage.greetingFor(DateTime(2026, 1, 1, 7)), 'Selamat pagi');
    expect(HomePage.greetingFor(DateTime(2026, 1, 1, 12)), 'Selamat siang');
    expect(HomePage.greetingFor(DateTime(2026, 1, 1, 16)), 'Selamat sore');
    expect(HomePage.greetingFor(DateTime(2026, 1, 1, 21)), 'Selamat malam');
  });

  group('nextPendingActivity', () {
    Activity activityAt(String id, int hour, {bool completed = false}) => Activity(
          id: id,
          title: id,
          icon: 'assets/images/Mandi.png',
          category: ActivityCategory.selfCare,
          startTime: DateTime(2026, 1, 1, hour),
          endTime: DateTime(2026, 1, 1, hour, 15),
          completed: completed,
        );

    Schedule scheduleWith(
      String id,
      List<Activity> activities, {
      BoardType type = BoardType.schedule,
    }) =>
        Schedule(
          id: id,
          childId: 'child-1',
          title: 'Papan $id',
          date: DateTime(2026, 1, 1),
          type: type,
          activities: activities,
        );

    test('returns the earliest incomplete activity across every board', () {
      final result = nextPendingActivity([
        scheduleWith('b', [activityAt('sore', 16)]),
        scheduleWith('a', [activityAt('pagi', 7), activityAt('siang', 12)]),
      ]);

      expect(result!.activity.id, 'pagi');
      expect(result.scheduleId, 'a');
      expect(result.scheduleTitle, 'Papan a');
    });

    test('skips completed activities', () {
      final result = nextPendingActivity([
        scheduleWith('a', [activityAt('pagi', 7, completed: true), activityAt('siang', 12)]),
      ]);

      expect(result!.activity.id, 'siang');
    });

    test('returns null when everything is done', () {
      final result = nextPendingActivity([
        scheduleWith('a', [activityAt('pagi', 7, completed: true)]),
      ]);

      expect(result, isNull);
    });

    test('returns null when there are no boards', () {
      expect(nextPendingActivity([]), isNull);
    });

    test('ignores non-schedule boards', () {
      // Emotion/waiting/first-then boards are visual supports, not timed
      // routines, so they must never surface as "sedang dikerjakan".
      for (final type in [BoardType.emotion, BoardType.waiting, BoardType.firstThen]) {
        final result = nextPendingActivity([
          scheduleWith('a', [activityAt('kartu', 7)], type: type),
        ]);
        expect(result, isNull, reason: 'board type $type should be skipped');
      }
    });

    test('picks the schedule board even when other board types sort earlier', () {
      final result = nextPendingActivity([
        scheduleWith('emosi', [activityAt('pagi', 6)], type: BoardType.emotion),
        scheduleWith('jadwal', [activityAt('siang', 12)]),
      ]);

      expect(result!.activity.id, 'siang');
    });
  });
}

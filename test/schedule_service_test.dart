import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/data/activity_catalog.dart';
import 'package:sprout_ly_app/core/services/schedule_service.dart';
import 'package:sprout_ly_app/models/activity.dart';
import 'package:sprout_ly_app/models/enums.dart';
import 'package:sprout_ly_app/models/schedule.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ScheduleService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ScheduleService(firestore);
  });

  Schedule buildSchedule(String id) {
    final now = DateTime(2026, 1, 1, 7);
    return Schedule(
      id: id,
      childId: 'child-1',
      title: 'Rutinitas Pagi',
      date: now,
      activities: [
        Activity(
          id: '$id-0',
          title: 'Sikat Gigi',
          icon: 'assets/images/Sikat Gigi.png',
          category: ActivityCategory.selfCare,
          startTime: now,
          endTime: now.add(const Duration(minutes: 15)),
        ),
        Activity(
          id: '$id-1',
          title: 'Makan',
          icon: 'assets/images/Makan.png',
          category: ActivityCategory.meal,
          startTime: now.add(const Duration(minutes: 30)),
          endTime: now.add(const Duration(minutes: 45)),
        ),
      ],
    );
  }

  test('saveSchedule persists and watchSchedulesForChild returns it', () async {
    final id = service.newScheduleId();
    await service.saveSchedule(buildSchedule(id));

    final schedules = await service.watchSchedulesForChild('child-1').first;
    expect(schedules, hasLength(1));
    expect(schedules.first.title, 'Rutinitas Pagi');
    expect(schedules.first.activities, hasLength(2));
  });

  test('setActivityCompleted flips only the targeted activity', () async {
    final id = service.newScheduleId();
    await service.saveSchedule(buildSchedule(id));

    await service.setActivityCompleted(scheduleId: id, activityId: '$id-0', completed: true);

    final schedule = await service.watchScheduleById(id).first;
    final first = schedule!.activities.firstWhere((a) => a.id == '$id-0');
    final second = schedule.activities.firstWhere((a) => a.id == '$id-1');

    expect(first.completed, isTrue);
    expect(second.completed, isFalse);
  });

  group('createBoard', () {
    test('resolves catalog ids into activities and round-trips through Firestore', () async {
      final start = DateTime(2026, 1, 1, 7);
      await service.createBoard(
        childId: 'child-1',
        title: 'Rutinitas Pagi',
        type: BoardType.schedule,
        picks: [
          (catalogId: 'sikat_gigi', start: start),
          (catalogId: 'makan', start: start.add(const Duration(minutes: 30))),
        ],
      );

      final saved = (await service.watchSchedulesForChild('child-1').first).single;
      expect(saved.type, BoardType.schedule);
      expect(saved.activities.map((a) => a.title), ['Sikat Gigi', 'Makan']);
      expect(saved.activities.first.icon, 'assets/images/Sikat Gigi.png');
      expect(saved.activities.first.category, ActivityCategory.selfCare);
      expect(saved.activities.last.startTime, start.add(const Duration(minutes: 30)));
      expect(saved.waitMinutes, isNull);
    });

    test('keeps waitMinutes on a waiting board', () async {
      await service.createBoard(
        childId: 'child-1',
        title: 'Menunggu',
        type: BoardType.waiting,
        waitMinutes: 10,
        picks: [(catalogId: 'menunggu', start: DateTime(2026, 1, 1, 7))],
      );

      final saved = (await service.watchSchedulesForChild('child-1').first).single;
      expect(saved.type, BoardType.waiting);
      expect(saved.waitMinutes, 10);
    });

    test('preserves card order for emotion boards', () async {
      final now = DateTime(2026, 1, 1, 7);
      await service.createBoard(
        childId: 'child-1',
        title: 'Papan Emosi',
        type: BoardType.emotion,
        picks: [
          (catalogId: 'kesal', start: now),
          (catalogId: 'tenang', start: now.add(const Duration(minutes: 1))),
          (catalogId: 'bermain', start: now.add(const Duration(minutes: 2))),
        ],
      );

      final saved = (await service.watchSchedulesForChild('child-1').first).single;
      expect(saved.type, BoardType.emotion);
      expect(saved.activities.map((a) => a.title), ['Kesal', 'Tenang', 'Bermain']);
    });

    test('resolves a parent-made activity id from customActivities', () async {
      const custom = ActivityCatalogItem(
        id: 'custom-1',
        title: 'Merapikan mainan',
        image: 'assets/images/Bermain.png',
        category: ActivityCategory.other,
      );

      await service.createBoard(
        childId: 'child-1',
        title: 'Sore',
        type: BoardType.schedule,
        customActivities: const [custom],
        picks: [(catalogId: 'custom-1', start: DateTime(2026, 1, 1, 16))],
      );

      final saved = (await service.watchSchedulesForChild('child-1').first).single;
      expect(saved.activities.single.title, 'Merapikan mainan');
      expect(saved.activities.single.category, ActivityCategory.other);
    });

    test('unknown catalog ids fall back to the first item instead of throwing', () async {
      await service.createBoard(
        childId: 'child-1',
        title: 'Papan',
        type: BoardType.schedule,
        picks: [(catalogId: 'tidak-ada', start: DateTime(2026, 1, 1, 7))],
      );

      final saved = (await service.watchSchedulesForChild('child-1').first).single;
      expect(saved.activities, hasLength(1));
    });
  });

  test('a document written without a type reads back as a schedule board', () async {
    // Boards saved before BoardType existed must keep working.
    final legacy = buildSchedule('legacy').toJson()..remove('type');
    await firestore.collection('schedules').doc('legacy').set(legacy);

    final saved = await service.watchScheduleById('legacy').first;
    expect(saved!.type, BoardType.schedule);
  });

  test('deleteSchedule removes the board', () async {
    final id = service.newScheduleId();
    await service.saveSchedule(buildSchedule(id));

    await service.deleteSchedule(id);

    expect(await service.watchSchedulesForChild('child-1').first, isEmpty);
  });
}

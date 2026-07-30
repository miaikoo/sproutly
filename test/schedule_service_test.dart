import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
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
}

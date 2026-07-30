import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/activity.dart';
import '../../models/schedule.dart';
import 'auth_providers.dart';

class ScheduleService {
  ScheduleService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _schedules => _firestore.collection('schedules');

  String newScheduleId() => _schedules.doc().id;

  Stream<List<Schedule>> watchSchedulesForChild(String childId) {
    return _schedules.where('childId', isEqualTo: childId).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => Schedule.fromJson(d.data())).toList(),
        );
  }

  Stream<Schedule?> watchScheduleById(String id) {
    return _schedules.doc(id).snapshots().map(
          (doc) => doc.exists ? Schedule.fromJson(doc.data()!) : null,
        );
  }

  Future<void> saveSchedule(Schedule schedule) {
    return _schedules.doc(schedule.id).set(schedule.toJson());
  }

  /// Marks a single activity within [scheduleId] complete or not, rewriting the
  /// embedded activities array (Firestore has no partial-array-element update).
  Future<void> setActivityCompleted({
    required String scheduleId,
    required String activityId,
    required bool completed,
  }) async {
    final doc = await _schedules.doc(scheduleId).get();
    if (!doc.exists) return;

    final schedule = Schedule.fromJson(doc.data()!);
    final updatedActivities = [
      for (final activity in schedule.activities)
        if (activity.id == activityId)
          Activity(
            id: activity.id,
            title: activity.title,
            icon: activity.icon,
            category: activity.category,
            startTime: activity.startTime,
            endTime: activity.endTime,
            completed: completed,
          )
        else
          activity,
    ];

    await _schedules.doc(scheduleId).update({
      'activities': updatedActivities.map((a) => a.toJson()).toList(),
    });
  }
}

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(ref.watch(firestoreProvider));
});

final schedulesForChildProvider = StreamProvider.family<List<Schedule>, String>((ref, childId) {
  return ref.watch(scheduleServiceProvider).watchSchedulesForChild(childId);
});

final scheduleByIdProvider = StreamProvider.family<Schedule?, String>((ref, id) {
  return ref.watch(scheduleServiceProvider).watchScheduleById(id);
});

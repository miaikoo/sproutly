import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/activity.dart';
import '../../models/enums.dart';
import '../../models/schedule.dart';
import '../data/activity_catalog.dart';
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

  Future<void> deleteSchedule(String id) => _schedules.doc(id).delete();

  /// Builds and persists a board of any [type] from catalog picks. Shared by
  /// every create-board page so activity construction lives in one place.
  ///
  /// [picks] carries a start time per card. Only schedule boards show times;
  /// the other board types pass the board date for every card.
  ///
  /// [customActivities] are the child's own cards, needed so a `custom-*` id
  /// resolves to the parent's activity instead of falling back to a preset.
  Future<Schedule> createBoard({
    required String childId,
    required String title,
    required BoardType type,
    required List<({String catalogId, DateTime start})> picks,
    List<ActivityCatalogItem> customActivities = const [],
    int? waitMinutes,
    List<String> thenActivityIds = const [],
    String? existingId,
  }) async {
    final id = existingId ?? newScheduleId();
    final schedule = Schedule(
      id: id,
      childId: childId,
      title: title,
      date: DateTime.now(),
      type: type,
      waitMinutes: waitMinutes,
      thenActivityIds: thenActivityIds,
      activities: [
        for (var i = 0; i < picks.length; i++)
          () {
            final item = ActivityCatalog.byId(picks[i].catalogId, customActivities);
            return Activity(
              id: '$id-$i',
              title: item.title,
              icon: item.image,
              category: item.category,
              startTime: picks[i].start,
              endTime: picks[i].start.add(const Duration(minutes: 15)),
              steps: item.steps,
            );
          }(),
      ],
    );

    await saveSchedule(schedule);
    return schedule;
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
        if (activity.id == activityId) activity.copyWith(completed: completed) else activity,
    ];

    await _schedules.doc(scheduleId).update({
      'activities': updatedActivities.map((a) => a.toJson()).toList(),
    });
  }
}

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(ref.watch(firestoreProvider));
});

final schedulesForChildProvider = StreamProvider.autoDispose.family<List<Schedule>, String>((ref, childId) {
  if (ref.watch(authStateChangesProvider).valueOrNull == null) return const Stream.empty();
  return ref.watch(scheduleServiceProvider).watchSchedulesForChild(childId);
});

final scheduleByIdProvider = StreamProvider.autoDispose.family<Schedule?, String>((ref, id) {
  if (ref.watch(authStateChangesProvider).valueOrNull == null) return const Stream.empty();
  return ref.watch(scheduleServiceProvider).watchScheduleById(id);
});

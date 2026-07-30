import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/enums.dart';
import '../../models/schedule.dart';
import 'child_service.dart';
import 'schedule_service.dart';

/// One scheduled activity reminder (RF-06, "pengingat").
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
  });

  final int id;
  final String title;
  final String body;
  final DateTime when;

  @override
  String toString() => 'Reminder($id, $title, $when)';

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.when == when;

  @override
  int get hashCode => Object.hash(id, title, body, when);
}

/// Stable notification id for an activity, derived rather than stored so a
/// reminder can be cancelled without any bookkeeping.
///
/// Android notification ids must fit in a 32-bit signed int.
int notificationId(String activityId) => activityId.hashCode & 0x7FFFFFFF;

/// The reminders a board should have scheduled right now.
///
/// Only schedule boards get reminders: waiting, first-then and emotion boards
/// have no clock time to fire at. Activities already done or already past are
/// skipped — a reminder for something finished is just noise.
List<Reminder> remindersFor(Schedule schedule, DateTime now) {
  if (schedule.type != BoardType.schedule) return const [];

  return [
    for (final activity in schedule.activities)
      if (!activity.completed && activity.startTime.isAfter(now))
        Reminder(
          id: notificationId(activity.id),
          title: activity.title,
          body: 'Waktunya ${activity.title} — ${schedule.title}.',
          when: activity.startTime,
        ),
  ]..sort((a, b) => a.when.compareTo(b.when));
}

/// All reminders across a child's boards, nearest first.
List<Reminder> remindersForAll(List<Schedule> schedules, DateTime now) {
  return [
    for (final schedule in schedules) ...remindersFor(schedule, now),
  ]..sort((a, b) => a.when.compareTo(b.when));
}

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _android = AndroidNotificationDetails(
    'sproutly_reminders',
    'Pengingat Aktivitas',
    channelDescription: 'Mengingatkan waktu aktivitas pada papan jadwal anak.',
    importance: Importance.high,
    priority: Priority.high,
  );

  bool _ready = false;

  /// Must run before scheduling. Safe to call more than once.
  Future<void> init() async {
    if (_ready) return;

    tz_data.initializeTimeZones();
    // ponytail: fixed to WIB. A parent in WITA/WIT gets reminders off by an
    // hour or two — add the flutter_timezone package and read the device zone
    // if the app ships outside western Indonesia.
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Android 13+ refuses to post notifications without this.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _ready = true;
  }

  /// Replaces every scheduled reminder with the ones [schedules] imply.
  ///
  /// Cancelling everything first is cheaper than diffing, and means a deleted or
  /// renamed board can never leave a stale reminder behind.
  Future<void> syncAll(List<Schedule> schedules, {DateTime? now}) async {
    await init();
    await _plugin.cancelAll();

    for (final reminder in remindersForAll(schedules, now ?? DateTime.now())) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.when, tz.local),
        notificationDetails: const NotificationDetails(android: _android),
        // Inexact avoids needing SCHEDULE_EXACT_ALARM: a routine reminder does
        // not need to fire on the exact second, and exact alarms are a
        // permission the user would have to grant by hand.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

/// Keeps scheduled reminders in step with the child's boards.
///
/// Watched once from the app shell rather than called from every place a board
/// changes: creating, renaming, deleting a board or completing an activity all
/// push a new value through [schedulesForChildProvider], and this re-syncs.
final reminderSyncProvider = Provider<void>((ref) {
  final child = ref.watch(currentChildProvider).valueOrNull;
  if (child == null) return;

  final schedules = ref.watch(schedulesForChildProvider(child.id)).valueOrNull;
  if (schedules == null) return;

  // Fire-and-forget: reminders are a convenience, and a failure here must never
  // block the UI the parent is trying to use.
  ref.read(notificationServiceProvider).syncAll(schedules).ignore();
});

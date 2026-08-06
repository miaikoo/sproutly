import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/behaviour_log.dart';
import 'auth_providers.dart';

class BehaviourLogService {
  BehaviourLogService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _logs => _firestore.collection('behaviour_logs');

  Future<void> addLog(BehaviourLog log) {
    return _logs.doc(log.id).set(log.toJson());
  }

  String newLogId() => _logs.doc().id;

  Stream<List<BehaviourLog>> watchLogsForChild(String childId) {
    return _logs.where('childId', isEqualTo: childId).snapshots().map(
          (snapshot) => normalizeLogsForAnalytics(
            parseLogsFromFirestore(snapshot.docs.map((d) => d.data()).toList()),
          ),
        );
  }

  static List<BehaviourLog> parseLogsFromFirestore(List<Map<String, dynamic>> rawLogs) {
    final parsed = <BehaviourLog>[];
    for (final raw in rawLogs) {
      try {
        parsed.add(BehaviourLog.fromJson(raw));
      } catch (_) {
        continue;
      }
    }
    return parsed;
  }

  static List<BehaviourLog> normalizeLogsForAnalytics(List<BehaviourLog> logs) {
    final normalized = List<BehaviourLog>.from(logs);
    normalized.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return normalized;
  }
}

final behaviourLogServiceProvider = Provider<BehaviourLogService>((ref) {
  return BehaviourLogService(ref.watch(firestoreProvider));
});

final logsForChildProvider = StreamProvider.autoDispose.family<List<BehaviourLog>, String>((ref, childId) {
  if (ref.watch(authStateChangesProvider).valueOrNull == null) return const Stream.empty();
  return ref.watch(behaviourLogServiceProvider).watchLogsForChild(childId);
});


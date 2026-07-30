import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/child.dart';
import '../../models/enums.dart';
import '../data/activity_catalog.dart';
import 'active_child.dart';
import 'auth_providers.dart';

class ChildService {
  ChildService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _children => _firestore.collection('children');

  /// Every child belonging to [parentId], oldest first so the list order is
  /// stable as profiles are added.
  Stream<List<Child>> watchChildrenForParent(String parentId) {
    return _children.where('parentId', isEqualTo: parentId).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => Child.fromJson(d.data())).toList()
            ..sort((a, b) => a.birthDate.compareTo(b.birthDate)),
        );
  }

  String newChildId() => _children.doc().id;

  /// Adds a sibling profile under the same parent.
  Future<Child> addChild({
    required String parentId,
    required String name,
    required DateTime birthDate,
    required Severity severity,
  }) async {
    final child = Child(
      id: newChildId(),
      parentId: parentId,
      name: name,
      birthDate: birthDate,
      severity: severity,
      photoUrl: '',
    );
    await _children.doc(child.id).set(child.toJson());
    return child;
  }

  Stream<Child?> watchChildById(String childId) {
    return _children.doc(childId).snapshots().map(
          (doc) => doc.exists ? Child.fromJson(doc.data()!) : null,
        );
  }

  Stream<List<Child>> watchChildrenForTherapist(String therapistId) {
    return _children.where('therapistId', isEqualTo: therapistId).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => Child.fromJson(d.data())).toList(),
        );
  }

  /// Looks up a therapist account by email and links them to [childId].
  /// Throws [StateError] if no therapist account uses that email.
  Future<void> linkTherapistByEmail({required String childId, required String email}) async {
    final matches = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'therapist')
        .limit(1)
        .get();

    if (matches.docs.isEmpty) {
      throw StateError('Tidak ditemukan akun terapis dengan email tersebut.');
    }

    final therapistId = matches.docs.first.id;
    await _children.doc(childId).update({'therapistId': therapistId});
  }

  Future<void> unlinkTherapist(String childId) async {
    await _children.doc(childId).update({'therapistId': null});
  }

  /// Updates the editable parts of the child profile (RF-02). Only the fields
  /// passed are written, so a partial edit can't blank out the rest.
  Future<void> updateProfile(
    String childId, {
    String? name,
    DateTime? birthDate,
    Severity? severity,
    String? photoUrl,
    List<String>? preferences,
    List<String>? interventionTargets,
  }) async {
    await _children.doc(childId).update({
      'name': ?name,
      'birthDate': ?birthDate?.toIso8601String(),
      'severity': ?severity?.name,
      'photoUrl': ?photoUrl,
      'preferences': ?preferences,
      'interventionTargets': ?interventionTargets,
    });
  }

  /// Appends a parent-made activity to the child's card library.
  Future<void> addCustomActivity(String childId, ActivityCatalogItem item) async {
    await _children.doc(childId).update({
      'customActivities': FieldValue.arrayUnion([item.toJson()]),
    });
  }

  Future<void> removeCustomActivity(String childId, ActivityCatalogItem item) async {
    await _children.doc(childId).update({
      'customActivities': FieldValue.arrayRemove([item.toJson()]),
    });
  }
}

final childServiceProvider = Provider<ChildService>((ref) {
  return ChildService(ref.watch(firestoreProvider));
});

/// Every child profile under the signed-in parent (or linked to the therapist).
final childrenForParentProvider = StreamProvider<List<Child>>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  if (profile == null) return const Stream.empty();

  if (profile.role == UserRole.therapist) {
    return ref.watch(childServiceProvider).watchChildrenForTherapist(user.uid);
  }
  return ref.watch(childServiceProvider).watchChildrenForParent(user.uid);
});

/// The child every other screen works with.
///
/// A family can have more than one child in the programme, so this resolves the
/// parent's saved choice against the profiles that actually exist — falling back
/// to the first one when nothing is selected or the selection was deleted. Every
/// screen downstream already takes a `childId`, so switching profiles just works.
final currentChildProvider = StreamProvider<Child?>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  final activeId = ref.watch(activeChildIdProvider);

  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  if (profile == null) return const Stream.empty();

  final stream = profile.role == UserRole.therapist
      ? ref.watch(childServiceProvider).watchChildrenForTherapist(user.uid)
      : ref.watch(childServiceProvider).watchChildrenForParent(user.uid);

  return stream.map((children) {
    if (children.isEmpty) return null;
    return children.firstWhere(
      (c) => c.id == activeId,
      orElse: () => children.first,
    );
  });
});

final childByIdProvider = StreamProvider.family<Child?, String>((ref, childId) {
  return ref.watch(childServiceProvider).watchChildById(childId);
});

final childrenForTherapistProvider = StreamProvider<List<Child>>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(childServiceProvider).watchChildrenForTherapist(user.uid);
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/child.dart';
import 'auth_providers.dart';

class ChildService {
  ChildService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _children => _firestore.collection('children');

  Stream<Child?> watchChildForParent(String parentId) {
    return _children.where('parentId', isEqualTo: parentId).limit(1).snapshots().map(
          (snapshot) => snapshot.docs.isEmpty ? null : Child.fromJson(snapshot.docs.first.data()),
        );
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
}

final childServiceProvider = Provider<ChildService>((ref) {
  return ChildService(ref.watch(firestoreProvider));
});

/// The current parent's single child profile (MVP: one child per parent).
final currentChildProvider = StreamProvider<Child?>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(childServiceProvider).watchChildForParent(user.uid);
});

final childByIdProvider = StreamProvider.family<Child?, String>((ref, childId) {
  return ref.watch(childServiceProvider).watchChildById(childId);
});

final childrenForTherapistProvider = StreamProvider<List<Child>>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(childServiceProvider).watchChildrenForTherapist(user.uid);
});

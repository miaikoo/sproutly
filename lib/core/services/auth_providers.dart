import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart' as model;
import 'auth_service.dart';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

final authStateChangesProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// The `users/{uid}` profile document for the signed-in account.
final currentUserProfileProvider = StreamProvider<model.User?>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreProvider).collection('users').doc(user.uid).snapshots().map(
        (doc) => doc.exists ? model.User.fromJson(doc.data()!) : null,
      );
});

final userByIdProvider = StreamProvider.autoDispose.family<model.User?, String>((ref, uid) {
  return ref.watch(firestoreProvider).collection('users').doc(uid).snapshots().map(
        (doc) => doc.exists ? model.User.fromJson(doc.data()!) : null,
      );
});

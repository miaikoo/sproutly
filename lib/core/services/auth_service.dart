import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../models/child.dart';
import '../../models/enums.dart';
import '../../models/user.dart' as model;

/// Thrown when registration/login fails; [message] is safe to show to the user.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  AuthService(this._auth, this._firestore);

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();
  fb.User? get currentUser => _auth.currentUser;

  /// Registers a parent account and creates the parent + child profile documents.
  Future<void> registerParent({
    required String email,
    required String password,
    required String parentName,
    required String childName,
    required DateTime childBirthDate,
    required Severity childSeverity,
  }) async {
    final fb.UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }

    final uid = credential.user!.uid;
    final childRef = _firestore.collection('children').doc();

    final user = model.User(
      id: uid,
      email: email,
      name: parentName,
      role: UserRole.parent,
    );
    final child = Child(
      id: childRef.id,
      parentId: uid,
      name: childName,
      birthDate: childBirthDate,
      severity: childSeverity,
      photoUrl: '',
    );

    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(uid), user.toJson());
    batch.set(childRef, child.toJson());
    await batch.commit();
  }

  /// Registers a therapist account (no child profile attached).
  Future<void> registerTherapist({
    required String email,
    required String password,
    required String name,
  }) async {
    final fb.UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }

    final user = model.User(
      id: credential.user!.uid,
      email: email,
      name: name,
      role: UserRole.therapist,
    );
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Signs out, then tries to reset the Firestore connection if the backend
  /// supports it. Some test doubles and older SDK wrappers do not expose the
  /// network toggle methods, so we treat that as optional rather than failing.
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _firestore.disableNetwork();
      await _firestore.enableNetwork();
    } on NoSuchMethodError {
      // Mock/Fake Firestore implementations may not implement these methods.
    } on UnsupportedError {
      // Some platforms or wrappers reject the network toggle API.
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  String _messageFor(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Terjadi kesalahan: ${e.message ?? e.code}';
    }
  }
}

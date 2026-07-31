import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/therapist_note.dart';
import 'auth_providers.dart';

class TherapistNoteService {
  TherapistNoteService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notes => _firestore.collection('therapist_notes');

  Future<void> addNote(TherapistNote note) {
    return _notes.doc(note.id).set(note.toJson());
  }

  String newNoteId() => _notes.doc().id;

  Stream<List<TherapistNote>> watchNotesForChild(String childId) {
    return _notes.where('childId', isEqualTo: childId).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => TherapistNote.fromJson(d.data())).toList()
            ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate)),
        );
  }
}

final therapistNoteServiceProvider = Provider<TherapistNoteService>((ref) {
  return TherapistNoteService(ref.watch(firestoreProvider));
});

final notesForChildProvider = StreamProvider.autoDispose.family<List<TherapistNote>, String>((ref, childId) {
  return ref.watch(therapistNoteServiceProvider).watchNotesForChild(childId);
});

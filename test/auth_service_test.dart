import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/services/auth_service.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    service = AuthService(auth, firestore);
  });

  test('registerParent creates the user and child documents in Firestore', () async {
    await service.registerParent(
      email: 'parent@example.com',
      password: 'secret123',
      parentName: 'Ibu Sari',
      childName: 'Budi',
      childBirthDate: DateTime(2020, 5, 1),
      childSeverity: Severity.moderate,
    );

    final uid = auth.currentUser!.uid;

    final userDoc = await firestore.collection('users').doc(uid).get();
    expect(userDoc.data()!['name'], 'Ibu Sari');
    expect(userDoc.data()!['role'], 'parent');

    final children = await firestore.collection('children').where('parentId', isEqualTo: uid).get();
    expect(children.docs, hasLength(1));
    expect(children.docs.first.data()['name'], 'Budi');
    expect(children.docs.first.data()['severity'], 'moderate');
  });

  test('login signs in an existing user', () async {
    await service.registerParent(
      email: 'parent@example.com',
      password: 'secret123',
      parentName: 'Ibu Sari',
      childName: 'Budi',
      childBirthDate: DateTime(2020, 5, 1),
      childSeverity: Severity.mild,
    );
    await service.logout();
    expect(auth.currentUser, isNull);

    await service.login(email: 'parent@example.com', password: 'secret123');
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.email, 'parent@example.com');
  });

  test('logout clears the current user', () async {
    await service.registerParent(
      email: 'parent2@example.com',
      password: 'secret123',
      parentName: 'Pak Andi',
      childName: 'Wati',
      childBirthDate: DateTime(2019, 1, 1),
      childSeverity: Severity.severe,
    );

    await service.logout();

    expect(auth.currentUser, isNull);
  });
}

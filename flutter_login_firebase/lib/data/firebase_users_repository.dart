import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user.dart';

class FirebaseUsersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(MyUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<MyUser?> getUser(String id) async {
    final snapshot = await _firestore.collection('users').doc(id).get();
    return snapshot.exists ? MyUser.fromMap(snapshot.data()!) : null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user.dart';

class AccountService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<User?> getUser(String email) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return User.fromJson(query.docs.first.data());
    }
    return null;
  }
}

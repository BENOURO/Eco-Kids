import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../domain/models/user.dart';
import '../domain/models/progression.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Lire le profil depuis users
  Future<User?> getUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return User.fromJson(doc.data()!);
  }

  // 🔹 Mettre à jour le profil
  Future<void> updateUser(User updatedUser) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update(updatedUser.toJson());
  }

  // 🔹 Créer progression séparée
  Future<void> createProgression(String uid) async {
    final doc = await _firestore.collection('progression').doc(uid).get();
    if (!doc.exists) {
      await _firestore.collection('progression').doc(uid).set(
        Progression(
          userId: uid,
          scoreTotal: 0,
          quizReussis: 0,
          elementsDecouverts: 0,
          tauxReussite: 0.0,
        ).toJson(),
      );
    }
  }

  // 🔹 Lire progression
  Future<Progression?> getProgression() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('progression').doc(uid).get();
    if (!doc.exists) return null;

    return Progression.fromJson(doc.data()!);
  }

  // 🔹 Mettre à jour progression
  Future<void> updateProgression(Progression progression) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('progression').doc(uid).update(progression.toJson());
  }

  // 🔹 Update après quiz
  Future<Progression?> updateProgressionAfterQuiz(bool quizSuccess, int scoreEarned) async {
    final current = await getProgression();
    if (current == null) return null;

    final newQuizReussis = current.quizReussis + (quizSuccess ? 1 : 0);
    final newScoreTotal = current.scoreTotal + scoreEarned;
    final newTaux = newQuizReussis / (current.quizReussis + 1) * 100;

    final updated = Progression(
      userId: current.userId,
      scoreTotal: newScoreTotal,
      quizReussis: newQuizReussis,
      elementsDecouverts: current.elementsDecouverts,
      tauxReussite: double.parse(newTaux.toStringAsFixed(2)),
    );

    await updateProgression(updated);
    return updated;
  }

  // 🔹 Incrément découverte
  Future<Progression?> incrementDiscoveredElements() async {
    final current = await getProgression();
    if (current == null) return null;

    final updated = Progression(
      userId: current.userId,
      scoreTotal: current.scoreTotal,
      quizReussis: current.quizReussis,
      elementsDecouverts: current.elementsDecouverts + 1,
      tauxReussite: current.tauxReussite,
    );

    await updateProgression(updated);
    return updated;
  }
}


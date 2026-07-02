import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/question.dart';

class QuestionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initializeDefaultQuestions() async {
    final ref = _db.collection("questions");

    final existing = await ref.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    int idCounter = 1;

    // -------------------------
    // (all your questions here)
    // -------------------------

    await batch.commit();
  }

  /// Get all questions
  Future<List<Question>> getAllQuestions() async {
    final snapshot = await _db.collection("questions").get();

    if (snapshot.docs.isEmpty) {
      await initializeDefaultQuestions();
      return getAllQuestions();
    }

    return snapshot.docs
        .map((doc) => Question.fromJson(doc.data()))
        .toList();
  }

  /// Filter category
  Future<List<Question>> getQuestionsByCategory(String cat) async {
    final snapshot = await _db
        .collection("questions")
        .where("categoryId", isEqualTo: cat)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson(doc.data()))
        .toList();
  }

  /// Filter subcategory
  Future<List<Question>> getQuestionsBySubcategory(String sub) async {
    final snapshot = await _db
        .collection("questions")
        .where("subcategoryId", isEqualTo: sub)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromJson(doc.data()))
        .toList();
  }

  /// 🔥 Get single question by ID (missing before!)
  Future<Question?> getQuestionById(String id) async {
    final doc = await _db.collection("questions").doc(id).get();
    if (!doc.exists) return null;
    return Question.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Random questions
  Future<List<Question>> getRandomQuestions({
    int count = 10,
    String? categoryId,
    String? subcategoryId,
  }) async {
    Query query = _db.collection("questions");

    if (categoryId != null) {
      query = query.where("categoryId", isEqualTo: categoryId);
    }
    if (subcategoryId != null) {
      query = query.where("subcategoryId", isEqualTo: subcategoryId);
    }

    final snap = await query.get();

    final questions = snap.docs
        .map((d) => Question.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    questions.shuffle(Random());
    return questions.take(count).toList();
  }
}

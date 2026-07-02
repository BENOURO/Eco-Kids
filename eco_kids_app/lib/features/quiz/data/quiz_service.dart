// lib/data/quiz_service.dart

import 'dart:math';

import '../domain/models/quiz.dart';
import '../domain/models/quiz_result.dart';
import '../domain/models/question.dart';
import '../../account/data/profile_service.dart';
import 'question_service.dart';

class QuizService {
  // Singleton
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final List<Quiz> _quizzes = [];
  final List<QuizResult> _results = [];
  final Random _random = Random();
  final QuestionService _questionService = QuestionService();

  /// Crée un quiz général (questions aléatoires)
  Future<Quiz> createGeneralQuiz({int questionCount = 10}) async {
    await _questionService.initializeDefaultQuestions();

    // ❗ FIX : removed snapshot:null
    final questions = await _questionService.getRandomQuestions(
      count: questionCount,
    );

    final seen = <String>{};
    final ids = <String>[];

    for (final q in questions) {
      if (!seen.contains(q.id)) {
        seen.add(q.id);
        ids.add(q.id);
      }
    }

    final quizId =
        'quiz_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

    final quiz = Quiz(
      id: quizId,
      type: QuizType.general,
      title: 'Quiz général #${quizId.split('_').last}',
      description: 'Quiz généré automatiquement',
      questionIds: ids,
      categoryId: null,
      subcategoryId: null,
      totalQuestions: ids.length,
      timeLimit: 0,
      createdAt: DateTime.now(),
    );

    _quizzes.add(quiz);
    return quiz;
  }

  /// Quiz personnalisé
  Future<Quiz> createPersonalizedQuiz({
    int questionCount = 10,
    String? categoryId,
    String? subcategoryId,
  }) async {
    await _questionService.initializeDefaultQuestions();

    // ❗ FIX : snapshot removed
    final questions = await _questionService.getRandomQuestions(
      count: questionCount,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
    );

    final seen = <String>{};
    final ids = <String>[];

    for (final q in questions) {
      if (!seen.contains(q.id)) {
        seen.add(q.id);
        ids.add(q.id);
      }
    }

    final quizId =
        'quiz_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';

    final quiz = Quiz(
      id: quizId,
      type: QuizType.personalized,
      title: 'Quiz personnalisé #${quizId.split('_').last}',
      description: 'Quiz personnalisé',
      questionIds: ids,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      totalQuestions: ids.length,
      timeLimit: 0,
      createdAt: DateTime.now(),
    );

    _quizzes.add(quiz);
    return quiz;
  }

  /// Get quiz by id
  Future<Quiz?> getQuizById(String quizId) async {
    try {
      return _quizzes.firstWhere((q) => q.id == quizId);
    } catch (_) {
      return null;
    }
  }

  /// Get all questions of a quiz
  Future<List<Question>> getQuizQuestions(String quizId) async {
    final quiz = await getQuizById(quizId);
    if (quiz == null) return [];

    final List<Question> result = [];

    for (final qid in quiz.questionIds) {
      final q = await _questionService.getQuestionById(qid);
      if (q != null) result.add(q);
    }

    return result;
  }

  /// Submit quiz
  Future<QuizResult> submitQuiz({
    required String quizId,
    required Map<String, String> answers,
    required int timeSpent,
    String? userId,
  }) async {
    final quiz = await getQuizById(quizId);
    if (quiz == null) {
      throw StateError('Quiz not found: $quizId');
    }

    final questions = await getQuizQuestions(quizId);

    double score = 0.0;
    double totalScore = 0.0;
    int correctAnswers = 0;

    final normalizedAnswers = <String, String>{};

    String normalize(String? s) => (s ?? '').trim().toLowerCase();

    for (final q in questions) {
      totalScore += q.points;

      final provided = answers[q.id];
      normalizedAnswers[q.id] = provided ?? '';

      if (normalize(provided) == normalize(q.correctAnswer)) {
        score += q.points;
        correctAnswers++;
      }
    }

    final result = QuizResult(
      id: 'result_${DateTime
          .now()
          .millisecondsSinceEpoch}_${_random.nextInt(10000)}',
      quizId: quiz.id,
      userId: userId ?? 'local_user',
      score: score,
      totalScore: totalScore,
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      answers: normalizedAnswers,
      timeSpent: timeSpent,
      completedAt: DateTime.now(),
    );

// 🔥 Mise à jour de la progression Firestore
    await ProfileService().updateProgressionAfterQuiz(
      result.correctAnswers == result.totalQuestions, // quizSuccess ?
      result.score.toInt(), // scoreEarned
    );

// 🔥 Sauvegarde locale du résultat
    _results.add(result);

// 🔥 Retourne le résultat
    return result;
  }




    Future<List<QuizResult>> getUserQuizHistory(String userId) async {
    final userResults = _results.where((r) => r.userId == userId).toList();
    userResults.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    return userResults;
  }

  Future<List<Quiz>> getAllQuizzes() async => List.unmodifiable(_quizzes);
  Future<List<QuizResult>> getAllResults() async => List.unmodifiable(_results);

  Future<List<QuizResult>> getResultsForQuiz(String quizId) async {
    return _results.where((r) => r.quizId == quizId).toList();
  }

  Future<QuizResult?> getResultById(String resultId) async {
    try {
      return _results.firstWhere((r) => r.id == resultId);
    } catch (_) {
      return null;
    }
  }
}

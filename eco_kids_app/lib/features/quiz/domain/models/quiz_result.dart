// domain/models/quiz_result.dart

/// Modèle pour le résultat d'un quiz
/// Propriétés :
/// - id
/// - quizId
/// - userId
/// - score
/// - totalScore
/// - correctAnswers
/// - totalQuestions
/// - percentage (calculé automatiquement)
/// - answers (Map<String, String>) : questionId -> réponse donnée
/// - timeSpent (en secondes)
/// - completedAt
///
/// Méthodes : toJson(), fromJson(), calculatePercentage()

class QuizResult {
  final String id;
  final String quizId;
  final String userId;
  final double score;
  final double totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final Map<String, String> answers;
  final int timeSpent; // en secondes
  final DateTime? completedAt;

  const QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    this.answers = const {},
    this.timeSpent = 0,
    this.completedAt,
  });

  double calculatePercentage() {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100.0;
  }

  double get percentage => calculatePercentage();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalScore': totalScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'answers': answers,
      'timeSpent': timeSpent,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    // parse answers
    Map<String, String> parsedAnswers = {};
    final rawAnswers = json['answers'];
    if (rawAnswers is Map) {
      rawAnswers.forEach((k, v) {
        if (k != null) {
          parsedAnswers[k.toString()] = v?.toString() ?? '';
        }
      });
    }

    // parse numbers robustly
    double parsedScore = 0.0;
    final s = json['score'];
    if (s is num) parsedScore = s.toDouble();
    else if (s != null) parsedScore = double.tryParse(s.toString()) ?? 0.0;

    double parsedTotalScore = 0.0;
    final ts = json['totalScore'];
    if (ts is num) parsedTotalScore = ts.toDouble();
    else if (ts != null) parsedTotalScore = double.tryParse(ts.toString()) ?? 0.0;

    int parsedCorrect = 0;
    final ca = json['correctAnswers'];
    if (ca is int) parsedCorrect = ca;
    else if (ca is num) parsedCorrect = ca.toInt();
    else if (ca != null) parsedCorrect = int.tryParse(ca.toString()) ?? 0;

    int parsedTotalQ = 0;
    final tq = json['totalQuestions'];
    if (tq is int) parsedTotalQ = tq;
    else if (tq is num) parsedTotalQ = tq.toInt();
    else if (tq != null) parsedTotalQ = int.tryParse(tq.toString()) ?? 0;

    int parsedTime = 0;
    final tp = json['timeSpent'];
    if (tp is int) parsedTime = tp;
    else if (tp is num) parsedTime = tp.toInt();
    else if (tp != null) parsedTime = int.tryParse(tp.toString()) ?? 0;

    DateTime? parsedCompletedAt;
    final caVal = json['completedAt'];
    if (caVal is DateTime) {
      parsedCompletedAt = caVal;
    } else if (caVal is int) {
      // detect milliseconds vs seconds
      if (caVal > 1e12) parsedCompletedAt = DateTime.fromMillisecondsSinceEpoch(caVal);
      else parsedCompletedAt = DateTime.fromMillisecondsSinceEpoch(caVal * 1000);
    } else if (caVal is String) {
      parsedCompletedAt = DateTime.tryParse(caVal);
    }

    return QuizResult(
      id: json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      score: parsedScore,
      totalScore: parsedTotalScore,
      correctAnswers: parsedCorrect,
      totalQuestions: parsedTotalQ,
      answers: parsedAnswers,
      timeSpent: parsedTime,
      completedAt: parsedCompletedAt,
    );
  }

  @override
  String toString() {
    return 'QuizResult(id: $id, quizId: $quizId, userId: $userId, score: $score, totalScore: $totalScore, correct: $correctAnswers/$totalQuestions, percentage: ${percentage.toStringAsFixed(2)}%)';
  }
}


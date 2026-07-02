// domain/models/quiz.dart

/// Modèle pour un Quiz
/// Propriétés :
/// - id
/// - type : enum (general, personalized)
/// - title
/// - description
/// - questionIds (List<String>)
/// - categoryId, subcategoryId (nullable pour quiz général)
/// - totalQuestions
/// - timeLimit (en secondes, 0 = illimité)
/// - createdAt

enum QuizType { general, personalized }

class Quiz {
  final String id;
  final QuizType type;
  final String title;
  final String description;
  final List<String> questionIds;
  final String? categoryId;
  final String? subcategoryId;
  final int totalQuestions;
  final int timeLimit; // en secondes, 0 = illimité
  final DateTime createdAt;

  const Quiz({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.questionIds = const [],
    this.categoryId,
    this.subcategoryId,
    required this.totalQuestions,
    this.timeLimit = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'title': title,
      'description': description,
      'questionIds': questionIds,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'totalQuestions': totalQuestions,
      'timeLimit': timeLimit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final rawQuestionIds = json['questionIds'];
    List<String> parsedQuestionIds = const [];
    if (rawQuestionIds is List) {
      try {
        parsedQuestionIds = List<String>.from(rawQuestionIds.map((e) => e?.toString() ?? ''));
      } catch (_) {
        parsedQuestionIds = rawQuestionIds.map((e) => e.toString()).toList();
      }
    }

    final dynamic totalQ = json['totalQuestions'];
    int parsedTotalQuestions;
    if (totalQ is int) {
      parsedTotalQuestions = totalQ;
    } else if (totalQ != null) {
      parsedTotalQuestions = int.tryParse(totalQ.toString()) ?? parsedQuestionIds.length;
    } else {
      parsedTotalQuestions = parsedQuestionIds.length;
    }

    final dynamic timeVal = json['timeLimit'];
    int parsedTimeLimit = 0;
    if (timeVal is int) {
      parsedTimeLimit = timeVal;
    } else if (timeVal != null) {
      parsedTimeLimit = int.tryParse(timeVal.toString()) ?? 0;
    }

    DateTime parsedCreatedAt;
    final createdAtVal = json['createdAt'];
    if (createdAtVal is DateTime) {
      parsedCreatedAt = createdAtVal;
    } else if (createdAtVal is int) {
      // timestamp in milliseconds or seconds? try to detect
      if (createdAtVal > 1e12) {
        parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(createdAtVal);
      } else {
        parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(createdAtVal * 1000);
      }
    } else if (createdAtVal is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtVal) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Quiz(
      id: json['id']?.toString() ?? '',
      type: _typeFromString(json['type']?.toString() ?? 'general'),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      questionIds: parsedQuestionIds,
      categoryId: json['categoryId']?.toString(),
      subcategoryId: json['subcategoryId']?.toString(),
      totalQuestions: parsedTotalQuestions,
      timeLimit: parsedTimeLimit,
      createdAt: parsedCreatedAt,
    );
  }

  static QuizType _typeFromString(String value) {
    switch (value) {
      case 'general':
        return QuizType.general;
      case 'personalized':
        return QuizType.personalized;
      default:
        return QuizType.general;
    }
  }

  static String _typeToString(QuizType type) => type.toString().split('.').last;

  @override
  String toString() {
    return 'Quiz(id: $id, type: ${_typeToString(type)}, title: $title, totalQuestions: $totalQuestions, timeLimit: $timeLimit)';
  }
}

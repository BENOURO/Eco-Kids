// domain/models/question.dart



enum QuestionType { image_choice, text_choice, true_false }

class Question {
  final String id;
  final QuestionType type;
  final String questionText;
  final String? imagePath;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String categoryId;
  final String subcategoryId;
  final int points;

  const Question({
    required this.id,
    required this.type,
    required this.questionText,
    this.imagePath,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    required this.categoryId,
    required this.subcategoryId,
    this.points = 10,
  });

  /// Convertit l'objet en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(type),
      'questionText': questionText,
      'imagePath': imagePath,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'points': points,
    };
  }

  /// Construit une Question depuis un Map (JSON)
  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<String> parsedOptions = const [];
    if (rawOptions is List) {
      try {
        parsedOptions = List<String>.from(rawOptions.map((e) => e?.toString() ?? ''));
      } catch (_) {
        // fallback: map each element to string
        parsedOptions = rawOptions.map((e) => e.toString()).toList();
      }
    }

    final dynamic pointsVal = json['points'];
    int parsedPoints = 10;
    if (pointsVal is int) {
      parsedPoints = pointsVal;
    } else if (pointsVal != null) {
      parsedPoints = int.tryParse(pointsVal.toString()) ?? 10;
    }

    return Question(
      id: json['id']?.toString() ?? '',
      type: _typeFromString(json['type']?.toString() ?? 'text_choice'),
      questionText: json['questionText']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
      options: parsedOptions,
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      subcategoryId: json['subcategoryId']?.toString() ?? '',
      points: parsedPoints,
    );
  }

  static QuestionType _typeFromString(String value) {
    switch (value) {
      case 'image_choice':
        return QuestionType.image_choice;
      case 'text_choice':
        return QuestionType.text_choice;
      case 'true_false':
        return QuestionType.true_false;
      default:
        return QuestionType.text_choice;
    }
  }

  static String _typeToString(QuestionType type) {
    return type.toString().split('.').last;
  }

  @override
  String toString() {
    return 'Question(id: $id, type: ${_typeToString(type)}, questionText: $questionText, points: $points)';
  }
}


class Progression {
  final String userId;
  final int scoreTotal;
  final int quizReussis;
  final int elementsDecouverts;
  final double tauxReussite;

  Progression({
    required this.userId,
    required this.scoreTotal,
    required this.quizReussis,
    required this.elementsDecouverts,
    required this.tauxReussite,
  });

  factory Progression.fromJson(Map<String, dynamic> json) => Progression(
    userId: json['userId'],
    scoreTotal: json['scoreTotal'],
    quizReussis: json['quizReussis'],
    elementsDecouverts: json['elementsDecouverts'],
    tauxReussite: json['tauxReussite'],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'scoreTotal': scoreTotal,
    'quizReussis': quizReussis,
    'elementsDecouverts': elementsDecouverts,
    'tauxReussite': tauxReussite,
  };
}

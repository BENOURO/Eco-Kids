class Discovery {
  final String id;
  final String userId;
  final String elementId;
  final String capturedPhoto;
  final DateTime dateDiscovered;

  Discovery({
    required this.id,
    required this.userId,
    required this.elementId,
    required this.capturedPhoto,
    required this.dateDiscovered,
  });

  factory Discovery.fromJson(Map<String, dynamic> json) => Discovery(
    id: json['id'],
    userId: json['userId'],
    elementId: json['elementId'],
    capturedPhoto: json['capturedPhoto'],
    dateDiscovered: DateTime.parse(json['dateDiscovered']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'elementId': elementId,
    'capturedPhoto': capturedPhoto,
    'dateDiscovered': dateDiscovered.toIso8601String(),
  };
}

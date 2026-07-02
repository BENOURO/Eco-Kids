class Ecosystem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> elementIds; // Liste des id d’éléments naturels (animaux/plantes)

  Ecosystem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.elementIds,
  });

  factory Ecosystem.fromJson(Map<String, dynamic> json) => Ecosystem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    elementIds: List<String>.from(json['elementIds']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'elementIds': elementIds,
  };
}

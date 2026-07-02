// lib/features/discovery/data/models/category.dart
class Category {
  final String id;
  final String name;
  final String description;
  final String imageUrl;


  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,

  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',

    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,

  };
}

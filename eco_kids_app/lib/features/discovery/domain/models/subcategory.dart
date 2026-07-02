class SubCategory {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final String? key; // Peut être null

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    this.key,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour récupérer une valeur String avec fallback
    String getString(String fieldName, [String defaultValue = '']) {
      final value = json[fieldName];
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Pour le champ key, on essaie plusieurs variantes
    String? keyValue;
    if (json.containsKey('key') && json['key'] != null) {
      keyValue = json['key'].toString();
    } else if (json.containsKey('id') && json['id'] != null) {
      // Fallback sur l'id si key n'existe pas
      keyValue = json['id'].toString();
    }

    return SubCategory(
      id: getString('id'),
      name: getString('name', 'Sans nom'),
      categoryId: getString('categoryId', ''),
      description: getString('description', 'Aucune description'),
      key: keyValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'description': description,
    if (key != null) 'key': key,
  };

  // Méthode pour copier avec modifications
  SubCategory copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    String? key,
  }) {
    return SubCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      key: key ?? this.key,
    );
  }

  @override
  String toString() {
    return 'SubCategory(id: $id, name: $name, categoryId: $categoryId, key: $key)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubCategory &&
        other.id == id &&
        other.name == name &&
        other.categoryId == categoryId &&
        other.key == key;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    categoryId.hashCode ^
    (key?.hashCode ?? 0);
  }
}
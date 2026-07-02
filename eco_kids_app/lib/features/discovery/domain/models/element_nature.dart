class ElementNature {
  final String id;
  final String name;
  final String type; // "Animal" or "Plant"
  final String categoryId;
  final String subCategoryId;
  final String description;
  final String imageUrl;
  final String wikipediaSource;

  ElementNature({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.subCategoryId,
    required this.description,
    required this.imageUrl,
    required this.wikipediaSource,
  });

  factory ElementNature.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour récupérer une valeur String avec fallback
    String getString(String key, [String defaultValue = '']) {
      final value = json[key];
      if (value == null) return defaultValue;
      return value.toString();
    }

    return ElementNature(
      id: getString('id'),
      name: getString('name', 'Sans nom'),
      type: getString('type', 'Unknown'),
      categoryId: getString('categoryId', ''),
      subCategoryId: getString('subCategoryId', ''),
      description: getString('description', 'Aucune description disponible'),
      imageUrl: getString('imageUrl', ''),
      wikipediaSource: getString('wikipediaSource', ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'categoryId': categoryId,
    'subCategoryId': subCategoryId,
    'description': description,
    'imageUrl': imageUrl,
    'wikipediaSource': wikipediaSource,
  };

  // Méthode pour copier avec modifications
  ElementNature copyWith({
    String? id,
    String? name,
    String? type,
    String? categoryId,
    String? subCategoryId,
    String? description,
    String? imageUrl,
    String? wikipediaSource,
  }) {
    return ElementNature(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      wikipediaSource: wikipediaSource ?? this.wikipediaSource,
    );
  }

  @override
  String toString() {
    return 'ElementNature(id: $id, name: $name, type: $type, categoryId: $categoryId, subCategoryId: $subCategoryId)';
  }
}
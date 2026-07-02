import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/category.dart';
import '../../domain/models/subcategory.dart';

class FirebaseDiscoveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== ELEMENTS ====================

  /// Récupérer tous les éléments d'un type (Animal ou Plante)
  Future<List<ElementNature>> getElementsByType(String type) async {
    try {
      final snapshot = await _db
          .collection("elements")
          .where("type", isEqualTo: type)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ElementNature.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des éléments: $e');
      rethrow;
    }
  }

  /// Récupérer un élément par son ID
  Future<ElementNature?> getElementById(String id) async {
    try {
      final doc = await _db.collection("elements").doc(id).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ElementNature.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de l\'élément: $e');
      return null;
    }
  }

  /// Récupérer les éléments par catégorie
  Future<List<ElementNature>> getElementsByCategory(String categoryId) async {
    try {
      final snapshot = await _db
          .collection("elements")
          .where("categoryId", isEqualTo: categoryId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ElementNature.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement par catégorie: $e');
      rethrow;
    }
  }

  /// Récupérer les éléments par sous-catégorie
  Future<List<ElementNature>> getElementsBySubCategory(String subCategoryId) async {
    try {
      final snapshot = await _db
          .collection("elements")
          .where("subCategoryId", isEqualTo: subCategoryId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ElementNature.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement par sous-catégorie: $e');
      rethrow;
    }
  }

  /// Rechercher des éléments par nom
  Future<List<ElementNature>> searchElements(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _db.collection("elements").get();

      return snapshot.docs
          .where((doc) {
        final name = (doc.data()['name'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      })
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ElementNature.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      rethrow;
    }
  }

  // ==================== CATEGORIES ====================

  /// Récupérer toutes les catégories
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _db.collection("categories").get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Category.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      rethrow;
    }
  }

  /// Récupérer une catégorie par ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _db.collection("categories").doc(categoryId).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Category.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de la catégorie: $e');
      return null;
    }
  }

  // ==================== SUB-CATEGORIES ====================

  /// Récupérer toutes les sous-catégories
  Future<List<SubCategory>> getSubCategories() async {
    try {
      final snapshot = await _db.collection("subcategorie").get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SubCategory.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des sous-catégories: $e');
      rethrow;
    }
  }

  /// Récupérer les sous-catégories d'une catégorie
  Future<List<SubCategory>> getSubCategoriesByCategory(String categoryId) async {
    try {
      final snapshot = await _db
          .collection("subcategorie")
          .where("categoryId", isEqualTo: categoryId)
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SubCategory.fromJson(data);
      })
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des sous-catégories: $e');
      rethrow;
    }
  }

  /// Récupérer une sous-catégorie par ID
  Future<SubCategory?> getSubCategoryById(String subCategoryId) async {
    try {
      final doc = await _db.collection("subcategorie").doc(subCategoryId).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return SubCategory.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de la sous-catégorie: $e');
      return null;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Récupérer catégorie + sous-catégories + éléments en une fois
  Future<Map<String, dynamic>> getCategoryWithData(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      final subCategories = await getSubCategoriesByCategory(categoryId);
      final elements = await getElementsByCategory(categoryId);

      return {
        'category': category,
        'subcategorie': subCategories,
        'elements': elements,
      };
    } catch (e) {
      print('Erreur lors du chargement des données de la catégorie: $e');
      rethrow;
    }
  }
}
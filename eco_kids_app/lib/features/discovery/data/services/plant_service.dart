import '../services/firebase_discovery_service.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/subcategory.dart';

class PlantService {
  final FirebaseDiscoveryService _firebaseService = FirebaseDiscoveryService();

  // A. Récupérer toutes les plantes (éléments de type "Plant")
  Future<List<ElementNature>> getAllPlants() async {
    try {
      print('🌱 Chargement des plantes depuis Firebase...');

      // Utiliser la méthode getElementsByType avec le bon type
      final plants = await _firebaseService.getElementsByType('Plant');

      print('✅ ${plants.length} plantes chargées');

      // Debug: afficher les détails des plantes
      for (var plant in plants) {
        print('  - ${plant.name} (${plant.id}) - subCategoryId: "${plant.subCategoryId}"');
      }

      return plants;
    } catch (e) {
      print('❌ Erreur lors du chargement des plantes: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // B. Récupérer les plantes par sous-catégorie
  Future<List<ElementNature>> getPlantsBySubcategory(String subCategoryKey) async {
    try {
      print('🌱 Chargement des plantes pour sous-catégorie: $subCategoryKey');

      final plants = await _firebaseService.getElementsBySubCategory(subCategoryKey);

      print('✅ ${plants.length} plantes trouvées');
      return plants;
    } catch (e) {
      print('❌ Erreur lors du chargement des plantes par sous-catégorie: $e');
      return [];
    }
  }

  // C. Récupérer une plante par ID
  Future<ElementNature?> getPlantById(String id) async {
    try {
      print('🌱 Chargement de la plante: $id');

      final plant = await _firebaseService.getElementById(id);

      if (plant == null) {
        print('⚠️ Plante non trouvée');
        return null;
      }

      // Vérifier que c'est bien une plante
      if (plant.type != 'Plant') {
        print('⚠️ L\'élément n\'est pas une plante (type: ${plant.type})');
        return null;
      }

      print('✅ Plante chargée: ${plant.name}');
      return plant;
    } catch (e) {
      print('❌ Erreur lors du chargement de la plante: $e');
      return null;
    }
  }

  // D. Récupérer les sous-catégories de plantes
  Future<List<SubCategory>> getPlantSubcategories() async {
    try {
      print('🌱 Chargement des sous-catégories de plantes...');

      final allSubcategories = await _firebaseService.getSubCategories();

      print('📋 Toutes les sous-catégories (${allSubcategories.length}):');
      for (var sc in allSubcategories) {
        print('  - ${sc.name} (id: ${sc.id}, categoryId: ${sc.categoryId}, key: ${sc.key})');
      }

      // Filtrer pour ne garder que les sous-catégories de plantes
      // Essayer avec "plantes" et "plants"
      final plantSubcategories = allSubcategories.where((sc) {
        final catId = sc.categoryId.toLowerCase();
        return catId == 'plantes' || catId == 'plants';
      }).toList();

      print('✅ ${plantSubcategories.length} sous-catégories de plantes chargées:');
      for (var sc in plantSubcategories) {
        print('  - ${sc.name} (key: ${sc.key})');
      }

      return plantSubcategories;
    } catch (e) {
      print('❌ Erreur lors du chargement des sous-catégories: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // E. Rechercher des plantes par nom
  Future<List<ElementNature>> searchPlants(String query) async {
    try {
      print('🔍 Recherche de plantes: $query');

      final allResults = await _firebaseService.searchElements(query);

      // Filtrer pour ne garder que les plantes
      final plants = allResults
          .where((element) => element.type == 'Plant')
          .toList();

      print('✅ ${plants.length} plantes trouvées');
      return plants;
    } catch (e) {
      print('❌ Erreur lors de la recherche: $e');
      return [];
    }
  }

  // F. Récupérer toutes les données pour la page de découverte des plantes
  Future<Map<String, dynamic>> getPlantDiscoveryData() async {
    try {
      print('🌱 Chargement des données de découverte des plantes...');

      final plants = await getAllPlants();
      final subcategories = await getPlantSubcategories();

      print('✅ Données chargées: ${plants.length} plantes, ${subcategories.length} sous-catégories');

      // Vérifier la correspondance entre plantes et sous-catégories
      print('🔍 Vérification des correspondances:');
      final plantSubCatIds = plants.map((p) => p.subCategoryId).toSet();
      final subCatKeys = subcategories.map((sc) => sc.key).toSet();

      print('  SubCategoryIds des plantes: $plantSubCatIds');
      print('  Keys des sous-catégories: $subCatKeys');

      return {
        'plants': plants,
        'subcategories': subcategories,
      };
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
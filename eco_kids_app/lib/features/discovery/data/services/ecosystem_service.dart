import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_discovery_service.dart';
import '../../domain/models/ecosystem.dart';
import '../../domain/models/element_nature.dart';

class EcosystemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDiscoveryService _discoveryService = FirebaseDiscoveryService();

  // A. Récupérer tous les écosystèmes
  Future<List<Ecosystem>> getAllEcosystems() async {
    try {
      print('🌍 Chargement des écosystèmes depuis Firebase...');

      final snapshot = await _firestore.collection('ecosystéme').get();

      final ecosystems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Ecosystem.fromJson(data);
      }).toList();

      print('✅ ${ecosystems.length} écosystèmes chargés');
      return ecosystems;
    } catch (e) {
      print('❌ Erreur lors du chargement des écosystèmes: $e');
      return [];
    }
  }

  // B. Récupérer un écosystème par ID
  Future<Ecosystem?> getEcosystemById(String id) async {
    try {
      print('🌍 Chargement de l\'écosystème: $id');

      final doc = await _firestore.collection('ecosystéme').doc(id).get();

      if (!doc.exists) {
        print('⚠️ Écosystème non trouvé');
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      final ecosystem = Ecosystem.fromJson(data);

      print('✅ Écosystème chargé: ${ecosystem.name}');
      return ecosystem;
    } catch (e) {
      print('❌ Erreur lors du chargement de l\'écosystème: $e');
      return null;
    }
  }

  // C. Récupérer tous les éléments (animaux + plantes) d'un écosystème
  Future<List<ElementNature>> getEcosystemElements(String ecosystemId) async {
    try {
      print('🌍 Chargement des éléments pour écosystème: $ecosystemId');

      final ecosystem = await getEcosystemById(ecosystemId);
      if (ecosystem == null || ecosystem.elementIds.isEmpty) {
        print('⚠️ Aucun élément trouvé');
        return [];
      }

      // Récupérer chaque élément via le service de découverte
      final elements = <ElementNature>[];
      for (final elementId in ecosystem.elementIds) {
        final element = await _discoveryService.getElementById(elementId);
        if (element != null) {
          elements.add(element);
        }
      }

      print('✅ ${elements.length} éléments chargés');
      return elements;
    } catch (e) {
      print('❌ Erreur lors du chargement des éléments: $e');
      return [];
    }
  }

  // D. Récupérer uniquement les animaux d'un écosystème
  Future<List<ElementNature>> getEcosystemAnimals(String ecosystemId) async {
    try {
      print('🌍 Chargement des animaux pour écosystème: $ecosystemId');

      final elements = await getEcosystemElements(ecosystemId);
      final animals = elements.where((e) => e.type == 'Animal').toList();

      print('✅ ${animals.length} animaux chargés');
      return animals;
    } catch (e) {
      print('❌ Erreur lors du chargement des animaux: $e');
      return [];
    }
  }

  // E. Récupérer uniquement les plantes d'un écosystème
  Future<List<ElementNature>> getEcosystemPlants(String ecosystemId) async {
    try {
      print('🌍 Chargement des plantes pour écosystème: $ecosystemId');

      final elements = await getEcosystemElements(ecosystemId);
      final plants = elements.where((e) => e.type == 'Plant').toList();

      print('✅ ${plants.length} plantes chargées');
      return plants;
    } catch (e) {
      print('❌ Erreur lors du chargement des plantes: $e');
      return [];
    }
  }

  // F. Ajouter un élément (animal ou plante) à un écosystème
  Future<void> addElementToEcosystem(String ecosystemId, String elementId) async {
    try {
      print('🌍 Ajout de l\'élément $elementId à l\'écosystème $ecosystemId');

      await _firestore.collection('ecosystéme').doc(ecosystemId).update({
        'elementIds': FieldValue.arrayUnion([elementId]),
      });

      print('✅ Élément ajouté');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout: $e');
    }
  }

  // G. Retirer un élément d'un écosystème
  Future<void> removeElementFromEcosystem(String ecosystemId, String elementId) async {
    try {
      print('🌍 Retrait de l\'élément $elementId de l\'écosystème $ecosystemId');

      await _firestore.collection('ecosystéme').doc(ecosystemId).update({
        'elementIds': FieldValue.arrayRemove([elementId]),
      });

      print('✅ Élément retiré');
    } catch (e) {
      print('❌ Erreur lors du retrait: $e');
    }
  }

  // H. Mettre à jour un écosystème
  Future<void> updateEcosystem(Ecosystem ecosystem) async {
    try {
      print('🌍 Mise à jour de l\'écosystème: ${ecosystem.id}');

      await _firestore.collection('ecosystéme').doc(ecosystem.id).update({
        'name': ecosystem.name,
        'description': ecosystem.description,
        'imageUrl': ecosystem.imageUrl,
        'elementIds': ecosystem.elementIds,
      });

      print('✅ Écosystème mis à jour');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour: $e');
    }
  }

  // I. Rechercher des écosystèmes par nom
  Future<List<Ecosystem>> searchEcosystems(String query) async {
    try {
      print('🔍 Recherche d\'écosystèmes: $query');

      final snapshot = await _firestore.collection('ecosystéme').get();

      final ecosystems = snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Ecosystem.fromJson(data);
      })
          .where((ecosystem) =>
          ecosystem.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print('✅ ${ecosystems.length} écosystèmes trouvés');
      return ecosystems;
    } catch (e) {
      print('❌ Erreur lors de la recherche: $e');
      return [];
    }
  }

  // J. Récupérer toutes les données d'un écosystème (écosystème + éléments séparés par type)
  Future<Map<String, dynamic>> getEcosystemWithData(String ecosystemId) async {
    try {
      print('🌍 Chargement complet de l\'écosystème: $ecosystemId');

      final ecosystem = await getEcosystemById(ecosystemId);
      final elements = await getEcosystemElements(ecosystemId);

      final animals = elements.where((e) => e.type == 'Animal').toList();
      final plants = elements.where((e) => e.type == 'Plant').toList();

      return {
        'ecosystem': ecosystem,
        'animals': animals,
        'plants': plants,
        'allElements': elements,
      };
    } catch (e) {
      print('❌ Erreur lors du chargement des données complètes: $e');
      rethrow;
    }
  }

  // K. Compter les éléments d'un écosystème par type
  Future<Map<String, int>> getEcosystemElementsCount(String ecosystemId) async {
    try {
      print('🌍 Comptage des éléments pour écosystème: $ecosystemId');

      final elements = await getEcosystemElements(ecosystemId);

      final animalCount = elements.where((e) => e.type == 'Animal').length;
      final plantCount = elements.where((e) => e.type == 'Plant').length;

      return {
        'animals': animalCount,
        'plants': plantCount,
        'total': elements.length,
      };
    } catch (e) {
      print('❌ Erreur lors du comptage: $e');
      return {'animals': 0, 'plants': 0, 'total': 0};
    }
  }
}
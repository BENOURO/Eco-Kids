import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/subcategory.dart';
import '../../../../core/utils/color_helper.dart';
import 'wikipedia_detail_page.dart';
import '../../presentation/widgets/animal_image.dart';

class AnimalDetailScreen extends StatelessWidget {
  final ElementNature animal;
  final List<SubCategory> subCategories;

  const AnimalDetailScreen({
    Key? key,
    required this.animal,
    required this.subCategories,
  }) : super(key: key);

  String _getSubCategoryName() {
    try {
      // Debug: afficher les valeurs
      print('=== DEBUG SUBCATEGORY ===');
      print('animal.subCategoryId: "${animal.subCategoryId}"');
      print('animal.subCategoryId est null? ${animal.subCategoryId == null}');
      print('animal.subCategoryId est vide? ${animal.subCategoryId.isEmpty}');
      print('subCategories disponibles (${subCategories.length}):');
      for (var sc in subCategories) {
        print('  - id: "${sc.id}", key: "${sc.key}", name: "${sc.name}"');
      }

      if (animal.subCategoryId.isEmpty) {
        print('⚠️ subCategoryId est vide!');
        return "Unknown";
      }

      // Chercher la sous-catégorie en utilisant le champ 'key'
      final sc = subCategories.firstWhere(
            (s) => s.key != null && s.key == animal.subCategoryId,
        orElse: () {
          print('❌ Aucune correspondance trouvée avec key: "${animal.subCategoryId}"');
          // Essayer avec l'id comme fallback
          try {
            final found = subCategories.firstWhere(
                  (s) => s.id == animal.subCategoryId,
            );
            print('✅ Correspondance trouvée avec id: ${found.name}');
            return found;
          } catch (e) {
            print('❌ Aucune correspondance trouvée avec id non plus');
            return SubCategory(
              id: '',
              name: 'Unknown',
              categoryId: '',
              description: '',
              key: animal.subCategoryId,
            );
          }
        },
      );
      print('✅ SubCategory finale: "${sc.name}"');
      return sc.name;
    } catch (e) {
      print('❌ Erreur dans _getSubCategoryName: $e');
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final subCategoryName = _getSubCategoryName();

    final bgColor =
    ColorHelper.getSubcategoryColor(subCategoryName, shade: 300);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.timer, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '0:20',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // IMAGE AVEC HERO
            Expanded(
              flex: 2,
              child: Center(
                child: Hero(
                  tag: animal.id,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: AnimalImage(
                      imageUrl: animal.imageUrl.trim(),
                      size: 160,
                    ),
                  ),
                ),
              ),
            ),

            // INDICATEURS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 0 ? 8 : 6,
                  height: index == 0 ? 8 : 6,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BAS DE PAGE
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER INFO + WIKIPEDIA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WikipediaDetailScreen(animal: animal),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.language,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'W',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // INFOS
                        _buildInfoRow('Name', animal.name),
                        _buildInfoRow('Type', animal.type),
                        _buildInfoRow('Class', animal.subCategoryId),

                        const SizedBox(height: 20),

                        // DESCRIPTION
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          animal.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/subcategory.dart';
import '../../../../core/utils/color_helper.dart';
import 'plant_image.dart';

class PlantCard extends StatelessWidget {
  final ElementNature plant;
  final List<SubCategory> subCategories;
  final VoidCallback onTap;

  PlantCard({
    required this.plant,
    required this.subCategories,
    required this.onTap,
  });

  String _getSubCategoryName() {
    try {
      final subcat = subCategories.firstWhere(
            (sc) => sc.key == plant.subCategoryId,
        orElse: () => SubCategory(
          id: '',
          name: plant.subCategoryId,
          categoryId: '',
          description: '',
          key: plant.subCategoryId,
        ),
      );
      return subcat.name;
    } catch (e) {
      return plant.subCategoryId;
    }
  }

  Color _getPlantColor() {
    final subcatName = _getSubCategoryName();
    // Utiliser ColorHelper avec des couleurs vertes pour les plantes
    return ColorHelper.getSubcategoryColor(subcatName, shade: 400);
  }

  @override
  Widget build(BuildContext context) {
    final plantColor = _getPlantColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: plantColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Hero(
                  tag: plant.id,
                  child: PlantImage(imageUrl: plant.imageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// presentation/widgets/animal/animal_card.dart
import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../../../core/utils/color_helper.dart';
import '../../presentation/widgets/animal_image.dart';
class AnimalCard extends StatelessWidget {
  final ElementNature animal;
  final String subCategoryId;
  final VoidCallback onTap;

  const AnimalCard({
    Key? key,
    required this.animal,
    required this.subCategoryId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: ColorHelper.getSubcategoryColor(subCategoryId),
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
                  tag: animal.id,
                  child: AnimalImage(imageUrl: animal.imageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                animal.name,
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


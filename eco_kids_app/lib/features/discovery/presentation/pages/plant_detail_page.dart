import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/subcategory.dart';
import '../../../../core/utils/color_helper.dart';
import '../widgets/plant_image.dart';
import 'plant_wikepidea_detail.dart';

class PlantDetailPage extends StatefulWidget {
  final ElementNature plant;
  final List<SubCategory> subCategories;

  PlantDetailPage({
    required this.plant,
    required this.subCategories,
  });

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  String _getSubCategoryName() {
    try {
      final subcat = widget.subCategories.firstWhere(
            (sc) => sc.key == widget.plant.subCategoryId,
        orElse: () => SubCategory(
          id: '',
          name: widget.plant.subCategoryId,
          categoryId: '',
          description: '',
          key: widget.plant.subCategoryId,
        ),
      );
      return subcat.name;
    } catch (e) {
      return widget.plant.subCategoryId;
    }
  }

  Color _getPlantColor() {
    final subcatName = _getSubCategoryName();
    return ColorHelper.getSubcategoryColor(subcatName, shade: 400);
  }

  @override
  Widget build(BuildContext context) {
    final plantColor = _getPlantColor();
    final subcatName = _getSubCategoryName();

    return Scaffold(
      backgroundColor: plantColor.withOpacity(0.15),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER avec image
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                children: [
                  // Fond dégradé
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          plantColor,
                          plantColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Bouton retour
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  // Bouton Wikipedia
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlantWikipediaDetailScreen(plant: widget.plant),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(

                        ),
                      ),
                    ),
                  ),
                  // Image ou icône de la plante
                  Center(
                    child: Hero(
                      tag: widget.plant.id,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          height: 180,
                          width: 180,
                          child: PlantImage(
                            imageUrl: widget.plant.imageUrl,
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Indicateurs
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
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
                  ),
                ],
              ),
            ),

            // CONTENU
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête Info + Wikipedia
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
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
                                        PlantWikipediaDetailScreen(
                                            plant: widget.plant),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
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
                        SizedBox(height: 24),

                        // Nom et catégorie
                        Text(
                          widget.plant.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Type', widget.plant.type),
                        _buildInfoRow('Class', subcatName),
                        SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: plantColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: plantColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            widget.plant.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: 24),
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
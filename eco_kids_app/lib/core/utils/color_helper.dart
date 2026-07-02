import 'package:flutter/material.dart';

class ColorHelper {
  // Couleurs pour les animaux
  static Color getSubcategoryColor(String subCategoryName, {int shade = 100}) {
    final name = subCategoryName.toLowerCase().trim();

    // ANIMAUX
    switch (name) {
      case "mammals":
        case "mammal":
      case "mammifères":
      case "mammiferes":
      case "mamifères":
        return _getColorShade(Colors.orange, shade);

      case "fish":
      case "poissons":
      case "poisson":
        return _getColorShade(Colors.yellow, shade);

      case "birds":
      case "oiseaux":
        return _getColorShade(Colors.pink, shade);

      case "reptiles":
        return _getColorShade(Colors.teal, shade);

      case "amphibians":
      case "amphibiens":
        return _getColorShade(Colors.red, shade);

      case "insects":
      case "insectes":
        return _getColorShade(Colors.amber, shade);

    // PLANTES
      case "tree":
      case "trees":
      case "arbre":
      case "arbres":
        return _getColorShade(Colors.lightGreen, shade);

      case "flower":
      case "flowers":
      case "fleur":
      case "fleurs":
        return Colors.pink[shade] ?? Colors.pink[400]!;

      case "herb":
      case "herbs":
      case "herbe":
      case "herbes":
      case "aromatic":
      case "aromatique":
        return _getColorShade(Colors.green, shade);

      case "vegetable":
      case "vegetables":
      case "légume":
      case "légumes":
      case "legume":
      case "legumes":
        return _getColorShade(Colors.deepOrange, shade);

      case "fruit":
      case "fruits":
        return Colors.pink[shade + 200] ?? Colors.pink[600]!;

      case "succulent":
      case "succulents":
      case "succulente":
      case "succulentes":
        return _getColorShade(Colors.teal, shade);

      case "medicinal":
      case "médicinale":
      case "medicinale":
        return _getColorShade(Colors.purple, shade);

      case "aquatic":
      case "aquatique":
        return _getColorShade(Colors.cyan, shade);

      case "cactus":
        return _getColorShade(Colors.lime, shade);

      case "fern":
      case "ferns":
      case "fougère":
      case "fougeres":
        return _getColorShade(Colors.green, shade + 200);

      case "moss":
      case "mousse":
        return _getColorShade(Colors.lightGreen, shade + 100);

      default:
        return _getColorShade(Colors.green, shade);
    }
  }

  static Color _getColorShade(MaterialColor color, int shade) {
    // S'assurer que le shade est valide
    final validShades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    int closestShade = validShades.reduce(
            (a, b) => (a - shade).abs() < (b - shade).abs() ? a : b);
    return color[closestShade] ?? color[400]!;
  }
}
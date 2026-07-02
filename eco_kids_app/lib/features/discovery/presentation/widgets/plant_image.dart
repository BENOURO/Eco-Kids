import 'package:flutter/material.dart';

class PlantImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const PlantImage({
    Key? key,
    required this.imageUrl,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _fallbackIcon();
    }

    // 👉 Si c'est un asset Flutter
    if (imageUrl.startsWith("assets/")) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackIcon();
        },
      );
    }

    // 👉 Sinon, on assume que c'est une URL réseau
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.7),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _fallbackIcon();
      },
    );
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.local_florist,
      size: size,
      color: Colors.white.withOpacity(0.7),
    );
  }
}
import 'package:flutter/material.dart';
import '../../domain/models/ecosystem.dart';

class EcosystemCard extends StatelessWidget {
  final Ecosystem ecosystem;
  final Color color;
  final int animalCount;
  final int plantCount;
  final VoidCallback onTap;

  EcosystemCard({
    required this.ecosystem,
    required this.color,
    required this.animalCount,
    required this.plantCount,
    required this.onTap,
  });

  IconData _getEcosystemIcon() {
    final name = ecosystem.name.toLowerCase();

    if (name.contains('forêt') || name.contains('forest')) {
      return Icons.forest;
    } else if (name.contains('océan') || name.contains('mer') || name.contains('ocean')) {
      return Icons.waves;
    } else if (name.contains('désert') || name.contains('desert')) {
      return Icons.wb_sunny;
    } else if (name.contains('montagne') || name.contains('mountain')) {
      return Icons.terrain;
    } else if (name.contains('savane') || name.contains('savanna')) {
      return Icons.grass;
    } else if (name.contains('jungle') || name.contains('tropical')) {
      return Icons.nature_people;
    } else if (name.contains('arctique') || name.contains('arctic') || name.contains('polaire')) {
      return Icons.ac_unit;
    } else if (name.contains('rivière') || name.contains('river') || name.contains('lac')) {
      return Icons.water;
    }

    return Icons.public;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getEcosystemIcon();
    final totalElements = animalCount + plantCount;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: ecosystem.id,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec image/icône
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Motif de fond
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          icon,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Icône principale
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Compteur d'éléments
                    if (totalElements > 0)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 16,
                                color: color,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$totalElements',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Contenu
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      ecosystem.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Description
                    Text(
                      ecosystem.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Statistiques
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.pets,
                          label: '$animalCount',
                          color: Colors.orange,
                          tooltip: 'Animaux',
                        ),
                        SizedBox(width: 12),
                        _buildStatChip(
                          icon: Icons.local_florist,
                          label: '$plantCount',
                          color: Colors.green,
                          tooltip: 'Plantes',
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
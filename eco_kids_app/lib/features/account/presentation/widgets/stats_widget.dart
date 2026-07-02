import 'package:flutter/material.dart';

class StatWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.65),
            color.withOpacity(0.35),
            color.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.7),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔵 Bubble icon with glow
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.7),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),

            const SizedBox(width: 20),

            // 📝 Texte adaptatif
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Value
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.6),
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // coupe si trop long
                  ),

                  const SizedBox(height: 4),

                  // Label avec emoji
                  Text(
                    "${_emojiForLabel(label)} $label",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // coupe si trop long
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Ajout emojis fun selon le label
  String _emojiForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains("score")) return "⭐";
    if (l.contains("quiz")) return "🧠";
    if (l.contains("niveau")) return "🎮";
    if (l.contains("progression")) return "🚀";
    return "🎉";
  }
}

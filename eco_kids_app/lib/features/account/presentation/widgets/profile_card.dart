import 'package:flutter/material.dart';
import '../../domain/models/user.dart';

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB74D), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage: user.profilePhoto != null
                      ? NetworkImage(user.profilePhoto!)
                      : null,
                  child: user.profilePhoto == null
                      ? const Icon(Icons.person, size: 60, color: Colors.orange)
                      : null,
                ),

                // ⭐ Badge enfantin
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "👦 ${user.name} 👧",
              style: const TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user.email,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                "🌟 Niveau : ${user.level}",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "📅 Depuis le ${user.dateJoined.day}/${user.dateJoined.month}/${user.dateJoined.year}",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

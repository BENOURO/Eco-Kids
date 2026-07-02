import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/profile_service.dart';
import '../../domain/models/progression.dart';
import '../widgets/stats_widget.dart';

class ProgressionPage extends StatefulWidget {
  const ProgressionPage({super.key});

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage> {
  final ProfileService _profileService = ProfileService();
  Progression? progression;
  String? userAvatar;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadProgression();
    _loadUserData();
  }

  Future<void> _loadProgression() async {
    final prog = await _profileService.getProgression();
    setState(() {
      progression = prog;
    });
  }

  // 🔹 Charger les données utilisateur (avatar + nom)
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            userAvatar = doc.data()?['profilePhoto'];
            userName = doc.data()?['name'] ?? user.displayName ?? 'EcoKid';
          });
        }
      } catch (e) {
        print('Erreur lors du chargement des données: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E5),
      appBar: AppBar(
        title: const Text(
          'Ma Progression ⭐',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBA68C8),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: progression == null
          ? Center(
        child: Lottie.asset(
          "assets/animations/loading_kid.json",
          height: 200,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🎨 Avatar avec style décoratif
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle décoratif arrière-plan animé
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFBA68C8).withOpacity(0.3),
                          const Color(0xFFFFD54F).withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Avatar principal
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBA68C8).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: userAvatar != null && userAvatar!.isNotEmpty
                          ? Image.asset(
                        userAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFBA68C8).withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFFBA68C8),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: const Color(0xFFBA68C8).withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFFBA68C8),
                        ),
                      ),
                    ),
                  ),

                  // Badge étoile en haut à droite
                  Positioned(
                    top: 10,
                    right: MediaQuery.of(context).size.width / 2 - 80,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nom de l'utilisateur
            if (userName != null)
              Text(
                userName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                  color: Color(0xFF6A1B9A),
                ),
              ),

            const SizedBox(height: 20),

            // 🟣 Score total
            StatWidget(
              icon: Icons.star,
              label: "Score total",
              value: progression!.scoreTotal.toString(),
              color: Colors.orangeAccent,
            ),

            const SizedBox(height: 16),

            // 🟢 Quiz et niveau
            Row(
              children: [
                Expanded(
                  child: StatWidget(
                    icon: Icons.quiz,
                    label: "Quiz réussis",
                    value: progression!.quizReussis.toString(),
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatWidget(
                    icon: Icons.trending_up,
                    label: "Taux réussite",
                    value: "${progression!.tauxReussite}%",
                    color: const Color(0xFF42A5F5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 💎 Éléments découverts
            StatWidget(
              icon: Icons.lightbulb,
              label: "Éléments découverts",
              value: progression!.elementsDecouverts.toString(),
              color: const Color(0xFFFFD54F),
            ),
          ],
        ),
      ),
    );
  }
}
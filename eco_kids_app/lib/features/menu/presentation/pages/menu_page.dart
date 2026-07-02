import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/activity_cart.dart';
import '../../../../bottom_nav_bar/bottomnavigation_bar.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _currentIndex = 0;

  final user = FirebaseAuth.instance.currentUser;
  String? userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  // 🔹 Charger l'avatar de l'utilisateur depuis Firestore
  Future<void> _loadUserAvatar() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            userAvatar = doc.data()?['profilePhoto'];
          });
        }
      } catch (e) {
        print('Erreur lors du chargement de l\'avatar: $e');
      }
    }
  }

  // 🧩 Liste d'activités à afficher dans le menu principal
  final activities = [
    {
      'title': 'Animaux',
      'image': 'assets/activities/elephant.png',
      'color': const Color(0xFFF4D6CC),
    },
    {
      'title': 'Plantes',
      'image': 'assets/activities/tree.png',
      'color': const Color(0xFFD8F8D8),
    },
    {
      'title': 'Ecosystèmes',
      'image': 'assets/activities/ecosystem.png',
      'color': const Color(0xFFE8F3FF),
    },
    {
      'title': 'Quiz',
      'image': 'assets/activities/quiz.png',
      'color': const Color(0xFFFFF4CC),
    },
    {
      'title': 'Reconnaissance',
      'image': 'assets/activities/reconnaisance.png',
      'color': const Color(0xFFF3E8FF),
    },
  ];

  // 🧭 Gère le changement d'onglet
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // déjà sur Menu
        break;
      case 1:
        Navigator.pushNamed(context, '/quiz');
        break;
      case 2:
        Navigator.pushNamed(context, '/recognition');
        break;
      case 3:
        Navigator.pushNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final childName = user?.displayName ?? "EcoKid 🌱";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Texte d'accueil
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bonjour 👋 $childName",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Découvre le monde d'EcoKids 🌎",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  // Avatar cliquable pour aller sur la page Profil
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profil');
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green.shade100,
                      child: userAvatar != null && userAvatar!.isNotEmpty
                          ? ClipOval(
                        child: Image.asset(
                          userAvatar!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.green,
                            );
                          },
                        ),
                      )
                          : const Icon(Icons.person, color: Colors.green),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===== Barre de recherche et progression =====
              Row(
                children: [
                  // Barre de recherche
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Rechercher une activité...",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bouton Progression
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/progression');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===== Grille d'activités =====
              Expanded(
                child: GridView.builder(
                  itemCount: activities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = activities[index];
                    return ActivityCard(
                      title: item['title'] as String,
                      imagePath: item['image'] as String,
                      backgroundColor: item['color'] as Color,
                      onTap: () {
                        if (item['title'] == 'Animaux') {
                          Navigator.pushNamed(context, '/animals');
                        }
                        if (item['title'] == 'Plantes') {
                          Navigator.pushNamed(context, '/plants');
                        }
                        if (item['title'] == 'Ecosystèmes') {
                          Navigator.pushNamed(context, '/ecosystems');
                        }
                        if (item['title'] == 'Quiz') {
                          Navigator.pushNamed(context, '/quiz');
                        } else if (item['title'] == 'Reconnaissance') {
                          Navigator.pushNamed(context, '/recognition');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== Bottom Navigation Bar =====
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
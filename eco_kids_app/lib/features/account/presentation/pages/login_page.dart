import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // 🎯 Zoom très léger pour un effet subtil
    _animation = Tween<double>(begin: 1.0, end: 1.008).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFB9E937), // vert clair du fond
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🐯 IMAGE EN HAUT (collée sans marge)
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: double.infinity,
                  height: size.height * 0.30,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/chat.jpg'),
                      fit: BoxFit.cover, // garde l’image pleine largeur
                      alignment: Alignment.centerRight, // 🎯 décale un peu vers la droite
                    ),
                  ),
                ),

                // 🔠 Titre animé mais stable
                Positioned(
                  bottom: 40,
                  left: 25,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Text(
                      "Se connecter",
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFD9727), // orange du tigre
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🧩 Bloc formulaire
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(25),
                child: const LoginForm(),
              ),
            ),

            // 🌿 Message d’accueil
            Text(
              "Bienvenue sur EcoKids ! 🌱",
              style: GoogleFonts.fredoka(
                color: const Color(0xFF3B7A00),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

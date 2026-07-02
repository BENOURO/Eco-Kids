import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHoverLogin = false;
  bool _isHoverSignup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // === Image de fond ===
          Positioned.fill(
            child: Image.asset(
              'assets/images/animals2.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // === Contenu principal ===
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),

                  // === Logo / Titre ===
                  Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.fredoka(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: const [
                            TextSpan(text: 'E', style: TextStyle(color: Color(0xFFFFB300))),
                            TextSpan(text: 'c', style: TextStyle(color: Color(0xFF42A5F5))),
                            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFF7043))),
                            TextSpan(text: 'K', style: TextStyle(color: Color(0xFFAB47BC))),
                            TextSpan(text: 'i', style: TextStyle(color: Color(0xFF26C6DA))),
                            TextSpan(text: 'd', style: TextStyle(color: Color(0xFFFFCA28))),
                            TextSpan(text: 's', style: TextStyle(color: Color(0xFF66BB6A))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Apprendre en s’amusant 🌈',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // === Boutons animés ===
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Bouton Se connecter ---
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHoverLogin = true),
                        onExit: (_) => setState(() => _isHoverLogin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          transform: _isHoverLogin
                              ? (Matrix4.identity()..scale(1.05))
                              : Matrix4.identity(),
                          curve: Curves.easeOut,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHoverLogin
                                  ? const Color(0xFF66CCFF) // plus clair au survol
                                  : const Color(0xD966CCFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: _isHoverLogin ? 10 : 6,
                              shadowColor: Colors.blueAccent.withOpacity(0.4),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'Se connecter',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- Bouton S'inscrire ---
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHoverSignup = true),
                        onExit: (_) => setState(() => _isHoverSignup = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          transform: _isHoverSignup
                              ? (Matrix4.identity()..scale(1.05))
                              : Matrix4.identity(),
                          curve: Curves.easeOut,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHoverSignup
                                  ? const Color(0xFFFFE082) // plus clair au survol
                                  : const Color(0xD9FFD180),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: _isHoverSignup ? 10 : 6,
                              shadowColor: Colors.orangeAccent.withOpacity(0.4),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              "S'inscrire",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

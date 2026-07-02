import 'package:ecokids/features/account/presentation/pages/login_page.dart';
import 'package:ecokids/features/account/presentation/pages/signup_page.dart';
import 'package:ecokids/features/discovery/presentation/pages/ecosystems_page.dart';
import 'package:ecokids/features/discovery/presentation/pages/plants_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/account/presentation/pages/profile_page.dart';
import 'features/account/presentation/pages/progression_page.dart';
import 'features/discovery/presentation/pages/discovery_page.dart';
import 'features/quiz/presentation/pages/quiz_home_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 🔥 Obligatoire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 🔥 Firebase init
  );
  runApp(const EcoKidsApp());
}

class EcoKidsApp extends StatelessWidget {
  const EcoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoKids',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFFC107), // Jaune joyeux
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          primary: const Color(0xFFFFC107),
          secondary: const Color(0xFF42A5F5), // Bleu clair
          tertiary: const Color(0xFFFF7043), // Orange doux
          background: const Color(0xFFFFF8E1),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(), // à remplacer
        '/signup': (context) => const SignupPage(),
        '/profil':(context)=>const ProfilePage(),
        '/progression':(context)=>const ProgressionPage(),
        '/animals': (_) => const DiscoveryScreen(),
        '/plants': (context) => PlantsPage(),
        '/ecosystems': (context) => EcosystemsPage(),
        '/quiz': (context) => const QuizHomePage(),
      },
    );
  }
}

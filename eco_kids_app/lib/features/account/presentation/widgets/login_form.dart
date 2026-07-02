import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../../../menu/presentation/pages/menu_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF9AD14B)),
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D32),
        fontSize: 16,
      ),
      filled: true,
      fillColor: const Color(0xFFE9FBE7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = await _authService.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie 🎉")),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainMenuPage(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation =
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(animation);
            final fadeAnimation =
            Tween<double>(begin: 0, end: 1).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou mot de passe incorrect ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Bienvenue 🐾",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 35),
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecoration("Email", Icons.email_outlined),
                style: const TextStyle(fontSize: 18),
                validator: (value) =>
                value!.isEmpty ? "Veuillez entrer votre email" : null,
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: _inputDecoration("Mot de passe", Icons.lock_outline),
                style: const TextStyle(fontSize: 18),
                validator: (value) =>
                value!.isEmpty ? "Veuillez entrer votre mot de passe" : null,
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  backgroundColor: const Color(0xFFFFA726),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Se connecter 🐯",
                  style: TextStyle(
                    fontSize: 19,
                    fontFamily: 'Baloo2',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "Pas encore de compte ? S'inscrire",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

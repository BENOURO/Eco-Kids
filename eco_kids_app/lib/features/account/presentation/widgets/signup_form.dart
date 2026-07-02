import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../data/auth_service.dart';
import '../../data/acount_service.dart';
import '../../domain/models/user.dart';
import '../../data/profile_service.dart'; // pour progression

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _selectedLevel = "Débutant";
  String? _profilePhoto;
  int _selectedAvatarIndex = 1; // Avatar sélectionné par défaut

  final _accountService = AccountService();
  final _authService = AuthService();
  final _profileService = ProfileService(); // 🔹 progression

  bool _isLoading = false;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 🔹 Création compte Firebase
    bool success = await _authService.register(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (success) {
      fb.User? firebaseUser = fb.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(_nameCtrl.text.trim());
        await firebaseUser.reload();
        firebaseUser = fb.FirebaseAuth.instance.currentUser;

        final uid = firebaseUser!.uid;

        // 🔹 Création de l'utilisateur local avec l'avatar sélectionné
        final user = User(
          id: uid, // on prend le uid Firebase
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          age: int.tryParse(_ageCtrl.text) ?? 0,
          level: _selectedLevel,
          profilePhoto: 'assets/avatars/avatar$_selectedAvatarIndex.png',
          dateJoined: DateTime.now(),
        );

        await _accountService.createUser(user);

        // 🔹 Création automatique du document progression
        await _profileService.createProgression(uid);
      }

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès 🎉")),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création du compte ❌")),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFBA68C8)),
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Color(0xFF6A1B9A),
      ),
      filled: true,
      fillColor: const Color(0xFFFFF1F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Color(0xFF8E24AA), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: _inputDecoration("Nom complet", Icons.person),
            validator: (value) => value!.isEmpty ? "Veuillez entrer votre nom" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            decoration: _inputDecoration("Email", Icons.email),
            validator: (value) => value!.isEmpty ? "Veuillez entrer votre email" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration("Âge", Icons.cake),
            validator: (value) => value!.isEmpty ? "Veuillez entrer votre âge" : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedLevel,
            decoration: _inputDecoration("Niveau", Icons.school),
            items: const [
              DropdownMenuItem(value: "Débutant", child: Text("Débutant")),
              DropdownMenuItem(value: "Intermédiaire", child: Text("Intermédiaire")),
              DropdownMenuItem(value: "Avancé", child: Text("Avancé")),
            ],
            onChanged: (val) => setState(() => _selectedLevel = val!),
          ),
          const SizedBox(height: 20),

          // 🔹 Section de sélection d'avatar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const Text(
                  "Choisir un avatar 🎨",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A1B9A),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final avatarIndex = index + 1;
                      final isSelected = _selectedAvatarIndex == avatarIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatarIndex = avatarIndex;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8E24AA)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/avatars/avatar$avatarIndex.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFFBA68C8),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: _inputDecoration("Mot de passe", Icons.lock_rounded),
            validator: (value) => value!.length < 6 ? "Mot de passe trop court" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: _inputDecoration("Confirmer le mot de passe", Icons.lock_outline),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _isLoading ? null : _signup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: const Color(0xFFBA68C8),
              elevation: 6,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "Créer un compte 🦜",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                "Déjà un compte ? Se connecter",
                style: TextStyle(
                  color: Color(0xFF8E24AA),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
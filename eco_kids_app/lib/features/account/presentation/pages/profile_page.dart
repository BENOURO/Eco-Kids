import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../data/profile_service.dart';
import '../../domain/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  User? user;
  bool isEditing = false;
  int selectedAvatarIndex = 1;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedLevel = "Débutant";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await _profileService.getUser();
    setState(() {
      user = currentUser;
      if (user != null) {
        _nameController.text = user!.name;
        _emailController.text = user!.email;
        _ageController.text = user!.age.toString();
        _selectedLevel = user!.level;
        // Extraire l'index de l'avatar
        if (user!.profilePhoto != null) {
          final match = RegExp(r'avatar(\d+)').firstMatch(user!.profilePhoto!);
          if (match != null) {
            selectedAvatarIndex = int.parse(match.group(1)!);
          }
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    if (user == null) return;

    final updatedUser = User(
      id: user!.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: user!.password,
      age: int.tryParse(_ageController.text) ?? user!.age,
      level: _selectedLevel,
      profilePhoto: 'assets/avatars/avatar$selectedAvatarIndex.png',
      dateJoined: user!.dateJoined,
    );

    await _profileService.updateUser(updatedUser);

    // Mettre à jour le displayName dans Firebase Auth
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateDisplayName(_nameController.text.trim());
    }

    setState(() {
      user = updatedUser;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✨ Profil mis à jour avec succès! 🎉',
          style: TextStyle(fontFamily: 'Baloo2', fontSize: 16),
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFBA68C8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E5),
      body: CustomScrollView(
        slivers: [
          // 🎨 Header avec gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFBA68C8),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      _loadUser();
                    });
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                isEditing ? '✏️ Modifier' : '👤 Mon Profil',
                style: const TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBA68C8), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 30,
                      right: -20,
                      child: Icon(
                        Icons.star,
                        size: 100,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -30,
                      child: Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 🎨 Avatar principal avec cercle orange animé
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cercles décoratifs
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade300,
                              Colors.pink.shade300,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 145,
                        height: 145,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      // Avatar
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade300.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/avatars/avatar$selectedAvatarIndex.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.orange.shade100,
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.orange,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Badge étoile
                      Positioned(
                        bottom: 0,
                        right: MediaQuery.of(context).size.width / 2 - 80,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.yellow.shade400, Colors.orange.shade400],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Nom affiché
                  Text(
                    user!.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                      color: Color(0xFF6A1B9A),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🎨 Sélection d'avatars (visible seulement en mode édition)
                  if (isEditing)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade50,
                            Colors.pink.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade200.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎨 Choisir un avatar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Baloo2',
                              color: Color(0xFF8E24AA),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                final avatarIndex = index + 1;
                                final isSelected = selectedAvatarIndex == avatarIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedAvatarIndex = avatarIndex;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.transparent,
                                        width: 4,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
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
                                              size: 30,
                                              color: Colors.orange,
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

                  // 📝 Champs de profil
                  _buildProfileField(
                    label: 'Nom complet',
                    controller: _nameController,
                    enabled: isEditing,
                    icon: Icons.person,
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 16),

                  _buildProfileField(
                    label: 'Email',
                    controller: _emailController,
                    enabled: isEditing,
                    icon: Icons.email,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 16),

                  _buildProfileField(
                    label: 'Âge',
                    controller: _ageController,
                    enabled: isEditing,
                    keyboardType: TextInputType.number,
                    icon: Icons.cake,
                    color: Colors.pink,
                  ),

                  const SizedBox(height: 16),

                  // Niveau (Dropdown en mode édition)
                  _buildLevelField(),

                  const SizedBox(height: 16),

                  // Date d'inscription (non modifiable)
                  _buildProfileField(
                    label: 'Membre depuis',
                    value: '${user!.dateJoined.day}/${user!.dateJoined.month}/${user!.dateJoined.year}',
                    enabled: false,
                    icon: Icons.calendar_today,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 25),

                  // 🎯 Message personnalisé
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.orange.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade300, Colors.orange.shade400],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            "Personnalise ton expérience EcoKids! 🌱",
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Baloo2',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 💾 Bouton Save Changes
                  if (isEditing)
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade500],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade300.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '💾 Enregistrer les modifications',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo2',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 📊 Bouton Voir ma progression
                  if (!isEditing)
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DD0E1).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/progression');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '⭐ Voir ma progression',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo2',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 🚪 Bouton Déconnexion
                  TextButton(
                    onPressed: () {
                      fb.FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      '🚪 Se déconnecter',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.school, color: Colors.green.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Niveau',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
                color: Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade100.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isEditing
              ? DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLevel,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade700),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
              items: const [
                DropdownMenuItem(
                  value: "Débutant",
                  child: Text("🌱 Débutant"),
                ),
                DropdownMenuItem(
                  value: "Intermédiaire",
                  child: Text("🌿 Intermédiaire"),
                ),
                DropdownMenuItem(
                  value: "Avancé",
                  child: Text("🌳 Avancé"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
          )
              : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _selectedLevel == "Débutant"
                  ? "🌱 Débutant"
                  : _selectedLevel == "Intermédiaire"
                  ? "🌿 Intermédiaire"
                  : "🌳 Avancé",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
    TextInputType? keyboardType,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo2',
                color: Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: enabled ? color.shade300 : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: color.shade100.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: controller != null
              ? TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          )
              : Text(
            value ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: enabled ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
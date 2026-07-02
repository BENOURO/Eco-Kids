import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Connexion
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print("Erreur login: ${e.message}");
      return false;
    }
  }

  // 🔹 Inscription
  Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print("Erreur inscription: ${e.message}");
      return false;
    }
  }

  // 🔹 Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 Utilisateur courant
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

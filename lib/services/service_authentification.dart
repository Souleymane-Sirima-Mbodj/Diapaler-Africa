import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper léger autour de Firebase Auth.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<bool> isEmailRegistered(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
    return methods.isNotEmpty;
  }

  /// Traduit un FirebaseAuthException en message FR lisible.
  static String humanError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';
        case 'user-disabled':
          return 'Ce compte est désactivé.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cet email.';
        case 'weak-password':
          return 'Mot de passe trop faible (min. 6 caractères).';
        case 'network-request-failed':
          return 'Connexion internet requise.';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessaie dans quelques minutes.';
        default:
          return e.message ?? 'Erreur d\'authentification.';
      }
    }
    return 'Une erreur inattendue est survenue.';
  }
}

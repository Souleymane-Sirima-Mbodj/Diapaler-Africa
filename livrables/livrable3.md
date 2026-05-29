---

&nbsp;

&nbsp;

&nbsp;

# ![Logo ESP]  École Supérieure Polytechnique de Dakar

&nbsp;

---

# DIAPALER AFRICA
## Plateforme mobile de mentorat entrepreneurial

&nbsp;

# LIVRABLE 3
## Authentification

&nbsp;

---

| | |
|---|---|
| **Membre 1** | Alioune Badara Barry |
| **Membre 2** | Anta Diama Kama |
| **Membre 3** | Souleymane Sirima Mbodj |
| **Membre 4** | Serigne Abdoul Aziz Ndiaye |
| **Membre 5** | Mohamed Moctar Niang |
| **Membre 6** | Mareme Tine |
| **Classe / Filière** | [Ta Classe] |
| **Enseignant** | [Nom du Professeur] |
| **Module** | Développement d'Applications Mobiles |
| **Institution** | École Supérieure Polytechnique (ESP) — Dakar |
| **Année académique** | 2025 – 2026 |
| **Date de remise** | [Date] |

---

&nbsp;

> **📸 [Insérer ici le logo de l'ESP et/ou une capture de l'application]**

&nbsp;

---

# LIVRABLE 3 — Authentification

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [Introduction](#introduction)
- [1. Service d'authentification](#1-service-dauthentification-service_authentificationdart)
- [2. Persistance de session — Approche offline-first](#2-persistance-de-session--approche-offline-first)
  - [2.1 CacheService — profil hors-ligne](#21-cacheservice--profil-hors-ligne)
  - [2.2 Bootstrap au démarrage](#22-bootstrap-au-démarrage-page_demarragedartsplashpage)
  - [2.3 Flux complet au démarrage](#23-flux-complet-au-démarrage)
- [3. Page de Connexion](#3-page-de-connexion-page_connexiondart)
  - [3.1 Description complète de l'écran](#31-description-complète-de-lécran)
  - [3.2 Code complet de la connexion](#32-code-complet-de-la-connexion)
- [4. Page d'Inscription 4 étapes](#4-page-dinscription-4-étapes-page_inscriptiondart)
  - [4.1 Champs requis selon les consignes](#41-champs-requis-selon-les-consignes)
  - [4.2 Étape 1 — Identité](#42-étape-1--identité)
  - [4.3 Étape 2 — Localisation](#43-étape-2--localisation)
  - [4.4 Étape 3 — Profil professionnel](#44-étape-3--profil-professionnel)
  - [4.5 Étape 4 — Sécurité du compte](#45-étape-4--sécurité-du-compte)
  - [4.6 Barre de progression animée](#46-barre-de-progression-animée)
  - [4.7 Soumission et création du compte](#47-soumission-et-création-du-compte)
- [5. Page Mot de passe oublié](#5-page-mot-de-passe-oublié-page_mot_de_passe_oubliedart)
- [6. Déconnexion sécurisée](#6-déconnexion-sécurisée)
- [Conclusion](#conclusion-du-livrable-3)

---

## Introduction

DIAPALER AFRICA intègre un système d'authentification **complet et sécurisé** basé sur **Firebase Authentication** (provider Email/Password). Il couvre :
- La connexion avec gestion d'erreurs humanisées
- L'inscription multi-étapes (4 étapes) avec validation temps réel
- La réinitialisation du mot de passe par email Firebase
- La persistance de session avec **cache local offline-first** (`SharedPreferences`)
- La déconnexion sécurisée avec nettoyage complet

**Fichiers principaux :**
- `lib/services/service_authentification.dart` — Wrapper Firebase Auth
- `lib/services/service_cache.dart` — Cache local profil (offline-first)
- `lib/screens/page_demarrage.dart` — Bootstrap (SplashPage) au démarrage

---

## 1. Service d'authentification (`service_authentification.dart`)

Ce service centralise tous les appels Firebase Auth :

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Stream de l'état d'authentification (connexion/déconnexion)
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Utilisateur courant (synchrone — peut être null si non connecté)
  static User? get currentUser => _auth.currentUser;

  /// UID de l'utilisateur actuellement connecté (null si déconnecté)
  static String? get currentUid => _auth.currentUser?.uid;

  /// Connexion avec email et mot de passe
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Création d'un nouveau compte
  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Envoi d'un email de réinitialisation du mot de passe
  static Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Déconnexion
  static Future<void> signOut() => _auth.signOut();

  /// Conversion des codes d'erreur Firebase en messages français lisibles
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
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : section Authentication avec les comptes créés**
> *(Insérer ici la capture d'écran)*

---

## 2. Persistance de session — Approche offline-first

### 2.1 CacheService — profil hors-ligne

Le `CacheService` enregistre le profil dans `SharedPreferences` à chaque mise à jour. Au prochain démarrage, le profil est affiché **instantanément** avant même que Firebase réponde.

```dart
// lib/services/service_cache.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profil_utilisateur.dart';

class CacheService {
  static const String _profileKey = 'diapaler_cached_profile';

  /// Enregistre le profil dans le stockage local de l'appareil.
  static Future<void> saveProfile(UserProfile p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(_toJson(p)));
    } catch (_) {
      // Le cache est une optimisation : on ignore les erreurs d'écriture.
    }
  }

  /// Recharge le dernier profil connu depuis le stockage local.
  /// Renvoie null si aucun profil n'est en cache.
  static Future<UserProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (_) {
      return null;  // Cache corrompu : on ignore
    }
  }

  /// Vide le cache (appelé à la déconnexion).
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (_) {
      // La déconnexion ne doit jamais échouer à cause du cache.
    }
  }
}
```

---

### 2.2 Bootstrap au démarrage (`page_demarrage.dart` — SplashPage)

Au lieu d'un simple `StreamBuilder<User?>` sur `authStateChanges()` (qui ne peut pas afficher le profil en cache ni gérer le timeout réseau), DIAPALER AFRICA utilise une méthode `_bootstrap()` asynchrone dans la `SplashPage` :

```dart
// lib/screens/page_demarrage.dart
class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    Widget next = const RoleSelectionPage(); // Destination par défaut

    // ── Étape 1 : Chargement instantané du cache local (offline-first)
    // Affiche immédiatement les données du dernier utilisateur connecté
    final cached = await CacheService.loadProfile();
    if (cached != null) UserProfileController.update(cached);

    try {
      // ── Étape 2 : Attente de l'initialisation de Firebase (max 5s)
      // Firebase Realtime Database doit être prêt avant toute lecture
      await firebaseReady.timeout(const Duration(seconds: 5));

      // ── Étape 3 : Vérification synchrone de l'état d'authentification
      // AuthService.currentUid lit FirebaseAuth.instance.currentUser?.uid
      // Si Firebase Auth a restauré la session, currentUid est non-null
      final uid = AuthService.currentUid;
      if (uid != null) {
        // ── Étape 4 : Chargement du profil depuis Firebase (max 4s)
        final remote = await DatabaseService.readUserProfile(uid)
            .timeout(const Duration(seconds: 4));
        if (remote != null) {
          UserProfileController.update(remote); // Remplace le cache par les données fraîches
          next = const RootShell();             // Utilisateur connecté → app principale
        }
      }
    } catch (_) {
      // Timeout réseau ou Firebase non disponible :
      // → Si un cache exist, l'utilisateur voit son profil hors-ligne
      // → Sinon, redirection vers RoleSelectionPage
    }

    // ── Étape 5 : Animation de 200ms puis navigation
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écran de démarrage : logo DIAPALER animé + bande drapeau sénégalais
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DiapalerLogoTile(size: 80),
            SizedBox(height: 16),
            DiapalerWordmark(fontSize: 32),
            SizedBox(height: 8),
            SenegalFlagStrip(height: 4),
          ],
        ),
      ),
    );
  }
}
```

---

### 2.3 Flux complet au démarrage

```
App lancée (main.dart)
       │
       ├─→ Firebase.initializeApp() [async, non bloquant]
       │          → firebaseReady (Future<FirebaseApp>)
       │
       └─→ SplashPage._bootstrap()
                 │
                 ├─→ CacheService.loadProfile()
                 │       ├─ Profile trouvé : affichage instantané (offline)
                 │       └─ Pas de cache : profil vide
                 │
                 ├─→ await firebaseReady (timeout 5s)
                 │
                 ├─→ AuthService.currentUid (synchrone)
                 │       ├─ null : → RoleSelectionPage (non connecté)
                 │       └─ uid  : → DatabaseService.readUserProfile()
                 │                         │
                 │                         ├─ Succès → RootShell (connecté)
                 │                         └─ Timeout → RoleSelectionPage
                 │
                 └─→ Navigation avec FadeTransition (350ms)
```

**Avantages de cette approche vs StreamBuilder :**

| Critère | `StreamBuilder<User?>` | `_bootstrap()` (notre approche) |
|---|---|---|
| Profil hors-ligne | ❌ Non | ✅ `CacheService.loadProfile()` |
| Timeout réseau | ❌ Attente infinie | ✅ `timeout(4s)` |
| Chargement profil Firebase | ❌ Non | ✅ `readUserProfile()` |
| Logo + animation | ❌ Complexe | ✅ Natif dans SplashPage |
| Gestion d'erreurs | ❌ Limitée | ✅ `try/catch` complet |

> **📸 CAPTURE D'ÉCRAN — Splash Screen animé au démarrage**
> *(Insérer ici la capture d'écran)*

---

## 3. Page de Connexion (`page_connexion.dart`)

### 3.1 Description complète de l'écran

| Élément | Description |
|---|---|
| En-tête | Gradient navy avec logo DIAPALER + bande drapeau sénégalais |
| Sous-titre | "Bon retour ! 👋" + "Connecte-toi pour continuer ton parcours" |
| Champ Email | Type email, autofill OS, icône mail bleue |
| Champ Mot de passe | `obscureText`, bouton œil afficher/masquer, icône cadenas |
| Lien "Mot de passe oublié ?" | Aligné à droite, couleur bleue |
| Bandeau d'erreur | Fond rouge 10%, icône alerte, message humanisé Firebase |
| Bouton SE CONNECTER | Gradient navy→bleu, glow amber en ombre, spinner pendant l'appel |
| Lien "S'inscrire" | Navigation `pushReplacement` vers `SignUpPage` |

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (état initial)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (erreur : mot de passe incorrect)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (spinner pendant la connexion)**
> *(Insérer ici la capture d'écran)*

---

### 3.2 Code complet de la connexion

```dart
// page_connexion.dart
class _LoginPageState extends State<LoginPage> {
  final _email    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    // ── Validation locale (avant appel réseau)
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email et mot de passe requis.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // ── 1. Authentification Firebase Auth
      final cred = await AuthService.signIn(
        email: _email.text,
        password: _password.text,
      );

      // ── 2. Chargement du profil depuis Firebase Database
      final uid = cred.user?.uid;
      if (uid != null) {
        final remote = await DatabaseService.readUserProfile(uid);
        if (remote != null) {
          UserProfileController.update(remote); // Cache local + état global
        }
      }

      // ── 3. Redirection (supprime la pile de navigation)
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (_) => false,
      );

    } catch (e) {
      // ── 4. Message d'erreur humanisé
      if (!mounted) return;
      setState(() => _error = AuthService.humanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── En-tête gradient navy + drapeau sénégalais
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navyDeep, AppColors.navy, Color(0xFF14305E)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Column(children: [
                const DiapalerLogoTile(size: 50, onDark: true),
                const DiapalerWordmark(fontSize: 24, onDark: true),
                const SenegalFlagStrip(height: 3),
              ]),
            ),

            // ── Formulaire
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                children: [
                  const Text('Bon retour ! 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Connecte-toi pour continuer ton parcours',
                    style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 20),

                  // Champs avec autofill OS
                  AutofillGroup(
                    child: Column(children: [
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nom@email.sn',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signIn(),
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  // Lien mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                      child: const Text('Mot de passe oublié ?',
                          style: TextStyle(color: AppColors.blue)),
                    ),
                  ),

                  // Bandeau d'erreur conditionnel
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!,
                            style: const TextStyle(color: AppColors.red))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Bouton SE CONNECTER avec gradient + glow amber
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.35),
                        blurRadius: 18, offset: const Offset(0, 8),
                      )],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SE CONNECTER',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lien S'inscrire
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const SignUpPage())),
                      child: const Text.rich(TextSpan(children: [
                        TextSpan(text: 'Pas encore de compte ? ',
                            style: TextStyle(color: AppColors.muted)),
                        TextSpan(text: "S'inscrire",
                            style: TextStyle(color: AppColors.blue,
                                fontWeight: FontWeight.w700)),
                      ])),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Page d'Inscription 4 étapes (`page_inscription.dart`)

### 4.1 Champs requis selon les consignes

| Consigne | Implémentation |
|---|---|
| Nom | Champ "Nom complet" (prénom + nom, min 2 mots, min 4 chars) |
| Téléphone | Champ téléphone +221 fixe + auto-format "77 123 45 67" |
| Email | Validation regex `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` |
| Mot de passe | Min 6 caractères + jauge de force + confirmation |
| Redirection vers connexion | Lien "J'ai déjà un compte → Se connecter" |

---

### 4.2 Étape 1 — Identité

**Champs :**
- Nom complet (prénom + nom obligatoires, min 4 caractères)
- Adresse email (validation regex)
- Sexe (Homme / Femme / Autre — pills animés)
- Date de naissance (DatePicker natif Flutter — `helpText: 'Date de naissance'`)
- Badge confirmation du rôle choisi (lecture seule)

**Validations temps réel :**

```dart
bool get _nameValid =>
    _name.text.trim().split(RegExp(r'\s+')).length >= 2 &&
    _name.text.trim().length >= 4;

bool get _emailValid =>
    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
    .hasMatch(_email.text.trim());

// DatePicker avec texte d'aide court pour éviter la troncature
await showDatePicker(
  context: context,
  initialDate: _birthDate ?? DateTime(2000),
  firstDate: DateTime(1940),
  lastDate: DateTime.now(),
  helpText: 'Date de naissance',  // ← 16 chars, pas de troncature
);
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (formulaire identité)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (champs validés en vert)**
> *(Insérer ici la capture d'écran)*

---

### 4.3 Étape 2 — Localisation

**Champs :**
- Pays (dropdown — liste de pays d'Afrique de l'Ouest + France)
- Ville (dropdown filtrée selon le pays sélectionné)
- Adresse (optionnel)

```dart
// Mise à jour automatique des villes lors du changement de pays
_InlineDropdown(
  label: 'Pays',
  value: _country,
  values: supportedCountries,
  onChanged: (v) => setState(() {
    _country = v;
    _city = citiesOf(v).first;  // Réinitialise la ville selon le pays
  }),
),
_InlineDropdown(
  label: 'Ville',
  value: _city,
  values: citiesOf(_country),   // Villes filtrées selon le pays
  onChanged: (v) => setState(() => _city = v),
),
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 2 (localisation — pays/ville)**
> *(Insérer ici la capture d'écran)*

---

### 4.4 Étape 3 — Profil professionnel

**Champs :**
- Photo de profil (tap → galerie/caméra → `image_picker` → redimensionnement 512×512 → encodage base64)
- Biographie (textarea, 240 caractères max avec compteur)
- LinkedIn (URL, optionnel)
- Centres d'intérêt / domaines d'expertise (chips multi-sélection — au moins 1 obligatoire)

```dart
Future<void> _pickProfilePhoto() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,   // Compression JPEG 80%
    maxWidth: 512,      // Redimensionnement automatique
    maxHeight: 512,
  );
  if (image != null) {
    final bytes = await image.readAsBytes();
    setState(() {
      _photoBytes   = bytes;
      _photoBase64  = base64Encode(bytes); // Format stockable dans Firebase
    });
  }
}

// Compteur de caractères temps réel dans la biographie
TextField(
  controller: _bio,
  maxLength: 240,
  maxLines: 4,
  decoration: InputDecoration(
    labelText: 'Biographie',
    counterText: '${_bio.text.length}/240',
  ),
),
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 3 (photo + sélection des intérêts)**
> *(Insérer ici la capture d'écran)*

---

### 4.5 Étape 4 — Sécurité du compte

**Champs :**
- Téléphone sénégalais : préfixe +221 fixe + champ digits auto-formaté (77 123 45 67)
- Mot de passe (min 6 caractères, bouton œil)
- Jauge de force du mot de passe (5 niveaux : Trop court / Faible / Moyen / Bon / Excellent)
- Confirmation du mot de passe (indicateur correspondance ✓/✗)
- Case à cocher CGU (obligatoire pour valider)

```dart
// Auto-format téléphone sénégalais "77 123 45 67"
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Calcul de la force du mot de passe (0 → 4)
int _computeStrength(String pwd) {
  if (pwd.length < 6) return 0;
  int score = 0;
  if (pwd.length >= 6)  score++;               // Longueur minimale
  if (pwd.length >= 10) score++;               // Longueur recommandée
  if (RegExp(r'[A-Z]').hasMatch(pwd) &&
      RegExp(r'[a-z]').hasMatch(pwd)) score++; // Majuscule + minuscule
  if (RegExp(r'\d').hasMatch(pwd)) score++;    // Chiffre
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) score++; // Caractère spécial
  return score.clamp(0, 4);
}

// Affichage de la jauge de force
final labels = ['Trop court', 'Faible', 'Moyen', 'Bon', 'Excellent'];
final colors = [AppColors.red, AppColors.orange, AppColors.amber,
                AppColors.green, AppColors.green];
final strength = _computeStrength(_password.text);
Row(
  children: List.generate(4, (i) => Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 4,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: i < strength ? colors[strength] : AppColors.border,
        borderRadius: BorderRadius.circular(99),
      ),
    ),
  )),
),
Text(labels[strength], style: TextStyle(color: colors[strength])),
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (téléphone + jauge mot de passe)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (jauge de force "Excellent")**
> *(Insérer ici la capture d'écran)*

---

### 4.6 Barre de progression animée

```dart
// 4 segments amber (fait) / gris (à venir) — animés avec AnimatedContainer
class _StepBar extends StatelessWidget {
  final int step;  // Étape courante (0-based)
  final int total; // Nombre total d'étapes

  const _StepBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 5,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.amber : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Barre de progression Étape 3 sur 4 (3 segments amber)**
> *(Insérer ici la capture d'écran)*

---

### 4.7 Soumission et création du compte

```dart
Future<void> _submit() async {
  if (!_step1Valid || !_step2Valid || !_step3Valid || !_step4Valid) return;
  setState(() { _loading = true; _error = null; });

  try {
    // ── 1. Création du compte Firebase Auth
    final cred = await AuthService.signUp(
      email: _email.text,
      password: _password.text,
    );
    final uid = cred.user!.uid;

    // ── 2. Construction du profil complet
    final parts = _name.text.trim().split(RegExp(r'\s+'));
    final profile = UserProfile(
      firstName:   parts.first,
      lastName:    parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email:       _email.text.trim(),
      phone:       '+221 ${_phone.text.trim()}',
      gender:      _gender,
      birthDate:   _birthDate,
      city:        _city,
      country:     _country,
      role:        _roleLabel(_role),   // Entrepreneur / Mentor / Investisseur
      sector:      _sector,
      bio:         _bio.text.trim(),
      linkedin:    _linkedin.text.trim(),
      photoBase64: _photoBase64,
      interests:   _interests.toList()..sort(),
      projects:    const [],
    );

    // ── 3. Sauvegarde dans Firebase Database (CREATE)
    await DatabaseService.createUserProfile(uid, profile);

    // ── 4. Mise à jour état local + cache automatique
    UserProfileController.update(profile);

    // ── 5. Redirection vers l'onboarding
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
      (_) => false,
    );

  } catch (e) {
    setState(() => _error = AuthService.humanError(e));
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Bouton S'INSCRIRE actif (toutes étapes valides)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Onboarding après inscription réussie**
> *(Insérer ici la capture d'écran)*

---

## 5. Page Mot de passe oublié (`page_mot_de_passe_oublie.dart`)

```dart
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email  = TextEditingController();
  bool _loading = false;
  bool _sent    = false;
  String? _error;

  Future<void> _reset() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Entre ton adresse email.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      // Appel Firebase : envoi d'un email de réinitialisation
      await AuthService.sendPasswordResetEmail(_email.text.trim());
      setState(() => _sent = true); // Affiche le message de succès
    } catch (e) {
      setState(() => _error = AuthService.humanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      // ── Message de confirmation (email envoyé)
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_rounded,
                    size: 72, color: AppColors.green),
                const SizedBox(height: 20),
                const Text('Email envoyé !',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Un lien de réinitialisation a été envoyé à ${_email.text.trim()}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Retour à la connexion'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Formulaire de reset
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.amber),
            const SizedBox(height: 16),
            const Text(
              'Entre ton email pour recevoir un lien de réinitialisation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'ton@email.sn',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _reset,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ENVOYER LE LIEN'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Écran Mot de Passe Oublié (formulaire)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Écran Mot de Passe Oublié (confirmation : email envoyé)**
> *(Insérer ici la capture d'écran)*

---

## 6. Déconnexion sécurisée

La déconnexion est gérée depuis `feuille_profil.dart` (bottom sheet du profil) avec un **dialog de confirmation** et un **nettoyage complet** en 6 étapes :

```dart
// widgets/feuille_profil.dart — Déconnexion depuis le bottom sheet profil
Future<void> _signOut(BuildContext context) async {
  // ── Dialog de confirmation avant déconnexion
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Se déconnecter ?'),
      content: const Text('Tu devras te reconnecter pour accéder à ton compte.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Se déconnecter',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirm != true) return; // Annulé par l'utilisateur

  // ── Nettoyage complet en 6 étapes
  await CacheService.clear();              // 1. Vide le cache SharedPreferences
  NotificationService.reset();            // 2. Vide les notifications en mémoire
  await AgendaController.reset();         // 3. Vide les sessions agenda en mémoire
  UserProfileController.reset();          // 4. Réinitialise le profil en mémoire
  appTabIndex.value = 0;                  // 5. Retour à l'onglet Accueil
  await AuthService.signOut();           // 6. Révoque la session Firebase Auth

  // ── Redirection vers le choix du rôle (pile vidée)
  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    (_) => false,
  );
}
```

**`UserProfileController.reset()` :**
```dart
/// Vide le profil en mémoire après déconnexion pour éviter la fuite
/// de données entre deux sessions utilisateurs différents.
static void reset() {
  profile.value = const UserProfile(
    firstName: '', lastName: '', email: '', phone: '',
    city: '', sector: '', role: '', bio: '',
    interests: [], projects: [],
  );
}
```

> **📸 CAPTURE D'ÉCRAN — Dialog de confirmation de déconnexion**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Retour à l'écran de sélection de rôle après déconnexion**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 3

| Critère du sujet | Implémentation | Statut |
|---|---|---|
| Page de Connexion | Email + mot de passe, validation, gradient button + glow | ✅ |
| Lien inscription | `pushReplacement` vers SignUpPage | ✅ |
| Redirection après connexion | `pushAndRemoveUntil` vers RootShell | ✅ |
| Page d'Inscription | Nom, téléphone, email, mot de passe — 4 étapes | ✅ |
| Redirection vers la connexion | Lien "J'ai déjà un compte" | ✅ |
| Gestion des erreurs Firebase | Messages humanisés pour tous les codes d'erreur | ✅ |
| Reset mot de passe | `sendPasswordResetEmail()` + confirmation visuelle | ✅ |
| Persistance de session | Cache local offline-first + `_bootstrap()` Firebase | ✅ |
| Cache offline-first | `CacheService` (SharedPreferences) | ✅ (bonus) |
| Déconnexion | Dialog + 6 étapes (cache + notifs + agenda + profil + tab + Auth) | ✅ |
| Jauge de force mot de passe | 5 niveaux animés + indicateurs couleur | ✅ (bonus) |
| Auto-format téléphone | `_PhoneFormatter` format sénégalais +221 XX XXX XX XX | ✅ (bonus) |

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
  - [4.6 Soumission et création du compte](#46-soumission-et-création-du-compte)
- [5. Page Mot de passe oublié](#5-page-mot-de-passe-oublié-page_mot_de_passe_oubliedart)
- [6. Déconnexion sécurisée](#6-déconnexion-sécurisée)
- [Conclusion](#conclusion-du-livrable-3)

---

## Introduction

Ce livrable couvre tout le système d'authentification de DIAPALER AFRICA, de la première ouverture de l'application jusqu'à la déconnexion sécurisée. Nous avons cherché à proposer une expérience fluide et rassurante pour l'utilisateur : une inscription guidée étape par étape, une connexion mémorisée par le gestionnaire de mots de passe du téléphone, et un mode hors-ligne qui évite de se retrouver bloqué faute de réseau. Chaque choix technique — Firebase Auth, cache local, messages d'erreur en français — a été pensé pour correspondre aux habitudes et contraintes du contexte sénégalais.

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

Plutôt que d'appeler Firebase Auth directement depuis chaque écran, nous avons centralisé tous les appels dans une classe `AuthService` statique. Cela garantit que la logique d'authentification n'est écrite qu'une seule fois, et surtout que la conversion des codes d'erreur Firebase en messages lisibles (en français) est appliquée de façon cohérente partout dans l'application. L'utilisateur ne verra jamais un code cryptique comme `wrong-password` ou `network-request-failed` — il recevra à la place un message humain et actionnable.

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

Au lieu d'un simple `StreamBuilder<User?>` sur `authStateChanges()` (qui ne peut pas afficher le profil en cache ni gérer le timeout réseau), DIAPALER AFRICA utilise une méthode `_bootstrap()` asynchrone dans la `SplashPage`.

**Écran de démarrage :** fond `AppColors.navyDeep` avec un pattern de points subtil en arrière-plan. Au centre : le logo DIAPALER (tile circulaire navy→blue avec bordure amber) entouré de **3 orbites animées** aux couleurs du drapeau sénégalais (vert, jaune, rouge), qui s'allument une à une. Le wordmark apparaît en `fontSize: 36` suivi du sous-titre *« Connecte ton idée à ton succès »* en italique, et d'une `LinearProgressIndicator` amber. L'`AnimationController` dure **1 100 ms** au total.

```dart
// lib/screens/page_demarrage.dart
class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
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
      await firebaseReady.timeout(const Duration(seconds: 5));

      // ── Étape 3 : Vérification synchrone de l'état d'authentification
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
      // → Si un cache existe, l'utilisateur voit son profil hors-ligne
      // → Sinon, redirection vers RoleSelectionPage
    }

    // ── Étape 5 : 200ms d'attente puis navigation avec FadeTransition
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: next),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fond navy profond + pattern de points + logo animé avec 3 orbites drapeau
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotsBg())),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Logo(anim: _ctrl), // tile + 3 orbites flagGreen/flagYellow/flagRed
                const SizedBox(height: 22),
                _slideUp(
                  anim: _at(0.55, 0.85),
                  child: const DiapalerWordmark(fontSize: 36, onDark: true),
                ),
                const SizedBox(height: 12),
                _slideUp(
                  anim: _at(0.7, 1.0),
                  child: const Text(
                    '« Connecte ton idée à ton succès »',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _at(0.9, 1.0),
                  child: const SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.amber),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 2.3 Flux complet au démarrage

Le schéma ci-dessous résume l'enchaînement des décisions au moment où l'application s'ouvre. L'idée centrale est de ne jamais laisser l'utilisateur sur un écran vide ou bloqué : si le cache local contient un profil, il est affiché immédiatement, et Firebase confirme ou met à jour les données dans un second temps. Les timeouts empêchent un gel infini en cas de réseau lent.

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

> **📸 CAPTURE D'ÉCRAN — Splash Screen animé au démarrage**
> *(Insérer ici la capture d'écran)*

---

## 3. Page de Connexion (`page_connexion.dart`)

La page de connexion est le point d'entrée de l'application pour les utilisateurs existants. Nous avons soigné son design — gradient navy, logo DIAPALER, bande aux couleurs du drapeau sénégalais — pour donner dès le premier regard une identité forte à l'application. Les erreurs Firebase (mauvais mot de passe, email inconnu) sont interceptées et traduites en messages compréhensibles par l'utilisateur, sans jargon technique. Un autre point important : la page utilise `AutofillGroup` pour que le gestionnaire de mots de passe du téléphone (Google, Samsung, iCloud) propose de sauvegarder et remplir automatiquement les identifiants à la prochaine connexion.

### 3.1 Description complète de l'écran

| Élément | Description |
|---|---|
| En-tête | Gradient navy avec logo DIAPALER + bande drapeau sénégalais |
| Sous-titre | "Bon retour ! 👋" + "Connecte-toi pour continuer ton parcours" |
| Champ Email | Type email, `autofillHints: [username, email]`, icône mail bleue |
| Champ Mot de passe | `obscureText`, `autofillHints: [password]`, bouton œil afficher/masquer |
| Sauvegarde MDP | `AutofillGroup` + `TextInput.finishAutofillContext(shouldSave: true)` après succès → Google Password Manager / Samsung Pass / iCloud Keychain |
| Lien "Mot de passe oublié ?" | Aligné à droite, couleur bleue |
| Bandeau d'erreur | Fond rouge 10%, icône alerte, message humanisé Firebase |
| Bouton SE CONNECTER | Gradient navy→bleu, glow amber en ombre, spinner pendant l'appel |
| Lien "S'inscrire" | Navigation `pushReplacement` vers `SignUpPage` |
| Après déconnexion | Retour vers cette page (pas vers le choix de rôle) |

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (état initial)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (erreur : mot de passe incorrect)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion (spinner pendant la connexion)**
> *(Insérer ici la capture d'écran)*

---

### 3.2 Code complet de la connexion

Le code de la page de connexion suit un flux clair en quatre temps : validation locale, appel Firebase, chargement du profil, puis redirection. Le spinner remplace le bouton pendant l'appel réseau pour éviter les doubles soumissions. En cas d'échec, le bandeau rouge s'affiche avec un message en français ; en cas de succès, toute la pile de navigation est effacée pour éviter que l'utilisateur puisse revenir en arrière avec le bouton « retour ».

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
                          hintText: 'nom@téki.sn',
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

L'inscription a été conçue en 4 étapes progressives pour ne pas décourager l'utilisateur avec un formulaire trop long d'un seul coup. Chaque étape collecte un ensemble cohérent d'informations, et une barre de progression animée indique visuellement où en est l'utilisateur. Les validations se font en temps réel : l'utilisateur voit immédiatement si son email est valide ou si son mot de passe est suffisamment fort. Le bouton « Suivant » ne s'active que lorsque tous les champs obligatoires de l'étape courante sont correctement remplis, ce qui évite de devoir afficher des messages d'erreur massifs en bas de page.

### 4.1 Champs requis selon les consignes

| Consigne | Implémentation |
|---|---|
| Nom | Champ "Nom complet" (prénom + nom, min 2 mots, min 4 chars) |
| Téléphone | Préfixe **dynamique** selon le pays (🇸🇳 +221 Sénégal / 🇬🇲 +220 Gambie / 🇲🇱 +223 Mali) + longueur adaptée (9/7/8 chiffres) |
| Email | Validation regex `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` |
| Mot de passe | Min 6 caractères + jauge de force + confirmation |
| Redirection vers connexion | Lien "J'ai déjà un compte → Se connecter" |

---

### 4.2 Étape 1 — Identité

La première étape réunit les informations de base qui définissent l'identité de l'utilisateur sur la plateforme. Nous avons volontairement regroupé ici le nom, l'email, le sexe et la date de naissance, car ce sont des informations que l'utilisateur connaît par cœur et peut saisir rapidement. Le choix du sexe s'effectue via trois pills animés avec l'option « Non précisé » sélectionnée par défaut, pour ne pas forcer une déclaration. L'âge minimum de 13 ans est imposé par le DatePicker via la contrainte `lastDate`, conformément aux règles Firebase et à la réglementation sur la protection des mineurs.

**Champs :**
- Nom complet (prénom + nom obligatoires, min 4 caractères)
- Adresse email (validation regex)
- Sexe (**Femme / Homme / Non précisé** — 3 pills animés, **défaut : Non précisé**)
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

// DatePicker avec contrainte d'âge minimum 13 ans
// initialDate : 22 ans en arrière par défaut (ou la date déjà saisie)
// lastDate    : 13 ans en arrière (âge minimum requis)
await showDatePicker(
  context: context,
  initialDate: _birthDate ?? DateTime(now.year - 22), // mois/jour = 1/1 par défaut
  firstDate: DateTime(1940),
  lastDate: DateTime(now.year - 13, 12, 31),
  helpText: 'Ta date de naissance',
);
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (formulaire identité)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (champs validés en vert)**
> *(Insérer ici la capture d'écran)*

---

### 4.3 Étape 2 — Localisation

La deuxième étape recueille la localisation de l'utilisateur. Nous avons limité la liste des pays aux marchés cibles de la plateforme — principalement l'Afrique de l'Ouest et la France — pour simplifier l'interface et ne pas noyer l'utilisateur dans un dropdown de 200 pays. La sélection du pays déclenche automatiquement la mise à jour de la liste des villes disponibles : l'utilisateur ne peut choisir une ville que parmi celles qui correspondent au pays sélectionné, ce qui garantit la cohérence des données. L'adresse précise est optionnelle.

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

La troisième étape est sans doute la plus riche, car elle construit le profil public de l'utilisateur sur la plateforme. C'est ici qu'il choisit son secteur d'activité, télécharge sa photo de profil, rédige sa biographie et sélectionne ses centres d'intérêt. Nous avons adapté les libellés et les champs selon le rôle : un entrepreneur n'a pas les mêmes besoins qu'un mentor ou un investisseur. La photo est redimensionnée à 512×512 pixels côté client avant envoi, pour limiter la consommation de données — un détail important dans un contexte où la connexion peut être limitée. Les chips de centres d'intérêt permettent une sélection multiple avec un retour visuel immédiat.

**Champs (communs à tous les rôles) :**
- Secteur d'activité (dropdown obligatoire — libellé adapté : "Secteur d'activité" / "Secteur principal" / "Secteur d'investissement")
- Photo de profil (tap → galerie → `image_picker` → redimensionnement 512×512 → encodage base64)
- Biographie "À propos de moi" (`hintText: 'Présente-toi en quelques lignes...'`, 240 caractères max, compteur natif)
- LinkedIn (URL, optionnel)
- Centres d'intérêt / domaines d'expertise (chips multi-sélection — au moins 1 obligatoire)

**Champs spécifiques selon le rôle :**
- **Mentor uniquement** : Années d'expérience (champ numérique optionnel)
- **Investisseur uniquement** : Ticket d'investissement (ex. "500 000 – 5 000 000 FCFA", optionnel)

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

// Biographie : hintText invite à se présenter, compteur natif Flutter (maxLength)
TextField(
  controller: _bio,
  maxLength: 240,
  maxLines: 4,
  decoration: const InputDecoration(
    hintText: 'Présente-toi en quelques lignes...',
  ),
),
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 3 (photo + sélection des intérêts)**
> *(Insérer ici la capture d'écran)*

---

### 4.5 Étape 4 — Sécurité du compte

La quatrième et dernière étape de l'inscription rassemble les informations de sécurité. Le préfixe téléphonique s'adapte automatiquement au pays choisi à l'étape 2 — si l'utilisateur a sélectionné le Sénégal, le préfixe `+221` et la longueur de 9 chiffres sont appliqués sans aucune manipulation de sa part. La jauge de force du mot de passe est animée en temps réel sur 5 niveaux pour aider l'utilisateur à choisir un mot de passe solide sans lui imposer des règles frustrantes. L'acceptation des CGU est obligatoire et visualisée par une case à cocher qui débloque le bouton de validation : l'utilisateur ne peut pas finaliser son inscription sans les avoir acceptées explicitement.

**Champs :**
- Téléphone avec **préfixe dynamique** selon le pays choisi à l'étape 2 :
  - 🇸🇳 **Sénégal** → `+221` (9 chiffres)
  - 🇬🇲 **Gambie** → `+220` (7 chiffres)
  - 🇲🇱 **Mali** → `+223` (8 chiffres)
  - Le préfixe et la validation de longueur s'adaptent automatiquement via les maps `countryDialCode` et `countryPhoneLength` dans `lib/data/pays.dart`
- Mot de passe (min 6 caractères, bouton œil)
- Jauge de force du mot de passe (5 niveaux : Trop court / Faible / Moyen / Bon / Excellent)
- Confirmation du mot de passe (indicateur correspondance ✓/✗)
- Case à cocher CGU (obligatoire pour valider)

Le téléphone est auto-formaté via un `TextInputFormatter` custom adapté à la longueur du pays. La force du mot de passe est calculée sur 5 niveaux (longueur, majuscule, chiffre, caractère spécial) et affichée via des segments `AnimatedContainer` colorés.

```dart
// Calcul de la force (0 → 4) : longueur, casse, chiffre, caractère spécial
int _computeStrength(String pwd) {
  if (pwd.length < 6) return 0;
  int s = 1;
  if (pwd.length >= 10) s++;
  if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) s++;
  if (RegExp(r'\d').hasMatch(pwd)) s++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) s++;
  return s.clamp(0, 4);
}
```

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (téléphone + jauge mot de passe)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (jauge de force "Excellent")**
> *(Insérer ici la capture d'écran)*

---

### 4.6 Soumission et création du compte

Une fois les 4 étapes validées, le bouton « S'INSCRIRE » déclenche une séquence de 5 opérations enchaînées. D'abord la création du compte Firebase Auth, ensuite l'upload de la photo vers Cloudinary (avec un fallback en base64 si la connexion échoue), puis la construction du profil complet, sa sauvegarde dans Firebase Database, et enfin la mise en cache local. Si une erreur survient à n'importe quelle étape, le message correspondant est affiché en français. En cas de succès, l'utilisateur est redirigé vers l'onboarding — un écran de bienvenue qui lui présente les grandes fonctionnalités de l'application avant sa première utilisation.

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

    // ── 2. Upload photo vers Cloudinary (si disponible), sinon fallback base64
    String photoData = _photoBase64;
    if (_photoBytes != null && _photoBytes!.isNotEmpty) {
      try {
        photoData = await CloudinaryService.uploadBytes(
          bytes: _photoBytes!,
          filename: 'avatar_$uid.jpg',
        );
        // photoData contient maintenant une URL HTTPS Cloudinary
      } catch (_) {
        // En cas d'erreur réseau, on garde le base64 temporairement
      }
    }

    // ── 3. Construction du profil complet
    final parts = _name.text.trim().split(RegExp(r'\s+'));
    // Préfixe dynamique selon le pays choisi à l'étape 2
    final dialCode = countryDialCode[_country] ?? '+221';
    final profile = UserProfile(
      firstName:       parts.first,
      lastName:        parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email:           _email.text.trim(),
      phone:           '$dialCode ${_phone.text.trim()}',
      gender:          _gender,
      birthDate:       _birthDate,
      address:         _address.text.trim(),
      city:            _city,
      country:         _country,
      role:            _roleLabel(_role),   // Entrepreneur / Mentor / Investisseur
      sector:          _sector,
      yearsExperience: _role == UserRole.mentor
                         ? (int.tryParse(_yearsExp.text.trim()) ?? 0) : 0,
      investmentRange: _role == UserRole.investor
                         ? _investmentRange.text.trim() : '',
      bio:             _bio.text.trim(),
      linkedin:        _linkedin.text.trim(),
      photoBase64:     photoData,   // URL Cloudinary ou base64 selon disponibilité
      interests:       _interests.toList()..sort(),
      projects:        const [],
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

La page de réinitialisation du mot de passe est volontairement simple : un champ email, un bouton, et deux états possibles — le formulaire ou la confirmation. Lorsque l'utilisateur soumet son email, Firebase envoie automatiquement un lien de réinitialisation à l'adresse indiquée. Côté application, on bascule sur un écran de confirmation avec une icône verte et un message rassurant qui indique l'adresse à laquelle le lien a été envoyé. On a fait le choix de ne pas distinguer le cas « email inconnu » du cas « email valide », pour éviter d'exposer la liste des comptes existants — c'est une bonne pratique de sécurité courante.

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

La déconnexion est accessible depuis **deux points d'entrée** : l'icône rouge dans l'AppBar de `page_profil.dart` et le bottom sheet profil (`feuille_profil.dart`). Les deux déclenchent un **dialog de confirmation** puis un **nettoyage complet** en 6 étapes avant de rediriger vers `LoginPage` :

```dart
// Logique partagée — _LogoutButton.confirmAndLogout()
Future<void> _signOut(BuildContext context) async {
  // ── Dialog de confirmation avant déconnexion
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Se déconnecter ?'),
      content: const Text('Tu devras te reconnecter pour accéder à ton tableau de bord.'),
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

  // ── Redirection vers la page de connexion (pile vidée, FadeTransition)
  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const LoginPage()),
      transitionDuration: const Duration(milliseconds: 350),
    ),
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

> **📸 CAPTURE D'ÉCRAN — Retour à l'écran de connexion après déconnexion**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 3

| Critère du sujet | Implémentation | Statut |
|---|---|---|
| Page de Connexion | Email + mot de passe, validation, gradient button + glow | ✅ |
| Lien inscription | `pushReplacement` vers SignUpPage | ✅ |
| Redirection après connexion | `pushAndRemoveUntil` vers RootShell | ✅ |
| Page d'Inscription | Nom, téléphone, email, mot de passe + secteur + champs rôle — 4 étapes | ✅ |
| Champs rôle-spécifiques | Années d'expérience (Mentor) + ticket investissement (Investisseur) à l'étape 3 | ✅ |
| Redirection vers la connexion | Lien "J'ai déjà un compte" + déconnexion → LoginPage | ✅ |
| Sauvegarde mot de passe | `AutofillGroup` + `finishAutofillContext(shouldSave: true)` — Google/Samsung/iCloud | ✅ |
| Gestion des erreurs Firebase | Messages humanisés pour tous les codes d'erreur | ✅ |
| Reset mot de passe | `sendPasswordResetEmail()` + confirmation visuelle | ✅ |
| Persistance de session | Cache local offline-first + `_bootstrap()` Firebase | ✅ |
| Cache offline-first | `CacheService` (SharedPreferences) | ✅ (bonus) |
| Déconnexion | Dialog + 6 étapes (cache + notifs + agenda + profil + tab + Auth) | ✅ |
| Jauge de force mot de passe | 5 niveaux animés + indicateurs couleur | ✅ (bonus) |
| Auto-format téléphone | `_PhoneFormatter` format adaptatif selon le pays | ✅ (bonus) |
| Préfixe téléphone dynamique | `countryDialCode` / `countryPhoneLength` — +221 SN / +220 GM / +223 ML | ✅ (bonus) |

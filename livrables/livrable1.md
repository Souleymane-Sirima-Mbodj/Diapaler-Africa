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

# LIVRABLE 1
## Création du projet Flutter · Intégration des interfaces · Navigation

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

# LIVRABLE 1 — Création du projet Flutter · Interfaces · Navigation

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [1. Création du projet Flutter](#1-création-du-projet-flutter)
  - [1.1 Nom et identité](#11-nom-et-identité)
  - [1.2 Dépendances installées](#12-dépendances-installées-pubspecyaml)
  - [1.3 Structure complète du projet](#13-structure-complète-du-projet)
  - [1.4 Initialisation et lancement](#14-initialisation-et-lancement)
- [2. Intégration des interfaces](#2-intégration-des-interfaces)
  - [2.1 Design System unifié](#21-design-system-unifié)
  - [2.2 Écran de démarrage (Splash)](#22-écran-de-démarrage-splash--page_demarragedar)
  - [2.3 Onboarding / Découverte](#23-onboarding--découverte--page_decouvertedar)
  - [2.4 Choix du rôle](#24-choix-du-rôle--page_choix_roledart)
  - [2.5 Connexion](#25-connexion--page_connexiondart)
  - [2.6 Inscription 4 étapes](#26-inscription-4-étapes--page_inscriptiondart)
  - [2.7 Dashboard Entrepreneur](#27-dashboard-entrepreneur--page_accueildart)
  - [2.8 Dashboard Mentor](#28-dashboard-mentor--page_dashboard_mentordart)
  - [2.9 Dashboard Investisseur](#29-dashboard-investisseur--page_dashboard_investisseurdart)
  - [2.10 Matching / Explorer](#210-matching--explorer--page_matchingdart)
  - [2.11 Détail d'un profil](#211-détail-dun-profil--page_detail_mentordart)
  - [2.12 Messagerie](#212-messagerie--page_messagesdart--page_chatdart)
  - [2.13 Notifications](#213-notifications--page_notificationsdart)
  - [2.14 Mon Profil](#214-mon-profil--page_profildart)
  - [2.15 Modifier le profil](#215-modifier-le-profil--page_modification_profildart)
  - [2.16 Déposer un Pitch](#216-déposer-un-pitch--page_pitchdart)
  - [2.17 Pitchs Publiés](#217-pitchs-publiés--page_pitches_publicsdart)
  - [2.18 Autres écrans complémentaires](#218-autres-écrans-complémentaires)
  - [2.19 Aide & Support](#219-aide--support--page_aidedar)
  - [2.20 Paramètres utilisateur](#220-paramètres-utilisateur--page_parametresdar)
- [3. Navigation entre les écrans](#3-navigation-entre-les-écrans)
  - [3.1 Architecture de navigation](#31-architecture-de-navigation-à-deux-niveaux)
  - [3.2 Flux de navigation complet](#32-flux-de-navigation-complet)
  - [3.3 Boutons retour](#33-boutons-retour-sur-tous-les-écrans)
  - [3.4 Animations de transition](#34-animations-de-transition)
- [Conclusion](#conclusion-du-livrable-1)

---

Ce livrable documente le travail accompli lors de la première phase du projet DIAPALER AFRICA : la mise en place du projet Flutter, l'intégration de l'ensemble des interfaces utilisateur, et la construction du système de navigation. L'objectif était de passer d'une idée à une application fonctionnelle et navigable, avec un design cohérent pensé pour le contexte sénégalais et ouest-africain. Chaque choix technique présenté ici a été guidé par deux priorités : la fluidité de l'expérience utilisateur et la maintenabilité du code à long terme.

---

## 1. Création du projet Flutter

Cette première section détaille la fondation technique du projet : comment il a été nommé, quelles bibliothèques ont été sélectionnées et pourquoi, comment le code est organisé, et comment l'application démarre. Ces décisions structurent toute l'architecture de l'app.

### 1.1 Nom et identité

| Champ | Valeur |
|---|---|
| **Nom technique** | `diapaler_africa` |
| **Nom d'affichage** | DIAPALER AFRICA |
| **Version** | 0.1.0+1 |
| **Description** | Plateforme mobile de mentorat et de mise en relation entrepreneuriale au Sénégal |
| **SDK Flutter** | ≥ 3.5.0 |
| **Langage** | Dart 3 (null-safe) |

**DIAPALER** est un terme wolof signifiant "avancer ensemble" — un nom qui résume l'essence de la plateforme : personne ne réussit seul. Ce choix ancre l'application dans sa culture d'origine et la distingue immédiatement des solutions génériques importées. L'application cible l'écosystème entrepreneurial sénégalais et ouest-africain, en connectant entrepreneurs, mentors et investisseurs.

### 1.2 Dépendances installées (`pubspec.yaml`)

Chaque package a été choisi pour une raison précise. Firebase assure le backend en temps réel sans serveur à maintenir. `google_fonts` permet d'appliquer une typographie soignée sans aucun asset local. `geolocator` alimente le tri "Près de moi" avec un calcul de distance Haversine. `shared_preferences` garantit une session persistante même hors-ligne, et `http` suffit pour l'intégration du chatbot IA via l'API Groq, sans dépendance lourde à un SDK tiers. `file_picker` et `crop_image` permettent respectivement la sélection de fichiers depuis le gestionnaire de fichiers et le recadrage de photo avant sauvegarde.

```yaml
name: diapaler_africa
description: "DIAPALER AFRICA — Plateforme mobile de mentorat et de mise en relation entrepreneuriale au Sénégal."
version: 0.1.0+1
publish_to: 'none'

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8       # Icônes iOS (compatibilité cross-platform)
  google_fonts: ^6.2.1          # Typographies Google Fonts
  firebase_core: ^3.8.0         # Initialisation Firebase
  firebase_auth: ^5.3.4         # Authentification Firebase (email/password)
  firebase_database: ^11.1.7    # Base de données temps réel WebSocket
  shared_preferences: ^2.3.0    # Cache local (session persistante, mode hors-ligne)
  image_picker: ^1.1.0          # Photo de profil (galerie — ImagePicker)
  geolocator: ^11.0.0           # GPS et calcul de distances (Haversine)
  http: ^1.2.2                  # Requêtes HTTP vers l'API Groq (chatbot DIALI)
  share_plus: ^10.1.4           # Partage natif (WhatsApp, Facebook, Telegram, X, LinkedIn…)
  url_launcher: ^6.3.1          # Ouverture de liens externes (Wave, Play Store…)
  file_picker: ^8.1.0           # Sélection de fichiers image depuis le gestionnaire de fichiers
  crop_image: ^1.0.17           # Recadrage de photo (CropPhotoPage) avant sauvegarde

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0         # Règles qualité de code (23 règles activées)
```

> **📸 CAPTURE D'ÉCRAN — Fichier pubspec.yaml ouvert dans VS Code**
> *(Insérer ici la capture d'écran)*

---

### 1.3 Structure complète du projet

Nous avons adopté une séparation stricte entre les données (`data/`), la logique métier (`services/`), les interfaces (`screens/`) et les composants partagés (`widgets/`). Cette organisation — inspirée de l'architecture en couches — rend chaque partie du code indépendante et facilite la collaboration à plusieurs dans l'équipe. Par exemple, un développeur peut travailler sur un écran sans avoir besoin de connaître le détail d'un service Firebase.

```
diapaler_africa/
├── android/app/
│   ├── google-services.json             # Configuration Firebase Android
│   └── src/main/AndroidManifest.xml    # Permissions internet + GPS
├── lib/
│   ├── main.dart                        # Point d'entrée — init Firebase non-bloquante + runApp
│   ├── firebase_options.dart            # Clés Firebase (FlutterFire CLI)
│   ├── data/                            # Modèles de données (UserProfile, ChatMessage…)
│   │   ├── profil_utilisateur.dart
│   │   ├── donnees_mentors.dart         # 112 profils sénégalais (statiques)
│   │   ├── avis_statiques.dart          # Avis de démonstration (statiques)
│   │   ├── pays.dart
│   │   ├── citations.dart
│   │   └── interactions.dart
│   ├── screens/                         # 35 écrans (auth, dashboard, matching, chat…)
│   │   ├── page_demarrage.dart          # Splash + bootstrap Firebase
│   │   ├── coquille_principale.dart     # RootShell : IndexedStack 5 onglets + FAB
│   │   ├── page_accueil.dart            # Dashboard adaptatif (3 rôles)
│   │   ├── page_matching.dart           # Explorer + recherche + GPS
│   │   ├── page_messages.dart / page_chat.dart
│   │   ├── page_profil.dart / page_modification_profil.dart
│   │   ├── page_profil_public.dart      # Profil public consultable par tous
│   │   ├── page_pitch.dart / page_pitches_publics.dart
│   │   ├── page_detail_pitch.dart       # Détail complet d'un pitch (bottom sheet étendu)
│   │   ├── page_avis.dart               # Système d'avis et notation étoiles 1–5
│   │   ├── page_mes_pitchs_favoris.dart # Pitchs sauvegardés (bookmark — Investisseur)
│   │   ├── page_mes_pitchs.dart         # Mes pitchs publiés (Entrepreneur)
│   │   ├── page_mes_favoris.dart        # Profils mis en favori
│   │   ├── page_mes_mentors.dart        # Mes mentors actifs
│   │   └── … (19 autres écrans)
│   ├── services/                        # 17 services métier (auth, RTDB, GPS, cache…)
│   │   ├── service_geolocation.dart     # Distances GPS Haversine (tri "Près de moi" — Matching)
│   │   ├── service_geolocalisation.dart # Auto-détection ville + localité (Nominatim)
│   │   ├── service_pitch_favoris.dart   # Pitchs favoris (bookmark temps réel)
│   ├── theme/theme_app.dart             # Palette couleurs + ThemeData
│   └── widgets/                         # 13 composants réutilisables (avatar, nav, squelette…)
├── pubspec.yaml
└── analysis_options.yaml
```

> **📸 CAPTURE D'ÉCRAN — Structure du projet dans l'explorateur VS Code**
> *(Insérer ici la capture d'écran)*

---

### 1.4 Initialisation et lancement

**Point d'entrée `main.dart` — initialisation non-bloquante :**

Une particularité de l'architecture : Firebase est initialisé en **parallèle** du lancement de l'app, sans bloquer `runApp`. Le splash screen attend ce Future pendant son animation, masquant le délai d'initialisation à l'utilisateur.

```dart
// main.dart
// Firebase initialisé en top-level (non-bloquant) — le splash l'attend
// pendant son animation, masquant tout délai d'initialisation.
final Future<FirebaseApp> firebaseReady = Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const DiapalerApp()); // Lance immédiatement l'UI
}

class DiapalerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Note : le code réel enveloppe MaterialApp dans un CursorFollower (effet
    // curseur personnalisé web) et configure également un pageTransitionsTheme
    // global (_FadeThroughBuilder) dans AppTheme.light() / dark().
    return MaterialApp(
      title: 'DIAPALER AFRICA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashPage(), // Splash attend firebaseReady
    );
  }
}
```

**Bootstrap auth dans `page_demarrage.dart` :**

```dart
Future<void> _bootstrap() async {
  Widget next = const RoleSelectionPage();

  // 1. Cache local → affichage instantané, même hors-ligne
  final cached = await CacheService.loadProfile();
  if (cached != null) UserProfileController.update(cached);

  try {
    // 2. Attente Firebase (max 5 secondes)
    await firebaseReady.timeout(const Duration(seconds: 5));
    final uid = AuthService.currentUid;
    if (uid != null) {
      // 3. Lecture du profil Firebase (max 4 secondes)
      final remote = await DatabaseService.readUserProfile(uid)
          .timeout(const Duration(seconds: 4));
      if (remote != null) {
        UserProfileController.update(remote); // Écrase le cache
        next = const RootShell(); // Utilisateur déjà connecté
      }
    }
  } catch (_) {
    // Réseau indisponible → RoleSelectionPage (mode dégradé)
  }

  await Future.delayed(const Duration(milliseconds: 200));
  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: next),
      transitionDuration: const Duration(milliseconds: 350),
    ),
  );
}
```

**Commandes de lancement :**
```bash
flutter pub get        # Installation des dépendances
flutter run            # Lancement sur émulateur/appareil connecté
flutter run -d chrome  # Lancement sur navigateur web
flutter build apk      # Build APK Android release
```

> **📸 CAPTURE D'ÉCRAN — Application lancée sur émulateur Android / Chrome**
> *(Insérer ici la capture d'écran)*

---

## 2. Intégration des interfaces

Cette section présente les 35 écrans de l'application, du splash screen d'accueil jusqu'aux pages secondaires. Pour chaque écran, nous expliquons ce qu'il fait, ce que l'utilisateur y vit, et les décisions de design ou technique qui ont guidé son implémentation. L'ensemble est pensé pour être cohérent visuellement et adaptatif selon le rôle de l'utilisateur connecté.

### 2.1 Design System unifié

Toutes les interfaces partagent une **palette de couleurs commune** définie dans `theme_app.dart` :

```dart
class AppColors {
  // Couleurs primaires
  static const navy       = Color(0xFF0A234B); // Fonds navbars, boutons
  static const navyDeep   = Color(0xFF0F1729); // Textes, titres principaux
  static const blue       = Color(0xFF1E50A0); // Investisseurs, liens actifs
  static const blueBright = Color(0xFF3B82F6); // Bleu vif (liens, accents)
  static const blueTint   = Color(0xFFDCE6F5); // Fond chips par défaut
  static const amber      = Color(0xFFF59E0B); // Or sénégalais — CTAs, FAB
  static const amberSoft  = Color(0xFFFCD5A0); // Fond chips amber

  // Couleurs fonctionnelles
  static const green  = Color(0xFF10B981); // Succès, validations, mentors
  static const red    = Color(0xFFEF4444); // Erreurs, suppression
  static const purple = Color(0xFF8B5CF6); // Distance GPS

  // Neutres
  static const surface = Color(0xFFF8FAFC); // Fond général de l'appli
  static const card    = Colors.white;       // Fond des cartes
  static const fieldBg = Color(0xFFF3F4F6); // Fond des champs de saisie
  static const border  = Color(0xFFE5E7EB); // Bordures légères
  static const muted   = Color(0xFF6B7280); // Textes secondaires
  static const subtle  = Color(0xFF9CA3AF); // Icônes inactives

  // Couleurs des rôles (cercles d'avatar)
  static const roleEntrepreneur = Color(0xFFFB7185);
  static const roleMentor       = Color(0xFF22D3EE);
  static const roleInvestor     = Color(0xFFF59E0B);

  // Drapeau sénégalais
  static const flagGreen  = Color(0xFF00853F);
  static const flagYellow = Color(0xFFFDEF42);
  static const flagRed    = Color(0xFFE31B23);

  // Mode sombre
  static const darkSurface = Color(0xFF0B1220);
  static const darkCard    = Color(0xFF111827);
  static const darkBorder  = Color(0xFF1F2937);
  static const darkFieldBg = Color(0xFF1F2937);
  static const darkMuted   = Color(0xFF9CA3AF);
}
```

**Règles de design appliquées partout :**
- Border radius : 10–16 px systématiquement
- Ombres légères (boxShadow) sur toutes les cartes
- Animations fluides (`AnimatedContainer`, `AnimatedSwitcher`, `FadeTransition`)
- Skeleton loading pendant les appels Firebase (`squelette.dart`)
- `SafeArea` sur tous les écrans
- `HoverGlowCard` : effet amber glow + scale 1.015 au survol souris (mode web)

> **📸 CAPTURE D'ÉCRAN — Design System : palette de couleurs visible dans l'app**
> *(Insérer ici la capture d'écran)*

---

### 2.2 Écran de démarrage (Splash) — `page_demarrage.dart`

Le splash screen est la toute première chose que l'utilisateur voit. Son rôle est double : afficher l'identité visuelle de l'app pendant que Firebase s'initialise en arrière-plan, puis router automatiquement vers le bon écran selon que l'utilisateur est déjà connecté ou non. Nous avons voulu que cette attente soit une expérience, pas juste un chargement — d'où l'animation en trois orbites aux couleurs du drapeau sénégalais.

**Fonctionnalités :**
- Logo DIAPALER AFRICA animé : tile central scale 0.5→1.0, 3 orbites colorées (drapeau sénégalais) s'allumant en séquence
- Fond navy avec motif de points subtils (CustomPainter)
- Wordmark "DIAPALER AFRICA" + slogan slide-up animé
- Barre de progression linéaire amber (progression Firebase)
- Bootstrap : vérifie l'auth Firebase, charge le cache local, route vers RootShell ou RoleSelectionPage
- Durée : 1.1s minimum (animation) + attente Firebase

> **📸 CAPTURE D'ÉCRAN — Écran de démarrage (Splash Screen)**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Onboarding / Découverte — `page_decouverte.dart`

L'onboarding n'apparaît qu'une seule fois, juste après la création d'un compte. L'idée est d'accueillir le nouvel utilisateur en lui montrant en trois slides ce que l'app va lui apporter concrètement, avant qu'il ne plonge dans l'interface. Nous avons volontairement limité à trois slides pour ne pas lasser — les utilisateurs peuvent de toute façon sauter l'écran s'ils le souhaitent.

> ⚠️ **Cet écran apparaît uniquement après une inscription réussie** — pas au premier lancement. Les utilisateurs déjà connectés arrivent directement dans le RootShell (§2.7).

**Fonctionnalités :**
- 3 slides de présentation avec animations d'entrée, affichées après la création du compte
- Slide 1 : "Trouve ton mentor" — icône poignée de main bleue
- Slide 2 : "Dépose ton pitch" — icône upload amber
- Slide 3 : "DER/FJ à portée de main" — dispositifs de financement sénégalais
- Indicateurs de pagination animés (dots)
- Bouton "JE COMMENCE 🚀" sur la dernière slide → **RootShell** (app principale)
- Bouton "Passer" pour ignorer l'onboarding → **RootShell** (app principale)

> **📸 CAPTURE D'ÉCRAN — Écran d'Onboarding (slide 1)**
> *(Insérer ici la capture d'écran)*

---

### 2.4 Choix du rôle — `page_choix_role.dart`

La page de sélection du rôle est le premier vrai choix que l'utilisateur effectue dans l'application. Nous avons opté pour trois tuiles visuellement distinctes — couleur amber pour l'entrepreneur, vert pour le mentor, bleu pour l'investisseur — afin que chaque utilisateur puisse s'identifier immédiatement à son profil. Cette convention de couleurs est ensuite maintenue sur toute l'app, ce qui crée une cohérence visuelle immédiatement perceptible.

**Fonctionnalités :**
- 3 tuiles de rôle avec couleur et icône distinctives :
  - 🟡 **Entrepreneur** (amber) — "J'ai un projet, je cherche un mentor"
  - 🟢 **Mentor** (vert) — "Je partage mon expertise"
  - 🔵 **Investisseur** (bleu) — "Je finance des projets prometteurs"
- Sélection visuelle avec bordure et fond colorés
- Bouton "CONTINUER" → Inscription avec le rôle pré-sélectionné
- Lien "Déjà un compte ? Se connecter" → Connexion

> **📸 CAPTURE D'ÉCRAN — Écran de Choix du Rôle (3 tuiles)**
> *(Insérer ici la capture d'écran)*

---

### 2.5 Connexion — `page_connexion.dart`

L'écran de connexion est conçu pour être rassurant et rapide. L'en-tête reprend le gradient navy avec la bande drapeau sénégalais pour ancrer visuellement l'app dans son identité. Les messages d'erreur Firebase sont traduits en français naturel — par exemple "Mot de passe incorrect" plutôt qu'un code d'erreur technique — pour ne pas décourager un utilisateur peu à l'aise avec la technologie.

**Fonctionnalités :**
- En-tête : gradient navy avec logo DIAPALER + bande drapeau sénégalais
- Champ email (type email, autofill OS)
- Champ mot de passe (obscureText, bouton œil afficher/masquer)
- Lien "Mot de passe oublié ?" → `ForgotPasswordPage`
- Bandeau d'erreur rouge avec message humanisé (Firebase)
- Bouton "SE CONNECTER" : glow amber, CircularProgressIndicator pendant l'appel
- Lien "Pas encore de compte ? S'inscrire" → `SignUpPage`
- Après connexion : chargement du profil Firebase + redirection RootShell

> **📸 CAPTURE D'ÉCRAN — Écran de Connexion**
> *(Insérer ici la capture d'écran)*

---

### 2.6 Inscription 4 étapes — `page_inscription.dart`

L'inscription est découpée en quatre étapes pour ne jamais noyer l'utilisateur sous un long formulaire. Chaque étape est focalisée sur un thème précis (identité, localisation, profil pro, sécurité), et la progression est visible à tout moment grâce à la barre amber segmentée. Une attention particulière a été portée à l'internationalisation : le préfixe téléphonique s'adapte automatiquement au pays choisi, et la validation de longueur change en conséquence, ce qui évite les erreurs fréquentes lors de la saisie d'un numéro sénégalais, gambien ou malien.

**Fonctionnalités :**
- Barre de progression 4 segments animés (amber = complété, gris = à venir)
- Étape 1 — Identité : nom complet (prénom + nom obligatoires), email (regex), sexe (pills), date naissance (DatePicker)
- Étape 2 — Localisation : pays (dropdown Afrique de l'Ouest), ville (filtrée par pays), adresse
- Étape 3 — Profil pro : secteur d'activité (dropdown, **adapté selon le rôle** : "Secteur d'activité" / "Secteur principal" / "Secteur d'investissement"), photo (galerie, redimensionnée max 512×512 à l'inscription — upload Cloudinary avec fallback base64), biographie, LinkedIn, intérêts/domaines (chips multi-sélection, libellé adapté : "Centres d'intérêt" / "Domaines d'expertise" / "Secteurs d'intérêt") + années d'expérience (Mentor) + ticket d'investissement (Investisseur) + entreprises fondées/possédées — liste dynamique ajout/suppression (Mentor + Investisseur)
- Étape 4 — Sécurité : téléphone avec **préfixe dynamique** selon le pays (🇸🇳 +221 Sénégal · 🇬🇲 +220 Gambie · 🇲🇱 +223 Mali), validation longueur adaptée (9/7/8 chiffres), mot de passe (jauge de force 5 niveaux), confirmation, CGU
- Validation temps réel : icônes ✓/✗ colorées + messages d'aide sur chaque champ
- Bouton CONTINUER désactivé si étape invalide
- Transitions FadeTransition + SlideTransition entre étapes

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (Identité)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (Téléphone + Mot de passe + jauge)**
> *(Insérer ici la capture d'écran)*

---

### 2.7 Dashboard Entrepreneur — `page_accueil.dart`

Le dashboard entrepreneur est l'écran central de l'utilisateur porteur de projet. Il a été pensé comme un tableau de bord opérationnel : d'un seul coup d'oeil, l'entrepreneur voit l'état de son projet, ses statistiques clés, et les actions qu'il peut faire tout de suite. Un skeleton loading (`squelette.dart`) s'affiche pendant le rafraîchissement Firebase pour masquer les temps de chargement et donner une impression de réactivité immédiate.

**Fonctionnalités :**
- En-tête gradient navy (`_NavyHero`) : avatar amber + "Bonjour 🇸🇳 + Nom complet" + cloche notifications (badge rouge dynamique via `NotificationService.notifications`)
- Barre de recherche dans l'en-tête → **auto-focus sur le champ de recherche de `MatchingPage`** via `matchingFocusSearch` ValueNotifier (pas de rechargement de page)
- Skeleton loading (`squelette.dart`) pendant le rafraîchissement Firebase (`_refresh()`)
- `_ProjectHero` : si aucun projet → carte "Aucun projet en cours" → `PitchPage()` (nouveau projet) ; si projet existant → carte de progression avec barre animée (`TweenAnimationBuilder`) + bottom sheet 3 actions : "Modifier le projet" → `PitchPage(existingProject:)`, "Publier le pitch" → `_directPublish()`, "Supprimer"
- Section "Actions rapides" — grille 2×2 (`_QuickActionsGrid`) — **visible pour tous les rôles** :
  - "Trouver un mentor" → onglet Matching (`appTabIndex.value = 1`) avec filtre Mentor pré-activé
  - "Déposer un pitch" → `PitchPage`
  - "DER / FJ Orientation" → bottom sheet d'orientation financement DER/FJ
  - "CIS Investisseurs" → bottom sheet Club des Investisseurs du Sénégal
- `_StatsStrip` — bande horizontale scrollable avec pills interactives :
  - **Sessions → cliquable** : navigue vers l'onglet Agenda (`appTabIndex.value = 3`)
  - Pills non encore navigables → badge `soon` + opacité 0.6 (indicateur visuel)
  - Mentors actifs / Sessions / Score / Pitchs / Favoris (`AnimatedCounter`)
- Section "Mentors pour toi" (`_RecommendedMentors`) → cartes mentors filtrées par `recommendedMentorsFor()` (secteur + intérêts partagés) ; si aucune correspondance → message "Choisis tes centres d'intérêt"
- Pull-to-refresh (RefreshIndicator)

> **📸 CAPTURE D'ÉCRAN — Dashboard Entrepreneur**
> *(Insérer ici la capture d'écran)*

---

### 2.8 Dashboard Mentor — `page_dashboard_mentor.dart`

Le dashboard mentor met en avant ce qui compte pour un expert qui partage son temps : combien de personnes il accompagne, combien de sessions il a réalisées, et quels sont ses domaines d'intervention. La SliverAppBar permet à l'en-tête de disparaître progressivement au scroll, laissant plus de place au contenu sans alourdir l'interface.

**Fonctionnalités :**
- En-tête sticky (SliverAppBar) avec avatar vert + badge "Mentor"
- 3 cartes stats : Mentorés / Sessions / Années d'expérience
- Domaines d'expertise (chips vert clair)
- Bio complète
- Accès rapide : Demandes reçues, Mon Planning, Pitchs publiés (Messages et Agenda sont accessibles via les onglets de la barre de navigation principale)

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor**
> *(Insérer ici la capture d'écran)*

---

### 2.9 Dashboard Investisseur — `page_dashboard_investisseur.dart`

L'investisseur a des besoins différents des deux autres rôles : il cherche des opportunités, pas un mentor. Son dashboard est donc centré sur le flux des pitchs reçus et les entrepreneurs avec qui il est en contact. Les données sont chargées via StreamBuilder directement depuis Firebase, ce qui garantit que la liste des pitchs est toujours à jour sans nécessiter de rafraîchissement manuel.

**Fonctionnalités :**
- En-tête sticky avec avatar bleu + badge "Investisseur"
- 3 cartes stats : Opportunités / Entrepreneurs / Favoris
- Secteurs d'intérêt (chips bleu clair)
- Accès rapide : Explorer la communauté, Pitchs reçus (StreamBuilder) (Messages et Agenda accessibles via les onglets de la barre de navigation principale)

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur**
> *(Insérer ici la capture d'écran)*

---

### 2.10 Matching / Explorer — `page_matching.dart`

La page Matching est le coeur de la mise en relation. Un utilisateur peut y trouver un mentor, un investisseur ou un entrepreneur en quelques secondes grâce aux filtres combinables : texte libre, rôle, secteur, ville, et tri par distance GPS. Nous avons affiché en priorité les membres réels de DIAPALER (inscrits via l'app) par rapport aux 112 profils statiques de démonstration, pour encourager les vraies connexions entre utilisateurs.

**Fonctionnalités :**
- Barre de recherche textuelle (filtre en temps réel : nom, secteur, ville, tags)
- Bouton "Près de moi" : active le tri par distance GPS
- Pills filtre par rôle : Tous / Mentor / Investisseur (scrollables)
- Filtre par secteur : 10 secteurs sénégalais en pills
- Dropdown filtre par ville
- Compteur de profils : "N profil(s)"
- **Membres DIAPALER réels** (inscrits via l'app) affichés en tête de liste avec badge distinctif
- 112 profils sénégalais statiques en complément
- Tri automatique : membres réels en priorité, puis par compatibilité dynamique (intérêts partagés)
- État vide illustré si aucun résultat
- Bouton "Réinitialiser" si filtres actifs
- **Titre et contenu adaptés selon le rôle connecté** :
  - Entrepreneur → voit Mentors + Investisseurs
  - Mentor → titre "Mes Entrepreneurs", voit les Entrepreneurs
  - Investisseur → titre "Entrepreneurs à financer", voit les Entrepreneurs

> **📸 CAPTURE D'ÉCRAN — Écran Matching (liste de profils)**
> *(Insérer ici la capture d'écran)*

---

### 2.11 Détail d'un profil — `page_detail_mentor.dart`

Cet écran est celui où l'utilisateur décide s'il veut entrer en contact avec quelqu'un. Il doit donc contenir toutes les informations utiles : biographie, domaines, disponibilités, et les actions possibles selon le contexte. Une attention particulière a été portée à la cohérence : pour les profils de démonstration (sans UID Firebase), les disponibilités affichées sont explicitement marquées comme illustratives, afin de ne pas créer de confusion avec les vraies disponibilités des membres réels.

**Fonctionnalités :**
- Avatar grand format en en-tête
- Nom, rôle, secteur, ville, distance GPS
- Biographie : utilise `mentor.bio` si non vide (membres Firebase), sinon génère une bio avec le bon pronom selon `mentor.gender`
- Tags / domaines d'expertise (chips)
- Score, statistiques
- **Section "Disponibilités"** — widget `_AvailabilityPreview` :
  - Profils démo (uid vide) → badges "Exemple" (point gris) — données illustratives
  - Membres Firebase → vraies disponibilités lues en temps réel via `InteractionsService.getAvailability(mentor.uid)` (StreamBuilder)
  - Message "Disponibilités non encore configurées." si aucun créneau Firebase
- **Bouton d'action adapté selon le rôle du profil consulté** :
  - Membres Firebase réels → "Réserver une session" (Mentor) → `_BookingSheet` (calendrier Firebase réel) ; "Proposer un investissement" (Investisseur) → `_BookingSheet`
  - Profils statiques de démo (uid vide) → `SendRequestPage` (formulaire de demande)
  - Type `'investment'` pour les propositions d'investissement
- **Bouton "Message"** — ID de conversation généré avec `AuthService.currentUid` (UID Firebase, jamais l'email) pour cohérence avec `page_notifications.dart`
- Logique de communication stricte : chat disponible seulement après acceptation de la demande (`_checkRequestStatus()` bidirectionnel)

> **📸 CAPTURE D'ÉCRAN — Écran Détail d'un Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.12 Messagerie — `page_messages.dart` + `page_chat.dart`

La messagerie est organisée en deux onglets complémentaires : "Contacts" regroupe les personnes avec qui l'utilisateur a une relation acceptée, tandis que "Messages" liste toutes les conversations actives avec aperçu du dernier message. Ce choix évite de mélanger carnet d'adresses et historique de conversation. Le compteur de messages non lus est calculé localement depuis le stream des conversations Firebase.

**Fonctionnalités `page_messages.dart` :**

La page Messages est organisée en **2 onglets** :

**Onglet "Contacts" :**
- Liste des relations acceptées : mentor/mentoré ou investisseur/entrepreneur
- Searchable par nom
- Chip badge coloré indiquant le rôle du contact
- Tap → ouvre le chat direct avec ce contact

**Onglet "Messages" :**
- Liste de toutes les conversations existantes (StreamBuilder Firebase temps réel)
- Avatar, nom, dernier message, horodatage relatif
- Badge rouge de messages non lus par conversation
- Badge de messages non lus calculé depuis le stream des conversations (comptage local dans `_buildMessagesTab()`)
- Tap sur une conversation → `ChatPage` + marquage comme lu

**Fonctionnalités `page_chat.dart` :**
- Bulles de messages (envoyés : droite `AppColors.blue` / reçus : gauche gris clair)
- Champ de saisie + bouton envoi
- Horodatage sur chaque message
- Synchronisation temps réel Firebase (StreamBuilder)
- Marquage automatique comme lu à l'ouverture

> **📸 CAPTURE D'ÉCRAN — Écran Liste des Messages**
> *(Insérer ici la capture d'écran)*

---

### 2.13 Notifications — `page_notifications.dart`

Le centre de notifications regroupe tous les événements importants : demandes de mentorat reçues, sessions réservées, offres d'investissement, nouveaux messages. Chaque type de notification est reconnaissable visuellement (icône et couleur distinctes) et cliquable pour naviguer directement vers l'écran concerné. Les types critiques comme les offres d'investissement disposent même de boutons "Accepter / Refuser" directement dans la tuile, évitant à l'utilisateur de chercher où aller pour agir.

**Fonctionnalités :**
- Liste toutes les notifications triées par date décroissante (Firebase temps réel)
- Icône et couleur distinctes selon le type (string) : `mentor_request`, `session_booked`, `session_cancelled`, `message`…
- Horodatage relatif ("Il y a 5m", "Il y a 2h"…)
- Fond légèrement coloré pour les notifications non lues + point coloré
- **Navigation contextuelle au tap** selon le type de notification : `message` → onglet Messages, `session_booked` / `rdv_booked` / `session_cancelled` → onglet Agenda, `mentor_request` / `mentor_request_accepted` / `mentor_request_rejected` / `investment_offer` → page Demandes (`RequestsPage`)
- **Actions inline Accept/Décline** pour les types `investment_offer` et `session_request` : boutons "Accepter" / "Refuser" directement dans la tuile sans naviguer vers `RequestsPage`
- Bouton **"Effacer tout"** → supprime le nœud Firebase
- Badge rouge dynamique sur l'icône cloche (dans les dashboards)
- État vide illustré si aucune notification

> **📸 CAPTURE D'ÉCRAN — Centre de Notifications**
> *(Insérer ici la capture d'écran)*

---

### 2.14 Mon Profil — `page_profil.dart`

La page profil est la vitrine de l'utilisateur au sein de DIAPALER. La jauge de complétion 0–100% motive l'utilisateur à renseigner toutes ses informations pour maximiser sa visibilité dans le Matching.

**Structure de la page (allégée et rôle-adaptive) :**
- Carte identité : photo/initiales, nom, rôle, ville, barre de complétion 0–100% ; badge "Entrepreneur Premium" (amber) sous le rôle si `isPremium = true`
- Bandeau stats **adapté selon le rôle** (`_StatsStrip`) :
  - Entrepreneur : carte "Projets / pitch decks publiés" (`_EntrepreneurStatCard`)
  - Mentor : Note moy. (StreamBuilder Firebase) + Avis reçus + Années d'expérience
  - Investisseur : Note moy. (StreamBuilder Firebase) + Avis reçus
- Carte "À propos" : bio + **LinkedIn cliquable** (url_launcher) + chip "X ans d'expérience" (Mentor) + chip ticket d'investissement (Investisseur)
- Coordonnées condensées (3 colonnes) : email · téléphone · ville
- Centres d'intérêt (chips colorés)
- Bouton "Mes demandes" (**Entrepreneur uniquement**) → `RequestsPage` (demandes de mentorat et d'investissement envoyées/reçues)
- Bannière **"Passer Entrepreneur Premium"** (Entrepreneur non-abonné uniquement) → `WavePremiumSheet` (4 900 FCFA/mois via Wave) ; si déjà abonné : badge vert "Compte Entrepreneur Premium actif"
- AppBar : Partager · Modifier · Déconnexion (icône rouge)

> **📸 CAPTURE D'ÉCRAN — Mon Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.15 Modifier le profil — `page_modification_profil.dart`

L'écran de modification du profil pré-remplit automatiquement tous les champs avec les valeurs existantes, pour que l'utilisateur ne parte pas d'une page vide. Le bouton "SAUVEGARDER" reste grisé tant qu'aucune modification n'a été effectuée, ce qui évite les sauvegardes accidentelles. La sauvegarde est volontairement en deux temps — locale immédiate puis sync Firebase — pour que l'utilisateur voie le changement tout de suite même si la connexion est lente.

**Fonctionnalités :**
- Pré-remplissage de tous les champs avec les valeurs actuelles
 - Photo de profil : tap → bottom sheet (Galerie / Fichier). Les deux sources utilisent max 512×512. La sélection ouvre `CropPhotoPage` pour recadrer avant sauvegarde. À l'inscription l'image est uploadée vers Cloudinary (URL) avec fallback base64; la modification de profil enregistre le blob encodé en base64 dans Firebase.
- Modification : prénom, nom, téléphone, adresse, ville, pays, secteur, sexe, date naissance
- Biographie (280 caractères max avec compteur)
- LinkedIn
- Centres d'intérêt (chips multi-sélection)
- Années d'expérience (**Mentor uniquement**)
- Ticket d'investissement (**Investisseur uniquement**)
- **Bouton "Détecter ma position"** — appelle `LocationService.detectCity()` (GPS + Nominatim OSM) : pré-remplit automatiquement les dropdowns Pays + Ville **et** le champ Adresse avec la localité fine (quartier/suburb, ex : "Liberté 6"). Le SnackBar affiche le chemin complet à 3 niveaux : "Sénégal · Dakar · Liberté 6"
- Détection des changements (bouton SAUVEGARDER désactivé si rien n'a changé)
- Sauvegarde : mise à jour locale immédiate + cache local + sync Firebase
- SnackBar vert de confirmation

> **📸 CAPTURE D'ÉCRAN — Écran Modifier le Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.16 Déposer un Pitch — `page_pitch.dart`

`PitchPage` est la page unifiée de **création, édition et publication** d'un pitch. Elle couvre le cycle de vie complet du projet entrepreneur : démarrage depuis zéro, reprise à l'étape sauvegardée (mode édition), complétion progressive, et publication publique uniquement à l'étape 5.

**Fonctionnalités :**
- **Stepper 5 étapes** avec barre de progression amber
- **Validation obligatoire par étape** — bouton CONTINUER désactivé si champs invalides + message d'aide
- **Bouton "← Précédent"** visible à partir de l'étape 2 — retour libre vers toute étape précédente
- Étape 1 — Informations : Titre (min 3 chars, obligatoire) + elevator pitch
- Étape 2 — Détails : Secteur dropdown (obligatoire) + description détaillée (min 20 chars, obligatoire)
- Étape 3 — Financement : Montant FCFA (optionnel) + carte "Qui verra ton pitch ?"
- Étape 4 — Documents : Business Plan PDF (obligatoire) + Vidéo de présentation (obligatoire) + Deck (optionnel) — upload Cloudinary
- Étape 5 — Récapitulatif : vue synthèse + bouton "PUBLIER MON PITCH"
- **Sauvegarde progressive** : à chaque avancement (étapes 1–4), le projet est sauvegardé localement + Firebase avec `step` mis à jour
- **Mode édition** : si `existingProject` fourni, champs pré-remplis et stepper démarre à l'étape sauvegardée
- **Publication** : uniquement à l'étape 5 — écriture dans `pitches/` global (visible mentors/investisseurs) + `step = 5`, `published = true`
- Après publication : retour automatique vers l'**onglet Profil** (onglet 4)
- SnackBar "Pitch publié ! Retrouve-le dans ton profil → Mes projets"

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch (Étape 1)**
> *(Insérer ici la capture d'écran)*

---

### 2.17 Pitchs Publiés — `page_pitches_publics.dart`

Cette page est le fil d'actualité des opportunités pour les mentors et les investisseurs. Elle est conçue pour faciliter la découverte rapide : barre de recherche, pills de secteur générées dynamiquement depuis les vraies données Firebase, et un compteur de résultats qui se met à jour en temps réel. L'investisseur dispose en plus d'une icône bookmark pour sauvegarder les pitchs qui l'intéressent, et d'un bouton d'investissement direct sans quitter la page.

**Fonctionnalités (accessible Mentors + Investisseurs) :**
- StreamBuilder Firebase (données temps réel)
- Tri **premium d'abord** puis date décroissante — les pitchs d'entrepreneurs Premium apparaissent en tête de liste
- **Barre de recherche** : filtre en temps réel (titre, entrepreneur, secteur, description)
- **Pills de secteur** générées dynamiquement depuis les pitchs Firebase
- **Compteur** "X pitch(s)" mis à jour selon les filtres actifs
- **Bouton "Réinitialiser"** visible si un filtre est actif
- Chaque carte : avatar entrepreneur, nom, **badge ⭐ Premium** si entrepreneur abonné, secteur (chip amber), titre, description (3 lignes max), montant FCFA
- Bouton "Contacter →" → Messagerie
- **Icône bookmark 🔖** : sauvegarde le pitch dans `pitchFavorites/` Firebase (Investisseur uniquement) — feedback visuel instantané
- **Bouton "💰 Proposer un investissement"** visible uniquement pour les Investisseurs → crée un `MentorRequest` de type `'investment'` dans Firebase + notification automatique à l'entrepreneur
- Tap sur la carte → **`_PitchDetailSheet`** (bottom sheet `DraggableScrollableSheet`) : détails complets + actions
- État vide illustré si aucun pitch publié

> **📸 CAPTURE D'ÉCRAN — Liste des Pitchs Publiés**
> *(Insérer ici la capture d'écran)*

---

### 2.18 Autres écrans complémentaires

Au-delà des écrans principaux déjà présentés, l'application inclut un ensemble d'écrans secondaires qui complètent le parcours utilisateur et rendent l'expérience plus riche. Ces écrans couvrent des besoins spécifiques : gestion des disponibilités pour le mentor, chatbot IA, système d'avis, gestion des demandes, et agendas. Chacun est accessible depuis le bon endroit dans le flux principal.

**Mentors recommandés — `page_mentors_recommandes.dart`**
- Liste filtrée de mentors correspondant aux intérêts de l'entrepreneur

**Crop photo — `page_crop_photo.dart`**
- Recadrage interactif d'une photo de profil avant upload Cloudinary

**Agenda — `page_agenda.dart`**
- Titre et messages **adaptés selon le rôle** : "Mes sessions" (Entrepreneur) / "Mon agenda" (Mentor) / "Mes rendez-vous" (Investisseur)
- Sessions **à venir uniquement** depuis Firebase (pas de section "Passées" — pas de suivi de complétion en base)
- Bouton "Mon Planning" dans l'AppBar (Mentor uniquement)
- **Bouton "Annuler"** sur chaque session réservée : dialog de confirmation → `AgendaController.cancel()` bilatéral

**Planning — `page_planning.dart`**
- Gestion des disponibilités (Mentor)
- Créneaux horaires disponibles + synchronisation Firebase

**Demandes — `page_requests.dart`**
- Liste des demandes de mentorat reçues (StreamBuilder Firebase)
- Actions : accepter / refuser → notification déclenchée

**Envoyer une demande — `page_send_request.dart`**
- Formulaire d'envoi de demande à un mentor/investisseur
- Message personnalisé → sauvegarde dans Firebase (`mentorRequests/`)

**Chatbot DIALI IA — `page_chatbot.dart`**
- Interface de chat avec l'IA Llama 3.1 (Groq)
- Message de bienvenue personnalisé selon le rôle
- Bulles de messages (utilisateur / IA)
- Indicateur de frappe animé (3 points)
- Historique de conversation conservé pendant la session

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA**
> *(Insérer ici la capture d'écran)*

**Système d'Avis et Notation — `page_avis.dart`**
- Page dédiée aux avis laissés sur un profil (mentor, investisseur, entrepreneur)
- **Notation étoiles 1–5** : sélecteur interactif + calcul de la moyenne live Firebase
- **Accès restreint** : uniquement les membres connectés ayant une relation acceptée peuvent laisser un avis
- Lecture lecture seule sur son propre profil (`showLockedBanner: false`)
- Bannière "Demande requise" pour les membres sans relation établie
- StreamBuilder sur `reviews/{toUid}` — mises à jour en temps réel
- Affichage de la moyenne et du compteur d'avis sur les profils et dashboards

> **📸 CAPTURE D'ÉCRAN — Page Avis (liste des avis + sélecteur étoiles)**
> *(Insérer ici la capture d'écran)*

**Pitchs Sauvegardés (Favoris) — `page_mes_pitchs_favoris.dart`**
- Liste des pitchs bookmarkés par l'Investisseur
- Réactive : ValueNotifier mis à jour en temps réel via `PitchFavoriteService`
- Actions : consulter le pitch en détail, contacter l'entrepreneur, proposer un investissement
- État vide illustré si aucun pitch sauvegardé

> **📸 CAPTURE D'ÉCRAN — Pitchs Sauvegardés (liste des bookmarks)**
> *(Insérer ici la capture d'écran)*

**Profil Public — `page_profil_public.dart`**
- Consultation du profil d'un autre membre DIAPALER (vue lecture seule)
- Accessible depuis le Matching, les notifications, les messages
- Affiche : photo, nom, rôle, secteur, bio, stats, avis/notation
- Boutons d'action contextuels selon la relation existante

**Paramètres — `page_parametres.dart`**
- Accès aux paramètres de l'application
- Thème, notifications, confidentialité

---

### 2.19 Aide & Support — `page_aide.dart`

L'écran Aide & Support est le point d'entrée pour les utilisateurs qui recherchent de l'assistance ou des réponses aux questions fréquentes. Il est conçu pour être simple et intuitif, avec une bannière gradient et des accordéons FAQ expansibles.

**Fonctionnalités :**
- Bannière gradient (navy → blue) avec icône agent support et accroche "Comment pouvons-nous t'aider ?"
- **Section "Questions fréquentes"** — 8 accordéons `_FaqTile` expansibles avec animation de rotation :
  - "Comment envoyer une demande de mentorat ?" → Explication du flux depuis l'accueil
  - "Comment trouver un investisseur ?" → Filtre par rôle dans la liste des membres
  - "Comment publier un pitch ?" → Stepper 5 étapes depuis le dashboard
  - "Comment accepter ou refuser une demande ?" → Onglet Demandes du dashboard
  - "Comment fonctionne le système de notation ?" → Étoiles 1–5 après relation acceptée
  - "Comment modifier mon profil ?" → Onglet Profil → bouton d'édition
  - "Pourquoi ma demande n'apparaît-elle pas ?" → Connexion Firebase / relancer l'app
  - "Comment supprimer mon compte ?" → Paramètres → Supprimer mon compte
- **Section "Nous contacter"** :
  - Email support : `support@diapaler.sn` → tap copie dans le presse-papier + SnackBar
  - WhatsApp : `+221 77 000 00 00` → tap copie dans le presse-papier + SnackBar
  - Horaires : Lun – Ven, 8h – 18h (GMT) (non-cliquable)
- Footer : "Diapaler Africa · v1.0.0"

> **📸 CAPTURE D'ÉCRAN — Écran Aide & Support (FAQ)**
> *(Insérer ici la capture d'écran)*

---

### 2.20 Paramètres utilisateur — `page_parametres.dart`

La page Paramètres centralise les actions de gestion de compte et les informations de l'application. Elle est structurée en sections logiques.

**Fonctionnalités :**

**Section Compte :**
- "Changer le mot de passe" → dialog de confirmation → lien de réinitialisation envoyé à l'email connecté (SnackBar vert de confirmation)

**Section Application :**
- "Langue" (affichage fixe "Français")
- "Version" (affichage fixe "1.0.0")
- "Développé par" → sous-titre "BNKMTN (Barry, Niang, Kama, Mbodj, Tine, Ndiaye) L3GLSIB"

**Section Support :**
- "Aide & support" → `AidePage` (FAQ + contacts) — navigation via `rootNavigator`

**Section Données de démo** *(visible uniquement pour les comptes de développement)* **:**
- Bouton `_SeedButton` → réinitialise les données de démo Firebase

**Section Zone de danger :**
- "Supprimer mon compte" (rouge) → dialog d'avertissement → suppression Firebase complète + cache + déconnexion → retour `LoginPage`

> **📸 CAPTURE D'ÉCRAN — Écran Paramètres Utilisateur**
> *(Insérer ici la capture d'écran)*

---

## 3. Navigation entre les écrans

La navigation est la colonne vertébrale de l'application. Bien penser la navigation, c'est s'assurer que l'utilisateur trouve toujours ce qu'il cherche sans se perdre, et que les transitions entre les pages sont fluides et naturelles. Cette section explique comment les 35 écrans de DIAPALER sont reliés entre eux, du flux d'authentification jusqu'aux sous-pages les plus profondes.

### 3.1 Architecture de navigation à deux niveaux

Nous avons choisi une architecture à deux niveaux : une barre d'onglets fixe (`IndexedStack`, 5 onglets) pour les écrans principaux, et un `Navigator.push` pour les écrans de détail. Ce choix nous a permis de préserver l'état de chaque onglet lors des transitions — la position de scroll, les données chargées et les streams Firebase actifs restent intacts — ce qui améliore significativement la fluidité perçue par rapport à une approche `PageView`.

**Niveau 1 — Navigation principale (barre d'onglets) :**

```dart
// coquille_principale.dart — RootShell
class _RootShellState extends State<RootShell> {
  int _index = 0;

  // Les 5 pages principales (jamais recréées grâce à IndexedStack)
  static const _pages = <Widget>[
    HomePage(),      // Onglet 0 — Accueil / Dashboard
    MatchingPage(),  // Onglet 1 — Explorer la communauté
    MessagesPage(),  // Onglet 2 — Messages
    AgendaPage(),    // Onglet 3 — Agenda
    ProfilePage(),   // Onglet 4 — Mon Profil
  ];

  @override
  void initState() {
    super.initState();
    // Initialise les services avec l'UID Firebase
    final uid = AuthService.currentUid;
    if (uid != null) {
      AgendaController.load(uid);
      NotificationService.init(uid);
    }
    // Écoute le notifier global pour changer d'onglet depuis n'importe quel écran
    appTabIndex.addListener(_onTabIndexChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DiapalerBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
      floatingActionButton: _PulseFab(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
```

**`IndexedStack` vs `PageView` :**
`IndexedStack` est utilisé à la place de `PageView` pour **préserver l'état** de chaque onglet : la position de scroll, les données chargées, et les streams Firebase actifs ne sont jamais perdus lors d'un changement d'onglet.

**Navigation globale entre onglets :**
Un `ValueNotifier<int>` global (`appTabIndex` dans `service_navigation.dart`) permet à n'importe quel écran de changer l'onglet actif sans passer de callback en prop.

**Niveau 2 — Navigation modale (push/pop) :**
```dart
// Navigation vers un sous-écran
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const EditProfilePage()),
);

// Remplacement total de la pile (après connexion/déconnexion)
Navigator.of(context).pushAndRemoveUntil(
  PageRouteBuilder(
    pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const RootShell()),
    transitionDuration: const Duration(milliseconds: 350),
  ),
  (_) => false,
);
```

### 3.2 Flux de navigation complet

```
[Splash + Bootstrap]
  ├─→ [RootShell]          ← utilisateur déjà connecté
  └─→ [Choix du rôle]      ← non connecté
        ├─→ [Connexion] → [RootShell] | [Mot de passe oublié]
        └─→ [Inscription 4 étapes] → [Onboarding] → [RootShell]

[RootShell — 5 onglets IndexedStack]
  ├─ 0 : [Dashboard]  →  Pitch · Nouveau projet · Notifications · Demandes
  ├─ 1 : [Matching]   →  [Détail profil] → Demande | Chat
  ├─ 2 : [Messages]   →  [Chat individuel]
  ├─ 3 : [Agenda]     →  Planning (Mentor)
  ├─ 4 : [Mon Profil] →  [Modifier le profil]
  └─ FAB              →  [Chatbot DIALI IA]
```

### 3.3 Boutons retour sur tous les écrans

| Écran | Type de retour | Comportement |
|---|---|---|
| Connexion | Bouton back AppBar | `Navigator.maybePop()` |
| Inscription étape 1 | Bouton back | `Navigator.pop()` → Choix du rôle |
| Inscription étapes 2-4 | Bouton back | Retour à l'étape précédente |
| Pitch étape 1 | Bouton back | `Navigator.pop()` |
| Pitch étapes 2-3 | Bouton back | Retour à l'étape précédente |
| Modifier le profil | Bouton back | `Navigator.pop()` (si pas de modifications) |
| Détail mentor | Bouton back auto AppBar | `Navigator.pop()` |
| Chat | Bouton back auto AppBar | `Navigator.pop()` |
| Chatbot | Bouton back auto AppBar | `Navigator.pop()` |

### 3.4 Animations de transition

Deux niveaux d'animation : une transition globale `FadeTransition + SlideTransition` (léger glissement vers le haut, `Curves.easeOutCubic`) est appliquée à tous les changements de page via `PageTransitionsBuilder`. Entre les étapes des formulaires (inscription, pitch), un `AnimatedSwitcher` assure un fondu + glissement horizontal doux.

```dart
// Transition globale — main.dart
class _FadeThroughBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(route, context, animation, _, child) =>
    FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
}
```

> **📸 CAPTURE D'ÉCRAN — Barre de navigation 5 onglets avec badge Messages**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — FAB chatbot DIALI (bouton doré pulsant)**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 1

| Critère | Détail | Statut |
|---|---|---|
| Projet Flutter créé | Nom, version, 11 dépendances, structure complète | ✅ |
| Écran d'accueil | Dashboard adaptatif selon le rôle (3 variantes) | ✅ |
| Liste des éléments principaux | Matching (112 profils), Pitchs publiés, Messages | ✅ |
| Détail d'un élément | `page_detail_mentor.dart` — profil complet + actions | ✅ |
| Formulaire d'ajout/modification | Inscription (4 étapes), Pitch (5 étapes + bouton Précédent + sauvegarde progressive), Modifier profil | ✅ |
| Profil utilisateur | `page_profil.dart` avec jauge de complétion | ✅ |
| Navigation entre pages | 5 onglets IndexedStack + push/pop + FAB | ✅ |
| Boutons retour | Sur tous les écrans, multi-étapes pour les steppers | ✅ |
| Accès aux détails | `page_detail_mentor.dart` depuis `MatchingPage` | ✅ |
| Navigation fluide | IndexedStack, AnimatedSwitcher, `appTabIndex` global | ✅ |
| Bonus — 35 écrans | Bien au-delà du minimum requis (vs 26 attendus) | ✅ |
| Bonus — 17 services métier | Architecture professionnelle couche services (incl. `LocationService` + `GeolocationService`) | ✅ |
| Bonus — 13 widgets réutilisables | Composants partagés dans toute l'app | ✅ |
| Bonus — Matching rôle-adaptatif | Titre et contenu selon le rôle connecté | ✅ |
| Bonus — Système de Contacts | Onglet Contacts dans Messages (relations acceptées) | ✅ |
| Bonus — Flux investisseur | Proposer un investissement + acceptation + relation Contacts | ✅ |
| Bonus — Filtres pitchs | Barre de recherche + pills secteur dynamiques dans Pitchs Publiés | ✅ |
| Bonus — Annulation session | Bouton "Annuler" avec confirmation dans l'Agenda | ✅ |
| Bonus — Avis et notation | Système d'étoiles 1–5, moyenne live Firebase, accès restreint par relation | ✅ |
| Bonus — Pitchs Favoris | Bookmark investisseur, liste réactive ValueNotifier, Firebase temps réel | ✅ |
| Bonus — Recherche auto-focus | `matchingFocusSearch` ValueNotifier → focus instantané sans rechargement de page | ✅ |
| Bonus — Préfixe téléphone dynamique | 🇸🇳 +221 / 🇬🇲 +220 / 🇲🇱 +223, validation longueur adaptée par pays | ✅ |
| Bonus — Actions rapides tous rôles | `_QuickActionsGrid` visible pour Entrepreneur, Mentor et Investisseur | ✅ |

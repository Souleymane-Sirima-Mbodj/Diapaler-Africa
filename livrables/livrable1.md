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
- [3. Navigation entre les écrans](#3-navigation-entre-les-écrans)
  - [3.1 Architecture de navigation](#31-architecture-de-navigation-à-deux-niveaux)
  - [3.2 Flux de navigation complet](#32-flux-de-navigation-complet)
  - [3.3 Boutons retour](#33-boutons-retour-sur-tous-les-écrans)
  - [3.4 Animations de transition](#34-animations-de-transition)
- [Conclusion](#conclusion-du-livrable-1)

---

## 1. Création du projet Flutter

### 1.1 Nom et identité

| Champ | Valeur |
|---|---|
| **Nom technique** | `diapaler_africa` |
| **Nom d'affichage** | DIAPALER AFRICA |
| **Version** | 0.1.0+1 |
| **Description** | Plateforme mobile de mentorat et de mise en relation entrepreneuriale au Sénégal |
| **SDK Flutter** | ≥ 3.5.0 |
| **Langage** | Dart 3 (null-safe) |

**DIAPALER** est un terme wolof signifiant "avancer ensemble". L'application cible l'écosystème entrepreneurial sénégalais et ouest-africain, en connectant entrepreneurs, mentors et investisseurs.

### 1.2 Dépendances installées (`pubspec.yaml`)

```yaml
name: diapaler_africa
description: "DIAPALER AFRICA — Plateforme mobile de mentorat et de mise en relation entrepreneuriale au Sénégal."
version: 0.1.0+1

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
  image_picker: ^1.1.0          # Photo de profil (galerie/caméra)
  geolocator: ^11.0.0           # GPS et calcul de distances (Haversine)
  http: ^1.2.2                  # Requêtes HTTP vers l'API Anthropic (chatbot)
  share_plus: ^10.1.4           # Partage natif (WhatsApp, Facebook, Telegram, X, LinkedIn…)
  url_launcher: ^6.3.1          # Ouverture de liens externes (Wave, Play Store…)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0         # Règles qualité de code (23 règles activées)
```

> **📸 CAPTURE D'ÉCRAN — Fichier pubspec.yaml ouvert dans VS Code**
> *(Insérer ici la capture d'écran)*

---

### 1.3 Structure complète du projet

```
diapaler_africa/
├── android/
│   └── app/
│       ├── google-services.json         # Configuration Firebase Android
│       └── src/main/
│           └── AndroidManifest.xml      # Permissions internet + GPS
├── ios/
├── web/                                 # Cible Web (Chrome) pour le développement
├── lib/
│   ├── main.dart                        # Point d'entrée — init Firebase non-bloquante + runApp
│   ├── firebase_options.dart            # Clés Firebase (FlutterFire CLI)
│   │
│   ├── data/                            # Modèles de données (pur Dart, immuables)
│   │   ├── profil_utilisateur.dart      # UserProfile, Gender, Project + UserProfileController
│   │   ├── donnees_mentors.dart         # 100+ profils mentors sénégalais (données statiques)
│   │   ├── pays.dart                    # Pays + villes (Afrique de l'Ouest)
│   │   ├── citations.dart               # Citations d'entrepreneurs africains (carrousel)
│   │   └── interactions.dart            # MentorRequest, ChatMessage, Conversation, Availability
│   │
│   ├── screens/                         # 26 écrans
│   │   ├── page_demarrage.dart          # Splash animé + bootstrap Firebase + routage auth
│   │   ├── page_decouverte.dart         # Onboarding 3 slides (PageView)
│   │   ├── page_choix_role.dart         # Sélection du rôle (Entrepreneur/Mentor/Investisseur)
│   │   ├── page_connexion.dart          # Connexion email/password
│   │   ├── page_inscription.dart        # Inscription 4 étapes avec validations
│   │   ├── page_mot_de_passe_oublie.dart# Reset mot de passe via Firebase
│   │   ├── coquille_principale.dart     # RootShell : IndexedStack 5 onglets + FAB chatbot
│   │   ├── page_accueil.dart            # Dashboard adaptatif (Entrepreneur/Mentor/Investisseur)
│   │   ├── page_dashboard_mentor.dart   # Vue spécialisée Mentor
│   │   ├── page_dashboard_investisseur.dart # Vue spécialisée Investisseur
│   │   ├── page_matching.dart           # Explorer la communauté (recherche + filtres + GPS)
│   │   ├── page_detail_mentor.dart      # Profil détaillé + contacter + demande
│   │   ├── page_messages.dart           # Liste des conversations (StreamBuilder)
│   │   ├── page_chat.dart               # Chat individuel temps réel Firebase
│   │   ├── page_notifications.dart      # Centre de notifications + badge + "Effacer tout"
│   │   ├── page_profil.dart             # Mon profil + jauge de complétion
│   │   ├── page_modification_profil.dart# Modifier mon profil (photo + tous champs)
│   │   ├── page_pitch.dart              # Déposer un pitch (stepper 3 étapes)
│   │   ├── page_pitches_publics.dart    # Pitchs publiés (vue Mentor/Investisseur)
│   │   ├── page_nouveau_projet.dart     # Créer un nouveau projet
│   │   ├── page_mentors_recommandes.dart# Mentors recommandés (filtre par intérêts)
│   │   ├── page_agenda.dart             # Agenda + événements Firebase
│   │   ├── page_planning.dart           # Gestion des disponibilités (Mentor)
│   │   ├── page_requests.dart           # Demandes de mentorat reçues
│   │   ├── page_send_request.dart       # Envoyer une demande de mentorat
│   │   └── page_chatbot.dart            # Chatbot DIALI IA (Claude Anthropic)
│   │
│   ├── services/                        # Couche métier — séparation des préoccupations
│   │   ├── service_authentification.dart # Firebase Auth (connexion, inscription, reset, logout)
│   │   ├── service_base_de_donnees.dart  # Firebase RTDB : profils + pitchs
│   │   ├── service_interactions.dart     # RTDB : messages, conversations, demandes mentorat
│   │   ├── service_chatbot.dart          # API Anthropic Claude (HTTP REST)
│   │   ├── service_notifications.dart    # Notifications Firebase temps réel (ValueNotifier + StreamSubscription)
│   │   ├── service_agenda.dart           # Agenda Firebase (CRUD événements)
│   │   ├── service_geolocation.dart      # GPS + calcul distances (Haversine)
│   │   ├── service_cache.dart            # Cache local SharedPreferences (hors-ligne)
│   │   ├── service_navigation.dart       # appTabIndex + unreadMessagesCount (ValueNotifier)
│   │   ├── service_utilisateurs.dart     # Chargement des membres réels depuis Firebase
│   │   ├── service_partage.dart          # Partage social (share_plus) : pitch, profil, DIALI
│   │   └── service_wave.dart             # Paiement Premium Wave (lien marchand + url_launcher)
│   │
│   ├── theme/
│   │   └── theme_app.dart               # Palette couleurs, ThemeData, AppColors
│   │
│   └── widgets/                         # 13 composants réutilisables
│       ├── avatar.dart                  # Avatar (initiales colorées / photo base64)
│       ├── barre_navigation.dart        # Barre navigation 5 onglets + badge Messages
│       ├── bande_drapeau.dart           # Bandeau drapeau sénégalais (vert/jaune/rouge)
│       ├── carte_lumineuse.dart         # HoverGlowCard : carte avec glow amber au survol
│       ├── carte_mentor.dart            # MentorCard : carte profil + badge Investisseur/CIS
│       ├── carrousel_citations.dart     # Carrousel de citations africaines (auto-scroll)
│       ├── compteur_anime.dart          # AnimatedCounter : chiffres qui s'incrémentent
│       ├── curseur_suiveur.dart         # CursorFollower : animation curseur (web)
│       ├── entete_section.dart          # SectionHeader : titre + sous-titre de section
│       ├── feuille_profil.dart          # BottomSheet profil résumé (avatar, nom, stats)
│       ├── logo_diapaler.dart           # DiapalerLogoTile + DiapalerWordmark
│       ├── slogan_rotatif.dart          # Slogan animé rotatif (Timer)
│       └── squelette.dart              # SkeletonLoader : placeholder de chargement animé
│
├── test/
│   └── widget_test.dart                 # Tests unitaires
├── analysis_options.yaml                # Linting strict Flutter
└── pubspec.yaml
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

### 2.1 Design System unifié

Toutes les interfaces partagent une **palette de couleurs commune** définie dans `theme_app.dart` :

```dart
class AppColors {
  // Couleurs primaires
  static const navyDeep  = Color(0xFF0F1C4D); // Textes, titres principaux
  static const navy      = Color(0xFF1B2B6B); // Fonds navbars, boutons
  static const blue      = Color(0xFF2563EB); // Investisseurs, liens actifs
  static const amber     = Color(0xFFF5A623); // Or sénégalais — CTAs, FAB
  static const amberSoft = Color(0xFFFFF3DC); // Fond chips amber

  // Couleurs fonctionnelles
  static const green     = Color(0xFF10B981); // Succès, validations, mentors
  static const red       = Color(0xFFEF4444); // Erreurs, suppression
  static const purple    = Color(0xFF7C3AED); // Distance GPS

  // Neutres
  static const surface   = Color(0xFFF8F9FB); // Fond général de l'appli
  static const fieldBg   = Color(0xFFF1F3F7); // Fond des champs de saisie
  static const border    = Color(0xFFE2E8F0); // Bordures légères
  static const muted     = Color(0xFF94A3B8); // Textes secondaires
  static const subtle    = Color(0xFFCBD5E1); // Icônes inactives

  // Drapeau sénégalais
  static const flagGreen  = Color(0xFF00853F);
  static const flagYellow = Color(0xFFFCDD09);
  static const flagRed    = Color(0xFFE31B23);
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

**Fonctionnalités :**
- Logo DIAPALER AFRICA animé : tile central scale 0.5→1.0, 3 orbites colorées (drapeau sénégalais) s'allumant en séquence
- Fond navy avec motif de points subtils (CustomPainter)
- Wordmark "DIAPALER AFRICA" + slogan slide-up animé
- Barre de progression linéaire amber (progression Firebase)
- Bootstrap : vérifie l'auth Firebase, charge le cache local, route vers RootShell ou RoleSelectionPage
- Durée : 1.2s minimum (animation) + attente Firebase

> **📸 CAPTURE D'ÉCRAN — Écran de démarrage (Splash Screen)**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Onboarding / Découverte — `page_decouverte.dart`

> ⚠️ **Cet écran apparaît uniquement après une inscription réussie** — pas au premier lancement. Les utilisateurs déjà connectés arrivent directement dans le RootShell (§2.7).

**Fonctionnalités :**
- 3 slides de présentation avec animations d'entrée, affichées après la création du compte
- Slide 1 : "Trouve ton mentor" — icône poignée de main bleue
- Slide 2 : "Dépose ton pitch" — icône upload amber
- Slide 3 : "DER/FJ à portée de main" — dispositifs de financement sénégalais
- Indicateurs de pagination animés (dots)
- Bouton "COMMENCER" sur la dernière slide → **RootShell** (app principale)
- Bouton "Passer" pour ignorer l'onboarding → **RootShell** (app principale)

> **📸 CAPTURE D'ÉCRAN — Écran d'Onboarding (slide 1)**
> *(Insérer ici la capture d'écran)*

---

### 2.4 Choix du rôle — `page_choix_role.dart`

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

**Fonctionnalités :**
- Barre de progression 4 segments animés (amber = complété, gris = à venir)
- Étape 1 — Identité : nom complet (prénom + nom obligatoires), email (regex), sexe (pills), date naissance (DatePicker)
- Étape 2 — Localisation : pays (dropdown Afrique de l'Ouest), ville (filtrée par pays), adresse
- Étape 3 — Profil pro : secteur d'activité (dropdown, **adapté selon le rôle**), photo (galerie, redim 512×512, base64), biographie, LinkedIn, intérêts/domaines (chips multi-sélection) + années d'expérience (Mentor) + ticket d'investissement (Investisseur)
- Étape 4 — Sécurité : téléphone +221 auto-format, mot de passe (jauge de force 5 niveaux), confirmation, CGU
- Validation temps réel : icônes ✓/✗ colorées + messages d'aide sur chaque champ
- Bouton CONTINUER désactivé si étape invalide
- Transitions FadeTransition + SlideTransition entre étapes

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (Identité)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (Téléphone + Mot de passe + jauge)**
> *(Insérer ici la capture d'écran)*

---

### 2.7 Dashboard Entrepreneur — `page_accueil.dart`

**Fonctionnalités :**
- En-tête sticky (SliverAppBar) : avatar amber + "Bienvenue Prénom 👋" + cloche notifications + badge
- Skeleton loading (squelette.dart) pendant 900ms au démarrage
- 3 cartes de statistiques animées : Projets / Mentors actifs / Score
- Carrousel de citations d'entrepreneurs africains (auto-scroll Timer)
- Section "Mes projets" avec barre de progression par projet
- Section "Mentors recommandés" (scroll horizontal)
- Bouton "DÉPOSER UN PITCH" → `PitchPage`
- Bouton "TROUVER UN MENTOR" → `MatchingPage`
- Bouton "MES PROJETS" → `NewProjectPage`
- Pull-to-refresh (RefreshIndicator)

> **📸 CAPTURE D'ÉCRAN — Dashboard Entrepreneur**
> *(Insérer ici la capture d'écran)*

---

### 2.8 Dashboard Mentor — `page_dashboard_mentor.dart`

**Fonctionnalités :**
- En-tête sticky (SliverAppBar) avec avatar vert + badge "Mentor"
- 3 cartes stats : Mentorés actifs / Sessions / Score
- Domaines d'expertise (chips vert clair)
- Bio complète
- Accès rapide : Messages, Agenda, Demandes reçues, Mon Planning, Pitchs publiés

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor**
> *(Insérer ici la capture d'écran)*

---

### 2.9 Dashboard Investisseur — `page_dashboard_investisseur.dart`

**Fonctionnalités :**
- En-tête sticky avec avatar bleu + badge "Investisseur"
- 3 cartes stats : Opportunités / Entrepreneurs / Favoris
- Secteurs d'intérêt (chips bleu clair)
- Accès rapide : Explorer la communauté, Pitchs reçus (StreamBuilder), Messages, Mon Agenda

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur**
> *(Insérer ici la capture d'écran)*

---

### 2.10 Matching / Explorer — `page_matching.dart`

**Fonctionnalités :**
- Barre de recherche textuelle (filtre en temps réel : nom, secteur, ville, tags)
- Bouton "Près de moi" : active le tri par distance GPS
- Pills filtre par rôle : Tous / Mentor / Investisseur (scrollables)
- Filtre par secteur : 10 secteurs sénégalais en pills
- Dropdown filtre par ville
- Compteur de profils : "N profil(s)"
- **Membres DIAPALER réels** (inscrits via l'app) affichés en tête de liste avec badge distinctif
- 100+ profils sénégalais statiques en complément
- Tri automatique : membres réels en priorité, puis par compatibilité
- État vide illustré si aucun résultat
- Bouton "Réinitialiser" si filtres actifs

> **📸 CAPTURE D'ÉCRAN — Écran Matching (liste de profils)**
> *(Insérer ici la capture d'écran)*

---

### 2.11 Détail d'un profil — `page_detail_mentor.dart`

**Fonctionnalités :**
- Avatar grand format en en-tête
- Nom, rôle, secteur, ville, distance GPS
- Biographie complète
- Tags / domaines d'expertise (chips)
- Score, statistiques
- Bouton "Envoyer une demande" → `SendRequestPage` (demande de mentorat Firebase)
- Bouton "Contacter" → `ChatPage` (messagerie Firebase)

> **📸 CAPTURE D'ÉCRAN — Écran Détail d'un Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.12 Messagerie — `page_messages.dart` + `page_chat.dart`

**Fonctionnalités `page_messages.dart` :**
- Liste de toutes les conversations (StreamBuilder Firebase temps réel)
- Avatar, nom, dernier message, horodatage relatif
- Badge rouge de messages non lus par conversation
- Badge global sur l'onglet Messages (`unreadMessagesCount` ValueNotifier)
- Tap sur une conversation → `ChatPage` + marquage comme lu

**Fonctionnalités `page_chat.dart` :**
- Bulles de messages (envoyés : droite navy / reçus : gauche blanc)
- Champ de saisie + bouton envoi
- Horodatage sur chaque message
- Synchronisation temps réel Firebase (StreamBuilder)
- Marquage automatique comme lu à l'ouverture

> **📸 CAPTURE D'ÉCRAN — Écran Liste des Messages**
> *(Insérer ici la capture d'écran)*

---

### 2.13 Notifications — `page_notifications.dart`

**Fonctionnalités :**
- Liste toutes les notifications triées par date décroissante (Firebase temps réel)
- Icône et couleur distinctes selon le type (string) : `mentor_request`, `session_booked`, `session_cancelled`, `message`…
- Horodatage relatif ("Il y a 5m", "Il y a 2h"…)
- Fond légèrement coloré pour les notifications non lues + point coloré
- Bouton **"Effacer tout"** → supprime le nœud Firebase
- Badge rouge dynamique sur l'icône cloche (dans les dashboards)
- État vide illustré si aucune notification

> **📸 CAPTURE D'ÉCRAN — Centre de Notifications**
> *(Insérer ici la capture d'écran)*

---

### 2.14 Mon Profil — `page_profil.dart`

**Structure de la page (allégée et rôle-adaptive) :**
- Carte identité : photo/initiales, nom, rôle, ville, barre de complétion 0–100%
- Bandeau stats **adapté selon le rôle** :
  - Entrepreneur : Projets / Terminés / Mentors / Favoris
  - Mentor : Mentorés / Sessions / Années d'expé. / Favoris
  - Investisseur : Contacts / Pitchs vus / Favoris / Rendez-vous
- Carte "À propos" : bio + **LinkedIn cliquable** (url_launcher) + chip "X ans d'expérience" (Mentor) + chip ticket d'investissement (Investisseur)
- Coordonnées condensées (3 colonnes) : email · téléphone · ville
- Centres d'intérêt (chips colorés)
- Mes Projets avec barres de progression (**Entrepreneur uniquement**)
- Boutons d'actions **rôle-spécifiques** :
  - Entrepreneur → "Mes demandes" (envoyées)
  - Mentor → "Planning" + "Demandes reçues"
  - Investisseur → "Pitchs publiés"
- AppBar : Partager · Modifier · Déconnexion (icône rouge)

> **📸 CAPTURE D'ÉCRAN — Mon Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.15 Modifier le profil — `page_modification_profil.dart`

**Fonctionnalités :**
- Pré-remplissage de tous les champs avec les valeurs actuelles
- Photo de profil : tap → galerie/caméra → redimensionnement 512×512 → base64
- Modification : prénom, nom, téléphone, adresse, ville, pays, secteur, sexe, date naissance
- Biographie (240 caractères max avec compteur)
- LinkedIn
- Centres d'intérêt (chips multi-sélection)
- Détection des changements (bouton SAUVEGARDER désactivé si rien n'a changé)
- Sauvegarde : mise à jour locale immédiate + cache local + sync Firebase
- SnackBar vert de confirmation

> **📸 CAPTURE D'ÉCRAN — Écran Modifier le Profil**
> *(Insérer ici la capture d'écran)*

---

### 2.16 Déposer un Pitch — `page_pitch.dart`

**Fonctionnalités :**
- Stepper 3 étapes avec barre de progression amber
- **Validation obligatoire par étape** — bouton CONTINUER désactivé si champs vides
- Étape 1 : Titre du projet (min 3 chars, obligatoire) + elevator pitch
- Étape 2 : Secteur dropdown (obligatoire) + description détaillée (min 20 chars, obligatoire)
- Étape 3 : Montant financement FCFA (optionnel) + carte explicative "Qui verra ton pitch ?"
- Double sauvegarde : dans le profil (`projects/` — Étape **1/3**) ET dans `pitches/` Firebase (visible mentors/investisseurs)
- Après publication : navigation automatique vers l'**onglet Profil** → Mes projets
- SnackBar "Retrouve-le dans ton profil → Mes projets"

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch (Étape 1)**
> *(Insérer ici la capture d'écran)*

---

### 2.17 Pitchs Publiés — `page_pitches_publics.dart`

**Fonctionnalités (accessible Mentors + Investisseurs) :**
- StreamBuilder Firebase (données temps réel)
- Tri par date décroissante (plus récent en premier)
- Chaque carte : avatar entrepreneur, nom, secteur (chip amber), titre, description (3 lignes max), montant FCFA
- Bouton "Contacter →" → Messagerie
- État vide illustré si aucun pitch publié

> **📸 CAPTURE D'ÉCRAN — Liste des Pitchs Publiés**
> *(Insérer ici la capture d'écran)*

---

### 2.18 Autres écrans complémentaires

**Mentors recommandés — `page_mentors_recommandes.dart`**
- Liste filtrée de mentors correspondant aux intérêts de l'entrepreneur

**Nouveau projet — `page_nouveau_projet.dart`**
- Formulaire de création d'un projet (nom, description, secteur)
- Sauvegarde dans le profil entrepreneur + Firebase

**Agenda — `page_agenda.dart`**
- Titre et messages **adaptés selon le rôle** : "Mes sessions" (Entrepreneur) / "Mon agenda" (Mentor) / "Mes rendez-vous" (Investisseur)
- Sessions à venir + passées depuis Firebase
- Bouton "Mon Planning" dans l'AppBar (Mentor uniquement)

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
- Interface de chat avec l'IA Claude Anthropic
- Message de bienvenue personnalisé selon le rôle
- Bulles de messages (utilisateur / IA)
- Indicateur de frappe animé (3 points)
- Historique de conversation conservé pendant la session

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA**
> *(Insérer ici la capture d'écran)*

---

## 3. Navigation entre les écrans

### 3.1 Architecture de navigation à deux niveaux

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
[Splash + Bootstrap Firebase + Cache]
  ├─→ [RootShell] ← utilisateur déjà connecté (session persistante)
  └─→ [Choix du rôle] ← utilisateur non connecté (défaut)
        ├─→ [Connexion]
        │     ├─→ [RootShell] ← après connexion réussie
        │     ├─→ [Inscription] ← lien "S'inscrire"
        │     └─→ [Mot de passe oublié]
        └─→ [Inscription 4 étapes]
              └─→ [Onboarding 3 slides] ← affiché UNIQUEMENT après inscription
                    └─→ [RootShell]

[RootShell — 5 onglets IndexedStack]
  │
  ├── Onglet 0 : [Dashboard Entrepreneur / Mentor / Investisseur]
  │     ├─→ [Pitch (3 étapes)]
  │     ├─→ [Nouveau projet]
  │     ├─→ [Mentors recommandés]
  │     ├─→ [Notifications]
  │     ├─→ [Pitchs publiés] (mentors + investisseurs)
  │     ├─→ [Demandes reçues]
  │     ├─→ [Planning]
  │     └─→ [Feuille profil BottomSheet]
  │
  ├── Onglet 1 : [Matching / Explorer]
  │     └─→ [Détail du profil]
  │           ├─→ [Envoyer une demande]
  │           └─→ [Chat individuel]
  │
  ├── Onglet 2 : [Messages]
  │     └─→ [Chat individuel]
  │
  ├── Onglet 3 : [Agenda]
  │
  ├── Onglet 4 : [Mon Profil]
  │     └─→ [Modifier le profil] ← fullscreenDialog
  │
  └── FAB (tous les onglets) : [Chatbot DIALI IA]
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

**Transition globale `FadeThroughBuilder` :**
```dart
// main.dart — Transition Fade + Slide sur toutes les pages
class _FadeThroughBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(route, context, animation, _, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025), // Léger glissement vers le haut
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}
```

**Transition entre étapes de l'inscription :**
```dart
// AnimatedSwitcher avec fade + slide horizontal
AnimatedSwitcher(
  duration: const Duration(milliseconds: 280),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0), end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  ),
  child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
)
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
| Liste des éléments principaux | Matching (100+ profils), Pitchs publiés, Messages | ✅ |
| Détail d'un élément | `page_detail_mentor.dart` — profil complet + actions | ✅ |
| Formulaire d'ajout/modification | Inscription (4 étapes), Pitch (3 étapes), Modifier profil | ✅ |
| Profil utilisateur | `page_profil.dart` avec jauge de complétion | ✅ |
| Navigation entre pages | 5 onglets IndexedStack + push/pop + FAB | ✅ |
| Boutons retour | Sur tous les écrans, multi-étapes pour les steppers | ✅ |
| Accès aux détails | `page_detail_mentor.dart` depuis `MatchingPage` | ✅ |
| Navigation fluide | IndexedStack, AnimatedSwitcher, `appTabIndex` global | ✅ |
| Bonus — 26 écrans | Bien au-delà du minimum requis | ✅ |
| Bonus — 12 services métier | Architecture professionnelle couche services | ✅ |
| Bonus — 13 widgets réutilisables | Composants partagés dans toute l'app | ✅ |

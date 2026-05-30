---

&nbsp;

&nbsp;

&nbsp;

# ![Logo ESP]  École Supérieure Polytechnique de Dakar

&nbsp;

---

# DIAPALER AFRICA
## Plateforme mobile de mentorat entrepreneurial au Sénégal

&nbsp;

# LIVRABLE 6
## Rapport Final de Projet

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

> **📸 [Insérer ici le logo de l'ESP + une belle capture de l'application]**

&nbsp;

---

## Résumé exécutif

**DIAPALER AFRICA** est une application mobile Flutter connectant entrepreneurs, mentors et investisseurs au Sénégal. Elle intègre Firebase Authentication + Realtime Database (temps réel), un cache offline-first (`SharedPreferences`), la géolocalisation GPS, une messagerie instantanée, un système de notifications réactif, un chatbot d'intelligence artificielle propulsé par Llama 3.1 via Groq, et une gestion complète de profils avec synchronisation cloud. L'application compte **26 écrans**, **12 services**, **13 widgets réutilisables** et couvre l'ensemble des fonctionnalités du cahier des charges avec de nombreux bonus.

---

# LIVRABLE 6 — Rapport de Projet

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [1. Présentation du projet](#1-présentation-du-projet)
  - [1.1 Contexte et problématique](#11-contexte-et-problématique)
  - [1.2 Nom et concept](#12-nom-et-concept)
  - [1.3 Public cible et rôles](#13-public-cible-et-rôles)
  - [1.4 Fonctionnalités complètes](#14-fonctionnalités-complètes)
- [2. Choix Techniques](#2-choix-techniques)
  - [2.1 Framework — Flutter](#21-framework--flutter)
  - [2.2 Backend — Firebase](#22-backend--firebase-google)
  - [2.3 Intelligence Artificielle — Meta Llama 3.1 via Groq](#23-intelligence-artificielle--groq--llama-31)
  - [2.4 Dépendances et justifications](#24-dépendances-et-justifications)
  - [2.5 Architecture du code](#25-architecture-du-code)
- [3. Captures d'écran de l'application](#3-captures-décran-de-lapplication)
- [4. Difficultés rencontrées et solutions](#4-difficultés-rencontrées-et-solutions)
- [5. Solutions proposées et innovations](#5-solutions-proposées-et-innovations)
- [6. Qualité du code](#6-qualité-du-code)
- [7. Bilan du projet](#7-bilan-du-projet)
  - [7.1 Récapitulatif des livrables](#71-récapitulatif-des-livrables)
  - [7.2 Métriques du projet](#72-métriques-du-projet)
  - [7.3 Déploiement](#73-déploiement)
  - [7.4 Perspectives d'évolution](#74-perspectives-dévolution)
  - [7.5 Conclusion](#75-conclusion)

---

## 1. Présentation du projet

### 1.1 Contexte et problématique

Le Sénégal connaît une dynamique entrepreneuriale forte, portée par les programmes publics (DER/FJ, BNDE, FONGIP, FONSIS) et privés. Pourtant, les jeunes entrepreneurs se heurtent à trois obstacles majeurs :

1. **L'accès au mentorat** : trouver un expert disponible, dans son secteur, géographiquement proche, et prêt à s'investir est difficile — les circuits existants sont informels ou peu structurés.

2. **La mise en relation avec les investisseurs** : les circuits de financement formels sont lents, complexes et inaccessibles aux primo-entrepreneurs faute de réseau.

3. **La structuration et la visibilité du pitch** : présenter son projet de façon professionnelle et le rendre visible auprès des bonnes personnes nécessite des outils adaptés.

**DIAPALER AFRICA** répond à ces trois défis en une seule application mobile moderne, en s'appuyant sur Flutter, Firebase et l'intelligence artificielle.

> **📸 CAPTURE D'ÉCRAN — Écran d'accueil DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

---

### 1.2 Nom et concept

**DIAPALER** est un terme wolof signifiant **"avancer ensemble"** ou **"progresser collectivement"**. Ce nom reflète les valeurs fondamentales :
- La **solidarité** entre acteurs de l'écosystème entrepreneurial
- Le **progrès collectif** par le partage de compétences et d'opportunités
- L'**ancrage culturel** sénégalais (langue, couleurs du drapeau, contexte local)

**Éléments culturels intégrés dans l'application :**

| Élément | Description |
|---|---|
| `SenegalFlagStrip` | Bandeau vert-jaune-rouge sur les écrans d'auth |
| Citations | Entrepreneurs africains dans les dashboards |
| **DIALI** | Nom de l'IA (wolof : "aller de l'avant") |
| Géographie | 40+ villes sénégalaises dans les menus |
| Monnaie | Montants de financement en FCFA |
| Programmes | DER/FJ, BNDE, FONGIP dans le contexte IA |
| Téléphone | Préfixe +221 fixe avec auto-format sénégalais |

---

### 1.3 Public cible et rôles

| Rôle | Profil | Besoins clés |
|---|---|---|
| **Entrepreneur** | Porteur de projet, startup, PME | Trouver un mentor, pitcher son projet, créer/suivre ses projets |
| **Mentor** | Expert, cadre, consultant expérimenté | Partager son expertise, gérer ses mentorés, voir les pitchs |
| **Investisseur** | Business angel, fonds, HNWI | Découvrir des opportunités, évaluer des pitchs, contacter les porteurs |

Chaque rôle bénéficie d'un **dashboard personnalisé** avec des fonctionnalités et des statistiques adaptées.

> **📸 CAPTURE D'ÉCRAN — Écran de Choix du Rôle (3 cartes illustrées)**
> *(Insérer ici la capture d'écran)*

---

### 1.4 Fonctionnalités complètes

| Fonctionnalité | Description | Rôles |
|---|---|---|
| Authentification | Connexion, inscription **rôle-spécifique** (4 étapes), reset MDP, déconnexion → LoginPage | Tous |
| Sauvegarde MDP | `AutofillGroup` → Google/Samsung/iCloud Password Manager | Tous |
| Persistance session | Cache offline-first + bootstrap Firebase | Tous |
| Dashboards | **3 dashboards distincts** : Entrepreneur (amber) / Mentor (vert) / Investisseur (bleu) | Selon rôle |
| Matching | 100+ profils + membres DIAPALER réels + 4 filtres + GPS | Tous |
| Messagerie | Chat temps réel Firebase + badge non lus filtré (ne compte pas les messages envoyés) | Tous |
| Notifications | Centre + badge dynamique + "Effacer tout" | Tous |
| Profil | Stats rôle-spécifiques + LinkedIn cliquable + coordonnées condensées + boutons adaptatifs | Tous |
| Dépôt de pitch | Stepper 3 étapes avec **validation** + double sauvegarde + redirect Profil | Entrepreneur |
| Pitchs publiés | StreamBuilder temps réel + bouton partage | Mentor, Investisseur |
| Projets | Création + suivi progression (Étape 1/3) + suppression | Entrepreneur |
| Agenda | Titre/descriptions **rôle-spécifiques** + synchronisation Firebase | Tous |
| Planning | Gestion créneaux disponibles + bouton dans AppBar Agenda | Mentor |
| Demandes | Envoi + gestion (accepter/refuser) + bouton "Envoyer une demande" sur profil détail | Tous |
| Chatbot DIALI | Llama 3.1 8B (Groq) + proxy Cloudflare + FAB pulsant + messages d'erreur clairs | Tous |
| Géolocalisation | GPS + bouton "Près de moi" + distances km | Tous |
| Cache offline | Profil disponible sans internet (SharedPreferences) | Tous |
| Partage social | Pitchs, profils, conseils DIALI sur WhatsApp, Facebook, Telegram, X, LinkedIn | Tous |
| Paiement Premium | Abonnement Wave (3 plans) + badge ⭐ + activation Firebase immédiate | Tous |
| Bouton CIS | Bottom sheet informatif : Club des Investisseurs du Sénégal | Entrepreneur |

---

## 2. Choix Techniques

### 2.1 Framework — Flutter

| Critère | Détail |
|---|---|
| Multiplateforme | Un seul codebase → Android + iOS + Web |
| Performance | Compilation native AOT, 60fps garantis |
| Richesse UI | Material 3 + composants entièrement personnalisés |
| Intégration Firebase | FlutterFire officiel (firebase_core, firebase_auth, firebase_database) |
| Communauté | Large, documentation complète, support long terme |
| ESP Dakar | Technologie au programme du module |
| Null-safety | Dart 3 — toutes les variables et paramètres null-safe |

**Version :** Flutter SDK ≥ 3.5.0 · Dart 3 null-safe

> **📸 CAPTURE D'ÉCRAN — flutter --version dans le terminal**
> *(Insérer ici la capture d'écran)*

---

### 2.2 Backend — Firebase (Google)

**Justification :** Firebase est explicitement listé dans les backends acceptés par le sujet (Firebase, Laravel, Node.js, Spring Boot, Strapi).

| Service Firebase | Utilisation dans DIAPALER AFRICA |
|---|---|
| **Firebase Authentication** | Gestion des comptes (email/password), sessions, reset MDP |
| **Firebase Realtime Database** | Profils, pitchs, messages, conversations, demandes, agenda, disponibilités |

**Structure Firebase complète :**
```
diapaler-africa-default-rtdb/
├── users/          → profils utilisateurs (CRUD complet)
├── pitches/        → pitchs publiés (lecture globale)
├── messages/       → messages par conversation (WebSocket)
├── conversations/  → index des conversations (compteur non lus)
├── mentorRequests/ → demandes de mentorat (statut pending/accepted/rejected)
├── availability/   → créneaux disponibles (mentor)
├── bookedSessions/ → sessions réservées par utilisateur (CRUD bilatéral)
└── notifications/  → notifications in-app par utilisateur
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : projet DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : Realtime Database avec tous les nœuds**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Intelligence Artificielle — Meta Llama 3.1 via Groq

| Paramètre | Valeur |
|---|---|
| API | Groq Chat Completions API |
| Modèle | llama-3.1-8b-instant |
| Langue | Français (compréhension du wolof) |
| Accès | HTTP REST (package `http`) |
| Contexte | Entrepreneuriat sénégalais (DER/FJ, BNDE, FONGIP, FONSIS) |
| Historique | Conversation complète transmise à chaque appel |

**Justification :** Llama 3.1 8B via Groq est rapide (< 500ms de latence), **gratuit** (14 400 requêtes/jour) et produit des réponses contextualisées de haute qualité. Son support d'instructions système longues permet de configurer DIALI avec une personnalité précise ancrée dans l'écosystème sénégalais. Le modèle est servi par Groq (infrastructure LPU dédiée à l'inférence IA), via un proxy Cloudflare Worker qui garde la clé API côté serveur.

---

### 2.4 Dépendances et justifications

| Package | Version | Justification |
|---|---|---|
| `firebase_core` | ^3.8.0 | Initialisation Firebase obligatoire |
| `firebase_auth` | ^5.3.4 | Authentification email/password, sessions |
| `firebase_database` | ^11.1.7 | Base de données temps réel WebSocket |
| `google_fonts` | ^6.2.1 | Typographies Mulish/Plus Jakarta Sans |
| `image_picker` | ^1.1.0 | Photo profil depuis galerie ou caméra |
| `geolocator` | ^11.0.0 | GPS + distances Haversine intégrées |
| `http` | ^1.2.2 | Requêtes HTTP vers API Groq |
| `shared_preferences` | ^2.3.0 | Cache local profil (offline-first) |
| `share_plus` | ^10.1.4 | Partage natif (WhatsApp, Facebook, Telegram, X, LinkedIn) |
| `url_launcher` | ^6.3.1 | Ouverture de liens externes (paiement Wave, sites) |

---

### 2.5 Architecture du code

**Structure des dossiers :**
```
lib/
├── main.dart                     ← Point d'entrée + firebaseReady (non bloquant)
├── theme/
│   └── theme_app.dart            ← Couleurs, typographies, styles globaux
├── data/
│   ├── profil_utilisateur.dart   ← UserProfile, Project, UserProfileController
│   ├── donnees_mentors.dart      ← 100+ profils sénégalais pré-chargés
│   └── interactions.dart         ← MentorRequest, ChatMessage, Conversation, Availability
├── services/
│   ├── service_authentification.dart  ← Firebase Auth wrapper
│   ├── service_base_de_donnees.dart   ← Firebase DB : profils, pitchs, agenda
│   ├── service_interactions.dart      ← Messages, conversations, demandes, planning
│   ├── service_utilisateurs.dart      ← Découverte membres DIAPALER
│   ├── service_cache.dart             ← SharedPreferences offline-first
│   ├── service_chatbot.dart           ← API REST Groq (DIALI IA)
│   ├── service_geolocation.dart       ← GPS + distances villes sénégalaises
│   ├── service_navigation.dart        ← appTabIndex + unreadMessagesCount
│   ├── service_notifications.dart     ← Centre de notifications réactif
│   ├── service_agenda.dart            ← CRUD agenda Firebase
│   ├── service_partage.dart           ← Partage natif (share_plus) : pitch, profil, DIALI
│   └── service_wave.dart              ← Paiement Premium Wave (lien marchand + url_launcher)
├── screens/
│   ├── page_demarrage.dart            ← SplashPage + _bootstrap()
│   ├── page_choix_role.dart           ← Sélection Entrepreneur/Mentor/Investisseur
│   ├── page_decouverte.dart           ← Onboarding 3 slides
│   ├── page_connexion.dart            ← Connexion email/password
│   ├── page_inscription.dart          ← Inscription 4 étapes
│   ├── page_mot_de_passe_oublie.dart  ← Reset MDP
│   ├── coquille_principale.dart       ← RootShell : IndexedStack + FAB DIALI
│   ├── page_accueil.dart              ← Dashboard Entrepreneur
│   ├── page_dashboard_mentor.dart     ← Dashboard Mentor
│   ├── page_dashboard_investisseur.dart ← Dashboard Investisseur
│   ├── page_matching.dart             ← Matching + filtres + GPS
│   ├── page_detail_mentor.dart        ← Profil détaillé d'un mentor
│   ├── page_messages.dart             ← Liste des conversations
│   ├── page_chat.dart                 ← Chat individuel temps réel
│   ├── page_agenda.dart               ← Agenda Firebase
│   ├── page_planning.dart             ← Planning mentor
│   ├── page_profil.dart               ← Profil utilisateur
│   ├── page_modification_profil.dart  ← Modification profil
│   ├── page_pitch.dart                ← Dépôt de pitch (stepper 3 étapes)
│   ├── page_pitches_publics.dart      ← Pitchs publiés (StreamBuilder)
│   ├── page_notifications.dart        ← Centre de notifications
│   ├── page_chatbot.dart              ← DIALI IA
│   ├── page_requests.dart             ← Demandes de mentorat reçues
│   ├── page_send_request.dart         ← Envoi d'une demande
│   ├── page_mentors_recommandes.dart  ← Liste recommandations
│   └── page_nouveau_projet.dart       ← Création d'un nouveau projet
└── widgets/
    ├── carte_mentor.dart              ← MentorCard (Matching)
    ├── carte_lumineuse.dart           ← HoverGlowCard (carte réutilisable)
    ├── avatar.dart                    ← Avatar (photo ou initiales)
    ├── feuille_profil.dart            ← Bottom sheet profil
    ├── bande_drapeau.dart             ← SenegalFlagStrip (bandeau drapeau sénégalais)
    ├── logo_diapaler.dart             ← DiapalerLogoTile + DiapalerWordmark
    └── ...                            ← 7+ autres widgets réutilisables
```

**Pattern architectural : Services + ValueNotifier**

```
┌──────────────────────────────────────────────────────┐
│          UI Layer (Screens / Widgets)                  │
│  ValueListenableBuilder / StreamBuilder               │
├──────────────────────────────────────────────────────┤
│          State Layer                                   │
│  ValueNotifier<UserProfile>   (profil global)         │
│  ValueNotifier<int>           (unreadMessages, tab)   │
│  ValueNotifier<List<NotifItem>> (notifications)       │
├──────────────────────────────────────────────────────┤
│          Service Layer                                 │
│  AuthService / DatabaseService / InteractionsService  │
│  UsersService / ChatbotService / CacheService         │
│  NotificationService / GeolocationService             │
│  NavigationService / AgendaService                    │
├──────────────────────────────────────────────────────┤
│          Backend Layer                                 │
│  Firebase Auth / Firebase Realtime DB / Groq API │
│  SharedPreferences (cache local)                      │
└──────────────────────────────────────────────────────┘
```

**Principes appliqués :**
- **Séparation des préoccupations** : `screens/`, `services/`, `data/`, `widgets/`
- **Single Responsibility** : chaque service n'a qu'une responsabilité
- **DRY** : widgets réutilisables (`Avatar`, `HoverGlowCard`, `MentorCard`…)
- **Réactivité** : `ValueNotifier` + `ValueListenableBuilder` (zéro setState global)
- **Offline-first** : `CacheService` affiché instantanément avant la réponse Firebase
- **Null-safety** : code Dart 3 entièrement null-safe
- **Immutabilité** : `UserProfile` et `Project` sont `@immutable` + `copyWith()`

---

## 3. Captures d'écran de l'application

### 3.1 Flux d'authentification

> **📸 CAPTURE D'ÉCRAN — Splash Screen animé (logo + drapeau sénégalais)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Onboarding Slide 1 : "Trouve ton mentor"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Onboarding Slide 3 : "DER/FJ à portée de main"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Choix du Rôle (3 cartes Entrepreneur/Mentor/Investisseur)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Page de Connexion (gradient navy + glow amber)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (Identité + DatePicker)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (Téléphone + jauge de force MDP)**
> *(Insérer ici la capture d'écran)*

---

### 3.2 Dashboards

> **📸 CAPTURE D'ÉCRAN — Dashboard Entrepreneur (accueil personnalisé + stats)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor (mentorés + pitchs reçus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur (opportunités + secteurs)**
> *(Insérer ici la capture d'écran)*

---

### 3.3 Matching et profils

> **📸 CAPTURE D'ÉCRAN — Matching (liste avec filtres + distances GPS)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching avec filtre "Mentor" + secteur "FinTech" actifs**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bouton "Trié par distance ✓" actif (violet)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Détail d'un profil mentor (photo, bio, stats, secteurs)**
> *(Insérer ici la capture d'écran)*

---

### 3.4 Pitchs

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch Étape 1 (titre + secteur)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch Étape 3 (montant + validation)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — SnackBar "🎉 Pitch publié !" après soumission**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Pitchs Publiés (vue Mentor/Investisseur — StreamBuilder)**
> *(Insérer ici la capture d'écran)*

---

### 3.5 Profil utilisateur

> **📸 CAPTURE D'ÉCRAN — Mon Profil (photo + badge rôle + jauge de complétion)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Modifier le Profil (formulaire pré-rempli)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — BottomSheet sélection photo (galerie / caméra)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bottom sheet profil (résumé + actions rapides)**
> *(Insérer ici la capture d'écran)*

---

### 3.6 Communications

> **📸 CAPTURE D'ÉCRAN — Messagerie (liste des conversations + badge non lus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Chat individuel (bulles + horodatage + temps réel)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Centre de Notifications (types colorés + badge + Effacer tout)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Badge rouge sur l'onglet Messages (NavBar)**
> *(Insérer ici la capture d'écran)*

---

### 3.7 Fonctionnalités avancées

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA (conversation active)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — FAB DIALI pulsant (anneau amber animé)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Agenda (liste des événements + types colorés)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Planning mentor (créneaux disponibles)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Demandes de mentorat (liste + Accepter/Refuser)**
> *(Insérer ici la capture d'écran)*

---

## 4. Difficultés rencontrées et solutions

### 4.1 Crash au démarrage — Configuration Firebase Android

**Problème :**
```
java.lang.ClassNotFoundException:
com.google.firebase.components.ComponentDiscoveryService
```
L'application crashait immédiatement au démarrage sur Android.

**Cause :** Le SDK Firebase Realtime Database nécessite des déclarations de services natifs dans `AndroidManifest.xml`.

**Solution :**
```xml
<service android:name="com.google.firebase.components.ComponentDiscoveryService"
    android:exported="false">
  <meta-data
    android:name="com.google.firebase.components:com.google.firebase.database.DatabaseRegistrar"
    android:value="com.google.firebase.components.ComponentRegistrar"/>
</service>
```

---

### 4.2 Pitchs non sauvegardés dans Firebase

**Problème :** L'entrepreneur voyait le SnackBar "Pitch publié !" mais aucun pitch n'apparaissait dans la vue des mentors/investisseurs.

**Cause :** La méthode `_next()` dans `page_pitch.dart` affichait le message de succès et fermait l'écran **sans appeler aucune méthode Firebase**.

```dart
// Code défaillant
void _next() {
  if (_step < _total - 1) { setState(() => _step++); return; }
  Navigator.of(context).pop();  // ← Fermait sans rien sauvegarder !
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pitch déposé !')));
}
```

**Solution :** Réécriture en `Future<void>` avec double sauvegarde :
```dart
Future<void> _next() async {
  if (_step < _total - 1) { setState(() => _step++); return; }
  setState(() => _loading = true);
  try {
    final project = Project(id: DateTime.now().ms.toString(), ...);
    final updated = profile.copyWith(projects: [...profile.projects, project]);
    UserProfileController.update(updated);           // Profil entrepreneur
    await DatabaseService.publishPitch(...);         // Nœud global pitches/
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Pitch publié !'),
          backgroundColor: AppColors.green));
  } catch (_) { /* gestion erreur */ }
  finally { setState(() => _loading = false); }
}
```

---

### 4.3 Erreur de cast Firebase — `type 'List<Object?>' is not a subtype of type 'Map<String, dynamic>'`

**Problème :** L'application plantait lors de la lecture des profils ou des intérêts depuis Firebase Realtime Database avec l'erreur :
```
type 'List<Object?>' is not a subtype of type 'Map<String, dynamic>'
```

**Cause :** Firebase Realtime Database ne conserve pas les types Dart. Quand un tableau JSON (`["Tech", "Mode"]`) est stocké, il peut être retourné comme une `List<Object?>` au lieu d'une `Map`. De plus, les entiers stockés comme clés de Map arrivent parfois comme `int` au lieu de `String`.

**Solution :** Désérialisation défensive avec vérifications de type :
```dart
// Gestion sécurisée des listes (peuvent arriver comme List OU comme Map)
final rawInterests = m['interests'];
final interests = <String>[];
if (rawInterests is List) {
  for (final v in rawInterests) interests.add(v.toString());
} else if (rawInterests is Map) {
  for (final v in rawInterests.values) interests.add(v.toString());
}

// Cast toujours explicite pour les Maps Firebase
final raw = Map<String, dynamic>.from(snap.value as Map);
```

---

### 4.4 Session non restaurée après rechargement de page (Flutter Web)

**Problème :** Sur Flutter Web (CanvasKit), après un rechargement de page (`F5`), l'application redirige vers `RoleSelectionPage` même si l'utilisateur était connecté.

**Cause :** `FirebaseAuth.instance.currentUser` est synchrone mais sur le web, Firebase Auth doit d'abord restaurer la session depuis IndexedDB (opération asynchrone). Au moment où `_bootstrap()` s'exécute, `currentUser` est encore `null`.

**Atténuation :** Utilisation d'un timeout de 5 secondes sur `firebaseReady` et mise en cache du profil (`CacheService`) pour afficher les données même sans session active :
```dart
// Si Firebase n'a pas encore restauré la session après 5s,
// le cache local assure la continuité de l'expérience utilisateur
await firebaseReady.timeout(const Duration(seconds: 5));
final uid = AuthService.currentUid; // Peut être null sur web au premier chargement
```

> Note : Ce comportement est propre à Flutter Web. Sur Android/iOS natif, `currentUser` est disponible immédiatement après `Firebase.initializeApp()`.

---

### 4.5 Overflow sur petits écrans (filtres Matching)

**Problème :**
```
RenderFlex overflowed by 32 pixels on the right.
```
Les pills de filtre dépassaient la largeur de l'écran sur les téléphones ≤ 360dp.

**Solution :** `SingleChildScrollView(scrollDirection: Axis.horizontal)` :
```dart
// Avant : Row fixe → overflow
Row(children: [...pills...])

// Après : Row scrollable horizontalement
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
  child: Row(children: [...pills...]),
)
```

---

### 4.6 Header qui disparaît lors du scroll

**Problème :** Sur les dashboards, l'en-tête (avatar + nom + cloche) disparaissait lors du scroll, forçant l'utilisateur à remonter pour accéder aux notifications.

**Solution :** `CustomScrollView` + `SliverAppBar(pinned: true)` :
```dart
// Avant : ListView simple → header disparaît
ListView(children: [header, ...content...])

// Après : SliverAppBar collant en haut
CustomScrollView(
  slivers: [
    SliverAppBar(pinned: true, toolbarHeight: 68, title: header),
    SliverPadding(sliver: SliverList(delegate: ...content...)),
  ],
)
```

---

### 4.7 Perte d'état entre les onglets

**Problème :** Changer d'onglet et revenir perdait la position de scroll, les données chargées et déclenchait des appels Firebase redondants.

**Cause :** `PageView` recrée les widgets à chaque changement d'onglet (lazy rebuilding).

**Solution :** `IndexedStack` maintient tous les onglets en mémoire simultanément :
```dart
// Avant — PageView recrée les widgets
PageView(children: _pages)

// Après — IndexedStack préserve tous les états
IndexedStack(index: _tab, children: _pages)
```

---

### 4.8 DatePicker — `helpText` tronqué dans le dialog

**Problème :** Le texte `'Ta date de naissance'` (18 caractères) était tronqué à `'Ta date de naissanc...'` dans l'en-tête du `DatePickerDialog` sur les petits écrans.

**Solution :** Raccourcir le texte à 16 caractères maximum :
```dart
// Avant (tronqué)
helpText: 'Ta date de naissance',

// Après (affiché entièrement)
helpText: 'Date de naissance',
```

---

### 4.9 FAB / Badge de carte overlap dans le Matching

**Problème :** Le FAB du chatbot DIALI (56dp + 16dp de marge = 72dp depuis le bord droit) **chevauchait** le badge de rôle (Investisseur/Mentor) affiché en haut-droite des cartes Matching, rendant le badge illisible.

**Calcul :**
- FAB bord gauche = 72dp depuis le bord droit de l'écran
- Padding liste = 20dp | Padding carte = 14dp → contenu à 34dp du bord droit
- Overlap = 72 - 34 = **38dp de chevauchement**

**Solution :** Augmenter le padding droit de la liste de 20dp à 76dp :
```dart
// Avant — overlap avec le FAB
padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),

// Après — 76dp > 72dp (FAB) → badge toujours visible
padding: const EdgeInsets.fromLTRB(20, 4, 76, 90),
```

---

### 4.10 Inscription non rôle-spécifique

**Problème :** L'inscription affichait exactement les mêmes champs pour les 3 rôles. Un Mentor n'avait pas de champ "Années d'expérience", un Investisseur pas de "Ticket d'investissement". Le secteur n'était jamais collecté (`sector: 'Autre'` hardcodé).

**Solution :** Ajout conditionnel dans l'étape 3 :
- Dropdown secteur (tous les rôles, obligatoire)
- Champ "Années d'expérience" visible uniquement si `role == Mentor`
- Champ "Ticket d'investissement" visible uniquement si `role == Investisseur`

---

### 4.11 Badge non lu déclenché par l'expéditeur lui-même

**Problème :** Quand un utilisateur envoyait un message, son propre badge "messages non lus" s'incrémentait, créant une fausse alerte.

**Cause :** `unreadCount` dans `Conversation` était toujours incrémenté sans distinguer l'expéditeur du destinataire.

**Solution :** Ajout du champ `lastSenderId` dans `Conversation`. Le badge ne compte que les conversations où `c.lastSenderId != currentUid`.

---

### 4.12 Page pitch — faux uploads et absence de validation

**Problème :** (1) Les tuiles "Pitch deck PDF" et "Vidéo" basculaient en "Fichier ajouté ✓" au simple tap, sans aucun fichier réel sélectionné. (2) L'utilisateur pouvait passer les étapes sans remplir les champs obligatoires.

**Solution :** Suppression des fausses tuiles d'upload. Ajout de validations par étape (`_step0Valid`, `_step1Valid`) avec bouton CONTINUER désactivé et message d'aide. `totalSteps` corrigé à 3 au lieu de 5.

---

### 4.13 Bio et pronoms incorrects sur les profils statiques

**Problème :** La page détail d'un mentor affichait une bio générique hardcodée avec "il/elle" pour tous les profils, ignorant la vraie bio Firebase et le genre de la personne.

**Solution :** Utilisation de `mentor.bio` si non vide (membres Firebase), sinon génération automatique d'une bio avec le bon pronom selon `mentor.gender` (il / elle / il·elle).

---

### 4.14 Déconnexion — redirection incorrecte

**Problème :** La déconnexion renvoyait vers la page de choix du rôle (`RoleSelectionPage`) au lieu de la page de connexion (`LoginPage`).

**Solution :** Changement de la destination dans `_LogoutButton.confirmAndLogout()` et `feuille_profil.dart` : `const LoginPage()` à la place de `const RoleSelectionPage()`.

---

## 5. Solutions proposées et innovations

### 5.1 Réactivité globale sans state management externe

**Innovation :** Au lieu d'un package de state management (Provider, Riverpod, Bloc, GetX), DIAPALER AFRICA utilise le duo natif Flutter `ValueNotifier<T>` + `ValueListenableBuilder<T>`.

**Architecture :**
```
UserProfileController.update(p)
    ├─→ ValueNotifier → rebuild immédiat (UI)
    ├─→ CacheService.saveProfile() → offline-first
    └─→ DatabaseService.updateUserProfile() → cloud (async)
```

**Avantages :**
- Zéro dépendance externe pour le state management
- Code simple, lisible, testable
- Mise à jour < 1ms sur tous les écrans simultanément
- Compatible `StatelessWidget` (pas de `StatefulWidget` requis)

---

### 5.2 Bootstrap offline-first avec cache `SharedPreferences`

**Innovation :** Au lieu d'attendre Firebase (200-800ms), l'application affiche instantanément le profil du dernier utilisateur depuis `SharedPreferences` puis remplace les données par les données Firebase fraîches dès qu'elles arrivent.

```
Démarrage app   → Cache local (< 5ms) → UI instantanée
                → Firebase (200-800ms) → Mise à jour silencieuse
```

---

### 5.3 Double sauvegarde des pitchs

**Innovation :** Chaque pitch est sauvegardé à **deux endroits** simultanément :
- `users/{uid}/projects/` → pour le portfolio de l'entrepreneur
- `pitches/{id}/` → nœud global lisible par tous (mentors + investisseurs)

Cela permet la **visibilité croisée** sans exposer les données privées du profil.

---

### 5.4 Personnalisation culturelle sénégalaise

- Widget `SenegalFlagStrip` réutilisable sur tous les écrans d'auth
- DIALI IA avec contexte DER/FJ, BNDE, FONGIP, FONSIS dans le system prompt
- 40+ villes sénégalaises dans la géolocalisation avec coordonnées GPS précises
- Auto-format téléphone +221 XX XXX XX XX
- Montants en FCFA dans les pitchs

---

### 5.5 Badge non lus temps réel via ValueNotifier global

**Innovation :** Le badge de messages non lus sur la NavBar se met à jour en temps réel grâce à un `ValueNotifier<int>` global (`unreadMessagesCount`) dans `service_navigation.dart`. La `MessagesPage` écoute le stream Firebase des conversations et met à jour ce compteur global, même quand l'utilisateur est sur un autre onglet.

---

## 6. Qualité du code

### 6.1 Conventions de nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | `snake_case.dart` | `page_inscription.dart` |
| Classes | `PascalCase` | `UserProfileController` |
| Variables/méthodes | `camelCase` | `_loadingMembers`, `_toggleNearMe()` |
| Constantes | `camelCase` ou `SCREAMING_SNAKE_CASE` | `_profileKey`, `_topSectors` |
| Widgets privés | Préfixe `_` | `_PulseFab`, `_CityDropdown` |

### 6.2 Bonnes pratiques appliquées

- **`@immutable`** sur `UserProfile` et `Project` — immutabilité garantie
- **`copyWith()`** sur tous les modèles — mutation sans référence partagée
- **`mounted` check** avant tout `setState()` après un `await` — pas de leak
- **`dispose()`** systématique sur les `TextEditingController`, `AnimationController`, `ScrollController`
- **`try/catch/finally`** autour de tous les appels Firebase et HTTP
- **`const` constructor** partout où applicable — performance Flutter
- **Séparation services/UI** stricte — aucun appel Firebase dans les widgets

### 6.3 Gestion des erreurs

| Niveau | Mécanisme |
|---|---|
| Auth Firebase | `AuthService.humanError()` — 8 codes d'erreur humanisés |
| Réseau | `timeout(Duration(seconds: 4-5))` sur tous les appels Firebase |
| Cache | `try/catch` silencieux — le cache ne bloque jamais l'app |
| Firebase | `catchError()` sur `_syncToFirebase()` — sync non bloquante |
| Chatbot | Fallback message si l'API Groq est indisponible |

---

## 7. Bilan du projet

### 7.1 Récapitulatif des livrables

| Livrable | Contenu | Fonctionnalités clés | Statut |
|---|---|---|---|
| **L1** | Architecture Flutter + Navigation | 26 écrans, IndexedStack, ValueNotifier | ✅ Complet |
| **L2** | Consommation API | Firebase CRUD + Interactions + Groq REST | ✅ Complet |
| **L3** | Authentification | Connexion, Inscription 4 étapes, Reset, Cache session | ✅ Complet |
| **L4** | Gestion de profil | Modification + Photo + Projets CRUD + UsersService | ✅ Complet |
| **L5** | Fonctionnalités avancées | Notifs + Filtres + GPS + DIALI IA + Messagerie | ✅ Complet |
| **L6** | Rapport final | Ce document | ✅ Complet |

---

### 7.2 Métriques du projet

| Indicateur | Valeur |
|---|---|
| Lignes de code Dart | ~10 500 lignes |
| Fichiers Dart | 62 fichiers |
| Écrans | 26 écrans |
| Widgets réutilisables | 13+ widgets |
| Services | 12 services |
| Modèles de données | 6 classes de données |
| Packages Flutter | 11 packages |
| Commits git documentés | 12+ commits |
| API externes | 2 (Firebase + Groq) |
| Nœuds Firebase | 8 nœuds (users, pitches, messages, conversations, mentorRequests, availability, bookedSessions, notifications) |
| Profils mentors pré-chargés | 100+ profils sénégalais |
| Villes sénégalaises (GPS) | 40+ villes avec coordonnées |
| Secteurs d'activité | 10 secteurs porteurs |
| Langues supportées | Français (compréhension wolof via DIALI) |

---

### 7.3 Déploiement

L'application a été compilée en APK release signé (57.9 MB) et est disponible au téléchargement :

> **📦 Télécharger DIAPALER AFRICA :**  
> **https://drive.google.com/file/d/1XLJiSSJR8rQXCrAmY5mJWyx9i-6HFoGJ/view?usp=sharing**

**Détails du build :**

| Paramètre | Valeur |
|---|---|
| Type de build | Release signé |
| Taille APK | 57.9 MB |
| Plateforme | Android |
| Compilateur | Flutter `assembleRelease` |
| Keystore | RSA 2048 bits, validité 10 000 jours |
| Tree-shaking icônes | MaterialIcons réduit de 1 645 184 → 16 040 octets (−99 %) |
| Signature | `diapaler-release.jks`, alias `diapaler` |

> **📸 CAPTURE D'ÉCRAN — Terminal : `✓ Built build\app\outputs\flutter-apk\app-release.apk (57.9MB)`**
> *(Insérer ici la capture d'écran)*

---

#### Pourquoi Google Drive plutôt que le Play Store ?

La publication sur le **Google Play Store** nécessite le paiement d'un **frais d'inscription unique de 25 USD** (~15 000 FCFA) pour créer un compte développeur. Dans le cadre de ce projet académique à l'ESP Dakar, cette dépense n'est pas justifiée.

L'APK distribué via Google Drive est identique à ce qui serait publié sur le Play Store : il s'agit d'un **build release signé** avec un keystore RSA 2048 bits, exactement selon les exigences de Google Play. Si le projet évoluait vers une publication commerciale, l'APK existant pourrait être soumis sans recompilation.

| Canal de distribution | Coût | Adapté pour |
|---|---|---|
| **Google Drive ← choix actuel** | Gratuit | Projet académique / démonstration |
| Google Play Store | 25 USD (unique) | Publication commerciale |
| APK direct (lien ou QR code) | Gratuit | Tests internes / beta |

---

### 7.4 Perspectives d'évolution

Si DIAPALER AFRICA devait évoluer vers un produit commercial, les priorités seraient :

| Priorité | Fonctionnalité | Technologie |
|---|---|---|
| 1 | Notifications push (hors-app) | Firebase Cloud Messaging (FCM) |
| 2 | Appels vidéo (sessions mentorat) | Agora.io ou WebRTC |
| 3 | Mode hors-ligne complet | Firebase offline persistence |
| 4 | Analytiques | Firebase Analytics + tableau de bord |
| 5 | Recherche avancée | Algolia ou Firebase Extensions |
| 6 | Multi-langues | Intl package — français + wolof + anglais |
| 7 | Web app publique | Flutter Web — vitrine et landing page |

---

### 7.5 Conclusion

**DIAPALER AFRICA** est une application mobile complète, professionnelle et culturellement ancrée dans l'écosystème sénégalais. Elle répond à l'ensemble des critères académiques définis dans les 6 livrables, avec de nombreuses fonctionnalités bonus :

| Livrable | Fonctionnalités minimales | Fonctionnalités bonus |
|---|---|---|
| L1 | Navigation + 26 écrans | `IndexedStack`, `ValueNotifier`, FAB pulsant, agenda rôle-spécifique |
| L2 | Firebase CRUD (4 ops) | 20+ opérations CRUD, `InteractionsService`, `UsersService`, cache offline, `lastSenderId` |
| L3 | Connexion + Inscription | 4 étapes rôle-adaptées, jauge MDP, `AutofillGroup` sauvegarde MDP, `_bootstrap()` offline-first |
| L4 | Profil + Photo | Stats rôle-spécifiques, LinkedIn cliquable, projets Entrepreneur uniquement, boutons rôle-adaptatifs |
| L5 | Notifs + Recherche + GPS | Filtres, DIALI IA, pitch validé (3 étapes), CIS informatif, Wave Premium, **sauvegarde MDP**, **déploiement APK** |
| L6 | Rapport | 14+ bugs documentés, métriques complètes, qualité du code, **APK signé déployé et mis à jour** |

Au-delà des critères académiques, DIAPALER AFRICA apporte une **vraie valeur ajoutée** à l'écosystème entrepreneurial sénégalais, en connectant entrepreneurs, mentors et investisseurs dans une plateforme unifiée, moderne et accessible, avec :
- Un **chatbot IA** (DIALI) contextuelisé à l'écosystème sénégalais
- Une **géolocalisation** précise de 40+ villes sénégalaises
- Une **messagerie instantanée** Firebase temps réel
- Un système de **matching avancé** combinant membres réels et profils curatés

Ce projet démontre qu'il est possible, avec Flutter, Firebase et l'API Groq, de concevoir en quelques semaines une application mobile de **qualité professionnelle**, complète, réactive et prête pour la mise sur le marché africain.

---

*Rapport rédigé dans le cadre du module de Développement d'Applications Mobiles*  
*École Supérieure Polytechnique (ESP) de Dakar — 2025-2026*  
*Projet DIAPALER AFRICA — Tous droits réservés*

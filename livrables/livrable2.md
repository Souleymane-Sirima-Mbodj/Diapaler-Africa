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

# LIVRABLE 2
## Consommation d'API Externes

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

# LIVRABLE 2 — Consommation d'API Externes

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [Introduction](#introduction)
- [1. Firebase Realtime Database](#1-firebase-realtime-database)
  - [1.1 Configuration et initialisation](#11-configuration-et-initialisation)
  - [1.2 Structure complète de la base de données](#12-structure-complète-de-la-base-de-données)
  - [1.3 CREATE — Créer un profil utilisateur](#13-create--créer-un-profil-utilisateur)
  - [1.4 READ — Lire un profil (lecture unique)](#14-read--lire-un-profil-lecture-unique)
  - [1.5 READ — Stream temps réel des pitchs](#15-read--stream-temps-réel-des-pitchs)
  - [1.6 UPDATE — Modifier un profil](#16-update--modifier-un-profil)
  - [1.7 CREATE — Publier un pitch dans le nœud global](#17-create--publier-un-pitch-dans-le-nœud-global)
  - [1.8 UPDATE — Activer le statut Premium (Wave)](#18-update--activer-le-statut-premium-wave)
  - [1.9 DELETE — Suppression d'une session réservée](#19-delete--suppression-dune-session-réservée-firebase-remove)
  - [1.10 DELETE — Déconnexion et nettoyage](#110-delete--déconnexion-et-nettoyage-du-cache-local)
  - [1.11 Sérialisation JSON ↔ Dart](#111-sérialisation-json--dart)
- [2. Service d'interactions (`service_interactions.dart`)](#2-service-dinteractions-service_interactionsdart)
  - [2.1 Demandes de mentorat (mentorRequests)](#21-demandes-de-mentorat-mentorrequests)
  - [2.2 Messagerie temps réel (messages + conversations)](#22-messagerie-temps-réel-messages--conversations)
  - [2.3 Disponibilités mentor (availability)](#23-disponibilités-mentor-availability)
- [3. Service de découverte des membres (`service_utilisateurs.dart`)](#3-service-de-découverte-des-membres-service_utilisateursdart)
- [4. Groq API (Llama 3.1) (Chatbot DIALI IA)](#4-groq-api-llama-31-chatbot-diali-ia)
  - [4.1 Présentation technique](#41-présentation-technique)
  - [4.2 Service chatbot](#42-service-chatbot-service_chatbotdart)
  - [4.3 Appel depuis page_chatbot.dart](#43-appel-depuis-page_chatbotdart)
- [5. Tableau récapitulatif CRUD complet](#5-tableau-récapitulatif-crud-complet)
- [Conclusion](#conclusion-du-livrable-2)

---

## Introduction

DIAPALER AFRICA consomme **deux API externes** pour assurer la persistance des données, la communication temps réel et l'intelligence artificielle :

| API | Technologie | Utilisation |
|---|---|---|
| **Firebase Authentication** | REST (Google) | Connexion, inscription, reset MDP, sessions |
| **Firebase Realtime Database** | WebSocket + REST (Google) | Profils, pitchs, messages, sessions, demandes mentorat, notifications |
| **Groq API (Llama 3.1)** | HTTP REST | Chatbot IA DIALI |

Le code d'appel est isolé dans le dossier `lib/services/` pour respecter la séparation des préoccupations. Chaque service ne connaît que sa responsabilité :

| Fichier | Responsabilité |
|---|---|
| `service_base_de_donnees.dart` | Profils utilisateurs, pitchs, Premium |
| `service_interactions.dart` | Messagerie, demandes mentorat, disponibilités |
| `service_utilisateurs.dart` | Découverte des membres DIAPALER |
| `service_authentification.dart` | Auth Firebase (connexion, inscription, reset) |
| `service_cache.dart` | Cache local `SharedPreferences` (offline-first) |
| `service_chatbot.dart` | API REST Groq (chatbot DIALI IA) |
| `service_partage.dart` | Partage social natif (share_plus) — pitch, profil, conseil DIALI |
| `service_wave.dart` | Paiement Premium Wave — lien marchand + activation Firebase |

---

## 1. Firebase Realtime Database

### 1.1 Configuration et initialisation

Pour stocker et synchroniser les données de DIAPALER AFRICA, nous avons retenu Firebase Realtime Database. Ce choix s'explique par trois avantages majeurs : les WebSockets natifs permettent une synchronisation en temps réel sans polling, la structure JSON hiérarchique s'adapte parfaitement à notre modèle de données, et l'intégration Flutter via le package `firebase_database` est très mature. Contrairement à une API REST classique, chaque changement de données est immédiatement répercuté sur tous les appareils connectés, ce qui est indispensable pour la messagerie et les notifications de DIAPALER.

**Backend choisi :** Firebase Realtime Database — API WebSocket temps réel avec synchronisation offline automatique.

```dart
// lib/services/service_base_de_donnees.dart
import 'package:firebase_database/firebase_database.dart';
import '../data/profil_utilisateur.dart';

class DatabaseService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;
  static DatabaseReference _userRef(String uid) => _db.ref('users/$uid');
  // Note : le getter _pitchesRef est simplifié ici pour illustrer la référence ;
  // dans le code réel, les accès aux pitches se font directement via _db.ref('pitches/...')
}
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : projet DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

---

### 1.2 Structure complète de la base de données

Avant d'écrire une seule ligne de code, nous avons conçu l'arborescence JSON de Firebase en partant des besoins fonctionnels : chaque écran de l'application correspond à un nœud distinct. Cette organisation « a plat » (dénormalisée) est volontaire — Firebase recommande d'éviter les données trop imbriquées pour garantir des requêtes rapides. Par exemple, les pitchs sont séparés des profils utilisateurs pour que la page d'accueil puisse lire `pitches/` sans avoir à parcourir chaque profil.

```
diapaler-africa-default-rtdb/
│
├── users/
│   └── {uid}/
│       ├── firstName          → "Mariéme"
│       ├── lastName           → "Tine"
│       ├── email              → "marieme@teki.sn"
│       ├── phone              → "+221 77 123 45 67"
│       ├── role               → "Entrepreneur"
│       ├── gender             → "female"
│       ├── birthDate          → "2001-03-15T00:00:00.000"
│       ├── address            → "Plateau, Dakar"
│       ├── city               → "Dakar"
│       ├── country            → "Sénégal"
│       ├── sector             → "Mode & Textile"
│       ├── bio                → "Entrepreneuse passionnée..."
│       ├── linkedin           → "linkedin.com/in/marieme-tine"
│       ├── photoBase64        → "iVBORw0KGgoAAAANS..." (photo encodée)
│       ├── interests          → ["Tech", "Mode & Textile", "Artisanat"]
│       ├── yearsExperience    → 5
│       ├── investmentRange    → "500 000 – 5 000 000 FCFA"
│       ├── projects/
│       │   └── {id}/
│       │       ├── id             → "abc123xyz..."
│       │       ├── name           → "Téranga Mode"
│       │       ├── description    → "Plateforme de mode africaine..."
│       │       ├── sector         → "Mode & Textile"
│       │       ├── step           → 3
│       │       ├── totalSteps     → 5
│       │       ├── amount         → "5000000" (optionnel)
│       │       ├── businessPlanUrl → "https://res.cloudinary.com/..." (optionnel)
│       │       ├── videoUrl       → "https://res.cloudinary.com/..." (optionnel)
│       │       ├── deckUrl        → "https://res.cloudinary.com/..." (optionnel)
│       │       └── published      → false
│       ├── mentorsActive      → 2
│       ├── sessionsCount      → 8
│       ├── favoritesCount     → 5
│       ├── score              → 4.7
│       └── updatedAt          → 1748123456789 (ServerTimestamp)
│
├── pitches/
│   └── {timestamp}/
│       ├── id              → "1748123456789"
│       ├── userId          → "uid_entrepreneur_abc123" (UID Firebase — pas l'email)
│       ├── userName        → "Mariéme Tine"
│       ├── title           → "Téranga Mode"
│       ├── sector          → "Mode & Textile"
│       ├── description     → "Plateforme de vente de mode africaine..."
│       ├── amount          → "5000000"
│       ├── businessPlanUrl → "https://res.cloudinary.com/..." (optionnel)
│       ├── videoUrl        → "https://res.cloudinary.com/..." (optionnel)
│       ├── deckUrl         → "https://res.cloudinary.com/..." (optionnel)
│       └── createdAt       → 1748123456789 (ServerTimestamp)
│
├── messages/
│   └── {conversationId}/
│       └── {messageId}/
│           ├── id          → "1748123456789"
│           ├── senderId    → "uid_expediteur"
│           ├── senderName  → "Mariéme Tine"
│           ├── recipientId → "uid_destinataire"
│           ├── text        → "Bonjour, je voudrais..."
│           ├── timestamp   → "2025-05-24T10:00:00.000"
│           └── isRead      → false
│
├── conversations/
│   └── {conversationId}/   (clé = sorted [uid1, uid2] joint par "--")
│       ├── id              → "uid1--uid2"
│       ├── user1Id         → "uid1"
│       ├── user2Id         → "uid2"
│       ├── user1Name       → "Mariéme Tine"
│       ├── user2Name       → "Ibrahima Sall"
│       ├── lastMessage     → "À bientôt !"
│       ├── lastMessageTime → "2025-05-24T10:05:00.000"
│       ├── lastSenderId    → "uid_expediteur"
│       └── unreadCount     → 3
│
├── mentorRequests/
│   └── {requestId}/
│       ├── id           → "1748123456789"
│       ├── fromUserId   → "uid_entrepreneur"
│       ├── toUserId     → "uid_mentor"
│       ├── fromName     → "Mariéme Tine"
│       ├── toName       → "Ibrahima Sall"
│       ├── message      → "Bonjour, je recherche un mentor..."
│       ├── type              → "mentor" | "investment" | "session"   ← distingue mentorat, investissement et réservation de session
│       ├── status            → "pending" | "accepted" | "rejected" | "cancelled"
│       ├── proposedDate      → "2025-06-15" (optionnel — date suggérée par l'expéditeur)
│       ├── proposedTime      → "14:00" (optionnel — heure suggérée)
│       ├── rejectionReason   → "Agenda complet" (optionnel — raison du refus)
│       ├── createdAt         → "2025-05-20T09:00:00.000"
│       └── respondedAt       → "2025-05-21T14:30:00.000"
│
├── availability/
│   └── {userId}/
│       ├── userId       → "uid_mentor"
│       ├── schedule/
│       │   └── {day}/   (Monday, Tuesday, ...)
│       │       ├── day         → "Monday"
│       │       ├── isAvailable → true
│       │       └── timeSlots/
│       │           └── {index}/
│       │               ├── startHour   → 9
│       │               ├── startMinute → 0
│       │               ├── endHour     → 12
│       │               └── endMinute   → 0
│       └── lastUpdated  → "2025-05-24T10:00:00.000"
│
├── bookedSessions/
│   └── {uid}/
│       └── {sessionId}/
│           ├── id              → "1748123456789"
│           ├── mentorName      → "Ibrahima Sall"
│           ├── mentorInitials  → "IS"
│           ├── scheduledAt     → "2025-06-15T10:00:00.000"
│           └── otherUid        → "uid_mentor" (vide si mentor statique)
│
├── notifications/
│   └── {uid}/
│       └── {notifId}/
│           ├── id          → "1748123456789"
│           ├── title       → "Nouveau rendez-vous"
│           ├── message     → "Ibrahima a réservé une session..."
│           ├── type        → "session_booked" | "session_cancelled" | "investment_offer" | "session_request" | "info"
│           ├── timestamp   → "2025-05-24T10:00:00.000"
│           ├── isRead      → false
│           ├── requestId   → "1748123456789" (optionnel — ID du mentorRequest pour actions inline Accept/Decline)
│           ├── fromUserId  → "uid_expediteur" (optionnel — pour ouvrir le chat après acceptation)
│           └── fromName    → "Mariéme Tine" (optionnel — nom affiché dans la notification)
│
├── reviews/
│   └── {toUid}/
│       └── {reviewId}/
│           ├── id          → "1748123456789"
│           ├── fromUid     → "uid_auteur"
│           ├── fromName    → "Mariéme Tine"
│           ├── text        → "Excellent mentor, très disponible"
│           └── createdAt   → 1748123456789  (millisecondsSinceEpoch — entier, pas ISO string)
│
├── ratings/
│   └── {toUid}/
│       └── {fromUid}   → 5   (entier 1–5 — une note par évaluateur, écrasement si réévaluation)
│
└── pitchFavorites/
    └── {userId}/
        └── {pitchId}/
            ├── id          → "1748123456789"  (ID du pitch)
            ├── userId      → "uid_entrepreneur"
            ├── userName    → "Mariéme Tine"
            ├── title       → "Téranga Mode"
            ├── sector      → "Mode & Textile"
            ├── description → "Plateforme de vente..."
            ├── amount      → "5000000"
            ├── createdAt   → 1748123456789
            └── savedAt     → 1748567890123  (timestamp de sauvegarde — tri décroissant)
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud users/ avec un profil**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud pitches/ avec des pitchs publiés**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud messages/ et conversations/**
> *(Insérer ici la capture d'écran)*

---

### 1.3 CREATE — Créer un profil utilisateur

L'opération de création du profil est déclenchée à la fin de l'inscription en quatre étapes. Elle consiste à écrire un objet JSON complet dans le nœud `users/{uid}` de Firebase, en une seule requête atomique via `.set()`. Le choix d'utiliser l'UID Firebase comme clé (plutôt qu'un email) garantit l'unicité même si l'utilisateur change d'adresse. Si l'écriture échoue (réseau indisponible), l'application bascule sur le cache local `SharedPreferences` pour rester fonctionnelle.

Appelée lors de l'inscription après la création du compte Firebase Auth.

```dart
// service_base_de_donnees.dart
static Future<void> createUserProfile(String uid, UserProfile profile) {
  return _userRef(uid).set(_toMap(profile));
}
```

**Appel depuis `page_inscription.dart` :**
```dart
Future<void> _submit() async {
  // 1. Création du compte Firebase Auth
  final cred = await AuthService.signUp(
    email: _email.text,
    password: _password.text,
  );
  final uid = cred.user!.uid;

  // 2. Construction du profil complet
  final parts = _name.text.trim().split(RegExp(r'\s+'));
  // Préfixe dynamique selon le pays choisi (🇸🇳 +221 / 🇬🇲 +220 / 🇲🇱 +223)
  final dialCode = countryDialCode[_country] ?? '+221';
  final profile = UserProfile(
    firstName: parts.first,
    lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    email: _email.text.trim(),
    phone: '$dialCode ${_phone.text.trim()}',
    role: _roleLabel(_role),                                    // "Entrepreneur" | "Mentor" | "Investisseur"
    gender: _gender,
    birthDate: _birthDate,
    address: _address.text.trim(),
    city: _city,
    country: _country,
    sector: _sector,
    yearsExperience: _role == UserRole.mentor
                       ? (int.tryParse(_yearsExp.text.trim()) ?? 0) : 0,
    investmentRange: _role == UserRole.investor
                       ? _investmentRange.text.trim() : '',
    bio: _bio.text.trim(),
    linkedin: _linkedin.text.trim(),
    photoBase64: photoData,                                     // URL Cloudinary ou base64 selon disponibilité
    interests: _interests.toList()..sort(),
    projects: const [],
    companies: (_role == UserRole.mentor || _role == UserRole.investor)
                 ? List<String>.from(_companies)
                 : const [],
  );

  // 3. Écriture dans Firebase (CREATE) + cache local
  await DatabaseService.createUserProfile(uid, profile);
  UserProfileController.update(profile); // Persistance cache + Firebase auto
}
```

> **📸 CAPTURE D'ÉCRAN — Après inscription : profil visible dans la console Firebase**
> *(Insérer ici la capture d'écran)*

---

### 1.4 READ — Lire un profil (lecture unique)

Lors de la connexion, l'application effectue une lecture unique (one-shot) du profil avec `.get()`. On privilégie ici une lecture ponctuelle plutôt qu'un stream continu, car le profil n'a pas besoin d'être synchronisé en permanence — seule la messagerie et les pitchs nécessitent un flux temps réel. Le résultat est immédiatement désérialisé et stocké dans le `UserProfileController`, accessible depuis toute l'application.

Appelée lors de la connexion pour charger le profil depuis Firebase.

```dart
// service_base_de_donnees.dart
static Future<UserProfile?> readUserProfile(String uid) async {
  final snap = await _userRef(uid).get();           // Requête GET Firebase
  if (!snap.exists || snap.value == null) return null;
  final raw = Map<String, dynamic>.from(snap.value as Map);
  return _fromMap(raw);  // Désérialisation JSON → Dart (avec cast sécurisé)
}
```

**Appel depuis `page_connexion.dart` :**
```dart
final cred = await AuthService.signIn(
  email: _email.text,
  password: _password.text,
);
final uid = cred.user?.uid;
if (uid != null) {
  final remote = await DatabaseService.readUserProfile(uid);
  if (remote != null) {
    UserProfileController.update(remote); // Met à jour cache + état local
  }
}
```

---

### 1.5 READ — Stream temps réel des pitchs

Pour la page des pitchs publics, nous avons besoin que chaque nouveau pitch posté par un entrepreneur apparaisse instantanément chez tous les autres membres sans nécessiter un rechargement manuel. C'est pourquoi on utilise `.onValue` qui maintient une connexion WebSocket ouverte : dès qu'un nœud `pitches/` est modifié côté Firebase, le stream Dart émet une nouvelle liste et le `StreamBuilder` redessine l'interface. Le tri par date décroissante est appliqué côté client pour éviter d'alourdir les règles Firebase.

Utilise le WebSocket Firebase (`.onValue`) pour recevoir les mises à jour en continu.

```dart
// service_base_de_donnees.dart
static Stream<List<Map<String, dynamic>>> getPitches() {
  return _db.ref('pitches').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];

    // Conversion sécurisée de chaque nœud en Map Dart
    final list = data.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();

    list.sort((a, b) {
      // Pitchs premium en tête, puis tri par date décroissante
      final aPremium = (a['isPremium'] as bool?) == true ? 1 : 0;
      final bPremium = (b['isPremium'] as bool?) == true ? 1 : 0;
      if (bPremium != aPremium) return bPremium.compareTo(aPremium);
      final aT = (a['createdAt'] as num?) ?? 0;
      final bT = (b['createdAt'] as num?) ?? 0;
      return bT.compareTo(aT);
    });

    return list;
  });
}
```

**Utilisation dans `page_pitches_publics.dart` avec `StreamBuilder` :**
```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: DatabaseService.getPitches(),  // Stream Firebase temps réel
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final pitches = snapshot.data ?? [];
    if (pitches.isEmpty) return const _EmptyState();
    return ListView.separated(
      itemCount: pitches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PitchCard(pitch: pitches[i]),
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Écran Pitchs Publiés avec StreamBuilder fonctionnel**
> *(Insérer ici la capture d'écran)*

---

### 1.6 UPDATE — Modifier un profil

Quand un utilisateur modifie son profil, on utilise `.update()` au lieu de `.set()`. La différence est importante : `.set()` remplacerait l'intégralité du nœud (et effacerait des champs comme `isPremium` ou `sessionsCount` qu'on ne renvoie pas depuis le formulaire), tandis que `.update()` ne touche que les champs explicitement fournis. Cela garantit une mise à jour partielle et non destructive, même si plusieurs appareils modifient le même profil en parallèle.

Utilise `.update()` (merge partiel) pour ne modifier que les champs envoyés.

```dart
// service_base_de_donnees.dart
static Future<void> updateUserProfile(String uid, UserProfile profile) {
  return _userRef(uid).update(_toMap(profile));  // UPDATE (merge, pas de remplacement total)
}
```

**Depuis `page_modification_profil.dart` :**
```dart
Future<void> _save() async {
  final yearsParsed = int.tryParse(_yearsExperience.text.trim()) ?? 0;
  final next = _initial.copyWith(
    firstName: _firstName.text.trim(),
    lastName: _lastName.text.trim(),
    email: _email.text.trim(),
    phone: _phone.text.trim(),
    gender: _gender,
    birthDate: _birthDate,
    address: _address.text.trim(),
    city: _city,
    country: _country,
    sector: _sector,
    linkedin: _linkedin.text.trim(),
    bio: _bio.text.trim(),
    photoBase64: _photoBase64,
    interests: _interests.toList()..sort(),
    yearsExperience: _isMentor ? yearsParsed : _initial.yearsExperience,
    investmentRange: _isInvestor ? _investmentRange.text.trim() : _initial.investmentRange,
  );

  // Mise à jour locale immédiate (UX réactive) + cache
  UserProfileController.update(next);

  // Mise à jour serveur (non bloquante) — on tente d'écrire en Firebase si l'UID est disponible
  final uid = AuthService.currentUid;
  if (uid != null) {
    try {
      await DatabaseService.updateUserProfile(uid, next);
    } catch (_) {/* non-bloquant */}
  }

  // Retour avec confirmation
  if (!mounted) return;
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('✅ Profil mis à jour'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

> **📸 CAPTURE D'ÉCRAN — Profil mis à jour après modification**
> *(Insérer ici la capture d'écran)*

---

### 1.7 CREATE — Publier un pitch dans le nœud global

Publier un pitch est une double opération : le projet est enregistré dans le profil de l'entrepreneur (nœud `users/{uid}/projects/`) pour son suivi personnel, ET dans le nœud global `pitches/` visible par tous les membres. Ce choix de duplication volontaire évite une jointure coûteuse : la page pitchs publics peut lire `pitches/` sans charger chaque profil utilisateur. L'ID du pitch est généré à partir du timestamp en millisecondes, ce qui garantit l'ordre chronologique et l'unicité sans avoir besoin d'un compteur serveur.

Écriture dans `pitches/` (accessible à tous les utilisateurs, pas seulement au propriétaire).

```dart
// service_base_de_donnees.dart
static Future<void> publishPitch({
  required String pitchId,       // ID pré-généré par PitchPage
  required String userId,
  required String userName,
  required String title,
  required String sector,
  required String description,
  required String amount,
  String? businessPlanUrl,
  String? videoUrl,
  String? deckUrl,
  bool isPremium = false,
}) async {
  await _db.ref('pitches/$pitchId').set({
    'id': pitchId,
    'userId': userId,
    'userName': userName,
    'title': title,
    'sector': sector,
    'description': description,
    'amount': amount,
    'createdAt': ServerValue.timestamp,
    'isPremium': isPremium,
    if (businessPlanUrl != null) 'businessPlanUrl': businessPlanUrl,
    if (videoUrl != null)        'videoUrl':        videoUrl,
    if (deckUrl != null)         'deckUrl':         deckUrl,
  });
}
```

**Publication depuis `page_pitch.dart` (étape 5 uniquement) :**
```dart
// _publish() — appelée à l'étape 5 uniquement
final project = _buildProject(published: true);  // published: true
UserProfileController.updateProject(project);    // Profil entrepreneur
await DatabaseService.publishPitch(
  pitchId: _pitchId,                            // ID généré à l'initState
  userId: uid,
  userName: profile.fullName,
  title: project.name,
  sector: project.sector,
  description: project.description,
  amount: _amount.text.trim(),
  businessPlanUrl: _businessPlanUrl,
  videoUrl: _videoUrl,
  deckUrl: _deckUrl,
  isPremium: profile.isPremium,  // Pitch marqué premium si entrepreneur abonné
);
```

> **📸 CAPTURE D'ÉCRAN — Pitch soumis visible dans la console Firebase (pitches/)**
> *(Insérer ici la capture d'écran)*

---

### 1.8 UPDATE — Activer le statut Premium (Wave)

Le système Premium de DIAPALER fonctionne avec Wave, le principal service de paiement mobile au Sénégal. Après que l'utilisateur a validé le paiement sur l'application Wave, notre service confirme l'activation en écrivant uniquement trois champs sur le profil Firebase (`isPremium`, `premiumPlan`, `premiumSince`) via `.update()`. Ce choix d'un update partiel est délibéré : on ne veut pas écraser d'autres données du profil. Le badge ⭐ Premium apparaît instantanément sur le profil, sur les cartes de pitch, et les pitchs de l'entrepreneur remontent en tête de liste — le tout grâce à la mise à jour en mémoire du `UserProfileController` et au batch Firebase sur les pitchs.

Après confirmation du paiement Wave, un `update()` partiel marque l'utilisateur Premium :

```dart
// service_base_de_donnees.dart
static Future<void> setPremium({
  required String uid,
  required String plan,   // 'entrepreneur'
}) async {
  await _userRef(uid).update({
    'isPremium': true,
    'premiumPlan': plan,
    'premiumSince': ServerValue.timestamp,
  });
}
```

Lors de l'activation Premium, tous les pitchs existants de l'utilisateur sont marqués `isPremium: true` en une seule opération batch :

```dart
/// Marque tous les pitchs d'un utilisateur comme premium (ou non) en batch.
static Future<void> markUserPitchesPremium(String uid,
    {required bool isPremium}) async {
  final snap = await _db.ref('pitches').get();
  if (!snap.exists || snap.value == null) return;
  final data = Map<String, dynamic>.from(snap.value as Map);
  final updates = <String, dynamic>{};
  for (final entry in data.entries) {
    final pitch = Map<String, dynamic>.from(entry.value as Map);
    if (pitch['userId'] == uid) {
      updates['pitches/${entry.key}/isPremium'] = isPremium;
    }
  }
  if (updates.isNotEmpty) await _db.ref().update(updates);
}
```

**Depuis `service_wave.dart` :**
```dart
// Après que l'utilisateur confirme son paiement Wave
static Future<void> activatePremium(PremiumPlan plan) async {
  final uid = AuthService.currentUid;
  if (uid == null) return;
  // 1. Persistance Firebase (profil)
  await DatabaseService.setPremium(uid: uid, plan: plan.name);
  // 2. Marquer tous les pitchs existants comme premium
  await DatabaseService.markUserPitchesPremium(uid, isPremium: true);
  // 3. Mise à jour en mémoire → badge ⭐ visible instantanément
  final updated = UserProfileController.profile.value.copyWith(
    isPremium: true,
    premiumPlan: plan.name,
  );
  UserProfileController.update(updated);
}
```

> **📸 CAPTURE D'ÉCRAN — Firebase Console : nœud users/{uid} avec isPremium = true**
> *(Insérer ici la capture d'écran)*

---

### 1.9 DELETE — Suppression d'une session réservée (Firebase `.remove()`)

L'annulation d'un rendez-vous doit être bilatérale : si Mariéme annule sa session avec Ibrahima, la session doit disparaître du calendrier des deux utilisateurs. On utilise `.remove()` plutôt qu'un update de statut car une session annulée ne doit laisser aucune trace dans Firebase — cela évite d'accumuler des données mortes et simplifie les requêtes de lecture. Une notification est automatiquement envoyée à l'autre partie pour l'informer de l'annulation.

L'annulation d'un rendez-vous bilatéral supprime physiquement le nœud Firebase via `.remove()` :

```dart
// lib/services/service_agenda.dart — AgendaController.cancel()
static Future<void> cancel({
  required String userId,
  required String userName,
  required BookedSession session,
  required String reason,
}) async {
  // DELETE côté annulant
  await _db.child('bookedSessions/$userId/${session.id}').remove();

  // DELETE côté autre partie (si compte Firebase connu)
  if (session.otherUid.isNotEmpty) {
    await _db.child('bookedSessions/${session.otherUid}/${session.id}').remove();
  }

  // Notif côté annulant (récap de son action)
  await NotificationService.addNotification(
    title: 'Rendez-vous annulé',
    message: 'Session avec ${session.mentorName} annulée — motif : $reason',
    type: 'session_cancelled',
  );
  // Notif croisée : avertit l'autre partie si elle a un compte Firebase
  await NotificationService.notifyUser(
    uid: session.otherUid,
    title: 'Rendez-vous annulé',
    message: '$userName a annulé votre session — motif : $reason',
    type: 'session_cancelled',
  );
}
```

**Nœud supprimé dans Firebase :**
```
bookedSessions/
└── {userId}/
    └── {sessionId}  ← .remove() → nœud entièrement effacé
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud bookedSessions après annulation (nœud disparu)**
> *(Insérer ici la capture d'écran)*

---

### 1.10 DELETE — Déconnexion et nettoyage du cache local

La déconnexion dans DIAPALER n'est pas un simple `signOut()` — c'est une séquence de six opérations dans un ordre précis. On vide d'abord toutes les couches de cache en mémoire avant de révoquer la session Firebase, pour éviter qu'un état résiduel ne s'affiche brièvement à l'écran lors de la redirection. Le `pushAndRemoveUntil` vide complètement la pile de navigation pour qu'un appui sur le bouton retour ne ramène pas à une page protégée après déconnexion.

```dart
// feuille_profil.dart — Déconnexion complète (6 étapes)
await CacheService.clear();              // 1. Vide le cache SharedPreferences
NotificationService.reset();            // 2. Vide les notifications en mémoire
await AgendaController.reset();         // 3. Vide les sessions agenda en mémoire
UserProfileController.reset();          // 4. Réinitialise le profil en mémoire
appTabIndex.value = 0;                  // 5. Retour à l'onglet Accueil
await AuthService.signOut();           // 6. Révoque la session Firebase Auth

// Redirection vers la page de connexion (pile vidée, fade transition)
if (!context.mounted) return;
Navigator.of(context).pushAndRemoveUntil(
  PageRouteBuilder(
    pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const LoginPage()),
    transitionDuration: const Duration(milliseconds: 350),
  ),
  (_) => false,
);
```

> **📸 CAPTURE D'ÉCRAN — Dialog de confirmation de déconnexion**
> *(Insérer ici la capture d'écran)*

---

### 1.11 Sérialisation JSON ↔ Dart

Firebase Realtime Database ne retourne pas des objets Dart typés mais des `Map<Object?, Object?>` bruts, ce qui impose une couche de sérialisation manuelle. Nous avons délibérément choisi de ne pas utiliser `json_serializable` ou `freezed` pour garder le projet simple et lisible, mais aussi parce que les types retournés par Firebase (`num`, `bool`, `List` ou `Map` selon la valeur) nécessitent des casts personnalisés qu'un générateur automatique gère mal.

La sérialisation manuelle est nécessaire car Firebase Realtime Database retourne des `Map<Object?, Object?>` que Dart ne peut pas caster directement. Un cast sécurisé est appliqué sur chaque champ via l'opérateur `?.toString()` et les casts numériques `(v as num?)?.toInt()`.

```dart
// Dart → JSON (envoi à Firebase)
static Map<String, dynamic> _toMap(UserProfile p) => {
  'firstName': p.firstName,
  'lastName': p.lastName,
  'email': p.email,
  'phone': p.phone,
  'gender': p.gender.serialized,
  'birthDate': p.birthDate?.toIso8601String(),
  'address': p.address,
  'city': p.city,
  'country': p.country,
  'sector': p.sector,
  'role': p.role,
  'bio': p.bio,
  'linkedin': p.linkedin,
  'photoBase64': p.photoBase64,
  'interests': p.interests,
  'projects': p.projects.map(_projectToMap).toList(),
  'mentorsActive': p.mentorsActive,
  'sessionsCount': p.sessionsCount,
  'favoritesCount': p.favoritesCount,
  'score': p.score,
  'yearsExperience': p.yearsExperience,
  'investmentRange': p.investmentRange,
  'isPremium': p.isPremium,
  'premiumPlan': p.premiumPlan,
  'companies': p.companies,
  'updatedAt': ServerValue.timestamp,
};

static Map<String, dynamic> _projectToMap(Project p) => {
  'id': p.id,
  'name': p.name,
  'description': p.description,
  'sector': p.sector,
  'step': p.step,
  'totalSteps': p.totalSteps,
  if (p.amount != null)          'amount':          p.amount,
  if (p.businessPlanUrl != null) 'businessPlanUrl': p.businessPlanUrl,
  if (p.videoUrl != null)        'videoUrl':        p.videoUrl,
  if (p.deckUrl != null)         'deckUrl':         p.deckUrl,
  'published': p.published,
};

// JSON → Dart (lecture depuis Firebase) — cast sécurisé + parsing listes
static UserProfile _fromMap(Map<String, dynamic> m) {
  final rawProjects = m['projects'];
  final projects = <Project>[];
  if (rawProjects is List) {
    for (final raw in rawProjects) {
      if (raw is Map) {
        final pm = Map<String, dynamic>.from(raw);
        projects.add(Project(
          id: pm['id']?.toString() ?? '',
          name: pm['name']?.toString() ?? '',
          description: pm['description']?.toString() ?? '',
          sector: pm['sector']?.toString() ?? '',
          step: (pm['step'] as num?)?.toInt() ?? 1,
          totalSteps: (pm['totalSteps'] as num?)?.toInt() ?? 5,
          amount: pm['amount']?.toString(),
          businessPlanUrl: pm['businessPlanUrl']?.toString(),
          videoUrl: pm['videoUrl']?.toString(),
          deckUrl: pm['deckUrl']?.toString(),
          published: (pm['published'] as bool?) ?? false,
        ));
      }
    }
  }

  final rawInterests = m['interests'];
  final interests = <String>[];
  if (rawInterests is List) {
    for (final v in rawInterests) {
      interests.add(v.toString());
    }
  }

  final rawCompanies = m['companies'];
  final companies = <String>[];
  if (rawCompanies is List) {
    for (final v in rawCompanies) {
      companies.add(v.toString());
    }
  }

  DateTime? birth;
  final rawBirth = m['birthDate']?.toString();
  if (rawBirth != null && rawBirth.isNotEmpty) {
    birth = DateTime.tryParse(rawBirth);
  }

  return UserProfile(
    firstName: m['firstName']?.toString() ?? '',
    lastName: m['lastName']?.toString() ?? '',
    email: m['email']?.toString() ?? '',
    phone: m['phone']?.toString() ?? '',
    gender: Gender.fromString(m['gender']?.toString()),
    birthDate: birth,
    address: m['address']?.toString() ?? '',
    city: m['city']?.toString() ?? 'Dakar',
    country: m['country']?.toString() ?? 'Sénégal',
    sector: m['sector']?.toString() ?? 'Autre',
    role: m['role']?.toString() ?? 'Entrepreneur',
    bio: m['bio']?.toString() ?? '',
    linkedin: m['linkedin']?.toString() ?? '',
    photoBase64: m['photoBase64']?.toString() ?? '',
    interests: interests,
    projects: projects,
    mentorsActive: (m['mentorsActive'] as num?)?.toInt() ?? 0,
    sessionsCount: (m['sessionsCount'] as num?)?.toInt() ?? 0,
    favoritesCount: (m['favoritesCount'] as num?)?.toInt() ?? 0,
    score: (m['score'] as num?)?.toDouble() ?? 0.0,
    yearsExperience: (m['yearsExperience'] as num?)?.toInt() ?? 0,
    investmentRange: m['investmentRange']?.toString() ?? '',
    isPremium: (m['isPremium'] as bool?) ?? false,
    premiumPlan: m['premiumPlan']?.toString() ?? '',
    companies: companies,
  );
}
```

---

## 2. Service d'interactions (`service_interactions.dart`)

L'`InteractionsService` gère toutes les interactions entre utilisateurs : **demandes de mentorat**, **messagerie temps réel** et **disponibilités des mentors**.

### 2.1 Demandes de mentorat (mentorRequests)

Le nœud `mentorRequests/` centralise deux types d'interactions entre membres : les demandes de mentorat (un entrepreneur sollicite un mentor) et les propositions d'investissement (un investisseur s'intéresse à un entrepreneur). Un seul modèle `MentorRequest` couvre les deux cas grâce au champ `type`, ce qui simplifie le code et la structure Firebase. Le champ `status` suit le cycle de vie de chaque demande, de `pending` à `accepted` ou `rejected`, avec la date de réponse tracée dans `respondedAt` pour l'historique.

**Modèle `MentorRequest`** — le champ `type` distingue les deux types de demandes :

| Champ | Type | Valeurs |
|---|---|---|
| `id` | String | Timestamp ms |
| `fromUserId` | String | UID de l'expéditeur |
| `toUserId` | String | UID du destinataire |
| `fromName` / `toName` | String | Noms affichés |
| `message` | String | Message personnalisé |
| `type` | String | `'mentor'` / `'investment'` / `'session'` |
| `status` | String | `'pending'` / `'accepted'` / `'rejected'` / `'cancelled'` |
| `createdAt` / `respondedAt` | String (ISO) | Dates |

```dart
// lib/services/service_interactions.dart
import 'package:firebase_database/firebase_database.dart';
import '../data/interactions.dart';

class InteractionsService {
  static final _db = FirebaseDatabase.instance.ref();

  // ── CREATE : Envoyer une demande de mentorat — retourne l'ID Firebase créé
  static Future<String> sendMentorRequest({
    required String fromUserId,
    required String toUserId,
    required String fromName,
    required String toName,
    required String message,
    String type = 'mentor',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final request = MentorRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromName: fromName,
      toName: toName,
      message: message,
      createdAt: DateTime.now(),
      status: RequestStatus.pending,
      type: type,
    );
    await _db.child('mentorRequests/$id').set(request.toJson());
    return id;  // ← ID renvoyé (utile pour référencer la demande après création)
  }

  // ── READ (stream) : Demandes reçues par un utilisateur
  // Filtrage serveur via orderByChild + equalTo — plus rapide que tout charger côté client.
  static Stream<List<MentorRequest>> getReceivedRequests(String userId) {
    return _db.child('mentorRequests')
        .orderByChild('toUserId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map)
          .map<MentorRequest>((v) =>
              MentorRequest.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // ── UPDATE : Accepter une demande
  static Future<void> acceptRequest(String requestId) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.accepted.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }

  // ── UPDATE : Rejeter une demande (avec raison optionnelle)
  static Future<void> rejectRequest(String requestId, {String? reason}) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.rejected.name,
      'respondedAt': DateTime.now().toIso8601String(),
      if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
    });
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Écran "Demandes reçues" avec liste des requêtes**
> *(Insérer ici la capture d'écran)*

---

### 2.2 Messagerie temps réel (messages + conversations)

La messagerie repose sur deux nœuds complémentaires : `messages/` stocke le contenu de chaque échange, et `conversations/` maintient un résumé (dernier message, compteur de non lus) pour afficher la liste des conversations sans avoir à charger tous les messages. L'identifiant de conversation est généré en triant les deux UIDs alphabétiquement et en les concaténant, ce qui garantit que deux utilisateurs partagent toujours le même identifiant de canal quelle que soit la direction du premier message.

L'envoi d'un message écrit dans `messages/{conv}/{id}` puis met à jour le compteur de non lus dans `conversations/{conv}`. La lecture utilise le WebSocket Firebase (`.onValue`) pour une synchronisation instantanée.

```dart
// ── CREATE : Envoyer un message
static Future<void> sendMessage({
  required String conversationId,
  required String senderId,
  required String senderName,
  required String recipientId,
  required String recipientName,
  required String text,
}) async {
  final msgId = DateTime.now().millisecondsSinceEpoch.toString();
  final now = DateTime.now();
  final message = ChatMessage(
    id: msgId, senderId: senderId, senderName: senderName,
    recipientId: recipientId, text: text, timestamp: now, isRead: false,
  );
  await _db.child('messages/$conversationId/$msgId').set(message.toJson());

  // Sync de la conversation avec createOrUpdateConversation (utilise .set())
  final ids = [senderId, recipientId]..sort();
  await createOrUpdateConversation(Conversation(
    id: conversationId,
    user1Id: ids[0],
    user2Id: ids[1],
    user1Name: ids[0] == senderId ? senderName : recipientName,
    user2Name: ids[0] == senderId ? recipientName : senderName,
    lastMessage: text,
    lastMessageTime: now,
    unreadCount: 1,
    lastSenderId: senderId,
  ));
}

static Future<void> createOrUpdateConversation(Conversation conversation) async {
  // Utilise .set() (remplacement complet) plutôt que .update() pour garantir
  // la cohérence de tous les champs à chaque message envoyé.
  await _db.child('conversations/${conversation.id}').set(conversation.toJson());
}

// ── READ (stream) : Messages temps réel + conversations d'un utilisateur
static Stream<List<ChatMessage>> getMessages(String conversationId) {
  return _db.child('messages/$conversationId').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];
    return data.values
        .map<ChatMessage>((v) => ChatMessage.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  });
}
```

> **📸 CAPTURE D'ÉCRAN — Messagerie : liste des conversations (avec compteur non lus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Messagerie : conversation temps réel**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Disponibilités mentor (availability)

Chaque mentor peut définir ses créneaux disponibles par jour de la semaine depuis son planning. Ces données sont stockées dans le nœud `availability/{userId}` et lues en temps réel par les entrepreneurs pour savoir quand réserver une session. On utilise `.set()` pour les mises à jour (remplacement complet du planning) plutôt que `.update()`, car modifier partiellement un calendrier hebdomadaire serait plus risqué — il vaut mieux réécrire tout le planning d'un coup pour garantir sa cohérence.

```dart
static Stream<Availability?> getAvailability(String userId) =>
    _db.child('availability/$userId').onValue.map((e) {
      final data = e.snapshot.value as Map?;
      return data == null ? null : Availability.fromJson(Map<String, dynamic>.from(data));
    });

static Future<void> updateAvailability(Availability a) =>
    _db.child('availability/${a.userId}').set(a.toJson());
```

> **📸 CAPTURE D'ÉCRAN — Planning du mentor : gestion des créneaux disponibles**
> *(Insérer ici la capture d'écran)*

---

## 3. Service de découverte des membres (`service_utilisateurs.dart`)

Le `UsersService` lit les membres DIAPALER inscrits depuis Firebase et les affiche dans la page Matching avec un badge "Membre DIAPALER" distinctif. La logique est **adaptative** : un Entrepreneur voit les Mentors et Investisseurs, tandis qu'un Mentor ou Investisseur voit les Entrepreneurs.

```dart
class UsersService {
  static final _db = FirebaseDatabase.instance.ref();

  /// Retourne la liste des membres filtrés selon le rôle de l'utilisateur courant :
  /// - Entrepreneur → charge Mentors + Investisseurs
  /// - Mentor ou Investisseur → charge uniquement les Entrepreneurs
  static Future<List<Mentor>> listMembers() async {
    final snap = await _db.child('users').get();
    if (!snap.exists || snap.value == null) return [];
    final data = Map<String, dynamic>.from(snap.value as Map);

    final currentUid = AuthService.currentUid;
    final myRole = UserProfileController.profile.value.role;

    // Rôles cibles selon mon propre rôle
    final Set<String> targetRoles;
    if (myRole == 'Mentor' || myRole == 'Investisseur') {
      targetRoles = {'Entrepreneur', 'Entrepreneure'};
    } else {
      // Entrepreneur (et cas par défaut) → voir Mentors & Investisseurs
      targetRoles = {'Mentor', 'Investisseur'};
    }

    final result = <Mentor>[];
    for (final entry in data.entries) {
      final uid = entry.key;
      if (uid == currentUid) continue;              // Exclure soi-même
      final m = Map<String, dynamic>.from(entry.value as Map);
      final role = (m['role']?.toString() ?? '').trim();
      if (!targetRoles.contains(role)) continue;    // Filtrage adaptatif
      // Parsing des secteurs (champ 'interests' ou 'sectors')
      final rawSectors = m['interests'] ?? m['sectors'];
      final sectors = <String>[];
      if (rawSectors is List) {
        for (final s in rawSectors) sectors.add(s.toString());
      }
      // Lecture des entreprises fondées/possédées depuis Firebase
      final rawCompanies = m['companies'];
      final companies = <String>[];
      if (rawCompanies is List) {
        for (final c in rawCompanies) companies.add(c.toString());
      }
      result.add(Mentor(
        uid: uid,
        initials: _initials(m['firstName']?.toString() ?? '',
            m['lastName']?.toString() ?? ''),
        name: '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim(),
        title: m['sector']?.toString() ?? '',
        city: m['city']?.toString() ?? 'Dakar',
        sectors: sectors,
        companies: companies,  // ← lues depuis Firebase (pas const [])
        rating: (m['score'] as num?)?.toDouble() ?? 0.0,
        reviews: 0,
        years: (m['yearsExperience'] as num?)?.toInt() ?? 0,
        compatibility: 80,
        gender: Gender.fromString(m['gender']?.toString()),
        bio: m['bio']?.toString() ?? '',
        role: role,
        photoBase64: m['photoBase64']?.toString() ?? '',
      ));
    }
    return result;
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Matching : membres DIAPALER réels en tête de liste**
> *(Insérer ici la capture d'écran)*

---

### Stockage de fichiers — Cloudinary

Les fichiers volumineux (photos de profil haute résolution, PDFs de pitchs, vidéos) sont uploadés vers Cloudinary via le service `service_cloudinary.dart`. Cela évite de surcharger Firebase Realtime Database avec du contenu binaire. Le flux est :

1. Utilisateur sélectionne fichier depuis la galerie (ImagePicker). L'application n'utilise pas de sélecteur caméra intégré pour ces flows.
2. `CloudinaryService.uploadBytes()` effectue POST HTTPS vers `upload.cloudinary.com`
3. Cloudinary retourne URL publique HTTPS
4. URL stockée dans Firebase (références, pas le fichier lui-même)
5. Affichage rapide de l'image via URL CDN global

**Configuration Cloudinary :**
- Cloud Name: ddpgzzwxb
- Upload Preset: diapaler_unsigned (non-signé pour faciliter uploads client-side)
- Dossier de destination: `pitches/` (organisé par type de contenu)
- Transformations: redimensionnement automatique côté client à 512×512 lors de l'inscription (Cloudinary), et 400×400 dans la page de modification du profil (client-side). Cloudinary peut aussi appliquer ses propres transformations côté serveur.

**Avantages :**
- Pas de limite de taille Firebase (illimitée Cloudinary)
- CDN global pour livraison rapide
- Compression auto + cache HTTP
- Gestion d'espace facilement séparable de la logique métier

---

## 4. Groq API — Llama 3.1 (Chatbot DIALI IA)

### 4.1 Architecture sécurisée — Proxy Cloudflare Worker

Pour le chatbot DIALI IA, nous avons choisi Groq avec le modèle Llama 3.1 8B instant. Groq se distingue par sa vitesse de génération (LPU — Language Processing Unit) qui produit des réponses en moins d'une seconde, bien adapté à une interface de chat mobile. Le modèle `llama-3.1-8b-instant` est suffisamment puissant pour conseiller un entrepreneur sénégalais tout en étant gratuit dans les quotas actuels, ce qui correspond au budget de notre projet académique. Quant au proxy Cloudflare Worker, il résout un problème de sécurité fondamental : une clé API embarquée dans le code d'une application mobile peut être extraite par décompilation.

Pour des raisons de **sécurité**, la clé API Groq n'est **jamais** embarquée dans le code Flutter. L'appel passe par un **Cloudflare Worker** déployé côté serveur qui détient la clé et joue le rôle de proxy.

```
┌─────────────────┐   HTTP POST (JSON)   ┌────────────────────────────┐
│  Flutter App    │ ──────────────────▶  │  Cloudflare Worker         │
│  (page_chatbot) │                      │  diali-proxy.sirimambodj   │
│                 │   ◀── réponse texte  │  .workers.dev/chat         │
└─────────────────┘                      └────────────┬───────────────┘
                                                       │  HTTP POST + x-api-key
                                                       ▼
                                         ┌─────────────────────────────┐
                                         │  Groq Chat Completions API      │
                                         │  llama-3.1-8b-instant  │
                                         └─────────────────────────────┘
```

| Paramètre | Valeur |
|---|---|
| **API** | Groq Chat Completions API (via proxy) |
| **Proxy URL** | `https://diali-proxy.sirimambodj.workers.dev/chat` |
| **Méthode HTTP** | POST |
| **Modèle** | `llama-3.1-8b-instant` |
| **Authentification** | Aucune clé côté client — gérée côté Worker |
| **Format** | JSON (Content-Type: application/json) |
| **Package Flutter** | `http: ^1.2.2` |

### 4.2 Service chatbot (`service_chatbot.dart`)

Le service chatbot construit un prompt système personnalisé à partir du profil de l'utilisateur connecté : son prénom, son rôle (Entrepreneur/Mentor/Investisseur), son secteur d'activité et sa ville. Cette personnalisation rend les réponses de DIALI bien plus pertinentes — un entrepreneur du secteur Mode à Dakar recevra des conseils différents d'un mentor tech à Saint-Louis. L'historique complet de la conversation est envoyé à chaque requête (format `messages[]`) pour que DIALI garde le contexte des échanges précédents.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modèle typé pour un message de la conversation.
class ChatbotMessage {
  final String role;     // 'user' ou 'assistant'
  final String content;
  const ChatbotMessage({required this.role, required this.content});
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class ChatbotService {
  /// Proxy Cloudflare Worker — la clé Groq est côté serveur (sécurité).
  static const _proxyUrl =
      'https://diali-proxy.sirimambodj.workers.dev/chat';

  static const _model = 'llama-3.1-8b-instant';

  /// Construit le prompt système personnalisé selon le profil de l'utilisateur.
  static String _systemPrompt({
    required String userName,
    required String userRole,
    required String userSector,
    required String userCity,
  }) {
    return '''Tu es DIALI, l\'assistant IA de DIAPALER AFRICA — la plateforme
qui connecte entrepreneurs, mentors et investisseurs au Sénégal et en Afrique de l\'Ouest.

Tu accompagnes $userName, $userRole dans le secteur $userSector basé(e) à $userCity.

Tes domaines d\'expertise :
• Stratégie entrepreneuriale et développement de projet au Sénégal
• Financement sénégalais : DER/FJ (100 000 à 30 000 000 FCFA), PAVIE 2, Be Yes (18-40 ans), ADPME, BNDE
• Conditions DER/FJ : nationalité sénégalaise, âge 18-35 ans, dossier complet (CNI, plan d\'affaires, photos passeport, relevé de compte)
• Préparation de pitchs et dossiers investisseurs
• Marketing digital, e-commerce, Made in Sénégal
• Mise en relation mentors et investisseurs via DIAPALER

Directives :
- Réponds toujours en français, avec un ton bienveillant, concret et adapté au contexte africain
- Utilise ponctuellement des mots en wolof (Ndank ndank, Baraka, Jërejëf, Yëgël...) pour créer du lien
- Donne des conseils actionnables, pas des généralités
- Pour le financement, cite les montants en FCFA et les conditions précises
- Sois concis : 3-4 paragraphes maximum par réponse
- Si l\'utilisateur demande de l\'aide pour un pitch, propose-lui un plan structuré''';
  }

  /// Envoie la conversation au proxy → Groq et retourne la réponse texte.
  static Future<String> sendMessage({
    required List<ChatbotMessage> messages,
    required String userName,
    required String userRole,
    required String userSector,
    required String userCity,
  }) async {
    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'model': _model,
            'max_tokens': 1024,
            'system': _systemPrompt(
              userName: userName,
              userRole: userRole,
              userSector: userSector,
              userCity: userCity,
            ),
            'messages': messages.map((m) => m.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // Détection en cascade — format Groq/OpenAI en priorité, Anthropic en fallback
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices[0]?['message'];
        if (msg is Map) {
          final text = msg['content'];
          if (text is String && text.isNotEmpty) return text;
        }
      }
      final content = data['content'];
      if (content is List && content.isNotEmpty) {
        final first = content[0];
        if (first is Map) {
          final text = first['text'];
          if (text is String && text.isNotEmpty) return text;
        }
      }
      throw Exception('Format de réponse inattendu du serveur.');
    } else if (response.statusCode == 429) {
      throw Exception('Limite d\'utilisation atteinte. Réessaie dans quelques instants.');
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(body['error']?['message'] ?? 'Erreur API (${response.statusCode})');
    }
  }
}
```

### 4.3 Appel depuis `page_chatbot.dart`

La page chatbot gère l'affichage optimiste des messages : le message de l'utilisateur est ajouté immédiatement dans la liste locale (avant même que la requête HTTP parte), ce qui donne l'impression d'une réactivité instantanée. Si l'appel échoue, le dernier message de l'utilisateur est retiré de la liste et une `SnackBar` affiche l'erreur. Ce pattern « affichage optimiste + rollback en cas d'erreur » est courant dans les applications de messagerie modernes.

```dart
class _ChatbotPageState extends State<ChatbotPage> {
  final _messages = <ChatbotMessage>[];   // Historique typé
  final _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    final userText = _ctrl.text.trim();
    if (userText.isEmpty || _loading) return;

    final profile = UserProfileController.profile.value;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatbotMessage(role: 'user', content: userText));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final reply = await ChatbotService.sendMessage(
        messages: _messages,
        userName: profile.firstName,
        userRole: profile.role,
        userSector: profile.sector,
        userCity: profile.city,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatbotMessage(role: 'assistant', content: reply));
      });
      _scrollToBottom();
    } on Exception catch (e) {
      if (!mounted) return;
      String raw = e.toString().replaceFirst('Exception: ', '');
      final String msg;
      if (raw.toLowerCase().contains('credit') || raw.toLowerCase().contains('balance')) {
        msg = 'Service DIALI temporairement indisponible — crédits IA épuisés. Réessaie dans quelques instants.';
      } else if (raw.toLowerCase().contains('timeout') || raw.toLowerCase().contains('network')) {
        msg = 'Connexion internet instable. Vérifie ta connexion et réessaie.';
      } else {
        msg = 'DIALI rencontre une difficulté technique. Réessaie dans quelques instants.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _messages.removeLast());
      _ctrl.text = userText;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA en cours de conversation**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Réponse de DIALI sur le financement sénégalais (DER/FJ)**
> *(Insérer ici la capture d'écran)*

---

## 5. Tableau récapitulatif CRUD complet

Pour récapituler l'ensemble des interactions avec Firebase et l'API Groq, le tableau ci-dessous liste chaque opération CRUD implémentée dans DIAPALER AFRICA. On constate que les opérations READ en mode stream (`.onValue`) sont les plus nombreuses, ce qui reflète bien l'architecture temps réel de l'application. Les opérations DELETE sont plus rares et ciblées : on préfère marquer un élément comme annulé ou lu plutôt que de le supprimer, sauf pour les sessions (données bilatérales) et le cache local à la déconnexion.

| Opération | Service | Nœud Firebase / Endpoint | Déclenché par |
|---|---|---|---|
| **CREATE** profil | `DatabaseService` | `users/{uid}.set()` | Inscription |
| **CREATE** pitch (nœud global) | `DatabaseService` | `pitches/{id}.set()` | Dépôt de pitch |
| **CREATE** message | `InteractionsService` | `messages/{conv}/{id}.set()` | Envoi chat |
| **CREATE** conversation | `InteractionsService` | `conversations/{id}.set()` | 1er message |
| **CREATE** session agenda | `AgendaController` | `bookedSessions/{uid}/{id}.set()` | Réservation RDV |
| **CREATE** demande mentorat | `InteractionsService` | `mentorRequests/{id}.set()` type=`'mentor'` | Envoi demande de mentorat |
| **CREATE** demande investissement | `InteractionsService` | `mentorRequests/{id}.set()` type=`'investment'` | Proposer un investissement |
| **READ (check)** anti-doublon demande | `InteractionsService` | `mentorRequests.orderByChild('fromUserId').equalTo()` | Avant envoi d'une demande |
| **READ** profil (unique) | `DatabaseService` | `users/{uid}.get()` | Connexion / Démarrage |
| **READ** membres inscrits | `UsersService` | `users.get()` | Chargement Matching |
| **READ** pitchs (stream) | `DatabaseService` | `pitches.onValue` | Vue pitchs publiés |
| **READ** messages (stream) | `InteractionsService` | `messages/{conv}.onValue` | Conversation chat |
| **READ** conversations (stream) | `InteractionsService` | `conversations.onValue` | Onglet Messages |
| **READ** demandes reçues (stream) | `InteractionsService` | `mentorRequests.onValue` | Mes demandes |
| **READ** disponibilités (stream) | `InteractionsService` | `availability/{uid}.onValue` | Planning mentor |
| **UPDATE** profil | `DatabaseService` | `users/{uid}.update()` | Modifier profil / pitch |
| **UPDATE** statut demande | `InteractionsService` | `mentorRequests/{id}.update()` | Accepter/Refuser |
| **UPDATE** disponibilités | `InteractionsService` | `availability/{uid}.set()` | Planning mentor |
| **UPDATE** conversation (nb non lus) | `InteractionsService` | `conversations/{id}.update()` | Lecture message |
| **CREATE** avis (texte) | `InteractionsService` | `reviews/{toUid}/{id}.set()` — champs : id, fromUid, fromName, text, createdAt (ms) | Laisser un commentaire |
| **CREATE/UPDATE** note (étoiles) | `InteractionsService` | `ratings/{toUid}/{fromUid}.set(value)` — entier 1–5, écrasement si réévaluation | Sélecteur étoiles 1–5 |
| **CREATE** pitch favori | `PitchFavoriteService` | `pitchFavorites/{userId}/{pitchId}.set()` | Bookmark investisseur |
| **READ** avis (stream) | `InteractionsService` | `reviews/{toUid}.onValue` | Page Avis / Profil |
| **READ** pitchs favoris (stream) | `PitchFavoriteService` | `pitchFavorites/{userId}.onValue` | Mes Pitchs Sauvegardés |
| **DELETE** pitch favori | `PitchFavoriteService` | `pitchFavorites/{userId}/{pitchId}.remove()` | Retirer un bookmark |
| **DELETE** session réservée | `AgendaController` | `bookedSessions/{uid}/{id}.remove()` | Annulation rendez-vous |
| **DELETE** déconnexion | `AuthService` | `signOut()` | Déconnexion |
| **DELETE** cache local | `CacheService` | `prefs.remove(key)` | Déconnexion |
| **POST** message IA | `ChatbotService` | proxy `/chat` → Groq `/openai/v1/chat/completions` | Chat DIALI |

> **📸 CAPTURE D'ÉCRAN — Console Firebase : messages en temps réel dans messages/**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 2

DIAPALER AFRICA consomme pleinement des API externes avec toutes les opérations CRUD :

| Critère | Détail | Statut |
|---|---|---|
| API REST intégrée | Firebase Realtime Database + Meta Llama 3.1 via Groq | ✅ |
| Récupérer des données | `readUserProfile()`, `getPitches()`, `getMessages()`, `getConversations()` | ✅ |
| Ajouter des données | `createUserProfile()`, `publishPitch()`, `sendMessage()`, `sendMentorRequest()`, `sendInvestmentProposal()` | ✅ |
| Modifier des données | `updateUserProfile()`, `acceptRequest()`, `updateAvailability()` | ✅ |
| Supprimer des données | `AgendaController.cancel()` → `bookedSessions/{uid}/{id}.remove()` (Firebase réel) + `signOut()` / cache | ✅ |
| Backend supporté | Firebase (listé dans les consignes) | ✅ |
| Sérialisation JSON | `_toMap()` / `_fromMap()` avec cast sécurisé | ✅ |
| Cache offline-first | `CacheService` (SharedPreferences) | ✅ (bonus) |
| Découverte membres | `UsersService.listMembers()` | ✅ (bonus) |
| Chatbot IA | Llama 3.1 8B via Groq — HTTP REST + proxy Cloudflare | ✅ (bonus) |
| Flux investisseur | `mentorRequests` type `'investment'` + notification + acceptation dans `RequestsPage` | ✅ (bonus) |
| Fix path Firebase | `generateConversationId` sanitize les caractères interdits (`.#$[]/@` → `_`) | ✅ (bonus) |
| Système d'avis (reviews) | CREATE + READ stream `reviews/` — notation 1–5, accès restreint, moyenne live | ✅ (bonus) |
| Pitchs favoris (bookmark) | CREATE + READ + DELETE stream `pitchFavorites/` — ValueNotifier temps réel | ✅ (bonus) |
| Préfixe téléphone dynamique | `countryDialCode` map — +221 SN / +220 GM / +223 ML à l'inscription | ✅ (bonus) |

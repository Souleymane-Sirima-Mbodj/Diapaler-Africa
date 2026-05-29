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
  - [1.9 DELETE — Déconnexion et nettoyage](#19-delete--déconnexion-et-nettoyage)
  - [1.10 Sérialisation JSON ↔ Dart](#110-sérialisation-json--dart)
- [2. Service d'interactions (`service_interactions.dart`)](#2-service-dinteractions-service_interactionsdart)
  - [2.1 Demandes de mentorat (mentorRequests)](#21-demandes-de-mentorat-mentorrequests)
  - [2.2 Messagerie temps réel (messages + conversations)](#22-messagerie-temps-réel-messages--conversations)
  - [2.3 Disponibilités mentor (availability)](#23-disponibilités-mentor-availability)
- [3. Service de découverte des membres (`service_utilisateurs.dart`)](#3-service-de-découverte-des-membres-service_utilisateursdart)
- [4. Anthropic Claude API (Chatbot DIALI IA)](#4-anthropic-claude-api-chatbot-diali-ia)
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
| **Firebase Realtime Database** | WebSocket + REST (Google) | Profils, pitchs, messages, agenda, demandes mentorat |
| **Anthropic Claude API** | HTTP REST | Chatbot IA DIALI |

Le code d'appel est isolé dans le dossier `lib/services/` pour respecter la séparation des préoccupations. Chaque service ne connaît que sa responsabilité :

| Fichier | Responsabilité |
|---|---|
| `service_base_de_donnees.dart` | Profils utilisateurs, pitchs, agenda |
| `service_interactions.dart` | Messagerie, demandes mentorat, disponibilités |
| `service_utilisateurs.dart` | Découverte des membres DIAPALER |
| `service_authentification.dart` | Auth Firebase (connexion, inscription, reset) |
| `service_cache.dart` | Cache local `SharedPreferences` (offline-first) |
| `service_chatbot.dart` | API REST Anthropic (chatbot DIALI IA) |
| `service_partage.dart` | Partage social natif (share_plus) — pitch, profil, conseil DIALI |
| `service_wave.dart` | Paiement Premium Wave — lien marchand + activation Firebase |

---

## 1. Firebase Realtime Database

### 1.1 Configuration et initialisation

**Backend choisi :** Firebase Realtime Database — API WebSocket temps réel avec synchronisation offline automatique.

```dart
// lib/services/service_base_de_donnees.dart
import 'package:firebase_database/firebase_database.dart';
import '../data/profil_utilisateur.dart';

class DatabaseService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;
  static DatabaseReference _userRef(String uid) => _db.ref('users/$uid');
  static DatabaseReference get _pitchesRef => _db.ref('pitches');
}
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : projet DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

---

### 1.2 Structure complète de la base de données

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
│       │       ├── name        → "Téranga Mode"
│       │       ├── description → "Plateforme de mode africaine..."
│       │       ├── sector      → "Mode & Textile"
│       │       ├── step        → 2
│       │       └── totalSteps  → 5
│       ├── mentorsActive      → 2
│       ├── sessionsCount      → 8
│       ├── favoritesCount     → 5
│       ├── score              → 4.7
│       └── updatedAt          → 1748123456789 (ServerTimestamp)
│
├── pitches/
│   └── {timestamp}/
│       ├── id           → "1748123456789"
│       ├── userId       → "marieme@teki.sn"
│       ├── userName     → "Mariéme Tine"
│       ├── title        → "Téranga Mode"
│       ├── sector       → "Mode & Textile"
│       ├── description  → "Plateforme de vente de mode africaine..."
│       ├── amount       → "5000000"
│       └── createdAt    → 1748123456789 (ServerTimestamp)
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
│   └── {conversationId}/   (clé = sorted [uid1, uid2] joint par "-")
│       ├── id              → "uid1-uid2"
│       ├── user1Id         → "uid1"
│       ├── user2Id         → "uid2"
│       ├── user1Name       → "Mariéme Tine"
│       ├── user2Name       → "Ibrahima Sall"
│       ├── lastMessage     → "À bientôt !"
│       ├── lastMessageTime → "2025-05-24T10:05:00.000"
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
│       ├── status       → "pending" | "accepted" | "rejected"
│       ├── createdAt    → "2025-05-20T09:00:00.000"
│       └── respondedAt  → "2025-05-21T14:30:00.000"
│
├── availability/
│   └── {userId}/
│       ├── userId       → "uid_mentor"
│       ├── slots/
│       │   └── {index}/ → {"day": "Lundi", "startTime": "09:00", "endTime": "12:00"}
│       └── updatedAt    → "2025-05-24T10:00:00.000"
│
└── agenda/
    └── {uid}/
        └── {eventId}/
            ├── id          → "1748123456789"
            ├── title       → "Session de mentorat"
            ├── date        → "2025-06-15"
            ├── time        → "10:00"
            ├── type        → "mentorat" | "reunion" | "evenement"
            └── description → "Revue du business plan"
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud users/ avec un profil**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud pitches/ avec des pitchs publiés**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : nœud messages/ et conversations/**
> *(Insérer ici la capture d'écran)*

---

### 1.3 CREATE — Créer un profil utilisateur

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
  final profile = UserProfile(
    firstName: parts.first,
    lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    email: _email.text.trim(),
    phone: '+221 ${_phone.text.trim()}',
    role: _roleLabel(_role),       // "Entrepreneur" | "Mentor" | "Investisseur"
    photoBase64: _photoBase64,
    interests: _interests.toList()..sort(),
    projects: const [],
    city: _city,
    sector: _sector,
    bio: _bio.text.trim(),
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

    // Tri par date décroissante (plus récent en premier)
    list.sort((a, b) {
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
  final updated = _initial.copyWith(
    firstName:   _firstName.text.trim(),
    lastName:    _lastName.text.trim(),
    bio:         _bio.text.trim(),
    photoBase64: _photoBase64,
    interests:   _interests.toList()..sort(),
    city:        _city,
    country:     _country,
    sector:      _sector,
    birthDate:   _birthDate,
  );

  // Mise à jour locale immédiate (UX réactive) + cache + Firebase auto
  UserProfileController.update(updated);

  // Retour avec confirmation
  if (!mounted) return;
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Profil mis à jour avec succès ✓'),
      backgroundColor: AppColors.green,
    ),
  );
}
```

> **📸 CAPTURE D'ÉCRAN — Profil mis à jour après modification**
> *(Insérer ici la capture d'écran)*

---

### 1.7 CREATE — Publier un pitch dans le nœud global

Écriture dans `pitches/` (accessible à tous les utilisateurs, pas seulement au propriétaire).

```dart
// service_base_de_donnees.dart
static Future<void> publishPitch({
  required String userId,
  required String userName,
  required String title,
  required String sector,
  required String description,
  required String amount,
}) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  await _db.ref('pitches/$id').set({
    'id': id,
    'userId': userId,
    'userName': userName,
    'title': title,
    'sector': sector,
    'description': description,
    'amount': amount,
    'createdAt': ServerValue.timestamp,  // Timestamp côté serveur Firebase
  });
}
```

**Double sauvegarde depuis `page_pitch.dart` :**
```dart
// Double sauvegarde : profil entrepreneur (projects/) + nœud global pitches/
final project = Project(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: title, description: description, sector: sector,
);
final updated = profile.copyWith(
  projects: [...profile.projects, project],
);
UserProfileController.update(updated);          // Profil entrepreneur (via update())
await DatabaseService.publishPitch(             // Nœud global visible par tous
  userId: profile.email,
  userName: profile.fullName,
  title: title,
  sector: sector,
  description: description,
  amount: _amount.text.trim(),
);
```

> **📸 CAPTURE D'ÉCRAN — Pitch soumis visible dans la console Firebase (pitches/)**
> *(Insérer ici la capture d'écran)*

---

### 1.8 UPDATE — Activer le statut Premium (Wave)

Après confirmation du paiement Wave, un `update()` partiel marque l'utilisateur Premium :

```dart
// service_base_de_donnees.dart
static Future<void> setPremium({
  required String uid,
  required String plan,   // 'entrepreneur' | 'mentor' | 'investisseur'
}) async {
  await _userRef(uid).update({
    'isPremium': true,
    'premiumPlan': plan,
    'premiumSince': ServerValue.timestamp,
  });
}
```

**Depuis `service_wave.dart` :**
```dart
// Après que l'utilisateur confirme son paiement Wave
await WaveService.activatePremium(plan);
// → Firebase : users/{uid}/isPremium = true
```

> **📸 CAPTURE D'ÉCRAN — Firebase Console : nœud users/{uid} avec isPremium = true**
> *(Insérer ici la capture d'écran)*

---

### 1.9 DELETE — Déconnexion et nettoyage

```dart
// feuille_profil.dart — Déconnexion complète (3 étapes)
await CacheService.clear();                // Vide le cache SharedPreferences
NotificationService.reset();              // Vide les notifications en mémoire
UserProfileController.reset();            // Réinitialise le profil en mémoire
appTabIndex.value = 0;                    // Retour à l'onglet Accueil
await AuthService.signOut();             // Révoque la session Firebase Auth

// Redirection vers l'écran de sélection de rôle
if (!mounted) return;
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
  (_) => false,
);
```

> **📸 CAPTURE D'ÉCRAN — Dialog de confirmation de déconnexion**
> *(Insérer ici la capture d'écran)*

---

### 1.9 Sérialisation JSON ↔ Dart

```dart
// Dart → JSON (envoi à Firebase)
static Map<String, dynamic> _toMap(UserProfile p) => {
  'firstName':      p.firstName,
  'lastName':       p.lastName,
  'email':          p.email,
  'phone':          p.phone,
  'gender':         p.gender.serialized,     // Enum → String
  'birthDate':      p.birthDate?.toIso8601String(),
  'address':        p.address,
  'city':           p.city,
  'country':        p.country,
  'sector':         p.sector,
  'role':           p.role,
  'bio':            p.bio,
  'linkedin':       p.linkedin,
  'photoBase64':    p.photoBase64,
  'interests':      p.interests,             // List<String>
  'projects':       p.projects.map(_projectToMap).toList(),
  'mentorsActive':  p.mentorsActive,
  'sessionsCount':  p.sessionsCount,
  'favoritesCount': p.favoritesCount,
  'score':          p.score,
  'yearsExperience': p.yearsExperience,
  'investmentRange': p.investmentRange,
  'updatedAt':      ServerValue.timestamp,
};

// JSON → Dart (lecture depuis Firebase)
// ⚠️ Casting sécurisé obligatoire : Firebase retourne des Map<Object?, Object?> 
//    que Dart ne peut pas caster directement en Map<String, dynamic>
static UserProfile _fromMap(Map<String, dynamic> m) {
  // Désérialisation sécurisée des listes (Firebase peut retourner List ou Map)
  final rawInterests = m['interests'];
  final interests = <String>[];
  if (rawInterests is List) {
    for (final v in rawInterests) interests.add(v.toString());
  }

  // Désérialisation des projets
  final rawProjects = m['projects'];
  final projects = <Project>[];
  if (rawProjects is Map) {
    for (final v in rawProjects.values) {
      if (v is Map) {
        final pm = Map<String, dynamic>.from(v);
        projects.add(Project(
          id: pm['id']?.toString() ?? '',
          name: pm['name']?.toString() ?? '',
          description: pm['description']?.toString() ?? '',
          sector: pm['sector']?.toString() ?? '',
          step: (pm['step'] as num?)?.toInt() ?? 1,
          totalSteps: (pm['totalSteps'] as num?)?.toInt() ?? 5,
        ));
      }
    }
  }

  DateTime? birth;
  final rawBirth = m['birthDate']?.toString();
  if (rawBirth != null && rawBirth.isNotEmpty) {
    birth = DateTime.tryParse(rawBirth);
  }

  return UserProfile(
    firstName:      m['firstName']?.toString()  ?? '',
    lastName:       m['lastName']?.toString()   ?? '',
    email:          m['email']?.toString()       ?? '',
    phone:          m['phone']?.toString()       ?? '',
    gender:         Gender.fromString(m['gender']?.toString()),
    birthDate:      birth,
    address:        m['address']?.toString()    ?? '',
    city:           m['city']?.toString()       ?? 'Dakar',
    country:        m['country']?.toString()    ?? 'Sénégal',
    sector:         m['sector']?.toString()     ?? 'Autre',
    role:           m['role']?.toString()       ?? 'Entrepreneur',
    bio:            m['bio']?.toString()        ?? '',
    linkedin:       m['linkedin']?.toString()   ?? '',
    photoBase64:    m['photoBase64']?.toString() ?? '',
    interests:      interests,
    projects:       projects,
    mentorsActive:  (m['mentorsActive'] as num?)?.toInt()    ?? 0,
    sessionsCount:  (m['sessionsCount'] as num?)?.toInt()    ?? 0,
    favoritesCount: (m['favoritesCount'] as num?)?.toInt()   ?? 0,
    score:          (m['score'] as num?)?.toDouble()         ?? 0.0,
    yearsExperience:(m['yearsExperience'] as num?)?.toInt()  ?? 0,
    investmentRange: m['investmentRange']?.toString()        ?? '',
  );
}
```

---

## 2. Service d'interactions (`service_interactions.dart`)

L'`InteractionsService` gère toutes les interactions entre utilisateurs : **demandes de mentorat**, **messagerie temps réel** et **disponibilités des mentors**.

### 2.1 Demandes de mentorat (mentorRequests)

```dart
// lib/services/service_interactions.dart
import 'package:firebase_database/firebase_database.dart';
import '../data/interactions.dart';

class InteractionsService {
  static final _db = FirebaseDatabase.instance.ref();

  // ── CREATE : Envoyer une demande de mentorat
  static Future<void> sendMentorRequest({
    required String fromUserId,
    required String toUserId,
    required String fromName,
    required String toName,
    required String message,
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
    );
    await _db.child('mentorRequests/$id').set(request.toJson());
  }

  // ── READ (stream) : Demandes reçues par un utilisateur
  static Stream<List<MentorRequest>> getReceivedRequests(String userId) {
    return _db.child('mentorRequests').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map && v['toUserId'] == userId)
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

  // ── UPDATE : Rejeter une demande
  static Future<void> rejectRequest(String requestId) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.rejected.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Écran "Demandes reçues" avec liste des requêtes**
> *(Insérer ici la capture d'écran)*

---

### 2.2 Messagerie temps réel (messages + conversations)

```dart
// ── CREATE : Envoyer un message + mise à jour de la conversation
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
  
  // 1. Écriture dans messages/{conversationId}/{msgId}
  final message = ChatMessage(
    id: msgId,
    senderId: senderId,
    senderName: senderName,
    recipientId: recipientId,
    text: text,
    timestamp: now,
    isRead: false,
  );
  await _db.child('messages/$conversationId/$msgId').set(message.toJson());

  // 2. Mise à jour de conversations/ (compteur non lus + dernier message)
  final ids = [senderId, recipientId]..sort();
  final countSnap =
      await _db.child('conversations/$conversationId/unreadCount').get();
  final prevUnread = countSnap.value is int ? (countSnap.value as int) : 0;
  
  await _db.child('conversations/$conversationId').set(Conversation(
    id: conversationId,
    user1Id: ids[0],
    user2Id: ids[1],
    user1Name: ids[0] == senderId ? senderName : recipientName,
    user2Name: ids[0] == senderId ? recipientName : senderName,
    lastMessage: text,
    lastMessageTime: now,
    unreadCount: prevUnread + 1,
  ).toJson());
}

// ── READ (stream) : Messages d'une conversation (WebSocket)
static Stream<List<ChatMessage>> getMessages(String conversationId) {
  return _db.child('messages/$conversationId').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];
    return data.values
        .map<ChatMessage>((v) =>
            ChatMessage.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  });
}

// ── READ (stream) : Toutes les conversations d'un utilisateur
static Stream<List<Conversation>> getConversations(String userId) {
  return _db.child('conversations').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];
    return data.values
        .where((v) => v is Map &&
            (v['user1Id'] == userId || v['user2Id'] == userId))
        .map<Conversation>((v) =>
            Conversation.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  });
}

// ── UPDATE : Marquer la conversation comme lue (réinitialise le compteur)
static Future<void> markConversationAsRead(String conversationId) async {
  await _db.child('conversations/$conversationId')
      .update({'unreadCount': 0});
}

// ── Génère un ID de conversation déterministe entre deux utilisateurs
static String generateConversationId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort(); // Tri alphabétique pour cohérence
  return '${ids[0]}-${ids[1]}';
}
```

> **📸 CAPTURE D'ÉCRAN — Messagerie : liste des conversations (avec compteur non lus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Messagerie : conversation temps réel**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Disponibilités mentor (availability)

```dart
// ── READ (stream) : Disponibilités d'un mentor
static Stream<Availability?> getAvailability(String userId) {
  return _db.child('availability/$userId').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return null;
    return Availability.fromJson(Map<String, dynamic>.from(data));
  });
}

// ── UPDATE : Mettre à jour les disponibilités
static Future<void> updateAvailability(Availability availability) async {
  await _db
      .child('availability/${availability.userId}')
      .set(availability.toJson());
}
```

> **📸 CAPTURE D'ÉCRAN — Planning du mentor : gestion des créneaux disponibles**
> *(Insérer ici la capture d'écran)*

---

## 3. Service de découverte des membres (`service_utilisateurs.dart`)

Le `UsersService` lit en temps réel les membres DIAPALER (mentors + investisseurs) inscrits via `SignUpPage` pour les afficher dans la page Matching au-dessus des profils pré-chargés.

```dart
// lib/services/service_utilisateurs.dart
import 'package:firebase_database/firebase_database.dart';
import '../data/donnees_mentors.dart';
import 'service_authentification.dart';

class UsersService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  /// Récupère les membres inscrits (Mentor + Investisseur uniquement).
  /// L'utilisateur courant est exclu de la liste.
  static Future<List<Mentor>> listMembers() async {
    final snap = await _db.ref('users').get();
    if (!snap.exists || snap.value == null) return [];

    // Cast sécurisé : Firebase retourne Map<Object?, Object?>
    final map = Map<String, dynamic>.from(snap.value as Map);
    final currentUid = AuthService.currentUid;

    final members = <Mentor>[];
    for (final entry in map.entries) {
      final uid = entry.key;
      if (uid == currentUid) continue;           // Exclure soi-même
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      
      // Filtrer : uniquement Mentor et Investisseur
      final role = (m['role']?.toString() ?? '').trim();
      if (role != 'Mentor' && role != 'Investisseur') continue;

      final firstName = m['firstName']?.toString() ?? '';
      final lastName  = m['lastName']?.toString()  ?? '';
      final fullName  = '$firstName $lastName'.trim();
      if (fullName.isEmpty) continue;

      // Construire le Mentor avec les données réelles Firebase
      members.add(Mentor(
        uid:        uid,
        name:       fullName,
        title:      m['bio']?.toString().split('\n').first ?? role,
        city:       m['city']?.toString() ?? 'Dakar',
        sectors:    _parseInterests(m['interests']),
        role:       role,
        photoBase64: m['photoBase64']?.toString() ?? '',
        compatibility: 80,   // Score par défaut pour un membre vérifié
        // ...autres champs
      ));
    }
    return members;
  }
}
```

**Intégration dans `page_matching.dart` :**
```dart
// Les membres réels sont chargés au démarrage et placés EN TÊTE de liste
// avec un badge "Membre DIAPALER" distinctif

List<Mentor> _members = const [];  // Membres Firebase
bool _loadingMembers = true;

@override
void initState() {
  super.initState();
  _loadMembers();  // Charge les membres DIAPALER depuis Firebase
}

Future<void> _loadMembers() async {
  try {
    final members = await UsersService.listMembers();
    if (!mounted) return;
    setState(() { _members = members; _loadingMembers = false; });
  } catch (_) {
    if (!mounted) return;
    setState(() => _loadingMembers = false);
  }
}

// Fusion : membres Firebase (badge DIAPALER) + profils statiques sénégalais
List<Mentor> get _filtered {
  final all = [..._members, ...mentors]; // Membres réels en priorité
  // Filtrage + tri...
}
```

> **📸 CAPTURE D'ÉCRAN — Matching : membres DIAPALER réels en tête de liste**
> *(Insérer ici la capture d'écran)*

---

## 4. Anthropic Claude API (Chatbot DIALI IA)

### 4.1 Architecture sécurisée — Proxy Cloudflare Worker

Pour des raisons de **sécurité**, la clé API Anthropic n'est **jamais** embarquée dans le code Flutter. L'appel passe par un **Cloudflare Worker** déployé côté serveur qui détient la clé et joue le rôle de proxy.

```
┌─────────────────┐   HTTP POST (JSON)   ┌────────────────────────────┐
│  Flutter App    │ ──────────────────▶  │  Cloudflare Worker         │
│  (page_chatbot) │                      │  diali-proxy.sirimambodj   │
│                 │   ◀── réponse texte  │  .workers.dev/chat         │
└─────────────────┘                      └────────────┬───────────────┘
                                                       │  HTTP POST + x-api-key
                                                       ▼
                                         ┌─────────────────────────────┐
                                         │  Anthropic Messages API      │
                                         │  claude-haiku-4-5-20251001  │
                                         └─────────────────────────────┘
```

| Paramètre | Valeur |
|---|---|
| **API** | Anthropic Messages API (via proxy) |
| **Proxy URL** | `https://diali-proxy.sirimambodj.workers.dev/chat` |
| **Méthode HTTP** | POST |
| **Modèle** | `claude-haiku-4-5-20251001` |
| **Authentification** | Aucune clé côté client — gérée côté Worker |
| **Format** | JSON (Content-Type: application/json) |
| **Package Flutter** | `http: ^1.2.2` |

### 4.2 Service chatbot (`service_chatbot.dart`)

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
  /// Proxy Cloudflare Worker — la clé Anthropic est côté serveur (sécurité).
  static const _proxyUrl =
      'https://diali-proxy.sirimambodj.workers.dev/chat';

  static const _model = 'claude-haiku-4-5-20251001';

  /// Construit le prompt système personnalisé selon le profil de l'utilisateur.
  static String _systemPrompt({
    required String userName,
    required String userRole,
    required String userSector,
    required String userCity,
  }) {
    return '''Tu es DIALI, l\'assistant IA de DIAPALER AFRICA — la plateforme
qui connecte entrepreneurs, mentors et investisseurs au Sénégal.

Tu accompagnes $userName, $userRole dans le secteur $userSector basé(e) à $userCity.

Tes domaines d\'expertise :
• Stratégie entrepreneuriale et développement de projet au Sénégal
• Financement : DER/FJ (100 000 à 30 000 000 FCFA), PAVIE 2, Be Yes (18-40 ans), ADPME, BNDE
• Conditions DER/FJ : nationalité sénégalaise, 18-35 ans, CNI + plan d\'affaires + photos passeport
• Préparation de pitchs et dossiers investisseurs
• Marketing digital, Made in Sénégal
• Mise en relation mentors et investisseurs via DIAPALER

Directives :
- Réponds en français, bienveillant et adapté au contexte africain
- Utilise ponctuellement des mots en wolof (Jërejëf, Baraka, Ndank ndank…)
- Conseils actionnables, 3-4 paragraphes maximum
- Pour le financement, cite les montants en FCFA et conditions précises''';
  }

  /// Envoie la conversation au proxy → Anthropic et retourne la réponse texte.
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
      return data['content'][0]['text'] as String;
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

```dart
class _ChatbotPageState extends State<ChatbotPage> {
  final _messages = <ChatbotMessage>[];   // Historique typé
  final _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    final profile = UserProfileController.profile.value;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatbotMessage(role: 'user', content: text));
      _loading = true;
    });
    _scrollToBottom();

    try {
      // Appel HTTP POST → proxy Cloudflare → Anthropic API
      final reply = await ChatbotService.sendMessage(
        messages: _messages,
        userName: profile.firstName,       // Prénom pour personnalisation
        userRole: profile.role,            // Entrepreneur / Mentor / Investisseur
        userSector: profile.sector,        // Secteur d'activité
        userCity: profile.city,            // Ville (Dakar, Saint-Louis…)
      );
      setState(() {
        _messages.add(ChatbotMessage(role: 'assistant', content: reply));
      });
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.red),
      );
      setState(() => _messages.removeLast()); // Retire le msg utilisateur si échec
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

| Opération | Service | Nœud Firebase / Endpoint | Déclenché par |
|---|---|---|---|
| **CREATE** profil | `DatabaseService` | `users/{uid}.set()` | Inscription |
| **CREATE** pitch (nœud global) | `DatabaseService` | `pitches/{id}.set()` | Dépôt de pitch |
| **CREATE** message | `InteractionsService` | `messages/{conv}/{id}.set()` | Envoi chat |
| **CREATE** conversation | `InteractionsService` | `conversations/{id}.set()` | 1er message |
| **CREATE** événement agenda | `DatabaseService` | `agenda/{uid}/{id}.set()` | Ajout agenda |
| **CREATE** demande mentorat | `InteractionsService` | `mentorRequests/{id}.set()` | Envoi demande |
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
| **DELETE** session | `AuthService` | `signOut()` | Déconnexion |
| **DELETE** cache local | `CacheService` | `prefs.remove(key)` | Déconnexion |
| **POST** message IA | `ChatbotService` | `/v1/messages` (HTTP POST) | Chat DIALI |

> **📸 CAPTURE D'ÉCRAN — Console Firebase : messages en temps réel dans messages/**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 2

DIAPALER AFRICA consomme pleinement des API externes avec toutes les opérations CRUD :

| Critère | Détail | Statut |
|---|---|---|
| API REST intégrée | Firebase Realtime Database + Anthropic Claude | ✅ |
| Récupérer des données | `readUserProfile()`, `getPitches()`, `getMessages()`, `getConversations()` | ✅ |
| Ajouter des données | `createUserProfile()`, `publishPitch()`, `sendMessage()`, `sendMentorRequest()` | ✅ |
| Modifier des données | `updateUserProfile()`, `acceptRequest()`, `updateAvailability()` | ✅ |
| Supprimer des données | `signOut()` + `CacheService.clear()` (déconnexion) | ✅ |
| Backend supporté | Firebase (listé dans les consignes) | ✅ |
| Sérialisation JSON | `_toMap()` / `_fromMap()` avec cast sécurisé | ✅ |
| Cache offline-first | `CacheService` (SharedPreferences) | ✅ (bonus) |
| Découverte membres | `UsersService.listMembers()` | ✅ (bonus) |
| Chatbot IA | API Anthropic Claude via HTTP REST | ✅ (bonus) |

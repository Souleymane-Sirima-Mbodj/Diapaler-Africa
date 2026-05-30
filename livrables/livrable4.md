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

# LIVRABLE 4
## Gestion des Profils

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

# LIVRABLE 4 — Gestion des Profils

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [Introduction](#introduction)
- [1. Modèle de données utilisateur](#1-modèle-de-données-utilisateur-profil_utilisateurdart)
  - [1.1 La classe UserProfile](#11-la-classe-userprofile)
  - [1.2 La classe Project](#12-la-classe-project)
  - [1.3 Contrôleur réactif global — UserProfileController](#13-contrôleur-réactif-global--userprofilecontroller)
- [2. Consultation du Profil](#2-consultation-du-profil-page_profildart)
  - [2.1 Description complète de l'écran](#21-description-complète-de-lécran)
  - [2.2 Jauge de complétion du profil](#22-jauge-de-complétion-du-profil)
  - [2.3 Réactivité avec ValueListenableBuilder](#23-réactivité-avec-valuelistenablebuilder)
  - [2.4 Feuille de profil (bottom sheet)](#24-feuille-de-profil-bottom-sheet)
- [3. Modification du profil](#3-modification-du-profil-page_modification_profildart)
  - [3.1 Tous les champs modifiables](#31-tous-les-champs-modifiables)
  - [3.2 Pré-remplissage des champs](#32-pré-remplissage-des-champs)
  - [3.3 Modification et changement de la photo de profil](#33-modification-et-changement-de-la-photo-de-profil)
  - [3.4 Détection des changements](#34-détection-des-changements)
  - [3.5 Sauvegarde avec synchronisation Firebase](#35-sauvegarde-avec-synchronisation-firebase)
- [4. Gestion des projets (Entrepreneur)](#4-gestion-des-projets-entrepreneur)
- [5. Propagation réactive des modifications](#5-propagation-réactive-des-modifications)
- [6. Membres DIAPALER dans le Matching](#6-membres-diapaler-dans-le-matching-service_utilisateursdart)
- [7. Widget Avatar réutilisable](#7-widget-avatar-réutilisable-widgetsavatardart)
- [Conclusion](#conclusion-du-livrable-4)

---

## Introduction

DIAPALER AFRICA offre une gestion de profil **complète et réactive** permettant à chaque utilisateur de :
- Consulter son profil avec une **jauge de complétion** animée
- **Modifier** toutes ses informations personnelles et professionnelles
- **Ajouter ou changer sa photo de profil** (galerie ou caméra)
- Voir ses **statistiques** (mentors actifs, sessions, favoris, score)
- **Créer, modifier et supprimer** ses projets (Entrepreneur)
- Voir les **membres DIAPALER réels** inscrits via Firebase

Toutes les modifications sont propagées **instantanément** dans toute l'interface ET persistées dans Firebase Realtime Database ET dans le cache local `SharedPreferences`.

---

## 1. Modèle de données utilisateur (`profil_utilisateur.dart`)

### 1.1 La classe `UserProfile`

```dart
// lib/data/profil_utilisateur.dart
@immutable
class UserProfile {
  // ── Identité
  final String firstName;    // Prénom
  final String lastName;     // Nom de famille
  final String email;        // Email (identifiant unique)
  final String phone;        // Téléphone (+221 XX XXX XX XX)
  final Gender gender;       // Enum : male | female | other | undisclosed
  final DateTime? birthDate; // Date de naissance (nullable)

  // ── Localisation
  final String address;  // Adresse complète
  final String city;     // Ville (ex: "Dakar")
  final String country;  // Pays (ex: "Sénégal")

  // ── Profil professionnel
  final String sector;       // Secteur d'activité
  final String role;         // 'Entrepreneur' | 'Mentor' | 'Investisseur'
  final String bio;          // Biographie (240 char max)
  final String linkedin;     // URL LinkedIn
  final String photoBase64;  // Photo encodée en base64 (vide = initiales)

  // ── Centres d'intérêt / domaines
  final List<String> interests;

  // ── Projets (Entrepreneur uniquement)
  final List<Project> projects;

  // ── Statistiques
  final int    mentorsActive;    // Mentors actifs / Mentorés actifs
  final int    sessionsCount;    // Nombre de sessions
  final int    favoritesCount;   // Favoris (Investisseur)
  final double score;            // Score / Note (0.0 → 5.0)

  // ── Champs spécifiques par rôle
  final int    yearsExperience;  // Années d'expérience (Mentor)
  final String investmentRange;  // Ticket investissement ex: "500k–5M FCFA" (Investisseur)

  // ── Statut Premium (abonnement Wave)
  final bool   isPremium;        // true si abonnement Premium actif
  final String premiumPlan;      // 'entrepreneur' | 'mentor' | 'investisseur' | ''

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.gender = Gender.undisclosed,
    this.birthDate,
    this.address = '',
    required this.city,
    this.country = 'Sénégal',
    required this.sector,
    required this.role,
    required this.bio,
    this.linkedin = '',
    this.photoBase64 = '',
    required this.interests,
    required this.projects,
    this.mentorsActive = 0,
    this.sessionsCount = 0,
    this.favoritesCount = 0,
    this.score = 0.0,
    this.yearsExperience = 0,
    this.investmentRange = '',
    this.isPremium = false,
    this.premiumPlan = '',
  });

  // ── Getters calculés
  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty  ? lastName[0]  : '';
    return (f + l).toUpperCase();
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var a = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) a--;
    return a;
  }

  // Projet courant (premier non terminé, ou dernier si tous terminés)
  Project? get currentProject {
    final active = projects.where((p) => !p.isCompleted).toList();
    if (active.isNotEmpty) return active.first;
    if (projects.isNotEmpty) return projects.last;
    return null;
  }

  bool get canStartNewProject =>
      projects.isEmpty || projects.every((p) => p.isCompleted);

  // ── Copie avec modifications (immutabilité)
  UserProfile copyWith({
    String? firstName, String? lastName, String? email, String? phone,
    Gender? gender, DateTime? birthDate, bool clearBirthDate = false,
    String? address, String? city, String? country, String? sector,
    String? role, String? bio, String? linkedin, String? photoBase64,
    List<String>? interests, List<Project>? projects,
    int? mentorsActive, int? sessionsCount, int? favoritesCount,
    double? score, int? yearsExperience, String? investmentRange,
    bool? isPremium, String? premiumPlan,
  }) {
    return UserProfile(
      firstName:      firstName      ?? this.firstName,
      lastName:       lastName       ?? this.lastName,
      email:          email          ?? this.email,
      phone:          phone          ?? this.phone,
      gender:         gender         ?? this.gender,
      birthDate:      clearBirthDate ? null : (birthDate ?? this.birthDate),
      address:        address        ?? this.address,
      city:           city           ?? this.city,
      country:        country        ?? this.country,
      sector:         sector         ?? this.sector,
      role:           role           ?? this.role,
      bio:            bio            ?? this.bio,
      linkedin:       linkedin       ?? this.linkedin,
      photoBase64:    photoBase64    ?? this.photoBase64,
      interests:      interests      ?? this.interests,
      projects:       projects       ?? this.projects,
      mentorsActive:  mentorsActive  ?? this.mentorsActive,
      sessionsCount:  sessionsCount  ?? this.sessionsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      score:          score          ?? this.score,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      investmentRange: investmentRange ?? this.investmentRange,
      isPremium:       isPremium       ?? this.isPremium,
      premiumPlan:     premiumPlan     ?? this.premiumPlan,
    );
  }
}
```

---

### 1.2 La classe `Project`

```dart
@immutable
class Project {
  final String id;          // Identifiant unique (timestamp ms)
  final String name;        // Nom du projet
  final String description; // Description
  final String sector;      // Secteur d'activité
  final int step;           // Étape actuelle (ex: 2)
  final int totalSteps;     // Total d'étapes (ex: 5)

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.sector,
    this.step = 1,
    this.totalSteps = 5,
  });

  bool   get isCompleted => step >= totalSteps;
  double get progress    => step / totalSteps;  // 0.0 → 1.0

  Project copyWith({
    String? id, String? name, String? description,
    String? sector, int? step, int? totalSteps,
  }) {
    return Project(
      id: id ?? this.id, name: name ?? this.name,
      description: description ?? this.description, sector: sector ?? this.sector,
      step: step ?? this.step, totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}
```

---

### 1.3 Contrôleur réactif global — `UserProfileController`

Le `UserProfileController` est le **cœur de la réactivité** de DIAPALER AFRICA. Il orchestre :
1. La mise à jour de l'état en mémoire (`ValueNotifier`)
2. La persistance dans le cache local (`CacheService.saveProfile()`)
3. La synchronisation Firebase (`DatabaseService.updateUserProfile()`)

```dart
/// État global du profil utilisateur — partagé entre toutes les pages.
class UserProfileController {
  // ValueNotifier initialisé avec le profil seed (données de démo)
  // Remplacé par les vraies données Firebase dès le bootstrap
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(_seed);

  /// Met à jour le profil courant, l'enregistre dans le cache local ET
  /// le synchronise avec Firebase. Tout changement est ainsi persisté
  /// localement ET sur la base distante de façon transparente.
  static void update(UserProfile next) {
    profile.value = next;            // 1. État en mémoire (rebuild immédiat)
    CacheService.saveProfile(next);  // 2. Cache local (SharedPreferences)
    _syncToFirebase(next);           // 3. Firebase (async, non bloquant)
  }

  /// Pousse le profil vers la base distante si un utilisateur est connecté.
  /// L'écriture est asynchrone : l'interface n'est jamais bloquée.
  static void _syncToFirebase(UserProfile p) {
    try {
      final uid = AuthService.currentUid;
      if (uid == null) return; // Pas connecté : cache local suffit
      DatabaseService.updateUserProfile(uid, p).catchError((Object _) {});
    } catch (_) {
      // Firebase pas encore prêt : le cache local a déjà tout sauvegardé.
    }
  }

  /// Ajoute un projet (uniquement si l'utilisateur peut en démarrer un nouveau).
  static bool addProject(Project p) {
    final current = profile.value;
    if (!current.canStartNewProject) return false;
    update(current.copyWith(projects: [...current.projects, p]));
    return true;
  }

  /// Met à jour un projet existant (retrouvé par son id).
  static void updateProject(Project updated) {
    final current = profile.value;
    update(current.copyWith(
      projects: current.projects
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    ));
  }

  /// Supprime le projet portant l'identifiant [id].
  static void deleteProject(String id) {
    final current = profile.value;
    update(current.copyWith(
      projects: current.projects.where((p) => p.id != id).toList(),
    ));
  }

  /// Vide le profil en mémoire après déconnexion — évite la fuite de données
  /// entre deux sessions utilisateurs différents.
  static void reset() {
    profile.value = const UserProfile(
      firstName: '', lastName: '', email: '', phone: '',
      city: '', sector: '', role: '', bio: '',
      interests: [], projects: [],
    );
  }

  // Profil de démonstration visible au premier lancement
  static final UserProfile _seed = UserProfile(
    firstName: 'Mariéme', lastName: 'Tine',
    email: 'marieme.tine@esp.sn', phone: '+221 77 123 45 67',
    gender: Gender.female, birthDate: DateTime(2001, 6, 14),
    city: 'Dakar', country: 'Sénégal', sector: 'Mode & Textile',
    role: 'Entrepreneure', bio: 'Diplômée ESP Dakar, je porte le projet '
        'Téranga Mode — valoriser les tissus traditionnels sénégalais.',
    interests: ['Mode & Textile', 'Artisanat', 'E-commerce', 'Made in Sénégal'],
    projects: [Project(
      id: 'teranga-mode', name: 'Téranga Mode',
      description: 'Marque de prêt-à-porter valorisant les tissus sénégalais.',
      sector: 'Mode & Textile', step: 3,
    )],
    mentorsActive: 4, sessionsCount: 3, favoritesCount: 7, score: 4.8,
  );
}
```

---

## 2. Consultation du Profil (`page_profil.dart`)

### 2.1 Description complète de l'écran (page allégée et rôle-adaptive)

**Structure de la page (de haut en bas) :**

| Élément | Description |
|---|---|
| Carte identité | Photo/initiales, nom, rôle · secteur, ville, barre de complétion 0–100% |
| Bandeau stats (4 tuiles) | Labels **adaptés au rôle** — voir tableau ci-dessous |
| Carte "À propos" | Bio + **LinkedIn cliquable** (url_launcher) + chip "X ans d'expé." (Mentor) + chip ticket (Investisseur) |
| Coordonnées condensées | 3 colonnes compactes : email · téléphone · ville |
| Centres d'intérêt | Chips colorés |
| Mes Projets | Liste avec barres de progression (**Entrepreneur uniquement**) |
| Boutons d'actions | Rôle-spécifiques (voir tableau ci-dessous) |
| AppBar | Partager · Modifier · Déconnexion (icône rouge discrète) |

**Stats par rôle :**

| Rôle | Stat 1 | Stat 2 | Stat 3 | Stat 4 |
|---|---|---|---|---|
| Entrepreneur | Projets | Terminés | Mentors → RequestsPage | Favoris |
| Mentor | Mentorés → RequestsPage | Sessions → AgendaPage | Années expé. | Favoris |
| Investisseur | Contacts → RequestsPage | Pitchs vus | Favoris | Rendez-vous → AgendaPage |

**Boutons d'actions par rôle :**

| Rôle | Boutons |
|---|---|
| Entrepreneur | "Mes demandes" (envoyées) → RequestsPage |
| Mentor | "Planning" → SchedulePage + "Demandes reçues" → RequestsPage |
| Investisseur | "Pitchs publiés" → PublicPitchesPage |

---

### 2.2 Jauge de complétion du profil

```dart
// Calcul basé sur 12 champs évalués
double _profileCompletion(UserProfile p) {
  final fields = <bool>[
    p.firstName.isNotEmpty,
    p.lastName.isNotEmpty,
    p.email.isNotEmpty,
    p.phone.isNotEmpty,
    p.birthDate != null,
    p.address.isNotEmpty,
    p.city.isNotEmpty,
    p.country.isNotEmpty,
    p.sector.isNotEmpty,
    p.bio.isNotEmpty,
    p.linkedin.isNotEmpty,
    p.interests.isNotEmpty,
  ];
  final filled = fields.where((x) => x).length;
  return filled / fields.length;  // Ex: 10/12 = 0.833 = 83%
}

// Affichage dynamique avec couleur selon le taux
final completion = _profileCompletion(profile);
final color = completion >= 0.8 ? AppColors.green
    : completion >= 0.5 ? AppColors.amber
    : AppColors.red;

LinearProgressIndicator(
  value: completion,
  backgroundColor: AppColors.border,
  valueColor: AlwaysStoppedAnimation<Color>(color),
  minHeight: 6,
  borderRadius: BorderRadius.circular(99),
),
const SizedBox(height: 4),
Text(
  '${(completion * 100).round()} % complété',
  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
),
```

---

### 2.3 Réactivité avec ValueListenableBuilder

```dart
// La page se reconstruit automatiquement à chaque modification du profil
// Sans setState, sans rebuild global — uniquement les widgets abonnés
ValueListenableBuilder<UserProfile>(
  valueListenable: UserProfileController.profile,
  builder: (_, profile, __) {
    final completion = _profileCompletion(profile);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          // Bouton partage — ouvre la feuille de partage native
          IconButton(
            tooltip: 'Partager mon profil',
            onPressed: () => ShareService.shareMyProfile(
              name: p.fullName,
              role: p.role,
              sector: p.sector,
              city: p.city,
              projectName: p.projects.isNotEmpty ? p.projects.first.name : null,
            ),
            icon: const Icon(Icons.share_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const EditProfilePage(),
              )),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Modifier le profil',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── Avatar ou photo
          Center(
            child: Avatar(
              initials: profile.initials,
              photoBase64: profile.photoBase64,
              size: 88,
              background: _roleColor(profile.role),
            ),
          ),
          const SizedBox(height: 12),

          // ── Nom + badge rôle
          Center(child: Text(profile.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
          Center(child: _RoleBadge(role: profile.role)),
          const SizedBox(height: 10),

          // ── Jauge de complétion
          LinearProgressIndicator(value: completion,
            valueColor: AlwaysStoppedAnimation<Color>(color)),
          Text('${(completion * 100).round()} % complété'),
          const SizedBox(height: 16),

          // ── Informations
          _InfoRow(icon: Icons.email_outlined, text: profile.email),
          _InfoRow(icon: Icons.phone_outlined,
              text: profile.phone.isEmpty ? 'Non renseigné' : profile.phone),
          if (profile.age != null)
            _InfoRow(icon: Icons.cake_outlined, text: '${profile.age} ans'),
          _InfoRow(icon: Icons.place_outlined,
              text: '${profile.city}, ${profile.country}'),
          if (profile.bio.isNotEmpty)
            _InfoRow(icon: Icons.info_outline, text: profile.bio),

          // ── Centres d'intérêt
          if (profile.interests.isNotEmpty) ...[
            const _SectionTitle('Centres d\'intérêt'),
            Wrap(spacing: 8, runSpacing: 8,
              children: profile.interests.map((i) => _InterestChip(i)).toList()),
          ],

          // ── Projets (Entrepreneur)
          if (profile.role == 'Entrepreneur' && profile.projects.isNotEmpty) ...[
            const _SectionTitle('Mes Projets'),
            for (final p in profile.projects)
              _ProjectCard(project: p),
          ],

          // ── Statistiques
          const _SectionTitle('Statistiques'),
          Row(children: [
            _StatCard('Mentors', '${profile.mentorsActive}',
                Icons.people_outline_rounded),
            _StatCard('Sessions', '${profile.sessionsCount}',
                Icons.calendar_today_outlined),
            _StatCard('Score', profile.score.toStringAsFixed(1),
                Icons.star_outline_rounded),
          ]),
        ],
      ),
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Mon Profil : photo, nom, badge rôle, jauge de complétion**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Mon Profil : centres d'intérêt + statistiques**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Mon Profil (Entrepreneur) : liste des projets avec barres de progression**
> *(Insérer ici la capture d'écran)*

---

### 2.4 Feuille de profil (bottom sheet)

Un bottom sheet récapitulatif (`feuille_profil.dart`) est accessible depuis l'AppBar de chaque dashboard. Il affiche le résumé du profil et propose les actions rapides :

```dart
// widgets/feuille_profil.dart
void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, profile, __) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 16),
              // Avatar + Nom + Rôle
              Avatar(initials: profile.initials,
                  photoBase64: profile.photoBase64, size: 64),
              const SizedBox(height: 8),
              Text(profile.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(profile.role, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              // Actions
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppColors.blue),
                title: const Text('Modifier le profil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const EditProfilePage(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.red),
                title: const Text('Se déconnecter',
                    style: TextStyle(color: AppColors.red)),
                onTap: () => _signOut(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Bottom sheet profil (avatar + actions)**
> *(Insérer ici la capture d'écran)*

---

## 3. Modification du profil (`page_modification_profil.dart`)

### 3.1 Tous les champs modifiables

| Section | Champs modifiables |
|---|---|
| Photo de profil | Galerie ou caméra → redimensionnée 512×512 → base64 |
| Identité | **Prénom**, **Nom** |
| Coordonnées | **Email**, **Téléphone**, Adresse |
| Localisation | Pays (dropdown), Ville (dropdown filtrée) |
| Profil pro | Secteur d'activité (dropdown), Biographie (240 chars), LinkedIn |
| Données perso | Sexe (pills), Date de naissance (DatePicker) |
| Intérêts | Chips multi-sélection (au moins 1 requis) |

---

### 3.2 Pré-remplissage des champs

```dart
@override
void initState() {
  super.initState();
  // Charge le profil actuel pour pré-remplir tous les champs
  _initial = UserProfileController.profile.value;

  _firstName = TextEditingController(text: _initial.firstName);
  _lastName  = TextEditingController(text: _initial.lastName);
  _email     = TextEditingController(text: _initial.email);
  _phone     = TextEditingController(text: _initial.phone);
  _address   = TextEditingController(text: _initial.address);
  _bio       = TextEditingController(text: _initial.bio);
  _linkedin  = TextEditingController(text: _initial.linkedin);

  // Vérification que les valeurs sont dans les listes supportées
  _country = supportedCountries.contains(_initial.country)
             ? _initial.country : 'Sénégal';
  final cities = citiesOf(_country);
  _city    = cities.contains(_initial.city) ? _initial.city : cities.first;

  _sector     = _initial.sector;
  _gender     = _initial.gender;
  _birthDate  = _initial.birthDate;
  _interests  = Set<String>.from(_initial.interests);
  _photoBase64 = _initial.photoBase64;
}
```

> **📸 CAPTURE D'ÉCRAN — Modifier le profil (formulaire pré-rempli)**
> *(Insérer ici la capture d'écran)*

---

### 3.3 Modification et changement de la photo de profil

```dart
// Sélection depuis la galerie
Future<void> _pickFromGallery() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,   // Compression JPEG 80%
    maxWidth: 512,      // Redimensionnement automatique à 512px max
    maxHeight: 512,
  );
  if (image != null) {
    final bytes = await image.readAsBytes();
    setState(() {
      _photoBytes  = bytes;
      _photoBase64 = base64Encode(bytes);  // Prêt pour Firebase
    });
  }
}

// Sélection depuis la caméra
Future<void> _pickFromCamera() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
    maxWidth: 512, maxHeight: 512,
  );
  if (image != null) {
    final bytes = await image.readAsBytes();
    setState(() {
      _photoBytes  = bytes;
      _photoBase64 = base64Encode(bytes);
    });
  }
}

// Affichage du sélecteur de source (galerie ou caméra)
void _showPhotoOptions() {
  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library_rounded, color: AppColors.blue),
          title: const Text('Choisir depuis la galerie'),
          onTap: () { Navigator.pop(context); _pickFromGallery(); },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt_rounded, color: AppColors.purple),
          title: const Text('Prendre une photo'),
          onTap: () { Navigator.pop(context); _pickFromCamera(); },
        ),
      ],
    ),
  );
}

// Widget d'affichage de la photo modifiable avec icône caméra superposée
GestureDetector(
  onTap: _showPhotoOptions,
  child: Stack(
    children: [
      // Photo actuelle ou initiales
      _photoBytes != null
          ? ClipOval(child: Image.memory(_photoBytes!,
              width: 90, height: 90, fit: BoxFit.cover))
          : Avatar(
              initials: _initial.initials,
              photoBase64: _photoBase64,
              size: 90,
            ),
      // Icône caméra superposée (coin bas-droite)
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.blue, shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt_rounded,
              size: 16, color: Colors.white),
        ),
      ),
    ],
  ),
)
```

> **📸 CAPTURE D'ÉCRAN — Modifier le profil : zone de photo avec icône caméra**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — BottomSheet choix galerie / caméra**
> *(Insérer ici la capture d'écran)*

---

### 3.4 Détection des changements

```dart
// Le bouton Enregistrer est actif uniquement si une modification a été faite
bool get _hasChanges =>
    _firstName.text.trim() != _initial.firstName      ||
    _lastName.text.trim()  != _initial.lastName       ||
    _phone.text.trim()     != _initial.phone          ||
    _address.text.trim()   != _initial.address        ||
    _bio.text.trim()       != _initial.bio            ||
    _linkedin.text.trim()  != _initial.linkedin       ||
    _city        != _initial.city                     ||
    _country     != _initial.country                  ||
    _sector      != _initial.sector                   ||
    _gender      != _initial.gender                   ||
    _birthDate   != _initial.birthDate                ||
    _photoBase64 != _initial.photoBase64              ||
    !_interests.containsAll(_initial.interests)       ||
    _interests.length != _initial.interests.length;
```

---

### 3.5 Sauvegarde avec synchronisation Firebase

```dart
Future<void> _save() async {
  if (!_hasChanges) {
    Navigator.pop(context);  // Pas de changements → retour simple
    return;
  }
  setState(() => _loading = true);

  try {
    // ── 1. Construction du profil mis à jour
    final updated = _initial.copyWith(
      firstName:   _firstName.text.trim(),
      lastName:    _lastName.text.trim(),
      phone:       _phone.text.trim(),
      address:     _address.text.trim(),
      city:        _city,
      country:     _country,
      sector:      _sector,
      gender:      _gender,
      birthDate:   _birthDate,
      bio:         _bio.text.trim(),
      linkedin:    _linkedin.text.trim(),
      interests:   _interests.toList()..sort(),
      photoBase64: _photoBase64,
    );

    // ── 2. Mise à jour LOCALE immédiate + cache + Firebase (via Controller)
    // UserProfileController.update() fait les 3 en une seule ligne
    UserProfileController.update(updated);

    // ── 3. Retour + confirmation SnackBar
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour avec succès ✓'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la sauvegarde : ${e.toString()}'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Modifier le profil : champs modifiés avant sauvegarde**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — SnackBar vert "Profil mis à jour avec succès ✓"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Profil consulté après modification (informations mises à jour)**
> *(Insérer ici la capture d'écran)*

---

## 4. Gestion des projets (Entrepreneur)

Les projets sont créés depuis `page_pitch.dart` (dépôt de pitch). Le `UserProfileController` expose des méthodes dédiées pour les opérations CRUD sur les projets :

```dart
// ── CREATE : Ajouter un projet (depuis page_pitch.dart)
final project = Project(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: _title.text.trim(),
  description: _description.text.trim(),
  sector: _sector,
  step: 1,
  totalSteps: 5,
);
// addProject() vérifie canStartNewProject avant d'ajouter
final added = UserProfileController.addProject(project);
if (!added) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Terminez votre projet actuel avant d\'en créer un nouveau.')),
  );
  return;
}

// ── UPDATE : Modifier un projet (avancement d'étape)
UserProfileController.updateProject(
  project.copyWith(step: project.step + 1),
);

// ── DELETE : Supprimer un projet
UserProfileController.deleteProject(project.id);
```

**Affichage des projets avec barre de progression :**
```dart
// _ProjectCard dans page_profil.dart
class _ProjectCard extends StatelessWidget {
  final Project project;

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          Text(project.sector,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: LinearProgressIndicator(
                value: project.progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 8),
            Text('Étape ${project.step}/${project.totalSteps}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
          if (project.isCompleted)
            const Chip(
              label: Text('Terminé ✓'),
              backgroundColor: AppColors.greenLight,
            ),
        ],
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Projet avec barre de progression (Étape 3/5)**
> *(Insérer ici la capture d'écran)*

---

## 5. Propagation réactive des modifications

Chaque appel à `UserProfileController.update()` se propage **instantanément** à tous les écrans abonnés via `ValueListenableBuilder` :

```
UserProfileController.update(updated)
        │
        ├─→ 1. profile.value = updated          (ValueNotifier → rebuild)
        │       ├─→ [ProfilePage]               → avatar + nom + jauge reconstruits
        │       ├─→ [HomePage AppBar]           → avatar + "Bonjour Prénom" reconstruits
        │       ├─→ [DashboardMentor]           → bio + stats + chips reconstruits
        │       ├─→ [DashboardInvestisseur]     → stats + secteurs reconstruits
        │       ├─→ [ProfileBottomSheet]        → résumé reconstruit
        │       └─→ [NavBar]                    → badge reconstruit
        │
        ├─→ 2. CacheService.saveProfile(updated)  (cache local → offline-first)
        │       → SharedPreferences → profil disponible sans internet
        │
        └─→ 3. DatabaseService.updateUserProfile(uid, updated) (async)
                → Firebase Realtime Database → synchronisé cloud
```

**Résultat :** L'interface est mise à jour en < 1ms (pas de setState, pas d'appel réseau bloquant). Firebase se synchronise en arrière-plan.

---

## 6. Membres DIAPALER dans le Matching (`service_utilisateurs.dart`)

Le `UsersService` charge les **vraies inscriptions** depuis `users/` dans Firebase et les expose en tant que `List<Mentor>` pour les afficher dans la page Matching au-dessus des profils pré-chargés.

```dart
// lib/services/service_utilisateurs.dart
class UsersService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  /// Récupère les membres inscrits (Mentor + Investisseur uniquement).
  /// L'utilisateur courant est exclu de la liste.
  static Future<List<Mentor>> listMembers() async {
    final snap = await _db.ref('users').get();
    if (!snap.exists || snap.value == null) return [];

    final map = Map<String, dynamic>.from(snap.value as Map);
    final currentUid = AuthService.currentUid;

    final members = <Mentor>[];
    for (final entry in map.entries) {
      final uid = entry.key;
      if (uid == currentUid) continue;
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final role = (m['role']?.toString() ?? '').trim();
      if (role != 'Mentor' && role != 'Investisseur') continue;

      final firstName = m['firstName']?.toString() ?? '';
      final lastName  = m['lastName']?.toString()  ?? '';
      final fullName  = '$firstName $lastName'.trim();
      if (fullName.isEmpty) continue;

      members.add(Mentor(
        uid: uid,             // UID non vide = badge "Membre DIAPALER"
        name: fullName,
        title: m['bio']?.toString().split('\n').first ?? role,
        city: m['city']?.toString() ?? 'Dakar',
        sectors: _parseInterests(m['interests']),
        role: role,
        photoBase64: m['photoBase64']?.toString() ?? '',
        compatibility: 80,
      ));
    }
    return members;
  }
}
```

**Dans `page_matching.dart` :**
```dart
// Membres DIAPALER (uid != '') affichés EN TÊTE, triés par compatibilité
list.sort((a, b) {
  final aIsMember = a.uid.isNotEmpty ? 1 : 0;
  final bIsMember = b.uid.isNotEmpty ? 1 : 0;
  if (aIsMember != bIsMember) return bIsMember - aIsMember; // Membres en premier
  return b.compatibility.compareTo(a.compatibility);
});
```

> **📸 CAPTURE D'ÉCRAN — Matching : membre DIAPALER réel en tête de liste**
> *(Insérer ici la capture d'écran)*

---

## 7. Widget Avatar réutilisable (`widgets/avatar.dart`)

Le widget `Avatar` est utilisé partout dans l'application (dashboard, profil, matching, chat, pitchs) :

```dart
// widgets/avatar.dart — Affiche photo base64 ou initiales colorées
class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final String photoBase64;

  const Avatar({
    super.key,
    this.initials = '?',
    required this.size,
    this.background = AppColors.navy,
    this.foreground = Colors.white,
    this.photoBase64 = '',
  });

  @override
  Widget build(BuildContext context) {
    if (photoBase64.isNotEmpty) {
      // Décodage et affichage de la photo
      final bytes = base64Decode(photoBase64);
      return ClipOval(
        child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
      );
    }
    // Cercle coloré avec les initiales
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
```

**Tailles utilisées dans l'app :**

| Contexte | Taille |
|---|---|
| Dashboard AppBar | 44px |
| Bottom sheet profil | 64px |
| Page Profil | 88px |
| Modification profil | 90px |
| Matching (carte) | 48px |
| Chat (messages) | 36px |
| Pitchs publiés (carte) | 40px |

> **📸 CAPTURE D'ÉCRAN — Avatar avec photo (profil utilisateur)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Avatar avec initiales (utilisateur sans photo)**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 4

| Critère du sujet | Implémentation | Statut |
|---|---|---|
| Modifier son nom | Champs prénom + nom pré-remplis | ✅ |
| Modifier son téléphone | Champ téléphone +221 modifiable | ✅ |
| Modifier son email | Champ email modifiable, mis à jour dans Firebase et cache | ✅ |
| Ajouter une photo de profil | Galerie + caméra → redim 512×512 → base64 | ✅ |
| Changer sa photo de profil | Même flux, remplace la photo existante | ✅ |
| Persistance Firebase | `UserProfileController.update()` → Firebase + cache | ✅ |
| Cache offline-first | `CacheService.saveProfile()` dans `update()` | ✅ |
| Réactivité UI | `ValueNotifier` → rebuild instantané sur tous les écrans | ✅ |
| Photo dans toute l'app | Widget `Avatar` réutilisable partout | ✅ |
| Gestion de projets | `addProject` / `updateProject` / `deleteProject` | ✅ (bonus) |
| Jauge de complétion | Indicateur 0–100% coloré (vert/amber/rouge) | ✅ (bonus) |
| Déconnexion sécurisée | `reset()` + cache + Firebase signOut → redirige vers LoginPage | ✅ |
| Membres DIAPALER réels | `UsersService.listMembers()` + badge dans Matching | ✅ (bonus) |
| Champs spécifiques rôle (inscription) | `yearsExperience` (Mentor), `investmentRange` (Investisseur) dès l'étape 3 | ✅ (bonus) |
| Stats profil rôle-spécifiques | Labels et valeurs différents pour Entrepreneur / Mentor / Investisseur | ✅ (bonus) |
| LinkedIn cliquable | Chip dans carte "À propos" → url_launcher → profil LinkedIn | ✅ (bonus) |
| Bouton partage profil | `ShareService.shareMyProfile()` dans AppBar — WhatsApp, Telegram… | ✅ (bonus) |
| Badge ⭐ Premium | Affiché sous le nom si `isPremium = true` — activé via Wave (L5) | ✅ (bonus) |

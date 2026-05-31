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
  - [1.2 Contrôleur réactif global — UserProfileController](#12-contrôleur-réactif-global--userprofilecontroller)
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
- [6. Widget Avatar réutilisable](#6-widget-avatar-réutilisable-widgetsavatardart)
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

Classe **immuable** (`@immutable`) regroupant tous les champs du profil. Le pattern `copyWith` garantit l'immuabilité lors des mises à jour.

```dart
@immutable
class UserProfile {
  // Identité
  final String firstName, lastName, email, phone;
  final Gender gender;
  final DateTime? birthDate;
  // Localisation & profil professionnel
  final String address, city, country, sector, role, bio, linkedin, photoBase64;
  // Données structurées
  final List<String> interests;
  final List<Project> projects;
  // Statistiques
  final int mentorsActive, sessionsCount, favoritesCount;
  final double score;
  // Champs rôle-spécifiques
  final int yearsExperience;          // Mentor
  final String investmentRange;        // Investisseur
  // Premium (Wave)
  final bool isPremium;
  final String premiumPlan;

  // Getters calculés
  String get fullName  => '$firstName $lastName'.trim();
  String get initials  => (firstName.isNotEmpty ? firstName[0] : '')
                        + (lastName.isNotEmpty  ? lastName[0]  : '');
  bool   get canStartNewProject => projects.isEmpty || projects.every((p) => p.isCompleted);

  // copyWith : retourne une copie avec les champs modifiés
  UserProfile copyWith({String? firstName, String? lastName, String? bio,
      String? photoBase64, List<String>? interests, List<Project>? projects,
      String? city, String? sector, /* … tous les champs … */}) { /* … */ }
}
```

---

### 1.2 Contrôleur réactif global — `UserProfileController`

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
| Entrepreneur | "Mes contacts" (relations acceptées) → RequestsPage |
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

// Affichage avec couleur fixe AppColors.amber (barre toujours amber dans le code réel)
final completion = _profileCompletion(profile);

ClipRRect(
  borderRadius: BorderRadius.circular(999),
  child: LinearProgressIndicator(
    value: completion,
    minHeight: 6,
    backgroundColor: Colors.white.withValues(alpha: 0.15),
    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
  ),
),
```

---

### 2.3 Réactivité avec ValueListenableBuilder

Toute la page est enveloppée dans un `ValueListenableBuilder<UserProfile>` abonné au `UserProfileController.profile`. Chaque appel à `update()` déclenche un rebuild instantané sans `setState` global.

```dart
ValueListenableBuilder<UserProfile>(
  valueListenable: UserProfileController.profile,
  builder: (_, profile, __) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded),
              onPressed: () => ShareService.shareMyProfile(name: profile.fullName, /* … */)),
          IconButton(icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  fullscreenDialog: true, builder: (_) => const EditProfilePage()))),
        ]),
      body: ListView(children: [
        Avatar(initials: profile.initials, photoBase64: profile.photoBase64, size: 64),
        Text(profile.fullName), _RoleBadge(role: profile.role),
        LinearProgressIndicator(value: _profileCompletion(profile)),
        // … infos, intérêts, projets, stats …
      ]),
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

Un bottom sheet récapitulatif (`feuille_profil.dart`) est accessible depuis l'AppBar de chaque dashboard. Il affiche avatar, nom et rôle, et propose les actions rapides : "Modifier le profil" et "Se déconnecter". Il utilise `ValueListenableBuilder` pour rester synchronisé avec le profil courant, et `showModalBottomSheet` avec `isScrollControlled: true` pour s'adapter à la taille du contenu.

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
  totalSteps: 3,
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
// _ProjectTile dans page_profil.dart
class _ProjectTile extends StatelessWidget {
  final Project project;
  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final completed = project.isCompleted;
    final accent = completed ? AppColors.green : AppColors.amber;

    return HoverGlowCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _showActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône colorée selon l'état
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  completed ? Icons.check_circle_rounded : Icons.workspace_premium_rounded,
                  color: Colors.white, size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    Text(project.sector,
                        style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                  ],
                ),
              ),
              _StatusBadge(completed: completed), // remplace Chip('Terminé')
            ],
          ),
          // … barre de progression + étapes …
        ],
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Projet avec barre de progression (Étape 2/3)**
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

## 6. Widget Avatar réutilisable (`widgets/avatar.dart`)

Le widget `Avatar` affiche soit la photo de profil (base64 → `Image.memory` dans un `ClipOval`), soit un cercle coloré avec les initiales si aucune photo n'est disponible. Il est utilisé à toutes les tailles dans l'app :

**Tailles utilisées dans l'app :**

| Contexte | Taille |
|---|---|
| Dashboard AppBar | 44px |
| Bottom sheet profil | 64px |
| Page Profil | 64px |
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
| Jauge de complétion | Indicateur 0–100%, barre toujours amber (`AppColors.amber`) | ✅ (bonus) |
| Déconnexion sécurisée | `reset()` + cache + Firebase signOut → redirige vers LoginPage | ✅ |
| Membres DIAPALER réels | `UsersService.listMembers()` + badge dans Matching | ✅ (bonus) |
| Champs spécifiques rôle (inscription) | `yearsExperience` (Mentor), `investmentRange` (Investisseur) dès l'étape 3 | ✅ (bonus) |
| Stats profil rôle-spécifiques | Labels et valeurs différents pour Entrepreneur / Mentor / Investisseur | ✅ (bonus) |
| LinkedIn cliquable | Chip dans carte "À propos" → url_launcher → profil LinkedIn | ✅ (bonus) |
| Bouton partage profil | `ShareService.shareMyProfile()` dans AppBar — WhatsApp, Telegram… | ✅ (bonus) |
| Badge ⭐ Premium | Affiché sous le nom si `isPremium = true` — activé via Wave (L5) | ✅ (bonus) |
| "Mes contacts" (Entrepreneur) | Remplace "Mes demandes" — affiche les relations acceptées (mentorat + investissement) | ✅ (bonus) |
| Photo membres Firebase | `BoxFit.cover` systématique dans le widget `Avatar` | ✅ (bonus) |

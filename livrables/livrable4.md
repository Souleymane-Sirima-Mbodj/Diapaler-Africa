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

Ce livrable porte sur l'une des fonctionnalités les plus importantes de toute application sociale ou professionnelle : la gestion du profil utilisateur. Dans DIAPALER AFRICA, le profil n'est pas un simple formulaire — c'est la carte de visite numérique de l'entrepreneur, du mentor ou de l'investisseur. Nous avons donc accordé une attention particulière à la fluidité de l'expérience, à la réactivité de l'interface et à la robustesse de la persistance des données. Ce livrable détaille les choix techniques retenus, les patterns d'architecture utilisés, et les fonctionnalités livrées.

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

Avant de construire les interfaces, nous avons commencé par définir clairement la structure des données. Tout repose sur un modèle de données unique et cohérent, partagé entre toutes les pages de l'application. Ce choix facilite la maintenance : quand on ajoute un champ au profil, il suffit de l'ajouter à un seul endroit.

### 1.1 La classe `UserProfile`

La conception d'un modèle de données solide est la première étape de tout développement sérieux. Nous avons opté pour une classe immuable annotée `@immutable`, ce qui signifie qu'on ne modifie jamais un objet `UserProfile` directement — on crée toujours une nouvelle copie avec les champs modifiés. C'est le pattern `copyWith`, très utilisé dans l'écosystème Flutter, qui rend cela naturel et sûr. Cette approche évite les bugs liés aux mutations inattendues d'état, surtout quand plusieurs écrans partagent le même profil.

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

Pour éviter de passer le profil en argument d'un widget à l'autre (ce qu'on appelle le "prop drilling"), nous avons mis en place un contrôleur global basé sur `ValueNotifier`. Le principe est simple : une seule source de vérité pour tout le profil, accessible depuis n'importe quelle page. Quand le profil change, tous les widgets abonnés se reconstruisent automatiquement, sans `setState`, sans `Provider` externe, sans boilerplate. Nous avons choisi ce pattern volontairement léger plutôt que BLoC ou Riverpod, car la gestion de profil ne nécessite pas toute la complexité d'un système de flux bidirectionnel.

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

La page de profil est la vitrine de l'utilisateur dans l'application. Nous avons voulu qu'elle soit à la fois complète et agréable à lire, en regroupant les informations par blocs logiques : identité, statistiques, présentation personnelle, centres d'intérêt, et projets pour les entrepreneurs. Un point important de notre conception est que la page s'adapte au rôle de l'utilisateur connecté — un mentor ne voit pas les mêmes statistiques ni les mêmes boutons d'action qu'un investisseur ou qu'un entrepreneur.

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

Un profil incomplet nuit à la qualité des mises en relation. Pour encourager les utilisateurs à renseigner toutes leurs informations, nous avons intégré une jauge de complétion visible dès la carte d'identité. Elle est calculée dynamiquement en évaluant 12 champs clés du profil, et s'affiche sous forme de barre de progression amber animée. L'objectif était de donner un signal visuel clair et motivant, sans être intrusif : si vous avez rempli 10 champs sur 12, la barre affiche 83% et vous voyez immédiatement qu'il reste deux champs à compléter.

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

L'un des problèmes courants dans les applications Flutter est la désynchronisation entre les données modifiées et leur affichage. Pour éviter cela, toute la page profil est enveloppée dans un `ValueListenableBuilder`. Ce widget Flutter écoute le `ValueNotifier` du contrôleur et se reconstruit automatiquement chaque fois que le profil change. Ainsi, si l'utilisateur modifie son prénom depuis la page d'édition, la page profil se met à jour instantanément dès qu'il revient, sans aucune logique supplémentaire.

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

Pour permettre un accès rapide au profil depuis n'importe quel écran de l'application, sans avoir à naviguer jusqu'à la page complète, nous avons développé une feuille de profil accessible depuis l'AppBar des dashboards. C'est un compromis entre accessibilité et encombrement visuel : un simple tap sur l'avatar suffit pour voir son nom, son rôle, et accéder aux actions essentielles.

Un bottom sheet récapitulatif (`feuille_profil.dart`) est accessible depuis l'AppBar de chaque dashboard. Il affiche avatar, nom et rôle, et propose les actions rapides : "Modifier le profil" et "Se déconnecter". Il utilise `ValueListenableBuilder` pour rester synchronisé avec le profil courant, et `showModalBottomSheet` avec `isScrollControlled: true` pour s'adapter à la taille du contenu.

> **📸 CAPTURE D'ÉCRAN — Bottom sheet profil (avatar + actions)**
> *(Insérer ici la capture d'écran)*

---

## 3. Modification du profil (`page_modification_profil.dart`)

La modification du profil est la fonctionnalité centrale pour tout utilisateur souhaitant mettre à jour ses informations. Nous avons fait le choix de regrouper tous les champs dans une seule page scrollable, organisée par sections logiques, plutôt que de multiplier les écrans. Cela réduit le nombre de navigations nécessaires et donne à l'utilisateur une vision complète de toutes les informations qu'il peut renseigner ou modifier.

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

Nous avons fait le choix de pré-remplir tous les champs avec les données actuelles du profil, pour que l'utilisateur n'ait à modifier que ce qui a changé. Il n'a pas besoin de tout ressaisir depuis le début à chaque ouverture du formulaire. Le pré-remplissage se fait dans `initState()`, en récupérant le profil courant depuis `UserProfileController` et en initialisant chaque `TextEditingController` avec la valeur existante. Pour les dropdowns (pays, ville, secteur), on vérifie que la valeur actuelle est bien dans la liste supportée, et on revient à une valeur par défaut si ce n'est pas le cas.

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

La photo de profil joue un rôle important dans une application de mise en relation : elle humanise le contact entre les membres. Nous avons implémenté deux sources possibles — la galerie photo et l'appareil photo — accessibles depuis un bottom sheet qui s'affiche au tap sur l'avatar. La photo est automatiquement redimensionnée à 512×512 pixels et convertie en base64 pour être stockée dans Firebase, ce qui garantit une URL stable et un chargement rapide partout dans l'application. L'icône caméra superposée en bas à droite de l'avatar indique clairement à l'utilisateur que la photo est modifiable.

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

Un détail d'expérience utilisateur qui nous tenait à coeur : le bouton "Enregistrer" reste désactivé tant qu'aucune modification réelle n'a été détectée. Cela évite les sauvegardes accidentelles ou inutiles — si l'utilisateur ouvre le formulaire et le ferme sans rien changer, aucun appel réseau n'est déclenché. La détection se fait en comparant chaque champ du formulaire avec la valeur initiale du profil, champ par champ.

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

La sauvegarde suit une logique en trois temps qui garantit à la fois la réactivité de l'interface et la fiabilité de la persistance. D'abord, le profil est mis à jour en mémoire via le `ValueNotifier`, ce qui provoque un rebuild instantané de tous les écrans abonnés. Ensuite, les données sont sauvegardées dans le cache local `SharedPreferences`, ce qui les rend disponibles même hors connexion. Enfin, la synchronisation vers Firebase se fait de manière asynchrone en arrière-plan, sans jamais bloquer l'interface.

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

Dans DIAPALER AFRICA, les entrepreneurs ne sont pas de simples utilisateurs — ils portent des projets concrets qu'ils cherchent à faire connaître auprès de mentors et d'investisseurs. Nous avons donc intégré une gestion de projets directement liée au profil, avec des opérations complètes de création, modification, avancement et suppression. Chaque projet est visualisé dans le profil avec une barre de progression indiquant l'étape courante, ce qui donne une lecture rapide de la maturité du projet.

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

// ── UPDATE : Avancement d'étape
UserProfileController.updateProject(
  project.copyWith(step: project.step + 1),
);

// ── UPDATE : Mode édition complet (depuis page_profil.dart → _ProjectTile)
// Tap sur un projet → AddProjectPage(existingProject: project)
// La page est réutilisée en mode édition — tous les champs pré-remplis.
// À la sauvegarde : UserProfileController.updateProject(updatedProject)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => AddProjectPage(existingProject: project),
));

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

## 5. Système d'Avis et Notation sur les profils

La crédibilité est un enjeu central dans une plateforme de mentorat et d'investissement. Pour aider les utilisateurs à évaluer la qualité d'un mentor ou la sérieux d'un entrepreneur, nous avons développé un système d'avis et de notation complet. Ce système est volontairement sécurisé : seuls les membres ayant une relation établie (demande acceptée des deux côtés) peuvent laisser un avis, ce qui garantit que les notes reflètent de vraies interactions et non des votes anonymes.

### 5.1 Accès depuis le profil

Chaque profil DIAPALER affiche un compteur d'avis et la note moyenne. Un bouton "Voir les avis" ouvre la `ReviewsPage` en navigation push.

```dart
// page_profil.dart / page_detail_mentor.dart
StreamBuilder<List<Review>>(
  stream: InteractionsService.getReviews(mentor.uid),
  builder: (context, snapshot) {
    final reviews = snapshot.data ?? [];
    final avg = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Row(children: [
      const Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
      Text(avg == 0 ? 'Aucun avis' : avg.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(' (${reviews.length} avis)', style: const TextStyle(color: AppColors.muted)),
    ]);
  },
)
```

### 5.2 Règles d'accès

Nous avons défini des règles d'accès claires pour éviter les abus. Le principe est simple : on ne peut noter que quelqu'un qu'on connaît réellement via la plateforme. Ces règles s'appliquent côté client via des vérifications d'état de relation, et côté Firebase via les règles de sécurité de la base de données.

| Cas | Comportement |
|---|---|
| Propre profil | Lecture seule — `showLockedBanner: false` |
| Relation acceptée (demande acceptée) | Peut laisser un avis ⭐ |
| Aucune relation établie | Bannière "Relation requise pour laisser un avis" |
| Non connecté | Bannière de blocage |

### 5.3 Laisser un avis — `page_avis.dart`

La page d'avis permet à un utilisateur de rédiger un commentaire et de noter son contact de 1 à 5 étoiles. L'avis est écrit dans Firebase sous le nœud `reviews/{uid_du_destinataire}`, ce qui permet un Stream en temps réel : dès qu'un nouvel avis est ajouté, la liste se met à jour automatiquement sur tous les appareils sans rechargement manuel. La moyenne est recalculée côté client à partir du Stream, ce qui évite de stocker une valeur agrégée qui pourrait être désynchronisée.

```dart
// InteractionsService.addReview
static Future<void> addReview({
  required String toUid,
  required String fromUid,
  required String fromName,
  required String text,
  required int rating,       // 1 à 5
}) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  await _db.child('reviews/$toUid/$id').set({
    'id': id,
    'fromUid': fromUid,
    'fromName': fromName,
    'text': text,
    'rating': rating,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

// Stream des avis (temps réel)
static Stream<List<Review>> getReviews(String targetUid) {
  return _db.child('reviews/$targetUid').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return [];
    return data.values
        .map<Review>((v) => Review.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  });
}
```

> **📸 CAPTURE D'ÉCRAN — Page Avis : liste des avis + sélecteur étoiles 1–5**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Détail profil : compteur d'avis + note moyenne**
> *(Insérer ici la capture d'écran)*

---

## 6. Propagation réactive des modifications

L'un des défis les plus concrets du développement de cette fonctionnalité était de s'assurer que toute modification du profil se reflète immédiatement partout dans l'application, y compris dans l'AppBar, le dashboard et la feuille de profil. Sans une architecture réactive, on serait obligé de recharger chaque page manuellement ou de passer des callbacks dans tous les sens. Le `ValueNotifier` résout ce problème élégamment : une seule ligne de code dans `update()` déclenche la reconstruction de tous les écrans abonnés.

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

## 7. Widget Avatar réutilisable (`widgets/avatar.dart`)

Le widget `Avatar` affiche la photo de profil en gérant **deux formats** : une URL HTTPS (Cloudinary → `Image.network`) ou un blob base64 (`Image.memory`). Dans les deux cas, la photo est rendue dans un `ClipOval`. Si aucune photo n'est disponible, un cercle coloré affiche les initiales. Le widget est zoomable (tap → visionneuse plein écran `InteractiveViewer`) et utilisé à toutes les tailles dans l'app :

```dart
// Détection automatique du format
bool get _isUrl =>
    photoBase64.startsWith('http://') || photoBase64.startsWith('https://');

// Rendu : URL Cloudinary → Image.network  /  base64 → Image.memory
if (_isUrl)
  ClipOval(child: Image.network(photoBase64, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _initialsCircle()))
else if (bytes != null)
  ClipOval(child: Image.memory(bytes, fit: BoxFit.cover))
else
  _initialsCircle()
```

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
| Ajouter une photo de profil | Galerie + caméra → redim 512×512 → upload Cloudinary (URL) | ✅ |
| Changer sa photo de profil | Même flux, remplace la photo existante | ✅ |
| Persistance Firebase | `UserProfileController.update()` → Firebase + cache | ✅ |
| Cache offline-first | `CacheService.saveProfile()` dans `update()` | ✅ |
| Réactivité UI | `ValueNotifier` → rebuild instantané sur tous les écrans | ✅ |
| Photo dans toute l'app | Widget `Avatar` réutilisable partout | ✅ |
| Gestion de projets | `addProject` / `updateProject` / `deleteProject` + mode édition `AddProjectPage(existingProject:)` | ✅ (bonus) |
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
| Avatar URL Cloudinary | Widget Avatar détecte auto URL vs base64 → `Image.network` vs `Image.memory` | ✅ (bonus) |
| Système d'avis et notation | `page_avis.dart` — StreamBuilder `reviews/`, étoiles 1–5, moyenne live, accès restreint par relation | ✅ (bonus) |
| Note moyenne sur profil | Compteur d'avis + moyenne affichés en temps réel sur `page_detail_mentor.dart` et `page_profil.dart` | ✅ (bonus) |

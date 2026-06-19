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
- [5. Système d'Avis et Notation](#5-système-davis-et-notation-sur-les-profils)
- [6. Propagation réactive des modifications](#6-propagation-réactive-des-modifications)
- [7. Widget Avatar réutilisable](#7-widget-avatar-réutilisable-widgetsavatardart)
- [Conclusion](#conclusion-du-livrable-4)

---

## Introduction

Ce livrable porte sur l'une des fonctionnalités les plus importantes de toute application sociale ou professionnelle : la gestion du profil utilisateur. Dans DIAPALER AFRICA, le profil n'est pas un simple formulaire — c'est la carte de visite numérique de l'entrepreneur, du mentor ou de l'investisseur. Nous avons donc accordé une attention particulière à la fluidité de l'expérience, à la réactivité de l'interface et à la robustesse de la persistance des données. Ce livrable détaille les choix techniques retenus, les patterns d'architecture utilisés, et les fonctionnalités livrées.

DIAPALER AFRICA offre une gestion de profil **complète et réactive** permettant à chaque utilisateur de :
- Consulter son profil avec une **jauge de complétion** animée
- **Modifier** toutes ses informations personnelles et professionnelles
- **Ajouter ou changer sa photo de profil** (galerie — ImagePicker)
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
  // Entreprises fondées / possédées (mentors et investisseurs)
  final List<String> companies;

  // Getters calculés
  String get fullName => '$firstName $lastName';
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }
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
    firstName: 'Mariéme',
    lastName: 'Tine',
    email: 'marieme.tine@esp.sn',
    phone: '+221 77 123 45 67',
    gender: Gender.female,
    birthDate: DateTime(2001, 6, 14),
    address: 'Sicap Liberté 6, Villa 1234',
    city: 'Dakar',
    sector: 'Mode & Textile',
    role: 'Entrepreneure',
    linkedin: 'linkedin.com/in/marieme-tine',
    bio: "Diplômée de l'École Supérieure Polytechnique de Dakar, je porte le projet "
        'Téranga Mode — une marque de prêt-à-porter qui valorise les tissus '
        'traditionnels sénégalais (bogolan, wax, bazin) à travers des coupes '
        'contemporaines. Je cherche un mentor pour structurer mon modèle '
        'économique et accéder au financement DER/FJ.',
    interests: const [
      'Mode & Textile',
      'Artisanat',
      'Cosmétique',
      'E-commerce',
      'Made in Sénégal',
    ],
    projects: const [Project(
      id: 'teranga-mode',
      name: 'Téranga Mode',
      description: 'Marque de prêt-à-porter qui valorise les tissus traditionnels '
          'sénégalais à travers des coupes contemporaines.',
      sector: 'Mode & Textile',
      step: 3,
    )],
    mentorsActive: 4,
    sessionsCount: 3,
    favoritesCount: 7,
    score: 4.8,
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
| Bandeau stats (`_StatsStrip`) | Adapté au rôle — voir tableau ci-dessous |
| Carte "À propos" | Bio + **LinkedIn cliquable** (url_launcher) + chip "X ans d'expé." (Mentor) + chip ticket (Investisseur) |
| Coordonnées condensées | 3 colonnes compactes : email · téléphone · ville |
| Centres d'intérêt | Chips colorés |
| Bouton "Mes demandes" | **Entrepreneur uniquement** → `RequestsPage` (demandes envoyées/reçues) |
| AppBar | Partager · Modifier · Déconnexion (icône rouge discrète) |

**Stats par rôle (`_StatsStrip`) :**

| Rôle | Contenu |
|---|---|
| Entrepreneur | Carte `_EntrepreneurStatCard` : nombre de projets / pitch decks publiés |
| Mentor | Note moy. (StreamBuilder Firebase) + Avis reçus + Années d'expérience |
| Investisseur | Note moy. (StreamBuilder Firebase) + Avis reçus |

**Bouton d'action :**

| Rôle | Bouton |
|---|---|
| Entrepreneur | "Mes demandes" → `RequestsPage` (demandes mentorat + investissement) |
| Mentor | — (pas de bouton dédié dans `page_profil.dart`) |
| Investisseur | — (pas de bouton dédié dans `page_profil.dart`) |

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
| Photo de profil | Bottom sheet (Galerie / Fichier) → `CropPhotoPage` → base64 (modification) ; inscription : 512×512 → upload Cloudinary |
| Identité | **Prénom**, **Nom** |
| Coordonnées | **Email**, **Téléphone**, Adresse |
| Localisation | Pays (dropdown), Ville (dropdown filtrée) + **bouton "Détecter ma position"** (GPS + Nominatim → pré-remplit Pays, Ville et Adresse avec le quartier/suburb) |
| Profil pro | Secteur d'activité (dropdown), Biographie (**280 chars** en modification, 240 chars à l'inscription), LinkedIn |
| Données perso | Sexe (pills : Femme / Homme — sans "Non précisé"), Date de naissance (DatePicker) |
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
  _linkedin  = TextEditingController(text: _initial.linkedin);
  _bio       = TextEditingController(text: _initial.bio);
  _yearsExperience = TextEditingController(
    text: _initial.yearsExperience > 0
        ? _initial.yearsExperience.toString()
        : '',
  );
  _investmentRange = TextEditingController(text: _initial.investmentRange);

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

La photo de profil joue un rôle important dans une application de mise en relation : elle humanise le contact entre les membres. Un tap sur la zone photo ouvre un **bottom sheet** proposant deux sources : **Galerie** (ImagePicker) ou **Fichier** (FilePicker, utile sur desktop/web). Ce comportement est identique à l'inscription et à la modification du profil. Dans les deux cas, l'image sélectionnée passe par la page `CropPhotoPage` pour recadrage carré (ratio 1:1) avant traitement. À l'inscription la photo est redimensionnée à max 512×512 et uploadée vers Cloudinary (URL) avec fallback base64 ; dans "Modifier le profil" elle est stockée directement en base64.

```dart
// Inscription et modification : bottom sheet (Galerie / Fichier) → CropPhotoPage → base64
enum _PhotoSource { gallery, file }

Future<void> _pickPhoto() async {
  final source = await showModalBottomSheet<_PhotoSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library_rounded),
          title: const Text('Galerie'),
          onTap: () => Navigator.of(context).pop(_PhotoSource.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.folder_open_rounded),
          title: const Text('Fichier'),
          onTap: () => Navigator.of(context).pop(_PhotoSource.file),
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
  if (source == null) return;
  if (source == _PhotoSource.gallery) {
    await _pickPhotoFromGallery();
  } else {
    await _pickPhotoFromFile();
  }
}

Future<void> _pickPhotoFromGallery() async {
  try {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    // Recadrage avant sauvegarde
    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => CropPhotoPage(imageBytes: bytes)),
    );
    if (croppedBytes != null && mounted) {
      setState(() => _photoBase64 = base64Encode(croppedBytes));
    }
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de charger la photo.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<void> _pickPhotoFromFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    if (!mounted) return;
    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => CropPhotoPage(imageBytes: bytes)),
    );
    if (croppedBytes != null && mounted) {
      setState(() => _photoBase64 = base64Encode(croppedBytes));
    }
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de charger la photo.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Modifier le profil : zone de photo avec icône caméra**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Sélecteur photo (galerie)**
> *(Insérer ici la capture d'écran)*

---

### 3.4 Détection des changements

La détection des changements protège la navigation en arrière : si l'utilisateur tente de fermer le formulaire sans sauvegarder, un `PopScope` (avec `canPop: !_hasChanges`) affiche un `AlertDialog` de confirmation. Le bouton ENREGISTRER est toujours actif (pas de condition sur `_hasChanges`), mais la protection contre la fermeture accidentelle est bien implémentée. Le getter `_hasChanges` compare chaque champ avec la valeur initiale du profil.

```dart
// Le bouton Enregistrer est actif uniquement si une modification a été faite
bool get _hasChanges =>
    _firstName.text.trim() != _initial.firstName ||
    _lastName.text.trim() != _initial.lastName ||
    _email.text.trim() != _initial.email ||
    _phone.text.trim() != _initial.phone ||
    _address.text.trim() != _initial.address ||
    _linkedin.text.trim() != _initial.linkedin ||
    _bio.text.trim() != _initial.bio ||
    _city != _initial.city ||
    _country != _initial.country ||
    _sector != _initial.sector ||
    _gender != _initial.gender ||
    _birthDate != _initial.birthDate ||
    _photoBase64 != _initial.photoBase64 ||
    !_setEquals(_interests, _initial.interests.toSet());
```

---

### 3.5 Sauvegarde avec synchronisation Firebase

La sauvegarde suit une logique en trois temps qui garantit à la fois la réactivité de l'interface et la fiabilité de la persistance. D'abord, le profil est mis à jour en mémoire via le `ValueNotifier`, ce qui provoque un rebuild instantané de tous les écrans abonnés. Ensuite, les données sont sauvegardées dans le cache local `SharedPreferences`, ce qui les rend disponibles même hors connexion. Enfin, la synchronisation vers Firebase se fait de manière asynchrone en arrière-plan, sans jamais bloquer l'interface.

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
    investmentRange:
        _isInvestor ? _investmentRange.text.trim() : _initial.investmentRange,
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

> **📸 CAPTURE D'ÉCRAN — Modifier le profil : champs modifiés avant sauvegarde**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — SnackBar vert "Profil mis à jour avec succès ✓"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Profil consulté après modification (informations mises à jour)**
> *(Insérer ici la capture d'écran)*

---

## 4. Gestion des projets (Entrepreneur)

Dans DIAPALER AFRICA, les entrepreneurs ne sont pas de simples utilisateurs — ils portent des projets concrets qu'ils cherchent à faire connaître auprès de mentors et d'investisseurs. Nous avons donc intégré une gestion de projets directement liée au profil, avec des opérations complètes de création, modification, avancement et suppression. Chaque projet est visualisé dans le profil avec une barre de progression indiquant l'étape courante, ce qui donne une lecture rapide de la maturité du projet.

La gestion de projet est entièrement pilotée par `page_pitch.dart`. Le modèle `Project` a été enrichi pour stocker non seulement la progression par étape, mais aussi toutes les données collectées au fil du stepper (montant, documents Cloudinary, statut de publication). Cela permet de reprendre un projet là où on s'était arrêté, avec tous les champs pré-remplis.

**Modèle `Project` enrichi (`profil_utilisateur.dart`) :**

```dart
@immutable
class Project {
  final String id;
  final String name;
  final String description;
  final String sector;
  final int step;          // étape actuelle (1–5)
  final int totalSteps;    // toujours 5
  final String? amount;          // montant financement FCFA (étape 3)
  final String? businessPlanUrl; // URL Cloudinary PDF (étape 4)
  final String? videoUrl;        // URL Cloudinary vidéo (étape 4)
  final String? deckUrl;         // URL Cloudinary deck (étape 4, optionnel)
  final bool published;          // true après publication Firebase pitches/

  bool get isCompleted => step >= totalSteps;
  double get progress  => step / totalSteps;
}
```

**Sauvegarde progressive à chaque étape (`page_pitch.dart`) :**

```dart
// Construit le projet depuis l'état courant du stepper
Project _buildProject({bool published = false}) {
  return Project(
    id: _pitchId,
    name: _title.text.trim(),
    description: [_description.text.trim(), _detailDescription.text.trim()]
        .where((s) => s.isNotEmpty).join('\n\n'),
    sector: _sector ?? UserProfileController.profile.value.sector,
    step: _step + 1,
    totalSteps: 5,
    amount: _amount.text.trim().isEmpty ? null : _amount.text.trim(),
    businessPlanUrl: _businessPlanUrl,
    videoUrl: _videoUrl,
    deckUrl: _deckUrl,
    published: published,
  );
}

// Appelé à chaque avancement d'étape (sauf la dernière)
void _saveProgress() {
  final project = _buildProject();
  if (_isNew) {
    final added = UserProfileController.addProject(project);
    if (added) _isNew = false;
  } else {
    UserProfileController.updateProject(project);
  }
}

Future<void> _next() async {
  if (!_currentStepValid) return;
  if (_step < _total - 1) {
    _saveProgress(); // sauvegarde locale + Firebase à chaque avancement
    setState(() => _step++);
    return;
  }
  _publish(); // uniquement à la dernière étape : publication Firebase pitches/
}
```

Remarques :
- `UserProfileController.addProject/updateProject/deleteProject` encapsulent la logique et la vérification `canStartNewProject`.
- La persistance se fait toujours via `UserProfileController.update()` → cache local (`CacheService`) + Firebase asynchrone (`DatabaseService`).

### 4.1 Stepper unifié création / édition / publication (`page_pitch.dart`)

`PitchPage` est la page unique qui gère l'ensemble du cycle de vie d'un projet : création, édition étape par étape, et publication publique. Elle accepte un paramètre `existingProject` optionnel :

- **Sans `existingProject`** : nouveau projet, démarrage à l'étape 1
- **Avec `existingProject`** : reprise à l'étape sauvegardée, tous les champs pré-remplis

```dart
class PitchPage extends StatefulWidget {
  final Project? existingProject;
  const PitchPage({super.key, this.existingProject});
}
```

**Reprise d'un projet existant (`initState`) :**

```dart
@override
void initState() {
  super.initState();
  final p = widget.existingProject;
  if (p != null) {
    _pitchId = p.id;
    _isNew   = false;
    _step    = (p.step - 1).clamp(0, _total - 1); // reprend à l'étape sauvegardée
    _title.text            = p.name;
    _sector                = p.sector.isNotEmpty ? p.sector : null;
    final parts            = p.description.split('\n\n');
    _description.text      = parts.isNotEmpty ? parts[0] : p.description;
    _detailDescription.text = parts.length > 1 ? parts.sublist(1).join('\n\n') : '';
    _amount.text           = p.amount ?? '';
    _businessPlanUrl       = p.businessPlanUrl;
    _videoUrl              = p.videoUrl;
    _deckUrl               = p.deckUrl;
  } else {
    _pitchId = _generateId();
    _isNew   = true;
  }
}
```

**Accès depuis le dashboard (`page_accueil.dart`) :**

La bottom sheet du projet propose deux actions principales :
- **"Modifier le projet"** → `PitchPage(existingProject: p.currentProject)` — reprend le stepper à l'étape sauvegardée
- **"Publier le pitch"** → `_directPublish(context, p.currentProject!)` — publie directement sans repasser par le stepper

**Publication directe sans stepper (`_directPublish`) :**

```dart
Future<void> _directPublish(BuildContext context, Project project) async {
  // Confirmation utilisateur
  final ok = await showDialog<bool>(...);
  if (ok != true) return;

  await DatabaseService.publishPitch(
    pitchId: project.id,
    userId: uid,
    userName: profile.fullName,
    title: project.name,
    sector: project.sector,
    description: project.description,
    amount: project.amount ?? '',
    businessPlanUrl: project.businessPlanUrl,
    videoUrl: project.videoUrl,
    deckUrl: project.deckUrl,
  );

  // Marquer le projet comme publié
  UserProfileController.updateProject(
    project.copyWith(published: true, step: project.totalSteps),
  );
}
```

**Sélection du projet à publier (`_showPitchListSheet`) :**

Le quick action "Déposer un pitch" du dashboard ouvre une bottom sheet listant tous les projets de l'entrepreneur. Chaque ligne affiche le nom, l'étape courante (`"Étape 2/5"` ou `"Déjà publié"`) et un bouton **Publier** qui appelle `_directPublish` directement.

- En **création** : `addProject()` vérifie `canStartNewProject` (un seul projet non terminé à la fois).
- En **édition** : `updateProject()` retrouve le projet par son `id` et met à jour les champs sans toucher à l'`id`.

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
// Les avis (texte) et les notes (1–5) sont stockés séparément dans Firebase.
// getReviews() lit reviews/{uid}, getRatings() lit ratings/{uid}/{fromUid}.
StreamBuilder<Map<String, int>>(
  stream: InteractionsService.getRatings(mentor.uid),
  builder: (context, snapshot) {
    final ratings = snapshot.data ?? {};
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.values.reduce((a, b) => a + b) / ratings.length;
    return Row(children: [
      const Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
      Text(avg == 0 ? 'Aucun avis' : avg.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700)),
      Text(' (${ratings.length} avis)', style: const TextStyle(color: AppColors.muted)),
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
// InteractionsService.addReview — nœud reviews/ : texte uniquement, PAS de rating
static Future<void> addReview({
  required String toUid,
  required String fromUid,
  required String fromName,
  required String text,
}) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  await _db.child('reviews/$toUid/$id').set({
    'id': id,
    'fromUid': fromUid,
    'fromName': fromName,
    'text': text,
    'createdAt': DateTime.now().millisecondsSinceEpoch, // entier, pas ISO string
  });
  // Notification non critique : ne pas bloquer si elle échoue
  try {
    await NotificationService.notifyUser(
      uid: toUid,
      title: 'Nouvel avis reçu 💬',
      message: '$fromName a laissé un avis sur votre profil.',
      type: 'new_review',
    );
  } catch (_) {}
}

// Stream des avis texte (temps réel) — trié du plus récent au plus ancien
static Stream<List<Review>> getReviews(String targetUid) {
  return _db.child('reviews/$targetUid').onValue.map((event) {
    final data = event.snapshot.value as Map?;
    if (data == null) return <Review>[];
    return data.values
        .map<Review>((v) => Review.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  });
}

// Les notes 1–5 sont séparées : nœud ratings/{toUid}/{fromUid} → entier
// Géré par setRating() / getRatings() — voir service_interactions.dart
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
  ClipOval(child: Image.memory(bytes, fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _initialsCircle()))
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
| Ajouter une photo de profil | Bottom sheet (Galerie / Fichier) → CropPhotoPage → base64 (inscription et modification) ; inscription : upload Cloudinary avec fallback base64 | ✅ |
| Changer sa photo de profil | Même flux (bottom sheet → crop → base64), remplace la photo existante | ✅ |
| Persistance Firebase | `UserProfileController.update()` → Firebase + cache | ✅ |
| Cache offline-first | `CacheService.saveProfile()` dans `update()` | ✅ |
| Réactivité UI | `ValueNotifier` → rebuild instantané sur tous les écrans | ✅ |
| Photo dans toute l'app | Widget `Avatar` réutilisable partout | ✅ |
| Gestion de projets | `addProject` / `updateProject` / `deleteProject` + stepper unifié `PitchPage(existingProject:)` + publication directe `_directPublish` | ✅ (bonus) |
| Jauge de complétion | Indicateur 0–100%, barre toujours amber (`AppColors.amber`) | ✅ (bonus) |
| Déconnexion sécurisée | `reset()` + cache + Firebase signOut → redirige vers LoginPage | ✅ |
| Membres DIAPALER réels | `UsersService.listMembers()` + badge dans Matching | ✅ (bonus) |
| Champs spécifiques rôle (inscription) | `yearsExperience` (Mentor), `investmentRange` (Investisseur) dès l'étape 3 | ✅ (bonus) |
| Stats profil rôle-spécifiques | Labels et valeurs différents pour Entrepreneur / Mentor / Investisseur | ✅ (bonus) |
| LinkedIn cliquable | Chip dans carte "À propos" → url_launcher → profil LinkedIn | ✅ (bonus) |
| Bouton partage profil | `ShareService.shareMyProfile()` dans AppBar — WhatsApp, Telegram… | ✅ (bonus) |
| Badge ⭐ Premium | 3 éléments visuels : (1) étoile dorée sur l'avatar, (2) label "Entrepreneur Premium" amber sous le rôle, (3) bannière "Passer Premium" cliquable → `WavePremiumSheet` (4 900 FCFA/mois) ; si abonné : badge vert "Compte Premium actif" | ✅ (bonus) |
| "Mes demandes" (Entrepreneur) | Bouton unique dans `page_profil.dart` → `RequestsPage` (onglets Reçues / Envoyées) | ✅ (bonus) |
| Photo membres Firebase | `BoxFit.cover` systématique dans le widget `Avatar` | ✅ (bonus) |
| Avatar URL Cloudinary | Widget Avatar détecte auto URL vs base64 → `Image.network` vs `Image.memory` | ✅ (bonus) |
| Système d'avis et notation | `page_avis.dart` — StreamBuilder `reviews/`, étoiles 1–5, moyenne live, accès restreint par relation | ✅ (bonus) |
| Note moyenne sur profil | Compteur d'avis + moyenne affichés en temps réel sur `page_detail_mentor.dart` et `page_profil.dart` | ✅ (bonus) |
| Auto-détection localisation | `LocationService.detectCity()` (GPS + Nominatim) → pré-remplit Pays, Ville et Adresse (quartier/suburb) + SnackBar 3 niveaux "Sénégal · Dakar · Liberté 6" | ✅ (bonus) |

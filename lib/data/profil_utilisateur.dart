import 'package:flutter/foundation.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_cache.dart';

enum Gender {
  female,
  male,
  other,
  undisclosed;

  String get label {
    switch (this) {
      case Gender.female:
        return 'Femme';
      case Gender.male:
        return 'Homme';
      case Gender.other:
        return 'Autre';
      case Gender.undisclosed:
        return 'Préfère ne pas dire';
    }
  }

  static Gender fromString(String? raw) {
    switch (raw) {
      case 'female':
        return Gender.female;
      case 'male':
        return Gender.male;
      case 'other':
        return Gender.other;
      default:
        return Gender.undisclosed;
    }
  }

  String get serialized => name;
}

@immutable
class Project {
  final String id;
  final String name;
  final String description;
  final String sector;
  final int step;
  final int totalSteps;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.sector,
    this.step = 1,
    this.totalSteps = 5,
  });

  bool get isCompleted => step >= totalSteps;
  double get progress => step / totalSteps;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? sector,
    int? step,
    int? totalSteps,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      step: step ?? this.step,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}

@immutable
class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Gender gender;
  final DateTime? birthDate;
  final String address;
  final String city;
  final String country;
  final String sector;
  final String role;
  final String bio;
  final String linkedin;

  /// Photo de profil encodée en base64 (chaîne vide = avatar à initiales).
  final String photoBase64;

  final List<String> interests;
  final List<Project> projects;

  // Stats agrégées (mises à jour par les actions de l'app — mentors contactés,
  // sessions réservées, favoris ajoutés, notes reçues).
  final int mentorsActive;
  final int sessionsCount;
  final int favoritesCount;
  final double score;

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
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var a = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      a--;
    }
    return a;
  }

  Project? get currentProject {
    final active = projects.where((p) => !p.isCompleted).toList();
    if (active.isNotEmpty) return active.first;
    if (projects.isNotEmpty) return projects.last;
    return null;
  }

  bool get canStartNewProject {
    if (projects.isEmpty) return true;
    return projects.every((p) => p.isCompleted);
  }

  String get projectName => currentProject?.name ?? 'Aucun projet';
  String get projectDescription => currentProject?.description ?? '';
  int get projectStep => currentProject?.step ?? 0;
  int get projectTotalSteps => currentProject?.totalSteps ?? 5;
  double get progress => currentProject?.progress ?? 0;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    Gender? gender,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? address,
    String? city,
    String? country,
    String? sector,
    String? role,
    String? bio,
    String? linkedin,
    String? photoBase64,
    List<String>? interests,
    List<Project>? projects,
    int? mentorsActive,
    int? sessionsCount,
    int? favoritesCount,
    double? score,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      sector: sector ?? this.sector,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      linkedin: linkedin ?? this.linkedin,
      photoBase64: photoBase64 ?? this.photoBase64,
      interests: interests ?? this.interests,
      projects: projects ?? this.projects,
      mentorsActive: mentorsActive ?? this.mentorsActive,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      score: score ?? this.score,
    );
  }
}

/// État global du profil utilisateur — partagé entre toutes les pages.
class UserProfileController {
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(_seed);

  /// Met à jour le profil courant, l'enregistre dans le cache local et
  /// le synchronise avec Firebase. Tout changement (profil ou projet) est
  /// ainsi persisté localement ET sur la base distante.
  static void update(UserProfile next) {
    profile.value = next;
    CacheService.saveProfile(next);
    _syncToFirebase(next);
  }

  /// Pousse le profil vers la base distante si un utilisateur est connecté.
  /// L'écriture est asynchrone et n'interrompt jamais l'interface.
  static void _syncToFirebase(UserProfile p) {
    try {
      final uid = AuthService.currentUid;
      if (uid == null) return;
      DatabaseService.updateUserProfile(uid, p).catchError((Object _) {});
    } catch (_) {
      // Firebase pas encore prêt : le cache local a déjà tout sauvegardé.
    }
  }

  /// Ajoute un projet, uniquement si l'utilisateur peut en démarrer un nouveau.
  static bool addProject(Project p) {
    final current = profile.value;
    if (!current.canStartNewProject) return false;
    update(current.copyWith(
      projects: [...current.projects, p],
    ));
    return true;
  }

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

  static final UserProfile _seed = UserProfile(
    firstName: 'Mariéme',
    lastName: 'Tine',
    email: 'marieme.tine@esp.sn',
    phone: '+221 77 123 45 67',
    gender: Gender.female,
    birthDate: DateTime(2001, 6, 14),
    address: 'Sicap Liberté 6, Villa 1234',
    city: 'Dakar',
    country: 'Sénégal',
    sector: 'Mode & Textile',
    role: 'Entrepreneure',
    linkedin: 'linkedin.com/in/marieme-tine',
    bio:
        "Diplômée de l'École Supérieure Polytechnique de Dakar, je porte le projet "
        'Téranga Mode — une marque de prêt-à-porter qui valorise les tissus '
        'traditionnels sénégalais (bogolan, wax, bazin) à travers des coupes '
        "contemporaines. Je cherche un mentor pour structurer mon modèle "
        'économique et accéder au financement DER/FJ.',
    interests: const [
      'Mode & Textile',
      'Artisanat',
      'Cosmétique',
      'E-commerce',
      'Made in Sénégal',
    ],
    projects: const [
      Project(
        id: 'teranga-mode',
        name: 'Téranga Mode',
        description:
            'Marque de prêt-à-porter qui valorise les tissus traditionnels '
            'sénégalais à travers des coupes contemporaines.',
        sector: 'Mode & Textile',
        step: 3,
        totalSteps: 5,
      ),
    ],
    mentorsActive: 4,
    sessionsCount: 3,
    favoritesCount: 7,
    score: 4.8,
  );
}

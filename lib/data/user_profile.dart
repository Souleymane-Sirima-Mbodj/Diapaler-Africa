import 'package:flutter/foundation.dart';

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
  final String city;
  final String sector;
  final String role;
  final String bio;
  final List<String> interests;
  final List<Project> projects;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.sector,
    required this.role,
    required this.bio,
    required this.interests,
    required this.projects,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  /// Le projet "actif" : le premier non-terminé. S'il n'y a que des projets
  /// terminés, on retourne le plus récent (dernier de la liste).
  Project? get currentProject {
    final active = projects.where((p) => !p.isCompleted).toList();
    if (active.isNotEmpty) return active.first;
    if (projects.isNotEmpty) return projects.last;
    return null;
  }

  /// On ne peut démarrer un nouveau projet que si tous les projets existants
  /// sont terminés (ou s'il n'y en a aucun).
  bool get canStartNewProject {
    if (projects.isEmpty) return true;
    return projects.every((p) => p.isCompleted);
  }

  // Backward-compat getters utilisés par HomePage / ProfileSheet.
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
    String? city,
    String? sector,
    String? role,
    String? bio,
    List<String>? interests,
    List<Project>? projects,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      sector: sector ?? this.sector,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      projects: projects ?? this.projects,
    );
  }
}

/// État global du profil utilisateur — partagé entre toutes les pages.
class UserProfileController {
  static final ValueNotifier<UserProfile> profile =
      ValueNotifier<UserProfile>(_seed);

  static void update(UserProfile next) {
    profile.value = next;
  }

  /// Ajoute un projet, uniquement si l'utilisateur peut en démarrer un nouveau.
  /// Retourne true si l'opération a réussi.
  static bool addProject(Project p) {
    final current = profile.value;
    if (!current.canStartNewProject) return false;
    profile.value = current.copyWith(
      projects: [...current.projects, p],
    );
    return true;
  }

  /// Met à jour un projet existant (par id).
  static void updateProject(Project updated) {
    final current = profile.value;
    profile.value = current.copyWith(
      projects: current.projects
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
  }

  static const _seed = UserProfile(
    firstName: 'Mariéme',
    lastName: 'Tine',
    email: 'marieme.tine@esp.sn',
    phone: '+221 77 123 45 67',
    city: 'Dakar',
    sector: 'Mode & Textile',
    role: 'Entrepreneure',
    bio:
        "Diplômée de l'École Supérieure Polytechnique de Dakar, je porte le projet "
        'Téranga Mode — une marque de prêt-à-porter qui valorise les tissus '
        'traditionnels sénégalais (bogolan, wax, bazin) à travers des coupes '
        "contemporaines. Je cherche un mentor pour structurer mon modèle "
        'économique et accéder au financement DER/FJ.',
    interests: [
      'Mode & Textile',
      'Artisanat',
      'Cosmétique',
      'E-commerce',
      'Made in Sénégal',
    ],
    projects: [
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
  );
}

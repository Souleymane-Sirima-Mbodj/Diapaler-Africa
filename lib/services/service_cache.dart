import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profil_utilisateur.dart';

/// Cache local du profil utilisateur (stockage hors-ligne).
///
/// Permet à l'application de réafficher instantanément les données du
/// dernier utilisateur connecté au démarrage, même sans connexion internet.
/// Les données sont sérialisées en JSON et stockées via shared_preferences.
class CacheService {
  static const String _profileKey = 'diapaler_cached_profile';

  /// Enregistre le profil dans le stockage local de l'appareil.
  static Future<void> saveProfile(UserProfile p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(_toJson(p)));
    } catch (_) {
      // Le cache est une optimisation : on ignore les erreurs d'écriture.
    }
  }

  /// Recharge le dernier profil connu depuis le stockage local.
  /// Renvoie `null` si aucun profil n'est en cache.
  static Future<UserProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Vide le cache (appelé à la déconnexion).
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (_) {
      // Ignoré : la déconnexion ne doit jamais échouer à cause du cache.
    }
  }

  // ─────────────────────────── Sérialisation JSON ───────────────────────────

  static Map<String, dynamic> _toJson(UserProfile p) => {
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
        'projects': p.projects
            .map((pr) => {
                  'id': pr.id,
                  'name': pr.name,
                  'description': pr.description,
                  'sector': pr.sector,
                  'step': pr.step,
                  'totalSteps': pr.totalSteps,
                })
            .toList(),
        'mentorsActive': p.mentorsActive,
        'sessionsCount': p.sessionsCount,
        'favoritesCount': p.favoritesCount,
        'score': p.score,
        'yearsExperience': p.yearsExperience,
        'investmentRange': p.investmentRange,
        'isPremium': p.isPremium,
        'premiumPlan': p.premiumPlan,
      };

  static UserProfile _fromJson(Map<String, dynamic> m) {
    final projects = <Project>[];
    final rawProjects = m['projects'];
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
          ));
        }
      }
    }

    final interests = <String>[];
    final rawInterests = m['interests'];
    if (rawInterests is List) {
      for (final v in rawInterests) {
        interests.add(v.toString());
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
    );
  }
}

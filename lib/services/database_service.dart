import 'package:firebase_database/firebase_database.dart';
import '../data/user_profile.dart';

/// Wrapper Realtime Database pour la persistance des profils utilisateurs.
class DatabaseService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  static DatabaseReference _userRef(String uid) => _db.ref('users/$uid');

  static Future<void> createUserProfile(String uid, UserProfile profile) {
    return _userRef(uid).set(_toMap(profile));
  }

  static Future<void> updateUserProfile(String uid, UserProfile profile) {
    return _userRef(uid).update(_toMap(profile));
  }

  static Future<UserProfile?> readUserProfile(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists || snap.value == null) return null;
    final raw = Map<String, dynamic>.from(snap.value as Map);
    return _fromMap(raw);
  }

  // ───────────────────────────── Sérialisation ─────────────────────────────

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
        'interests': p.interests,
        'projects': p.projects.map(_projectToMap).toList(),
        'updatedAt': ServerValue.timestamp,
      };

  static Map<String, dynamic> _projectToMap(Project p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'sector': p.sector,
        'step': p.step,
        'totalSteps': p.totalSteps,
      };

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
      interests: interests,
      projects: projects,
    );
  }
}

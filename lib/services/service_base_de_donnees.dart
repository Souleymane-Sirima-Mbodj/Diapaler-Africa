import 'package:firebase_database/firebase_database.dart';
import '../data/profil_utilisateur.dart';

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

  // ───────────────────────────── Pitchs publics ────────────────────────────

  /// Publie un pitch dans le nœud global `pitches/` — visible par tous.
  /// [pitchId] doit être pré-généré (pour permettre l'upload Cloudinary avant publication).
  static Future<void> publishPitch({
    required String pitchId,
    required String userId,
    required String userName,
    required String title,
    required String sector,
    required String description,
    required String amount,
    String? businessPlanUrl,
    String? videoUrl,
    String? deckUrl,
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
      if (businessPlanUrl != null) 'businessPlanUrl': businessPlanUrl,
      if (videoUrl != null)        'videoUrl':        videoUrl,
      if (deckUrl != null)         'deckUrl':         deckUrl,
    });
  }

  /// Stream temps réel de tous les pitchs publiés.
  static Stream<List<Map<String, dynamic>>> getPitches() {
    return _db.ref('pitches').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      final list = data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      list.sort((a, b) {
        final aT = (a['createdAt'] as num?) ?? 0;
        final bT = (b['createdAt'] as num?) ?? 0;
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Stream temps réel des pitchs publiés uniquement par [userId].
  static Stream<List<Map<String, dynamic>>> getMyPitches(String userId) {
    return _db.ref('pitches').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      final list = data.values
          .where((v) => v is Map && v['userId'] == userId)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      list.sort((a, b) {
        final aT = (a['createdAt'] as num?) ?? 0;
        final bT = (b['createdAt'] as num?) ?? 0;
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Met à jour le titre, secteur, description et montant d'un pitch existant.
  static Future<void> updatePitch({
    required String pitchId,
    required String title,
    required String sector,
    required String description,
    required String amount,
  }) async {
    await _db.ref('pitches/$pitchId').update({
      'title': title,
      'sector': sector,
      'description': description,
      'amount': amount,
    });
  }

  /// Supprime un pitch de [pitches/$pitchId].
  static Future<void> deletePitch(String pitchId) async {
    await _db.ref('pitches/$pitchId').remove();
  }

  /// Met à jour (ou supprime) l'URL d'un document lié à un pitch.
  /// [field] : 'businessPlanUrl' | 'videoUrl' | 'deckUrl'
  /// Passer [url] = null pour supprimer le champ.
  static Future<void> updatePitchDocumentUrl({
    required String pitchId,
    required String field,
    required String? url,
  }) async {
    if (url == null) {
      await _db.ref('pitches/$pitchId/$field').remove();
    } else {
      await _db.ref('pitches/$pitchId').update({field: url});
    }
  }

  // ────────────────────────────── Premium ──────────────────────────────────

  /// Active le statut Premium de l'utilisateur dans Firebase.
  static Future<void> setPremium({
    required String uid,
    required String plan, // 'entrepreneur' | 'mentor' | 'investisseur'
  }) async {
    await _userRef(uid).update({
      'isPremium': true,
      'premiumPlan': plan,
      'premiumSince': ServerValue.timestamp,
    });
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

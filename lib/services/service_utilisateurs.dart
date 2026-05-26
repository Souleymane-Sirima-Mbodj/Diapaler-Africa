import 'package:firebase_database/firebase_database.dart';

import '../data/donnees_mentors.dart';
import 'service_authentification.dart';

/// Service de découverte des utilisateurs inscrits.
///
/// Lit `users/` dans Firebase Realtime Database et expose les profils sous
/// forme de [Mentor] (pour réutiliser directement [MentorCard] et
/// [MentorDetailPage]). Seuls les rôles Mentor et Investisseur sont retournés,
/// et l'utilisateur courant est exclu.
class UsersService {
  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  /// Récupère la liste des membres DIAPALER (mentors + investisseurs)
  /// inscrits via SignUpPage. L'utilisateur courant est exclu.
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
      final lastName = m['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isEmpty) continue;

      final interests = <String>[];
      final rawInterests = m['interests'];
      if (rawInterests is List) {
        for (final v in rawInterests) {
          interests.add(v.toString());
        }
      }

      members.add(Mentor(
        uid: uid,
        initials: _initialsOf(firstName, lastName),
        name: fullName,
        title: m['bio']?.toString().split('\n').first ?? role,
        city: m['city']?.toString() ?? 'Dakar',
        sectors: interests.isEmpty ? const ['Autre'] : interests,
        companies: const [],
        rating: 0,
        reviews: 0,
        years: 0,
        compatibility: 80, // Score par défaut pour un membre vérifié.
        role: role,
        photoBase64: m['photoBase64']?.toString() ?? '',
      ));
    }
    return members;
  }

  static String _initialsOf(String first, String last) {
    final a = first.isNotEmpty ? first[0] : '';
    final b = last.isNotEmpty ? last[0] : '';
    final res = (a + b).toUpperCase();
    return res.isEmpty ? '?' : res;
  }
}

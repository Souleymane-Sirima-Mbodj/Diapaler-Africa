import 'package:firebase_database/firebase_database.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import 'service_authentification.dart';

/// Service de lecture des membres inscrits depuis Firebase Realtime Database.
class UsersService {
  static final _db = FirebaseDatabase.instance.ref();

  /// Retourne la liste des membres enregistrés dans Firebase sous le nœud
  /// `users/`, filtrés selon le rôle de l'utilisateur courant :
  /// - Entrepreneur → charge Mentors + Investisseurs
  /// - Mentor ou Investisseur → charge uniquement les Entrepreneurs
  static Future<List<Mentor>> listMembers() async {
    final snap = await _db.child('users').get();
    if (!snap.exists || snap.value == null) return [];
    final data = Map<String, dynamic>.from(snap.value as Map);

    final currentUid = AuthService.currentUid;
    final myRole = UserProfileController.profile.value.role;

    // Rôles cibles selon mon propre rôle
    final Set<String> targetRoles;
    if (myRole == 'Mentor' || myRole == 'Investisseur') {
      targetRoles = {'Entrepreneur', 'Entrepreneure'};
    } else {
      // Entrepreneur (et cas par défaut) → voir Mentors & Investisseurs
      targetRoles = {'Mentor', 'Investisseur'};
    }

    final result = <Mentor>[];
    for (final entry in data.entries) {
      final uid = entry.key;
      if (uid == currentUid) continue;
      final m = Map<String, dynamic>.from(entry.value as Map);
      final role = (m['role']?.toString() ?? '').trim();
      if (!targetRoles.contains(role)) continue;
      final rawSectors = m['interests'] ?? m['sectors'];
      final sectors = <String>[];
      if (rawSectors is List) {
        for (final s in rawSectors) {
          sectors.add(s.toString());
        }
      }
      result.add(Mentor(
        uid: uid,
        initials: _initials(m['firstName']?.toString() ?? '',
            m['lastName']?.toString() ?? ''),
        name: '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim(),
        title: m['sector']?.toString() ?? '',
        city: m['city']?.toString() ?? 'Dakar',
        sectors: sectors,
        companies: const [],
        rating: (m['score'] as num?)?.toDouble() ?? 0.0,
        reviews: 0,
        years: (m['yearsExperience'] as num?)?.toInt() ?? 0,
        compatibility: 80,
        gender: Gender.fromString(m['gender']?.toString()),
        bio: m['bio']?.toString() ?? '',
        role: role,
        photoBase64: m['photoBase64']?.toString() ?? '',
      ));
    }
    return result;
  }

  static String _initials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }
}

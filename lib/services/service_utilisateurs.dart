import 'package:firebase_database/firebase_database.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';

/// Service de lecture des membres inscrits depuis Firebase Realtime Database.
class UsersService {
  static final _db = FirebaseDatabase.instance.ref();

  /// Retourne la liste des membres (Mentors / Investisseurs) enregistrés dans
  /// Firebase sous le nœud `users/`. Chaque entrée est convertie en [Mentor]
  /// pour être affichée dans l'interface.
  static Future<List<Mentor>> listMembers() async {
    final snap = await _db.child('users').get();
    if (!snap.exists || snap.value == null) return [];
    final data = Map<String, dynamic>.from(snap.value as Map);
    final result = <Mentor>[];
    for (final entry in data.entries) {
      final uid = entry.key;
      final m = Map<String, dynamic>.from(entry.value as Map);
      final role = m['role']?.toString() ?? 'Mentor';
      if (role != 'Mentor' && role != 'Investisseur') continue;
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
        compatibility: 0,
        gender: Gender.fromString(m['gender']?.toString()),
        bio: m['bio']?.toString() ?? '',
        role: role,
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

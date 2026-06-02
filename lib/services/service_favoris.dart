import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';

/// Gère la liste des mentors/investisseurs mis en favori par l'utilisateur.
///
/// Les favoris sont stockés dans Firebase sous :
///   `favorites/$userId/$key → snapshot du Mentor`
///
/// Le [ValueNotifier] [favorites] se met à jour en temps réel,
/// ce qui permet de synchroniser [favoritesCount] via [coquille_principale.dart].
class FavoriteService {
  FavoriteService._();

  static final _db = FirebaseDatabase.instance.ref();

  /// Liste réactive des mentors/investisseurs favoris de l'utilisateur courant.
  static final favorites = ValueNotifier<List<Mentor>>([]);
  static StreamSubscription? _sub;

  // ──────────────────────────────────────────────────────────────────
  // Clé Firebase unique par mentor (uid réel ou nom normalisé)
  // ──────────────────────────────────────────────────────────────────
  static String _keyOf(Mentor m) => m.uid.isNotEmpty
      ? m.uid
      : m.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  // ──────────────────────────────────────────────────────────────────
  // Chargement / reset
  // ──────────────────────────────────────────────────────────────────

  /// Lance le listener temps réel sur `favorites/$userId`.
  static Future<void> load(String userId) async {
    await _sub?.cancel();
    _sub = _db.child('favorites/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        favorites.value = [];
        return;
      }
      try {
        favorites.value = data.values
            .where((v) => v is Map)
            .map<Mentor>(
                (v) => _fromJson(Map<String, dynamic>.from(v as Map)))
            .toList();
      } catch (_) {
        favorites.value = [];
      }
    }, onError: (_) => favorites.value = []);
  }

  /// Vide la liste et annule le listener (appelé à la déconnexion).
  static Future<void> reset() async {
    await _sub?.cancel();
    _sub = null;
    favorites.value = [];
  }

  // ──────────────────────────────────────────────────────────────────
  // Opérations
  // ──────────────────────────────────────────────────────────────────

  /// Retourne `true` si [mentor] est dans la liste des favoris.
  static bool isFavorite(Mentor mentor) =>
      favorites.value.any((f) => _keyOf(f) == _keyOf(mentor));

  /// Ajoute ou retire [mentor] des favoris de [userId].
  static Future<void> toggle(String userId, Mentor mentor) async {
    final key = _keyOf(mentor);
    final ref = _db.child('favorites/$userId/$key');
    if (isFavorite(mentor)) {
      await ref.remove();
    } else {
      await ref.set(_toJson(mentor));
    }
    // Le ValueNotifier est mis à jour par le listener Firebase automatiquement.
  }

  // ──────────────────────────────────────────────────────────────────
  // Sérialisation
  // ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toJson(Mentor m) => {
        'initials': m.initials,
        'name': m.name,
        'title': m.title,
        'city': m.city,
        'sectors': m.sectors,
        'companies': m.companies,
        'rating': m.rating,
        'reviews': m.reviews,
        'years': m.years,
        'compatibility': m.compatibility,
        'cis': m.cis,
        'role': m.role,
        'gender': m.gender.name,
        'bio': m.bio,
        'uid': m.uid,
        'photoBase64': m.photoBase64,
      };

  static Mentor _fromJson(Map<String, dynamic> m) => Mentor(
        initials: m['initials']?.toString() ?? '?',
        name: m['name']?.toString() ?? '',
        title: m['title']?.toString() ?? '',
        city: m['city']?.toString() ?? '',
        sectors: _toStringList(m['sectors']),
        companies: _toStringList(m['companies']),
        rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
        reviews: (m['reviews'] as num?)?.toInt() ?? 0,
        years: (m['years'] as num?)?.toInt() ?? 0,
        compatibility: (m['compatibility'] as num?)?.toInt() ?? 0,
        cis: m['cis'] as bool? ?? false,
        role: m['role']?.toString() ?? 'Mentor',
        gender: Gender.values.firstWhere(
          (g) => g.name == m['gender']?.toString(),
          orElse: () => Gender.undisclosed,
        ),
        bio: m['bio']?.toString() ?? '',
        uid: m['uid']?.toString() ?? '',
        photoBase64: m['photoBase64']?.toString() ?? '',
      );

  static List<String> _toStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

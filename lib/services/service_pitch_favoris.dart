import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Gère les pitchs mis en favori (bookmark) par l'investisseur.
///
/// Nœud Firebase : `pitchFavorites/{userId}/{pitchId}` → snapshot du pitch.
/// Le [ValueNotifier] [pitchFavorites] se met à jour en temps réel.
class PitchFavoriteService {
  PitchFavoriteService._();

  static final _db = FirebaseDatabase.instance.ref();

  /// Liste réactive des pitchs mis en favori par l'utilisateur courant.
  static final pitchFavorites =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  static StreamSubscription? _sub;

  // ──────────────────────────────────────────────────────────────────
  // Clé Firebase unique par pitch
  // ──────────────────────────────────────────────────────────────────
  static String _keyOf(Map<String, dynamic> pitch) {
    final id = pitch['id']?.toString() ?? '';
    if (id.isNotEmpty) return id;
    // Fallback : titre normalisé
    return (pitch['title']?.toString() ?? 'pitch')
        .replaceAll(RegExp(r'[^\w]'), '_')
        .toLowerCase();
  }

  // ──────────────────────────────────────────────────────────────────
  // Chargement / reset
  // ──────────────────────────────────────────────────────────────────

  /// Lance le listener temps réel sur `pitchFavorites/{userId}`.
  static Future<void> load(String userId) async {
    await _sub?.cancel();
    _sub = _db.child('pitchFavorites/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        pitchFavorites.value = [];
        return;
      }
      try {
        final list = data.values
            .whereType<Map>()
            .map<Map<String, dynamic>>(
                (v) => Map<String, dynamic>.from(v as Map))
            .toList()
          ..sort((a, b) {
            final at = (b['savedAt'] as int?) ?? 0;
            final bt = (a['savedAt'] as int?) ?? 0;
            return at.compareTo(bt);
          });
        pitchFavorites.value = list;
      } catch (_) {
        pitchFavorites.value = [];
      }
    }, onError: (_) => pitchFavorites.value = []);
  }

  /// Vide la liste et annule le listener (appelé à la déconnexion).
  static Future<void> reset() async {
    await _sub?.cancel();
    _sub = null;
    pitchFavorites.value = [];
  }

  // ──────────────────────────────────────────────────────────────────
  // Opérations
  // ──────────────────────────────────────────────────────────────────

  /// Retourne `true` si ce pitch est dans les favoris.
  static bool isFavorite(Map<String, dynamic> pitch) {
    final key = _keyOf(pitch);
    return pitchFavorites.value.any((p) => _keyOf(p) == key);
  }

  /// Ajoute ou retire le pitch des favoris de [userId].
  static Future<void> toggle(String userId, Map<String, dynamic> pitch) async {
    if (userId.isEmpty) return;
    final key = _keyOf(pitch);
    if (key.isEmpty) return;
    final ref = _db.child('pitchFavorites/$userId/$key');
    if (isFavorite(pitch)) {
      await ref.remove();
    } else {
      await ref.set({
        ...pitch,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}

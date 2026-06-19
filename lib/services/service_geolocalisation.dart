import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../data/pays.dart';

class LocationResult {
  final String city;
  final String country;
  final String locality; // quartier/suburb — vide si non détecté
  const LocationResult({
    required this.city,
    required this.country,
    this.locality = '',
  });
}

class LocationService {
  LocationService._();

  /// Détecte la ville de l'utilisateur via GPS + Nominatim reverse geocoding.
  /// Retourne null si la permission est refusée ou si la position ne peut pas
  /// être obtenue.
  static Future<LocationResult?> detectCity() async {
    // 1. Vérifier et demander la permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // 2. Obtenir la position GPS
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 12),
    );

    // 3. Reverse geocoding via Nominatim (OSM) — gratuit, sans clé API
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&accept-language=fr',
    );
    final resp = await http
        .get(uri, headers: {'User-Agent': 'DiapalaAfrica/1.0 (sirimambodj@gmail.com)'})
        .timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final address = (data['address'] as Map?)?.cast<String, dynamic>() ?? {};

    // Extraire la ville depuis les champs possibles
    final rawCity = _firstNonEmpty([
      address['city'],
      address['town'],
      address['village'],
      address['municipality'],
      address['county'],
    ]);
    final rawCountry = address['country']?.toString() ?? '';

    // Extraire la localité fine (quartier, suburb…)
    final rawLocality = _firstNonEmpty([
      address['neighbourhood'],
      address['suburb'],
      address['quarter'],
      address['city_district'],
      address['residential'],
    ]);

    // 4. Correspondance pays supportés
    final matchedCountry = _matchCountry(rawCountry);

    // 5. Correspondance ville disponible dans pays.dart
    final cities = citiesOf(matchedCountry);
    final matchedCity = _matchCity(rawCity, cities);

    return LocationResult(
      city: matchedCity,
      country: matchedCountry,
      locality: rawLocality,
    );
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  static String _matchCountry(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('sénégal') || lower.contains('senegal')) return 'Sénégal';
    if (lower.contains('gambi')) return 'Gambie';
    if (lower.contains('mali')) return 'Mali';
    return 'Sénégal'; // défaut
  }

  static String _matchCity(String raw, List<String> cities) {
    if (raw.isEmpty) return cities.first;
    final rawLower = raw.toLowerCase();

    // Correspondance exacte ou partielle
    for (final city in cities) {
      final cityLower = city.toLowerCase();
      if (rawLower.contains(cityLower) || cityLower.contains(rawLower)) {
        return city;
      }
    }

    // Correspondance par préfixe (ex: "Dakar Plateau" → "Dakar")
    for (final city in cities) {
      if (rawLower.startsWith(city.toLowerCase().substring(0, 3))) {
        return city;
      }
    }

    return cities.first;
  }
}

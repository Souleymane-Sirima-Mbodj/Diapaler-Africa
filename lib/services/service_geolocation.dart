import 'package:geolocator/geolocator.dart';

class GeolocationService {
  /// Coordonnées GPS de toutes les villes / régions du Sénégal.
  static const Map<String, List<double>> cityCoordinates = {
    // Région de Dakar
    'Dakar':       [14.6928, -17.4467],
    'Pikine':      [14.7500, -17.3833],
    'Rufisque':    [14.7167, -17.2667],
    'Guédiawaye':  [14.7750, -17.4000],
    // Région de Thiès
    'Thiès':       [14.7833, -16.9167],
    'Mbour':       [14.3833, -16.9667],
    'Saly':        [14.4667, -17.0167],
    'Tivaouane':   [14.9500, -16.8167],
    'Bambey':      [14.7000, -16.4500],
    // Région de Diourbel
    'Diourbel':    [14.6500, -16.2333],
    'Touba':       [14.8500, -15.8833],
    'Mbacké':      [14.8000, -15.9167],
    // Région de Fatick
    'Fatick':      [14.3333, -16.4000],
    'Gossas':      [14.5000, -16.0500],
    'Foundiougne': [14.1333, -16.4667],
    // Région de Kaolack
    'Kaolack':     [14.1500, -16.0667],
    'Nioro du Rip':[13.7500, -15.7833],
    'Kaffrine':    [14.1000, -15.5500],
    // Région de Kaffrine
    'Malem-Hodar': [14.0833, -15.1167],
    'Birkelane':   [14.0833, -15.7000],
    // Région de Saint-Louis
    'Saint-Louis': [16.0333, -16.5000],
    'Podor':       [16.6500, -14.9667],
    'Dagana':      [16.5167, -15.5000],
    'Richard-Toll': [16.4667, -15.7000],
    // Région de Louga
    'Louga':       [15.6167, -16.2167],
    'Linguère':    [15.3833, -15.1167],
    'Kébémer':     [15.3667, -16.4500],
    // Région de Matam
    'Matam':       [15.6667, -13.2500],
    'Ourossogui':  [15.6167, -13.3167],
    'Kanel':       [15.4833, -13.1833],
    // Région de Tambacounda
    'Tambacounda': [13.7667, -13.6667],
    'Bakel':       [14.9000, -12.4667],
    'Goudiry':     [14.1833, -12.7167],
    // Région de Kédougou
    'Kédougou':    [12.5500, -12.1833],
    'Saraya':      [12.8333, -11.7500],
    // Région de Kolda
    'Kolda':       [12.8833, -14.9500],
    'Vélingara':   [13.1500, -14.1167],
    'Médina Yoro Foula': [12.5000, -14.9000],
    // Région de Sédhiou
    'Sédhiou':     [12.7000, -15.5500],
    'Bounkiling':  [12.8833, -15.6833],
    // Région de Ziguinchor
    'Ziguinchor':  [12.5667, -16.2667],
    'Bignona':     [12.8167, -16.2167],
    'Oussouye':    [12.4833, -16.5500],
  };

  /// Distance en km entre la position utilisateur et une ville.
  static double? distanceKmToCity(Position userPos, String city) {
    final coords = cityCoordinates[city];
    if (coords == null) return null;
    return Geolocator.distanceBetween(
      userPos.latitude, userPos.longitude,
      coords[0], coords[1],
    ) / 1000;
  }

  /// Formate une distance en km de façon lisible.
  static String formatDistance(double km) {
    if (km < 1) return '< 1 km';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static String formatCoordinates(Position position) {
    return '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
  }
}

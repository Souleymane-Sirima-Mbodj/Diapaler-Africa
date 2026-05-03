/// Pays supportés par DIAPALER AFRICA et leurs villes principales.
/// Pour le Livrable 0 on se limite à 3 pays — l'application sera étendue
/// à toute l'Afrique de l'Ouest dans les livrables suivants.
const countriesAndCities = <String, List<String>>{
  'Sénégal': [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Ziguinchor',
    'Kaolack',
    'Mbour',
    'Touba',
    'Diourbel',
    'Tambacounda',
    'Louga',
    'Fatick',
    'Kolda',
    'Matam',
    'Kaffrine',
    'Kédougou',
    'Sédhiou',
    'Diaspora',
  ],
  'Gambie': [
    'Banjul',
    'Serekunda',
    'Brikama',
    'Bakau',
    'Farafenni',
    'Lamin',
    'Sukuta',
    'Soma',
    'Basse Santa Su',
  ],
  'Mali': [
    'Bamako',
    'Sikasso',
    'Kayes',
    'Ségou',
    'Mopti',
    'Gao',
    'Koulikoro',
    'Tombouctou',
    'Kidal',
    'Koutiala',
  ],
};

const supportedCountries = ['Sénégal', 'Gambie', 'Mali'];

List<String> citiesOf(String country) =>
    countriesAndCities[country] ?? const ['Dakar'];

/// Retourne le pays auquel appartient une ville donnée
/// (utile pour reconstituer un profile chargé depuis RTDB).
String? findCountryForCity(String city) {
  for (final entry in countriesAndCities.entries) {
    if (entry.value.contains(city)) return entry.key;
  }
  return null;
}

/// Calcule l'âge à partir d'une date de naissance.
int? ageFromBirthDate(DateTime? birth) {
  if (birth == null) return null;
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    age--;
  }
  return age;
}

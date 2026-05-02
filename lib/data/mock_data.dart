class Mentor {
  final String initials;
  final String name;
  final String title;
  final String city;
  final List<String> sectors;
  final List<String> companies;
  final double rating;
  final int reviews;
  final int years;
  final int compatibility;
  final bool cis;

  const Mentor({
    required this.initials,
    required this.name,
    required this.title,
    required this.city,
    required this.sectors,
    required this.companies,
    required this.rating,
    required this.reviews,
    required this.years,
    required this.compatibility,
    this.cis = false,
  });

  String get firstName => name.split(' ').first;

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        city.toLowerCase().contains(q) ||
        sectors.any((s) => s.toLowerCase().contains(q)) ||
        title.toLowerCase().contains(q);
  }
}

const mentors = <Mentor>[
  Mentor(
    initials: 'AK',
    name: 'Anta Diama Kama',
    title: 'CEO · Diama Cooking',
    city: 'Dakar',
    sectors: ['Gastronomie', 'Food'],
    companies: [
      'Diama Cooking',
      'Diama Catering Services',
      'École Diama Cooking Academy',
    ],
    rating: 4.9,
    reviews: 47,
    years: 15,
    compatibility: 96,
    cis: true,
  ),
  Mentor(
    initials: 'YS',
    name: 'Yérim Habib Sow',
    title: 'Fondateur · Groupe Teyliom',
    city: 'Dakar',
    sectors: ['Télécoms', 'Immobilier', 'Finance'],
    companies: [
      'Groupe Teyliom (52 sociétés)',
      'Eden Roc Hotel & Spa',
      'Elton Oil Company',
      'CCBM (Compagnie Commerciale Bancaire et Mobilière)',
      'Teyliom Properties',
      'Teyliom Industries',
    ],
    rating: 4.8,
    reviews: 62,
    years: 25,
    compatibility: 92,
    cis: true,
  ),
  Mentor(
    initials: 'MN',
    name: 'Mansour Ndao',
    title: 'PDG · Mansour Ndao Holding',
    city: 'Dakar',
    sectors: ['Automobile', 'Lifestyle'],
    companies: [
      'Mansour Ndao Holding',
      'Mansour Motors',
      'TRAMCO',
      'Champs de Luxe',
      'Man Cave',
      'Asma Lounge',
      'Contrap',
      'Secusen',
    ],
    rating: 4.7,
    reviews: 28,
    years: 8,
    compatibility: 88,
    cis: true,
  ),
  Mentor(
    initials: 'BN',
    name: 'Babacar Ngom',
    title: 'Président · Groupe Sedima',
    city: 'Dakar',
    sectors: ['Agro-industrie', 'Avicole'],
    companies: [
      'Groupe Sedima',
      'Sedima Holding',
      'Sedima Services',
      'Yobante Express',
      'Banque Nationale du Sénégal (administrateur)',
    ],
    rating: 4.9,
    reviews: 81,
    years: 30,
    compatibility: 84,
    cis: true,
  ),
  Mentor(
    initials: 'MD',
    name: 'Mossane Diop',
    title: 'Fondatrice · Mossane Cosmetics',
    city: 'Thiès',
    sectors: ['Cosmétique', 'Beauté', 'Mode & Textile'],
    companies: [
      'Mossane Cosmetics',
      'Mossane Beauty Lab',
    ],
    rating: 4.7,
    reviews: 34,
    years: 7,
    compatibility: 91,
  ),
  Mentor(
    initials: 'AN',
    name: 'Aminata Niane',
    title: 'CEO · Sahel Digital',
    city: 'Dakar',
    sectors: ['Tech & Digital', 'E-commerce'],
    companies: [
      'Sahel Digital',
      'Téranga Tech Hub',
      'Niane Capital Partners',
    ],
    rating: 4.8,
    reviews: 51,
    years: 12,
    compatibility: 94,
    cis: true,
  ),
  Mentor(
    initials: 'KB',
    name: 'Khadim Bâ',
    title: 'PDG · Locafrique Holding',
    city: 'Dakar',
    sectors: ['BTP', 'Logistique'],
    companies: [
      'Locafrique Holding',
      'Locafrique Sénégal',
      'African Trade Logistics',
      'Bâ & Associés Construction',
    ],
    rating: 4.6,
    reviews: 26,
    years: 18,
    compatibility: 78,
    cis: true,
  ),
  Mentor(
    initials: 'AD',
    name: 'Aïssa Dione',
    title: 'Designer · Aïssa Dione Tissus',
    city: 'Saint-Louis',
    sectors: ['Mode & Textile', 'Artisanat'],
    companies: [
      'Aïssa Dione Tissus',
      'Manufactures Sénégalaises des Arts Décoratifs',
      'Atelier Tissage de Rufisque',
    ],
    rating: 4.9,
    reviews: 42,
    years: 22,
    compatibility: 97,
  ),
  Mentor(
    initials: 'PD',
    name: 'Pape Diouf',
    title: 'Fondateur · Wave Sénégal',
    city: 'Dakar',
    sectors: ['FinTech', 'Mobile Money'],
    companies: [
      'Wave Sénégal',
      'Wave Mobile Money International',
    ],
    rating: 4.8,
    reviews: 58,
    years: 9,
    compatibility: 95,
    cis: true,
  ),
  Mentor(
    initials: 'MW',
    name: 'Magatte Wade',
    title: 'Fondatrice · SkinIsSkin',
    city: 'Dakar',
    sectors: ['Cosmétique', 'Beauté'],
    companies: [
      'SkinIsSkin',
      'Adina World Beat Beverages',
      'Tiossan',
    ],
    rating: 4.7,
    reviews: 39,
    years: 14,
    compatibility: 82,
  ),
  Mentor(
    initials: 'OS',
    name: 'Ousmane Sané',
    title: 'CEO · Téranga Energy',
    city: 'Ziguinchor',
    sectors: ['Énergie', 'Renouvelable'],
    companies: [
      'Téranga Energy',
      'Casamance Solar',
    ],
    rating: 4.6,
    reviews: 21,
    years: 10,
    compatibility: 80,
  ),
  Mentor(
    initials: 'FF',
    name: 'Fatou Fall',
    title: 'Directrice · MedTech Dakar',
    city: 'Dakar',
    sectors: ['Santé', 'E-santé'],
    companies: [
      'MedTech Dakar',
      'TéléSanté Sénégal',
    ],
    rating: 4.8,
    reviews: 33,
    years: 11,
    compatibility: 89,
  ),
];

/// Secteurs du projet en cours de l'utilisatrice (Téranga Mode).
/// Sert à filtrer les mentors recommandés sur le dashboard.
const _userProjectSectors = <String>[
  'Mode & Textile',
  'Artisanat',
  'Cosmétique',
  'Beauté',
];

/// Mentors recommandés pour Mariéme Tine (Téranga Mode), triés par
/// compatibilité décroissante. Filtrage sur les secteurs du projet.
List<Mentor> get recommendedMentors {
  final list = mentors.where((m) {
    return m.sectors.any((s) => _userProjectSectors.contains(s));
  }).toList()
    ..sort((a, b) => b.compatibility.compareTo(a.compatibility));
  return list;
}

/// Liste fermée des secteurs (utilisée par les filtres et le dropdown pitch).
const allSectors = <String>[
  'Agro-industrie',
  'Agriculture',
  'Avicole',
  'Artisanat',
  'Automobile',
  'Beauté',
  'BTP',
  'Cosmétique',
  'E-commerce',
  'E-santé',
  'Éducation / EdTech',
  'Énergie',
  'FinTech',
  'Finance',
  'Food',
  'Gastronomie',
  'Hôtellerie',
  'Immobilier',
  'Lifestyle',
  'Logistique',
  'Médias',
  'Mobile Money',
  'Mode & Textile',
  'Renouvelable',
  'Santé',
  'Services',
  'Tech & Digital',
  'Télécoms',
  'Tourisme',
  'Transport',
  'Autre',
];

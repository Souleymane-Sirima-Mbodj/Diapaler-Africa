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
  Mentor(
    initials: 'KS',
    name: 'Khadidiatou Sall',
    title: 'Fondatrice · Sénégal Étudie',
    city: 'Dakar',
    sectors: ['Éducation / EdTech', 'Tech & Digital'],
    companies: [
      'Sénégal Étudie',
      'Académie Numérique Dakar',
      'Bourse Étudiants Africains',
    ],
    rating: 4.9,
    reviews: 44,
    years: 9,
    compatibility: 90,
  ),
  Mentor(
    initials: 'CN',
    name: 'Cheikh Niasse',
    title: 'CEO · WikiAfrica Médias',
    city: 'Dakar',
    sectors: ['Médias', 'Tech & Digital'],
    companies: [
      'WikiAfrica Médias',
      'Sénégal Live TV',
      'Podcast Réseau Africain',
    ],
    rating: 4.6,
    reviews: 29,
    years: 12,
    compatibility: 78,
  ),
  Mentor(
    initials: 'AB',
    name: 'Aïssatou Ba',
    title: 'Fondatrice · Téranga Travel',
    city: 'Saly',
    sectors: ['Tourisme', 'Hôtellerie'],
    companies: [
      'Téranga Travel',
      'Saly Beach Resort',
      'Saly Travel Agency',
    ],
    rating: 4.8,
    reviews: 51,
    years: 13,
    compatibility: 82,
  ),
  Mentor(
    initials: 'MT',
    name: 'Mor Talla Kane',
    title: 'PDG · Niayes AgriCorp',
    city: 'Thiès',
    sectors: ['Agriculture', 'Agro-industrie', 'Avicole'],
    companies: [
      'Niayes AgriCorp',
      'Coopérative Maraîchère du Cap-Vert',
      'AgriExport Sénégal',
    ],
    rating: 4.7,
    reviews: 38,
    years: 16,
    compatibility: 85,
  ),
  Mentor(
    initials: 'AS',
    name: 'Astou Diop',
    title: 'CEO · Marketplace Téranga',
    city: 'Dakar',
    sectors: ['E-commerce', 'Tech & Digital'],
    companies: [
      'Marketplace Téranga',
      'Livraison Express SN',
      'Boutique Digitale Africaine',
    ],
    rating: 4.7,
    reviews: 42,
    years: 8,
    compatibility: 88,
  ),
  Mentor(
    initials: 'IS',
    name: 'Ibrahima Sow',
    title: 'PDG · Gaïndé Transport',
    city: 'Kaolack',
    sectors: ['Logistique', 'Transport'],
    companies: [
      'Gaïndé Transport',
      'CargoSén Logistique',
      'Flotte Atlantique Ouest',
    ],
    rating: 4.5,
    reviews: 22,
    years: 14,
    compatibility: 76,
  ),
  Mentor(
    initials: 'MF',
    name: 'Mariama Faye',
    title: 'Associée · MF Consulting',
    city: 'Dakar',
    sectors: ['Services', 'Finance'],
    companies: [
      'MF Consulting',
      'Africa Strategy Partners',
    ],
    rating: 4.8,
    reviews: 47,
    years: 17,
    compatibility: 84,
  ),
  Mentor(
    initials: 'DM',
    name: 'Daouda Mbaye',
    title: 'Président · Téranga Hospitality',
    city: 'Dakar',
    sectors: ['Hôtellerie', 'Tourisme', 'Lifestyle'],
    companies: [
      'Téranga Hospitality Group',
      'Almadies Beach Hotel',
      'Saly Resort & Spa',
      'Dakar Plaza',
    ],
    rating: 4.7,
    reviews: 36,
    years: 20,
    compatibility: 81,
    cis: true,
  ),
  Mentor(
    initials: 'CD',
    name: 'Cheikh Tidiane Diop',
    title: 'Pharmacien · Pharma Plus Sénégal',
    city: 'Dakar',
    sectors: ['Santé', 'E-santé'],
    companies: [
      'Pharma Plus Sénégal',
      'Réseau de Pharmacies Téranga',
      'Distrib-Médicaments SA',
    ],
    rating: 4.6,
    reviews: 31,
    years: 19,
    compatibility: 79,
  ),
  Mentor(
    initials: 'AC',
    name: 'Awa Cissé',
    title: 'Fondatrice · Awa Naturelle',
    city: 'Dakar',
    sectors: ['Cosmétique', 'Beauté', 'Mode & Textile'],
    companies: [
      'Awa Naturelle',
      'Beauté Africaine Cosmetics',
    ],
    rating: 4.8,
    reviews: 56,
    years: 6,
    compatibility: 92,
  ),
  Mentor(
    initials: 'OD',
    name: 'Ousmane Diagne',
    title: 'Directeur · Banque Atlantique SN',
    city: 'Dakar',
    sectors: ['Finance', 'FinTech'],
    companies: [
      'Banque Atlantique Sénégal',
      'Atlantique Microfinance',
      'Paiements Mobiles Atlantique',
    ],
    rating: 4.7,
    reviews: 48,
    years: 22,
    compatibility: 83,
    cis: true,
  ),
  Mentor(
    initials: 'FS',
    name: 'Fatima Sy',
    title: 'Directrice · Africa Éditions',
    city: 'Dakar',
    sectors: ['Médias', 'Éducation / EdTech'],
    companies: [
      'Africa Éditions',
      'Librairie Sankoré',
      'Manuels Scolaires SN',
    ],
    rating: 4.6,
    reviews: 25,
    years: 15,
    compatibility: 77,
  ),
];

/// Calcule les mentors recommandés pour un utilisateur donné.
///
/// Source des secteurs pertinents (par ordre de priorité) :
///   1. Le secteur principal du profil (si défini)
///   2. Les secteurs des projets en cours
///   3. Les centres d'intérêt sélectionnés
///
/// Tri : d'abord par nombre de secteurs en commun (overlap), puis par
/// compatibility globale du mentor. Si l'utilisateur n'a sélectionné
/// aucun secteur, on retourne tous les mentors triés par compatibility.
List<Mentor> recommendedMentorsFor({
  required String userSector,
  required List<String> userInterests,
  required List<String> projectSectors,
}) {
  final relevant = <String>{};
  if (userSector.isNotEmpty && userSector != 'Autre') {
    relevant.add(userSector);
  }
  for (final s in projectSectors) {
    if (s.isNotEmpty) relevant.add(s);
  }
  relevant.addAll(userInterests);

  if (relevant.isEmpty) {
    return mentors.toList()
      ..sort((a, b) => b.compatibility.compareTo(a.compatibility));
  }

  final scored = mentors
      .map((m) {
        final overlap =
            m.sectors.where((s) => relevant.contains(s)).length;
        return (m, overlap);
      })
      .where((e) => e.$2 > 0)
      .toList()
    ..sort((a, b) {
      final byOverlap = b.$2.compareTo(a.$2);
      if (byOverlap != 0) return byOverlap;
      return b.$1.compatibility.compareTo(a.$1.compatibility);
    });

  return scored.map((e) => e.$1).toList();
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

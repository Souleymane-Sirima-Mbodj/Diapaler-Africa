import 'profil_utilisateur.dart';

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
  final String role; // 'Mentor' ou 'Investisseur'
  final Gender gender;
  final String bio;
  /// UID Firebase — vide pour les mentors statiques, rempli pour les membres réels.
  final String uid;

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
    this.role = 'Mentor',
    this.gender = Gender.undisclosed,
    this.bio = '',
    this.uid = '',
  });

  bool get isInvestor => role == 'Investisseur';

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
  // ─── Agro / Food / Gastronomie ───
  Mentor(
    initials: 'MD',
    name: 'Mamadou Diop',
    title: 'PDG · Casamance Agro',
    city: 'Ziguinchor',
    sectors: ['Agriculture', 'Agro-industrie'],
    companies: ['Casamance Agro', 'Riz du Sud SARL'],
    rating: 4.6, reviews: 28, years: 18, compatibility: 80,
  ),
  Mentor(
    initials: 'BF',
    name: 'Bineta Faye',
    title: 'Fondatrice · Aviculteurs du Sénégal',
    city: 'Thiès',
    sectors: ['Avicole', 'Agriculture', 'Agro-industrie'],
    companies: ['Aviculteurs du Sénégal', 'Élevage Faye & Fils'],
    rating: 4.7, reviews: 32, years: 14, compatibility: 84,
  ),
  Mentor(
    initials: 'CS',
    name: 'Cheikh Sarr',
    title: 'Chef · Téranga Cuisine',
    city: 'Dakar',
    sectors: ['Gastronomie', 'Food', 'Hôtellerie'],
    companies: ['Téranga Cuisine', 'Restaurant Le Sénégalais', 'Catering Plus'],
    rating: 4.8, reviews: 41, years: 12, compatibility: 86,
  ),
  Mentor(
    initials: 'RN',
    name: 'Rama Niang',
    title: 'Cheffe · Bonne Cuisine Africaine',
    city: 'Dakar',
    sectors: ['Gastronomie', 'Food'],
    companies: ['Bonne Cuisine Africaine', 'Académie Culinaire SN'],
    rating: 4.9, reviews: 36, years: 10, compatibility: 88,
  ),
  Mentor(
    initials: 'AD2',
    name: 'Abdou Diallo',
    title: 'Producteur · Niayes Frais',
    city: 'Saint-Louis',
    sectors: ['Agriculture', 'Food', 'Agro-industrie', 'Avicole'],
    companies: ['Niayes Frais', 'Maraîchers du Nord'],
    rating: 4.5, reviews: 22, years: 16, compatibility: 79,
  ),
  Mentor(
    initials: 'KD',
    name: 'Khady Dia',
    title: 'Restauratrice · Saveurs Téranga',
    city: 'Saly',
    sectors: ['Gastronomie', 'Food', 'Tourisme'],
    companies: ['Saveurs Téranga', 'Restaurant Atlantique'],
    rating: 4.7, reviews: 27, years: 9, compatibility: 82,
  ),
  // ─── Artisanat / Mode / Cosmétique / Beauté ───
  Mentor(
    initials: 'CD2',
    name: 'Coumba Diop',
    title: 'Artisane · Bogolan Atelier',
    city: 'Saint-Louis',
    sectors: ['Artisanat', 'Mode & Textile'],
    companies: ['Bogolan Atelier', 'Tisseuses du Walo'],
    rating: 4.8, reviews: 29, years: 14, compatibility: 85,
  ),
  Mentor(
    initials: 'PS',
    name: 'Penda Sy',
    title: 'Fondatrice · Penda Beauty',
    city: 'Dakar',
    sectors: ['Cosmétique', 'Beauté'],
    companies: ['Penda Beauty', 'Beauté Naturelle SN'],
    rating: 4.7, reviews: 38, years: 8, compatibility: 86,
  ),
  Mentor(
    initials: 'SM',
    name: 'Sokhna Mbaye',
    title: 'Designer · Sokhna Crafts',
    city: 'Touba',
    sectors: ['Artisanat', 'Mode & Textile', 'Beauté'],
    companies: ['Sokhna Crafts', 'Boutique Touba Style'],
    rating: 4.6, reviews: 24, years: 11, compatibility: 81,
  ),
  Mentor(
    initials: 'YB',
    name: 'Yacine Bâ',
    title: 'Styliste · Téranga Couture',
    city: 'Dakar',
    sectors: ['Mode & Textile', 'Artisanat'],
    companies: ['Téranga Couture', 'Atelier Yacine Bâ'],
    rating: 4.8, reviews: 33, years: 13, compatibility: 88,
  ),
  // ─── Automobile / Transport / Logistique ───
  Mentor(
    initials: 'MS',
    name: 'Modou Sow',
    title: 'PDG · Auto Plus Sénégal',
    city: 'Dakar',
    sectors: ['Automobile', 'Transport'],
    companies: ['Auto Plus Sénégal', 'Garage Auto Centre'],
    rating: 4.5, reviews: 21, years: 17, compatibility: 76,
  ),
  Mentor(
    initials: 'AD3',
    name: 'Aliou Diallo',
    title: 'Directeur · Logistique Express',
    city: 'Kaolack',
    sectors: ['Logistique', 'Transport'],
    companies: ['Logistique Express', 'Transit Régional'],
    rating: 4.6, reviews: 26, years: 15, compatibility: 78,
  ),
  Mentor(
    initials: 'BC',
    name: 'Babacar Cissé',
    title: 'Importateur · Cisco Automobile',
    city: 'Dakar',
    sectors: ['Automobile', 'Lifestyle'],
    companies: ['Cisco Automobile', 'Pièces Auto SN'],
    rating: 4.6, reviews: 19, years: 11, compatibility: 75,
  ),
  Mentor(
    initials: 'IN',
    name: 'Ibrahima Niang',
    title: 'CEO · TransAfrica Logistics',
    city: 'Dakar',
    sectors: ['Transport', 'Logistique', 'Automobile'],
    companies: ['TransAfrica Logistics', 'Flotte Sénégalaise'],
    rating: 4.7, reviews: 30, years: 20, compatibility: 82,
  ),
  // ─── Énergie / Renouvelable ───
  Mentor(
    initials: 'YN',
    name: 'Yacine Ndiaye',
    title: 'CEO · Solar Power Sénégal',
    city: 'Dakar',
    sectors: ['Énergie', 'Renouvelable'],
    companies: ['Solar Power Sénégal', 'EcoSolaire Africa'],
    rating: 4.8, reviews: 34, years: 12, compatibility: 87,
  ),
  Mentor(
    initials: 'BK',
    name: 'Boubacar Ka',
    title: 'Fondateur · EnergyTech SN',
    city: 'Dakar',
    sectors: ['Énergie', 'Tech & Digital', 'Services'],
    companies: ['EnergyTech SN', 'Smart Grid Africa'],
    rating: 4.7, reviews: 28, years: 14, compatibility: 84,
  ),
  Mentor(
    initials: 'KH',
    name: 'Khady Diallo',
    title: 'Fondatrice · EcoFarm',
    city: 'Thiès',
    sectors: ['Renouvelable', 'Agriculture', 'Agro-industrie'],
    companies: ['EcoFarm', 'Bio-Énergie Niayes'],
    rating: 4.6, reviews: 23, years: 10, compatibility: 80,
  ),
  Mentor(
    initials: 'AS2',
    name: 'Aïda Sène',
    title: 'CTO · GreenTech Sénégal',
    city: 'Dakar',
    sectors: ['Renouvelable', 'Tech & Digital', 'Énergie'],
    companies: ['GreenTech Sénégal', 'Climat Numérique'],
    rating: 4.8, reviews: 31, years: 9, compatibility: 88,
  ),
  // ─── Finance / FinTech / Mobile Money ───
  Mentor(
    initials: 'OF',
    name: 'Ousmane Faye',
    title: 'Banquier · Banque Privée SN',
    city: 'Dakar',
    sectors: ['Finance', 'FinTech'],
    companies: ['Banque Privée Sénégal', 'Conseil Financier SN'],
    rating: 4.7, reviews: 39, years: 22, compatibility: 83,
    cis: true,
  ),
  Mentor(
    initials: 'ASR',
    name: 'Aminata Sarr',
    title: 'CTO · PaySN',
    city: 'Dakar',
    sectors: ['FinTech', 'Mobile Money', 'Tech & Digital'],
    companies: ['PaySN', 'Wallet Plus'],
    rating: 4.8, reviews: 42, years: 8, compatibility: 89,
  ),
  Mentor(
    initials: 'CC',
    name: 'Cheikhou Camara',
    title: 'Fondateur · Wallet Africa',
    city: 'Dakar',
    sectors: ['Mobile Money', 'FinTech', 'Services'],
    companies: ['Wallet Africa', 'PayMobile SN'],
    rating: 4.6, reviews: 27, years: 7, compatibility: 81,
  ),
  Mentor(
    initials: 'NF',
    name: 'Ndèye Fall',
    title: 'Directrice · Microfinance Téranga',
    city: 'Kaolack',
    sectors: ['Finance', 'Mobile Money'],
    companies: ['Microfinance Téranga', 'Caisse Régionale'],
    rating: 4.7, reviews: 35, years: 18, compatibility: 84,
  ),
  // ─── Hôtellerie / Tourisme / Lifestyle ───
  Mentor(
    initials: 'NDI',
    name: 'Ndèye Diop',
    title: 'Manager · Cap Skirring Resort',
    city: 'Ziguinchor',
    sectors: ['Hôtellerie', 'Tourisme'],
    companies: ['Cap Skirring Resort', 'Casamance Tours'],
    rating: 4.7, reviews: 29, years: 13, compatibility: 82,
  ),
  Mentor(
    initials: 'MK',
    name: 'Modou Ka',
    title: 'Fondateur · Voyage Téranga',
    city: 'Dakar',
    sectors: ['Tourisme', 'Lifestyle', 'Hôtellerie'],
    companies: ['Voyage Téranga', 'Téranga Travel Plus'],
    rating: 4.6, reviews: 25, years: 10, compatibility: 79,
  ),
  Mentor(
    initials: 'KF',
    name: 'Khady Faye',
    title: 'Influenceuse · Lifestyle SN',
    city: 'Dakar',
    sectors: ['Lifestyle', 'Beauté', 'Médias'],
    companies: ['Lifestyle SN', 'Khady Faye Brand'],
    rating: 4.8, reviews: 51, years: 6, compatibility: 86,
  ),
  // ─── Santé / E-santé / Pharmacie ───
  Mentor(
    initials: 'ALD',
    name: 'Dr. Aliou Diop',
    title: 'Médecin · Cabinet Plateau',
    city: 'Dakar',
    sectors: ['Santé', 'E-santé'],
    companies: ['Cabinet Médical Plateau', 'Réseau Médecins SN'],
    rating: 4.9, reviews: 47, years: 25, compatibility: 90,
  ),
  Mentor(
    initials: 'PK',
    name: 'Khady Pouye',
    title: 'Pharmacienne · Réseau Pharmacies',
    city: 'Thiès',
    sectors: ['Santé', 'Services'],
    companies: ['Réseau Pharmacies SN', 'Pharma Express'],
    rating: 4.7, reviews: 33, years: 16, compatibility: 83,
  ),
  Mentor(
    initials: 'CTK',
    name: 'Cheikh T. Ka',
    title: 'CEO · TeleMed SN',
    city: 'Dakar',
    sectors: ['E-santé', 'Tech & Digital', 'Santé'],
    companies: ['TeleMed SN', 'Santé Connectée Africa'],
    rating: 4.8, reviews: 38, years: 11, compatibility: 87,
  ),
  // ─── Médias / EdTech / Tech ───
  Mentor(
    initials: 'AN2',
    name: 'Awa Niang',
    title: 'Fondatrice · Journal Numérique SN',
    city: 'Dakar',
    sectors: ['Médias', 'Éducation / EdTech'],
    companies: ['Journal Numérique SN', 'Africa News Daily'],
    rating: 4.7, reviews: 29, years: 12, compatibility: 84,
  ),
  Mentor(
    initials: 'PN',
    name: 'Pape Ndiaye',
    title: 'Fondateur · Coding Africa',
    city: 'Dakar',
    sectors: ['Éducation / EdTech', 'Tech & Digital'],
    companies: ['Coding Africa', 'École Numérique Dakar'],
    rating: 4.9, reviews: 44, years: 9, compatibility: 91,
  ),
  Mentor(
    initials: 'MD2',
    name: 'Mariam Diop',
    title: 'Directrice · Magazine Téranga',
    city: 'Dakar',
    sectors: ['Médias', 'Lifestyle'],
    companies: ['Magazine Téranga', 'Édition Sahel'],
    rating: 4.6, reviews: 22, years: 14, compatibility: 78,
  ),
  // ─── Télécoms / Immobilier / BTP / Services ───
  Mentor(
    initials: 'ID',
    name: 'Idrissa Diop',
    title: 'CEO · Sénégal Connect',
    city: 'Dakar',
    sectors: ['Télécoms', 'Tech & Digital'],
    companies: ['Sénégal Connect', 'Fibre Téranga'],
    rating: 4.7, reviews: 36, years: 18, compatibility: 85,
    cis: true,
  ),
  Mentor(
    initials: 'MSY',
    name: 'Maïmouna Sy',
    title: 'PDG · Immo Plus Dakar',
    city: 'Dakar',
    sectors: ['Immobilier', 'BTP'],
    companies: ['Immo Plus Dakar', 'Promoteur Téranga'],
    rating: 4.6, reviews: 30, years: 15, compatibility: 80,
  ),
  Mentor(
    initials: 'CAF',
    name: 'Cheikh A. Faye',
    title: 'Fondateur · Constructions Africaines',
    city: 'Dakar',
    sectors: ['BTP', 'Immobilier', 'Services'],
    companies: ['Constructions Africaines', 'Bâtiment Plus SN'],
    rating: 4.7, reviews: 28, years: 21, compatibility: 82,
    cis: true,
  ),
  Mentor(
    initials: 'AMN',
    name: 'Aminata Niang',
    title: 'Manager · Mobile SN Pro',
    city: 'Dakar',
    sectors: ['Télécoms', 'Services', 'Mobile Money'],
    companies: ['Mobile SN Pro', 'Téléphonie Africa'],
    rating: 4.6, reviews: 24, years: 11, compatibility: 78,
  ),
  Mentor(
    initials: 'OBA',
    name: 'Ousmane Bâ',
    title: 'Architecte · Cabinet Bâ & Co',
    city: 'Dakar',
    sectors: ['Immobilier', 'BTP', 'Services'],
    companies: ['Cabinet Bâ & Co', 'Architecture Sénégal'],
    rating: 4.8, reviews: 32, years: 19, compatibility: 86,
  ),
  Mentor(
    initials: 'SD',
    name: 'Seydou Diop',
    title: 'Promoteur · Téranga Real Estate',
    city: 'Saly',
    sectors: ['Immobilier', 'Hôtellerie', 'BTP'],
    companies: ['Téranga Real Estate', 'Saly Properties'],
    rating: 4.7, reviews: 26, years: 17, compatibility: 81,
  ),
  Mentor(
    initials: 'AT',
    name: 'Aboubacar Touré',
    title: 'CEO · Touré Telecom',
    city: 'Dakar',
    sectors: ['Télécoms', 'Tech & Digital', 'Services'],
    companies: ['Touré Telecom', 'Réseau Africa'],
    rating: 4.6, reviews: 23, years: 16, compatibility: 79,
  ),
  // ─── E-commerce ───
  Mentor(
    initials: 'BS',
    name: 'Bineta Sow',
    title: 'Fondatrice · FashionSN',
    city: 'Dakar',
    sectors: ['E-commerce', 'Mode & Textile'],
    companies: ['FashionSN', 'Téranga Online Store'],
    rating: 4.7, reviews: 31, years: 7, compatibility: 84,
  ),
  Mentor(
    initials: 'MC',
    name: 'Modou Cissé',
    title: 'CEO · Marketplace Africa',
    city: 'Dakar',
    sectors: ['E-commerce', 'Lifestyle', 'Tech & Digital'],
    companies: ['Marketplace Africa', 'Boutique en ligne SN'],
    rating: 4.6, reviews: 25, years: 9, compatibility: 80,
  ),

  // ─── Région Dakar (banlieue) ───
  Mentor(
    initials: 'MG',
    name: 'Mamadou Guèye',
    title: 'PDG · Guèye Construction',
    city: 'Rufisque',
    sectors: ['BTP', 'Immobilier', 'Services'],
    companies: ['Guèye Construction', 'Rufisque Bâtiment'],
    rating: 4.6, reviews: 22, years: 14, compatibility: 80,
  ),
  Mentor(
    initials: 'FDi',
    name: 'Fatou Diallo',
    title: 'Fondatrice · Pikine Commerce Digital',
    city: 'Pikine',
    sectors: ['E-commerce', 'Commerce', 'Services'],
    companies: ['Pikine Commerce Digital', 'Boutique Banlieue SN'],
    rating: 4.5, reviews: 18, years: 7, compatibility: 78,
  ),

  // ─── Région Thiès (compléments) ───
  Mentor(
    initials: 'OBa',
    name: 'Omar Badji',
    title: 'Fondateur · Mbour Tourisme Plus',
    city: 'Mbour',
    sectors: ['Tourisme', 'Hôtellerie', 'Services'],
    companies: ['Mbour Tourisme Plus', 'Côte des Filets'],
    rating: 4.6, reviews: 24, years: 10, compatibility: 79,
  ),
  Mentor(
    initials: 'AFa',
    name: 'Awa Fall',
    title: 'PDG · Tivaouane Agri Services',
    city: 'Tivaouane',
    sectors: ['Agriculture', 'Agro-industrie', 'Services'],
    companies: ['Tivaouane Agri Services', 'Coopérative Niayes Centre'],
    rating: 4.5, reviews: 19, years: 12, compatibility: 77,
  ),

  // ─── Région Fatick ───
  Mentor(
    initials: 'ACi',
    name: 'Aminata Cissokho',
    title: 'Fondatrice · Fatick AgroFemmes',
    city: 'Fatick',
    sectors: ['Agriculture', 'Agro-industrie', 'Finance'],
    companies: ['Fatick AgroFemmes', 'Microfinance Sine-Saloum'],
    rating: 4.7, reviews: 28, years: 11, compatibility: 83,
  ),
  Mentor(
    initials: 'MDg',
    name: 'Moussa Diagne',
    title: 'PDG · Gossas Agri+',
    city: 'Gossas',
    sectors: ['Agriculture', 'Agro-industrie', 'Avicole'],
    companies: ['Gossas Agri+', 'Élevage Sine Saloum'],
    rating: 4.5, reviews: 16, years: 13, compatibility: 76,
  ),
  Mentor(
    initials: 'BDi',
    name: 'Baye Diaw',
    title: 'CEO · Foundiougne Pêche Durable',
    city: 'Foundiougne',
    sectors: ['Agriculture', 'Food', 'Tourisme'],
    companies: ['Foundiougne Pêche Durable', 'Delta du Saloum Nature'],
    rating: 4.6, reviews: 20, years: 9, compatibility: 78,
  ),

  // ─── Région Kaffrine ───
  Mentor(
    initials: 'ICi',
    name: 'Ibrahima Cissé',
    title: 'Fondateur · Kaffrine Élevage',
    city: 'Kaffrine',
    sectors: ['Agriculture', 'Agro-industrie', 'Avicole'],
    companies: ['Kaffrine Élevage', 'Coopérative Pastorale Centre'],
    rating: 4.5, reviews: 17, years: 16, compatibility: 75,
  ),
  Mentor(
    initials: 'MDl',
    name: 'Marème Diallo',
    title: 'Directrice · Kaffrine Microfinance',
    city: 'Kaffrine',
    sectors: ['Finance', 'Services', 'Agriculture'],
    companies: ['Kaffrine Microfinance', 'Réseau Femmes Rurales'],
    rating: 4.6, reviews: 21, years: 12, compatibility: 80,
  ),

  // ─── Région Louga ───
  Mentor(
    initials: 'CLo',
    name: 'Cheikh Lô',
    title: 'PDG · Louga Commerce & Transit',
    city: 'Louga',
    sectors: ['Commerce', 'Transport', 'Logistique'],
    companies: ['Louga Commerce & Transit', 'Nord Transit SN'],
    rating: 4.6, reviews: 23, years: 17, compatibility: 79,
  ),
  Mentor(
    initials: 'NSa',
    name: 'Ndéye Sall',
    title: 'Fondatrice · Artisanat Louga',
    city: 'Louga',
    sectors: ['Artisanat', 'Mode & Textile', 'Agriculture'],
    companies: ['Artisanat Louga', 'Tisseuses du Cayor'],
    rating: 4.7, reviews: 26, years: 10, compatibility: 81,
  ),

  // ─── Région Saint-Louis (compléments) ───
  Mentor(
    initials: 'OSo',
    name: 'Oumar Sow',
    title: 'PDG · Podor Élevage Sahel',
    city: 'Podor',
    sectors: ['Agriculture', 'Agro-industrie', 'Avicole'],
    companies: ['Podor Élevage Sahel', 'Fleuve Agri Services'],
    rating: 4.5, reviews: 18, years: 20, compatibility: 74,
  ),
  Mentor(
    initials: 'ABa',
    name: 'Aminata Baldé',
    title: 'CEO · Dagana Riz & Céréales',
    city: 'Dagana',
    sectors: ['Agriculture', 'Agro-industrie', 'Food'],
    companies: ['Dagana Riz & Céréales', 'Vallée Agricole Nord'],
    rating: 4.6, reviews: 22, years: 14, compatibility: 78,
  ),

  // ─── Région Matam ───
  Mentor(
    initials: 'DDl',
    name: 'Demba Diallo',
    title: 'Fondateur · Matam Agro-Pastoral',
    city: 'Matam',
    sectors: ['Agriculture', 'Agro-industrie', 'Services'],
    companies: ['Matam Agro-Pastoral', 'Sahel Bétail Export'],
    rating: 4.5, reviews: 15, years: 18, compatibility: 73,
  ),
  Mentor(
    initials: 'HSo',
    name: 'Hawa Sow',
    title: 'Directrice · Microfinance Fouta',
    city: 'Matam',
    sectors: ['Finance', 'Services', 'Éducation / EdTech'],
    companies: ['Microfinance Fouta', 'Réseau Femmes Fouta'],
    rating: 4.6, reviews: 20, years: 13, compatibility: 77,
  ),

  // ─── Région Tambacounda ───
  Mentor(
    initials: 'OBl',
    name: 'Oumar Baldé',
    title: 'PDG · Tambacounda Commerce',
    city: 'Tambacounda',
    sectors: ['Commerce', 'Agro-industrie', 'Transport'],
    companies: ['Tambacounda Commerce', 'Tamba Transit Est'],
    rating: 4.5, reviews: 19, years: 15, compatibility: 75,
  ),
  Mentor(
    initials: 'ADl',
    name: 'Aïssatou Diallo',
    title: 'Fondatrice · EduTamba',
    city: 'Tambacounda',
    sectors: ['Éducation / EdTech', 'Services', 'Tech & Digital'],
    companies: ['EduTamba', 'Centre Numérique Est Sénégal'],
    rating: 4.7, reviews: 24, years: 8, compatibility: 82,
  ),

  // ─── Région Kédougou ───
  Mentor(
    initials: 'DCa',
    name: 'Daouda Camara',
    title: 'CEO · Kédougou Resources',
    city: 'Kédougou',
    sectors: ['Agriculture', 'Renouvelable', 'Services'],
    companies: ['Kédougou Resources', 'Or & Développement SN'],
    rating: 4.6, reviews: 17, years: 12, compatibility: 77,
  ),

  // ─── Région Kolda ───
  Mentor(
    initials: 'MaDl',
    name: 'Mamadou Diallo',
    title: 'PDG · Kolda Agri Sud',
    city: 'Kolda',
    sectors: ['Agriculture', 'Agro-industrie', 'Food'],
    companies: ['Kolda Agri Sud', 'Casamance Intérieure Agro'],
    rating: 4.5, reviews: 16, years: 17, compatibility: 74,
  ),
  Mentor(
    initials: 'FBl',
    name: 'Fatoumata Baldé',
    title: 'Fondatrice · Kolda Femmes Entrepreneurs',
    city: 'Vélingara',
    sectors: ['Commerce', 'Artisanat', 'Services'],
    companies: ['Kolda Femmes Entrepreneurs', 'Marché Sud SARL'],
    rating: 4.6, reviews: 21, years: 9, compatibility: 78,
  ),

  // ─── Région Sédhiou ───
  Mentor(
    initials: 'ACo',
    name: 'Adama Coly',
    title: 'Fondateur · Sédhiou Artisanat Casamance',
    city: 'Sédhiou',
    sectors: ['Artisanat', 'Agriculture', 'Tourisme'],
    companies: ['Sédhiou Artisanat Casamance', 'Forêts & Développement'],
    rating: 4.5, reviews: 14, years: 10, compatibility: 74,
  ),

  // ─── Région Ziguinchor (compléments) ───
  Mentor(
    initials: 'MDt',
    name: 'Marie-Thérèse Diatta',
    title: 'Fondatrice · Bignona Nature & Tourisme',
    city: 'Bignona',
    sectors: ['Tourisme', 'Artisanat', 'Agriculture'],
    companies: ['Bignona Nature & Tourisme', 'Kassolol Artisanat'],
    rating: 4.7, reviews: 25, years: 11, compatibility: 81,
  ),
  Mentor(
    initials: 'SDi',
    name: 'Samba Dione',
    title: 'PDG · Nioro AgroExport',
    city: 'Nioro du Rip',
    sectors: ['Agriculture', 'Agro-industrie', 'Commerce'],
    companies: ['Nioro AgroExport', 'Saloum Sud Producteurs'],
    rating: 4.5, reviews: 17, years: 14, compatibility: 76,
  ),
  Mentor(
    initials: 'MDp',
    name: 'Moustapha Diop',
    title: 'Fondateur · Diourbel Négoce',
    city: 'Diourbel',
    sectors: ['Commerce', 'Services', 'Transport'],
    companies: ['Diourbel Négoce', 'Baol Transit'],
    rating: 4.5, reviews: 19, years: 16, compatibility: 75,
  ),

  // ─── Investisseurs régionaux ───
  Mentor(
    initials: 'AMb',
    name: 'Aliou Mbaye',
    title: 'Fondateur · Mbour Impact Invest',
    city: 'Mbour',
    sectors: ['Tourisme', 'Agriculture', 'Finance'],
    companies: ['Mbour Impact Invest', 'Petite Côte Ventures'],
    rating: 4.7, reviews: 28, years: 13, compatibility: 82,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'IBl',
    name: 'Ibrahima Baldé',
    title: 'Fondateur · Sud Sénégal Capital',
    city: 'Vélingara',
    sectors: ['Agriculture', 'Commerce', 'Finance'],
    companies: ['Sud Sénégal Capital', 'Kolda Angel Fund'],
    rating: 4.6, reviews: 20, years: 12, compatibility: 79,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'FDn',
    name: 'Fatou Dione',
    title: 'Directrice · Kaolack Invest',
    city: 'Kaolack',
    sectors: ['Finance', 'Agriculture', 'Agro-industrie'],
    companies: ['Kaolack Invest', 'Bassin Arachidier Fund'],
    rating: 4.7, reviews: 25, years: 15, compatibility: 81,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'MSa',
    name: 'Mamadou Sarr',
    title: 'Partner · Louga Ventures',
    city: 'Louga',
    sectors: ['Agriculture', 'Commerce', 'Finance'],
    companies: ['Louga Ventures', 'Nord Sénégal Angel Network'],
    rating: 4.6, reviews: 18, years: 11, compatibility: 78,
    role: 'Investisseur',
  ),

  // ═══════════════════════════════════════════════
  //  INVESTISSEURS SÉNÉGALAIS
  // ═══════════════════════════════════════════════

  // ─── Tech / FinTech / Digital ───
  Mentor(
    initials: 'ABC',
    name: 'Alioune Badara Cissé',
    title: 'Fondateur · Dakar Angel Network',
    city: 'Dakar',
    sectors: ['Tech & Digital', 'FinTech', 'E-commerce'],
    companies: [
      'Dakar Angel Network',
      'Téranga Ventures Fund',
      'Africa Tech Holdings',
    ],
    rating: 4.9, reviews: 64, years: 16, compatibility: 95,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'NS',
    name: 'Ndèye Seck',
    title: 'Managing Partner · Impact Africa SN',
    city: 'Dakar',
    sectors: ['FinTech', 'Éducation / EdTech', 'Santé'],
    companies: [
      'Impact Africa SN',
      'Fonds Entrepreneuriat Féminin',
      'Réseau Business Angels Africa',
    ],
    rating: 4.8, reviews: 53, years: 14, compatibility: 92,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'HB',
    name: 'Hamidou Bah',
    title: 'Partner · Jokkolabs Capital',
    city: 'Dakar',
    sectors: ['Tech & Digital', 'Mobile Money', 'E-commerce'],
    companies: [
      'Jokkolabs Capital',
      'West Africa Tech Fund',
      'StartHub Dakar',
    ],
    rating: 4.7, reviews: 41, years: 12, compatibility: 89,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'CMT',
    name: 'Cheikh M. Tall',
    title: 'CEO · Téranga Venture Capital',
    city: 'Dakar',
    sectors: ['Tech & Digital', 'FinTech', 'Télécoms'],
    companies: [
      'Téranga Venture Capital',
      'Tall Family Office',
      'InnoSeed SN',
    ],
    rating: 4.8, reviews: 48, years: 19, compatibility: 91,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'RN',
    name: 'Rokhaya Ndoye',
    title: 'Associée · Cauris Capital',
    city: 'Dakar',
    sectors: ['FinTech', 'Mobile Money', 'Finance'],
    companies: [
      'Cauris Capital Sénégal',
      'Fonds Francophone d\'Investissement',
      'Réseau Investisseurs UEMOA',
    ],
    rating: 4.9, reviews: 57, years: 21, compatibility: 94,
    cis: true, role: 'Investisseur',
  ),

  // ─── Agro-industrie / Agriculture ───
  Mentor(
    initials: 'TD',
    name: 'Thierno Diallo',
    title: 'PDG · Fonds Agricole du Sénégal',
    city: 'Kaolack',
    sectors: ['Agriculture', 'Agro-industrie', 'Renouvelable'],
    companies: [
      'Fonds Agricole du Sénégal',
      'Agri-Finance Sahel',
      'Investissements Ruraux SN',
    ],
    rating: 4.7, reviews: 39, years: 18, compatibility: 86,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'FMB',
    name: 'Fatou Mbodj',
    title: 'Fondatrice · AgroInvest Africa',
    city: 'Thiès',
    sectors: ['Agro-industrie', 'Food', 'Agriculture'],
    companies: [
      'AgroInvest Africa',
      'Green Sahel Partners',
      'Coopérative d\'Investissement Féminin',
    ],
    rating: 4.7, reviews: 35, years: 13, compatibility: 84,
    role: 'Investisseur',
  ),

  // ─── Immobilier / BTP ───
  Mentor(
    initials: 'MoD',
    name: 'Mouhamed Diagne',
    title: 'Fondateur · Dakar Capital Immo',
    city: 'Dakar',
    sectors: ['Immobilier', 'BTP', 'Services'],
    companies: [
      'Dakar Capital Immo',
      'Fonds Immobilier UEMOA',
      'Diagne & Partners',
    ],
    rating: 4.6, reviews: 30, years: 22, compatibility: 82,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'KAN',
    name: 'Khadidjatou Ndiaye',
    title: 'Directrice · NdFund Immobilier',
    city: 'Dakar',
    sectors: ['Immobilier', 'Finance', 'Services'],
    companies: [
      'NdFund Immobilier',
      'Savane Property Group',
      'Africa Real Estate Partners',
    ],
    rating: 4.7, reviews: 26, years: 17, compatibility: 80,
    role: 'Investisseur',
  ),

  // ─── Énergie / Renouvelable ───
  Mentor(
    initials: 'AS3',
    name: 'Ababacar Sèye',
    title: 'CEO · Africa Green Fund',
    city: 'Dakar',
    sectors: ['Énergie', 'Renouvelable', 'Tech & Digital'],
    companies: [
      'Africa Green Fund',
      'Sèye Solar Investments',
      'Fonds Énergie Propre CEDEAO',
    ],
    rating: 4.8, reviews: 44, years: 15, compatibility: 88,
    role: 'Investisseur',
  ),
  Mentor(
    initials: 'MB2',
    name: 'Mariama Ba',
    title: 'Partner · CleanTech Invest SN',
    city: 'Dakar',
    sectors: ['Renouvelable', 'Énergie', 'Agriculture'],
    companies: [
      'CleanTech Invest SN',
      'Fonds Climat Africa',
      'Ba Green Partners',
    ],
    rating: 4.7, reviews: 32, years: 11, compatibility: 85,
    role: 'Investisseur',
  ),

  // ─── Santé / E-santé ───
  Mentor(
    initials: 'DrFM',
    name: 'Dr. Fatou Mbaye',
    title: 'Fondatrice · HealthCare Invest SN',
    city: 'Dakar',
    sectors: ['Santé', 'E-santé', 'Services'],
    companies: [
      'HealthCare Invest SN',
      'Fonds Santé Afrique Occidentale',
      'Réseau Médical d\'Investissement',
    ],
    rating: 4.9, reviews: 50, years: 20, compatibility: 91,
    cis: true, role: 'Investisseur',
  ),

  // ─── Tourisme / Hôtellerie ───
  Mentor(
    initials: 'IBa',
    name: 'Ibrahima Ba',
    title: 'Partner · Téranga Hospitality Fund',
    city: 'Saly',
    sectors: ['Tourisme', 'Hôtellerie', 'Lifestyle'],
    companies: [
      'Téranga Hospitality Fund',
      'Côte Ouest Investments',
      'Saly Resort Capital',
    ],
    rating: 4.7, reviews: 36, years: 16, compatibility: 83,
    role: 'Investisseur',
  ),

  // ─── Mode / Cosmétique / Artisanat ───
  Mentor(
    initials: 'SD2',
    name: 'Sokhna Diallo',
    title: 'Angel Investor · African Beauty Fund',
    city: 'Dakar',
    sectors: ['Cosmétique', 'Beauté', 'Mode & Textile', 'Artisanat'],
    companies: [
      'African Beauty Fund',
      'Diallo Angel Investments',
      'Fashion Africa Capital',
    ],
    rating: 4.8, reviews: 42, years: 10, compatibility: 87,
    role: 'Investisseur',
  ),

  // ─── Transport / Logistique ───
  Mentor(
    initials: 'MaC',
    name: 'Mamadou Camara',
    title: 'Fondateur · Mobility Africa Fund',
    city: 'Dakar',
    sectors: ['Transport', 'Logistique', 'E-commerce'],
    companies: [
      'Mobility Africa Fund',
      'Camara Logistique Capital',
      'Réseau Transport Invest UEMOA',
    ],
    rating: 4.6, reviews: 28, years: 14, compatibility: 81,
    role: 'Investisseur',
  ),

  // ─── Médias / Éducation ───
  Mentor(
    initials: 'AdN',
    name: 'Adja Ndiaye',
    title: 'Directrice · Médias Invest Africa',
    city: 'Dakar',
    sectors: ['Médias', 'Éducation / EdTech', 'Tech & Digital'],
    companies: [
      'Médias Invest Africa',
      'Content Capital SN',
      'Fonds Créatif Africa',
    ],
    rating: 4.7, reviews: 33, years: 13, compatibility: 84,
    role: 'Investisseur',
  ),

  // ─── Multi-secteurs / Fonds généralistes ───
  Mentor(
    initials: 'PMN',
    name: 'Pape Malick Ndiaye',
    title: 'Fondateur · Jeune Afrique Capital',
    city: 'Dakar',
    sectors: ['Finance', 'Tech & Digital', 'Agro-industrie', 'Énergie'],
    companies: [
      'Jeune Afrique Capital',
      'Fonds Émergence Sénégal',
      'Ndiaye Family Office',
    ],
    rating: 4.8, reviews: 61, years: 24, compatibility: 93,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'SM2',
    name: 'Serigne Mbaye',
    title: 'Partner · AfricaInvest Sénégal',
    city: 'Dakar',
    sectors: ['Finance', 'FinTech', 'Immobilier', 'Agro-industrie'],
    companies: [
      'AfricaInvest Sénégal',
      'Mbaye Partners Capital',
      'FONSIS (administrateur)',
    ],
    rating: 4.9, reviews: 72, years: 28, compatibility: 96,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'AW',
    name: 'Aminata Wane',
    title: 'CEO · Sahel Impact Investors',
    city: 'Dakar',
    sectors: ['Finance', 'Santé', 'Agriculture', 'Renouvelable'],
    companies: [
      'Sahel Impact Investors',
      'Wane Capital Partners',
      'Réseau Femmes Investisseuses Africa',
    ],
    rating: 4.8, reviews: 49, years: 17, compatibility: 90,
    cis: true, role: 'Investisseur',
  ),
  Mentor(
    initials: 'OTh',
    name: 'Oumar Thiam',
    title: 'Fondateur · Gaïndé Capital',
    city: 'Dakar',
    sectors: ['Tech & Digital', 'Transport', 'BTP', 'Tourisme'],
    companies: [
      'Gaïndé Capital',
      'Thiam Holding Investissements',
      'Fonds Infrastructures UEMOA',
    ],
    rating: 4.7, reviews: 45, years: 20, compatibility: 88,
    cis: true, role: 'Investisseur',
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

class Quote {
  final String text;
  final String author;
  final String role;
  final String emoji;

  const Quote({
    required this.text,
    required this.author,
    required this.role,
    this.emoji = '',
  });
}

/// Citations qui s'affichent dans le carrousel de l'écran d'accueil et du splash.
/// Mélange volontaire : proverbes wolof (libres de droits, héritage culturel
/// sénégalais) + citations courtes d'entrepreneurs panafricains.
const quotes = <Quote>[
  Quote(
    text: 'Nit, nit ay garabam.\nL\'Homme est le remède de l\'Homme.',
    author: 'Proverbe wolof',
    role: 'Héritage sénégalais',
    emoji: '🇸🇳',
  ),
  Quote(
    text: 'Quand tu abandonnes, tu as échoué.',
    author: 'Aliko Dangote',
    role: 'Entrepreneur · Nigéria',
    emoji: '🦁',
  ),
  Quote(
    text: 'L\'Afrique appartient à ceux qui osent.',
    author: 'Patrice Motsepe',
    role: 'Entrepreneur · Afrique du Sud',
    emoji: '🌍',
  ),
  Quote(
    text: 'L\'entrepreneuriat est la voie de la dignité.',
    author: 'Tony Elumelu',
    role: 'Fondateur · TEF',
    emoji: '💡',
  ),
  Quote(
    text: 'Nos jeunes, c\'est l\'Afrique qui se lève.',
    author: 'Magatte Wade',
    role: 'Entrepreneure · Sénégal',
    emoji: '🌟',
  ),
  Quote(
    text: 'Bokk te def — ensemble, on agit.',
    author: 'Sagesse wolof',
    role: 'Esprit Diapaler',
    emoji: '🤝',
  ),
  Quote(
    text: 'Bâtissons d\'abord nos hommes.',
    author: 'Cheikh Anta Diop',
    role: 'Penseur · Sénégal',
    emoji: '📚',
  ),
  Quote(
    text: 'Sénégal Émergent passe par sa jeunesse.',
    author: 'Vision 2027',
    role: 'République du Sénégal',
    emoji: '🇸🇳',
  ),
  Quote(
    text: 'Ku liggéey, du dee xiif.\nQui travaille ne meurt pas de faim.',
    author: 'Proverbe wolof',
    role: 'Sagesse populaire',
    emoji: '🌾',
  ),
  Quote(
    text: "L'innovation est la clé du futur africain.",
    author: 'Mo Ibrahim',
    role: 'Entrepreneur · Soudan',
    emoji: '💡',
  ),
  Quote(
    text: 'Téranga mooy ñoom — la solidarité, c\'est nous.',
    author: 'Sagesse wolof',
    role: 'Esprit Diapaler',
    emoji: '🤝',
  ),
  Quote(
    text: "Construis pour l'Afrique, pas seulement pour toi.",
    author: 'Tony Elumelu',
    role: 'Fondateur · TEF',
    emoji: '🏗️',
  ),
  Quote(
    text: 'Investis dans la jeunesse africaine.',
    author: 'Aliko Dangote',
    role: 'Entrepreneur · Nigéria',
    emoji: '🦁',
  ),
  Quote(
    text: "L'Afrique se construit avec ses fils.",
    author: 'Proverbe panafricain',
    role: 'Sagesse continentale',
    emoji: '🌍',
  ),
  Quote(
    text: 'Yax dem, jot dem — la force vient de l\'union.',
    author: 'Proverbe wolof',
    role: 'Sagesse sénégalaise',
    emoji: '✊',
  ),
  Quote(
    text: "Mama Africa is rising — l'Afrique se lève.",
    author: 'Magatte Wade',
    role: 'Entrepreneure · Sénégal',
    emoji: '🌟',
  ),
  Quote(
    text: 'Sunu réew, sunu yitte — notre pays, notre fierté.',
    author: 'Sagesse wolof',
    role: 'Héritage sénégalais',
    emoji: '🇸🇳',
  ),
  Quote(
    text: 'Le travail acharné paye toujours.',
    author: 'Patrice Motsepe',
    role: 'Entrepreneur · Afrique du Sud',
    emoji: '⚡',
  ),
  Quote(
    text: 'Le rêve africain ne meurt jamais.',
    author: 'Strive Masiyiwa',
    role: 'Entrepreneur · Zimbabwe',
    emoji: '🌅',
  ),
];

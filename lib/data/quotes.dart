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
];

import '../data/interactions.dart';

/// Avis fictifs pré-remplis pour les comptes statiques (mentors & investisseurs).
/// Clé = `Mentor.name` exact.
final Map<String, List<Review>> staticReviewsByMentor = {
  'Anta Diama Kama': [
    Review(
      id: 'static-ak-1',
      fromUid: '',
      fromName: 'Aminata Sow',
      text:
          'Anta m\'a aidée à structurer mon offre traiteur de zéro. Ses conseils sur la gestion des coûts en restauration m\'ont permis d\'atteindre la rentabilité en 8 mois. Une mentor exceptionnelle, disponible et bienveillante.',
      createdAt: DateTime(2026, 4, 12),
    ),
    Review(
      id: 'static-ak-2',
      fromUid: '',
      fromName: 'Moussa Diallo',
      text:
          'J\'ai lancé mon food truck grâce à ses conseils. Elle m\'a orienté sur les autorisations sanitaires et la négociation avec les fournisseurs. Je recommande à tout entrepreneur du secteur Food.',
      createdAt: DateTime(2026, 3, 5),
    ),
    Review(
      id: 'static-ak-3',
      fromUid: '',
      fromName: 'Fatoumata Diop',
      text:
          'Une vraie inspiration. Anta connaît les réalités du marché sénégalais dans les moindres détails. Après une session avec elle, j\'ai revu toute ma stratégie de pricing et mes marges ont augmenté de 30 %.',
      createdAt: DateTime(2026, 2, 18),
    ),
    Review(
      id: 'static-ak-4',
      fromUid: '',
      fromName: 'Ibrahima Ndiaye',
      text:
          'Très professionnelle et généreuse de son temps. Elle m\'a mis en relation avec des distributeurs clés que je n\'aurais jamais pu approcher seul. Son réseau dans le secteur Food est impressionnant.',
      createdAt: DateTime(2025, 12, 29),
    ),
    Review(
      id: 'static-ak-5',
      fromUid: '',
      fromName: 'Mame Diarra Fall',
      text:
          'Session très enrichissante. Elle ne donne pas de réponses toutes faites mais t\'amène à trouver les tiennes. Méthode pédagogique vraiment efficace.',
      createdAt: DateTime(2025, 11, 14),
    ),
  ],
  'Yérim Habib Sow': [
    Review(
      id: 'static-ys-1',
      fromUid: '',
      fromName: 'Cheikh Bamba Ndiaye',
      text:
          'M. Sow m\'a reçu avec une humilité remarquable pour quelqu\'un de son envergure. Il m\'a aidé à revoir mon modèle de revenus et m\'a donné des pistes concrètes pour lever des fonds. Une rencontre qui a changé ma trajectoire.',
      createdAt: DateTime(2026, 5, 3),
    ),
    Review(
      id: 'static-ys-2',
      fromUid: '',
      fromName: 'Ndéye Fatou Sall',
      text:
          'Sa vision stratégique est hors du commun. Il m\'a aidée à identifier des opportunités dans l\'immobilier que je n\'avais pas encore envisagées. Très reconnaissante pour son accompagnement.',
      createdAt: DateTime(2026, 3, 22),
    ),
    Review(
      id: 'static-ys-3',
      fromUid: '',
      fromName: 'Oumar Ly',
      text:
          'Rencontre exceptionnelle. M. Sow pense à grande échelle et m\'a challengé sur mes ambitions — il m\'a dit que je pensais trop petit ! Depuis, j\'ai revu mon plan à la hausse et les résultats suivent.',
      createdAt: DateTime(2026, 1, 9),
    ),
    Review(
      id: 'static-ys-4',
      fromUid: '',
      fromName: 'Rokhaya Diène',
      text:
          'Ce qui m\'a le plus frappée, c\'est sa capacité à simplifier des sujets complexes. Il maîtrise les télécoms, l\'immobilier et la finance et sait relier ces trois domaines avec une clarté déconcertante.',
      createdAt: DateTime(2025, 11, 7),
    ),
  ],
  'Mansour Ndao': [
    Review(
      id: 'static-mn-1',
      fromUid: '',
      fromName: 'Seydou Camara',
      text:
          'M. Ndao m\'a aidé à structurer mon projet automobile. Ses contacts chez les importateurs m\'ont ouvert des portes que je cherchais depuis deux ans. Un réseau incroyable.',
      createdAt: DateTime(2026, 4, 25),
    ),
    Review(
      id: 'static-mn-2',
      fromUid: '',
      fromName: 'Astou Guèye',
      text:
          'Très direct et très concret. Il ne perd pas de temps en théorie et va droit au but. Ses conseils sur la diversification m\'ont permis de lancer une deuxième activité complémentaire.',
      createdAt: DateTime(2026, 2, 14),
    ),
    Review(
      id: 'static-mn-3',
      fromUid: '',
      fromName: 'Pape Sarr',
      text:
          'Un mentor exigeant mais juste. Il m\'a aidé à revoir mon business plan en profondeur et à identifier les failles avant de me lancer. Je lui dois d\'éviter un investissement risqué.',
      createdAt: DateTime(2025, 12, 3),
    ),
  ],
  'Babacar Ngom': [
    Review(
      id: 'static-bn-1',
      fromUid: '',
      fromName: 'Aliou Badji',
      text:
          'M. Ngom est une légende de l\'agro-industrie sénégalaise et il partage ses connaissances sans réserve. Il m\'a accompagné dans la mise en place de ma filière avicole de bout en bout. Résultats au-delà de mes espérances.',
      createdAt: DateTime(2026, 5, 10),
    ),
    Review(
      id: 'static-bn-2',
      fromUid: '',
      fromName: 'Bintou Kouyaté',
      text:
          'Sa connaissance des circuits de distribution alimentaire au Sénégal est unique. Il m\'a mis en contact avec des acheteurs institutionnels (hôtels, cantines) que je n\'aurais jamais pu approcher seule.',
      createdAt: DateTime(2026, 4, 1),
    ),
    Review(
      id: 'static-bn-3',
      fromUid: '',
      fromName: 'Mamadou Faye',
      text:
          'Accessible et profondément engagé pour le développement des jeunes agriculteurs. Ses conseils sur la gestion des risques climatiques et la diversification des cultures ont été précieux.',
      createdAt: DateTime(2026, 2, 28),
    ),
    Review(
      id: 'static-bn-4',
      fromUid: '',
      fromName: 'Khady Cissé',
      text:
          'Une session avec M. Ngom vaut dix livres sur l\'agro-industrie. Il parle avec des exemples concrets tirés de ses 30 ans d\'expérience. On repart avec des actions claires à mettre en œuvre.',
      createdAt: DateTime(2026, 1, 16),
    ),
    Review(
      id: 'static-bn-5',
      fromUid: '',
      fromName: 'Lamine Touré',
      text:
          'Grâce à ses conseils, j\'ai obtenu une certification qualité pour ma production de volaille. Il connaît toutes les démarches administratives et ne garde rien pour lui. Un vrai don pour les entrepreneurs.',
      createdAt: DateTime(2025, 11, 22),
    ),
  ],
  'Mossane Diop': [
    Review(
      id: 'static-md-1',
      fromUid: '',
      fromName: 'Yacine Badji',
      text:
          'Mossane m\'a aidée à reformuler mes produits pour mieux correspondre aux attentes des distributeurs. Elle connaît parfaitement les tendances cosmétiques en Afrique de l\'Ouest.',
      createdAt: DateTime(2026, 4, 18),
    ),
    Review(
      id: 'static-md-2',
      fromUid: '',
      fromName: 'Adja Traoré',
      text:
          'Passionnée et généreuse. Elle m\'a accompagnée dans ma stratégie de marque et m\'a aidée à me positionner clairement sur le marché de la cosmétique naturelle. Très inspirante !',
      createdAt: DateTime(2026, 3, 9),
    ),
    Review(
      id: 'static-md-3',
      fromUid: '',
      fromName: 'Mariama Baldé',
      text:
          'Ses conseils sur le packaging et la communication ont transformé ma marque. Avant de la rencontrer, mes produits peinaient à se vendre. Aujourd\'hui, j\'ai un réseau de 15 revendeurs.',
      createdAt: DateTime(2026, 1, 24),
    ),
  ],
  'Aminata Niane': [
    Review(
      id: 'static-an-1',
      fromUid: '',
      fromName: 'Djibril Sène',
      text:
          'Aminata m\'a guidé dans le lancement de ma solution SaaS pour les PME sénégalaises. Sa connaissance du marché Tech local est inestimable. Elle sait exactement comment adapter les modèles étrangers aux réalités africaines.',
      createdAt: DateTime(2026, 5, 6),
    ),
    Review(
      id: 'static-an-2',
      fromUid: '',
      fromName: 'Coumba Diallo',
      text:
          'Une mentor techniquement très solide. Elle m\'a aidée à cadrer mon MVP en 3 séances. Sa vision du e-commerce en Afrique de l\'Ouest m\'a permis d\'éviter des erreurs classiques de débutant.',
      createdAt: DateTime(2026, 4, 2),
    ),
    Review(
      id: 'static-an-3',
      fromUid: '',
      fromName: 'Modou Gaye',
      text:
          'Grâce à Aminata, j\'ai pu présenter mon projet à des investisseurs de son réseau. Elle prépare vraiment ses mentorés à passer à l\'étape suivante. Très reconnaissant.',
      createdAt: DateTime(2026, 2, 11),
    ),
    Review(
      id: 'static-an-4',
      fromUid: '',
      fromName: 'Ndéye Diallo',
      text:
          'Elle m\'a appris à lire des indicateurs de performance que je ne comprenais pas. Très pédagogique et toujours disponible entre les sessions pour répondre aux questions urgentes.',
      createdAt: DateTime(2025, 12, 5),
    ),
  ],
  'Khadim Bâ': [
    Review(
      id: 'static-kb-1',
      fromUid: '',
      fromName: 'Pape Malick Diagne',
      text:
          'M. Bâ m\'a aidé à décrocher mon premier marché public dans le BTP. Sa maîtrise des procédures d\'appel d\'offres et des contrats logistiques m\'a fait gagner des mois de démarches.',
      createdAt: DateTime(2026, 3, 30),
    ),
    Review(
      id: 'static-kb-2',
      fromUid: '',
      fromName: 'Aminata Ndiaye',
      text:
          'Très pragmatique. Il ne perd pas de temps et va droit à l\'essentiel. Ses conseils sur la gestion de flotte ont réduit mes coûts opérationnels de 20 %.',
      createdAt: DateTime(2026, 1, 19),
    ),
    Review(
      id: 'static-kb-3',
      fromUid: '',
      fromName: 'Samba Keïta',
      text:
          'Excellente expérience. M. Bâ a 18 ans d\'expérience dans la logistique et ça se ressent dans chaque conseil. Un mentor exigeant qui tire le meilleur de toi.',
      createdAt: DateTime(2025, 11, 8),
    ),
  ],
  'Aïssa Dione': [
    Review(
      id: 'static-ad-1',
      fromUid: '',
      fromName: 'Rokhaya Sow',
      text:
          'Aïssa Dione est une pionnière et elle transmet sa passion avec une générosité rare. Elle m\'a aidée à valoriser mes créations artisanales auprès d\'acheteurs internationaux. Une rencontre qui a changé ma vision.',
      createdAt: DateTime(2026, 4, 28),
    ),
    Review(
      id: 'static-ad-2',
      fromUid: '',
      fromName: 'Binetou Dieye',
      text:
          'Ses conseils sur la standardisation tout en préservant l\'authenticité du savoir-faire artisanal sont exactement ce dont j\'avais besoin. Elle comprend l\'équilibre entre tradition et marché.',
      createdAt: DateTime(2026, 3, 15),
    ),
    Review(
      id: 'static-ad-3',
      fromUid: '',
      fromName: 'Daouda Gueye',
      text:
          'Après notre session, j\'ai revu toute ma collection pour la rendre exportable. Elle m\'a montré comment adapter les finitions et l\'emballage aux exigences du marché européen sans trahir mon identité.',
      createdAt: DateTime(2025, 12, 20),
    ),
    Review(
      id: 'static-ad-4',
      fromUid: '',
      fromName: 'Fatou Mbaye',
      text:
          'Une légende accessible. Elle prend le temps de comprendre ton projet avant de donner des conseils. J\'ai beaucoup appris sur le tissage industriel et les certifications nécessaires à l\'export.',
      createdAt: DateTime(2025, 10, 4),
    ),
  ],
  'Pape Diouf': [
    Review(
      id: 'static-pd-1',
      fromUid: '',
      fromName: 'Ibrahima Ka',
      text:
          'Pape m\'a aidé à comprendre les défis réglementaires du mobile money en Afrique de l\'Ouest. Sa vision des FinTech est claire et stimulante. Il pousse à penser à l\'échelle du continent.',
      createdAt: DateTime(2026, 5, 14),
    ),
    Review(
      id: 'static-pd-2',
      fromUid: '',
      fromName: 'Marème Ba',
      text:
          'Incroyablement inspirant. Il a construit quelque chose de révolutionnaire avec Wave et partage ses apprentissages sans retenue. Ses conseils sur l\'expérience utilisateur ont transformé mon app.',
      createdAt: DateTime(2026, 4, 7),
    ),
    Review(
      id: 'static-pd-3',
      fromUid: '',
      fromName: 'Abdoulaye Diop',
      text:
          'Sa maîtrise des partenariats bancaires et des licences d\'opérateur m\'a fait gagner énormément de temps. Un mentor rare dans le secteur FinTech sénégalais.',
      createdAt: DateTime(2026, 2, 22),
    ),
    Review(
      id: 'static-pd-4',
      fromUid: '',
      fromName: 'Seynabou Sarr',
      text:
          'Très ouvert et franc. Il m\'a dit clairement ce qui ne marchait pas dans mon modèle et m\'a proposé une alternative concrète. Honnêteté et expertise au service de l\'entrepreneur.',
      createdAt: DateTime(2025, 12, 11),
    ),
  ],
  'Magatte Wade': [
    Review(
      id: 'static-mw-1',
      fromUid: '',
      fromName: 'Kadiatou Sow',
      text:
          'Magatte m\'a aidée à positionner ma marque cosmétique à l\'international. Sa vision africaine et sa maîtrise des marchés américain et européen sont une combinaison unique.',
      createdAt: DateTime(2026, 4, 20),
    ),
    Review(
      id: 'static-mw-2',
      fromUid: '',
      fromName: 'Cheikh Gassama',
      text:
          'Une mentor qui inspire par sa trajectoire autant que par ses conseils. Elle m\'a donné le courage de viser plus haut et les outils pour y arriver.',
      createdAt: DateTime(2026, 2, 5),
    ),
    Review(
      id: 'static-mw-3',
      fromUid: '',
      fromName: 'Aminata Koné',
      text:
          'Ses conseils sur la certification de produits naturels pour le marché américain valent de l\'or. Elle connaît les pièges et les raccourcis — une vraie accélératrice.',
      createdAt: DateTime(2025, 11, 28),
    ),
  ],
  'Fatou Fall': [
    Review(
      id: 'static-ff-1',
      fromUid: '',
      fromName: 'Boubacar Diallo',
      text:
          'Fatou m\'a accompagné dans le lancement de ma solution de téléconsultation médicale. Sa connaissance des acteurs de la santé numérique au Sénégal est précieuse. Elle m\'a ouvert des portes chez des hôpitaux partenaires.',
      createdAt: DateTime(2026, 5, 1),
    ),
    Review(
      id: 'static-ff-2',
      fromUid: '',
      fromName: 'Ndéye Binta Diop',
      text:
          'Son expertise à la croisée de la médecine et de la tech est rare. Elle comprend les enjeux réglementaires de la santé numérique mieux que quiconque. Très utile pour structurer mon dossier d\'autorisation.',
      createdAt: DateTime(2026, 3, 18),
    ),
    Review(
      id: 'static-ff-3',
      fromUid: '',
      fromName: 'Malick Seck',
      text:
          'Disponible et très engagée. Elle m\'a aidé à valider mon modèle économique avec des données réelles du secteur. Une mentor incontournable pour la santé digitale au Sénégal.',
      createdAt: DateTime(2026, 1, 7),
    ),
  ],
  'Khadidiatou Sall': [
    Review(
      id: 'static-ks-1',
      fromUid: '',
      fromName: 'Ousmane Badji',
      text:
          'Khadidiatou m\'a aidé à construire mon offre de formation numérique pour les lycées. Elle comprend les contraintes des établissements publics et sait comment adapter une solution EdTech au contexte sénégalais.',
      createdAt: DateTime(2026, 4, 15),
    ),
    Review(
      id: 'static-ks-2',
      fromUid: '',
      fromName: 'Sophie Faye',
      text:
          'Une mentor passionnée par l\'éducation. Ses retours sur mon application d\'apprentissage m\'ont permis de l\'améliorer considérablement. Elle pense toujours d\'abord à l\'apprenant.',
      createdAt: DateTime(2026, 3, 3),
    ),
    Review(
      id: 'static-ks-3',
      fromUid: '',
      fromName: 'Mamadou Koné',
      text:
          'Grâce à ses conseils, j\'ai pu postuler à une subvention du Ministère de l\'Éducation. Elle connaît les processus institutionnels et m\'a aidé à formuler mon dossier.',
      createdAt: DateTime(2026, 1, 21),
    ),
    Review(
      id: 'static-ks-4',
      fromUid: '',
      fromName: 'Coumba Sow',
      text:
          'Très méthodique et bienveillante. Elle pose les bonnes questions et t\'aide à structurer ta pensée. Après nos sessions, j\'ai une roadmap claire sur 18 mois.',
      createdAt: DateTime(2025, 12, 14),
    ),
  ],
  'Mariama Faye': [
    Review(
      id: 'static-mf-1',
      fromUid: '',
      fromName: 'Babacar Sall',
      text:
          'Mariama m\'a aidé à sécuriser mon premier financement bancaire. Sa connaissance des critères d\'éligibilité et sa capacité à préparer un dossier solide sont sans égal.',
      createdAt: DateTime(2026, 5, 8),
    ),
    Review(
      id: 'static-mf-2',
      fromUid: '',
      fromName: 'Thioro Diop',
      text:
          'Une experte en stratégie financière qui sait vulgariser. Elle m\'a aidée à comprendre mes états financiers et à les présenter de manière convaincante aux investisseurs.',
      createdAt: DateTime(2026, 3, 25),
    ),
    Review(
      id: 'static-mf-3',
      fromUid: '',
      fromName: 'El Hadji Niang',
      text:
          'Très professionnelle et structurée. Elle m\'a accompagné dans la mise en place d\'un système de comptabilité adapté à ma TPE. Depuis, je vois clairement où va mon argent.',
      createdAt: DateTime(2026, 1, 30),
    ),
  ],
  'Aïssatou Ba': [
    Review(
      id: 'static-ab-1',
      fromUid: '',
      fromName: 'Pape Dembélé',
      text:
          'Aïssatou m\'a aidé à structurer mon offre d\'écotourisme à Casamance. Elle connaît parfaitement les attentes des tour-opérateurs internationaux et m\'a aidé à adapter mon offre.',
      createdAt: DateTime(2026, 4, 22),
    ),
    Review(
      id: 'static-ab-2',
      fromUid: '',
      fromName: 'Ndiogou Sène',
      text:
          'Sa connaissance du secteur hôtelier est impressionnante. Ses conseils sur la gestion des saisons basses et la fidélisation des clients m\'ont permis de doubler mon taux d\'occupation.',
      createdAt: DateTime(2026, 2, 9),
    ),
    Review(
      id: 'static-ab-3',
      fromUid: '',
      fromName: 'Aminata Camara',
      text:
          'Elle m\'a mis en relation avec des plateformes de réservation en ligne que je ne connaissais pas. En quelques mois, mes réservations ont explosé. Une mentor avec un réseau exceptionnel.',
      createdAt: DateTime(2025, 12, 17),
    ),
  ],
  'Awa Cissé': [
    Review(
      id: 'static-ac-1',
      fromUid: '',
      fromName: 'Khady Niang',
      text:
          'Awa m\'a guidée dans la formulation de mes produits naturels et dans la mise en conformité avec les normes CEDEAO. Ses connaissances en chimie cosmétique et en marketing sont une combinaison rare.',
      createdAt: DateTime(2026, 5, 11),
    ),
    Review(
      id: 'static-ac-2',
      fromUid: '',
      fromName: 'Fatou Traoré',
      text:
          'Bienveillante, directe et très expérimentée. Elle m\'a aidée à construire une identité visuelle cohérente et à choisir mes canaux de distribution. Je l\'avais contactée pour une session, elle est devenue ma mentor de référence.',
      createdAt: DateTime(2026, 3, 28),
    ),
    Review(
      id: 'static-ac-3',
      fromUid: '',
      fromName: 'Moussa Diop',
      text:
          'Elle m\'a expliqué comment négocier avec les grossistes et les épiceries de quartier. Ses conseils terrain ont un impact immédiat sur les ventes.',
      createdAt: DateTime(2026, 2, 15),
    ),
    Review(
      id: 'static-ac-4',
      fromUid: '',
      fromName: 'Ndeye Rama Sarr',
      text:
          'Sa franchise m\'a choquée au début puis m\'a aidée à progresser rapidement. Elle dit exactement ce qui ne va pas et propose toujours une solution concrète. On ressort de chaque session plus solide.',
      createdAt: DateTime(2025, 12, 8),
    ),
  ],
  'Ousmane Diagne': [
    Review(
      id: 'static-od-1',
      fromUid: '',
      fromName: 'Alioune Faye',
      text:
          'M. Diagne m\'a aidé à comprendre les conditions d\'accès au crédit bancaire et à préparer un dossier solide. Son expertise en microfinance est précieuse pour les petites structures.',
      createdAt: DateTime(2026, 4, 30),
    ),
    Review(
      id: 'static-od-2',
      fromUid: '',
      fromName: 'Bineta Gueye',
      text:
          'Très pédagogique sur les sujets financiers complexes. Il a rendu accessibles les notions de taux, de garanties et de remboursement. Mon rapport aux finances a complètement changé.',
      createdAt: DateTime(2026, 3, 11),
    ),
    Review(
      id: 'static-od-3',
      fromUid: '',
      fromName: 'Idrissa Mbaye',
      text:
          'Grâce à ses conseils, j\'ai pu accéder à un produit de crédit adapté à mon cycle d\'activité saisonnière. Il connaît parfaitement les offres bancaires disponibles sur le marché.',
      createdAt: DateTime(2026, 1, 26),
    ),
  ],
  // ─── Investisseurs ───
  'Alioune Badara Cissé': [
    Review(
      id: 'static-abc-1',
      fromUid: '',
      fromName: 'Lamine Badji',
      text:
          'Alioune est l\'un des rares investisseurs qui prend le temps de comprendre ton projet avant d\'en parler. Il m\'a aidé à reformuler ma proposition de valeur pour la rendre investissable. Deal signé 3 mois plus tard !',
      createdAt: DateTime(2026, 5, 16),
    ),
    Review(
      id: 'static-abc-2',
      fromUid: '',
      fromName: 'Rokhaya Fall',
      text:
          'Son réseau au sein du Dakar Angel Network est exceptionnel. Une seule session avec lui m\'a ouvert des portes inimaginables. Un investisseur qui s\'implique vraiment dans la réussite des startups.',
      createdAt: DateTime(2026, 3, 20),
    ),
    Review(
      id: 'static-abc-3',
      fromUid: '',
      fromName: 'Ndama Diouf',
      text:
          'Il m\'a accompagnée pendant 6 mois de pitch training. Sa connaissance des attentes des fonds d\'investissement africains est unique. J\'ai levé ma première tranche grâce à ses préparations.',
      createdAt: DateTime(2026, 1, 4),
    ),
  ],
  'Serigne Mbaye': [
    Review(
      id: 'static-sm-1',
      fromUid: '',
      fromName: 'Cheikh T. Sow',
      text:
          'M. Mbaye est l\'investisseur le plus complet que j\'aie rencontré. Il comprend aussi bien les enjeux financiers que les réalités opérationnelles. Son accompagnement va bien au-delà du chèque.',
      createdAt: DateTime(2026, 5, 18),
    ),
    Review(
      id: 'static-sm-2',
      fromUid: '',
      fromName: 'Aïda Faye',
      text:
          'Après une session avec lui, j\'ai complètement revu ma gouvernance. Il insiste sur la transparence et les processus — des bases que j\'avais négligées. Mon rapport avec mes associés s\'est amélioré.',
      createdAt: DateTime(2026, 4, 8),
    ),
    Review(
      id: 'static-sm-3',
      fromUid: '',
      fromName: 'El Hadji Diop',
      text:
          'Sa connaissance du droit des affaires OHADA et des structures d\'investissement adaptées au marché sénégalais est précieuse. Il m\'a aidé à éviter une erreur juridique coûteuse.',
      createdAt: DateTime(2026, 2, 26),
    ),
    Review(
      id: 'static-sm-4',
      fromUid: '',
      fromName: 'Fatou Diagne',
      text:
          'M. Mbaye est exigeant mais bienveillant. Il attend le meilleur de toi et te donne les outils pour y arriver. Une chance de l\'avoir comme mentor/investisseur.',
      createdAt: DateTime(2025, 12, 31),
    ),
  ],
  'Pape Malick Ndiaye': [
    Review(
      id: 'static-pmn-1',
      fromUid: '',
      fromName: 'Mamadou Lamine Sow',
      text:
          'M. Ndiaye m\'a aidé à développer une stratégie multi-sectorielle cohérente. Sa vision à long terme et sa connaissance des fonds panafricains ont été déterminantes dans ma levée de fonds.',
      createdAt: DateTime(2026, 5, 2),
    ),
    Review(
      id: 'static-pmn-2',
      fromUid: '',
      fromName: 'Ndeye Seck',
      text:
          'Un investisseur qui pense Africa first. Ses conseils m\'ont aidée à structurer un partenariat entre mon entreprise sénégalaise et deux partenaires ivoiriens. Une vision véritablement continentale.',
      createdAt: DateTime(2026, 3, 13),
    ),
    Review(
      id: 'static-pmn-3',
      fromUid: '',
      fromName: 'Souleymane Diallo',
      text:
          'Session très dense et productive. Il m\'a aidé à prioriser mes marchés cibles et à concentrer mes ressources. Mon chiffre d\'affaires a augmenté de 45 % dans les 6 mois suivants.',
      createdAt: DateTime(2026, 1, 17),
    ),
  ],
  'Dr. Fatou Mbaye': [
    Review(
      id: 'static-dfm-1',
      fromUid: '',
      fromName: 'Papa Ibou Sow',
      text:
          'Dr. Mbaye est une figure incontournable de la santé numérique en Afrique. Elle m\'a aidé à identifier les bons partenaires hospitaliers et à structurer mon modèle de remboursement.',
      createdAt: DateTime(2026, 5, 7),
    ),
    Review(
      id: 'static-dfm-2',
      fromUid: '',
      fromName: 'Salimata Diallo',
      text:
          'Une investisseuse qui comprend à la fois la médecine et les affaires. Ses conseils sont précis, actionnables et toujours fondés sur une connaissance approfondie du terrain.',
      createdAt: DateTime(2026, 3, 23),
    ),
    Review(
      id: 'static-dfm-3',
      fromUid: '',
      fromName: 'Thierno Diallo',
      text:
          'Elle m\'a mis en relation avec des décideurs du Ministère de la Santé que je n\'aurais pas pu approcher seul. Un réseau institutionnel exceptionnel au service des entrepreneurs de la santé.',
      createdAt: DateTime(2026, 2, 2),
    ),
  ],
  'Aminata Wane': [
    Review(
      id: 'static-aw-1',
      fromUid: '',
      fromName: 'Boly Diallo',
      text:
          'Aminata a une capacité à connecter des projets très différents (santé, agriculture, énergie) dans une vision d\'impact cohérente. Elle m\'a aidé à mesurer l\'impact social de mon activité et à le valoriser auprès des fonds ESG.',
      createdAt: DateTime(2026, 4, 26),
    ),
    Review(
      id: 'static-aw-2',
      fromUid: '',
      fromName: 'Hawa Kouyaté',
      text:
          'Une mentor et investisseuse engagée pour les femmes entrepreneures. Elle comprend les défis spécifiques que nous rencontrons et propose des solutions adaptées. Précieuse !',
      createdAt: DateTime(2026, 3, 6),
    ),
    Review(
      id: 'static-aw-3',
      fromUid: '',
      fromName: 'Daouda Seck',
      text:
          'Sa connaissance des fonds d\'impact investing africains m\'a permis de cibler les bons interlocuteurs pour lever des fonds verts. Très efficace et très engagée.',
      createdAt: DateTime(2026, 1, 12),
    ),
  ],
};

/// Retourne les avis statiques pour un mentor donné (par son nom).
/// Retourne une liste vide si aucun avis n\'est défini pour ce mentor.
List<Review> staticReviewsFor(String mentorName) =>
    staticReviewsByMentor[mentorName] ?? [];

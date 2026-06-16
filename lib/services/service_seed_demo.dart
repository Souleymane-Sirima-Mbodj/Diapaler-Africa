import 'package:firebase_database/firebase_database.dart';
import 'service_authentification.dart';
import 'service_interactions.dart';

/// Injecte des données de démo complètes pour Souleymane Sirima Mbodj.
/// Exécuter une seule fois depuis la page Paramètres (bouton visible uniquement
/// pour sirimambodj@gmail.com).
class SeedDemoService {
  static final _db = FirebaseDatabase.instance.ref();

  // UIDs fictifs stables pour les contacts démo
  static const _papeDioufUid    = 'demo_mentor_pape_diouf';
  static const _aminataNianeUid = 'demo_mentor_aminata_niane';
  static const _yassineDialloUid = 'demo_investor_yassine_diallo';
  static const _awaCisseUid     = 'demo_investor_awa_cisse';

  // UIDs fictifs — entrepreneurs qui envoient des demandes de mentorat
  static const _ibrahimaSarrUid = 'demo_entr_ibrahima_sarr';
  static const _fatouBaUid      = 'demo_entr_fatou_ba';

  // UIDs réels de vrais comptes Firebase
  static const _mohamedNiangUid = 'iBu5zkFzocPW8yuRGcXB9pCH3ss2'; // Mentor
  static const _testInvestUid   = 'W9vpBlD7cmOoyuLMNO7Chq1iknD3'; // Investisseur

  static Future<void> seed() async {
    final myUid = AuthService.currentUid;
    if (myUid == null) throw Exception('Non connecté');

    // ── 1. Profils des contacts démo ───────────────────────────────
    // Ignoré si les règles Firebase ne permettent pas l'écriture sur users/{autreUid}
    await _tryPutProfile(_papeDioufUid, {
      'firstName': 'Pape', 'lastName': 'Diouf',
      'email': 'pape.diouf@demo.sn',
      'role': 'Mentor', 'gender': 'male',
      'city': 'Dakar', 'country': 'Sénégal', 'sector': 'FinTech',
      'bio': 'Expert en FinTech avec plus de 15 ans d\'expérience dans le secteur bancaire et les startups de paiement mobile en Afrique de l\'Ouest.',
      'interests': ['FinTech', 'Paiement mobile', 'Inclusion financière'],
      'score': 4.8, 'yearsExperience': 15,
    });

    await _tryPutProfile(_aminataNianeUid, {
      'firstName': 'Aminata', 'lastName': 'Niane',
      'email': 'aminata.niane@demo.sn',
      'role': 'Mentor', 'gender': 'female',
      'city': 'Dakar', 'country': 'Sénégal', 'sector': 'Tech & Innovation',
      'bio': 'CTO d\'une startup EdTech sénégalaise, passionnée par l\'accessibilité de la tech en Afrique.',
      'interests': ['Tech', 'EdTech', 'Innovation', 'Mobile'],
      'score': 4.6, 'yearsExperience': 10,
    });

    await _tryPutProfile(_yassineDialloUid, {
      'firstName': 'Yassine', 'lastName': 'Diallo',
      'email': 'yassine.diallo@demo.sn',
      'role': 'Investisseur', 'gender': 'male',
      'city': 'Abidjan', 'country': 'Côte d\'Ivoire', 'sector': 'Capital-risque',
      'bio': 'Business Angel basé à Abidjan, investit dans des startups africaines en phase de croissance.',
      'interests': ['AgriTech', 'HealthTech', 'FinTech'],
      'score': 4.5, 'yearsExperience': 12,
      'investmentRange': '5M - 50M FCFA',
    });

    await _tryPutProfile(_ibrahimaSarrUid, {
      'firstName': 'Ibrahima', 'lastName': 'Sarr',
      'email': 'ibrahima.sarr@demo.sn',
      'role': 'Entrepreneur', 'gender': 'male',
      'city': 'Thiès', 'country': 'Sénégal', 'sector': 'AgriTech',
      'bio': 'Fondateur de FarmLink, une plateforme qui connecte les petits producteurs agricoles aux marchés locaux. 2 ans d\'expérience terrain dans la région de Thiès.',
      'interests': ['AgriTech', 'Chaîne de valeur agricole', 'Impact rural'],
      'score': 0.0, 'yearsExperience': 2,
    });

    await _tryPutProfile(_fatouBaUid, {
      'firstName': 'Fatou', 'lastName': 'Ba',
      'email': 'fatou.ba@demo.sn',
      'role': 'Entrepreneur', 'gender': 'female',
      'city': 'Dakar', 'country': 'Sénégal', 'sector': 'HealthTech',
      'bio': 'Co-fondatrice de SantéDirect, une solution de téléconsultation médicale adaptée aux zones périurbaines. Infirmière de formation reconvertie en entrepreneuse tech.',
      'interests': ['HealthTech', 'Télémédecine', 'Santé communautaire'],
      'score': 0.0, 'yearsExperience': 3,
    });

    await _tryPutProfile(_awaCisseUid, {
      'firstName': 'Awa', 'lastName': 'Cissé',
      'email': 'awa.cisse@demo.sn',
      'role': 'Investisseur', 'gender': 'female',
      'city': 'Dakar', 'country': 'Sénégal', 'sector': 'Impact investing',
      'bio': 'Investisseuse à impact, fondatrice du fonds DiafrikInvest. Focus sur les startups à fort impact social.',
      'interests': ['Impact social', 'Agritech', 'Éducation'],
      'score': 4.7, 'yearsExperience': 8,
      'investmentRange': '2M - 20M FCFA',
    });

    // ── 2. Relations acceptées (mentorRequests) ────────────────────
    final short = myUid.length >= 8 ? myUid.substring(0, 8) : myUid;
    final req1 = 'demo_mr_pd_$short';
    final req2 = 'demo_mr_an_$short';
    final req3 = 'demo_mr_yd_$short';
    final req4 = 'demo_mr_ac_$short';

    await _db.child('mentorRequests/$req1').set({
      'id': req1,
      'fromUserId': myUid, 'toUserId': _papeDioufUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Pape Diouf',
      'message': 'Bonjour Pape, je développe une solution FinTech de paiement pour les marchés informels. Votre expertise me serait précieuse.',
      'type': 'mentor', 'status': 'accepted',
      'createdAt': _daysAgo(30), 'respondedAt': _daysAgo(28),
    });

    await _db.child('mentorRequests/$req2').set({
      'id': req2,
      'fromUserId': myUid, 'toUserId': _aminataNianeUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Aminata Niane',
      'message': 'Bonjour Aminata, votre parcours en EdTech m\'inspire. J\'aimerais bénéficier de votre mentorat pour la partie tech de mon projet.',
      'type': 'mentor', 'status': 'accepted',
      'createdAt': _daysAgo(14), 'respondedAt': _daysAgo(13),
    });

    await _db.child('mentorRequests/$req3').set({
      'id': req3,
      'fromUserId': _yassineDialloUid, 'toUserId': myUid,
      'fromName': 'Yassine Diallo', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'Bonjour Souleymane, j\'ai vu votre pitch et je suis très intéressé. Seriez-vous disponible pour un échange cette semaine ?',
      'type': 'investment', 'status': 'accepted',
      'createdAt': _daysAgo(19), 'respondedAt': _daysAgo(18),
    });

    await _db.child('mentorRequests/$req4').set({
      'id': req4,
      'fromUserId': _awaCisseUid, 'toUserId': myUid,
      'fromName': 'Awa Cissé', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'Votre projet d\'inclusion financière correspond parfaitement à notre thèse d\'investissement impact.',
      'type': 'investment', 'status': 'accepted',
      'createdAt': _daysAgo(7), 'respondedAt': _daysAgo(6),
    });

    // ── 2b. Demandes de mentorat EN ATTENTE reçues d'entrepreneurs ──
    final reqIs = 'demo_mr_is_$short';
    await _db.child('mentorRequests/$reqIs').set({
      'id': reqIs,
      'fromUserId': _ibrahimaSarrUid, 'toUserId': myUid,
      'fromName': 'Ibrahima Sarr', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'Bonjour Souleymane, j\'ai découvert votre parcours avec PayFlow et votre expérience sur le marché informel m\'inspire beaucoup. Je développe FarmLink en AgriTech et je cherche un mentor qui comprend les réalités du terrain en Afrique de l\'Ouest. Seriez-vous disponible pour m\'accompagner ?',
      'type': 'mentor', 'status': 'pending',
      'createdAt': _daysAgo(1), 'respondedAt': null,
    });

    final reqFb = 'demo_mr_fb_$short';
    await _db.child('mentorRequests/$reqFb').set({
      'id': reqFb,
      'fromUserId': _fatouBaUid, 'toUserId': myUid,
      'fromName': 'Fatou Ba', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'Bonjour Souleymane ! Je suis co-fondatrice de SantéDirect, une app de téléconsultation pour les zones périurbaines. Votre expérience en acquisition utilisateurs et en réglementation me serait très précieuse. J\'aimerais beaucoup bénéficier de votre mentorat pour passer à l\'étape de scale-up.',
      'type': 'mentor', 'status': 'pending',
      'createdAt': _daysAgo(3), 'respondedAt': null,
    });

    // ── 3. Conversations et messages temps réel ────────────────────
    await _seedConv(myUid, _papeDioufUid, 'Souleymane Sirima Mbodj', 'Pape Diouf', const [
      _M(_papeDioufUid,  'Bonjour Souleymane ! Votre projet me semble très prometteur. Ravi de vous accompagner.', 28),
      _M(_selfUid,       'Merci beaucoup Pape ! Quand pourrait-on se retrouver pour une première session ?', 27),
      _M(_papeDioufUid,  'Je suis disponible mardi à 15h ou jeudi à 10h. Quel horaire vous convient ?', 27),
      _M(_selfUid,       'Mardi à 15h me convient parfaitement ! En visioconférence ?', 26),
      _M(_papeDioufUid,  'Absolument. Je vous enverrai le lien Meet demain. Préparez une présentation de 10 min sur votre modèle éco.', 26),
      _M(_selfUid,       'Parfait ! J\'ai mis à jour mon pitch deck ce matin. Merci encore !', 20),
      _M(_papeDioufUid,  'Excellente première session ! Votre compréhension du marché informel est un vrai avantage concurrentiel.', 13),
      _M(_selfUid,       'Merci ! Vos conseils sur la stratégie B2B m\'ont vraiment ouvert les yeux. Je vais retravailler le go-to-market.', 13),
      _M(_papeDioufUid,  'On se retrouve dans 2 semaines. D\'ici là, contactez au moins 3 commerçants potentiels.', 12),
      _M(_selfUid,       'J\'ai déjà contacté 5 commerçants du marché Sandaga ! 3 sont très intéressés pour tester l\'app.', 2),
    ]);

    await _seedConv(myUid, _aminataNianeUid, 'Souleymane Sirima Mbodj', 'Aminata Niane', const [
      _M(_aminataNianeUid, 'Salut Souleymane ! J\'ai regardé ta stack technique. Quelques questions sur le choix de Flutter.', 13),
      _M(_selfUid,         'Bonjour Aminata ! Flutter pour la cross-platform bien sûr, mais aussi la rapidité de développement.', 13),
      _M(_aminataNianeUid, 'Bonne décision. Tu as pensé au mode offline-first ? Avec la connectivité parfois limitée, c\'est crucial.', 12),
      _M(_selfUid,         'Excellente remarque ! J\'ai du SQLite local mais c\'est basique. Tu peux m\'aider à améliorer ça ?', 12),
      _M(_aminataNianeUid, 'Bien sûr. Je t\'envoie des ressources sur Isar et la sync Firebase offline. On en parle à notre prochaine session.', 11),
      _M(_selfUid,         'Super merci ! J\'ai aussi ajouté les tests unitaires comme tu me l\'avais conseillé.', 5),
      _M(_aminataNianeUid, 'Très bien ! Pour la prochaine fois, travaille sur la sécurité des données — c\'est non négociable en FinTech.', 5),
      _M(_selfUid,         'Compris. Je lis la doc PCI DSS ce week-end. Ta guidance est vraiment précieuse, merci Aminata !', 4),
    ]);

    await _seedConv(myUid, _yassineDialloUid, 'Souleymane Sirima Mbodj', 'Yassine Diallo', const [
      _M(_yassineDialloUid, 'Bonjour Souleymane, j\'ai visionné votre pitch vidéo. Très solide ! Quelques questions sur vos chiffres.', 18),
      _M(_selfUid,          'Bonjour Yassine, merci ! Je suis disponible pour répondre à toutes vos questions.', 18),
      _M(_yassineDialloUid, 'Votre CAC est estimé à combien ? Et votre projection de LTV sur 12 mois ?', 17),
      _M(_selfUid,          'CAC pilote : ~2 500 FCFA / commerçant. LTV projetée : 45 000 FCFA sur 12 mois. ROI de 18x.', 17),
      _M(_yassineDialloUid, 'Votre taux de rétention à 30 jours sur les bêta-testeurs ?', 17),
      _M(_selfUid,          '78% de rétention à 30 jours sur 23 bêta-testeurs actifs. 4,2 transactions/semaine en moyenne.', 16),
      _M(_yassineDialloUid, 'Ces métriques sont excellentes pour une phase beta. Nous souhaitons participer à votre tour de seed.', 15),
      _M(_selfUid,          'C\'est une excellente nouvelle ! J\'attends votre term sheet avec impatience. Merci de la confiance !', 15),
      _M(_yassineDialloUid, 'Term sheet envoyée par email. Prenez le temps de la lire. On se rappelle vendredi ?', 14),
      _M(_selfUid,          'Parfait, vendredi 10h vous convient-il ?', 14),
    ]);

    await _seedConv(myUid, _awaCisseUid, 'Souleymane Sirima Mbodj', 'Awa Cissé', const [
      _M(_awaCisseUid, 'Bonjour Souleymane ! Votre projet d\'inclusion financière correspond à notre mission. Parlez-moi de votre impact social.', 6),
      _M(_selfUid,     'Bonjour Awa ! Notre solution permet à des commerçants non-bancarisés d\'accéder aux paiements digitaux. 74% de nos utilisatrices sont des femmes.', 6),
      _M(_awaCisseUid, 'Parfait, c\'est exactement ce que nous cherchons. Avez-vous des données sur le profil de vos utilisatrices ?', 5),
      _M(_selfUid,     'Âge moyen 38 ans, revenus entre 80 000 et 250 000 FCFA/mois. Aucune n\'avait de compte bancaire avant notre app.', 5),
      _M(_awaCisseUid, 'Ces données sont remarquables. DiafrikInvest est très intéressé. Je vous propose une réunion avec toute mon équipe.', 4),
      _M(_selfUid,     'Avec plaisir ! Dites-moi quel jour vous convient. Je préparerai une présentation complète.', 4),
      _M(_awaCisseUid, 'Mercredi 14h à nos bureaux à la Cité Keur Gorgui. Je vous envoie l\'adresse.', 3),
      _M(_selfUid,     'Très bien, je serai là avec mon associé technique. Merci de cet intérêt, Awa !', 3),
    ]);

    // ── 4. Notifications ───────────────────────────────────────────
    await _notif(myUid, 'Bienvenue sur Diapaler ! 🎉',
        'Votre compte a été créé. Complétez votre profil pour commencer.', 'welcome', daysAgo: 45);
    await _notif(myUid, 'Demande acceptée ✓',
        'Pape Diouf a accepté votre demande de mentorat.',
        'mentor_request_accepted', fromUserId: _papeDioufUid, fromName: 'Pape Diouf', requestId: req1, daysAgo: 28);
    await _notif(myUid, 'Session confirmée ✓',
        'Votre session avec Pape Diouf est confirmée pour mardi à 15h.',
        'session_accepted', fromUserId: _papeDioufUid, fromName: 'Pape Diouf', daysAgo: 20);
    await _notif(myUid, 'Offre d\'investissement 💰',
        'Yassine Diallo vous propose un investissement. Consultez sa demande.',
        'investment_offer', fromUserId: _yassineDialloUid, fromName: 'Yassine Diallo', requestId: req3, daysAgo: 19);
    await _notif(myUid, 'Nouveau message',
        'Yassine Diallo vous a envoyé un message.',
        'message', fromUserId: _yassineDialloUid, fromName: 'Yassine Diallo', daysAgo: 14);
    await _notif(myUid, 'Demande acceptée ✓',
        'Aminata Niane a accepté votre demande de mentorat.',
        'mentor_request_accepted', fromUserId: _aminataNianeUid, fromName: 'Aminata Niane', requestId: req2, daysAgo: 13);
    await _notif(myUid, 'Nouvel avis reçu 💬',
        'Pape Diouf a laissé un avis sur votre profil.',
        'new_review', fromUserId: _papeDioufUid, fromName: 'Pape Diouf', daysAgo: 10);
    await _notif(myUid, 'Nouvelle note reçue ⭐',
        'Aminata Niane vous a attribué 5 étoiles.',
        'new_rating', fromUserId: _aminataNianeUid, fromName: 'Aminata Niane', daysAgo: 8);
    await _notif(myUid, 'Offre d\'investissement 💰',
        'Awa Cissé (DiafrikInvest) est intéressée par votre projet.',
        'investment_offer', fromUserId: _awaCisseUid, fromName: 'Awa Cissé', requestId: req4, daysAgo: 7);
    await _notif(myUid, 'Pitch consulté 👀',
        'Votre pitch PayFlow a été consulté par 12 investisseurs cette semaine.',
        'pitch_viewed', daysAgo: 3);
    await _notif(myUid, 'Nouvelle demande de mentorat 🤝',
        'Fatou Ba souhaite bénéficier de votre mentorat pour SantéDirect.',
        'mentor_request', fromUserId: _fatouBaUid, fromName: 'Fatou Ba', requestId: reqFb, daysAgo: 3);
    await _notif(myUid, 'Nouvelle demande de mentorat 🤝',
        'Ibrahima Sarr vous contacte pour un accompagnement sur FarmLink.',
        'mentor_request', fromUserId: _ibrahimaSarrUid, fromName: 'Ibrahima Sarr', requestId: reqIs, daysAgo: 1);

    // ── 5. Pitchs complets ─────────────────────────────────────────
    final p1 = 'demo_pitch_${short}_payflow';
    await _db.child('pitches/$p1').set({
      'id': p1,
      'userId': myUid,
      'userName': 'Souleymane Sirima Mbodj',
      'title': 'PayFlow — Paiement digital pour le commerce informel',
      'sector': 'FinTech',
      'description':
          'PayFlow est une solution de paiement mobile sans compte bancaire destinée aux commerçants du secteur informel en Afrique de l\'Ouest.\n\n'
          'Via un QR code ou un numéro de téléphone, un commerçant peut recevoir des paiements, envoyer de l\'argent et accéder à des micro-crédits basés sur son historique de transactions.\n\n'
          'Nous ciblons en priorité les femmes des marchés urbains — une population sous-bancarisée mais très active économiquement. '
          'Traction : 23 bêta-testeurs actifs, 78% de rétention à 30 jours, 4,2 transactions/semaine en moyenne.\n\n'
          'Nous cherchons 15M FCFA pour finaliser l\'app, obtenir notre agrément EME et lancer un pilote sur 3 marchés de Dakar.',
      'amount': '15 000 000 FCFA',
      'createdAt': DateTime.now().subtract(const Duration(days: 35)).millisecondsSinceEpoch,
      'businessPlanUrl': 'https://example.com/demo_bp_payflow.pdf',
      'deckUrl': 'https://example.com/demo_deck_payflow.pdf',
    });

    final p2 = 'demo_pitch_${short}_agriconnect';
    await _db.child('pitches/$p2').set({
      'id': p2,
      'userId': myUid,
      'userName': 'Souleymane Sirima Mbodj',
      'title': 'AgriConnect — Marketplace B2B pour l\'agriculture locale',
      'sector': 'AgriTech',
      'description':
          'AgriConnect met en relation directe les producteurs agricoles locaux avec les restaurateurs, hôtels et supermarchés de Dakar. '
          'Fini les intermédiaires qui captent jusqu\'à 60% de la marge des agriculteurs.\n\n'
          'Notre plateforme permet : aux agriculteurs de publier leurs récoltes avec photos et prix ; '
          'aux acheteurs de passer des commandes directement avec livraison coordonnée ; '
          'aux deux parties de se noter et bâtir une réputation digitale.\n\n'
          'Pilote réussi avec 8 producteurs de la région de Thiès et 5 restaurants de Dakar. '
          'Volume : 4,2M FCFA sur 3 mois.',
      'amount': '8 000 000 FCFA',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)).millisecondsSinceEpoch,
    });

    // ── 6. Favoris ─────────────────────────────────────────────────
    await _db.child('favorites/$myUid/$_papeDioufUid').set({
      'initials': 'PD', 'name': 'Pape Diouf', 'title': 'FinTech',
      'city': 'Dakar', 'sectors': {'0': 'FinTech', '1': 'Paiement mobile', '2': 'Inclusion financière'},
      'companies': <String, String>{}, 'rating': 4.8, 'reviews': 47,
      'years': 15, 'compatibility': 95, 'cis': false,
      'role': 'Mentor', 'gender': 'male',
      'bio': 'Expert en FinTech avec plus de 15 ans d\'expérience.',
      'uid': _papeDioufUid,
    });

    await _db.child('favorites/$myUid/$_awaCisseUid').set({
      'initials': 'AC', 'name': 'Awa Cissé', 'title': 'Impact investing',
      'city': 'Dakar', 'sectors': {'0': 'Impact social', '1': 'Agritech', '2': 'Éducation'},
      'companies': <String, String>{}, 'rating': 4.7, 'reviews': 23,
      'years': 8, 'compatibility': 88, 'cis': false,
      'role': 'Investisseur', 'gender': 'female',
      'bio': 'Investisseuse à impact, fondatrice du fonds DiafrikInvest.',
      'uid': _awaCisseUid,
    });

    // ── 7. Sessions agenda ─────────────────────────────────────────
    // Demande de session EN ATTENTE avec Yassine Diallo (à venir dans 10 j.)
    final sr1 = 'demo_sr_yd_$short';
    await _db.child('mentorRequests/$sr1').set({
      'id': sr1,
      'fromUserId': myUid, 'toUserId': _yassineDialloUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Yassine Diallo',
      'message': 'Bonjour Yassine, je souhaite une session pour discuter du term sheet et négocier les conditions d\'entrée au capital.',
      'type': 'session', 'status': 'pending',
      'proposedDate': _dateInDays(10), 'proposedTime': '14:00',
      'sessionTheme': 'Négociation term sheet — conditions d\'investissement',
      'createdAt': _daysAgo(2), 'respondedAt': null,
    });

    // Session ACCEPTÉE à venir dans 4 j. avec Pape Diouf
    final sr2 = 'demo_sr_pd_$short';
    await _db.child('mentorRequests/$sr2').set({
      'id': sr2,
      'fromUserId': myUid, 'toUserId': _papeDioufUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Pape Diouf',
      'message': 'Bonjour Pape, je veux retravailler ma stratégie go-to-market après les retours terrain du marché Sandaga.',
      'type': 'session', 'status': 'accepted',
      'proposedDate': _dateInDays(4), 'proposedTime': '15:00',
      'sessionTheme': 'Stratégie go-to-market — retours terrain Sandaga',
      'createdAt': _daysAgo(5), 'respondedAt': _daysAgo(4),
    });

    // Session TERMINÉE (accepted + date passée) avec Aminata Niane
    final sr3 = 'demo_sr_an_past_$short';
    await _db.child('mentorRequests/$sr3').set({
      'id': sr3,
      'fromUserId': myUid, 'toUserId': _aminataNianeUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Aminata Niane',
      'message': 'Session sur l\'architecture offline-first et la synchronisation Firebase.',
      'type': 'session', 'status': 'accepted',
      'proposedDate': _dateInDays(-11), 'proposedTime': '10:00',
      'sessionTheme': 'Architecture offline-first et sync Firebase',
      'createdAt': _daysAgo(18), 'respondedAt': _daysAgo(17),
    });

    // Session ANNULÉE avec Awa Cissé (il y a 6 j.)
    final sr4 = 'demo_sr_ac_cancel_$short';
    await _db.child('mentorRequests/$sr4').set({
      'id': sr4,
      'fromUserId': _awaCisseUid, 'toUserId': myUid,
      'fromName': 'Awa Cissé', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'RDV avec l\'équipe DiafrikInvest pour présentation du plan d\'impact social.',
      'type': 'session', 'status': 'cancelled',
      'proposedDate': _dateInDays(-6), 'proposedTime': '14:00',
      'sessionTheme': 'Présentation plan d\'impact — équipe DiafrikInvest',
      'cancellationReason': 'Déplacement urgent à l\'étranger de l\'équipe DiafrikInvest. Report prévu prochainement.',
      'createdAt': _daysAgo(14), 'respondedAt': _daysAgo(6),
    });

    // BookedSession à venir dans 7 j. avec Aminata Niane
    final bsId = 'demo_bs_an_$short';
    final bsDate = DateTime.now().add(const Duration(days: 7));
    await _db.child('bookedSessions/$myUid/$bsId').set({
      'id': bsId,
      'mentorName': 'Aminata Niane',
      'mentorInitials': 'AN',
      'scheduledAt': bsDate
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0)
          .toIso8601String(),
      'otherUid': _aminataNianeUid,
    });

    // ── 8. Utilisateurs réels — Mohamed Moctar Niang & Test ───────

    // Relation acceptée avec Mohamed Moctar Niang (Mentor réel)
    final req5 = 'demo_mr_mmn_$short';
    await _db.child('mentorRequests/$req5').set({
      'id': req5,
      'fromUserId': myUid, 'toUserId': _mohamedNiangUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Mohamed Moctar Niang',
      'message': 'Bonjour Mohamed, votre expérience en entrepreneuriat africain correspond exactement à ce dont j\'ai besoin. J\'aimerais bénéficier de votre mentorat pour structurer PayFlow.',
      'type': 'mentor', 'status': 'accepted',
      'createdAt': _daysAgo(22), 'respondedAt': _daysAgo(20),
    });

    await _seedConv(myUid, _mohamedNiangUid, 'Souleymane Sirima Mbodj', 'Mohamed Moctar Niang', const [
      _M(_mohamedNiangUid, 'Bonjour Souleymane ! Ravi de vous accompagner dans votre parcours entrepreneurial.', 20),
      _M(_selfUid,         'Merci Mohamed ! Je suis vraiment enthousiaste à l\'idée de travailler avec vous.', 20),
      _M(_mohamedNiangUid, 'J\'ai parcouru votre pitch PayFlow. Très bonne compréhension du marché informel. Quelle est votre principale difficulté ?', 18),
      _M(_selfUid,         'La réglementation. Les agréments EME au Sénégal sont complexes à obtenir.', 18),
      _M(_mohamedNiangUid, 'Je connais bien ce sujet. J\'ai accompagné deux startups FinTech dans ce processus. Je vous mets en contact avec un conseiller juridique spécialisé.', 17),
      _M(_selfUid,         'C\'est exactement ce dont j\'avais besoin ! Merci infiniment Mohamed.', 17),
      _M(_mohamedNiangUid, 'De rien. Préparez un dossier complet sur votre modèle de transaction pour notre prochaine session.', 10),
      _M(_selfUid,         'En cours ! Notre taux de transaction moyen est de 450 FCFA par opération.', 8),
    ]);

    // Demande de session EN ATTENTE avec Mohamed Moctar Niang (dans 6 j.)
    final sr5 = 'demo_sr_mmn_$short';
    await _db.child('mentorRequests/$sr5').set({
      'id': sr5,
      'fromUserId': myUid, 'toUserId': _mohamedNiangUid,
      'fromName': 'Souleymane Sirima Mbodj', 'toName': 'Mohamed Moctar Niang',
      'message': 'Bonjour Mohamed, je souhaite une session pour préparer mon dossier réglementaire EME.',
      'type': 'session', 'status': 'pending',
      'proposedDate': _dateInDays(6), 'proposedTime': '11:00',
      'sessionTheme': 'Dossier réglementaire EME — agrément FinTech',
      'createdAt': _daysAgo(1), 'respondedAt': null,
    });

    await _notif(myUid, 'Demande acceptée ✓',
        'Mohamed Moctar Niang a accepté votre demande de mentorat.',
        'mentor_request_accepted',
        fromUserId: _mohamedNiangUid, fromName: 'Mohamed Moctar Niang',
        requestId: req5, daysAgo: 20);

    // Relation acceptée avec Test (Investisseur réel)
    final req6 = 'demo_mr_test_$short';
    await _db.child('mentorRequests/$req6').set({
      'id': req6,
      'fromUserId': _testInvestUid, 'toUserId': myUid,
      'fromName': 'Test', 'toName': 'Souleymane Sirima Mbodj',
      'message': 'Bonjour, votre projet m\'intéresse. Pouvez-vous me présenter votre stratégie de financement ?',
      'type': 'investment', 'status': 'accepted',
      'createdAt': _daysAgo(9), 'respondedAt': _daysAgo(8),
    });

    await _seedConv(myUid, _testInvestUid, 'Souleymane Sirima Mbodj', 'Test', const [
      _M(_testInvestUid, 'Bonjour Souleymane, j\'ai vu votre pitch PayFlow. Quels sont vos besoins en financement ?', 8),
      _M(_selfUid,       'Bonjour ! 15M FCFA pour la phase seed : finaliser l\'app, obtenir l\'agrément EME et lancer sur 3 marchés.', 8),
      _M(_testInvestUid, 'Intéressant. Avez-vous des traction chiffrées ?', 7),
      _M(_selfUid,       '23 bêta-testeurs actifs, 78% de rétention à 30 jours, 4,2 transactions/semaine. Volume beta : 1,2M FCFA sur 2 mois.', 7),
      _M(_testInvestUid, 'Très encourageant pour une phase beta. Parlez-moi de votre modèle de revenus.', 6),
      _M(_selfUid,       'Commission de 1,5% par transaction + abonnement commerçant 3 500 FCFA/mois. LTV projetée : 45 000 FCFA sur 12 mois.', 6),
      _M(_testInvestUid, 'Bon ratio CAC/LTV. Je voudrais voir vos projections sur 18 mois. Pouvez-vous les partager ?', 4),
      _M(_selfUid,       'Bien sûr, je vous envoie le fichier Excel dès aujourd\'hui. Merci de l\'intérêt !', 4),
    ]);

    await _notif(myUid, 'Offre d\'investissement 💰',
        'Test est intéressé par votre projet. Consultez sa demande.',
        'investment_offer',
        fromUserId: _testInvestUid, fromName: 'Test',
        requestId: req6, daysAgo: 9);

    // Mise à jour compteur mentorsActive
    await _db.child('users/$myUid').update({'mentorsActive': 6});
  }

  // ── Helpers ──────────────────────────────────────────────────────

  static Future<void> _tryPutProfile(String uid, Map<String, dynamic> d) async {
    try {
      await _putProfile(uid, d);
    } catch (_) {} // ignoré si règles Firebase trop restrictives
  }

  static Future<void> _putProfile(String uid, Map<String, dynamic> d) async {
    await _db.child('users/$uid').set({
      'firstName': d['firstName'] ?? '',
      'lastName':  d['lastName'] ?? '',
      'email':     d['email'] ?? '',
      'phone': '', 'address': '', 'linkedin': '', 'photoBase64': '',
      'gender':    d['gender'] ?? 'undisclosed',
      'birthDate': null,
      'city':      d['city'] ?? 'Dakar',
      'country':   d['country'] ?? 'Sénégal',
      'sector':    d['sector'] ?? '',
      'role':      d['role'] ?? 'Mentor',
      'bio':       d['bio'] ?? '',
      'interests': d['interests'] ?? <String>[],
      'projects':  <dynamic>[],
      'mentorsActive': 0, 'sessionsCount': 0, 'favoritesCount': 0,
      'score':         d['score'] ?? 0.0,
      'yearsExperience': d['yearsExperience'] ?? 0,
      'investmentRange': d['investmentRange'] ?? '',
      'isPremium': false, 'premiumPlan': '',
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Sentinel pour repérer "l'utilisateur courant" dans les listes de messages statiques
  static const _selfUid = '__SELF__';

  static Future<void> _seedConv(
    String myUid,
    String otherUid,
    String myName,
    String otherName,
    List<_M> msgs,
  ) async {
    final convId = InteractionsService.generateConversationId(myUid, otherUid);
    final ids = [myUid, otherUid]..sort();

    String lastMsg = '';
    String lastSender = '';
    DateTime? lastTime;

    // Ajouter un offset en minutes pour que les IDs soient uniques même sur le même jour
    int minuteOffset = 0;
    for (final m in msgs) {
      final senderId = m.sender == _selfUid ? myUid : m.sender;
      final recipId  = senderId == myUid ? otherUid : myUid;
      final ts = DateTime.now()
          .subtract(Duration(days: m.daysAgo))
          .subtract(Duration(minutes: minuteOffset));
      minuteOffset += 17; // écart entre messages

      final msgId = ts.millisecondsSinceEpoch.toString();
      await _db.child('messages/$convId/$msgId').set({
        'id': msgId,
        'senderId': senderId,
        'senderName': senderId == myUid ? myName : otherName,
        'recipientId': recipId,
        'text': m.text,
        'timestamp': ts.toIso8601String(),
        'isRead': true,
      });
      lastMsg    = m.text;
      lastSender = senderId;
      lastTime   = ts;
    }

    if (lastTime != null) {
      await _db.child('conversations/$convId').set({
        'id': convId,
        'user1Id':   ids[0],
        'user2Id':   ids[1],
        'user1Name': ids[0] == myUid ? myName : otherName,
        'user2Name': ids[0] == myUid ? otherName : myName,
        'lastMessage':     lastMsg,
        'lastMessageTime': lastTime.toIso8601String(),
        'unreadCount': 0,
        'lastSenderId': lastSender,
      });
    }
  }

  static Future<void> _notif(
    String uid,
    String title,
    String message,
    String type, {
    String fromUserId = '',
    String fromName = '',
    String requestId = '',
    int daysAgo = 0,
  }) async {
    final ts = DateTime.now().subtract(Duration(days: daysAgo));
    final id = ts.millisecondsSinceEpoch.toString();
    await _db.child('notifications/$uid/$id').set({
      'id': id, 'title': title, 'message': message,
      'timestamp': ts.toIso8601String(),
      'type': type,
      'isRead': daysAgo > 3,
      'requestId': requestId,
      'fromUserId': fromUserId,
      'fromName': fromName,
    });
  }

  static String _daysAgo(int days) =>
      DateTime.now().subtract(Duration(days: days)).toIso8601String();

  /// Retourne une date au format 'YYYY-MM-DD' décalée de [days] jours
  /// depuis aujourd'hui (positif = futur, négatif = passé).
  static String _dateInDays(int days) {
    final d = DateTime.now().add(Duration(days: days));
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}

/// Message de conversation statique pour le seed.
class _M {
  final String sender;  // UID réel ou '__SELF__'
  final String text;
  final int daysAgo;
  const _M(this.sender, this.text, this.daysAgo);
}

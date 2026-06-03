import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../services/service_favoris.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_chat.dart';
import 'page_send_request.dart';

/// Construit la bio à afficher dans le détail d'un mentor.
/// Utilise mentor.bio si non vide, sinon génère une bio automatique
/// avec le bon pronom selon le genre.
String _buildBio(Mentor mentor) {
  if (mentor.bio.isNotEmpty) return mentor.bio;
  final String pronom;
  final String convaincu;
  switch (mentor.gender) {
    case Gender.male:
      pronom = 'il';
      convaincu = 'Convaincu';
      break;
    case Gender.female:
      pronom = 'elle';
      convaincu = 'Convaincue';
      break;
    default:
      pronom = 'il/elle';
      convaincu = 'Convaincu·e';
  }
  return '${mentor.name} accompagne les jeunes entrepreneurs sénégalais '
      'depuis ${mentor.years} ans dans les secteurs ${mentor.sectors.join(", ")}. '
      '$convaincu que l\'avenir de l\'Afrique se joue dans la jeunesse, '
      '$pronom privilégie un mentorat sectoriel concret et bienveillant.';
}

class MentorDetailPage extends StatefulWidget {
  final Mentor mentor;
  const MentorDetailPage({super.key, required this.mentor});

  @override
  State<MentorDetailPage> createState() => _MentorDetailPageState();
}

class _MentorDetailPageState extends State<MentorDetailPage> {
  late bool _isFavorite;
  // null = chargement en cours, true = acceptée, false = non acceptée
  bool? _requestAccepted;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoriteService.isFavorite(widget.mentor);
    FavoriteService.favorites.addListener(_onFavoritesChanged);
    _checkRequestStatus();
  }

  void _onFavoritesChanged() {
    final fav = FavoriteService.isFavorite(widget.mentor);
    if (fav != _isFavorite) {
      setState(() => _isFavorite = fav);
    }
  }

  @override
  void dispose() {
    FavoriteService.favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  Future<void> _checkRequestStatus() async {
    final mentor = widget.mentor;

    // Profils statiques (uid vide) : pas de vérification Firebase
    // Le bloc boutons est masqué directement dans le Builder pour ces profils.
    if (mentor.uid.isEmpty) {
      setState(() => _requestAccepted = false);
      return;
    }

    final myUid = AuthService.currentUid;
    if (myUid == null) {
      setState(() => _requestAccepted = false);
      return;
    }

    // Même utilisateur qui regarde son propre profil
    if (myUid == mentor.uid) {
      setState(() => _requestAccepted = true);
      return;
    }

    try {
      final snap = await FirebaseDatabase.instance.ref('mentorRequests').get();
      final data = snap.value as Map?;
      if (data == null) {
        setState(() => _requestAccepted = false);
        return;
      }
      // Vérification bidirectionnelle : une demande acceptée dans n'importe quel sens
      final accepted = data.values.any((v) {
        if (v is! Map) return false;
        if (v['status'] != 'accepted') return false;
        final from = v['fromUserId']?.toString() ?? '';
        final to = v['toUserId']?.toString() ?? '';
        return (from == myUid && to == mentor.uid) ||
               (from == mentor.uid && to == myUid);
      });
      setState(() => _requestAccepted = accepted);
    } catch (_) {
      setState(() => _requestAccepted = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final myUid = AuthService.currentUid ?? '';
    if (myUid.isEmpty) return;
    try {
      await FavoriteService.toggle(myUid, widget.mentor);
      // L'état _isFavorite est mis à jour par _onFavoritesChanged via le listener.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de modifier le favori : $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showBookingSheet(BuildContext ctx) async {
    if (widget.mentor.uid.isEmpty) {
      // Profil statique : booking direct J+7 14h (démo)
      _bookSessionLegacy();
      return;
    }
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookingSheet(mentor: widget.mentor),
    );
  }

  void _bookSessionLegacy() {
    final profile = UserProfileController.profile.value;
    final sessionDate = DateTime.now().add(const Duration(days: 7));
    final session = BookedSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mentorName: widget.mentor.name,
      mentorInitials: widget.mentor.initials,
      scheduledAt: DateTime(sessionDate.year, sessionDate.month, sessionDate.day, 14),
    );
    AgendaController.add(profile.email, session);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session réservée avec ${widget.mentor.name.split(" ").first} !'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mentor = widget.mentor;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 218,
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(_isFavorite),
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(
                              initials: mentor.initials,
                              size: 70,
                              background: AppColors.amber,
                              foreground: AppColors.navyDeep,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          mentor.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (mentor.isInvestor) const _InvestorBadgeBig(),
                                      if (mentor.cis && !mentor.isInvestor) const _CisBadgeBig(),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mentor.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _HeroChip(
                                        icon: Icons.location_on_outlined,
                                        label: mentor.city,
                                      ),
                                      _HeroChip(
                                        icon: Icons.business_rounded,
                                        label:
                                            '${mentor.companies.length} entreprise${mentor.companies.length > 1 ? "s" : ""}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 8),
                        // Stats inline dans le hero
                        Row(
                          children: [
                            Expanded(child: _HeroStat(
                              icon: Icons.star_rounded,
                              color: AppColors.amber,
                              value: mentor.rating.toStringAsFixed(1),
                              label: 'Note',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.bolt_rounded,
                              color: AppColors.green,
                              value: '${mentor.compatibility} %',
                              label: 'Match',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.timeline_rounded,
                              color: AppColors.blueBright,
                              value: '${mentor.years}+',
                              label: 'Années',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.reviews_rounded,
                              color: AppColors.purple,
                              value: '${mentor.reviews}',
                              label: 'Avis',
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 18),
              const _SectionTitle('À propos'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _buildBio(mentor),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Domaines d\'expertise'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mentor.sectors.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.blueTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (mentor.companies.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(
                    'Entreprises (${mentor.companies.length})'),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CompaniesList(companies: mentor.companies),
                ),
              ],
              // Disponibilités : masquées tant que la demande n'est pas acceptée
              // Disponibilités : visibles uniquement après acceptation.
              // Profils statiques et non-acceptés → section masquée.
              Builder(builder: (context) {
                // Profil statique → pas de section disponibilités
                if (mentor.uid.isEmpty) return const SizedBox.shrink();

                final myRole = UserProfileController.profile.value.role;
                final needsAcceptance =
                    myRole == 'Entrepreneur' || myRole == 'Investisseur';
                // Masqué si la demande n'est pas encore acceptée
                final canSee = !needsAcceptance || _requestAccepted == true;
                if (!canSee) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    const _SectionTitle('Disponibilités'),
                    const SizedBox(height: 10),
                    _AvailabilityPreview(mentor: mentor),
                    const SizedBox(height: 28),
                  ],
                );
              }),
              Builder(
                builder: (context) {
                  final myRole = UserProfileController.profile.value.role;
                  // Affiché uniquement pour Entrepreneur et Investisseur
                  if (myRole != 'Entrepreneur' && myRole != 'Investisseur') {
                    return const SizedBox.shrink();
                  }
                  // Un investisseur ne voit ce bloc que sur le profil d'un Entrepreneur
                  if (myRole == 'Investisseur' && mentor.isInvestor) {
                    return const SizedBox.shrink();
                  }

                  // Profil statique (démo) → montrer le bouton de demande
                  // (uid vide = pas d'état d'acceptation à vérifier)
                  if (mentor.uid.isEmpty) {
                    final isInvestorViewing = myRole == 'Investisseur';
                    final isInvestorProfile = mentor.isInvestor;
                    final IconData actionIcon =
                        isInvestorViewing || isInvestorProfile
                            ? Icons.monetization_on_rounded
                            : Icons.handshake_rounded;
                    final String actionLabel = isInvestorViewing
                        ? 'Proposer un investissement'
                        : isInvestorProfile
                            ? 'Proposer un investissement'
                            : 'Envoyer une demande de mentorat';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SendRequestPage(mentor: mentor),
                            ),
                          ),
                          icon: Icon(actionIcon, size: 18),
                          label: Text(actionLabel),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.green,
                            side: const BorderSide(color: AppColors.green),
                          ),
                        ),
                      ),
                    );
                  }

                  // Chargement en cours → spinner
                  if (_requestAccepted == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Demande ACCEPTÉE → Message + Réserver une session
                  if (_requestAccepted!) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final myUid = AuthService.currentUid ??
                                    UserProfileController.profile.value.email;
                                final convId =
                                    InteractionsService.generateConversationId(
                                  myUid,
                                  mentor.uid.isNotEmpty
                                      ? mentor.uid
                                      : mentor.name,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      conversationId: convId,
                                      otherUserName: mentor.name,
                                      otherUserId: mentor.uid.isNotEmpty
                                          ? mentor.uid
                                          : mentor.name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18),
                              label: const Text('Message'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => _showBookingSheet(context),
                              icon: const Icon(Icons.calendar_month_rounded,
                                  size: 18),
                              label: const Text('Réserver une session'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Demande PAS encore acceptée → bouton d'action uniquement
                  final isInvestorViewing = myRole == 'Investisseur';
                  final isInvestorProfile = mentor.isInvestor;
                  final IconData actionIcon = isInvestorViewing || isInvestorProfile
                      ? Icons.monetization_on_rounded
                      : Icons.handshake_rounded;
                  final String actionLabel = isInvestorViewing
                      ? 'Proposer un investissement'
                      : isInvestorProfile
                          ? 'Proposer un investissement'
                          : 'Envoyer une demande de mentorat';

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SendRequestPage(mentor: mentor),
                          ),
                        ),
                        icon: Icon(actionIcon, size: 18),
                        label: Text(actionLabel),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: AppColors.green,
                          side: const BorderSide(color: AppColors.green),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InvestorBadgeBig extends StatelessWidget {
  const _InvestorBadgeBig();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 13, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Investisseur',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CisBadgeBig extends StatelessWidget {
  const _CisBadgeBig();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: AppColors.navyDeep),
          SizedBox(width: 4),
          Text(
            'CIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDeep,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.navyDeep,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _HeroStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.amber, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompaniesList extends StatelessWidget {
  final List<String> companies;
  const _CompaniesList({required this.companies});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: companies.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.amber.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.business_rounded,
                  size: 13, color: AppColors.amber),
              const SizedBox(width: 6),
              Text(
                c,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Feuille de réservation — 2 étapes : jour puis créneau horaire
// ─────────────────────────────────────────────────────────────────
class _BookingSheet extends StatefulWidget {
  final Mentor mentor;
  const _BookingSheet({required this.mentor});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const _dayEn = [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
  ];
  static const _dayFrShort = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
  static const _dayFrLong  = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
  static const _monthFr    = [
    'jan','fév','mar','avr','mai','juin','juil','août','sep','oct','nov','déc'
  ];
  static const _monthFrLong = [
    'janvier','février','mars','avril','mai','juin',
    'juillet','août','septembre','octobre','novembre','décembre'
  ];

  // 0 = choisir un jour, 1 = choisir un créneau
  int _step = 0;
  DateTime? _selectedDate;
  String?   _selectedTime;
  bool      _sending = false;

  /// Les 14 prochains jours à partir de demain.
  List<DateTime> get _next14 {
    final list = <DateTime>[];
    var d = DateTime.now().add(const Duration(days: 1));
    for (int i = 0; i < 14; i++) {
      list.add(DateTime(d.year, d.month, d.day));
      d = d.add(const Duration(days: 1));
    }
    return list;
  }

  String _dayEnName(DateTime d) => _dayEn[d.weekday - 1];

  bool _isAvailable(DateTime date, Availability avail) {
    final schedule = avail.schedule[_dayEnName(date)];
    return schedule?.isAvailable ?? false;
  }

  List<String> _slotsFor(DateTime date, Availability avail) {
    final schedule = avail.schedule[_dayEnName(date)];
    if (schedule == null || !schedule.isAvailable) return [];
    if (schedule.timeSlots.isEmpty) {
      return ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];
    }
    return schedule.timeSlots.map((ts) => ts.startTime).toList();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime d) =>
      '${_dayFrLong[d.weekday - 1]} ${d.day} ${_monthFrLong[d.month - 1]}';

  Future<void> _confirm() async {
    if (_selectedDate == null || _selectedTime == null) return;
    setState(() => _sending = true);

    final profile = UserProfileController.profile.value;
    final myUid   = AuthService.currentUid ?? '';
    final dateStr = _dateKey(_selectedDate!);

    try {
      final reqId = await InteractionsService.sendSessionRequest(
        fromUserId:   myUid,
        toUserId:     widget.mentor.uid,
        fromName:     profile.fullName,
        toName:       widget.mentor.name,
        message:      'Demande de session le $dateStr à $_selectedTime.',
        proposedDate: dateStr,
        proposedTime: _selectedTime!,
      );
      await NotificationService.notifyUser(
        uid:        widget.mentor.uid,
        title:      'Nouvelle demande de session',
        message:    '${profile.fullName} souhaite réserver une session le $dateStr à $_selectedTime.',
        type:       'session_request',
        requestId:  reqId,
        fromUserId: myUid,
        fromName:   profile.fullName,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande envoyée à ${widget.mentor.name.split(" ").first} ✅'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Availability?>(
      stream: InteractionsService.getAvailability(widget.mentor.uid),
      builder: (ctx, snap) {
        final avail = snap.data;
        final dates = _next14;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Poignée ──
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              // ── En-tête avec breadcrumb ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    if (_step == 1)
                      GestureDetector(
                        onTap: () => setState(() {
                          _step = 0;
                          _selectedTime = null;
                        }),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: AppColors.navy),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _step == 0 ? 'Choisir un jour' : 'Choisir un créneau',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navyDeep,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _step == 0
                                ? '${widget.mentor.name.split(" ").first} · 2 semaines max'
                                : _dateLabel(_selectedDate!),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Indicateur d'étape
                    Row(
                      children: List.generate(2, (i) => Container(
                        width: i == _step ? 16 : 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: i == _step ? AppColors.navy : AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else if (_step == 0)
                _buildStep0(avail, dates)
              else
                _buildStep1(avail),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ── Étape 1 : grille de jours ──────────────────────────────────
  Widget _buildStep0(Availability? avail, List<DateTime> dates) {
    final hasAnyAvailable = avail != null &&
        dates.any((d) => _isAvailable(d, avail));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasAnyAvailable && avail != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Ce mentor n\'a pas encore configuré ses disponibilités.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dates.map((date) {
                final available = avail != null && _isAvailable(date, avail);
                final dayShort  = _dayFrShort[date.weekday - 1];
                final month     = _monthFr[date.month - 1];

                return GestureDetector(
                  onTap: available
                      ? () => setState(() {
                            _selectedDate = date;
                            _step = 1;
                          })
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 54,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: available ? Colors.white : AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: available
                            ? AppColors.blue.withValues(alpha: 0.45)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayShort,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: available ? AppColors.muted : AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: available ? AppColors.navyDeep : AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          month,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: available ? AppColors.muted : AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: available ? AppColors.green : AppColors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ── Étape 2 : créneaux horaires ────────────────────────────────
  Widget _buildStep1(Availability? avail) {
    if (_selectedDate == null) return const SizedBox.shrink();
    final slots = avail != null ? _slotsFor(_selectedDate!, avail) : <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slots.isEmpty)
            const Text(
              'Aucun créneau disponible pour ce jour.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((t) {
                final selected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.navy : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.navy : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : AppColors.navyDeep,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (_selectedTime != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _confirm,
                icon: _sending
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text(
                  'CONFIRMER LA SESSION',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aperçu des disponibilités du mentor.
/// — Profil démo (uid vide) : créneaux illustratifs statiques.
/// — Membre Firebase (uid non vide) : données réelles en temps réel.
class _AvailabilityPreview extends StatelessWidget {
  final Mentor mentor;
  const _AvailabilityPreview({required this.mentor});

  static const _dayFr = <String, String>{
    'Monday': 'Lundi',
    'Tuesday': 'Mardi',
    'Wednesday': 'Mercredi',
    'Thursday': 'Jeudi',
    'Friday': 'Vendredi',
    'Saturday': 'Samedi',
    'Sunday': 'Dimanche',
  };

  static const _demoSlots = <(String, String)>[
    ('Lundi', '14h00'),
    ('Mardi', '10h00'),
    ('Mercredi', '15h00'),
    ('Jeudi', '11h00'),
    ('Vendredi', '16h00'),
  ];

  Widget _buildRow(List<(String, String)> slots, {required bool isDemo}) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = slots[i];
          return Container(
            width: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.$1.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.$2,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isDemo ? AppColors.subtle : AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDemo ? 'Exemple' : 'Dispo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDemo ? AppColors.subtle : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Profil démo : créneaux illustratifs
    if (mentor.uid.isEmpty) {
      return _buildRow(_demoSlots, isDemo: true);
    }
    // Membre Firebase : disponibilités réelles
    return StreamBuilder<Availability?>(
      stream: InteractionsService.getAvailability(mentor.uid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final avail = snap.data;
        if (avail == null || avail.schedule.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Disponibilités non encore configurées.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          );
        }
        final slots = avail.schedule.entries
            .where((e) => e.value.isAvailable)
            .map((e) => (
                  _dayFr[e.key] ?? e.key,
                  e.value.timeSlots.isEmpty
                      ? 'Dispo'
                      : e.value.timeSlots.first.startTime,
                ))
            .toList();
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Aucun créneau disponible pour le moment.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          );
        }
        return _buildRow(slots, isDemo: false);
      },
    );
  }
}

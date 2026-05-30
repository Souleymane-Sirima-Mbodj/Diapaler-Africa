import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_planning.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Agenda — sessions de mentorat planifiées.
// Sépare les sessions à venir et les sessions passées.
// ─────────────────────────────────────────────────────────────────

enum _Status { confirmed, pending, done }

/// Une session de mentorat planifiée avec un mentor.
class _Session {
  final Mentor mentor;
  final String topic;
  final String weekday;
  final String day;
  final String month;
  final String time;
  final String place;
  final _Status status;

  const _Session({
    required this.mentor,
    required this.topic,
    required this.weekday,
    required this.day,
    required this.month,
    required this.time,
    required this.place,
    required this.status,
  });

  bool get isPast => status == _Status.done;
}

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  /// Sessions de démonstration, basées sur les mentors du domaine Agro-industrie.
  static final List<_Session> _sessions = [
    _Session(
      mentor: const Mentor(
        initials: 'ID',
        name: 'Ibrahima Diop',
        title: 'PDG · Groupe Téranga Agri',
        city: 'Thiès',
        sectors: ['Agro-industrie'],
        companies: ['Groupe Téranga Agri', 'SénéMaïs SA'],
        rating: 4.8, reviews: 24, years: 12, compatibility: 95,
      ),
      topic: 'Accès aux financements DER/FJ pour l\'agriculture',
      weekday: 'Jeudi',
      day: '05',
      month: 'JUIN',
      time: '10:00 – 11:00',
      place: 'En ligne',
      status: _Status.confirmed,
    ),
    _Session(
      mentor: const Mentor(
        initials: 'AF',
        name: 'Abdoulaye Fall',
        title: 'Directeur · CNAAS Sénégal',
        city: 'Dakar',
        sectors: ['Agro-industrie', 'Agroécologie'],
        companies: ['CNAAS', 'Agri-Finance Sénégal'],
        rating: 4.7, reviews: 31, years: 18, compatibility: 92,
      ),
      topic: 'Structuration de mon projet agricole',
      weekday: 'Lundi',
      day: '09',
      month: 'JUIN',
      time: '14:00 – 15:00',
      place: 'Bureau · Dakar-Plateau',
      status: _Status.confirmed,
    ),
    _Session(
      mentor: const Mentor(
        initials: 'FD',
        name: 'Fatou Diallo',
        title: 'Fondatrice · AgriTech Sénégal',
        city: 'Saint-Louis',
        sectors: ['Agro-industrie', 'Tech & Digital'],
        companies: ['AgriTech Sénégal', 'Doolel Farm'],
        rating: 4.9, reviews: 18, years: 8, compatibility: 97,
      ),
      topic: 'Digitaliser ma chaîne de valeur agricole',
      weekday: 'Mercredi',
      day: '14',
      month: 'MAI',
      time: '11:00 – 12:00',
      place: 'En ligne',
      status: _Status.done,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final role = UserProfileController.profile.value.role;
    final upcoming = _sessions.where((s) => !s.isPast).toList();
    final past = _sessions.where((s) => s.isPast).toList();

    // Textes adaptés selon le rôle
    final String agendaTitle;
    final String summarySubtitle;
    final String emptyUpcoming;
    final String emptyPast;

    switch (role) {
      case 'Mentor':
        agendaTitle = 'Mon agenda';
        summarySubtitle = 'Tes sessions de mentorat avec tes mentorés.';
        emptyUpcoming = 'Aucune session planifiée. Définis tes disponibilités dans "Mon planning".';
        emptyPast = 'Tes sessions terminées apparaîtront ici.';
        break;
      case 'Investisseur':
        agendaTitle = 'Mes rendez-vous';
        summarySubtitle = 'Tes rendez-vous avec les entrepreneurs.';
        emptyUpcoming = 'Aucun rendez-vous planifié. Explore les pitchs pour contacter des entrepreneurs.';
        emptyPast = 'Tes rendez-vous passés apparaîtront ici.';
        break;
      default: // Entrepreneur
        agendaTitle = 'Mes sessions';
        summarySubtitle = 'Tes sessions de mentorat planifiées.';
        emptyUpcoming = 'Aucune session planifiée. Réserve une session depuis le profil d\'un mentor.';
        emptyPast = 'Tes sessions terminées apparaîtront ici.';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(agendaTitle),
        actions: [
          if (role == 'Mentor')
            IconButton(
              tooltip: 'Mon planning',
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SchedulePage()),
              ),
            ),
        ],
      ),
      body: ValueListenableBuilder<List<BookedSession>>(
        valueListenable: AgendaController.sessions,
        builder: (context, bookedSessions, _) {
          final totalUpcoming = upcoming.length + bookedSessions.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            children: [
              _SummaryCard(
                upcomingCount: totalUpcoming,
                subtitle: summarySubtitle,
              ),
              const SizedBox(height: 20),
              const _SectionLabel('À venir'),
              const SizedBox(height: 10),
              if (totalUpcoming == 0)
                _EmptyHint(emptyUpcoming)
              else ...[
                for (final s in bookedSessions) ...[
                  _BookedSessionCard(session: s),
                  const SizedBox(height: 10),
                ],
                for (final s in upcoming) ...[
                  _SessionCard(session: s),
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 12),
              const _SectionLabel('Passées'),
              const SizedBox(height: 10),
              if (past.isEmpty)
                _EmptyHint(emptyPast)
              else
                for (final s in past) ...[
                  _SessionCard(session: s),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }
}

/// Carte de résumé en haut de l'agenda.
class _SummaryCard extends StatelessWidget {
  final int upcomingCount;
  final String subtitle;
  const _SummaryCard({required this.upcomingCount, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_available_rounded,
                color: AppColors.amber, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upcomingCount > 0
                      ? '$upcomingCount rendez-vous à venir'
                      : 'Aucun rendez-vous à venir',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit titre de section.
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Message affiché quand une section est vide.
class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: AppColors.muted,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Carte représentant une session de mentorat.
class _SessionCard extends StatelessWidget {
  final _Session session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final past = s.isPast;
    final dateColor = past ? AppColors.muted : AppColors.navy;

    return HoverGlowCard(
      onTap: () => _showDetails(context, s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pastille de date.
              Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: dateColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.month,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.topic,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Avatar(
                          initials: s.mentor.initials,
                          size: 22,
                          background: AppColors.blue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.mentor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: s.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 15, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                '${s.weekday} · ${s.time}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
              const Spacer(),
              Icon(
                s.place == 'En ligne'
                    ? Icons.videocam_rounded
                    : Icons.place_outlined,
                size: 15,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  s.place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ouvre une feuille de détails pour la session.
  void _showDetails(BuildContext context, _Session s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Avatar(
                  initials: s.mentor.initials,
                  size: 46,
                  background: AppColors.navy,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.mentor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      Text(
                        s.mentor.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: s.status),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              s.topic,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              text: '${s.weekday} ${s.day} ${s.month}',
            ),
            const SizedBox(height: 8),
            _DetailRow(icon: Icons.schedule_rounded, text: s.time),
            const SizedBox(height: 8),
            _DetailRow(
              icon: s.place == 'En ligne'
                  ? Icons.videocam_rounded
                  : Icons.place_outlined,
              text: s.place,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne icône + texte utilisée dans la feuille de détails.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.blueTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.navy),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDeep,
          ),
        ),
      ],
    );
  }
}

/// Carte pour une session réservée dynamiquement (via page_detail_mentor).
class _BookedSessionCard extends StatelessWidget {
  final BookedSession session;
  const _BookedSessionCard({required this.session});

  Future<void> _cancelSession(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler la session ?'),
        content: Text(
          'Veux-tu annuler ta session avec ${session.mentorName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final profile = UserProfileController.profile.value;
    await AgendaController.cancel(
      userId: profile.email,
      userName: profile.fullName,
      session: session,
      reason: 'Annulation par l\'entrepreneur',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session annulée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = session;
    return HoverGlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.month,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session avec ${s.mentorName}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Avatar(
                          initials: s.mentorInitials,
                          size: 22,
                          background: AppColors.blue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.mentorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'En attente',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 15, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                '${s.weekday} · ${s.timeRange}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
              const Spacer(),
              const Icon(Icons.videocam_rounded, size: 15, color: AppColors.muted),
              const SizedBox(width: 5),
              const Text(
                'En ligne',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _cancelSession(context),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Annuler'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge coloré indiquant l'état d'une session.
class _StatusBadge extends StatelessWidget {
  final _Status status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      _Status.confirmed => (AppColors.green, 'Confirmée'),
      _Status.pending => (AppColors.amber, 'En attente'),
      _Status.done => (AppColors.subtle, 'Terminée'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

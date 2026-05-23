import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';

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

  /// Sessions de démonstration, basées sur les mentors de la plateforme.
  static final List<_Session> _sessions = [
    _Session(
      mentor: mentors[3], // Babacar Ngom
      topic: 'Revue de ton business plan',
      weekday: 'Jeudi',
      day: '28',
      month: 'MAI',
      time: '15:00 – 16:00',
      place: 'En ligne',
      status: _Status.confirmed,
    ),
    _Session(
      mentor: mentors[5], // Aminata Niane
      topic: 'Stratégie de lancement de la marketplace',
      weekday: 'Lundi',
      day: '01',
      month: 'JUIN',
      time: '10:00 – 11:00',
      place: 'En ligne',
      status: _Status.pending,
    ),
    _Session(
      mentor: mentors[0], // Anta Diama Kama
      topic: 'Positionnement et image de marque',
      weekday: 'Mercredi',
      day: '03',
      month: 'JUIN',
      time: '14:00 – 15:00',
      place: 'Bureau · Dakar-Plateau',
      status: _Status.confirmed,
    ),
    _Session(
      mentor: mentors[1], // Yérim Habib Sow
      topic: 'Premier échange découverte',
      weekday: 'Lundi',
      day: '12',
      month: 'MAI',
      time: '11:00 – 12:00',
      place: 'En ligne',
      status: _Status.done,
    ),
    _Session(
      mentor: mentors[4], // Mossane Diop
      topic: 'Cadrage des objectifs du projet',
      weekday: 'Jeudi',
      day: '08',
      month: 'MAI',
      time: '16:00 – 17:00',
      place: 'En ligne',
      status: _Status.done,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final upcoming = _sessions.where((s) => !s.isPast).toList();
    final past = _sessions.where((s) => s.isPast).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        children: [
          _SummaryCard(upcomingCount: upcoming.length),
          const SizedBox(height: 20),
          const _SectionLabel('À venir'),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            const _EmptyHint('Aucune session planifiée pour le moment.')
          else
            for (final s in upcoming) ...[
              _SessionCard(session: s),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 12),
          const _SectionLabel('Passées'),
          const SizedBox(height: 10),
          if (past.isEmpty)
            const _EmptyHint('Tes sessions terminées apparaîtront ici.')
          else
            for (final s in past) ...[
              _SessionCard(session: s),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

/// Carte de résumé en haut de l'agenda.
class _SummaryCard extends StatelessWidget {
  final int upcomingCount;
  const _SummaryCard({required this.upcomingCount});

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
                      ? '$upcomingCount session${upcomingCount > 1 ? "s" : ""} à venir'
                      : 'Aucune session à venir',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Retrouve ici tous tes rendez-vous de mentorat.',
                  style: TextStyle(
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

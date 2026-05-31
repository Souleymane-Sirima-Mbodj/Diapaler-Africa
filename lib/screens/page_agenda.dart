import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_planning.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Agenda — sessions de mentorat planifiées (Firebase only).
// ─────────────────────────────────────────────────────────────────

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserProfileController.profile.value.role;

    // Textes adaptés selon le rôle
    final String agendaTitle;
    final String summarySubtitle;
    final String emptyUpcoming;

    switch (role) {
      case 'Mentor':
        agendaTitle = 'Mon agenda';
        summarySubtitle = 'Tes sessions de mentorat avec tes mentorés.';
        emptyUpcoming = 'Aucune session planifiée. Définis tes disponibilités dans "Mon planning".';
        break;
      case 'Investisseur':
        agendaTitle = 'Mes rendez-vous';
        summarySubtitle = 'Tes rendez-vous avec les entrepreneurs.';
        emptyUpcoming = 'Aucun rendez-vous planifié. Explore les pitchs pour contacter des entrepreneurs.';
        break;
      default: // Entrepreneur
        agendaTitle = 'Mes sessions';
        summarySubtitle = 'Tes sessions de mentorat planifiées.';
        emptyUpcoming = 'Aucune session planifiée. Réserve une session depuis le profil d\'un mentor.';
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            children: [
              _SummaryCard(
                upcomingCount: bookedSessions.length,
                subtitle: summarySubtitle,
              ),
              const SizedBox(height: 20),
              const _SectionLabel('À venir'),
              const SizedBox(height: 10),
              if (bookedSessions.isEmpty)
                _EmptyHint(emptyUpcoming)
              else
                for (final s in bookedSessions) ...[
                  _BookedSessionCard(session: s),
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

/// Carte pour une session réservée via Firebase (via page_detail_mentor).
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


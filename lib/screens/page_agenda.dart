import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';

// ─────────────────────────────────────────────────────────────────
// Onglet Agenda — sessions de mentorat planifiées (100 % Firebase).
// Affiche uniquement les vrais RDV réservés via AgendaController.
// ─────────────────────────────────────────────────────────────────

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: ValueListenableBuilder<List<BookedSession>>(
        valueListenable: AgendaController.sessions,
        builder: (context, bookedSessions, _) {
          // Sépare sessions futures et passées selon la date planifiée.
          final now = DateTime.now();
          final upcoming = bookedSessions
              .where((s) => s.scheduledAt.isAfter(now))
              .toList();
          final past = bookedSessions
              .where((s) => !s.scheduledAt.isAfter(now))
              .toList();

          return ListView(
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
                  _BookedSessionCard(session: s),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 12),
              const _SectionLabel('Passées'),
              const SizedBox(height: 10),
              if (past.isEmpty)
                const _EmptyHint('Tes sessions terminées apparaîtront ici.')
              else
                for (final s in past) ...[
                  _BookedSessionCard(session: s, isPast: true),
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

/// Carte pour une session réservée dynamiquement (via page_detail_mentor).
class _BookedSessionCard extends StatefulWidget {
  final BookedSession session;
  /// Vrai si la session est dans le passé — affichage atténué.
  final bool isPast;
  const _BookedSessionCard({required this.session, this.isPast = false});

  @override
  State<_BookedSessionCard> createState() => _BookedSessionCardState();
}

class _BookedSessionCardState extends State<_BookedSessionCard> {
  bool _cancelling = false;

  Future<void> _confirmCancel() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _CancelDialog(mentorName: widget.session.mentorName),
    );
    if (reason == null || reason.trim().isEmpty) return;
    final uid = AuthService.currentUid;
    if (uid == null) return;
    final userName = UserProfileController.profile.value.fullName;
    setState(() => _cancelling = true);
    try {
      await AgendaController.cancel(
        userId: uid,
        userName: userName,
        session: widget.session,
        reason: reason.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous annulé. Notification envoyée.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'annulation : $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final cardColor = widget.isPast ? AppColors.muted : AppColors.navy;
    return Opacity(
      opacity: widget.isPast ? 0.60 : 1.0,
      child: HoverGlowCard(
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
                  color: cardColor,
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _cancelling ? null : _confirmCancel,
              icon: _cancelling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.red,
                      ),
                    )
                  : const Icon(Icons.event_busy_rounded, size: 16),
              label: const Text('Annuler le rendez-vous'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

/// Dialog qui demande un motif d'annulation et renvoie le texte saisi.
class _CancelDialog extends StatefulWidget {
  final String mentorName;
  const _CancelDialog({required this.mentorName});

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _ctrl = TextEditingController();
  bool _empty = true;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final next = _ctrl.text.trim().isEmpty;
      if (next != _empty) setState(() => _empty = next);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Annuler avec ${widget.mentorName} ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indique brièvement le motif. Une notification sera envoyée.',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            maxLength: 160,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex. Conflit d\'agenda, imprévu professionnel…',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Garder le RDV'),
        ),
        ElevatedButton(
          onPressed: _empty ? null : () => Navigator.of(context).pop(_ctrl.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}


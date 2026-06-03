import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
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
        builder: (context, bookedSessions, _) =>
            ValueListenableBuilder<List<MentorRequest>>(
          valueListenable: AgendaController.sessionRequests,
          builder: (context, sessionReqs, _) {
            final today = DateTime.now();
            final todayStr =
                '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

            final pending = sessionReqs
                .where((r) => r.status == RequestStatus.pending)
                .toList();
            final accepted = sessionReqs
                .where((r) => r.status == RequestStatus.accepted)
                .toList();
            final upcoming = accepted
                .where((r) => (r.proposedDate ?? '').compareTo(todayStr) >= 0)
                .toList();
            final finished = accepted
                .where((r) {
                  final d = r.proposedDate ?? '';
                  return d.isNotEmpty && d.compareTo(todayStr) < 0;
                })
                .toList();

            final upcomingCount = bookedSessions.length + upcoming.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                _SummaryCard(
                  upcomingCount: upcomingCount,
                  pendingCount: pending.length,
                  subtitle: summarySubtitle,
                ),
                // ── En attente ──────────────────────────────────
                if (pending.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('En attente'),
                  const SizedBox(height: 10),
                  for (final r in pending) ...[
                    _PendingSessionCard(request: r),
                    const SizedBox(height: 10),
                  ],
                ],
                // ── À venir ─────────────────────────────────────
                const SizedBox(height: 20),
                const _SectionLabel('À venir'),
                const SizedBox(height: 10),
                if (upcomingCount == 0)
                  _EmptyHint(emptyUpcoming)
                else ...[
                  for (final r in upcoming) ...[
                    _AcceptedSessionCard(request: r),
                    const SizedBox(height: 10),
                  ],
                  for (final s in bookedSessions) ...[
                    _BookedSessionCard(session: s),
                    const SizedBox(height: 10),
                  ],
                ],
                // ── Terminés ────────────────────────────────────
                if (finished.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Terminés'),
                  const SizedBox(height: 10),
                  for (final r in finished) ...[
                    _FinishedSessionCard(request: r),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Carte de résumé en haut de l'agenda.
class _SummaryCard extends StatelessWidget {
  final int upcomingCount;
  final int pendingCount;
  final String subtitle;
  const _SummaryCard({
    required this.upcomingCount,
    required this.pendingCount,
    required this.subtitle,
  });

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
                if (pendingCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$pendingCount en attente de confirmation',
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
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

// ─────────────────────────────────────────────────────────────────
// Carte pour une demande de session EN ATTENTE (mentorRequests pending)
// — Affiche Accept/Refus si le user est le destinataire (mentor),
//   ou Annuler si c'est l'expéditeur (entrepreneur).
// ─────────────────────────────────────────────────────────────────
class _PendingSessionCard extends StatelessWidget {
  final MentorRequest request;
  const _PendingSessionCard({required this.request});

  String get _myUid => AuthService.currentUid ?? '';

  bool get _isRecipient => request.toUserId == _myUid;

  String get _otherName =>
      request.fromUserId == _myUid ? request.toName : request.fromName;

  String get _day {
    final parts = (request.proposedDate ?? '').split('-');
    return parts.length >= 3 ? parts[2] : '—';
  }

  String get _month {
    final parts = (request.proposedDate ?? '').split('-');
    if (parts.length < 2) return '—';
    const months = ['JAN','FÉV','MAR','AVR','MAI','JUIN',
                    'JUIL','AOÛT','SEP','OCT','NOV','DÉC'];
    final m = int.tryParse(parts[1]) ?? 1;
    return months[(m - 1).clamp(0, 11)];
  }

  Future<void> _accept(BuildContext context) async {
    final profile = UserProfileController.profile.value;
    await InteractionsService.acceptSessionRequest(
      requestId: request.id,
      mentorName: profile.fullName,
      entrepreneurUid: request.fromUserId,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session acceptée — notification envoyée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Refuser la demande ?'),
        content: Text('Refuser la session avec ${request.fromName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, refuser'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final profile = UserProfileController.profile.value;
    await InteractionsService.rejectSessionRequest(
      requestId: request.id,
      mentorName: profile.fullName,
      entrepreneurUid: request.fromUserId,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande refusée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler la demande ?'),
        content: Text('Annuler la demande de session avec $_otherName ?'),
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
    await InteractionsService.cancelSessionRequest(request.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande annulée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.4)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _day,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _month,
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
                      'Session avec $_otherName',
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
                        const Icon(Icons.schedule_rounded,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          request.proposedTime ?? '—',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 10),
          if (_isRecipient)
            // Mentor reçoit → Accepter / Refuser
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(context),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _accept(context),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accepter'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            // Entrepreneur envoie → Annuler
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cancel(context),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Annuler la demande'),
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

// ─────────────────────────────────────────────────────────────────
// Carte pour une session ACCEPTÉE (mentorRequests accepted)
// ─────────────────────────────────────────────────────────────────
class _AcceptedSessionCard extends StatelessWidget {
  final MentorRequest request;
  const _AcceptedSessionCard({required this.request});

  String get _otherName {
    final myUid = UserProfileController.profile.value.email;
    return request.fromUserId == myUid ? request.toName : request.fromName;
  }

  String get _day {
    final parts = (request.proposedDate ?? '').split('-');
    return parts.length >= 3 ? parts[2] : '—';
  }

  String get _month {
    final parts = (request.proposedDate ?? '').split('-');
    if (parts.length < 2) return '—';
    const months = ['JAN','FÉV','MAR','AVR','MAI','JUIN',
                    'JUIL','AOÛT','SEP','OCT','NOV','DÉC'];
    final m = int.tryParse(parts[1]) ?? 1;
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
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
                      _day,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _month,
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
                      'Session avec $_otherName',
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
                        const Icon(Icons.schedule_rounded,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          request.proposedTime ?? '—',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Confirmé ✓',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.videocam_rounded,
                  size: 15, color: AppColors.muted),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte pour une session TERMINÉE (accepted + date passée)
// ─────────────────────────────────────────────────────────────────
class _FinishedSessionCard extends StatelessWidget {
  final MentorRequest request;
  const _FinishedSessionCard({required this.request});

  String get _otherName {
    final myUid = AuthService.currentUid ?? '';
    return request.fromUserId == myUid ? request.toName : request.fromName;
  }

  String get _day {
    final parts = (request.proposedDate ?? '').split('-');
    return parts.length >= 3 ? parts[2] : '—';
  }

  String get _month {
    final parts = (request.proposedDate ?? '').split('-');
    if (parts.length < 2) return '—';
    const months = ['JAN','FÉV','MAR','AVR','MAI','JUIN',
                    'JUIL','AOÛT','SEP','OCT','NOV','DÉC'];
    final m = int.tryParse(parts[1]) ?? 1;
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _day,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _month,
                  style: const TextStyle(
                    color: AppColors.muted,
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
                  'Session avec $_otherName',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: AppColors.subtle),
                    const SizedBox(width: 4),
                    Text(
                      request.proposedTime ?? '—',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subtle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Terminé ✓',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
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
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'À venir',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blue,
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


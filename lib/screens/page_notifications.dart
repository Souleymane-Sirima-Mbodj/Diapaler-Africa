

import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_interactions.dart';
import '../services/service_navigation.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import 'page_chat.dart';
import 'page_requests.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// Navigue vers l'écran pertinent selon le type de notification.
  void _handleNotifTap(BuildContext ctx, NotificationItem notif) {
    switch (notif.type) {
      case 'message':
        appTabIndex.value = 2; // onglet Messages
        Navigator.of(ctx).pop();
      case 'session_booked':
      case 'rdv_booked':
      case 'session_cancelled':
        appTabIndex.value = 3; // onglet Agenda
        Navigator.of(ctx).pop();
      case 'mentor_request':
        // Géré via les boutons inline — fallback si la notif est déjà lue
        Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const RequestsPage()),
        );
      case 'mentor_request_accepted':
      case 'mentor_request_rejected':
        // Reçu par l'entrepreneur (sa demande a été traitée) → onglet "Envoyées" (1)
        Navigator.of(ctx).push(
          MaterialPageRoute(
              builder: (_) => const RequestsPage(initialTab: 1)),
        );
      // investment_offer et session_request sont gérés inline — pas de navigation ici
      default:
        break;
    }
  }

  /// Accept une proposition d'investissement depuis la notification.
  Future<void> _acceptInvestment(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    try {
      await InteractionsService.acceptRequest(notif.requestId);

      // Investisseur : +1 opportunité active
      if (notif.fromUserId.isNotEmpty) {
        try {
          final investorSnap =
              await DatabaseService.readUserProfile(notif.fromUserId);
          if (investorSnap != null) {
            final updated = investorSnap.copyWith(
              mentorsActive: investorSnap.mentorsActive + 1,
            );
            await DatabaseService.updateUserProfile(notif.fromUserId, updated);
          }
        } catch (_) {}
      }

      // Entrepreneur (moi) : +1 investisseur actif
      final myUid = AuthService.currentUid;
      if (myUid != null) {
        final profile = UserProfileController.profile.value;
        final updated = profile.copyWith(
          mentorsActive: profile.mentorsActive + 1,
        );
        UserProfileController.update(updated);
        await DatabaseService.updateUserProfile(myUid, updated);
      }

      // Notifier l'investisseur
      if (notif.fromUserId.isNotEmpty) {
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Proposition acceptée 🎉',
          message: 'Votre proposition d\'investissement a été acceptée.',
          type: 'mentor_request_accepted',
          fromUserId: AuthService.currentUid ?? '',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      // Ouvrir le chat avec l'investisseur
      if (notif.fromUserId.isNotEmpty) {
        final myUid = AuthService.currentUid ?? '';
        final convId = InteractionsService.generateConversationId(myUid, notif.fromUserId);
        Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: convId,
            otherUserName: notif.fromName.isNotEmpty ? notif.fromName : 'Investisseur',
            otherUserId: notif.fromUserId,
          ),
        ));
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('✅ Proposition acceptée — conversation ouverte.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'acceptation.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  /// Refuse une proposition d'investissement depuis la notification.
  Future<void> _rejectInvestment(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    // Dialog pour saisir une raison
    String? reason;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Refuser la proposition'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Raison (optionnelle)'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                reason = ctrl.text.trim();
                Navigator.of(dCtx).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !ctx.mounted) return;
    try {
      await InteractionsService.rejectRequest(notif.requestId, reason: reason);
      if (notif.fromUserId.isNotEmpty) {
        final msg = reason != null && reason!.isNotEmpty
            ? 'Votre proposition a été refusée. Motif : $reason'
            : 'Votre proposition d\'investissement a été refusée.';
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Proposition refusée',
          message: msg,
          type: 'mentor_request_rejected',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Proposition refusée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Erreur lors du refus.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  /// Accept une demande de session (côté mentor).
  Future<void> _acceptSession(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    try {
      await InteractionsService.acceptRequest(notif.requestId);
      if (notif.fromUserId.isNotEmpty) {
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Session confirmée ✅',
          message: 'Votre demande de session a été acceptée.',
          type: 'session_booked',
          fromUserId: AuthService.currentUid ?? '',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Session acceptée — l\'entrepreneur a été notifié.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'acceptation.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  /// Refuse une demande de session (côté mentor) avec raison.
  Future<void> _rejectSession(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    String? reason;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Refuser la session'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Raison du refus'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                reason = ctrl.text.trim();
                Navigator.of(dCtx).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !ctx.mounted) return;
    try {
      await InteractionsService.rejectRequest(notif.requestId, reason: reason);
      if (notif.fromUserId.isNotEmpty) {
        final msg = reason != null && reason!.isNotEmpty
            ? 'Votre demande de session a été refusée. Motif : $reason'
            : 'Votre demande de session a été refusée.';
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Session refusée',
          message: msg,
          type: 'session_cancelled',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Session refusée.'), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Erreur lors du refus.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _acceptMentorRequest(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    try {
      await InteractionsService.acceptRequest(notif.requestId);
      final myUid = AuthService.currentUid;
      if (myUid != null) {
        final profile = UserProfileController.profile.value;
        final updated = profile.copyWith(mentorsActive: profile.mentorsActive + 1);
        UserProfileController.update(updated);
        await DatabaseService.updateUserProfile(myUid, updated);
      }
      if (notif.fromUserId.isNotEmpty) {
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Demande acceptée 🎉',
          message: 'Votre demande de mentorat a été acceptée.',
          type: 'mentor_request_accepted',
          fromUserId: AuthService.currentUid ?? '',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      if (notif.fromUserId.isNotEmpty) {
        final myUid2 = AuthService.currentUid ?? '';
        final convId = InteractionsService.generateConversationId(myUid2, notif.fromUserId);
        Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: convId,
            otherUserName: notif.fromName.isNotEmpty ? notif.fromName : 'Entrepreneur',
            otherUserId: notif.fromUserId,
          ),
        ));
      }
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Demande acceptée — conversation ouverte.'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Erreur lors de l\'acceptation.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _rejectMentorRequest(BuildContext ctx, NotificationItem notif) async {
    if (notif.requestId.isEmpty) return;
    String? reason;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Refuser la demande'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Raison (optionnelle)'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () { reason = ctrl.text.trim(); Navigator.of(dCtx).pop(true); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !ctx.mounted) return;
    try {
      await InteractionsService.rejectRequest(notif.requestId, reason: reason);
      if (notif.fromUserId.isNotEmpty) {
        final msg = reason != null && reason!.isNotEmpty
            ? 'Votre demande a été refusée. Motif : $reason'
            : 'Votre demande de mentorat a été refusée.';
        await NotificationService.notifyUser(
          uid: notif.fromUserId,
          title: 'Demande refusée',
          message: msg,
          type: 'mentor_request_rejected',
        );
      }
      if (!ctx.mounted) return;
      NotificationService.markAsRead(notif.id);
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Demande refusée.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Erreur lors du refus.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _buildInlineActions(BuildContext ctx, NotificationItem notif) {
    final isInvestment = notif.type == 'investment_offer';
    final isMentorRequest = notif.type == 'mentor_request';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Détails de session uniquement pour session_request
        if (!isInvestment && !isMentorRequest) ...[
          const SizedBox(height: 10),
          _SessionDetailCard(requestId: notif.requestId),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (isInvestment) {
                    _rejectInvestment(ctx, notif);
                  } else if (isMentorRequest) {
                    _rejectMentorRequest(ctx, notif);
                  } else {
                    _rejectSession(ctx, notif);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Refuser',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (isInvestment) {
                    _acceptInvestment(ctx, notif);
                  } else if (isMentorRequest) {
                    _acceptMentorRequest(ctx, notif);
                  } else {
                    _acceptSession(ctx, notif);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  isInvestment ? 'Accepter & Contacter' : 'Accepter',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        actions: [
          ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: NotificationService.notifications,
            builder: (context, notifs, _) {
              if (notifs.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Effacer les notifications ?'),
                      content: const Text(
                        'Toutes les notifications seront supprimées.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Effacer'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) NotificationService.clearAll();
                },
                child: const Text(
                  'Effacer tout',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: NotificationService.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 60,
                    color: AppColors.muted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Pas de notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tu recevras des notifications quand\ndes mises à jour importantes arrivent.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final showInlineActions =
                  notif.requestId.isNotEmpty &&
                  !notif.isRead &&
                  (notif.type == 'investment_offer' ||
                   notif.type == 'session_request' ||
                   notif.type == 'mentor_request');
              return Dismissible(
                key: ValueKey(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                    size: 26,
                  ),
                ),
                confirmDismiss: (_) async {
                  // Les notifs avec actions inline demandent confirmation
                  if (showInlineActions) {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text(
                          'Supprimer cette notification ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDeep,
                          ),
                        ),
                        content: const Text(
                          'Les boutons Accepter / Refuser ne seront plus accessibles depuis les notifications.',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Annuler',
                                style: TextStyle(color: AppColors.muted)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Supprimer',
                                style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ) ?? false;
                  }
                  return true;
                },
                onDismissed: (_) => NotificationService.deleteOne(notif.id),
                child: _NotificationTile(
                  notification: notif,
                  onTap: () {
                    NotificationService.markAsRead(notif.id);
                    _handleNotifTap(context, notif);
                  },
                  inlineActions: showInlineActions
                      ? _buildInlineActions(context, notif)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final Widget? inlineActions;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.inlineActions,
  });

  Color _getTypeColor() {
    switch (notification.type) {
      case 'mentor_request':
        return AppColors.roleMentor;
      case 'mentor_request_accepted':
        return AppColors.green;
      case 'mentor_request_rejected':
        return AppColors.red;
      case 'session_booked':
      case 'rdv_booked':
        return AppColors.blue;
      case 'session_cancelled':
        return AppColors.red;
      case 'investment_offer':
        return AppColors.roleInvestor;
      case 'message':
        return AppColors.blue;
      case 'success':
        return AppColors.green;
      default:
        return AppColors.amber;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'mentor_request':
        return Icons.school_rounded;
      case 'mentor_request_accepted':
        return Icons.check_circle_rounded;
      case 'mentor_request_rejected':
        return Icons.cancel_rounded;
      case 'session_booked':
      case 'rdv_booked':
        return Icons.event_available_rounded;
      case 'session_cancelled':
        return Icons.event_busy_rounded;
      case 'investment_offer':
        return Icons.trending_up_rounded;
      case 'message':
        return Icons.mail_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : _getTypeColor().withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : _getTypeColor().withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(),
                color: _getTypeColor(),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDeep,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getTypeColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (inlineActions != null) inlineActions!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte des détails de session (date, heure, objectif)
// ─────────────────────────────────────────────────────────────────
class _SessionDetailCard extends StatelessWidget {
  final String requestId;
  const _SessionDetailCard({required this.requestId});

  static const _monthFr = [
    'janvier','février','mars','avril','mai','juin',
    'juillet','août','septembre','octobre','novembre','décembre',
  ];
  static const _dayFrLong = [
    'Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche',
  ];

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '–';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final year  = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day   = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return dateStr;
    final dt = DateTime(year, month, day);
    return '${_dayFrLong[dt.weekday - 1]} $day ${_monthFr[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MentorRequest?>(
      future: InteractionsService.fetchRequest(requestId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 24,
            child: Center(
              child: SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final req = snap.data;
        if (req == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.blueTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                color: AppColors.blue,
                label: 'Date',
                value: _formatDate(req.proposedDate),
              ),
              if (req.proposedTime != null) ...[
                const SizedBox(height: 6),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  color: AppColors.blue,
                  label: 'Heure',
                  value: req.proposedTime!,
                ),
              ],
              if (req.sessionTheme != null &&
                  req.sessionTheme!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _DetailRow(
                  icon: Icons.flag_rounded,
                  color: AppColors.amber,
                  label: 'Objectif',
                  value: req.sessionTheme!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 7),
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDeep,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

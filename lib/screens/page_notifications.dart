import 'package:flutter/material.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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
                onPressed: () => NotificationService.clearAll(),
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
              return _NotificationTile(
                notification: notif,
                onTap: () =>
                    NotificationService.markAsRead(notif.id),
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

  const _NotificationTile({
    required this.notification,
    required this.onTap,
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
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}

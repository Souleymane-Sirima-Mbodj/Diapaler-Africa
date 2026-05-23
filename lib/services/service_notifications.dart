import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'mentor_request', 'investment_offer', 'message', etc.
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  static void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    notifications.value = [notification, ...notifications.value];
  }

  static void markAsRead(String id) {
    final list = notifications.value;
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index].isRead = true;
      notifications.value = [...list];
    }
  }

  static void clearAll() {
    notifications.value = [];
  }

  static int get unreadCount =>
      notifications.value.where((n) => !n.isRead).length;
}

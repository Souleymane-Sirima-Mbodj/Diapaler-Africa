import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'isRead': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: json['type'] as String,
        isRead: json['isRead'] as bool? ?? false,
      );
}

class NotificationService {
  static final _db = FirebaseDatabase.instance.ref();
  static String? _userId;

  static final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);

  static void init(String userId) {
    _userId = userId;
    _db.child('notifications/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        notifications.value = [];
        return;
      }
      final list = data.values
          .map<NotificationItem>(
              (v) => NotificationItem.fromJson(v as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifications.value = list;
    });
  }

  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    if (_userId != null) {
      await _db.child('notifications/$_userId/$id').set(item.toJson());
      // Le ValueNotifier est mis à jour par le listener Firebase en temps réel.
    } else {
      // Fallback mémoire si pas encore connecté.
      notifications.value = [item, ...notifications.value];
    }
  }

  static Future<void> markAsRead(String id) async {
    if (_userId != null) {
      await _db.child('notifications/$_userId/$id').update({'isRead': true});
    } else {
      final list = notifications.value;
      final index = list.indexWhere((n) => n.id == id);
      if (index != -1) {
        list[index].isRead = true;
        notifications.value = [...list];
      }
    }
  }

  static Future<void> clearAll() async {
    if (_userId != null) {
      await _db.child('notifications/$_userId').remove();
    }
    notifications.value = [];
  }

  static int get unreadCount =>
      notifications.value.where((n) => !n.isRead).length;
}

import 'package:flutter/foundation.dart';

enum RequestStatus { pending, accepted, rejected, cancelled }

enum AvailabilityType { available, unavailable }

@immutable
class TimeSlot {
  final int startHour; // 0-23
  final int startMinute; // 0-59
  final int endHour;
  final int endMinute;

  const TimeSlot({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  String get startTime => '${'$startHour'.padLeft(2, '0')}:${'$startMinute'.padLeft(2, '0')}';
  String get endTime => '${'$endHour'.padLeft(2, '0')}:${'$endMinute'.padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
  };

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    startHour: json['startHour'] as int,
    startMinute: json['startMinute'] as int,
    endHour: json['endHour'] as int,
    endMinute: json['endMinute'] as int,
  );
}

@immutable
class DaySchedule {
  final String day; // 'Monday', 'Tuesday', etc.
  final bool isAvailable;
  final List<TimeSlot> timeSlots; // Empty if all day

  const DaySchedule({
    required this.day,
    required this.isAvailable,
    required this.timeSlots,
  });

  Map<String, dynamic> toJson() => {
    'day': day,
    'isAvailable': isAvailable,
    'timeSlots': timeSlots.map((ts) => ts.toJson()).toList(),
  };

  factory DaySchedule.fromJson(Map<String, dynamic> json) => DaySchedule(
    day: json['day'] as String,
    isAvailable: json['isAvailable'] as bool,
    timeSlots: (json['timeSlots'] as List?)
        ?.map((ts) => TimeSlot.fromJson(ts as Map<String, dynamic>))
        .toList() ?? [],
  );
}

@immutable
class Availability {
  final String userId;
  final Map<String, DaySchedule> schedule; // Key: day name
  final DateTime lastUpdated;

  const Availability({
    required this.userId,
    required this.schedule,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'schedule': schedule.map((k, v) => MapEntry(k, v.toJson())),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    userId: json['userId'] as String,
    schedule: (json['schedule'] as Map?)?.map((k, v) =>
        MapEntry(k as String, DaySchedule.fromJson(v as Map<String, dynamic>))) ?? {},
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );

  static Availability empty(String userId) => Availability(
    userId: userId,
    schedule: {
      'Monday': DaySchedule(day: 'Monday', isAvailable: true, timeSlots: []),
      'Tuesday': DaySchedule(day: 'Tuesday', isAvailable: true, timeSlots: []),
      'Wednesday': DaySchedule(day: 'Wednesday', isAvailable: true, timeSlots: []),
      'Thursday': DaySchedule(day: 'Thursday', isAvailable: true, timeSlots: []),
      'Friday': DaySchedule(day: 'Friday', isAvailable: true, timeSlots: []),
      'Saturday': DaySchedule(day: 'Saturday', isAvailable: false, timeSlots: []),
      'Sunday': DaySchedule(day: 'Sunday', isAvailable: false, timeSlots: []),
    },
    lastUpdated: DateTime.now(),
  );
}

@immutable
class MentorRequest {
  final String id;
  final String fromUserId; // Entrepreneur
  final String toUserId; // Mentor or Investor
  final String fromName;
  final String toName;
  final String message;
  final DateTime createdAt;
  final RequestStatus status;
  final String? respondedAt;

  const MentorRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromName,
    required this.toName,
    required this.message,
    required this.createdAt,
    required this.status,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'fromName': fromName,
    'toName': toName,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'respondedAt': respondedAt,
  };

  factory MentorRequest.fromJson(Map<String, dynamic> json) => MentorRequest(
    id: json['id'] as String,
    fromUserId: json['fromUserId'] as String,
    toUserId: json['toUserId'] as String,
    fromName: json['fromName'] as String,
    toName: json['toName'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: RequestStatus.values.byName(json['status'] as String),
    respondedAt: json['respondedAt'] as String?,
  );
}

@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'recipientId': recipientId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    recipientId: json['recipientId'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isRead: json['isRead'] as bool,
  );
}

@immutable
class Conversation {
  final String id; // Combined userId1-userId2 (sorted)
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user1Id': user1Id,
    'user2Id': user2Id,
    'user1Name': user1Name,
    'user2Name': user2Name,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    user1Id: json['user1Id'] as String,
    user2Id: json['user2Id'] as String,
    user1Name: json['user1Name'] as String,
    user2Name: json['user2Name'] as String,
    lastMessage: json['lastMessage'] as String,
    lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
    unreadCount: json['unreadCount'] as int? ?? 0,
  );
}

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
        ?.map((ts) => TimeSlot.fromJson(Map<String, dynamic>.from(ts as Map)))
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
    userId: json['userId']?.toString() ?? '',
    schedule: (json['schedule'] as Map?)?.map((k, v) =>
        MapEntry(k.toString(), DaySchedule.fromJson(Map<String, dynamic>.from(v as Map)))) ?? {},
    lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
  );

  static Availability empty(String userId) => Availability(
    userId: userId,
    schedule: const {
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
  /// Type de la demande : 'mentor', 'investment' ou 'session'.
  final String type;
  /// Date proposée pour une session (format 'YYYY-MM-DD').
  final String? proposedDate;
  /// Heure proposée pour une session (format 'HH:mm').
  final String? proposedTime;
  /// Raison de refus (optionnelle, renseignée lors d'un rejet).
  final String? rejectionReason;
  /// Thème / objectif de la session (renseigné par l'entrepreneur lors de la réservation).
  final String? sessionTheme;
  /// Motif d'annulation d'une session confirmée.
  final String? cancellationReason;

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
    this.type = 'mentor',
    this.proposedDate,
    this.proposedTime,
    this.rejectionReason,
    this.sessionTheme,
    this.cancellationReason,
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
    'type': type,
    if (proposedDate != null) 'proposedDate': proposedDate,
    if (proposedTime != null) 'proposedTime': proposedTime,
    if (rejectionReason != null) 'rejectionReason': rejectionReason,
    if (sessionTheme != null) 'sessionTheme': sessionTheme,
    if (cancellationReason != null) 'cancellationReason': cancellationReason,
  };

  factory MentorRequest.fromJson(Map<String, dynamic> json) => MentorRequest(
    id: json['id']?.toString() ?? '',
    fromUserId: json['fromUserId']?.toString() ?? '',
    toUserId: json['toUserId']?.toString() ?? '',
    fromName: json['fromName']?.toString() ?? '',
    toName: json['toName']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    status: RequestStatus.values.byName(json['status']?.toString() ?? 'pending'),
    respondedAt: json['respondedAt']?.toString(),
    type: json['type']?.toString() ?? 'mentor',
    proposedDate: json['proposedDate']?.toString(),
    proposedTime: json['proposedTime']?.toString(),
    rejectionReason: json['rejectionReason']?.toString(),
    sessionTheme: json['sessionTheme']?.toString(),
    cancellationReason: json['cancellationReason']?.toString(),
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
    id: json['id']?.toString() ?? '',
    senderId: json['senderId']?.toString() ?? '',
    senderName: json['senderName']?.toString() ?? '',
    recipientId: json['recipientId']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    isRead: json['isRead'] as bool? ?? false,
  );
}

/// Avis laissé par un utilisateur sur un autre (mentor, investisseur ou entrepreneur).
@immutable
class Review {
  final String id;
  final String fromUid;
  final String fromName;
  final String text;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromUid': fromUid,
    'fromName': fromName,
    'text': text,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id']?.toString() ?? '',
    fromUid: json['fromUid']?.toString() ?? '',
    fromName: json['fromName']?.toString() ?? 'Utilisateur',
    text: json['text']?.toString() ?? '',
    createdAt: json['createdAt'] is num
        ? DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as num).toInt())
        : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
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
  /// Identifiant de l'expéditeur du dernier message, pour éviter de
  /// comptabiliser ses propres messages comme "non lus".
  final String lastSenderId;

  const Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.lastSenderId = '',
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
    'lastSenderId': lastSenderId,
  };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id']?.toString() ?? '',
    user1Id: json['user1Id']?.toString() ?? '',
    user2Id: json['user2Id']?.toString() ?? '',
    user1Name: json['user1Name']?.toString() ?? '',
    user2Name: json['user2Name']?.toString() ?? '',
    lastMessage: json['lastMessage']?.toString() ?? '',
    lastMessageTime: DateTime.tryParse(json['lastMessageTime']?.toString() ?? '') ?? DateTime.now(),
    unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    lastSenderId: json['lastSenderId']?.toString() ?? '',
  );
}

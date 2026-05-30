import 'package:firebase_database/firebase_database.dart';
import '../data/interactions.dart';

class InteractionsService {
  static final _db = FirebaseDatabase.instance.ref();

  // ────── MENTOR REQUESTS ──────

  static Future<void> sendMentorRequest({
    required String fromUserId,
    required String toUserId,
    required String fromName,
    required String toName,
    required String message,
    String type = 'mentor',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final request = MentorRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      fromName: fromName,
      toName: toName,
      message: message,
      createdAt: DateTime.now(),
      status: RequestStatus.pending,
      type: type,
    );
    await _db.child('mentorRequests/$id').set(request.toJson());
  }

  static Stream<List<MentorRequest>> getReceivedRequests(String userId) {
    return _db.child('mentorRequests').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map && v['toUserId'] == userId)
          .map<MentorRequest>((v) => MentorRequest.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  static Future<void> acceptRequest(String requestId) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.accepted.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> rejectRequest(String requestId) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.rejected.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
  }

  // ────── AVAILABILITY ──────

  static Stream<Availability?> getAvailability(String userId) {
    return _db.child('availability/$userId').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return null;
      return Availability.fromJson(Map<String, dynamic>.from(data));
    });
  }

  static Future<void> updateAvailability(Availability availability) async {
    await _db.child('availability/${availability.userId}').set(availability.toJson());
  }

  // ────── CHAT MESSAGES ──────

  static Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String text,
  }) async {
    final msgId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final message = ChatMessage(
      id: msgId,
      senderId: senderId,
      senderName: senderName,
      recipientId: recipientId,
      text: text,
      timestamp: now,
      isRead: false,
    );
    await _db.child('messages/$conversationId/$msgId').set(message.toJson());

    // Sync conversation list so both users see the thread.
    final ids = [senderId, recipientId]..sort();
    await createOrUpdateConversation(Conversation(
      id: conversationId,
      user1Id: ids[0],
      user2Id: ids[1],
      user1Name: ids[0] == senderId ? senderName : recipientName,
      user2Name: ids[0] == senderId ? recipientName : senderName,
      lastMessage: text,
      lastMessageTime: now,
      unreadCount: 1,
      lastSenderId: senderId,
    ));
  }

  static Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _db.child('messages/$conversationId').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .map<ChatMessage>((v) => ChatMessage.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Future<void> markMessageAsRead(String conversationId, String messageId) async {
    await _db.child('messages/$conversationId/$messageId').update({'isRead': true});
  }

  // ────── CONVERSATIONS ──────

  static String generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids
        .join('--')
        .replaceAll(RegExp(r'[.#\$\[\]/\s@]'), '_');
  }

  static Stream<List<Conversation>> getConversations(String userId) {
    return _db.child('conversations').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map && (v['user1Id'] == userId || v['user2Id'] == userId))
          .map<Conversation>((v) => Conversation.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }

  static Future<void> createOrUpdateConversation(Conversation conversation) async {
    await _db.child('conversations/${conversation.id}').set(conversation.toJson());
  }

  static Future<void> markConversationAsRead(String conversationId) async {
    await _db
        .child('conversations/$conversationId')
        .update({'unreadCount': 0});
  }
}

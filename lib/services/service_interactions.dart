import 'package:firebase_database/firebase_database.dart';
import '../data/interactions.dart';
import 'service_notifications.dart';

class InteractionsService {
  static final _db = FirebaseDatabase.instance.ref();

  // Broadcast streams partagés pour éviter l'erreur "Bad state: Stream has
  // already been listened to" quand TabBarView / IndexedStack monte plusieurs
  // StreamBuilder qui écoutent le même nœud Firebase simultanément.
  static final Stream<DatabaseEvent> _mentorRequestsEvents =
      FirebaseDatabase.instance.ref('mentorRequests').onValue.asBroadcastStream();
  static final Stream<DatabaseEvent> _conversationsEvents =
      FirebaseDatabase.instance.ref('conversations').onValue.asBroadcastStream();

  /// Expose le stream broadcast mentorRequests pour les pages qui le lisent
  /// directement (ex. onglet Contacts de MessagesPage).
  static Stream<DatabaseEvent> get mentorRequestsEvents => _mentorRequestsEvents;

  // ────── MENTOR REQUESTS ──────

  /// Retourne `true` si une demande en attente existe déjà entre ces deux utilisateurs.
  static Future<bool> hasPendingRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    final snap = await _db
        .child('mentorRequests')
        .orderByChild('fromUserId')
        .equalTo(fromUserId)
        .get();
    if (!snap.exists || snap.value == null) return false;
    final data = Map<String, dynamic>.from(snap.value as Map);
    return data.values.any((v) {
      final m = Map<String, dynamic>.from(v as Map);
      return m['toUserId'] == toUserId && m['status'] == 'pending';
    });
  }

  /// Envoie une demande et retourne son ID Firebase.
  static Future<String> sendMentorRequest({
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
    return id;
  }

  static Stream<List<MentorRequest>> getReceivedRequests(String userId) {
    return _mentorRequestsEvents.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map && v['toUserId'] == userId)
          .map<MentorRequest>((v) => MentorRequest.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Retourne en temps réel les demandes envoyées par [userId].
  static Stream<List<MentorRequest>> getSentRequests(String userId) {
    return _mentorRequestsEvents.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .where((v) => v is Map && v['fromUserId'] == userId)
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

  static Future<void> rejectRequest(String requestId, {String? reason}) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.rejected.name,
      'respondedAt': DateTime.now().toIso8601String(),
      if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
    });
  }

  /// Annule une relation acceptée (mentorat ou investissement) et décrémente
  /// le compteur [mentorsActive] des deux parties dans Firebase.
  static Future<void> cancelRequest({
    required String requestId,
    required String fromUserId,
    required String toUserId,
  }) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': 'cancelled',
      'cancelledAt': DateTime.now().toIso8601String(),
    });
    await Future.wait([
      _decrementMentorsActive(fromUserId),
      _decrementMentorsActive(toUserId),
    ]);
  }

  /// Annule TOUTES les relations acceptées entre deux utilisateurs (mentor + investment).
  static Future<void> cancelAllRequestsWith({
    required String myUid,
    required String otherUid,
  }) async {
    final snap = await _db.child('mentorRequests').get();
    if (snap.value == null) return;
    final data = Map<String, dynamic>.from(snap.value as Map);
    final futures = <Future>[];
    for (final entry in data.entries) {
      final m = Map<String, dynamic>.from(entry.value as Map);
      if (m['status'] != 'accepted') continue;
      final from = m['fromUserId']?.toString() ?? '';
      final to = m['toUserId']?.toString() ?? '';
      if ((from == myUid && to == otherUid) || (from == otherUid && to == myUid)) {
        futures.add(_db.child('mentorRequests/${entry.key}').update({
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
        }));
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
      await Future.wait([
        _decrementMentorsActive(myUid),
        _decrementMentorsActive(otherUid),
      ]);
    }
  }

  static Future<void> _decrementMentorsActive(String uid) async {
    try {
      final snap = await _db.child('users/$uid/mentorsActive').get();
      final current = (snap.value as num?)?.toInt() ?? 0;
      if (current > 0) {
        await _db.child('users/$uid').update({'mentorsActive': current - 1});
      }
    } catch (_) {}
  }

  /// Envoie une demande de session au mentor/investisseur avec date et heure proposées.
  static Future<String> sendSessionRequest({
    required String fromUserId,
    required String toUserId,
    required String fromName,
    required String toName,
    required String message,
    required String proposedDate,
    required String proposedTime,
    String? sessionTheme,
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
      type: 'session',
      proposedDate: proposedDate,
      proposedTime: proposedTime,
      sessionTheme: sessionTheme,
    );
    await _db.child('mentorRequests/$id').set(request.toJson());
    return id;
  }

  /// Accepte une demande de session et notifie l'entrepreneur.
  static Future<void> acceptSessionRequest({
    required String requestId,
    required String mentorName,
    required String entrepreneurUid,
  }) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.accepted.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
    await NotificationService.notifyUser(
      uid: entrepreneurUid,
      title: 'Session confirmée ✓',
      message: '$mentorName a accepté ta demande de session.',
      type: 'session_accepted',
    );
  }

  /// Refuse une demande de session et notifie l'entrepreneur.
  static Future<void> rejectSessionRequest({
    required String requestId,
    required String mentorName,
    required String entrepreneurUid,
  }) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.rejected.name,
      'respondedAt': DateTime.now().toIso8601String(),
    });
    await NotificationService.notifyUser(
      uid: entrepreneurUid,
      title: 'Session refusée',
      message: '$mentorName n\'a pas pu accepter ta demande de session.',
      type: 'session_rejected',
    );
  }

  /// Récupère une demande (mentor, session, investissement) par son ID Firebase.
  /// Retourne null si introuvable ou en cas d'erreur.
  static Future<MentorRequest?> fetchRequest(String requestId) async {
    if (requestId.isEmpty) return null;
    try {
      final snap = await _db.child('mentorRequests/$requestId').get();
      if (!snap.exists || snap.value == null) return null;
      return MentorRequest.fromJson(
          Map<String, dynamic>.from(snap.value as Map));
    } catch (_) {
      return null;
    }
  }

  /// Annule une session CONFIRMÉE avec un motif justificatif, notifie l'autre partie.
  static Future<void> cancelConfirmedSession({
    required String requestId,
    required String cancellerName,
    required String otherUid,
    required String reason,
  }) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': RequestStatus.cancelled.name,
      'cancellationReason': reason,
      'respondedAt': DateTime.now().toIso8601String(),
    });
    await NotificationService.notifyUser(
      uid: otherUid,
      title: 'Session annulée',
      message: '$cancellerName a annulé la session — motif : $reason',
      type: 'session_cancelled',
    );
  }

  /// Annule une demande de session en attente (status → 'cancelled').
  static Future<void> cancelSessionRequest(String requestId) async {
    await _db.child('mentorRequests/$requestId').update({
      'status': 'cancelled',
      'cancelledAt': DateTime.now().toIso8601String(),
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
    return _conversationsEvents.map((event) {
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

  /// Supprime un message d'une conversation.
  static Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _db.child('messages/$conversationId/$messageId').remove();
  }

  // ────── REVIEWS ──────

  /// Publie un avis sur [toUid]. Nœud Firebase : `reviews/{toUid}/{id}`.
  /// Notifie automatiquement le destinataire.
  static Future<void> addReview({
    required String toUid,
    required String fromUid,
    required String fromName,
    required String text,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.child('reviews/$toUid/$id').set({
      'id': id,
      'fromUid': fromUid,
      'fromName': fromName,
      'text': text,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    // Notification non critique : ne pas bloquer si elle échoue
    try {
      await NotificationService.notifyUser(
        uid: toUid,
        title: 'Nouvel avis reçu 💬',
        message: '$fromName a laissé un avis sur votre profil.',
        type: 'new_review',
      );
    } catch (_) {}
  }

  /// Écoute en temps réel tous les avis laissés sur [targetUid],
  /// triés du plus récent au plus ancien.
  static Stream<List<Review>> getReviews(String targetUid) {
    return _db.child('reviews/$targetUid').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <Review>[];
      return data.values
          .map<Review>((v) =>
              Review.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // ────── RATINGS ──────

  /// Enregistre (ou met à jour) la note 1–5 de [fromUid] sur [toUid].
  /// Nœud Firebase : `ratings/{toUid}/{fromUid}` → entier 1-5.
  /// Un utilisateur ne peut laisser qu'une seule note par profil (écrasement).
  /// Notifie le destinataire uniquement lors d'une première note (pas lors d'une mise à jour).
  static Future<void> setRating({
    required String toUid,
    required String fromUid,
    required int value,
    String fromName = '',
  }) async {
    assert(value >= 1 && value <= 5, 'La note doit être comprise entre 1 et 5');
    final isNew = !(await _db.child('ratings/$toUid/$fromUid').get()).exists;
    await _db.child('ratings/$toUid/$fromUid').set(value);
    // Notification non critique : ne pas bloquer si elle échoue
    if (isNew && fromName.isNotEmpty) {
      try {
        await NotificationService.notifyUser(
          uid: toUid,
          title: 'Nouvelle note reçue ⭐',
          message: '$fromName vous a attribué $value étoile${value > 1 ? 's' : ''}.',
          type: 'new_rating',
        );
      } catch (_) {}
    }
  }

  /// Écoute en temps réel toutes les notes laissées sur [targetUid].
  /// Retourne une Map { fromUid → valeur (1–5) }.
  static Stream<Map<String, int>> getRatings(String targetUid) {
    return _db.child('ratings/$targetUid').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <String, int>{};
      return {
        for (final e in data.entries)
          e.key.toString(): (e.value as num?)?.toInt() ?? 0,
      };
    });
  }
}

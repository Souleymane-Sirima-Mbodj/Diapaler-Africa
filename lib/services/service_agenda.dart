import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'service_notifications.dart';

class BookedSession {
  final String id;
  final String mentorName;
  final String mentorInitials;
  final DateTime scheduledAt;

  /// UID Firebase de l'autre partie (mentor/investisseur si l'entrepreneur a
  /// réservé, ou inversement). Permet de lui envoyer une notification croisée
  /// lors d'une annulation. Reste vide quand l'autre partie n'a pas de
  /// compte (mentor de la liste statique [donnees_mentors.dart]).
  final String otherUid;

  const BookedSession({
    required this.id,
    required this.mentorName,
    required this.mentorInitials,
    required this.scheduledAt,
    this.otherUid = '',
  });

  static const _weekdays = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];
  static const _months = [
    'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUIN',
    'JUIL', 'AOÛT', 'SEP', 'OCT', 'NOV', 'DÉC',
  ];

  String get weekday => _weekdays[scheduledAt.weekday - 1];
  String get day => scheduledAt.day.toString().padLeft(2, '0');
  String get month => _months[scheduledAt.month - 1];
  String get timeRange {
    final h = scheduledAt.hour.toString().padLeft(2, '0');
    final hEnd = (scheduledAt.hour + 1).toString().padLeft(2, '0');
    return '$h:00 – $hEnd:00';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mentorName': mentorName,
    'mentorInitials': mentorInitials,
    'scheduledAt': scheduledAt.toIso8601String(),
    'otherUid': otherUid,
  };

  factory BookedSession.fromJson(Map<String, dynamic> json) => BookedSession(
    id: json['id']?.toString() ?? '',
    mentorName: json['mentorName']?.toString() ?? '',
    mentorInitials: json['mentorInitials']?.toString() ?? '?',
    scheduledAt: DateTime.tryParse(json['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
    otherUid: json['otherUid']?.toString() ?? '',
  );
}

class AgendaController {
  AgendaController._();

  static final _db = FirebaseDatabase.instance.ref();
  static final sessions = ValueNotifier<List<BookedSession>>([]);

  static Future<void> load(String userId) async {
    _db.child('bookedSessions/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        sessions.value = [];
        return;
      }
      try {
        final list = data.values
            .map<BookedSession>(
                (v) => BookedSession.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        sessions.value = list;
      } catch (_) {
        sessions.value = [];
      }
    }, onError: (_) => sessions.value = []);
  }

  static Future<void> add(String userId, BookedSession session) async {
    await _db.child('bookedSessions/$userId/${session.id}').set(session.toJson());
    // Le ValueNotifier est mis à jour par le listener Firebase en temps réel.
  }

  /// Réserve un RDV bilatéral : écrit la session dans les agendas des deux
  /// parties, avec un libellé miroir (chacun voit l'autre comme "other").
  /// Si [otherUid] est vide (mentor statique de demo), écrit uniquement côté
  /// demandeur — comportement équivalent à [add].
  static Future<void> bookBilateral({
    required String requesterUid,
    required String requesterName,
    required String requesterInitials,
    required String otherUid,
    required String otherName,
    required String otherInitials,
    required DateTime scheduledAt,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    // Côté demandeur : "l'autre" c'est le mentor/investisseur ciblé.
    final requesterSession = BookedSession(
      id: id,
      mentorName: otherName,
      mentorInitials: otherInitials,
      scheduledAt: scheduledAt,
      otherUid: otherUid,
    );
    await _db.child('bookedSessions/$requesterUid/$id').set(requesterSession.toJson());

    if (otherUid.isEmpty) return; // Mentor statique : pas de miroir.

    // Côté autre partie : "l'autre" c'est le demandeur.
    final otherSession = BookedSession(
      id: id,
      mentorName: requesterName,
      mentorInitials: requesterInitials,
      scheduledAt: scheduledAt,
      otherUid: requesterUid,
    );
    await _db.child('bookedSessions/$otherUid/$id').set(otherSession.toJson());

    // Notification au mentor/investisseur de la nouvelle réservation.
    await NotificationService.notifyUser(
      uid: otherUid,
      title: 'Nouveau rendez-vous',
      message:
          '$requesterName a réservé une session avec toi le ${_formatDate(scheduledAt)}.',
      type: 'session_booked',
    );
  }

  /// Annule une session : la retire de Firebase chez les deux parties et
  /// envoie une notification au demandeur (récap) ainsi qu'à l'autre partie
  /// (si son UID est connu).
  static Future<void> cancel({
    required String userId,
    required String userName,
    required BookedSession session,
    required String reason,
  }) async {
    // Suppression côté annulant.
    await _db.child('bookedSessions/$userId/${session.id}').remove();
    // Suppression côté autre partie si elle a un compte.
    if (session.otherUid.isNotEmpty) {
      await _db.child('bookedSessions/${session.otherUid}/${session.id}').remove();
    }
    // Notif côté annulant : récap de son action.
    await NotificationService.addNotification(
      title: 'Rendez-vous annulé',
      message:
          'Session avec ${session.mentorName} annulée — motif : $reason',
      type: 'session_cancelled',
    );
    // Notif croisée : avertit l'autre partie s'il a un compte (UID connu).
    await NotificationService.notifyUser(
      uid: session.otherUid,
      title: 'Rendez-vous annulé',
      message:
          '$userName a annulé votre session — motif : $reason',
      type: 'session_cancelled',
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${d.day} ${months[d.month - 1]} à ${d.hour.toString().padLeft(2, '0')}h';
  }
}

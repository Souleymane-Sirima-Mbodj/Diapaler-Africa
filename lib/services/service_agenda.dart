import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class BookedSession {
  final String id;
  final String mentorName;
  final String mentorInitials;
  final DateTime scheduledAt;

  const BookedSession({
    required this.id,
    required this.mentorName,
    required this.mentorInitials,
    required this.scheduledAt,
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
  };

  factory BookedSession.fromJson(Map<String, dynamic> json) => BookedSession(
    id: json['id'] as String,
    mentorName: json['mentorName'] as String,
    mentorInitials: json['mentorInitials'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
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
      final list = data.values
          .map<BookedSession>(
              (v) => BookedSession.fromJson(v as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      sessions.value = list;
    });
  }

  static Future<void> add(String userId, BookedSession session) async {
    await _db.child('bookedSessions/$userId/${session.id}').set(session.toJson());
    // Le ValueNotifier est mis à jour par le listener Firebase en temps réel.
  }
}

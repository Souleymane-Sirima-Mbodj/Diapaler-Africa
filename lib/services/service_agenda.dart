import 'package:flutter/foundation.dart';

class BookedSession {
  final String mentorName;
  final String mentorInitials;
  final DateTime scheduledAt;

  const BookedSession({
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
}

class AgendaController {
  AgendaController._();
  static final sessions = ValueNotifier<List<BookedSession>>([]);

  static void add(BookedSession session) {
    sessions.value = [session, ...sessions.value];
  }
}

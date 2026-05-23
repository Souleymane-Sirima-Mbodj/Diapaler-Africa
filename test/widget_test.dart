import 'package:flutter_test/flutter_test.dart';
import 'package:diapaler_africa/data/donnees_mentors.dart';
import 'package:diapaler_africa/services/service_agenda.dart';
import 'package:diapaler_africa/services/service_notifications.dart';

void main() {
  // ─── Mentor.isInvestor ───────────────────────────────────────────
  group('Mentor.role', () {
    test('role par défaut est Mentor', () {
      final m = mentors.first;
      expect(m.role, equals('Mentor'));
      expect(m.isInvestor, isFalse);
    });

    test('isInvestor vrai pour les profils investisseurs', () {
      final investors = mentors.where((m) => m.isInvestor).toList();
      expect(investors, isNotEmpty);
      for (final inv in investors) {
        expect(inv.role, equals('Investisseur'));
      }
    });

    test('au moins 15 investisseurs dans la liste', () {
      final count = mentors.where((m) => m.isInvestor).length;
      expect(count, greaterThanOrEqualTo(15));
    });

    test('au moins 50 mentors dans la liste', () {
      final count = mentors.where((m) => !m.isInvestor).length;
      expect(count, greaterThanOrEqualTo(50));
    });
  });

  // ─── Mentor.matches ─────────────────────────────────────────────
  group('Mentor.matches()', () {
    test('requête vide retourne true', () {
      expect(mentors.first.matches(''), isTrue);
    });

    test('match sur le nom (insensible à la casse)', () {
      final m = mentors.first; // Anta Diama Kama
      expect(m.matches('anta'), isTrue);
      expect(m.matches('KAMA'), isTrue);
      expect(m.matches('diama'), isTrue);
    });

    test('match sur la ville', () {
      final dakarMentors = mentors.where((m) => m.matches('dakar'));
      expect(dakarMentors, isNotEmpty);
    });

    test('match sur un secteur', () {
      final techMentors = mentors.where((m) => m.matches('tech'));
      expect(techMentors, isNotEmpty);
    });

    test('pas de match pour un texte inexistant', () {
      final result = mentors.where((m) => m.matches('xyzabc123'));
      expect(result, isEmpty);
    });
  });

  // ─── recommendedMentorsFor ───────────────────────────────────────
  group('recommendedMentorsFor()', () {
    test('retourne tous les mentors triés si aucun secteur fourni', () {
      final result = recommendedMentorsFor(
        userSector: '',
        userInterests: [],
        projectSectors: [],
      );
      expect(result.length, equals(mentors.length));
    });

    test('filtre par secteur utilisateur', () {
      final result = recommendedMentorsFor(
        userSector: 'Tech & Digital',
        userInterests: [],
        projectSectors: [],
      );
      expect(result, isNotEmpty);
      for (final m in result) {
        expect(m.sectors.any((s) => s.contains('Tech')), isTrue);
      }
    });

    test('filtre par intérêts', () {
      final result = recommendedMentorsFor(
        userSector: '',
        userInterests: ['Finance'],
        projectSectors: [],
      );
      expect(result, isNotEmpty);
    });

    test('filtre par secteur de projet', () {
      final result = recommendedMentorsFor(
        userSector: '',
        userInterests: [],
        projectSectors: ['FinTech'],
      );
      expect(result, isNotEmpty);
    });

    test('résultats triés par compatibilité décroissante si overlap égal', () {
      final result = recommendedMentorsFor(
        userSector: '',
        userInterests: [],
        projectSectors: [],
      );
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].compatibility, greaterThanOrEqualTo(result[i + 1].compatibility));
      }
    });
  });

  // ─── BookedSession sérialisation ────────────────────────────────
  group('BookedSession toJson/fromJson', () {
    final session = BookedSession(
      id: '1234567890',
      mentorName: 'Anta Diama Kama',
      mentorInitials: 'AK',
      scheduledAt: DateTime(2026, 6, 15, 14, 0),
    );

    test('toJson contient tous les champs', () {
      final json = session.toJson();
      expect(json['id'], equals('1234567890'));
      expect(json['mentorName'], equals('Anta Diama Kama'));
      expect(json['mentorInitials'], equals('AK'));
      expect(json['scheduledAt'], isA<String>());
    });

    test('fromJson reconstruit correctement', () {
      final json = session.toJson();
      final restored = BookedSession.fromJson(json);
      expect(restored.id, equals(session.id));
      expect(restored.mentorName, equals(session.mentorName));
      expect(restored.mentorInitials, equals(session.mentorInitials));
      expect(restored.scheduledAt, equals(session.scheduledAt));
    });

    test('getters weekday/day/month/timeRange corrects', () {
      // 15 juin 2026 à 14h = Lundi
      expect(session.day, equals('15'));
      expect(session.month, equals('JUIN'));
      expect(session.timeRange, equals('14:00 – 15:00'));
    });
  });

  // ─── NotificationItem sérialisation ────────────────────────────
  group('NotificationItem toJson/fromJson', () {
    final notif = NotificationItem(
      id: 'notif-001',
      title: 'Demande envoyée',
      message: 'Ta demande à Anta Diama Kama a été transmise.',
      timestamp: DateTime(2026, 5, 23, 10, 30),
      type: 'mentor_request',
      isRead: false,
    );

    test('toJson contient tous les champs', () {
      final json = notif.toJson();
      expect(json['id'], equals('notif-001'));
      expect(json['title'], equals('Demande envoyée'));
      expect(json['type'], equals('mentor_request'));
      expect(json['isRead'], isFalse);
    });

    test('fromJson reconstruit correctement', () {
      final json = notif.toJson();
      final restored = NotificationItem.fromJson(json);
      expect(restored.id, equals(notif.id));
      expect(restored.title, equals(notif.title));
      expect(restored.message, equals(notif.message));
      expect(restored.type, equals(notif.type));
      expect(restored.isRead, isFalse);
    });

    test('isRead par défaut est false', () {
      final n = NotificationItem(
        id: 'x',
        title: 'Test',
        message: 'msg',
        timestamp: DateTime.now(),
        type: 'info',
      );
      expect(n.isRead, isFalse);
    });
  });

  // ─── allSectors ─────────────────────────────────────────────────
  group('allSectors', () {
    test('liste non vide', () {
      expect(allSectors, isNotEmpty);
    });

    test('contient les secteurs essentiels', () {
      expect(allSectors, contains('Tech & Digital'));
      expect(allSectors, contains('FinTech'));
      expect(allSectors, contains('Agriculture'));
      expect(allSectors, contains('Santé'));
      expect(allSectors, contains('Éducation / EdTech'));
    });

    test('se termine par Autre', () {
      expect(allSectors.last, equals('Autre'));
    });
  });
}

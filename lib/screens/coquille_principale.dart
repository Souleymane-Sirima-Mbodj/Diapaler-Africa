import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_favoris.dart';
import '../services/service_navigation.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/barre_navigation.dart';
import 'page_accueil.dart';
import 'page_chatbot.dart';
import 'page_matching.dart';
import 'page_messages.dart';
import 'page_agenda.dart';
import 'page_profil.dart';

// ── FAB chatbot avec anneau de pulse ──────────────────────────────
class _PulseFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _PulseFab({required this.onPressed});

  @override
  State<_PulseFab> createState() => _PulseFabState();
}

class _PulseFabState extends State<_PulseFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _scale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: _opacity.value),
              ),
            ),
          ),
        ),
        FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.navyDeep,
          elevation: 4,
          tooltip: 'DIALI IA — Assistant entrepreneurial',
          child: const Icon(Icons.psychology_rounded, size: 26),
        ),
      ],
    );
  }
}

/// Conteneur principal de l'application après connexion.
/// Gère la barre de navigation inférieure à cinq onglets et conserve
/// l'état de chaque onglet grâce à un [IndexedStack].
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  StreamSubscription? _pendingRequestsSub;
  StreamSubscription? _mentorsActiveSub;
  StreamSubscription? _pitchSub;

  @override
  void initState() {
    super.initState();
    final uid = AuthService.currentUid;
    if (uid != null && uid.isNotEmpty) {
      AgendaController.load(uid);
      FavoriteService.load(uid);
      NotificationService.init(uid);
      _listenPendingRequests(uid);
      _listenMentorsActive(uid);
      _listenPitchCount(uid);
    }
    AgendaController.sessions.addListener(_onSessionsChanged);
    FavoriteService.favorites.addListener(_onFavoritesChanged);
    appTabIndex.addListener(_onTabIndexChanged);
  }

  /// Écoute en temps réel les demandes en attente reçues par l'utilisateur.
  void _listenPendingRequests(String uid) {
    _pendingRequestsSub?.cancel();
    _pendingRequestsSub = FirebaseDatabase.instance
        .ref('mentorRequests')
        .orderByChild('toUserId')
        .equalTo(uid)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        pendingRequestsCount.value = 0;
        return;
      }
      final count = data.values.where((v) {
        if (v is! Map) return false;
        return v['status']?.toString() == 'pending';
      }).length;
      pendingRequestsCount.value = count;
    }, onError: (_) => pendingRequestsCount.value = 0);
  }

  /// Écoute en temps réel et calcule le compteur `mentorsActive`
  /// directement depuis les demandes acceptées — jamais de désynchronisation.
  ///
  /// - Mentor       : demandes reçues, type='mentor',      status='accepted'
  /// - Investisseur : demandes reçues, type='investment',  status='accepted'
  /// - Entrepreneur : demandes envoyées, type='mentor',    status='accepted'
  void _listenMentorsActive(String uid) {
    _mentorsActiveSub?.cancel();
    _mentorsActiveSub = FirebaseDatabase.instance
        .ref('mentorRequests')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map?;
      final role = UserProfileController.profile.value.role;

      if (data == null) {
        _applyMentorsActive(0);
        return;
      }

      int count = 0;
      for (final v in data.values) {
        if (v is! Map) continue;
        final status = v['status']?.toString();
        final type = v['type']?.toString() ?? 'mentor';
        final from = v['fromUserId']?.toString() ?? '';
        final to = v['toUserId']?.toString() ?? '';
        if (status != 'accepted') continue;

        if (role == 'Mentor' && type == 'mentor' && to == uid) count++;
        if (role == 'Investisseur' && type == 'investment' && to == uid) count++;
        if (role == 'Entrepreneur' && type == 'mentor' && from == uid) count++;
      }
      _applyMentorsActive(count);
    }, onError: (_) {});
  }

  /// Écoute en temps réel le nombre de pitchs publiés par l'utilisateur.
  void _listenPitchCount(String uid) {
    _pitchSub?.cancel();
    _pitchSub = DatabaseService.getMyPitches(uid).listen(
      (pitches) => pitchCount.value = pitches.length,
      onError: (_) => pitchCount.value = 0,
    );
  }

  void _applyMentorsActive(int count) {
    if (!mounted) return;
    final current = UserProfileController.profile.value;
    if (current.mentorsActive != count) {
      UserProfileController.update(current.copyWith(mentorsActive: count));
    }
  }

  /// Synchronise `sessionsCount` depuis la liste réelle des sessions réservées.
  /// Déclenché à chaque ajout ou annulation de session (AgendaController).
  void _onSessionsChanged() {
    if (!mounted) return;
    final count = AgendaController.sessions.value.length;
    final current = UserProfileController.profile.value;
    if (current.sessionsCount != count) {
      UserProfileController.update(current.copyWith(sessionsCount: count));
    }
  }

  /// Synchronise `favoritesCount` depuis la liste réelle des favoris.
  /// Déclenché à chaque ajout ou suppression d'un favori.
  void _onFavoritesChanged() {
    if (!mounted) return;
    final count = FavoriteService.favorites.value.length;
    final current = UserProfileController.profile.value;
    if (current.favoritesCount != count) {
      UserProfileController.update(current.copyWith(favoritesCount: count));
    }
  }

  void _onTabIndexChanged() {
    if (mounted) setState(() => _index = appTabIndex.value);
  }

  @override
  void dispose() {
    appTabIndex.removeListener(_onTabIndexChanged);
    AgendaController.sessions.removeListener(_onSessionsChanged);
    FavoriteService.favorites.removeListener(_onFavoritesChanged);
    _pendingRequestsSub?.cancel();
    _mentorsActiveSub?.cancel();
    _pitchSub?.cancel();
    pendingRequestsCount.value = 0;
    pitchCount.value = 0;
    super.dispose();
  }

  // Un écran par onglet : Accueil, Matching, Messages, Agenda, Profil.
  static const _pages = <Widget>[
    HomePage(),
    MatchingPage(),
    MessagesPage(),
    AgendaPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DiapalerBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
      floatingActionButton: _PulseFab(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

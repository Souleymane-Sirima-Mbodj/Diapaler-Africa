import 'package:flutter/material.dart';

import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
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

  @override
  void initState() {
    super.initState();
    // Charge les sessions agenda depuis Firebase au démarrage.
    final uid = UserProfileController.profile.value.email;
    if (uid.isNotEmpty) {
      AgendaController.load(uid);
      NotificationService.init(uid);
    }
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

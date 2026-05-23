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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        ),
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.navyDeep,
        tooltip: 'DIALI IA — Assistant entrepreneurial',
        child: const Icon(Icons.psychology_rounded, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

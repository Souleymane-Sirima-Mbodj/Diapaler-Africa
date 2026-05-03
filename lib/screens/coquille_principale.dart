import 'package:flutter/material.dart';

import '../theme/theme_app.dart';
import '../widgets/barre_navigation.dart';
import 'page_accueil.dart';
import 'page_profil.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    _ComingSoonPage(
      icon: Icons.handshake_rounded,
      title: 'Matching',
      subtitle: 'Retrouve ici les mentors avec qui tu as matché.\nDisponible bientôt.',
    ),
    _ComingSoonPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Messages',
      subtitle: 'Discute avec tes mentors et entrepreneurs.\nDisponible bientôt.',
    ),
    _ComingSoonPage(
      icon: Icons.event_rounded,
      title: 'Agenda',
      subtitle: 'Retrouve toutes tes sessions planifiées.\nDisponible bientôt.',
    ),
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
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.blueTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.navy, size: 44),
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'À venir',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

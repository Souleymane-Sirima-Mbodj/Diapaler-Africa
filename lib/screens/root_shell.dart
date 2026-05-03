// ignore_for_file: unused_import
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'home_page.dart';
import 'matching_page.dart';
import 'pitch_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    MatchingPage(),
  ];

  void _openPitch() {
    // TODO: réactiver — Navigator.push(PitchPage)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _PitchFab(onTap: _openPitch),
      bottomNavigationBar: DiapalerBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PitchFab extends StatelessWidget {
  final VoidCallback onTap;
  const _PitchFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.6),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        shape: const CircleBorder(),
        tooltip: 'Déposer un pitch',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

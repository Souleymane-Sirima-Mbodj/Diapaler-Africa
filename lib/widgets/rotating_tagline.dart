import 'dart:async';
import 'package:flutter/material.dart';
import '../data/quotes.dart';
import '../theme/app_theme.dart';

/// Petit texte italique sous le greeting qui change toutes les 6s.
/// Très discret — joue le rôle de "citation du jour" sans encombrer l'UI.
class RotatingTagline extends StatefulWidget {
  const RotatingTagline({super.key});

  @override
  State<RotatingTagline> createState() => _RotatingTaglineState();
}

class _RotatingTaglineState extends State<RotatingTagline> {
  Timer? _timer;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _i = (_i + 1) % quotes.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = quotes[_i];
    // On garde uniquement la première ligne pour rester compact.
    final firstLine = q.text.split('\n').first;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (c, a) =>
          FadeTransition(opacity: a, child: c),
      child: Text(
        '“ $firstLine ”  — ${q.author}',
        key: ValueKey(_i),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.muted,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

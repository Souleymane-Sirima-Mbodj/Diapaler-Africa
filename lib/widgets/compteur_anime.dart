import 'package:flutter/material.dart';

/// Compteur qui anime un nombre de 0 vers `value` au premier rendu.
/// Supporte un suffixe (ex. "%", "+", "★") et des décimales optionnelles.
class AnimatedCounter extends StatelessWidget {
  final num value;
  final int decimals;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.decimals = 0,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1100),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (_, v, __) {
        final formatted =
            decimals == 0 ? v.toInt().toString() : v.toStringAsFixed(decimals);
        return Text('$formatted$suffix', style: style);
      },
    );
  }
}

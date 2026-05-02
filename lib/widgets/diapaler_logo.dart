import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Logo "entraide" — un cercle navy lumineux qui contient une icône handshake,
/// entouré de 3 points aux couleurs du drapeau du Sénégal (vert, jaune, rouge).
/// Le sens : « Diapaler » = épauler, accompagner — l'autre est le remède de l'autre.
class DiapalerLogoTile extends StatelessWidget {
  final double size;
  final bool onDark;

  const DiapalerLogoTile({super.key, this.size = 72, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final outer = size * 1.42;
    final dotR = size * 0.62;
    final dotSize = size * 0.13;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo doré subtil
          Container(
            width: size * 1.32,
            height: size * 1.32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.amber.withValues(alpha: onDark ? 0.4 : 0.3),
                width: 1,
              ),
            ),
          ),
          // Cercle principal
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.blue],
              ),
              border: Border.all(color: AppColors.amber, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.handshake_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
          // Trois points autour aux couleurs du drapeau du Sénégal
          _orbitDot(angle: -math.pi / 2, r: dotR, color: AppColors.flagGreen, size: dotSize),
          _orbitDot(angle: math.pi / 6, r: dotR, color: AppColors.flagYellow, size: dotSize),
          _orbitDot(angle: 5 * math.pi / 6, r: dotR, color: AppColors.flagRed, size: dotSize),
        ],
      ),
    );
  }

  Widget _orbitDot({
    required double angle,
    required double r,
    required Color color,
    required double size,
  }) {
    return Transform.translate(
      offset: Offset(r * math.cos(angle), r * math.sin(angle)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wordmark "DIAPALER / AFRICA" aux couleurs du drapeau du Sénégal 🇸🇳
class DiapalerWordmark extends StatelessWidget {
  final double fontSize;
  final bool onDark;

  const DiapalerWordmark({
    super.key,
    this.fontSize = 32,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final yellowShadow = onDark
        ? <Shadow>[
            const Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
          ]
        : <Shadow>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1,
            ),
            children: [
              const TextSpan(
                text: 'DIAPAL',
                style: TextStyle(color: AppColors.flagGreen),
              ),
              TextSpan(
                text: 'ER',
                style: TextStyle(
                  color: AppColors.flagYellow,
                  shadows: yellowShadow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'AFRICA',
          style: TextStyle(
            fontSize: fontSize * 0.46,
            fontWeight: FontWeight.w900,
            color: AppColors.flagRed,
            letterSpacing: fontSize * 0.18,
          ),
        ),
      ],
    );
  }
}

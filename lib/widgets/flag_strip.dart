import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bandeau horizontal aux trois couleurs du drapeau du Sénégal.
class SenegalFlagStrip extends StatelessWidget {
  final double height;
  const SenegalFlagStrip({super.key, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Row(
        children: [
          Expanded(child: ColoredBox(color: AppColors.flagGreen)),
          Expanded(child: ColoredBox(color: AppColors.flagYellow)),
          Expanded(child: ColoredBox(color: AppColors.flagRed)),
        ],
      ),
    );
  }
}

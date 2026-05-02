import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final bool online;

  const Avatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = AppColors.navy,
    this.foreground = Colors.white,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: foreground,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

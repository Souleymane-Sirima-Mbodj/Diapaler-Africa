import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

/// Card qui se met en valeur au survol de la souris :
/// scale 1.015, ombre ambrée, bordure bleue. Sur tactile, simple Container.
class HoverGlowCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color background;
  final Color? hoverBorder;

  const HoverGlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    BorderRadius? borderRadius,
    this.background = Colors.white,
    this.hoverBorder,
  }) : borderRadius =
            borderRadius ?? const BorderRadius.all(Radius.circular(16));

  @override
  State<HoverGlowCard> createState() => _HoverGlowCardState();
}

class _HoverGlowCardState extends State<HoverGlowCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hoverBorder = widget.hoverBorder ?? AppColors.blue;
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          transform: _hover
              ? (Matrix4.identity()..scaleByDouble(1.015, 1.015, 1.015, 1.0))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _hover ? hoverBorder : AppColors.border,
              width: _hover ? 1.4 : 1,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

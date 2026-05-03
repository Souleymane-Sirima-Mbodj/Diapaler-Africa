import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/theme_app.dart';

/// Traînée d'étoiles aux couleurs du drapeau du Sénégal qui suit la souris.
/// Sur tactile/mobile, devient un no-op.
class CursorFollower extends StatefulWidget {
  final Widget child;
  const CursorFollower({super.key, required this.child});

  @override
  State<CursorFollower> createState() => _CursorFollowerState();
}

class _CursorFollowerState extends State<CursorFollower>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Star> _stars = [];
  final ValueNotifier<int> _tickNotifier = ValueNotifier<int>(0);
  final _rng = math.Random();
  Offset? _lastSpawn;

  static const _maxStars = 50;
  static const _starLifeMs = 900;
  static const _spawnDistance = 14.0;

  static const _palette = <Color>[
    AppColors.flagGreen,
    AppColors.flagYellow,
    AppColors.flagRed,
    AppColors.amber,
  ];

  bool get _enabled =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (_enabled) {
      _ticker = createTicker(_onTick)..start();
    }
  }

  @override
  void dispose() {
    if (_enabled) _ticker.dispose();
    _tickNotifier.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final before = _stars.length;
    _stars.removeWhere(
      (s) => now.difference(s.born).inMilliseconds > _starLifeMs,
    );
    if (before != _stars.length || _stars.isNotEmpty) {
      _tickNotifier.value++;
    }
  }

  void _spawnStar(Offset position) {
    if (_lastSpawn != null &&
        (position - _lastSpawn!).distance < _spawnDistance) {
      return;
    }
    _lastSpawn = position;

    if (_stars.length >= _maxStars) {
      _stars.removeAt(0);
    }

    _stars.add(_Star(
      position: position,
      born: DateTime.now(),
      size: 4 + _rng.nextDouble() * 6,
      rotation: _rng.nextDouble() * math.pi * 2,
      color: _palette[_rng.nextInt(_palette.length)],
      drift: Offset(
        (_rng.nextDouble() - 0.5) * 30,
        -20 - _rng.nextDouble() * 20,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;

    return MouseRegion(
      opaque: false,
      onHover: (e) => _spawnStar(e.position),
      onExit: (_) => _lastSpawn = null,
      child: Stack(
        children: [
          widget.child,
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _StarsPainter(_stars, _tickNotifier),
            ),
          ),
        ],
      ),
    );
  }
}

class _Star {
  final Offset position;
  final DateTime born;
  final double size;
  final double rotation;
  final Color color;
  final Offset drift;

  _Star({
    required this.position,
    required this.born,
    required this.size,
    required this.rotation,
    required this.color,
    required this.drift,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  _StarsPainter(this.stars, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    for (final s in stars) {
      final ageMs = now.difference(s.born).inMilliseconds;
      final t = (ageMs / _CursorFollowerState._starLifeMs).clamp(0.0, 1.0);
      if (t >= 1.0) continue;

      // Lifecycle : opacité monte rapidement puis descend.
      final opacity = t < 0.15 ? (t / 0.15) : (1 - (t - 0.15) / 0.85);
      final radius = s.size * (1 - t * 0.4);

      // Dérive : un peu de mouvement vers le haut + horizontal aléatoire.
      final pos = s.position + s.drift * t;

      // Rotation lente dans le temps.
      final angle = s.rotation + t * math.pi;

      final paint = Paint()
        ..color = s.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + t * 2);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      canvas.drawPath(_starPath(radius), paint);
      canvas.restore();
    }
  }

  /// Trace une étoile à 5 branches centrée sur l'origine.
  Path _starPath(double r) {
    final path = Path();
    const points = 5;
    final inner = r * 0.42;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_StarsPainter old) => false;
}

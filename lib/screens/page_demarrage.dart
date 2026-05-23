import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart' show firebaseReady;
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_cache.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';
import '../widgets/logo_diapaler.dart';
import 'page_choix_role.dart';
import 'coquille_principale.dart';

/// Splash 1.6s — le tile apparaît, les 3 orbites s'allument une à une,
/// puis le wordmark monte. À la fin → navigation vers RoleSelectionPage.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _bootstrap();
  }

  /// Attend que Firebase soit prêt ET que l'animation du splash se termine,
  /// puis route vers RootShell (utilisateur déjà connecté) ou RoleSelectionPage.
  Future<void> _bootstrap() async {
    Widget next = const RoleSelectionPage();

    // Cache local : recharge le dernier profil connu pour un affichage
    // instantané au démarrage (fonctionne même hors-ligne).
    final cached = await CacheService.loadProfile();
    if (cached != null) {
      UserProfileController.update(cached);
    }

    try {
      await firebaseReady.timeout(const Duration(seconds: 5));
      final uid = AuthService.currentUid;
      if (uid != null) {
        final remote = await DatabaseService.readUserProfile(uid)
            .timeout(const Duration(seconds: 4));
        if (remote != null) {
          UserProfileController.update(remote);
          next = const RootShell();
        }
      }
    } catch (_) {
      // En cas de problème (réseau, timeout), on tombe sur RoleSelection.
    }

    // On garantit que le splash dure au minimum 1.2s pour bien voir l'anim.
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: next),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _at(double s, double e) =>
      CurvedAnimation(parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        children: [
          // Fond pattern subtil
          Positioned.fill(child: CustomPaint(painter: _DotsBg())),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Logo(anim: _ctrl),
                const SizedBox(height: 22),
                _slideUp(
                  anim: _at(0.55, 0.85),
                  child: const DiapalerWordmark(fontSize: 36, onDark: true),
                ),
                const SizedBox(height: 12),
                _slideUp(
                  anim: _at(0.7, 1.0),
                  child: const Text(
                    '« Connecte ton idée à ton succès »',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _at(0.9, 1.0),
                  child: const SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.white12,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.amber),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slideUp({required Animation<double> anim, required Widget child}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 18),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _Logo extends StatelessWidget {
  final AnimationController anim;
  const _Logo({required this.anim});

  Animation<double> _at(double s, double e) =>
      CurvedAnimation(parent: anim, curve: Interval(s, e, curve: Curves.easeOutBack));

  @override
  Widget build(BuildContext context) {
    const size = 88.0;
    const outer = size * 1.5;
    const dotR = size * 0.62;
    const dotSize = size * 0.13;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tile principal (apparaît en premier)
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(_at(0.0, 0.4)),
            child: FadeTransition(
              opacity: _at(0.0, 0.3),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, AppColors.blue],
                  ),
                  border: Border.all(color: AppColors.amber, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.5),
                      blurRadius: 36,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.handshake_rounded,
                    color: Colors.white, size: 50),
              ),
            ),
          ),
          // 3 orbites apparaissent une à une
          _Dot(
            anim: _at(0.30, 0.50),
            angle: -math.pi / 2,
            r: dotR,
            color: AppColors.flagGreen,
            size: dotSize,
          ),
          _Dot(
            anim: _at(0.40, 0.60),
            angle: math.pi / 6,
            r: dotR,
            color: AppColors.flagYellow,
            size: dotSize,
          ),
          _Dot(
            anim: _at(0.50, 0.70),
            angle: 5 * math.pi / 6,
            r: dotR,
            color: AppColors.flagRed,
            size: dotSize,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Animation<double> anim;
  final double angle;
  final double r;
  final Color color;
  final double size;

  const _Dot({
    required this.anim,
    required this.angle,
    required this.r,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(r * math.cos(angle), r * math.sin(angle)),
          child: Transform.scale(
            scale: anim.value.clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DotsBg extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    const step = 22.0;
    for (double y = 8; y < size.height; y += step) {
      for (double x = 8; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsBg old) => false;
}

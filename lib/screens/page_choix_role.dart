import 'package:flutter/material.dart';
import '../theme/theme_app.dart';
import '../widgets/logo_diapaler.dart';
import '../widgets/bande_drapeau.dart';
import 'page_connexion.dart';
import 'page_inscription.dart';

enum UserRole { entrepreneur, mentor, investor }

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  UserRole _selected = UserRole.entrepreneur;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _staggered(double start, double end) =>
      CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(staggered: _staggered),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              child: _slideUp(
                anim: _staggered(0.45, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Je suis...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choisis ton profil pour commencer',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    _RoleTile(
                      letter: 'E',
                      title: 'Entrepreneur',
                      subtitle: "J'ai un projet, je cherche un mentor",
                      circle: AppColors.roleEntrepreneur,
                      selected: _selected == UserRole.entrepreneur,
                      onTap: () => setState(
                          () => _selected = UserRole.entrepreneur),
                    ),
                    const SizedBox(height: 10),
                    _RoleTile(
                      letter: 'M',
                      title: 'Mentor',
                      subtitle: 'Je partage mon expertise',
                      circle: AppColors.roleMentor,
                      selected: _selected == UserRole.mentor,
                      onTap: () =>
                          setState(() => _selected = UserRole.mentor),
                    ),
                    const SizedBox(height: 10),
                    _RoleTile(
                      letter: 'I',
                      title: 'Investisseur',
                      subtitle: 'Je finance des projets prometteurs',
                      circle: AppColors.roleInvestor,
                      selected: _selected == UserRole.investor,
                      onTap: () =>
                          setState(() => _selected = UserRole.investor),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SignUpPage(initialRole: _selected),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'CONTINUER',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ?  ',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 13.5),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slideUp({required Animation<double> anim, required Widget child}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 24),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  final Animation<double> Function(double, double) staggered;
  const _Header({required this.staggered});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.navyDeep,
            AppColors.navy,
            Color(0xFF14305E),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _DotsPattern()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Column(
                children: [
                  _fadeIn(
                    anim: staggered(0.0, 0.45),
                    child: const DiapalerLogoTile(size: 52, onDark: true),
                  ),
                  const SizedBox(height: 10),
                  _fadeIn(
                    anim: staggered(0.10, 0.55),
                    child: const DiapalerWordmark(fontSize: 26, onDark: true),
                  ),
                  const SizedBox(height: 8),
                  _fadeIn(
                    anim: staggered(0.20, 0.65),
                    child: const Text(
                      '« Connecte ton idée à ton succès »',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SenegalFlagStrip(height: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fadeIn({required Animation<double> anim, required Widget child}) {
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

class _DotsPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const step = 18.0;
    for (double y = 8; y < size.height; y += step) {
      for (double x = 8; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPattern oldDelegate) => false;
}

class _RoleTile extends StatelessWidget {
  final String letter;
  final String title;
  final String subtitle;
  final Color circle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.circle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

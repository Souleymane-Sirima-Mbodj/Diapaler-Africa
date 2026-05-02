import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../data/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/avatar.dart';
import '../widgets/hover_glow_card.dart';
import '../widgets/mentor_card.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/rotating_tagline.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.amber,
          backgroundColor: Theme.of(context).cardTheme.color,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
            children: _loading ? _skeletons() : _content(),
          ),
        ),
      ),
    );
  }

  List<Widget> _content() {
    return [
      const _Header(),
      const SizedBox(height: 18),
      const _ProgressCard(),
      const SizedBox(height: 14),
      const _StatsStrip(),
      const SizedBox(height: 22),
      const SectionHeader(
        title: 'Mentors recommandés',
        action: 'Tout voir',
      ),
      const SizedBox(height: 10),
      ...recommendedMentors.take(2).map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MentorCard(mentor: m),
            ),
          ),
      const SizedBox(height: 4),
      const _DerCard(),
    ];
  }

  List<Widget> _skeletons() {
    return const [
      Row(
        children: [
          SkeletonBox(width: 42, height: 42, radius: 999),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 16),
                SizedBox(height: 6),
                SkeletonBox(width: 130, height: 11),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 40, height: 40, radius: 12),
        ],
      ),
      SizedBox(height: 18),
      SkeletonBox(width: double.infinity, height: 130, radius: 18),
      SizedBox(height: 14),
      SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(child: SkeletonBox(height: 64, radius: 12)),
            SizedBox(width: 8),
            Expanded(child: SkeletonBox(height: 64, radius: 12)),
            SizedBox(width: 8),
            Expanded(child: SkeletonBox(height: 64, radius: 12)),
          ],
        ),
      ),
      SizedBox(height: 22),
      MentorCardSkeleton(),
      SizedBox(height: 10),
      MentorCardSkeleton(),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// Header — avatar + greeting + citation rotative + cloche
// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        return Row(
          children: [
            GestureDetector(
              onTap: () => showProfileSheet(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Avatar(
                  initials: p.initials,
                  size: 42,
                  background: AppColors.amber,
                  foreground: AppColors.navyDeep,
                  online: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Bonjour, ${p.firstName}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const RotatingTagline(),
                ],
              ),
            ),
            _IconBubble(
              icon: Icons.notifications_none_rounded,
              badge: '3',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  const _IconBubble({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero "Mon projet"
// ─────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final p = UserProfileController.profile.value;
    final step = p.projectStep;
    final total = p.projectTotalSteps;
    final percent = (p.progress * 100).round();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Page détail projet — à brancher plus tard
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -28,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -18,
            right: 30,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue.withValues(alpha: 0.22),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '🚀  PROJET EN COURS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedCounter(
                    value: percent,
                    suffix: ' %',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p.projectName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Étape $step / $total · ${p.sector}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: p.progress),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.amber),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stats — bande horizontale déroulante
// ─────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _StatPill(
        icon: Icons.handshake_rounded,
        color: AppColors.blue,
        label: 'Mentors',
        value: 4,
      ),
      _StatPill(
        icon: Icons.calendar_month_rounded,
        color: AppColors.green,
        label: 'Sessions',
        value: 3,
      ),
      _StatPill(
        icon: Icons.star_rounded,
        color: AppColors.amber,
        label: 'Score',
        value: 4.8,
        decimals: 1,
        suffix: '★',
      ),
      _StatPill(
        icon: Icons.upload_file_rounded,
        color: AppColors.purple,
        label: 'Pitchs',
        value: 2,
      ),
      _StatPill(
        icon: Icons.bookmark_rounded,
        color: AppColors.red,
        label: 'Favoris',
        value: 7,
      ),
    ];
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => items[i],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final num value;
  final int decimals;
  final String suffix;

  const _StatPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.decimals = 0,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCounter(
                  value: value,
                  decimals: decimals,
                  suffix: suffix,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DER/FJ
// ─────────────────────────────────────────────────────────────────
class _DerCard extends StatelessWidget {
  const _DerCard();

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      padding: const EdgeInsets.all(14),
      background: AppColors.blueTint,
      hoverBorder: AppColors.blue,
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: AppColors.amber, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAVIE 2 · DER/FJ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDeep,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '107,2 Mds FCFA · candidatures ouvertes',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
        ],
      ),
    );
  }
}

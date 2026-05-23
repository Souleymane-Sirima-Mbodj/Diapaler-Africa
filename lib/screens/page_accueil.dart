import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';
import '../widgets/compteur_anime.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import '../widgets/carte_mentor.dart';
import '../widgets/feuille_profil.dart';
import '../widgets/entete_section.dart';
import '../widgets/squelette.dart';
import 'page_nouveau_projet.dart';
import 'page_matching.dart';
import 'page_pitch.dart';
import 'page_mentors_recommandes.dart';

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
      body: RefreshIndicator(
        color: AppColors.amber,
        backgroundColor: Theme.of(context).cardTheme.color,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 90),
          children: _loading ? _skeletons() : _content(),
        ),
      ),
    );
  }

  List<Widget> _content() {
    return [
      const _NavyHero(),
      const SizedBox(height: 14),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _ProjectHero(),
      ),
      const SizedBox(height: 18),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SectionHeader(title: 'Actions rapides'),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _QuickActionsGrid(),
      ),
      const SizedBox(height: 18),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _StatsStrip(),
      ),
      const SizedBox(height: 22),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _RecommendedHeader(),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _RecommendedMentors(),
      ),
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _DerCard(),
      ),
    ];
  }

  List<Widget> _skeletons() {
    return const [
      Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
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
      ),
      SizedBox(height: 18),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SkeletonBox(width: double.infinity, height: 130, radius: 18),
      ),
      SizedBox(height: 14),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
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
      ),
      SizedBox(height: 22),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: MentorCardSkeleton(),
      ),
      SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: MentorCardSkeleton(),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero navy avec greeting + searchbar (style maquette)
// ─────────────────────────────────────────────────────────────────
class _NavyHero extends StatelessWidget {
  const _NavyHero();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showProfileSheet(context),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Avatar(
                            initials: p.initials,
                            size: 50,
                            background: AppColors.amber,
                            foreground: AppColors.navyDeep,
                            photoBase64: p.photoBase64,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Bonjour ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('🇸🇳', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _NotifBell(onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Barre de recherche
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MatchingPage(),
                      ),
                    ),
                    child: Container(
                      height: 44,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: AppColors.subtle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Rechercher un mentor, secteur…',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.subtle,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _NotifBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotifBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero "Mon projet" — bascule entre empty state et card projet en cours
// ─────────────────────────────────────────────────────────────────
class _ProjectHero extends StatelessWidget {
  const _ProjectHero();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        if (p.currentProject == null) {
          return const _EmptyProjectHero();
        }
        return _ProgressCard(profile: p);
      },
    );
  }
}

class _EmptyProjectHero extends StatelessWidget {
  const _EmptyProjectHero();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const AddProjectPage(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aucun projet en cours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tape ici pour démarrer ton premier projet entrepreneurial.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final UserProfile profile;
  const _ProgressCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final step = p.projectStep;
    final total = p.projectTotalSteps;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Page détail projet — à brancher plus tard
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MON PROJET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.projectName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDeep,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.projectDescription.isEmpty
                    ? p.sector
                    : p.projectDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Étape $step / $total',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: p.progress),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          backgroundColor: AppColors.fieldBg,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  AppColors.amber),
                        ),
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
// Actions rapides — grille 2x2 (style maquette)
// ─────────────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _QuickAction(
          icon: Icons.handshake_rounded,
          color: AppColors.roleMentor,
          title: 'Trouver',
          subtitle: 'un mentor',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MatchingPage()),
          ),
        ),
        _QuickAction(
          icon: Icons.upload_file_rounded,
          color: AppColors.amber,
          title: 'Déposer',
          subtitle: 'un pitch',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const PitchPage(),
            ),
          ),
        ),
        _QuickAction(
          icon: Icons.account_balance_rounded,
          color: AppColors.roleEntrepreneur,
          title: 'DER / FJ',
          subtitle: 'Orientation',
          onTap: () {},
        ),
        _QuickAction(
          icon: Icons.workspace_premium_rounded,
          color: AppColors.green,
          title: 'CIS',
          subtitle: 'Investisseurs',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MatchingPage()),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDeep,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stats — bande horizontale déroulante (lit le profile en live)
// ─────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        final items = <_StatPill>[
          _StatPill(
            icon: Icons.handshake_rounded,
            color: AppColors.blue,
            label: 'Mentors',
            value: p.mentorsActive,
          ),
          _StatPill(
            icon: Icons.calendar_month_rounded,
            color: AppColors.green,
            label: 'Sessions',
            value: p.sessionsCount,
          ),
          if (p.score > 0)
            _StatPill(
              icon: Icons.star_rounded,
              color: AppColors.amber,
              label: 'Score',
              value: p.score,
              decimals: 1,
              suffix: '★',
            ),
          _StatPill(
            icon: Icons.upload_file_rounded,
            color: AppColors.purple,
            label: 'Pitchs',
            value: p.projects.length,
          ),
          _StatPill(
            icon: Icons.bookmark_rounded,
            color: AppColors.red,
            label: 'Favoris',
            value: p.favoritesCount,
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
      },
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

class _RecommendedHeader extends StatelessWidget {
  const _RecommendedHeader();

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: 'Mentors pour toi',
      action: 'Voir tout →',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RecommendedMentorsPage()),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Mentors recommandés — liste réactive selon le profil utilisateur
// ─────────────────────────────────────────────────────────────────
class _RecommendedMentors extends StatelessWidget {
  const _RecommendedMentors();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        final recos = recommendedMentorsFor(
          userSector: p.sector,
          userInterests: p.interests,
          projectSectors: p.projects.map((pr) => pr.sector).toList(),
        ).take(2).toList();

        if (recos.isEmpty) {
          return const _NoRecoState();
        }
        return Column(
          children: [
            for (final m in recos)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MentorCard(mentor: m),
              ),
          ],
        );
      },
    );
  }
}

class _NoRecoState extends StatelessWidget {
  const _NoRecoState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppColors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Choisis tes centres d\'intérêt dans ton profil pour voir des mentors adaptés.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
        ],
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
                  'Candidater pour un financement',
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

import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_navigation.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/compteur_anime.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import '../widgets/carte_mentor.dart';
import '../widgets/feuille_profil.dart';
import '../widgets/entete_section.dart';
import '../widgets/squelette.dart';
import 'page_nouveau_projet.dart';
import 'page_notifications.dart';
import 'page_pitch.dart';
import 'page_mentors_recommandes.dart';
import 'page_mes_favoris.dart';
import 'page_mes_mentors.dart';
import 'page_mes_pitchs.dart';
import 'page_dashboard_investisseur.dart';
import 'page_dashboard_mentor.dart';

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
      body: ValueListenableBuilder<UserProfile>(
        valueListenable: UserProfileController.profile,
        builder: (context, profile, _) {
          if (profile.role == 'Investisseur') {
            return RefreshIndicator(
              color: AppColors.amber,
              backgroundColor: Theme.of(context).cardTheme.color,
              onRefresh: _refresh,
              child: const InvestorDashboard(),
            );
          } else if (profile.role == 'Mentor') {
            return RefreshIndicator(
              color: AppColors.amber,
              backgroundColor: Theme.of(context).cardTheme.color,
              onRefresh: _refresh,
              child: const MentorDashboard(),
            );
          }
          return RefreshIndicator(
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
          );
        },
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
                  SkeletonBox(width: 160),
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
                      _NotifBell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Barre de recherche → bascule sur l'onglet Matching
                  GestureDetector(
                    onTap: () => appTabIndex.value = 1,
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
    return ValueListenableBuilder<List<NotificationItem>>(
      valueListenable: NotificationService.notifications,
      builder: (_, notifs, __) {
        final unread = notifs.where((n) => !n.isRead).length;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 22),
                ),
                if (unread > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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

void _showProjectSheet(BuildContext context, UserProfile p) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.sector,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Étape ${p.projectStep} / ${p.projectTotalSteps}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: p.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.fieldBg,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.amber),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(p.progress * 100).round()} %',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const PitchPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text(
                  'Déposer un pitch',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
        onTap: () => _showProjectSheet(context, p),
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
          onTap: () => appTabIndex.value = 1,
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
          onTap: () => _showDerFjSheet(context),
        ),
        _QuickAction(
          icon: Icons.workspace_premium_rounded,
          color: AppColors.green,
          title: 'CIS',
          subtitle: 'Investisseurs',
          onTap: () => _showCisSheet(context),
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesMentorsPage()),
            ),
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesPitchsPage()),
            ),
          ),
          _StatPill(
            icon: Icons.bookmark_rounded,
            color: AppColors.red,
            label: 'Favoris',
            value: p.favoritesCount,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MesFavorisPage()),
            ),
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
  final VoidCallback? onTap;

  const _StatPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.decimals = 0,
    this.suffix = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
void _showDerFjSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _DerFjSheet(),
  );
}

class _DerFjSheet extends StatelessWidget {
  const _DerFjSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyDeep, AppColors.navy],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_rounded,
                    color: AppColors.amber, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAVIE 2 · DER/FJ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Financement entrepreneurial au Sénégal',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _InfoTile(
            icon: Icons.info_rounded,
            color: AppColors.blue,
            title: 'Qu\'est-ce que la DER/FJ ?',
            body:
                'La Délégation générale à l\'Entrepreneuriat Rapide des Femmes et des Jeunes (DER/FJ) est un programme du gouvernement sénégalais qui finance les projets des jeunes entrepreneurs.',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.attach_money_rounded,
            color: AppColors.green,
            title: 'Montants disponibles',
            body:
                '• Volet individuel : 100 000 – 3 000 000 FCFA\n• Volet groupements : jusqu\'à 15 000 000 FCFA\n• Volet PME/TPE : jusqu\'à 30 000 000 FCFA',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.checklist_rounded,
            color: AppColors.amber,
            title: 'Conditions d\'éligibilité',
            body:
                '• Être sénégalais(e), âgé(e) de 18 à 40 ans\n• Avoir un projet viable avec un plan de gestion\n• Fournir une pièce d\'identité valide\n• Résider au Sénégal',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.description_rounded,
            color: AppColors.purple,
            title: 'Documents requis',
            body:
                '• CNI ou passeport en cours de validité\n• Plan d\'affaires (business plan)\n• Photos d\'identité\n• Justificatif de domicile\n• Registre de commerce (si entreprise existante)',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.place_rounded,
            color: AppColors.red,
            title: 'Contact & Dépôt',
            body:
                'Délégation Générale à l\'Entrepreneuriat Rapide\nRue Amadou Assane Ndoye × Boulevard de la République\nDakar, Sénégal\n📞 +221 33 889 47 00\n🌐 derfj.sn',
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text(
              'Fermer',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CIS — Club des Investisseurs du Sénégal
// ─────────────────────────────────────────────────────────────────
void _showCisSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CisSheet(),
  );
}

class _CisSheet extends StatelessWidget {
  const _CisSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navyDeep, AppColors.navy],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded,
                    color: AppColors.green, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Club des Investisseurs du Sénégal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Réseau d\'investisseurs privés sénégalais',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _InfoTile(
            icon: Icons.info_rounded,
            color: AppColors.blue,
            title: 'Qu\'est-ce que le CIS ?',
            body:
                'Le Club des Investisseurs du Sénégal (CIS) est un réseau privé d\'investisseurs sénégalais qui accompagnent les entrepreneurs à fort potentiel. Il facilite l\'accès au financement et au mentorat pour les startups et PME.',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.trending_up_rounded,
            color: AppColors.green,
            title: 'Types d\'investissement',
            body:
                '• Capital-risque (equity) pour les startups\n• Prêts participatifs pour les PME\n• Business angels individuels\n• Financement de série A et B',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.checklist_rounded,
            color: AppColors.amber,
            title: 'Profil des projets recherchés',
            body:
                '• Startups à fort potentiel de croissance\n• Projets innovants dans les secteurs porteurs\n• Équipe fondatrice solide et engagée\n• Marché addressable significatif en Afrique de l\'Ouest',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.handshake_rounded,
            color: AppColors.purple,
            title: 'Comment accéder au CIS ?',
            body:
                '• Déposer ton pitch sur DIAPALER AFRICA\n• Être recommandé par un membre du réseau\n• Participer aux événements entrepreneuriaux (CTIC Dakar, Yoban\'tel)\n• Contacter via la messagerie DIAPALER',
          ),
          const SizedBox(height: 10),
          const _InfoTile(
            icon: Icons.place_rounded,
            color: AppColors.red,
            title: 'Où trouver des investisseurs CIS ?',
            body:
                'Les membres CIS inscrits sur DIAPALER AFRICA sont identifiés par le badge vert "Investisseur". Utilise le Matching pour les contacter directement.\n\nÉvénements : CTIC Dakar, Silicon Valley of Africa, Dakar Startup Week',
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              appTabIndex.value = 1; // Ouvre le Matching
            },
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text(
              'Trouver des investisseurs',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text(
              'Fermer',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}


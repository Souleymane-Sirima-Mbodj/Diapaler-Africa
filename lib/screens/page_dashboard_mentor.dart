import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_notifications.dart';
import 'page_pitches_publics.dart';
import 'page_planning.dart';
import 'page_requests.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (context, profile, _) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Header collant ────────────────────────────────────
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.surface,
              scrolledUnderElevation: 1,
              shadowColor: AppColors.border,
              toolbarHeight: 68,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Avatar(
                      initials: profile.initials,
                      background: AppColors.roleMentor,
                      photoBase64: profile.photoBase64,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenue ${profile.firstName} 👋',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyDeep,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Mentor',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cloche notifications
                    ValueListenableBuilder<List<NotificationItem>>(
                      valueListenable: NotificationService.notifications,
                      builder: (context, notifs, _) {
                        final unread = notifs.where((n) => !n.isRead).length;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              color: AppColors.navyDeep,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              ),
                            ),
                            if (unread > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$unread',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Contenu scrollable ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.school_rounded,
                          label: 'Mentorés',
                          value: '${profile.mentorsActive}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_month_rounded,
                          label: 'Sessions',
                          value: '${profile.sessionsCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.workspace_premium_rounded,
                          label: profile.yearsExperience > 1 ? 'Années expé.' : 'Année expé.',
                          value: profile.yearsExperience > 0
                              ? '${profile.yearsExperience}'
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Domaines d'expertise
                  const Text(
                    'Domaines d\'expertise',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.roleMentor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.roleMentor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.roleMentor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Bio
                  const Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.bio.isEmpty
                          ? 'Pas de biographie renseignée.'
                          : profile.bio,
                      style: TextStyle(
                        fontSize: 13,
                        color: profile.bio.isEmpty
                            ? AppColors.muted
                            : AppColors.navyDeep,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions rapides
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RequestsPage()),
                          ),
                          icon: const Icon(Icons.mail_rounded, size: 18),
                          label: const Text(
                            'Demandes',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.roleMentor,
                            side: const BorderSide(color: AppColors.roleMentor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SchedulePage()),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text(
                            'Mon Planning',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navyDeep,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PublicPitchesPage()),
                      ),
                      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: const Text(
                        'Voir les pitchs publiés',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amber,
                        side: const BorderSide(color: AppColors.amber),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.roleMentor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../services/service_navigation.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_notifications.dart';
import 'page_pitches_publics.dart';
import 'page_planning.dart';
import 'page_profil_public.dart';
import 'page_requests.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  Stream<Map<String, int>>? _ratingsStream;

  @override
  void initState() {
    super.initState();
    final uid = AuthService.currentUid;
    if (uid != null && uid.isNotEmpty) {
      _ratingsStream = InteractionsService.getRatings(uid);
    }
  }

  // ── Suppression d'un entrepreneur ───────────────────────────────
  Future<void> _confirmDeleteEntrepreneur(
      BuildContext context, MentorRequest req) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirer cet entrepreneur ?'),
        content: Text(
            '${req.fromName} sera retiré(e) de votre liste d\'entrepreneurs mentorés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    try {
      await InteractionsService.cancelRequest(
        requestId: req.id,
        fromUserId: req.fromUserId,
        toUserId: req.toUserId,
      );
      // Met à jour le compteur local
      final p = UserProfileController.profile.value;
      UserProfileController.update(
          p.copyWith(mentorsActive: (p.mentorsActive - 1).clamp(0, 9999)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${req.fromName} retiré(e) de vos entrepreneurs.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
                          Text(
                            profile.role,
                            style: const TextStyle(
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
                  // Stats (grille 2×2)
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.school_rounded,
                          label: 'Mentorés',
                          value: '${profile.mentorsActive}',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _MesMentoresPage(),
                            ),
                          ),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.workspace_premium_rounded,
                          label: profile.yearsExperience > 1
                              ? 'Années expé.'
                              : 'Année expé.',
                          value: profile.yearsExperience > 0
                              ? '${profile.yearsExperience}'
                              : '—',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StreamBuilder<Map<String, int>>(
                          stream: _ratingsStream,
                          builder: (ctx, snap) {
                            final ratings = snap.data ?? {};
                            final avg = ratings.isEmpty
                                ? 0.0
                                : ratings.values
                                        .fold(0, (a, b) => a + b) /
                                    ratings.length;
                            final display = ratings.isEmpty
                                ? '—'
                                : avg.toStringAsFixed(1);
                            return _StatCard(
                              icon: Icons.star_rounded,
                              label: 'Note moy.',
                              value: display,
                            );
                          },
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
                        child: ValueListenableBuilder<int>(
                          valueListenable: pendingRequestsCount,
                          builder: (context, pending, _) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              OutlinedButton.icon(
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
                                  side: const BorderSide(
                                      color: AppColors.roleMentor),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                              ),
                              if (pending > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                        minWidth: 18, minHeight: 18),
                                    child: Center(
                                      child: Text(
                                        pending > 9 ? '9+' : '$pending',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null
                ? AppColors.roleMentor.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.roleMentor, size: 20),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted, size: 16),
              ],
            ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page liste des entrepreneurs mentorés
// ─────────────────────────────────────────────────────────────────
class _MesMentoresPage extends StatelessWidget {
  const _MesMentoresPage();

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUid ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Entrepreneurs')),
      body: StreamBuilder<List<MentorRequest>>(
        stream: InteractionsService.getReceivedRequests(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entrepreneurs = (snap.data ?? [])
              .where((r) =>
                  r.type == 'mentor' && r.status == RequestStatus.accepted)
              .toList();

          if (entrepreneurs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 56,
                        color: AppColors.roleMentor.withValues(alpha: 0.4)),
                    const SizedBox(height: 14),
                    const Text(
                      'Aucun entrepreneur mentoré',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Les entrepreneurs dont vous acceptez les demandes apparaîtront ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entrepreneurs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final req = entrepreneurs[i];
              return _MentoreListTile(req: req);
            },
          );
        },
      ),
    );
  }
}

class _MentoreListTile extends StatelessWidget {
  final MentorRequest req;
  const _MentoreListTile({required this.req});

  String get _initials {
    final parts = req.fromName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilPublicPage(
            uid: req.fromUserId,
            name: req.fromName,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.roleMentor.withValues(alpha: 0.15),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: AppColors.roleMentor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req.fromName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.roleEntrepreneur.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Entrepreneur',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.roleEntrepreneur,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte d'un entrepreneur (partagée entre mentor et investisseur)
// ─────────────────────────────────────────────────────────────────
class _EntrepreneurCard extends StatelessWidget {
  final String name;
  final Color accentColor;
  final VoidCallback onDelete;

  const _EntrepreneurCard({
    required this.name,
    required this.accentColor,
    required this.onDelete,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accentColor.withValues(alpha: 0.15),
            child: Text(
              _initials,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.navyDeep,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.roleEntrepreneur.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Entrepreneur',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roleEntrepreneur,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove_rounded, size: 20),
            color: AppColors.red.withValues(alpha: 0.7),
            tooltip: 'Retirer',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_notifications.dart';
import 'page_pitches_publics.dart';
import 'page_profil_public.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
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
                      background: AppColors.blue,
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
                            'Investisseur',
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
                          icon: Icons.trending_up_rounded,
                          label: 'Opportunités',
                          value: '${profile.mentorsActive}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_rounded,
                          label: 'Entrepreneurs',
                          value: '${profile.mentorsActive}',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _MesEntrepreneursPage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.bookmark_rounded,
                          label: 'Favoris',
                          value: '${profile.favoritesCount}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Ticket d'investissement (visible si renseigné)
                  if (profile.investmentRange.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_rounded,
                              color: AppColors.green, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ticket d\'investissement',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.investmentRange,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Secteurs d'intérêt
                  const Text(
                    'Secteurs d\'intérêt',
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
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PublicPitchesPage()),
                      ),
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: const Text('Explorer la communauté'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 0),
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
            color: onTap != null ? AppColors.blue.withValues(alpha: 0.35) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.blue, size: 20),
                if (onTap != null) ...[
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 14, color: AppColors.muted),
                ],
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
// Page liste des entrepreneurs de l'investisseur (tap sur la stat)
// ─────────────────────────────────────────────────────────────────
class _MesEntrepreneursPage extends StatelessWidget {
  const _MesEntrepreneursPage();

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.currentUid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Entrepreneurs')),
      body: StreamBuilder<List<MentorRequest>>(
        stream: FirebaseDatabase.instance.ref('mentorRequests').onValue.map(
          (event) {
            final data = event.snapshot.value as Map?;
            if (data == null) return <MentorRequest>[];
            final list = <MentorRequest>[];
            for (final v in data.values) {
              if (v is! Map) continue;
              final m = Map<String, dynamic>.from(v);
              if (m['type']?.toString() != 'investment') continue;
              if (m['status']?.toString() != 'accepted') continue;
              final from = m['fromUserId']?.toString() ?? '';
              final to   = m['toUserId']?.toString() ?? '';
              if (from != myUid && to != myUid) continue;
              list.add(MentorRequest.fromJson(m));
            }
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entrepreneurs = snap.data ?? [];
          if (entrepreneurs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.people_outline_rounded,
                        size: 56, color: AppColors.subtle),
                    SizedBox(height: 14),
                    Text(
                      'Aucun entrepreneur pour l\'instant.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: entrepreneurs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final req = entrepreneurs[i];
              // L'entrepreneur est la partie opposée à l'investisseur
              final entrUid  = req.fromUserId == myUid ? req.toUserId  : req.fromUserId;
              final entrName = req.fromUserId == myUid ? req.toName    : req.fromName;
              return _EntrepreneurListTile(
                name: entrName,
                uid: entrUid,
                request: req,
                myUid: myUid,
              );
            },
          );
        },
      ),
    );
  }
}

class _EntrepreneurListTile extends StatelessWidget {
  final String name;
  final String uid;
  final MentorRequest request;
  final String myUid;

  const _EntrepreneurListTile({
    required this.name,
    required this.uid,
    required this.request,
    required this.myUid,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _remove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirer cet entrepreneur ?'),
        content: Text('$name sera retiré(e) de votre liste.'),
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
    if (confirmed != true) return;
    await InteractionsService.cancelRequest(
      requestId: request.id,
      fromUserId: request.fromUserId,
      toUserId: request.toUserId,
    );
    final p = UserProfileController.profile.value;
    UserProfileController.update(
        p.copyWith(mentorsActive: (p.mentorsActive - 1).clamp(0, 9999)));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name retiré(e).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilPublicPage(uid: uid, name: name),
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
              backgroundColor: AppColors.blue.withValues(alpha: 0.15),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: AppColors.blue,
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
                      fontSize: 14,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
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
              icon: const Icon(Icons.person_remove_rounded, size: 18),
              color: AppColors.red.withValues(alpha: 0.7),
              tooltip: 'Retirer',
              onPressed: () => _remove(context),
            ),
          ],
        ),
      ),
    );
  }
}


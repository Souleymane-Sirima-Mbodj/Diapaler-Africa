import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../screens/page_profil.dart';
import '../screens/page_choix_role.dart';
import '../services/service_authentification.dart';
import '../services/service_cache.dart';
import '../services/service_navigation.dart';
import '../services/service_agenda.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import 'avatar.dart';

void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ValueListenableBuilder<UserProfile>(
              valueListenable: UserProfileController.profile,
              builder: (_, p, __) {
                return Row(
                  children: [
                    Avatar(
                      initials: p.initials,
                      size: 52,
                      background: AppColors.amber,
                      foreground: AppColors.navyDeep,
                      photoBase64: p.photoBase64,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navyDeep,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.role} · ${p.projectName}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '● en ligne',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            _Tile(
              icon: Icons.person_outline_rounded,
              label: 'Mon profil',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            ValueListenableBuilder<UserProfile>(
              valueListenable: UserProfileController.profile,
              builder: (_, p, __) {
                return Column(
                  children: [
                    _Tile(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Mes pitchs déposés',
                      trailing: '${p.projects.length}',
                    ),
                    _Tile(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Mentors favoris',
                      trailing: '${p.favoritesCount}',
                    ),
                  ],
                );
              },
            ),
            const _Tile(
              icon: Icons.language_rounded,
              label: 'Langue',
              trailing: 'FR',
            ),
            const _Tile(
              icon: Icons.settings_outlined,
              label: 'Paramètres',
            ),
            const _Tile(
              icon: Icons.help_outline_rounded,
              label: 'Aide & support',
            ),
            const Divider(height: 24),
            _LogoutTile(
              onLogout: () async {
                Navigator.of(context).pop();
                // Nettoyage complet avant déconnexion (même séquence que ProfilePage)
                await CacheService.clear();
                NotificationService.reset();
                await AgendaController.reset();
                UserProfileController.reset();
                appTabIndex.value = 0;
                await AuthService.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, a, __) => FadeTransition(
                      opacity: a,
                      child: const RoleSelectionPage(),
                    ),
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _Tile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navy, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDeep,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.subtle, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutTile({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLogout,
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red, size: 22),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.red, size: 20),
          ],
        ),
      ),
    );
  }
}

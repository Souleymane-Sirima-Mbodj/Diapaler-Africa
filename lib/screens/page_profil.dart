import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../services/service_cache.dart';
import '../services/service_navigation.dart';
import '../services/service_notifications.dart';
import '../services/service_partage.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_connexion.dart';
import 'page_nouveau_projet.dart';
import 'page_modification_profil.dart';
import 'page_agenda.dart';
import 'page_pitches_publics.dart';
import 'page_planning.dart';
import 'page_requests.dart';

/// Pourcentage de complétion du profil — basé sur les champs remplis.
double _profileCompletion(UserProfile p) {
  final fields = <bool>[
    p.firstName.isNotEmpty,
    p.lastName.isNotEmpty,
    p.email.isNotEmpty,
    p.phone.isNotEmpty,
    p.birthDate != null,
    p.address.isNotEmpty,
    p.city.isNotEmpty,
    p.country.isNotEmpty,
    p.sector.isNotEmpty,
    p.bio.isNotEmpty,
    p.linkedin.isNotEmpty,
    p.interests.isNotEmpty,
  ];
  final filled = fields.where((x) => x).length;
  return filled / fields.length;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        final completion = _profileCompletion(p);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              // Partage
              IconButton(
                tooltip: 'Partager mon profil',
                onPressed: () => ShareService.shareMyProfile(
                  name: p.fullName,
                  role: p.role,
                  sector: p.sector,
                  city: p.city,
                  projectName: p.projects.isNotEmpty ? p.projects.first.name : null,
                ),
                icon: const Icon(Icons.share_rounded),
              ),
              // Modifier
              IconButton(
                tooltip: 'Modifier',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const EditProfilePage(),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
              ),
              // Déconnexion (icône discrète dans l'AppBar)
              IconButton(
                tooltip: 'Se déconnecter',
                onPressed: () => _LogoutButton.confirmAndLogout(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.red),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // 1. Carte identité (photo, nom, rôle, complétion)
              _IdentityCard(profile: p, completion: completion),
              const SizedBox(height: 16),
              // 2. Stats (tappables)
              const _StatsStrip(),
              const SizedBox(height: 16),
              // 3. Bio + Coordonnées principales (condensées) + Intérêts
              _AboutCard(profile: p),
              const SizedBox(height: 12),
              _CompactCoordsCard(profile: p),
              const SizedBox(height: 12),
              _InterestsCard(interests: p.interests),
              // 4. Projets (Entrepreneur uniquement)
              if (p.role == 'Entrepreneur' || p.role == 'Entrepreneure') ...[
                const SizedBox(height: 16),
                _ProjectsSection(profile: p),
              ],
              // 5. Boutons d'actions rapides (Entrepreneur uniquement)
              if (p.role == 'Entrepreneur' || p.role == 'Entrepreneure') ...[
                const SizedBox(height: 16),
                const _InteractionsSection(),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Identity
// ─────────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserProfile profile;
  final double completion;
  const _IdentityCard({required this.profile, required this.completion});

  @override
  Widget build(BuildContext context) {
    final percent = (completion * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.amber, width: 2),
                    ),
                    child: Avatar(
                      initials: profile.initials,
                      size: 64,
                      background: AppColors.amber,
                      foreground: AppColors.navyDeep,
                      photoBase64: profile.photoBase64,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.role} · ${profile.sector}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            color: AppColors.amber, size: 13),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Text('  ·  🇸🇳', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barre de complétion du profil
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  color: AppColors.amber, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Profil complété',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '$percent %',
                style: const TextStyle(
                  color: AppColors.amber,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stats strip — compacte
// ─────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    final p = UserProfileController.profile.value;
    final pitchsTotal = p.projects.length;
    final completed = p.projects.where((x) => x.isCompleted).length;

    // Labels et valeurs adaptés à chaque rôle
    final List<_MiniStat> items;

    if (p.role == 'Mentor') {
      items = [
        _MiniStat(
            icon: Icons.school_rounded,
            color: AppColors.roleMentor,
            value: '${p.mentorsActive}',
            label: 'Mentorés',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsPage()),
                )),
        _MiniStat(
            icon: Icons.calendar_month_rounded,
            color: AppColors.blue,
            value: '${p.sessionsCount}',
            label: 'Sessions',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AgendaPage()),
                )),
        _MiniStat(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.amber,
            value: p.yearsExperience > 0 ? '${p.yearsExperience}' : '—',
            label: 'Années expé.'),
        _MiniStat(
            icon: Icons.bookmark_rounded,
            color: AppColors.red,
            value: '${p.favoritesCount}',
            label: 'Favoris',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Fonctionnalité favoris disponible prochainement'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )),
      ];
    } else if (p.role == 'Investisseur') {
      items = [
        _MiniStat(
            icon: Icons.trending_up_rounded,
            color: AppColors.blue,
            value: '${p.mentorsActive}',
            label: 'Contacts',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsPage()),
                )),
        _MiniStat(
            icon: Icons.rocket_launch_rounded,
            color: AppColors.amber,
            value: '${p.sessionsCount}',
            label: 'Pitchs vus',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PublicPitchesPage()),
                )),
        _MiniStat(
            icon: Icons.bookmark_rounded,
            color: AppColors.red,
            value: '${p.favoritesCount}',
            label: 'Favoris',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Fonctionnalité favoris disponible prochainement'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )),
        _MiniStat(
            icon: Icons.calendar_today_rounded,
            color: AppColors.green,
            value: '${p.sessionsCount}',
            label: 'Rendez-vous',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AgendaPage()),
                )),
      ];
    } else {
      // Entrepreneur / Entrepreneure
      items = [
        _MiniStat(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.amber,
            value: '$pitchsTotal',
            label: 'Projets',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consulte la section "Mes projets" ci-dessous.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )),
        _MiniStat(
            icon: Icons.check_circle_rounded,
            color: AppColors.green,
            value: '$completed',
            label: 'Terminés',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consulte la section "Mes projets" ci-dessous.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )),
        _MiniStat(
            icon: Icons.handshake_rounded,
            color: AppColors.blue,
            value: '${p.mentorsActive}',
            label: 'Mentors',
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsPage()),
                )),
        _MiniStat(
            icon: Icons.bookmark_rounded,
            color: AppColors.red,
            value: '${p.favoritesCount}',
            label: 'Favoris',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Fonctionnalité favoris disponible prochainement'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )),
      ];
    }
    return SizedBox(
      height: 74,
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              child: items[i],
            ),
          );
        }),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null ? AppColors.blue.withValues(alpha: 0.35) : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDeep,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                height: 1.2,
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
// Coordonnées condensées (email + téléphone + ville uniquement)
// ─────────────────────────────────────────────────────────────────
class _CompactCoordsCard extends StatelessWidget {
  final UserProfile profile;
  const _CompactCoordsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Email
          Expanded(
            child: _CompactRow(
              icon: Icons.mail_outline_rounded,
              text: profile.email.isEmpty ? '—' : profile.email,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          // Téléphone
          Expanded(
            child: _CompactRow(
              icon: Icons.phone_outlined,
              text: profile.phone.isEmpty ? 'Non renseigné' : profile.phone,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          // Ville
          Expanded(
            child: _CompactRow(
              icon: Icons.place_outlined,
              text: profile.city.isEmpty ? '—' : profile.city,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CompactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(height: 4),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDeep,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Mes projets — liste + bouton Nouveau
// ─────────────────────────────────────────────────────────────────
class _ProjectsSection extends StatelessWidget {
  final UserProfile profile;
  const _ProjectsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🚀  Mes projets',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            Text(
              '${profile.projects.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (profile.projects.isEmpty)
          const _EmptyProjects()
        else ...[
          ...profile.projects.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProjectTile(project: p),
            ),
          ),
          _NewProjectButton(canStart: profile.canStartNewProject),
        ],
      ],
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;
  const _ProjectTile({required this.project});

  /// Affiche les actions disponibles pour le projet (avancer / supprimer).
  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Modifier
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: AppColors.blue, size: 20),
              ),
              title: const Text(
                'Modifier le projet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => AddProjectPage(existingProject: project),
                  ),
                );
              },
            ),
            if (!project.isCompleted)
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: AppColors.green, size: 20),
                ),
                title: const Text(
                  'Avancer d\'une étape',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  'Étape ${project.step} → ${project.step + 1} / '
                  '${project.totalSteps}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  UserProfileController.updateProject(
                    project.copyWith(step: project.step + 1),
                  );
                },
              ),
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.red, size: 20),
              ),
              title: const Text(
                'Supprimer le projet',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.red,
                ),
              ),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Demande confirmation avant de supprimer définitivement le projet.
  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Supprimer ce projet ?'),
        content: Text(
          '« ${project.name} » sera définitivement supprimé de ton profil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              UserProfileController.deleteProject(project.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = project.isCompleted;
    final accent = completed ? AppColors.green : AppColors.amber;

    return HoverGlowCard(
      onTap: () => _showActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    Text(
                      project.sector,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(completed: completed),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Étape ${project.step} / ${project.totalSteps}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(project.progress * 100).round()} %',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: project.progress,
              minHeight: 5,
              backgroundColor: AppColors.fieldBg,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool completed;
  const _StatusBadge({required this.completed});

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppColors.green : AppColors.amber;
    final label = completed ? 'TERMINÉ' : 'EN COURS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AddProjectPage(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Démarre ton premier projet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tape ici pour créer ton projet entrepreneurial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewProjectButton extends StatelessWidget {
  final bool canStart;
  const _NewProjectButton({required this.canStart});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: canStart
          ? 'Démarrer un nouveau projet'
          : 'Termine ton projet en cours (5/5) avant d\'en créer un nouveau',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: canStart
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const AddProjectPage(),
                    ),
                  )
              : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(
            'Nouveau projet',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: canStart ? AppColors.navy : AppColors.subtle,
            side: BorderSide(
              color: canStart ? AppColors.border : AppColors.border,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Domaines d'intérêt + À propos
// ─────────────────────────────────────────────────────────────────
class _InterestsCard extends StatelessWidget {
  final List<String> interests;
  const _InterestsCard({required this.interests});

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
          const Text(
            "🏷️  Domaines d'intérêt",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          if (interests.isEmpty)
            const Text(
              'Aucun domaine sélectionné. Modifie ton profil pour en ajouter.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: interests
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.blueTint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final UserProfile profile;
  const _AboutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio.isNotEmpty;
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
          const Text(
            '📝  À propos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          if (hasBio)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 38,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navyDeep,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.amber, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Ajoute une bio pour te présenter aux mentors et investisseurs.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // ── Infos pro + LinkedIn (si renseignés) ─────────────
          if (profile.yearsExperience > 0 ||
              profile.investmentRange.isNotEmpty ||
              profile.linkedin.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Années d'expérience (Mentor)
                if (profile.yearsExperience > 0)
                  _ProChip(
                    icon: Icons.workspace_premium_rounded,
                    label: '${profile.yearsExperience} ans d\'expérience',
                    color: AppColors.roleMentor,
                  ),
                // Ticket d'investissement (Investisseur)
                if (profile.investmentRange.isNotEmpty)
                  _ProChip(
                    icon: Icons.payments_rounded,
                    label: profile.investmentRange,
                    color: AppColors.roleInvestor,
                  ),
                // LinkedIn (cliquable)
                if (profile.linkedin.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      var url = profile.linkedin.trim();
                      if (!url.startsWith('http')) url = 'https://$url';
                      final uri = Uri.tryParse(url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const _ProChip(
                      icon: Icons.link_rounded,
                      label: 'LinkedIn',
                      color: AppColors.blue,
                      tappable: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool tappable;
  const _ProChip({
    required this.icon,
    required this.label,
    required this.color,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 11, color: color),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Interactions Section
// ─────────────────────────────────────────────────────────────────
class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection();

  @override
  Widget build(BuildContext context) {
    final p = UserProfileController.profile.value;
    final role = p.role;

    // Boutons affichés selon le rôle :
    // • Entrepreneur  → "Mes demandes" seulement
    // • Mentor        → "Planning" + "Demandes reçues"
    // • Investisseur  → "Pitchs publiés" seulement
    List<Widget> buttons;
    if (role == 'Mentor') {
      buttons = [
        Expanded(
          child: _InteractionButton(
            icon: Icons.calendar_today_rounded,
            label: 'Planning',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InteractionButton(
            icon: Icons.mail_rounded,
            label: 'Demandes reçues',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RequestsPage()),
            ),
          ),
        ),
      ];
    } else if (role == 'Investisseur') {
      buttons = [
        Expanded(
          child: _InteractionButton(
            icon: Icons.bar_chart_rounded,
            label: 'Pitchs publiés',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PublicPitchesPage()),
            ),
          ),
        ),
      ];
    } else {
      // Entrepreneur / Entrepreneure
      buttons = [
        Expanded(
          child: _InteractionButton(
            icon: Icons.people_rounded,
            label: 'Mes contacts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RequestsPage()),
            ),
          ),
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        const SizedBox(height: 10),
        Row(children: buttons),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.blue, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bouton "Se déconnecter" en bas de page
// ─────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  // Statique pour être appelable depuis l'AppBar
  static Future<void> confirmAndLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Tu devras te reconnecter pour accéder à ton tableau de bord.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
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
          child: const LoginPage(),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => confirmAndLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

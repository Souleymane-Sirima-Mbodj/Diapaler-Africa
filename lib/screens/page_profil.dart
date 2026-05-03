// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_nouveau_projet.dart';
import 'page_modification_profil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
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
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _IdentityCard(profile: p),
              const SizedBox(height: 14),
              const _StatsStrip(),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _CoordsCard(profile: p)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              _InterestsCard(interests: p.interests),
                              const SizedBox(height: 14),
                              _AboutCard(profile: p),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _CoordsCard(profile: p),
                      const SizedBox(height: 14),
                      _InterestsCard(interests: p.interests),
                      const SizedBox(height: 14),
                      _AboutCard(profile: p),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              _ProjectsSection(profile: p),
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
  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
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
                    Text(
                      profile.city,
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
    final items = [
      _MiniStat(
          icon: Icons.workspace_premium_rounded,
          color: AppColors.amber,
          value: '$pitchsTotal',
          label: 'Projets'),
      _MiniStat(
          icon: Icons.check_circle_rounded,
          color: AppColors.green,
          value: '$completed',
          label: 'Terminés'),
      _MiniStat(
          icon: Icons.handshake_rounded,
          color: AppColors.blue,
          value: '${p.mentorsActive}',
          label: 'Mentors'),
      _MiniStat(
          icon: Icons.bookmark_rounded,
          color: AppColors.red,
          value: '${p.favoritesCount}',
          label: 'Favoris'),
    ];
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
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Coordonnées
// ─────────────────────────────────────────────────────────────────
class _CoordsCard extends StatelessWidget {
  final UserProfile profile;
  const _CoordsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final rows = <_CoordEntry>[
      _CoordEntry(
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        value: profile.email,
      ),
      _CoordEntry(
        icon: Icons.phone_outlined,
        label: 'Téléphone',
        value: profile.phone.isEmpty ? '—' : profile.phone,
      ),
      _CoordEntry(
        icon: Icons.wc_rounded,
        label: 'Sexe',
        value: profile.gender.label,
      ),
      if (profile.birthDate != null)
        _CoordEntry(
          icon: Icons.cake_outlined,
          label: 'Naissance',
          value:
              '${profile.birthDate!.day.toString().padLeft(2, '0')}/${profile.birthDate!.month.toString().padLeft(2, '0')}/${profile.birthDate!.year}'
              '${profile.age != null ? "  ·  ${profile.age} ans" : ""}',
        ),
      if (profile.address.isNotEmpty)
        _CoordEntry(
          icon: Icons.home_outlined,
          label: 'Adresse',
          value: profile.address,
        ),
      _CoordEntry(
        icon: Icons.public_rounded,
        label: 'Pays',
        value: profile.country,
      ),
      if (profile.linkedin.isNotEmpty)
        _CoordEntry(
          icon: Icons.link_rounded,
          label: 'LinkedIn',
          value: profile.linkedin,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _CoordRow(
              icon: rows[i].icon,
              label: rows[i].label,
              value: rows[i].value,
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, indent: 56, endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _CoordEntry {
  final IconData icon;
  final String label;
  final String value;
  _CoordEntry({required this.icon, required this.label, required this.value});
}

class _CoordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CoordRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.blueTint,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: AppColors.navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final completed = project.isCompleted;
    final accent = completed ? AppColors.green : AppColors.amber;

    return HoverGlowCard(
      padding: const EdgeInsets.all(14),
      onTap: () {},
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
      // TODO: réactiver — Navigator.push(AddProjectPage)
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.5),
            width: 1.5,
            style: BorderStyle.solid,
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
          // TODO: réactiver — Navigator.push(AddProjectPage)
          onPressed: canStart ? () {} : null,
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
          Text(
            profile.bio,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.navyDeep,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

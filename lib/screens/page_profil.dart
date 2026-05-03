// ignore_for_file: unused_import, unused_element
import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import '../widgets/carte_lumineuse.dart';
import 'page_choix_role.dart';
import 'page_nouveau_projet.dart';
import 'page_modification_profil.dart';

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
              _IdentityCard(profile: p, completion: completion),
              // TODO: réactiver — _AchievementsRow(profile: p, completion: completion)
              //   quand les flows "Créer un projet" et "Devenir mentoré" seront
              //   rebranchés (sinon 3 badges sur 4 restent verrouillés et confus).
              if (completion < 1.0) ...[
                const SizedBox(height: 14),
                _CompleteProfileCta(percent: completion),
              ],
              const SizedBox(height: 18),
              const _StatsStrip(),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _AboutCard(profile: p),
                              const SizedBox(height: 14),
                              _CoordsCard(profile: p),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: _InterestsCard(interests: p.interests)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _AboutCard(profile: p),
                      const SizedBox(height: 14),
                      _CoordsCard(profile: p),
                      const SizedBox(height: 14),
                      _InterestsCard(interests: p.interests),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              _ProjectsSection(profile: p),
              const SizedBox(height: 22),
              const _LogoutButton(),
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
                      "Ajoute une bio pour te présenter aux mentors et investisseurs.",
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Succès / badges — gamification
// ─────────────────────────────────────────────────────────────────
class _AchievementsRow extends StatelessWidget {
  final UserProfile profile;
  final double completion;
  const _AchievementsRow({required this.profile, required this.completion});

  @override
  Widget build(BuildContext context) {
    final items = <_Achievement>[
      const _Achievement(
        icon: Icons.verified_rounded,
        label: 'Inscrit',
        unlocked: true,
        color: AppColors.green,
      ),
      _Achievement(
        icon: Icons.rocket_launch_rounded,
        label: '1er projet',
        unlocked: profile.projects.isNotEmpty,
        color: AppColors.amber,
      ),
      _Achievement(
        icon: Icons.handshake_rounded,
        label: 'Mentoré',
        unlocked: profile.mentorsActive > 0,
        color: AppColors.blue,
      ),
      _Achievement(
        icon: Icons.workspace_premium_rounded,
        label: 'Profil complet',
        unlocked: completion >= 1.0,
        color: AppColors.purple,
      ),
    ];
    return SizedBox(
      height: 76,
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              child: _AchievementChip(item: items[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final bool unlocked;
  final Color color;
  const _Achievement({
    required this.icon,
    required this.label,
    required this.unlocked,
    required this.color,
  });
}

class _AchievementChip extends StatelessWidget {
  final _Achievement item;
  const _AchievementChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final unlocked = item.unlocked;
    final color = unlocked ? item.color : AppColors.subtle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.15)
                  : AppColors.fieldBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? item.icon : Icons.lock_outline_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: unlocked ? AppColors.navyDeep : AppColors.subtle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CTA "Compléter mon profil" — visible si <100%
// ─────────────────────────────────────────────────────────────────
class _CompleteProfileCta extends StatelessWidget {
  final double percent;
  const _CompleteProfileCta({required this.percent});

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - percent) * 100).round();
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const EditProfilePage(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.amber.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complète ton profil',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Plus ton profil est complet, plus tu reçois de propositions.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+$remaining %',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
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

  Future<void> _confirmAndLogout(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmAndLogout(context),
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

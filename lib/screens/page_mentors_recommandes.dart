import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';
import '../widgets/carte_mentor.dart';

/// Liste complète des mentors recommandés pour l'utilisateur en cours,
/// filtrés selon le secteur de son profil, ses centres d'intérêt
/// et les secteurs de ses projets.
class RecommendedMentorsPage extends StatelessWidget {
  const RecommendedMentorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentors recommandés'),
      ),
      body: ValueListenableBuilder<UserProfile>(
        valueListenable: UserProfileController.profile,
        builder: (_, p, __) {
          final recos = recommendedMentorsFor(
            userSector: p.sector,
            userInterests: p.interests,
            projectSectors: p.projects.map((pr) => pr.sector).toList(),
          );

          if (recos.isEmpty) {
            return const _EmptyRecos();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _Header(profile: p, count: recos.length),
              const SizedBox(height: 14),
              for (final m in recos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MentorCard(mentor: m),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProfile profile;
  final int count;
  const _Header({required this.profile, required this.count});

  @override
  Widget build(BuildContext context) {
    final tags = <String>{};
    if (profile.sector.isNotEmpty && profile.sector != 'Autre') {
      tags.add(profile.sector);
    }
    for (final pr in profile.projects) {
      if (pr.sector.isNotEmpty) tags.add(pr.sector);
    }
    tags.addAll(profile.interests);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blueTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.amber, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count mentor${count > 1 ? "s" : ""} pour toi',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const Text(
                      'Sélection basée sur ton profil',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.take(6).map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyRecos extends StatelessWidget {
  const _EmptyRecos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.fieldBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.subtle, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucun mentor recommandé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choisis tes centres d\'intérêt dans ton profil pour voir des mentors adaptés.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

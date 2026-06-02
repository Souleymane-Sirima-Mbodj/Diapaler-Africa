import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../services/service_authentification.dart';
import '../services/service_favoris.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_detail_mentor.dart';

/// Page listant tous les mentors/investisseurs mis en favori.
/// Réactive : se met à jour en temps réel via [FavoriteService.favorites].
class MesFavorisPage extends StatelessWidget {
  const MesFavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.currentUid ?? '';

    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mes favoris',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        foregroundColor: AppColors.navyDeep,
      ),
      body: ValueListenableBuilder<List<Mentor>>(
        valueListenable: FavoriteService.favorites,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, i) => _FavCard(
              mentor: list[i],
              userId: myUid,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte d'un favori
// ─────────────────────────────────────────────────────────────────

class _FavCard extends StatelessWidget {
  final Mentor mentor;
  final String userId;

  const _FavCard({required this.mentor, required this.userId});

  Color get _roleColor =>
      mentor.isInvestor ? AppColors.green : AppColors.roleMentor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Avatar(
          initials: mentor.initials,
          background: _roleColor,
          photoBase64: mentor.photoBase64,
        ),
        title: Text(
          mentor.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.navyDeep,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              mentor.title,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mentor.isInvestor ? 'Investisseur' : 'Mentor',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _roleColor,
                    ),
                  ),
                ),
                if (mentor.city.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.place_rounded,
                      size: 11, color: AppColors.muted),
                  const SizedBox(width: 2),
                  Text(
                    mentor.city,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton retirer du favori
            GestureDetector(
              onTap: () => FavoriteService.toggle(userId, mentor),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.favorite_rounded,
                    color: AppColors.red, size: 20),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MentorDetailPage(mentor: mentor),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  size: 40, color: AppColors.red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun favori pour l\'instant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuie sur ❤ sur le profil d\'un mentor\nou investisseur pour le retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

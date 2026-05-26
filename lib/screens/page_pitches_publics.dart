import 'package:flutter/material.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';

/// Liste temps réel de tous les pitchs publiés par les entrepreneurs.
/// Accessible depuis les dashboards Mentor et Investisseur.
class PublicPitchesPage extends StatelessWidget {
  const PublicPitchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pitchs publiés',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService.getPitches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            );
          }

          final pitches = snapshot.data ?? [];

          if (pitches.isEmpty) {
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
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.subtle,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Aucun pitch publié',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Les pitchs des entrepreneurs apparaîtront ici dès qu\'ils sont publiés.',
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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
            itemCount: pitches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PitchCard(pitch: pitches[i]),
          );
        },
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final Map<String, dynamic> pitch;
  const _PitchCard({required this.pitch});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final title = pitch['title']?.toString() ?? 'Pitch sans titre';
    final userName = pitch['userName']?.toString() ?? 'Entrepreneur';
    final sector = pitch['sector']?.toString() ?? '';
    final description = pitch['description']?.toString() ?? '';
    final amount = pitch['amount']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête entrepreneur
          Row(
            children: [
              Avatar(
                initials: _initials(userName),
                size: 40,
                background: AppColors.amber,
                foreground: AppColors.navyDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const Text(
                      'Entrepreneur',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (sector.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sector,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Titre du pitch
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDeep,
            ),
          ),

          // Description
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ],

          // Besoin de financement
          if (amount.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.payments_rounded,
                          size: 13, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        '$amount FCFA',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  size: 14, color: AppColors.muted),
              const SizedBox(width: 5),
              const Text(
                'Pitch publié · En attente de mentor',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contacter $userName via la messagerie.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.navy,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                ),
                child: const Text(
                  'Contacter  →',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

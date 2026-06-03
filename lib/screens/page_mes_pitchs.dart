import 'package:flutter/material.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import 'page_detail_pitch.dart';
import 'page_pitch.dart';

/// Liste temps réel des pitchs publiés par l'utilisateur connecté.
class MesPitchsPage extends StatelessWidget {
  const MesPitchsPage({super.key});

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
          'Mes pitchs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        foregroundColor: AppColors.navyDeep,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService.getMyPitches(myUid),
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
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: pitches.length,
            itemBuilder: (context, i) => _PitchCard(pitch: pitches[i]),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte d'un pitch
// ─────────────────────────────────────────────────────────────────

class _PitchCard extends StatelessWidget {
  final Map<String, dynamic> pitch;
  const _PitchCard({required this.pitch});

  String get _title => pitch['title']?.toString() ?? 'Sans titre';
  String get _sector => pitch['sector']?.toString() ?? '';
  String get _amount => pitch['amount']?.toString() ?? '';
  String get _description => pitch['description']?.toString() ?? '';

  DateTime? get _createdAt {
    final v = pitch['createdAt'];
    if (v == null) return null;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String get _dateLabel {
    final d = _createdAt;
    if (d == null) return '';
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String get _summary {
    if (_description.isEmpty) return 'Aucune description.';
    return _description.length > 120
        ? '${_description.substring(0, 120)}…'
        : _description;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PitchDetailPage(pitch: pitch),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // ── Header dégradé ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyDeep, AppColors.navy],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        color: AppColors.amber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_dateLabel.isNotEmpty)
                          Text(
                            'Publié le $_dateLabel',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white60),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white54, size: 20),
                ],
              ),
            ),

            // ── Corps ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips secteur + montant
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (_sector.isNotEmpty)
                        _MiniChip(
                          label: _sector,
                          color: AppColors.blue,
                          icon: Icons.category_rounded,
                        ),
                      if (_amount.isNotEmpty)
                        _MiniChip(
                          label: '$_amount FCFA',
                          color: AppColors.green,
                          icon: Icons.payments_rounded,
                        ),
                      const _MiniChip(
                        label: 'Public',
                        color: AppColors.purple,
                        icon: Icons.public_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Résumé description
                  Text(
                    _summary,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
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
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.upload_file_rounded,
                  size: 40, color: AppColors.purple),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun pitch publié',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dépose ton premier pitch pour le rendre\nvisible aux mentors et investisseurs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const PitchPage(),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Déposer un pitch'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

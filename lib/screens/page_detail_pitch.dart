import 'package:flutter/material.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';

/// Page de détail d'un pitch publié.
/// Reçoit la map brute Firebase du pitch.
class PitchDetailPage extends StatelessWidget {
  final Map<String, dynamic> pitch;

  const PitchDetailPage({super.key, required this.pitch});

  String get _title => pitch['title']?.toString() ?? 'Sans titre';
  String get _sector => pitch['sector']?.toString() ?? '';
  String get _description => pitch['description']?.toString() ?? '';
  String get _amount => pitch['amount']?.toString() ?? '';
  String get _pitchId => pitch['id']?.toString() ?? '';
  String get _userName => pitch['userName']?.toString() ?? '';

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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce pitch ?'),
        content: Text(
          'Le pitch "$_title" sera définitivement supprimé.\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await DatabaseService.deletePitch(_pitchId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pitch supprimé.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navyDeep,
            foregroundColor: Colors.white,
            expandedHeight: 160,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Supprimer ce pitch',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 60, 14),
              title: Text(
                _title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meta chips ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_sector.isNotEmpty)
                        _Chip(
                          icon: Icons.category_rounded,
                          label: _sector,
                          color: AppColors.blue,
                        ),
                      if (_amount.isNotEmpty)
                        _Chip(
                          icon: Icons.payments_rounded,
                          label: '$_amount FCFA',
                          color: AppColors.green,
                        ),
                      if (_dateLabel.isNotEmpty)
                        _Chip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Publié le $_dateLabel',
                          color: AppColors.muted,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Description ──
                  _SectionCard(
                    icon: Icons.description_rounded,
                    title: 'Description du projet',
                    color: AppColors.purple,
                    child: Text(
                      _description.isNotEmpty
                          ? _description
                          : 'Aucune description renseignée.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navyDeep,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Financement ──
                  _SectionCard(
                    icon: Icons.monetization_on_rounded,
                    title: 'Besoin de financement',
                    color: AppColors.green,
                    child: _amount.isEmpty
                        ? const Text(
                            'Non renseigné',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.muted),
                          )
                        : Row(
                            children: [
                              Text(
                                _amount,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.navyDeep,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'FCFA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),

                  // ── Visibilité ──
                  _SectionCard(
                    icon: Icons.visibility_rounded,
                    title: 'Visibilité',
                    color: AppColors.amber,
                    child: const Row(
                      children: [
                        Icon(Icons.public_rounded,
                            size: 16, color: AppColors.green),
                        SizedBox(width: 8),
                        Text(
                          'Visible par tous les mentors & investisseurs',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.navyDeep),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Documents (PDF / Vidéo) — à venir ──
                  _SectionCard(
                    icon: Icons.attach_file_rounded,
                    title: 'Documents & Médias',
                    color: AppColors.roleMentor,
                    child: Column(
                      children: [
                        _DocRow(
                          icon: Icons.picture_as_pdf_rounded,
                          color: AppColors.red,
                          label: 'Business Plan (PDF)',
                          available: false,
                        ),
                        const SizedBox(height: 10),
                        _DocRow(
                          icon: Icons.videocam_rounded,
                          color: AppColors.purple,
                          label: 'Vidéo de présentation',
                          available: false,
                        ),
                        const SizedBox(height: 10),
                        _DocRow(
                          icon: Icons.image_rounded,
                          color: AppColors.blue,
                          label: 'Deck / Présentation',
                          available: false,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    AppColors.amber.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: AppColors.amber),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'L\'upload de fichiers sera disponible dans une prochaine mise à jour.',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ── Bouton supprimer ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.red),
                      label: const Text(
                        'Supprimer ce pitch',
                        style: TextStyle(color: AppColors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Composants internes
// ─────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
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
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool available;
  const _DocRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: available
                ? color.withValues(alpha: 0.12)
                : AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: available ? color : AppColors.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: available ? AppColors.navyDeep : AppColors.muted,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: available
                ? AppColors.green.withValues(alpha: 0.1)
                : AppColors.border,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            available ? 'Ajouté' : 'À venir',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: available ? AppColors.green : AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

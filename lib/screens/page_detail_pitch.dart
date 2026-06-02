import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
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

  Future<void> _showEditSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PitchEditSheet(pitch: pitch),
    );
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
                onPressed: () => _showEditSheet(context),
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Modifier ce pitch',
              ),
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

                  // ── Bouton modifier ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditSheet(context),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text(
                        'Modifier ce pitch',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

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

// ─────────────────────────────────────────────────────────────────
// Bottom sheet — Modifier un pitch (Update du CRUD)
// ─────────────────────────────────────────────────────────────────

class _PitchEditSheet extends StatefulWidget {
  final Map<String, dynamic> pitch;
  const _PitchEditSheet({required this.pitch});

  @override
  State<_PitchEditSheet> createState() => _PitchEditSheetState();
}

class _PitchEditSheetState extends State<_PitchEditSheet> {
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _amount;
  String? _sector;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
        text: widget.pitch['title']?.toString() ?? '');
    _description = TextEditingController(
        text: widget.pitch['description']?.toString() ?? '');
    _amount = TextEditingController(
        text: widget.pitch['amount']?.toString() ?? '');
    _sector = widget.pitch['sector']?.toString();

    for (final c in [_title, _description, _amount]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  bool get _valid =>
      _title.text.trim().length >= 3 &&
      _sector != null &&
      _description.text.trim().length >= 10;

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _loading = true);
    try {
      final pitchId = widget.pitch['id']?.toString() ?? '';
      await DatabaseService.updatePitch(
        pitchId: pitchId,
        title: _title.text.trim(),
        sector: _sector!,
        description: _description.text.trim(),
        amount: _amount.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pitch mis à jour ✓'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            // Poignée
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: AppColors.amber, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Modifier le pitch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Titre
                  const Text('Titre *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(
                      hintText: 'Titre du projet',
                      prefixIcon: const Icon(Icons.title_rounded,
                          color: AppColors.subtle),
                      suffixIcon: _title.text.isNotEmpty
                          ? Icon(
                              _title.text.trim().length >= 3
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _title.text.trim().length >= 3
                                  ? AppColors.green
                                  : AppColors.red,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secteur
                  const Text('Secteur *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sector,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.subtle),
                    decoration: const InputDecoration(
                      hintText: 'Choisis un secteur',
                      prefixIcon: Icon(Icons.category_rounded,
                          color: AppColors.subtle),
                    ),
                    items: allSectors
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.navyDeep)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _sector = v),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description *',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _description,
                    maxLines: 8,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Décris ton projet en détail…',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Montant
                  const Text('Besoin de financement (FCFA)',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '5 000 000',
                      prefixIcon: Icon(Icons.payments_rounded,
                          color: AppColors.subtle),
                      suffixText: 'FCFA',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton sauvegarder
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_loading || !_valid) ? null : _save,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                            AppColors.navy.withValues(alpha: 0.35),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ENREGISTRER LES MODIFICATIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

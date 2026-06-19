import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_cloudinary.dart';
import '../services/service_partage.dart';
import '../theme/theme_app.dart';

/// Page de détail d'un pitch publié (vue propriétaire — entrepreneur).
class PitchDetailPage extends StatefulWidget {
  final Map<String, dynamic> pitch;

  const PitchDetailPage({super.key, required this.pitch});

  @override
  State<PitchDetailPage> createState() => _PitchDetailPageState();
}

class _PitchDetailPageState extends State<PitchDetailPage> {
  late Map<String, dynamic> _pitch;

  // ── URLs des documents (null = pas encore uploadé) ──────────────
  String? _businessPlanUrl;
  String? _videoUrl;
  String? _deckUrl;

  // ── Types en cours d'upload ─────────────────────────────────────
  final Set<String> _uploading = {};

  @override
  void initState() {
    super.initState();
    _pitch = Map<String, dynamic>.from(widget.pitch);
    _businessPlanUrl = _pitch['businessPlanUrl']?.toString();
    _videoUrl = _pitch['videoUrl']?.toString();
    _deckUrl = _pitch['deckUrl']?.toString();
  }

  // ── Getters ─────────────────────────────────────────────────────
  String get _title => _pitch['title']?.toString() ?? 'Sans titre';
  String get _sector => _pitch['sector']?.toString() ?? '';
  String get _description => _pitch['description']?.toString() ?? '';
  String get _amount => _pitch['amount']?.toString() ?? '';
  String get _pitchId => _pitch['id']?.toString() ?? '';

  DateTime? get _createdAt {
    final v = _pitch['createdAt'];
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

  String? _urlFromType(String type) {
    switch (type) {
      case 'businessPlan': return _businessPlanUrl;
      case 'video':        return _videoUrl;
      case 'deck':         return _deckUrl;
    }
    return null;
  }

  void _setUrl(String type, String? url) {
    setState(() {
      switch (type) {
        case 'businessPlan': _businessPlanUrl = url; break;
        case 'video':        _videoUrl        = url; break;
        case 'deck':         _deckUrl         = url; break;
      }
    });
  }

  String _labelFromType(String type) {
    switch (type) {
      case 'businessPlan': return 'Business Plan';
      case 'video':        return 'Vidéo de présentation';
      case 'deck':         return 'Deck / Présentation';
    }
    return type;
  }

  // ── Upload vers Cloudinary ───────────────────────────────────────
  Future<void> _uploadDocument({
    required String type,
    required String dbField,
    required FileType fileType,
    List<String>? allowedExtensions,
    required int maxMb,
  }) async {
    // 1. Sélection du fichier
    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final pf = result.files.first;
    if (pf.path == null) return;

    // 2. Vérification taille
    if (pf.size > maxMb * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Fichier trop volumineux (max $maxMb Mo). '
          'Taille : ${(pf.size / (1024 * 1024)).toStringAsFixed(1)} Mo.',
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // 3. Upload Cloudinary
    setState(() => _uploading.add(type));
    try {
      final url = await CloudinaryService.uploadFile(
        filePath: pf.path!,
        resourceType: _resourceType(type),
        folder: 'pitches/$_pitchId',
      );

      // 4. Sauvegarde URL en base Firebase
      await DatabaseService.updatePitchDocumentUrl(
        pitchId: _pitchId,
        field: dbField,
        url: url,
      );

      _setUrl(type, url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_labelFromType(type)} uploadé ✓'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _uploading.remove(type));
    }
  }

  String _resourceType(String type) {
    if (type == 'video') return 'video';
    return 'auto'; // Cloudinary détecte automatiquement image/raw (PDF)
  }

  // ── Suppression d'un document ────────────────────────────────────
  /// Retire le lien de la base Firebase. Le fichier reste sur Cloudinary
  /// (la suppression côté Cloudinary nécessite la clé API secrète — non
  /// stockée côté client).
  Future<void> _deleteDocument(String type, String dbField) async {
    final label = _labelFromType(type);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Retirer "$label" ?'),
        content: const Text(
          'Le document sera retiré du pitch. Tu pourras en uploader un nouveau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await DatabaseService.updatePitchDocumentUrl(
        pitchId: _pitchId,
        field: dbField,
        url: null,
      );
      _setUrl(type, null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Ouvrir un document ───────────────────────────────────────────
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible d\'ouvrir ce fichier.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Actions pitch ────────────────────────────────────────────────
  Future<void> _showEditSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PitchEditSheet(pitch: _pitch),
    );
  }

  Future<void> _confirmDelete() async {
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
    if (confirmed == true && mounted) {
      await DatabaseService.deletePitch(_pitchId);
      if (mounted) {
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

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fieldBg,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ───────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navyDeep,
            foregroundColor: Colors.white,
            expandedHeight: 160,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => ShareService.sharePitch(
                  title: _title,
                  sector: _sector,
                  description: _description,
                  authorName: UserProfileController.profile.value.fullName,
                  amount: _amount.isNotEmpty ? _amount : null,
                ),
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Partager ce pitch',
              ),
              IconButton(
                onPressed: _showEditSheet,
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Modifier ce pitch',
              ),
              IconButton(
                onPressed: _confirmDelete,
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
                  // Meta chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_sector.isNotEmpty)
                        _Chip(icon: Icons.category_rounded, label: _sector, color: AppColors.blue),
                      if (_amount.isNotEmpty)
                        _Chip(icon: Icons.payments_rounded, label: '$_amount FCFA', color: AppColors.green),
                      if (_dateLabel.isNotEmpty)
                        _Chip(icon: Icons.calendar_today_rounded, label: 'Publié le $_dateLabel', color: AppColors.muted),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _SectionCard(
                    icon: Icons.description_rounded,
                    title: 'Description du projet',
                    color: AppColors.purple,
                    child: Text(
                      _description.isNotEmpty ? _description : 'Aucune description renseignée.',
                      style: const TextStyle(fontSize: 14, color: AppColors.navyDeep, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Financement
                  _SectionCard(
                    icon: Icons.monetization_on_rounded,
                    title: 'Besoin de financement',
                    color: AppColors.green,
                    child: _amount.isEmpty
                        ? const Text('Non renseigné',
                            style: TextStyle(fontSize: 14, color: AppColors.muted))
                        : Row(
                            children: [
                              Text(_amount,
                                  style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.navyDeep)),
                              const SizedBox(width: 6),
                              const Text('FCFA',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.muted)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),

                  // Visibilité
                  _SectionCard(
                    icon: Icons.visibility_rounded,
                    title: 'Visibilité',
                    color: AppColors.amber,
                    child: const Row(
                      children: [
                        Icon(Icons.public_rounded, size: 16, color: AppColors.green),
                        SizedBox(width: 8),
                        Text('Visible par tous les mentors & investisseurs',
                            style: TextStyle(fontSize: 13, color: AppColors.navyDeep)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Documents & Médias ──────────────────────────
                  _SectionCard(
                    icon: Icons.attach_file_rounded,
                    title: 'Documents & Médias',
                    color: AppColors.roleMentor,
                    child: Column(
                      children: [
                        // Business Plan (PDF)
                        _DocRow(
                          icon: Icons.picture_as_pdf_rounded,
                          color: AppColors.red,
                          label: 'Business Plan',
                          hint: 'PDF · max 20 Mo',
                          url: _businessPlanUrl,
                          uploading: _uploading.contains('businessPlan'),
                          onUpload: () => _uploadDocument(
                            type: 'businessPlan',
                            dbField: 'businessPlanUrl',
                            fileType: FileType.custom,
                            allowedExtensions: ['pdf'],
                            maxMb: 20,
                          ),
                          onOpen: _businessPlanUrl != null ? () => _openUrl(_businessPlanUrl!) : null,
                          onDelete: _businessPlanUrl != null
                              ? () => _deleteDocument('businessPlan', 'businessPlanUrl')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Vidéo de présentation
                        _DocRow(
                          icon: Icons.videocam_rounded,
                          color: AppColors.purple,
                          label: 'Vidéo de présentation',
                          hint: 'MP4 / MOV · max 100 Mo',
                          url: _videoUrl,
                          uploading: _uploading.contains('video'),
                          onUpload: () => _uploadDocument(
                            type: 'video',
                            dbField: 'videoUrl',
                            fileType: FileType.video,
                            maxMb: 100,
                          ),
                          onOpen: _videoUrl != null ? () => _openUrl(_videoUrl!) : null,
                          onDelete: _videoUrl != null
                              ? () => _deleteDocument('video', 'videoUrl')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Deck / Présentation
                        _DocRow(
                          icon: Icons.image_rounded,
                          color: AppColors.blue,
                          label: 'Deck / Présentation',
                          hint: 'PDF ou image · max 20 Mo',
                          url: _deckUrl,
                          uploading: _uploading.contains('deck'),
                          onUpload: () => _uploadDocument(
                            type: 'deck',
                            dbField: 'deckUrl',
                            fileType: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                            maxMb: 20,
                          ),
                          onOpen: _deckUrl != null ? () => _openUrl(_deckUrl!) : null,
                          onDelete: _deckUrl != null
                              ? () => _deleteDocument('deck', 'deckUrl')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bouton modifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showEditSheet,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Modifier ce pitch',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bouton supprimer
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                      label: const Text('Supprimer ce pitch',
                          style: TextStyle(color: AppColors.red)),
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
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Ligne de document avec boutons Upload / Ouvrir / Retirer.
class _DocRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String hint;
  final String? url;        // null = pas encore uploadé
  final bool uploading;     // true pendant l'upload
  final VoidCallback? onUpload;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  const _DocRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.hint,
    this.url,
    this.uploading = false,
    this.onUpload,
    this.onOpen,
    this.onDelete,
  });

  bool get _hasFile => url != null && url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icône
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hasFile
                ? color.withValues(alpha: 0.12)
                : AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: _hasFile ? color : AppColors.muted),
        ),
        const SizedBox(width: 12),

        // Label + hint / spinner
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _hasFile ? AppColors.navyDeep : AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              if (uploading)
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: AppColors.border,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Upload en cours…',
                        style: TextStyle(fontSize: 10.5, color: color)),
                  ],
                )
              else
                Text(
                  hint,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Boutons d'action
        if (uploading)
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else if (_hasFile)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionChip(label: 'Ouvrir', color: color, onTap: onOpen),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
              ),
            ],
          )
        else
          _ActionChip(
            label: 'Uploader',
            color: AppColors.navy,
            icon: Icons.upload_rounded,
            outlined: true,
            onTap: onUpload,
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: outlined ? AppColors.border : color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
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
    _title       = TextEditingController(text: widget.pitch['title']?.toString() ?? '');
    _description = TextEditingController(text: widget.pitch['description']?.toString() ?? '');
    _amount      = TextEditingController(text: widget.pitch['amount']?.toString() ?? '');
    _sector      = widget.pitch['sector']?.toString();
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
      await DatabaseService.updatePitch(
        pitchId: widget.pitch['id']?.toString() ?? '',
        title:       _title.text.trim(),
        sector:      _sector!,
        description: _description.text.trim(),
        amount:      _amount.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pitch mis à jour ✓'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
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
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.amber, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Modifier le pitch',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text('Titre *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(
                      hintText: 'Titre du projet',
                      prefixIcon: const Icon(Icons.title_rounded, color: AppColors.subtle),
                      suffixIcon: _title.text.isNotEmpty
                          ? Icon(
                              _title.text.trim().length >= 3
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _title.text.trim().length >= 3 ? AppColors.green : AppColors.red,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Secteur *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sector,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle),
                    decoration: const InputDecoration(
                      hintText: 'Choisis un secteur',
                      prefixIcon: Icon(Icons.category_rounded, color: AppColors.subtle),
                    ),
                    items: allSectors
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(fontSize: 14, color: AppColors.navyDeep)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _sector = v),
                  ),
                  const SizedBox(height: 16),
                  const Text('Description *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _description,
                    maxLines: 8,
                    maxLength: 500,
                    decoration: const InputDecoration(hintText: 'Décris ton projet en détail…'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Besoin de financement (FCFA)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '5 000 000',
                      prefixIcon: Icon(Icons.payments_rounded, color: AppColors.subtle),
                      suffixText: 'FCFA',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_loading || !_valid) ? null : _save,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.35),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('ENREGISTRER LES MODIFICATIONS',
                              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 13)),
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

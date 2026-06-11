import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_cloudinary.dart';
import '../services/service_navigation.dart';
import '../theme/theme_app.dart';

/// Stepper 5 étapes pour déposer un pitch.
/// Étape 4 (Documents) est obligatoire : PDF + vidéo requis avant publication.
class PitchPage extends StatefulWidget {
  const PitchPage({super.key});

  @override
  State<PitchPage> createState() => _PitchPageState();
}

class _PitchPageState extends State<PitchPage> {
  int _step = 0;
  bool _loading = false;
  static const _total = 5;

  /// ID stable généré au chargement de la page — utilisé pour Cloudinary
  /// avant même la publication Firebase.
  late final String _pitchId;

  // ── Étapes 0-2 ──────────────────────────────────────────────────
  final _title = TextEditingController();
  String? _sector;
  final _description = TextEditingController();
  final _detailDescription = TextEditingController();
  final _amount = TextEditingController();

  // ── Étape 3 — Documents ─────────────────────────────────────────
  String? _businessPlanUrl;
  String? _videoUrl;
  String? _deckUrl;
  final Set<String> _uploadingDocs = {};

  static const _steps = [
    ('Informations',  'Présente ton projet en quelques mots'),
    ('Détails',       'Secteur, description, ambition'),
    ('Financement',   'Besoin de financement'),
    ('Documents',     'Business Plan et vidéo de présentation obligatoires'),
    ('Récapitulatif', 'Vérifie ton pitch avant publication'),
  ];

  // ── Validations ─────────────────────────────────────────────────
  bool get _step0Valid => _title.text.trim().length >= 3;
  bool get _step1Valid =>
      _sector != null && _detailDescription.text.trim().length >= 20;
  bool get _step2Valid => true; // montant optionnel
  bool get _step3Valid =>
      _businessPlanUrl != null && _videoUrl != null;
  bool get _step4Valid => true; // récap — toujours valide

  bool get _currentStepValid {
    switch (_step) {
      case 0: return _step0Valid;
      case 1: return _step1Valid;
      case 2: return _step2Valid;
      case 3: return _step3Valid;
      case 4: return _step4Valid;
      default: return false;
    }
  }

  static String _generateId() {
    final r = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    super.initState();
    _pitchId = _generateId();
    for (final c in [_title, _description, _detailDescription, _amount]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _detailDescription.dispose();
    _amount.dispose();
    super.dispose();
  }

  // ── Navigation entre étapes ──────────────────────────────────────
  Future<void> _next() async {
    if (!_currentStepValid) return;
    if (_step < _total - 1) {
      setState(() => _step++);
      return;
    }
    _publish();
  }

  // ── Publication ─────────────────────────────────────────────────
  Future<void> _publish() async {
    setState(() => _loading = true);
    try {
      final profile = UserProfileController.profile.value;
      final uid = AuthService.currentUid ?? '';
      final title = _title.text.trim();
      final detail = _detailDescription.text.trim();
      final summary = _description.text.trim();
      final description =
          [summary, detail].where((s) => s.isNotEmpty).join('\n\n');
      final sector = _sector ?? profile.sector;

      // 1. Ajoute le projet au profil de l'entrepreneur
      final project = Project(
        id: _pitchId,
        name: title,
        description: description,
        sector: sector,
        totalSteps: 5,
      );
      final updated =
          profile.copyWith(projects: [...profile.projects, project]);
      UserProfileController.update(updated);
      if (uid.isNotEmpty) {
        await DatabaseService.updateUserProfile(uid, updated);
      }

      // 2. Publie dans le nœud global pitches/ avec les URLs documents
      await DatabaseService.publishPitch(
        pitchId: _pitchId,
        userId: uid,
        userName: profile.fullName,
        title: title,
        sector: sector,
        description: description,
        amount: _amount.text.trim(),
        businessPlanUrl: _businessPlanUrl,
        videoUrl: _videoUrl,
        deckUrl: _deckUrl,
      );

      if (!mounted) return;
      appTabIndex.value = 4;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '🎉 Pitch publié ! Retrouve-le dans ton profil → Mes projets.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la publication : $e'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Upload Cloudinary ────────────────────────────────────────────
  Future<void> _uploadDoc({
    required String type,
    required FileType fileType,
    List<String>? allowedExtensions,
    required int maxMb,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final pf = result.files.first;
    if (pf.path == null) return;

    if (pf.size > maxMb * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Fichier trop volumineux (max $maxMb Mo). '
            'Taille : ${(pf.size / (1024 * 1024)).toStringAsFixed(1)} Mo.'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _uploadingDocs.add(type));
    try {
      final url = await CloudinaryService.uploadFile(
        filePath: pf.path!,
        resourceType: type == 'video' ? 'video' : 'auto',
        folder: 'pitches/$_pitchId',
      );
      if (!mounted) return;
      setState(() {
        _uploadingDocs.remove(type);
        switch (type) {
          case 'businessPlan': _businessPlanUrl = url; break;
          case 'video':        _videoUrl        = url; break;
          case 'deck':         _deckUrl         = url; break;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_docLabel(type)} uploadé ✓'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingDocs.remove(type));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : $e'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _docLabel(String type) {
    switch (type) {
      case 'businessPlan': return 'Business Plan';
      case 'video':        return 'Vidéo de présentation';
      case 'deck':         return 'Deck';
    }
    return type;
  }

  void _removeDoc(String type) {
    setState(() {
      switch (type) {
        case 'businessPlan': _businessPlanUrl = null; break;
        case 'video':        _videoUrl        = null; break;
        case 'deck':         _deckUrl         = null; break;
      }
    });
  }

  // ── Hint texte ───────────────────────────────────────────────────
  String _stepHint() {
    switch (_step) {
      case 0:
        return _title.text.trim().isEmpty
            ? 'Remplis le titre de ton projet pour continuer.'
            : 'Titre trop court (3 caractères minimum).';
      case 1:
        if (_sector == null) return 'Choisis un secteur d\'activité.';
        return 'Description trop courte (20 caractères minimum).';
      case 3:
        if (_businessPlanUrl == null && _videoUrl == null)
          return 'Business Plan (PDF) et vidéo sont obligatoires.';
        if (_businessPlanUrl == null) return 'Upload ton Business Plan (PDF).';
        if (_videoUrl == null) return 'Upload ta vidéo de présentation.';
        return '';
      default:
        return '';
    }
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Étape ${_step + 1} / $_total · ${_steps[_step].$1}'),
        leading: IconButton(
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(step: _step, total: _total),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (c, a) =>
                    FadeTransition(opacity: a, child: c),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  if (!_currentStepValid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _stepHint(),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_loading || !_currentStepValid) ? null : _next,
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
                          : Text(
                              _step == _total - 1
                                  ? 'PUBLIER MON PITCH'
                                  : 'CONTINUER',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 14,
                              ),
                            ),
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

  Widget _buildStep() {
    return Padding(
      key: ValueKey(_step),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text(_steps[_step].$2,
              style: const TextStyle(fontSize: 14, color: AppColors.muted)),
          const SizedBox(height: 22),
          if (_step == 0) ..._step1(),
          if (_step == 1) ..._step2(),
          if (_step == 2) ..._step3(),
          if (_step == 3) ..._step4(),
          if (_step == 4) ..._step5(),
        ],
      ),
    );
  }

  // ── ÉTAPE 1 — Titre + Elevator pitch ────────────────────────────
  List<Widget> _step1() => [
        const _FieldLabel('Titre du projet', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: _title,
          decoration: InputDecoration(
            hintText: 'Ex. Téranga Mode',
            prefixIcon:
                const Icon(Icons.title_rounded, color: AppColors.subtle),
            suffixIcon: _title.text.isNotEmpty
                ? Icon(
                    _step0Valid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _step0Valid ? AppColors.green : AppColors.red,
                    size: 20,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Elevator pitch'),
        const SizedBox(height: 4),
        const Text(
          'Décris ton projet en 1-2 phrases : ce que tu fais, pour qui, et pourquoi.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'Ex. Je crée une plateforme de mode africaine pour valoriser le tissu sénégalais.',
          ),
        ),
      ];

  // ── ÉTAPE 2 — Secteur + Description détaillée ───────────────────
  List<Widget> _step2() => [
        const _FieldLabel('Secteur d\'activité', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _sector,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.subtle),
          decoration: const InputDecoration(
            hintText: 'Choisis un secteur',
            prefixIcon:
                Icon(Icons.category_rounded, color: AppColors.subtle),
          ),
          items: allSectors
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.navyDeep)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _sector = v),
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Description détaillée', required: true),
        const SizedBox(height: 4),
        const Text(
          'Marché cible, équipe, traction, vision à 3 ans…',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _detailDescription,
          maxLines: 8,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Décris ton projet en détail…',
          ),
        ),
      ];

  // ── ÉTAPE 3 — Financement ────────────────────────────────────────
  List<Widget> _step3() => [
        const _FieldLabel('Besoin de financement (FCFA)'),
        const SizedBox(height: 4),
        const Text(
          'Montant recherché pour développer ton projet (optionnel).',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '5 000 000',
            prefixIcon:
                Icon(Icons.payments_rounded, color: AppColors.subtle),
            suffixText: 'FCFA',
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.visibility_rounded, color: AppColors.green, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qui verra ton pitch ?',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDeep)),
                    SizedBox(height: 4),
                    Text(
                      'Tous les mentors et investisseurs inscrits sur DIAPALER AFRICA pourront consulter ton pitch.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.muted, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];

  // ── ÉTAPE 4 — Documents (obligatoires) ──────────────────────────
  List<Widget> _step4() => [
        // Bannière info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_rounded, color: AppColors.amber, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Le Business Plan (PDF) et la vidéo de présentation sont obligatoires pour publier ton pitch. Le deck est optionnel.',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.navyDeep,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Business Plan — obligatoire
        _DocUploadTile(
          icon: Icons.picture_as_pdf_rounded,
          color: AppColors.red,
          label: 'Business Plan',
          hint: 'PDF · max 20 Mo',
          required: true,
          url: _businessPlanUrl,
          uploading: _uploadingDocs.contains('businessPlan'),
          onUpload: () => _uploadDoc(
            type: 'businessPlan',
            fileType: FileType.custom,
            allowedExtensions: ['pdf'],
            maxMb: 20,
          ),
          onRemove: () => _removeDoc('businessPlan'),
        ),
        const SizedBox(height: 12),

        // Vidéo — obligatoire
        _DocUploadTile(
          icon: Icons.videocam_rounded,
          color: AppColors.purple,
          label: 'Vidéo de présentation',
          hint: 'MP4 / MOV · max 100 Mo',
          required: true,
          url: _videoUrl,
          uploading: _uploadingDocs.contains('video'),
          onUpload: () => _uploadDoc(
            type: 'video',
            fileType: FileType.video,
            maxMb: 100,
          ),
          onRemove: () => _removeDoc('video'),
        ),
        const SizedBox(height: 12),

        // Deck — optionnel
        _DocUploadTile(
          icon: Icons.image_rounded,
          color: AppColors.blue,
          label: 'Deck / Présentation',
          hint: 'PDF ou image · max 20 Mo · optionnel',
          required: false,
          url: _deckUrl,
          uploading: _uploadingDocs.contains('deck'),
          onUpload: () => _uploadDoc(
            type: 'deck',
            fileType: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            maxMb: 20,
          ),
          onRemove: () => _removeDoc('deck'),
        ),
        const SizedBox(height: 8),
      ];

  // ── ÉTAPE 5 — Récapitulatif ──────────────────────────────────────
  List<Widget> _step5() {
    final sector = _sector ?? '—';
    final amount = _amount.text.trim();
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navyDeep, AppColors.blue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title.text.trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDeep,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Secteur + Montant
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                    icon: Icons.category_rounded,
                    label: sector,
                    color: AppColors.blue),
                if (amount.isNotEmpty)
                  _SummaryChip(
                      icon: Icons.payments_rounded,
                      label: '$amount FCFA',
                      color: AppColors.green),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            const Text('Description',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                    letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(
              [
                _description.text.trim(),
                _detailDescription.text.trim(),
              ].where((s) => s.isNotEmpty).join('\n\n'),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.navyDeep, height: 1.5),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24),

            // Documents
            const Text('Documents',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                    letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _DocStatusRow(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Business Plan',
                color: AppColors.red,
                ok: _businessPlanUrl != null),
            const SizedBox(height: 6),
            _DocStatusRow(
                icon: Icons.videocam_rounded,
                label: 'Vidéo de présentation',
                color: AppColors.purple,
                ok: _videoUrl != null),
            const SizedBox(height: 6),
            _DocStatusRow(
                icon: Icons.image_rounded,
                label: 'Deck / Présentation',
                color: AppColors.blue,
                ok: _deckUrl != null,
                optional: true),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ton pitch est prêt ! Appuie sur "Publier mon pitch" pour le rendre visible aux mentors et investisseurs.',
                style: TextStyle(
                    fontSize: 12.5, color: AppColors.navyDeep, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// Widget d'upload de document (étape 4)
// ─────────────────────────────────────────────────────────────────
class _DocUploadTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String hint;
  final bool required;
  final String? url;
  final bool uploading;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocUploadTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.hint,
    required this.required,
    required this.url,
    required this.uploading,
    required this.onUpload,
    required this.onRemove,
  });

  bool get _done => url != null && url!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _done
            ? color.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _done
              ? color.withValues(alpha: 0.4)
              : AppColors.border,
          width: _done ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _done
                  ? color.withValues(alpha: 0.15)
                  : AppColors.fieldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 20, color: _done ? color : AppColors.muted),
          ),
          const SizedBox(width: 12),

          // Label + hint
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _done
                              ? AppColors.navyDeep
                              : AppColors.muted,
                        )),
                    if (required) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _done
                              ? AppColors.green.withValues(alpha: 0.15)
                              : AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _done ? 'OK' : 'Requis',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _done ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (uploading)
                  Row(
                    children: [
                      Expanded(
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
                          style: TextStyle(
                              fontSize: 10.5, color: color)),
                    ],
                  )
                else
                  Text(hint,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bouton
          if (uploading)
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
          else if (_done)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 20),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.muted),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: onUpload,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_rounded,
                        size: 13, color: AppColors.navy),
                    SizedBox(width: 4),
                    Text('Upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        )),
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
// Récapitulatif — statut des documents
// ─────────────────────────────────────────────────────────────────
class _DocStatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool ok;
  final bool optional;

  const _DocStatusRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.ok,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: ok ? color : AppColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                color: ok ? AppColors.navyDeep : AppColors.muted,
              )),
        ),
        if (ok)
          const Icon(Icons.check_circle_rounded,
              size: 16, color: AppColors.green)
        else if (optional)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Optionnel',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
          )
        else
          const Icon(Icons.cancel_rounded,
              size: 16, color: AppColors.red),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Chip résumé (récapitulatif)
// ─────────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Label de champ
// ─────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    if (!required) {
      return Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDeep));
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDeep),
        children: const [
          TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.red)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Barre de progression
// ─────────────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                height: 5,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.amber : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

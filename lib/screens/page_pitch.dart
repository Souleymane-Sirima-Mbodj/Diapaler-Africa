import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_navigation.dart';
import '../theme/theme_app.dart';

/// Stepper 3 étapes pour déposer un pitch.
class PitchPage extends StatefulWidget {
  const PitchPage({super.key});

  @override
  State<PitchPage> createState() => _PitchPageState();
}

class _PitchPageState extends State<PitchPage> {
  int _step = 0;
  bool _loading = false;
  static const _total = 3;

  final _title = TextEditingController();
  String? _sector;
  final _description = TextEditingController();
  final _detailDescription = TextEditingController();
  final _amount = TextEditingController();

  static const _steps = [
    ('Informations', 'Présente ton projet en quelques mots'),
    ('Détails', 'Secteur, description, ambition'),
    ('Financement', 'Besoin de financement et informations complémentaires'),
  ];

  // ── Validations par étape ──────────────────────────────────────
  bool get _step0Valid => _title.text.trim().length >= 3;
  bool get _step1Valid =>
      _sector != null && _detailDescription.text.trim().length >= 20;
  bool get _step2Valid => true; // Montant optionnel

  bool get _currentStepValid {
    switch (_step) {
      case 0: return _step0Valid;
      case 1: return _step1Valid;
      case 2: return _step2Valid;
      default: return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Rebuild sur chaque frappe pour activer/désactiver le bouton
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

  Future<void> _next() async {
    // Validation obligatoire avant de passer à l'étape suivante
    if (!_currentStepValid) return;

    if (_step < _total - 1) {
      setState(() => _step++);
      return;
    }

    // Dernière étape → publication
    setState(() => _loading = true);
    try {
      final profile = UserProfileController.profile.value;
      final uid = AuthService.currentUid;
      final title = _title.text.trim();
      final detail = _detailDescription.text.trim();
      final summary = _description.text.trim();
      final description = [summary, detail]
          .where((s) => s.isNotEmpty)
          .join('\n\n');
      final sector = _sector ?? profile.sector;

      // 1. Ajoute au profil de l'entrepreneur comme projet (3 étapes = pitch process)
      final project = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: title,
        description: description,
        sector: sector,
        totalSteps: 3, // 3 étapes : Idée → En cours → Lancé
      );
      final updated = profile.copyWith(
        projects: [...profile.projects, project],
      );
      UserProfileController.update(updated);
      if (uid != null) {
        await DatabaseService.updateUserProfile(uid, updated);
      }

      // 2. Publie dans le nœud global pitches/ → visible mentors & investisseurs
      await DatabaseService.publishPitch(
        userId: uid ?? '',
        userName: profile.fullName,
        title: title,
        sector: sector,
        description: description,
        amount: _amount.text.trim(),
      );

      if (!mounted) return;

      // 3. Navigue vers l'onglet Profil pour que l'entrepreneur voit son projet
      appTabIndex.value = 4;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎉 Pitch publié ! Retrouve-le dans ton profil → Mes projets.',
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la publication : $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Étape ${_step + 1} / $_total · ${_steps[_step].$1}'),
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
                  // Indicateur si le bouton est désactivé
                  if (!_currentStepValid && _step < 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Text(
                            _stepHint(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
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

  String _stepHint() {
    switch (_step) {
      case 0:
        return _title.text.trim().isEmpty
            ? 'Remplis le titre de ton projet pour continuer.'
            : 'Titre trop court (3 caractères minimum).';
      case 1:
        if (_sector == null) return 'Choisis un secteur d\'activité.';
        return 'Description trop courte (20 caractères minimum).';
      default:
        return '';
    }
  }

  Widget _buildStep() {
    return Padding(
      key: ValueKey(_step),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text(
            _steps[_step].$2,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          if (_step == 0) ..._step1(),
          if (_step == 1) ..._step2(),
          if (_step == 2) ..._step3(),
        ],
      ),
    );
  }

  // ── ÉTAPE 1 — Titre + Elevator pitch ──────────────────────────
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
        const _FieldLabel('Mon élévator pitch'),
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
            hintText: 'Ex. Je crée une plateforme de mode africaine pour valoriser le tissu sénégalais.',
          ),
        ),
      ];

  // ── ÉTAPE 2 — Secteur + Description détaillée ─────────────────
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
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.navyDeep,
                      ),
                    ),
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

  // ── ÉTAPE 3 — Financement ─────────────────────────────────────
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
            prefixIcon: Icon(Icons.payments_rounded, color: AppColors.subtle),
            suffixText: 'FCFA',
          ),
        ),
        const SizedBox(height: 24),
        // Info sur la visibilité
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.green.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.visibility_rounded,
                  color: AppColors.green, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qui verra ton pitch ?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tous les mentors et investisseurs inscrits sur DIAPALER AFRICA pourront consulter ton pitch et te contacter directement.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Info sur le projet dans profil
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.amber.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person_rounded, color: AppColors.amber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dans ton profil',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ton projet sera ajouté à ton profil dans l\'onglet "Profil" → section "Mes projets".',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
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
      return Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.red),
          ),
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

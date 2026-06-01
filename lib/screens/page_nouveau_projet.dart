import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';

class AddProjectPage extends StatefulWidget {
  /// Si renseigné, la page est en mode édition (pré-remplit les champs).
  final Project? existingProject;
  const AddProjectPage({super.key, this.existingProject});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  String? _sector;

  bool get _isEditing => widget.existingProject != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProject;
    if (p != null) {
      _name.text = p.name;
      _description.text = p.description;
      _sector = p.sector;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty && _sector != null;

  void _save() {
    if (!_valid) return;
    if (_isEditing) {
      // Mode édition : conserver l'id et les étapes existantes
      final existing = widget.existingProject!;
      UserProfileController.updateProject(
        existing.copyWith(
          name: _name.text.trim(),
          description: _description.text.trim(),
          sector: _sector!,
        ),
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✏️ Projet modifié : ${_name.text.trim()}'),
          backgroundColor: AppColors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Mode création
      final id = _name.text.trim().toLowerCase().replaceAll(' ', '-');
      final added = UserProfileController.addProject(
        Project(
          id: '$id-${DateTime.now().millisecondsSinceEpoch}',
          name: _name.text.trim(),
          description: _description.text.trim(),
          sector: _sector!,
        ),
      );
      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚠️  Termine ton projet en cours avant d\'en démarrer un nouveau.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Nouveau projet ajouté : ${_name.text.trim()}'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            _isEditing ? 'Modifie ton projet' : 'Démarre ton aventure',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEditing
                ? 'Mets à jour les informations de ton projet.'
                : 'Décris ton nouveau projet en quelques mots — tu pourras le compléter plus tard.',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          const _Label('Nom du projet'),
          const SizedBox(height: 6),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ex. Téranga Mode',
              prefixIcon:
                  Icon(Icons.workspace_premium_outlined, color: AppColors.subtle),
            ),
          ),
          const SizedBox(height: 14),
          const _Label("Secteur d'activité"),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _sector,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.subtle),
            decoration: const InputDecoration(
              hintText: 'Choisis un secteur',
              prefixIcon: Icon(Icons.category_rounded, color: AppColors.subtle),
            ),
            items: allSectors
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _sector = v),
          ),
          const SizedBox(height: 14),
          const _Label('Description'),
          const SizedBox(height: 6),
          TextField(
            controller: _description,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Que fais-tu, pour qui, et pourquoi ?',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _valid ? _save : null,
              icon: Icon(_isEditing ? Icons.check_rounded : Icons.add_rounded, size: 20),
              label: Text(
                _isEditing ? 'ENREGISTRER LES MODIFICATIONS' : 'CRÉER LE PROJET',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor:
                    AppColors.navy.withValues(alpha: 0.35),
                disabledForegroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.navyDeep,
        ),
      );
}

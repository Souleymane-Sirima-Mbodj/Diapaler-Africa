import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../data/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final UserProfile _initial;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  late String _city;
  late String _sector;
  late Set<String> _interests;

  static const _cities = <String>[
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Ziguinchor',
    'Kaolack',
    'Mbour',
    'Touba',
    'Diaspora',
  ];

  @override
  void initState() {
    super.initState();
    _initial = UserProfileController.profile.value;
    _firstName = TextEditingController(text: _initial.firstName);
    _lastName = TextEditingController(text: _initial.lastName);
    _phone = TextEditingController(text: _initial.phone);
    _bio = TextEditingController(text: _initial.bio);
    _city = _initial.city;
    _sector = _initial.sector;
    _interests = Set<String>.from(_initial.interests);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    UserProfileController.update(_initial.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
      city: _city,
      sector: _sector,
      bio: _bio.text.trim(),
      interests: _interests.toList()..sort(),
    ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profil mis à jour'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Modifier le profil'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'ENREGISTRER',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(
                  initials: ('${_firstName.text.isNotEmpty ? _firstName.text[0] : ''}'
                      '${_lastName.text.isNotEmpty ? _lastName.text[0] : ''}').toUpperCase(),
                  size: 88,
                  background: AppColors.amber,
                  foreground: AppColors.navyDeep,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '📷 Sélection de photo (à venir avec Firebase Storage)'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _Section('Identité'),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Prénom',
                  icon: Icons.person_outline_rounded,
                  controller: _firstName,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: 'Nom',
                  icon: Icons.badge_outlined,
                  controller: _lastName,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            controller: TextEditingController(text: _initial.email),
            readOnly: true,
            trailing: const Icon(Icons.lock_outline_rounded,
                size: 16, color: AppColors.subtle),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 22),
          const _Section('Localisation et secteur'),
          _Dropdown(
            label: 'Ville',
            icon: Icons.place_outlined,
            value: _city,
            values: _cities,
            onChanged: (v) => setState(() => _city = v),
          ),
          const SizedBox(height: 12),
          _Dropdown(
            label: "Secteur d'activité",
            icon: Icons.category_rounded,
            value: _sector,
            values: allSectors,
            onChanged: (v) => setState(() => _sector = v),
          ),
          const SizedBox(height: 22),
          _InterestsPicker(
            selected: _interests,
            onToggle: (s) => setState(() {
              if (_interests.contains(s)) {
                _interests.remove(s);
              } else {
                _interests.add(s);
              }
            }),
          ),
          const SizedBox(height: 22),
          const _Section('À propos de moi'),
          TextField(
            controller: _bio,
            maxLines: 6,
            maxLength: 280,
            decoration: const InputDecoration(
              hintText: 'Présente-toi en quelques lignes…',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text(
                'ENREGISTRER',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.trailing,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDeep,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.subtle, size: 19),
            suffixIcon: trailing == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: trailing,
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = values.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.navyDeep,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.subtle),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.subtle, size: 19),
          ),
          items: values
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

class _InterestsPicker extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _InterestsPicker({
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Section("Domaines d'intérêt"),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${selected.length} / ${allSectors.length}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Tape sur un domaine pour le sélectionner ou le retirer.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allSectors.map((s) {
            final on = selected.contains(s);
            return GestureDetector(
              onTap: () => onToggle(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: on ? AppColors.navy : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: on ? AppColors.navy : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (on) ...[
                      const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.amber),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: on ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../data/countries.dart';
import '../data/mock_data.dart';
import '../data/user_profile.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
  late final TextEditingController _address;
  late final TextEditingController _linkedin;
  late final TextEditingController _bio;
  late String _city;
  late String _country;
  late String _sector;
  late Gender _gender;
  DateTime? _birthDate;
  late Set<String> _interests;

  @override
  void initState() {
    super.initState();
    _initial = UserProfileController.profile.value;
    _firstName = TextEditingController(text: _initial.firstName);
    _lastName = TextEditingController(text: _initial.lastName);
    _phone = TextEditingController(text: _initial.phone);
    _address = TextEditingController(text: _initial.address);
    _linkedin = TextEditingController(text: _initial.linkedin);
    _bio = TextEditingController(text: _initial.bio);
    // Si le pays courant n'est pas dans la liste supportée, on défaut à Sénégal.
    _country = supportedCountries.contains(_initial.country)
        ? _initial.country
        : 'Sénégal';
    final cities = citiesOf(_country);
    _city = cities.contains(_initial.city) ? _initial.city : cities.first;
    _sector = _initial.sector;
    _gender = _initial.gender;
    _birthDate = _initial.birthDate;
    _interests = Set<String>.from(_initial.interests);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _linkedin.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Ta date de naissance',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    final next = _initial.copyWith(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      address: _address.text.trim(),
      city: _city,
      country: _country,
      sector: _sector,
      linkedin: _linkedin.text.trim(),
      bio: _bio.text.trim(),
      interests: _interests.toList()..sort(),
    );
    UserProfileController.update(next);

    final uid = AuthService.currentUid;
    if (uid != null) {
      try {
        await DatabaseService.updateUserProfile(uid, next);
      } catch (_) {/* non-bloquant */}
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profil mis à jour'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _initialsPreview {
    final f = _firstName.text.isNotEmpty ? _firstName.text[0] : '';
    final l = _lastName.text.isNotEmpty ? _lastName.text[0] : '';
    return (f + l).toUpperCase();
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
                  initials: _initialsPreview,
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
          _PhoneField(controller: _phone),
          const SizedBox(height: 12),
          const _SubLabel('Sexe'),
          const SizedBox(height: 6),
          _GenderPicker(
            value: _gender,
            onChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: 12),
          _DateField(
            label: 'Date de naissance',
            value: _birthDate,
            onTap: _pickBirthDate,
            onClear: _birthDate == null
                ? null
                : () => setState(() => _birthDate = null),
          ),
          const SizedBox(height: 22),
          const _Section('Localisation'),
          _Dropdown(
            label: 'Pays *',
            icon: Icons.public_rounded,
            value: _country,
            values: supportedCountries,
            onChanged: (v) => setState(() {
              _country = v;
              _city = citiesOf(v).first;
            }),
          ),
          const SizedBox(height: 12),
          _Dropdown(
            label: 'Ville *',
            icon: Icons.place_outlined,
            value: _city,
            values: citiesOf(_country),
            onChanged: (v) => setState(() => _city = v),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Adresse',
            icon: Icons.home_outlined,
            controller: _address,
            hint: 'Quartier, rue, n°…',
          ),
          const SizedBox(height: 22),
          const _Section('Profil professionnel'),
          _Dropdown(
            label: "Secteur d'activité",
            icon: Icons.category_rounded,
            value: _sector,
            values: allSectors,
            onChanged: (v) => setState(() => _sector = v),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'LinkedIn (optionnel)',
            icon: Icons.link_rounded,
            controller: _linkedin,
            hint: 'linkedin.com/in/...',
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

// ─────────────────────────────────────────────────────────────────
// Petits widgets utilitaires
// ─────────────────────────────────────────────────────────────────
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

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool readOnly;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final String? hint;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.readOnly = false,
    this.trailing,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
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

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubLabel('Téléphone'),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '🇸🇳  +221',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '77 123 45 67',
                ),
              ),
            ),
          ],
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
        _SubLabel(label),
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? null
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';
    final age = ageFromBirthDate(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubLabel(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined,
                    color: AppColors.subtle, size: 19),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatted ?? 'Choisir une date',
                    style: TextStyle(
                      fontSize: 14,
                      color: formatted == null
                          ? AppColors.subtle
                          : AppColors.navyDeep,
                      fontWeight:
                          formatted == null ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),
                if (age != null)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$age ans',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                if (onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.subtle),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.subtle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;
  const _GenderPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [
      Gender.female,
      Gender.male,
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((g) {
        final on = value == g;
        return GestureDetector(
          onTap: () => onChanged(g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on ? AppColors.navy : AppColors.fieldBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              g.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: on ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
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

import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/pays.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_cloudinary.dart';
import '../theme/theme_app.dart';
import 'page_decouverte.dart';
import 'page_choix_role.dart';

class SignUpPage extends StatefulWidget {
  final UserRole initialRole;
  const SignUpPage({super.key, this.initialRole = UserRole.entrepreneur});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Identité
  late final UserRole _role = widget.initialRole;
  Gender _gender = Gender.undisclosed;
  DateTime? _birthDate;
  final _name = TextEditingController();
  final _email = TextEditingController();

  // Profil pro (optionnels)
  final _address = TextEditingController();
  final _linkedin = TextEditingController();
  final _bio = TextEditingController();
  String _city = 'Dakar';
  String _country = 'Sénégal';
  String _sector = 'Agro-industrie';
  final _yearsExp = TextEditingController();
  final _investmentRange = TextEditingController();
  final Set<String> _interests = {};

  // Photo de profil (octets en memoire — compatible web ET mobile)
  Uint8List? _photoBytes;
  String _photoBase64 = '';

  // Sécurité
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0; // 0..3
  bool _obscure = true;
  bool _accept = false;
  bool _loading = false;
  String? _error;

  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');


  @override
  void initState() {
    super.initState();
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _address.dispose();
    _linkedin.dispose();
    _bio.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _yearsExp.dispose();
    _investmentRange.dispose();
    super.dispose();
  }

  // ─── Validations ───
  bool get _nameValid =>
      _name.text.trim().split(RegExp(r'\s+')).length >= 2 &&
      _name.text.trim().length >= 4;
  bool get _emailValid => _emailRegex.hasMatch(_email.text.trim());
  String get _phoneDigits => _phone.text.replaceAll(RegExp(r'\D'), '');
  int get _expectedPhoneLength => countryPhoneLength[_country] ?? 9;
  bool get _phoneValid => _phoneDigits.length == _expectedPhoneLength;
  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _password.text == _confirm.text;
  int get _passwordStrength => _computeStrength(_password.text);

  bool get _step1Valid =>
      _nameValid &&
      _emailValid &&
      _birthDate != null;
  bool get _step2Valid =>
      supportedCountries.contains(_country) &&
      citiesOf(_country).contains(_city);
  bool get _step3Valid => _interests.isNotEmpty;
  bool get _step4Valid =>
      _phoneValid &&
      _password.text.length >= 6 &&
      _passwordsMatch &&
      _accept;

  bool get _stepValid {
    switch (_step) {
      case 0:
        return _step1Valid;
      case 1:
        return _step2Valid;
      case 2:
        return _step3Valid;
      case 3:
        return _step4Valid;
      default:
        return false;
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 22),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 13, 12, 31),
      helpText: 'Ta date de naissance',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoBase64 = base64Encode(bytes); // temporaire, remplacé par URL au submit
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.entrepreneur:
        return 'Entrepreneur';
      case UserRole.mentor:
        return 'Mentor';
      case UserRole.investor:
        return 'Investisseur';
    }
  }

  Future<void> _submit() async {
    if (!_step1Valid || !_step2Valid || !_step3Valid || !_step4Valid) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await AuthService.signUp(
        email: _email.text,
        password: _password.text,
      );
      final uid = cred.user!.uid;
      final parts = _name.text.trim().split(RegExp(r'\s+'));
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      // Upload photo vers Cloudinary si disponible, sinon garder base64 local
      String photoData = _photoBase64;
      if (_photoBytes != null && _photoBytes!.isNotEmpty) {
        try {
          photoData = await CloudinaryService.uploadBytes(
            bytes: _photoBytes!,
            filename: 'avatar_$uid.jpg',
          );
        } catch (_) {
          // En cas d'erreur Cloudinary, on garde le base64 temporairement
        }
      }

      final profile = UserProfile(
        firstName: firstName,
        lastName: lastName,
        email: _email.text.trim(),
        phone: '${countryDialCode[_country] ?? '+221'} ${_phone.text.trim()}',
        gender: _gender,
        birthDate: _birthDate,
        address: _address.text.trim(),
        city: _city,
        country: _country,
        sector: _sector,
        role: _roleLabel(_role),
        yearsExperience: _role == UserRole.mentor
            ? (int.tryParse(_yearsExp.text.trim()) ?? 0)
            : 0,
        investmentRange: _role == UserRole.investor
            ? _investmentRange.text.trim()
            : '',
        bio: _bio.text.trim(),
        linkedin: _linkedin.text.trim(),
        photoBase64: photoData,
        interests: _interests.toList()..sort(),
        projects: const [],
      );
      await DatabaseService.createUserProfile(uid, profile);
      UserProfileController.update(profile);

      // Demande au gestionnaire de mots de passe du téléphone de sauvegarder
      TextInput.finishAutofillContext();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: false);
      setState(() => _error = AuthService.humanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _next() {
    if (!_stepValid) return;
    if (_step < 3) {
      setState(() => _step += 1);
    } else {
      _submit();
    }
  }

  // ─── Build ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_step > 0) {
              setState(() => _step -= 1);
            } else {
              Navigator.of(context).maybePop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          _stepTitle(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(step: _step, total: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Étape ${_step + 1} / 4',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${_stepSubtitle()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(a),
                    child: c,
                  ),
                ),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ErrorBox(message: _error!),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          (_loading || !_stepValid) ? null : _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.navy.withValues(alpha: 0.35),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _step == 3 ? "S'INSCRIRE" : 'CONTINUER',
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

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Créer un compte';
      case 1:
        return 'Localisation';
      case 2:
        return 'Profil professionnel';
      case 3:
        return 'Sécurité du compte';
    }
    return '';
  }

  String _stepSubtitle() {
    switch (_step) {
      case 0:
        return 'Qui es-tu ?';
      case 1:
        return 'D\'où viens-tu ?';
      case 2:
        return 'Présente-toi à la communauté';
      case 3:
        return 'Sécurise ton compte';
    }
    return '';
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
    }
    return const SizedBox.shrink();
  }

  // ─── ÉTAPE 1 — Identité ───
  Widget _buildStep1() {
    return ListView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        _RoleBadge(role: _role),
        const SizedBox(height: 16),
        const _LabelRequired('Nom complet'),
        const SizedBox(height: 6),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline_rounded,
                color: AppColors.subtle, size: 20),
            hintText: 'Mariéme Tine',
            suffixIcon:
                _name.text.isEmpty ? null : _ValidIcon(ok: _nameValid),
          ),
        ),
        if (_name.text.isNotEmpty && !_nameValid)
          const _Hint(text: 'Saisis ton prénom et ton nom (4 lettres min).'),
        const SizedBox(height: 12),
        const _LabelRequired('Adresse e-mail'),
        const SizedBox(height: 6),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail_outline_rounded,
                color: AppColors.subtle, size: 20),
            hintText: 'nom@téki.sn',
            suffixIcon:
                _email.text.isEmpty ? null : _ValidIcon(ok: _emailValid),
          ),
        ),
        if (_email.text.isNotEmpty && !_emailValid)
          const _Hint(text: 'Format e-mail invalide (ex. nom@téki.sn).'),
        const SizedBox(height: 14),
        const _Label('Sexe'),
        const SizedBox(height: 6),
        _GenderRow(
          value: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        const SizedBox(height: 14),
        if (_role == UserRole.entrepreneur) ...[
          const _LabelRequired('Date de naissance'),
          const SizedBox(height: 6),
          _DatePickerField(
            value: _birthDate,
            onTap: _pickBirthDate,
          ),
        ] else ...[
          const _LabelRequired('Date de naissance'),
          const SizedBox(height: 6),
          _DatePickerField(
            value: _birthDate,
            onTap: _pickBirthDate,
          ),
        ],
      ],
    );
  }

  // ─── ÉTAPE 2 — Localisation (pays + ville obligatoires) ───
  Widget _buildStep2() {
    return ListView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        Row(
          children: [
            Expanded(
              child: _InlineDropdown(
                label: 'Pays',
                required: true,
                icon: Icons.public_rounded,
                value: _country,
                values: supportedCountries,
                onChanged: (v) => setState(() {
                  _country = v;
                  _city = citiesOf(v).first;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InlineDropdown(
                label: 'Ville',
                required: true,
                icon: Icons.place_outlined,
                value: _city,
                values: citiesOf(_country),
                onChanged: (v) => setState(() => _city = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Label('Adresse'),
        const SizedBox(height: 6),
        TextField(
          controller: _address,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.home_outlined,
                color: AppColors.subtle, size: 20),
            hintText: 'Quartier, rue, n°…',
          ),
        ),
        const SizedBox(height: 8),
        const _Hint(text: 'L\'adresse est optionnelle.'),
      ],
    );
  }

  // ─── ÉTAPE 3 — Profil pro (intérêts obligatoires) ───
  Widget _buildStep3() {
    return ListView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        const _Label('Photo de profil'),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickProfilePhoto,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _photoBytes != null ? AppColors.blue : AppColors.border,
                width: 2,
              ),
            ),
            child: _photoBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _photoBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 40,
                        color: AppColors.muted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajouter une photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Optionnel',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),
        // Secteur d'activité (tous les rôles)
        _LabelRequired(_role == UserRole.mentor
            ? 'Secteur principal'
            : _role == UserRole.investor
                ? "Secteur d'investissement"
                : "Secteur d'activité"),
        const SizedBox(height: 6),
        _InlineDropdown(
          label: _role == UserRole.mentor
              ? 'Secteur principal'
              : _role == UserRole.investor
                  ? "Secteur d'investissement"
                  : "Secteur d'activité",
          required: true,
          icon: Icons.category_rounded,
          value: _sector,
          values: allSectors,
          onChanged: (v) => setState(() => _sector = v),
        ),
        const SizedBox(height: 12),

        // Années d'expérience (Mentor uniquement)
        if (_role == UserRole.mentor) ...[
          const _Label("Années d'expérience"),
          const SizedBox(height: 6),
          TextField(
            controller: _yearsExp,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.workspace_premium_rounded,
                  color: AppColors.subtle, size: 20),
              hintText: 'Ex. 12',
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Ticket d'investissement (Investisseur uniquement)
        if (_role == UserRole.investor) ...[
          const _Label("Ticket d'investissement"),
          const SizedBox(height: 6),
          TextField(
            controller: _investmentRange,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.payments_rounded,
                  color: AppColors.subtle, size: 20),
              hintText: '500 000 – 5 000 000 FCFA',
            ),
          ),
          const SizedBox(height: 12),
        ],

        const _Label('À propos de moi'),
        const SizedBox(height: 6),
        TextField(
          controller: _bio,
          maxLines: 4,
          maxLength: 240,
          decoration: const InputDecoration(
            hintText: 'Présente-toi en quelques lignes…',
          ),
        ),
        const SizedBox(height: 4),
        const _Label('LinkedIn'),
        const SizedBox(height: 6),
        TextField(
          controller: _linkedin,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.link_rounded,
                color: AppColors.subtle, size: 20),
            hintText: 'linkedin.com/in/...',
          ),
        ),
        const SizedBox(height: 8),
        const _Hint(
            text: 'À propos, LinkedIn et photo sont optionnels — tu peux les ajouter plus tard.'),
        const SizedBox(height: 18),
        Row(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
                children: [
                  TextSpan(
                    text: _role == UserRole.investor
                        ? 'Secteurs d\'intérêt'
                        : _role == UserRole.mentor
                            ? 'Domaines d\'expertise'
                            : 'Centres d\'intérêt',
                  ),
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '${_interests.length} sélectionné${_interests.length > 1 ? "s" : ""}',
              style: TextStyle(
                fontSize: 11.5,
                color: _interests.isEmpty
                    ? AppColors.red
                    : AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _interests.isEmpty
              ? 'Choisis au moins 1 secteur qui t\'intéresse pour avancer.'
              : 'Tu peux en sélectionner plusieurs.',
          style: TextStyle(
            fontSize: 11.5,
            color: _interests.isEmpty ? AppColors.red : AppColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allSectors.map((s) {
            final on = _interests.contains(s);
            return GestureDetector(
              onTap: () => setState(() {
                if (on) {
                  _interests.remove(s);
                } else {
                  _interests.add(s);
                }
              }),
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

  // ─── ÉTAPE 4 — Sécurité ───
  Widget _buildStep4() {
    return AutofillGroup(
      child: ListView(
      key: const ValueKey('step4'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        const _LabelRequired('Téléphone'),
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
              child: Text(
                '${countryFlag[_country] ?? '🌍'}  ${countryDialCode[_country] ?? '+?'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_expectedPhoneLength),
                  _PhoneFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: _country == 'Sénégal' ? '77 123 45 67' : 'Numéro local',
                  suffixIcon: _phone.text.isEmpty
                      ? null
                      : _ValidIcon(ok: _phoneValid),
                ),
              ),
            ),
          ],
        ),
        if (_phone.text.isNotEmpty && !_phoneValid)
          _Hint(text: 'Numéro à $_expectedPhoneLength chiffres pour $_country.'),
        const SizedBox(height: 14),
        const _LabelRequired('Mot de passe'),
        const SizedBox(height: 6),
        TextField(
          controller: _password,
          obscureText: _obscure,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.subtle, size: 20),
            hintText: '6 caractères minimum',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.subtle,
                size: 20,
              ),
            ),
          ),
        ),
        if (_password.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _StrengthMeter(strength: _passwordStrength),
          ),
        const SizedBox(height: 12),
        const _LabelRequired('Confirmer le mot de passe'),
        const SizedBox(height: 6),
        TextField(
          controller: _confirm,
          obscureText: _obscure,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.subtle, size: 20),
            suffixIcon: _confirm.text.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _passwordsMatch
                            ? AppColors.green
                            : AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        _ConsentCheckbox(
          value: _accept,
          onChanged: (v) => setState(() => _accept = v ?? false),
        ),
      ],
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stepper bar (3 segments)
// ─────────────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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

// ─────────────────────────────────────────────────────────────────
// Helpers UI
// ─────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
      );
}

class _LabelRequired extends StatelessWidget {
  final String text;
  const _LabelRequired(this.text);
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: AppColors.red)),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 13, color: AppColors.muted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidIcon extends StatelessWidget {
  final bool ok;
  const _ValidIcon({required this.ok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: ok ? AppColors.green : AppColors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          ok ? Icons.check_rounded : Icons.close_rounded,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;
  const _DatePickerField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? null
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';
    final age = ageFromBirthDate(value);
    return InkWell(
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
                formatted ?? 'JJ / MM / AAAA',
                style: TextStyle(
                  fontSize: 14,
                  color: formatted == null
                      ? AppColors.subtle
                      : AppColors.navyDeep,
                  fontWeight: formatted == null
                      ? FontWeight.w400
                      : FontWeight.w600,
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
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}

class _InlineDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  final bool required;
  const _InlineDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = values.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required) _LabelRequired(label) else _Label(label),
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

// ─────────────────────────────────────────────────────────────────
// Badge confirmation du rôle (read-only, choisi sur l'écran précédent)
// ─────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  String get _roleLabel {
    switch (role) {
      case UserRole.entrepreneur:
        return 'Entrepreneur';
      case UserRole.mentor:
        return 'Mentor';
      case UserRole.investor:
        return 'Investisseur';
    }
  }

  IconData get _roleIcon {
    switch (role) {
      case UserRole.entrepreneur:
        return Icons.rocket_launch_rounded;
      case UserRole.mentor:
        return Icons.school_rounded;
      case UserRole.investor:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get _roleColor {
    switch (role) {
      case UserRole.entrepreneur:
        return AppColors.roleEntrepreneur;
      case UserRole.mentor:
        return AppColors.roleMentor;
      case UserRole.investor:
        return AppColors.roleInvestor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blueTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _roleColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_roleIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Je m'inscris en tant que",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.green, size: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Pills sexe
// ─────────────────────────────────────────────────────────────────
class _GenderRow extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;
  const _GenderRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [Gender.female, Gender.male, Gender.undisclosed];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(items[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: value == items[i]
                      ? AppColors.navy
                      : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[i].label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: value == items[i]
                        ? Colors.white
                        : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Consent checkbox
// ─────────────────────────────────────────────────────────────────
class _ConsentCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _ConsentCheckbox({required this.value, required this.onChanged});

  @override
  State<_ConsentCheckbox> createState() => _ConsentCheckboxState();
}

class _ConsentCheckboxState extends State<_ConsentCheckbox> {
  late final TapGestureRecognizer _cguRec;
  late final TapGestureRecognizer _privacyRec;

  @override
  void initState() {
    super.initState();
    _cguRec = TapGestureRecognizer()
      ..onTap = () => _showLegalDialog(
            context,
            "Conditions d'utilisation",
            _cguText,
          );
    _privacyRec = TapGestureRecognizer()
      ..onTap = () => _showLegalDialog(
            context,
            'Politique de confidentialité',
            _privacyText,
          );
  }

  @override
  void dispose() {
    _cguRec.dispose();
    _privacyRec.dispose();
    super.dispose();
  }

  static const _cguText =
      'En utilisant Diapaler Africa, vous vous engagez à :\n\n'
      '• Ne publier que des informations véridiques sur votre profil et vos projets.\n'
      '• Respecter la vie privée et la confidentialité des autres membres.\n'
      '• Utiliser la plateforme à des fins professionnelles et légales.\n'
      '• Ne pas partager vos identifiants de connexion avec des tiers.\n'
      '• Ne pas diffuser de contenu offensant, trompeur ou frauduleux.\n\n'
      'Diapaler Africa se réserve le droit de suspendre ou supprimer tout compte '
      'ne respectant pas ces conditions, sans préavis.\n\n'
      'Pour toute question : support@diapaler.sn\n\nVersion 1.0 — Juin 2026';

  static const _privacyText =
      'Diapaler Africa collecte uniquement les données nécessaires au fonctionnement de la plateforme :\n\n'
      '• Identité : nom, email, téléphone, photo de profil.\n'
      '• Informations professionnelles : secteur, bio, LinkedIn, années d\'expérience.\n'
      '• Données d\'interaction : demandes de mentorat, investissement, messagerie.\n\n'
      'Vos données sont stockées de façon sécurisée sur Firebase (Google) et ne sont jamais '
      'vendues ni partagées avec des tiers sans votre consentement.\n\n'
      'Vous pouvez demander la modification ou la suppression de vos données à tout moment '
      'en contactant : support@diapaler.sn\n\n'
      'Conforme à la loi 2008-12 sur la protection des données personnelles au Sénégal.\n\n'
      'Version 1.0 — Juin 2026';

  void _showLegalDialog(BuildContext ctx, String title, String content) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('J\'ai compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onChanged(!widget.value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: widget.value,
                  onChanged: widget.onChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  activeColor: AppColors.blue,
                  side: const BorderSide(color: AppColors.subtle, width: 1.4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: "J'accepte les "),
                    TextSpan(
                      text: "conditions d'utilisation",
                      recognizer: _cguRec,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      recognizer: _privacyRec,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Force du mot de passe
// ─────────────────────────────────────────────────────────────────
int _computeStrength(String pwd) {
  if (pwd.length < 6) return 0;
  int score = 0;
  if (pwd.length >= 6) score++;
  if (pwd.length >= 10) score++;
  if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(pwd)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)) score++;
  return score.clamp(0, 4);
}

class _StrengthMeter extends StatelessWidget {
  final int strength; // 0..4
  const _StrengthMeter({required this.strength});

  static const _labels = [
    'Trop court',
    'Faible',
    'Moyen',
    'Bon',
    'Excellent',
  ];
  static const _colors = [
    AppColors.red,
    AppColors.red,
    AppColors.amber,
    AppColors.green,
    AppColors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final on = i < strength;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4,
                  decoration: BoxDecoration(
                    color: on ? _colors[strength] : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Force : ${_labels[strength]}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _colors[strength],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Téléphone : auto-format "XX XXX XX XX"
// ─────────────────────────────────────────────────────────────────
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

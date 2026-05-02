import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/user_profile.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_page.dart';
import 'role_selection_page.dart';

class SignUpPage extends StatefulWidget {
  final UserRole initialRole;
  const SignUpPage({super.key, this.initialRole = UserRole.entrepreneur});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late UserRole _role = widget.initialRole;
  Gender _gender = Gender.female;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0; // 0 = identité, 1 = sécurité
  bool _obscure = true;
  bool _accept = false;
  bool _loading = false;
  String? _error;

  static final _emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
    _phone.addListener(() => setState(() {}));
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  // ─────────── Validations ───────────
  bool get _nameValid => _name.text.trim().split(RegExp(r'\s+')).length >= 2 &&
      _name.text.trim().length >= 4;
  bool get _emailValid => _emailRegex.hasMatch(_email.text.trim());
  String get _phoneDigits => _phone.text.replaceAll(RegExp(r'\D'), '');
  bool get _phoneValid => _phoneDigits.length >= 8 && _phoneDigits.length <= 9;
  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _password.text == _confirm.text;
  int get _passwordStrength => _computeStrength(_password.text);

  bool get _step1Valid => _nameValid && _emailValid;
  bool get _step2Valid =>
      _phoneValid &&
      _password.text.length >= 6 &&
      _passwordsMatch &&
      _accept;

  // ─────────── Actions ───────────
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
    if (!_step1Valid || !_step2Valid) return;
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

      final profile = UserProfile(
        firstName: firstName,
        lastName: lastName,
        email: _email.text.trim(),
        phone: '+221 ${_phone.text.trim()}',
        gender: _gender,
        city: 'Dakar',
        country: 'Sénégal',
        sector: 'Autre',
        role: _roleLabel(_role),
        bio: '',
        interests: const [],
        projects: const [],
      );
      await DatabaseService.createUserProfile(uid, profile);
      UserProfileController.update(profile);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthService.humanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────── Build ───────────
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
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.of(context).maybePop();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          _step == 0 ? 'Créer un compte' : 'Sécurité du compte',
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
            _StepBar(step: _step),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Étape ${_step + 1} / 2',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _step == 0 ? '· Qui es-tu ?' : '· Sécurise ton compte',
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
                child: _step == 0 ? _buildStep1() : _buildStep2(),
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
                      onPressed: _bottomCta(),
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
                              _step == 0 ? 'CONTINUER' : "S'INSCRIRE",
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

  VoidCallback? _bottomCta() {
    if (_loading) return null;
    if (_step == 0) {
      return _step1Valid ? () => setState(() => _step = 1) : null;
    }
    return _step2Valid ? _submit : null;
  }

  // ─────────── Étape 1 ───────────
  Widget _buildStep1() {
    return ListView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      children: [
        const _Label("Je m'inscris en tant que"),
        const SizedBox(height: 8),
        _RolePills(
          value: _role,
          onChanged: (r) => setState(() => _role = r),
        ),
        const SizedBox(height: 16),
        const _LabelRequired('Nom complet'),
        const SizedBox(height: 6),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline_rounded,
                color: AppColors.subtle, size: 20),
            hintText: 'Mariéme Tine',
            suffixIcon: _name.text.isEmpty ? null : _ValidIcon(ok: _nameValid),
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
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail_outline_rounded,
                color: AppColors.subtle, size: 20),
            hintText: 'nom@exemple.sn',
            suffixIcon:
                _email.text.isEmpty ? null : _ValidIcon(ok: _emailValid),
          ),
        ),
        if (_email.text.isNotEmpty && !_emailValid)
          const _Hint(text: 'Format e-mail invalide (ex. nom@exemple.sn).'),
        const SizedBox(height: 14),
        const _Label('Sexe'),
        const SizedBox(height: 6),
        _GenderRow(
          value: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─────────── Étape 2 ───────────
  Widget _buildStep2() {
    return ListView(
      key: const ValueKey('step2'),
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
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  _PhoneFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '77 123 45 67',
                  suffixIcon: _phone.text.isEmpty
                      ? null
                      : _ValidIcon(ok: _phoneValid),
                ),
              ),
            ),
          ],
        ),
        if (_phone.text.isNotEmpty && !_phoneValid)
          const _Hint(text: 'Numéro sénégalais à 9 chiffres (ex. 77 123 45 67).'),
        const SizedBox(height: 14),
        const _LabelRequired('Mot de passe'),
        const SizedBox(height: 6),
        TextField(
          controller: _password,
          obscureText: _obscure,
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
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stepper bar
// ─────────────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int step;
  const _StepBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              height: 5,
              decoration: BoxDecoration(
                color: step >= 1 ? AppColors.amber : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
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

// ─────────────────────────────────────────────────────────────────
// Pills rôle + sexe
// ─────────────────────────────────────────────────────────────────
class _RolePills extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole> onChanged;
  const _RolePills({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [
      (UserRole.entrepreneur, 'Entrepreneur'),
      (UserRole.mentor, 'Mentor'),
      (UserRole.investor, 'Investisseur'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(items[i].$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: value == items[i].$1
                      ? AppColors.navy
                      : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  items[i].$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: value == items[i].$1
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

class _GenderRow extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;
  const _GenderRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [Gender.female, Gender.male];
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
class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _ConsentCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
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
                  value: value,
                  onChanged: onChanged,
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
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: "J'accepte les "),
                    TextSpan(
                      text: "conditions d'utilisation",
                      style: TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: TextStyle(
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
      // Groupe : 2 - 3 - 2 - 2  →  "XX XXX XX XX"
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

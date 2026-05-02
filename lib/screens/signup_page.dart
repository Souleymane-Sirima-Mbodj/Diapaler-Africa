import 'package:flutter/material.dart';
import '../data/user_profile.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
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
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Gender _gender = Gender.undisclosed;
  bool _obscure = true;
  bool _accept = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
  }

  bool get _passwordsMatch =>
      _password.text.isNotEmpty && _password.text == _confirm.text;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
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
    if (!_accept || !_passwordsMatch || _name.text.trim().isEmpty) return;

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

      // Construit le profil initial.
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

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _accept && _passwordsMatch && _name.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const _Label("Je m'inscris en tant que"),
            const SizedBox(height: 8),
            _RolePills(value: _role, onChanged: (r) => setState(() => _role = r)),
            const SizedBox(height: 16),
            const _LabelRequired('Nom complet'),
            const SizedBox(height: 6),
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.subtle, size: 20),
                hintText: 'Mariéme Tine',
              ),
            ),
            const SizedBox(height: 12),
            const _LabelRequired('Adresse e-mail'),
            const SizedBox(height: 6),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.mail_outline_rounded,
                    color: AppColors.subtle, size: 20),
                hintText: 'nom@exemple.sn',
              ),
            ),
            const SizedBox(height: 12),
            const _Label('Téléphone'),
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
                    decoration: const InputDecoration(
                      hintText: '77 123 45 67',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _Label('Sexe'),
            const SizedBox(height: 6),
            _GenderRow(
              value: _gender,
              onChanged: (g) => setState(() => _gender = g),
            ),
            const SizedBox(height: 12),
            const _LabelRequired('Mot de passe'),
            const SizedBox(height: 6),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.subtle, size: 20),
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
                hintText: '6 caractères minimum',
              ),
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
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (canSubmit && !_loading) ? _submit : null,
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
                    : const Text(
                        "S'INSCRIRE",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Déjà un compte ?  ',
                  style: TextStyle(color: AppColors.muted, fontSize: 13.5),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final items = [
      Gender.female,
      Gender.male,
      Gender.other,
    ];
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

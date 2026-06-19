import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import '../widgets/logo_diapaler.dart';
import '../widgets/bande_drapeau.dart';
import 'coquille_principale.dart';
import 'page_choix_role.dart';
import 'page_mot_de_passe_oublie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = false;
  String? _error;

  static const _kEmail    = 'saved_email';
  static const _kPassword = 'saved_password';
  static const _kRemember = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRemember) ?? false;
    if (!remember) return;
    final email    = prefs.getString(_kEmail)    ?? '';
    final password = prefs.getString(_kPassword) ?? '';
    if (!mounted) return;
    setState(() {
      _rememberMe = true;
      _email.text    = email;
      _password.text = password;
    });
  }

  Future<void> _persistCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool  (_kRemember, true);
      await prefs.setString(_kEmail,    _email.text.trim());
      await prefs.setString(_kPassword, _password.text);
    } else {
      await prefs.remove(_kRemember);
      await prefs.remove(_kEmail);
      await prefs.remove(_kPassword);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email et mot de passe requis.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await AuthService.signIn(
        email: _email.text,
        password: _password.text,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        try {
          final remote = await DatabaseService.readUserProfile(uid);
          if (remote != null) {
            UserProfileController.update(remote);
          }
        } catch (_) {
          // Le profil sera rechargé au démarrage — ne pas bloquer la connexion
        }
      }
      // Demande au gestionnaire de mots de passe du téléphone de sauvegarder
      // les identifiants (Google Password Manager, Samsung Pass, iCloud Keychain…)
      await _persistCredentials();
      TextInput.finishAutofillContext();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      // Connexion échouée : on annule la sauvegarde des identifiants
      TextInput.finishAutofillContext(shouldSave: false);
      setState(() => _error = AuthService.humanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bandeau navy compact avec logo ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navyDeep,
                    AppColors.navy,
                    Color(0xFF14305E),
                  ],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                  ),
                  const DiapalerLogoTile(size: 50, onDark: true),
                  const SizedBox(height: 10),
                  const DiapalerWordmark(fontSize: 24, onDark: true),
                  const SizedBox(height: 10),
                  const SenegalFlagStrip(height: 3),
                ],
              ),
            ),
            // ── Contenu ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                children: [
                  const Center(
                    child: Text(
                      'Bon retour ! 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDeep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Connecte-toi pour continuer ton parcours',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('Email'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.blueTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.mail_outline_rounded,
                                  color: AppColors.blue, size: 18),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 48, minHeight: 48),
                            hintText: 'nom@téki.sn',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _Label('Mot de passe'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _signIn(),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.amber, size: 18),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                          minWidth: 48, minHeight: 48),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
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
                      ],
                    ),
                  ),
                  // ── Se souvenir de moi ──
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _rememberMe = !_rememberMe),
                        child: const Text(
                          'Se souvenir de moi',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.navyDeep,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ── Erreur ──
                  if (_error != null) ...[
                    const SizedBox(height: 8),
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
                  const SizedBox(height: 14),
                  // Bouton SE CONNECTER avec gradient + glow
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.5),
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
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SE CONNECTER',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore de compte ?  ',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const RoleSelectionPage()),
                        ),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
      );
}

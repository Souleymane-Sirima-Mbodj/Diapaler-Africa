import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/service_authentification.dart';
import '../services/service_seed_demo.dart';
import '../theme/theme_app.dart';
import 'page_aide.dart';

/// Page Paramètres — changer le mot de passe, infos app, support, suppression compte.
class ParametresPage extends StatelessWidget {
  const ParametresPage({super.key});

  static const _demoEmail = 'sirimambodj@gmail.com';

  @override
  Widget build(BuildContext context) {
    final email = AuthService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      backgroundColor: AppColors.surface,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Compte ──────────────────────────────────────────────
          _SectionHeader('Compte'),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            label: 'Changer le mot de passe',
            subtitle: email.isNotEmpty
                ? 'Un lien sera envoyé à $email'
                : 'Réinitialisation par email',
            onTap: () => _resetPassword(context, email),
          ),

          const SizedBox(height: 4),

          // ── Application ──────────────────────────────────────────
          _SectionHeader('Application'),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Langue',
            trailing: 'Français',
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'Version',
            trailing: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.apartment_rounded,
            label: 'Développé par',
            subtitle: 'BNKMTN (Barry, Niang, Kama, Mbodj, Tine, Ndiaye) L3GLSIB',
          ),

          const SizedBox(height: 4),

          // ── Aide ─────────────────────────────────────────────────
          _SectionHeader('Support'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Aide & support',
            subtitle: 'FAQ, contact, guide d\'utilisation',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const AidePage()),
            ),
          ),

          // ── Démo ────────────────────────────────────────────────────
          // const SizedBox(height: 4),
          // _SectionHeader('Données de démo'),
          // const _SeedButton(),

          const SizedBox(height: 4),

          // ── Zone de danger ───────────────────────────────────────
          _SectionHeader('Zone de danger', danger: true),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: AppColors.red,
            label: 'Supprimer mon compte',
            labelColor: AppColors.red,
            onTap: () => _showDeleteDialog(context, email),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Réinitialisation mot de passe ───────────────────────────────
  Future<void> _resetPassword(BuildContext context, String email) async {
    if (email.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Réinitialiser le mot de passe ?'),
        content: Text(
          'Un lien de réinitialisation va être envoyé à :\n\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await AuthService.sendPasswordResetEmail(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email envoyé à $email — vérifie ta boîte mail.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Suppression compte ───────────────────────────────────────────
  void _showDeleteDialog(BuildContext context, String email) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer mon compte ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.red.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action supprime définitivement ton compte et toutes tes données.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pour supprimer ton compte, envoie un email à :\n\nsupport@diapaler.sn\n\nTa demande sera traitée sous 48h.',
              style: TextStyle(fontSize: 13, color: AppColors.navyDeep),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri(
                scheme: 'mailto',
                path: 'support@diapaler.sn',
                queryParameters: {
                  'subject': 'Suppression de compte - $email',
                  'body':
                      'Bonjour,\n\nJe souhaite supprimer mon compte Diapaler Africa.\n\nEmail : $email\n\nMerci.',
                },
              );
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Envoyer un email'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Composants
// ─────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────
// Bouton de seed démo
// ─────────────────────────────────────────────────────────────────
class _SeedButton extends StatefulWidget {
  const _SeedButton();

  @override
  State<_SeedButton> createState() => _SeedButtonState();
}

class _SeedButtonState extends State<_SeedButton> {
  bool _loading = false;
  bool _done = false;

  Future<void> _run() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Injecter les données démo ?'),
        content: const Text(
          'Cette action va créer des relations de mentorat, des messages, des notifications et des pitchs de démonstration dans Firebase.\n\nElle est idempotente : re-taper écrasera les données existantes.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Injecter')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() { _loading = true; _done = false; });
    try {
      await SeedDemoService.seed();
      if (mounted) setState(() { _loading = false; _done = true; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Données démo injectées avec succès !'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: _done ? Icons.check_circle_rounded : Icons.science_rounded,
      iconColor: _done ? AppColors.green : AppColors.purple,
      label: _done ? 'Données injectées ✓' : 'Injecter les données démo',
      subtitle: 'Mentors, investisseurs, messages, notifications, pitchs',
      onTap: _loading ? null : _run,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool danger;
  const _SectionHeader(this.title, {this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: danger ? AppColors.red : AppColors.muted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = onTap != null;
    final color = iconColor ?? AppColors.navy;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? AppColors.navyDeep,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (isActive)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.subtle, size: 20)
            else
              const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

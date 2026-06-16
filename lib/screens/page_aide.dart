import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_app.dart';

class AidePage extends StatelessWidget {
  const AidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: const Text(
          'Aide & support',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── Bannière ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navy, AppColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment pouvons-nous t\'aider ?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulte la FAQ ou contacte notre équipe.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── FAQ ───────────────────────────────────────────────────
          const _SectionTitle('Questions fréquentes'),
          const SizedBox(height: 10),
          const _FaqTile(
            question: 'Comment envoyer une demande de mentorat ?',
            answer:
                'Depuis l\'accueil, appuie sur un mentor pour voir son profil. '
                'Clique sur "Demander ce mentorat" et rédige ton message en expliquant '
                'ton projet et tes objectifs. Le mentor recevra une notification et pourra accepter ou refuser.',
          ),
          const _FaqTile(
            question: 'Comment trouver un investisseur ?',
            answer:
                'Dans la liste des membres, filtre par rôle "Investisseur". '
                'Tu peux aussi consulter leurs secteurs d\'intérêt et leur ticket d\'investissement '
                'pour trouver celui qui correspond à ton projet. Envoie-lui une demande de financement depuis son profil.',
          ),
          const _FaqTile(
            question: 'Comment publier un pitch ?',
            answer:
                'Depuis ton dashboard, appuie sur "Pitcher mon projet". '
                'Remplis le titre, le secteur, la description et le montant recherché. '
                'Ton pitch sera visible par tous les investisseurs de la plateforme.',
          ),
          const _FaqTile(
            question: 'Comment accepter ou refuser une demande ?',
            answer:
                'Depuis l\'onglet "Demandes" de ton dashboard, appuie sur la demande concernée. '
                'Tu verras deux boutons : "Accepter" (vert) et "Refuser" (rouge). '
                'L\'expéditeur recevra une notification dans tous les cas.',
          ),
          const _FaqTile(
            question: 'Comment fonctionne le système de notation ?',
            answer:
                'Après une relation de mentorat ou d\'investissement acceptée, '
                'tu peux noter ton contact de 1 à 5 étoiles. '
                'La moyenne est affichée publiquement sur le profil. '
                'Chaque utilisateur peut noter une seule fois par relation.',
          ),
          const _FaqTile(
            question: 'Comment modifier mon profil ?',
            answer:
                'Va dans l\'onglet "Profil" (icône en bas à droite). '
                'Appuie sur le bouton d\'édition pour modifier ta photo, ta bio, '
                'tes centres d\'intérêt et tes informations professionnelles.',
          ),
          const _FaqTile(
            question: 'Pourquoi ma demande n\'apparaît-elle pas ?',
            answer:
                'Vérifie ta connexion internet. Les demandes sont synchronisées en temps réel '
                'avec Firebase. Si le problème persiste, ferme et rouvre l\'application. '
                'Si tu vois toujours rien, contacte notre support.',
          ),
          const _FaqTile(
            question: 'Comment supprimer mon compte ?',
            answer:
                'Va dans Paramètres → "Supprimer mon compte". '
                'Cette action est irréversible : toutes tes données (profil, messages, '
                'demandes, pitchs) seront définitivement supprimées.',
          ),

          const SizedBox(height: 24),

          // ── Contacter ─────────────────────────────────────────────
          const _SectionTitle('Nous contacter'),
          const SizedBox(height: 10),
          _ContactTile(
            icon: Icons.mail_outline_rounded,
            iconColor: AppColors.blue,
            label: 'Support par e-mail',
            value: 'support@diapaler.sn',
            onTap: () => _copyToClipboard(context, 'support@diapaler.sn'),
          ),
          _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            iconColor: AppColors.green,
            label: 'WhatsApp',
            value: '+221 77 000 00 00',
            onTap: () => _copyToClipboard(context, '+221 77 000 00 00'),
          ),
          _ContactTile(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.amber,
            label: 'Horaires du support',
            value: 'Lun – Ven, 8h – 18h (GMT)',
            onTap: null,
          ),

          const SizedBox(height: 24),

          // ── Version ───────────────────────────────────────────────
          Center(
            child: Text(
              'Diapaler Africa · v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$text" copié'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: AppColors.navyDeep,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FAQ tile (expandable)
// ─────────────────────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _open
              ? AppColors.blue.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _open ? AppColors.blue : AppColors.navyDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _open ? AppColors.blue : AppColors.muted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Text(
                        widget.answer,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Contact tile
// ─────────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.copy_rounded,
                    size: 16, color: AppColors.subtle),
            ],
          ),
        ),
      ),
    );
  }
}

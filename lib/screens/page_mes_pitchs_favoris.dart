import 'package:flutter/material.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../services/service_pitch_favoris.dart';
import '../data/profil_utilisateur.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_pitches_publics.dart';

/// Page listant les pitchs sauvegardés par l'investisseur.
/// Réactive : se met à jour en temps réel via [PitchFavoriteService].
class MesPitchsFavorisPage extends StatelessWidget {
  const MesPitchsFavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.navyDeep,
        title: const Text(
          'Pitchs sauvegardés',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: PitchFavoriteService.pitchFavorites,
        builder: (context, list, _) {
          if (list.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _SavedPitchCard(pitch: list[i]),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte pitch sauvegardé
// ─────────────────────────────────────────────────────────────────
class _SavedPitchCard extends StatelessWidget {
  final Map<String, dynamic> pitch;
  const _SavedPitchCard({required this.pitch});

  String get _title => pitch['title']?.toString() ?? 'Pitch sans titre';
  String get _userName => pitch['userName']?.toString() ?? 'Entrepreneur';
  String get _sector => pitch['sector']?.toString() ?? '';
  String get _description => pitch['description']?.toString() ?? '';
  String get _amount => pitch['amount']?.toString() ?? '';

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatAmount(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return raw;
    final buf = StringBuffer();
    final len = digits.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  void _showDetail(BuildContext context) {
    final currentUid = AuthService.currentUid;
    final profile = UserProfileController.profile.value;
    final toUserId = pitch['userId']?.toString() ?? '';
    final toName = _userName;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PitchDetailSheet(
        pitch: pitch,
        onInvest: (budget, message) async {
          if (currentUid == null || toUserId.isEmpty) return;
          final fullMessage = [
            message.isNotEmpty
                ? message
                : 'Je souhaite investir dans votre projet "${_title}".',
            if (budget.isNotEmpty) 'Budget proposé : $budget FCFA.',
          ].join('\n');
          try {
            final reqId = await InteractionsService.sendMentorRequest(
              fromUserId: currentUid,
              toUserId: toUserId,
              fromName: profile.fullName,
              toName: toName,
              message: fullMessage,
              type: 'investment',
            );
            await NotificationService.notifyUser(
              uid: toUserId,
              title: 'Proposition d\'investissement 💰',
              message:
                  '${profile.fullName} souhaite investir${budget.isNotEmpty ? " (budget : $budget FCFA)" : ""} dans votre projet "$_title".',
              type: 'investment_offer',
              requestId: reqId,
              fromUserId: currentUid,
              fromName: profile.fullName,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Proposition envoyée à $toName.'),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de l\'envoi.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.currentUid ?? '';

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête entrepreneur ──────────────────────────
            Row(
              children: [
                Avatar(
                  initials: _initials(_userName),
                  size: 38,
                  background: AppColors.amber,
                  foreground: AppColors.navyDeep,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const Text(
                        'Entrepreneur',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                if (_sector.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _sector,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // Bouton retirer du favori
                GestureDetector(
                  onTap: () => PitchFavoriteService.toggle(myUid, pitch),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.bookmark_rounded,
                        color: AppColors.blue, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Titre ─────────────────────────────────────────
            Text(
              _title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDeep,
              ),
            ),

            // ── Description ───────────────────────────────────
            if (_description.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                _description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.muted, height: 1.4),
              ),
            ],

            // ── Montant + CTA ──────────────────────────────────
            const SizedBox(height: 10),
            Row(
              children: [
                if (_amount.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_rounded,
                            size: 12, color: AppColors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatAmount(_amount)} FCFA',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                const Text(
                  'Voir le pitch  →',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
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

// ─────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 40, color: AppColors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun pitch sauvegardé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuie sur 🔖 sur un pitch pour le retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

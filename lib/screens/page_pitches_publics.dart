import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../services/service_partage.dart';
import '../services/service_pitch_favoris.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_chat.dart';

/// Liste temps réel de tous les pitchs publiés par les entrepreneurs.
/// Accessible depuis les dashboards Mentor et Investisseur.
/// Inclut une barre de recherche + filtres par secteur.
class PublicPitchesPage extends StatefulWidget {
  const PublicPitchesPage({super.key});

  @override
  State<PublicPitchesPage> createState() => _PublicPitchesPageState();
}

class _PublicPitchesPageState extends State<PublicPitchesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedSector = 'Tous';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> pitches) {
    return pitches.where((p) {
      final title = p['title']?.toString().toLowerCase() ?? '';
      final sector = p['sector']?.toString() ?? '';
      final userName = p['userName']?.toString().toLowerCase() ?? '';
      final desc = p['description']?.toString().toLowerCase() ?? '';

      // Filtre texte
      final q = _query.toLowerCase().trim();
      if (q.isNotEmpty &&
          !title.contains(q) &&
          !userName.contains(q) &&
          !desc.contains(q) &&
          !sector.toLowerCase().contains(q)) {
        return false;
      }

      // Filtre secteur (insensible à la casse)
      if (_selectedSector != 'Tous' &&
          sector.toLowerCase().trim() != _selectedSector.toLowerCase().trim()) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Extrait la liste des secteurs présents dans les pitchs
  List<String> _sectors(List<Map<String, dynamic>> pitches) {
    final sectors = pitches
        .map((p) => p['sector']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Tous', ...sectors];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pitchs publiés',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService.getPitches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            );
          }

          final allPitches = snapshot.data ?? [];
          final sectors = _sectors(allPitches);
          final filtered = _filter(allPitches);
          final hasFilter = _query.isNotEmpty || _selectedSector != 'Tous';

          return Column(
            children: [
              // ── Barre de recherche ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Titre, entrepreneur, secteur…',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.subtle),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.subtle),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // ── Pills secteur ──────────────────────────────
              if (allPitches.isNotEmpty) ...[
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sectors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final s = sectors[i];
                      final selected = s == _selectedSector;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSector = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.amber
                                : Colors.white,
                            border: Border.all(
                              color: selected
                                  ? AppColors.amber
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppColors.navyDeep,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ── Compteur + reset ───────────────────────────
              if (allPitches.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} pitch${filtered.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const Spacer(),
                      if (hasFilter)
                        TextButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _selectedSector = 'Tous');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),

              // ── Liste ─────────────────────────────────────
              Expanded(
                child: allPitches.isEmpty
                    ? _EmptyState()
                    : filtered.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 48, color: AppColors.subtle),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucun pitch ne correspond à ta recherche.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 4, 16, 90),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                                _PitchCard(pitch: filtered[i]),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
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
              decoration: const BoxDecoration(
                color: AppColors.fieldBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.upload_file_rounded,
                  color: AppColors.subtle, size: 38),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucun pitch publié',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Les pitchs des entrepreneurs apparaîtront ici dès qu\'ils sont publiés.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte pitch
// ─────────────────────────────────────────────────────────────────
class _PitchCard extends StatelessWidget {
  final Map<String, dynamic> pitch;
  const _PitchCard({required this.pitch});

  /// Formate un montant avec des espaces (ex: 5000000 → 5 000 000).
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _sendInvestmentRequest(
      BuildContext context, Map<String, dynamic> pitch,
      {required String budget, required String message}) async {
    final currentUid = AuthService.currentUid;
    final profile = UserProfileController.profile.value;
    final toUserId = pitch['userId']?.toString() ?? '';
    final toName = pitch['userName']?.toString() ?? 'Entrepreneur';

    if (currentUid == null || toUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'envoyer la proposition.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final fullMessage = [
      message.isNotEmpty
          ? message
          : 'Je souhaite investir dans votre projet "${pitch['title'] ?? ''}".',
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
      // Notifier l'entrepreneur avec requestId pour l'accept/decline inline
      await NotificationService.notifyUser(
        uid: toUserId,
        title: 'Proposition d\'investissement 💰',
        message:
            '${profile.fullName} souhaite investir${budget.isNotEmpty ? " (budget : $budget FCFA)" : ""} dans votre projet "${pitch['title'] ?? ''}".',
        type: 'investment_offer',
        requestId: reqId,
        fromUserId: currentUid,
        fromName: profile.fullName,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proposition d\'investissement envoyée à $toName.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.green,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi de la proposition.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PitchDetailSheet(
        pitch: pitch,
        onInvest: (budget, message) =>
            _sendInvestmentRequest(context, pitch, budget: budget, message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = pitch['title']?.toString() ?? 'Pitch sans titre';
    final userName = pitch['userName']?.toString() ?? 'Entrepreneur';
    final sector = pitch['sector']?.toString() ?? '';
    final description = pitch['description']?.toString() ?? '';
    final amount = pitch['amount']?.toString() ?? '';
    final isPremium = (pitch['isPremium'] as bool?) == true;
    final isInvestor =
        UserProfileController.profile.value.role == 'Investisseur';
    final myUid = AuthService.currentUid ?? '';

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: PitchFavoriteService.pitchFavorites,
      builder: (context, _, __) {
        final isBookmarked = PitchFavoriteService.isFavorite(pitch);
        return _buildCard(context, title, userName, sector, description,
            amount, isPremium, isInvestor, myUid, isBookmarked);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String userName,
    String sector,
    String description,
    String amount,
    bool isPremium,
    bool isInvestor,
    String myUid,
    bool isBookmarked,
  ) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête entrepreneur
          Row(
            children: [
              Avatar(
                initials: _initials(userName),
                size: 40,
                background: AppColors.amber,
                foreground: AppColors.navyDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDeep,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: const Color(0xFFF59E0B), width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    color: Color(0xFFF59E0B), size: 10),
                                SizedBox(width: 2),
                                Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Text(
                      'Entrepreneur',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (sector.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sector,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Titre
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDeep,
            ),
          ),

          // Description
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.muted, height: 1.45),
            ),
          ],

          // Montant
          if (amount.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_rounded,
                      size: 13, color: AppColors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatAmount(amount)} FCFA',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      isInvestor
                          ? 'Pitch · Opportunité d\'investissement'
                          : 'Pitch publié · En attente de mentor',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.muted),
                    ),
                  ),
                  const Spacer(),
                  // Partager
                  IconButton(
                    onPressed: () => ShareService.sharePitch(
                      title: title,
                      sector: sector,
                      description: description,
                      authorName: userName,
                      amount: amount.isNotEmpty ? amount : null,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    color: AppColors.muted,
                    tooltip: 'Partager',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // Bookmark (investisseur uniquement)
                  if (isInvestor) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () =>
                          PitchFavoriteService.toggle(myUid, pitch),
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 20,
                      ),
                      color: isBookmarked ? AppColors.blue : AppColors.muted,
                      tooltip: isBookmarked
                          ? 'Retirer des favoris'
                          : 'Sauvegarder',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  const SizedBox(width: 8),
                  // Contacter — masqué pour les Investisseurs (contact via Messages après acceptation)
                  if (!isInvestor)
                    TextButton(
                      onPressed: () {
                        final currentUid = AuthService.currentUid;
                        final otherUid = pitch['userId']?.toString() ?? '';
                        if (currentUid == null || otherUid.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Impossible de contacter cet entrepreneur.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final convId =
                            InteractionsService.generateConversationId(
                                currentUid, otherUid);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatPage(
                            conversationId: convId,
                            otherUserName: userName,
                            otherUserId: otherUid,
                          ),
                        ));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                      child: const Text(
                        'Contacter  →',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                ],
              ),

              // Investisseur : voir le détail complet avant d'investir
              if (isInvestor) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _showDetail(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Voir le pitch complet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────
// Fiche détail pitch (bottom sheet) — publique pour réutilisation

// ─────────────────────────────────────────────────────────────────
class PitchDetailSheet extends StatelessWidget {
  final Map<String, dynamic> pitch;
  final void Function(String budget, String message) onInvest;

  const PitchDetailSheet({super.key, required this.pitch, required this.onInvest});

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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final title = pitch['title']?.toString() ?? 'Pitch sans titre';
    final userName = pitch['userName']?.toString() ?? 'Entrepreneur';
    final sector = pitch['sector']?.toString() ?? '';
    final description = pitch['description']?.toString() ?? '';
    final amount = pitch['amount']?.toString() ?? '';
    final pdfUrl = pitch['businessPlanUrl']?.toString() ?? '';
    final videoUrl = pitch['videoUrl']?.toString() ?? '';
    final isInvestor = UserProfileController.profile.value.role == 'Investisseur';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          // En-tête entrepreneur
          Row(
            children: [
              Avatar(
                initials: _initials(userName),
                size: 46,
                background: AppColors.amber,
                foreground: AppColors.navyDeep,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
                    const Text('Entrepreneur',
                        style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              if (sector.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(sector,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amber)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Titre
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navyDeep)),
          // Montant
          if (amount.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_rounded, size: 14, color: AppColors.green),
                  const SizedBox(width: 6),
                  Text('${_formatAmount(amount)} FCFA recherchés',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          // Description complète
          if (description.isNotEmpty) ...[
            const Text('Description',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.6)),
            const SizedBox(height: 20),
          ],
          // PDF
          if (pdfUrl.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            const Text('Documents',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final uri = Uri.tryParse(pdfUrl);
                if (uri != null) {
                  try {
                    // ignore: deprecated_member_use
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, color: AppColors.red, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Voir le PDF du pitch',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: AppColors.navyDeep, fontSize: 13)),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Vidéo
          if (videoUrl.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            const Text('Vidéo de présentation',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navyDeep)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final uri = Uri.tryParse(videoUrl);
                if (uri != null) {
                  try {
                    // ignore: deprecated_member_use
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_circle_outline_rounded, color: AppColors.blue, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Regarder la vidéo',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: AppColors.navyDeep, fontSize: 13)),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Bouton investissement (investisseur uniquement)
          if (isInvestor) ...[
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, String>>(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => _InvestmentProposalDialog(
                      pitchTitle: title,
                      defaultRange:
                          UserProfileController.profile.value.investmentRange,
                    ),
                  );
                  if (result == null || !context.mounted) return;
                  Navigator.of(context).pop();
                  onInvest(result['budget'] ?? '', result['message'] ?? '');
                },
                icon: const Icon(Icons.monetization_on_rounded),
                label: const Text(
                  'PROPOSER UN INVESTISSEMENT',
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Dialogue de proposition d'investissement
// ─────────────────────────────────────────────────────────────────
class _InvestmentProposalDialog extends StatefulWidget {
  final String pitchTitle;
  final String defaultRange;

  const _InvestmentProposalDialog({
    required this.pitchTitle,
    required this.defaultRange,
  });

  @override
  State<_InvestmentProposalDialog> createState() =>
      _InvestmentProposalDialogState();
}

class _InvestmentProposalDialogState
    extends State<_InvestmentProposalDialog> {
  late final TextEditingController _budgetCtrl;
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _budgetCtrl = TextEditingController(text: widget.defaultRange);
    _budgetCtrl.addListener(() => setState(() {}));
    _messageCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _budgetCtrl.text.trim().isNotEmpty;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.monetization_on_rounded,
                color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Proposition d\'investissement',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pitch ciblé
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Pitch : ${widget.pitchTitle}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDeep,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Fourchette budget
            const Text(
              'Budget proposé (FCFA) *',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _budgetCtrl,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Ex. 500 000 – 2 000 000',
                prefixIcon:
                    Icon(Icons.payments_rounded, color: AppColors.subtle, size: 18),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Indique une fourchette ou un montant précis.',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            // Message optionnel
            const Text(
              'Message (optionnel)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _messageCtrl,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Présente-toi ou précise les conditions…',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Annuler',
            style: TextStyle(
                color: AppColors.muted, fontWeight: FontWeight.w700),
          ),
        ),
        ElevatedButton(
          onPressed: canSend
              ? () => Navigator.of(context).pop({
                    'budget': _budgetCtrl.text.trim(),
                    'message': _messageCtrl.text.trim(),
                  })
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppColors.green.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            'Envoyer',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

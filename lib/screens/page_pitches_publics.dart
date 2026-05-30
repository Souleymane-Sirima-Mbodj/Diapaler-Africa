import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../services/service_partage.dart';
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

      // Filtre secteur
      if (_selectedSector != 'Tous' && sector != _selectedSector) {
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _sendInvestmentRequest(
      BuildContext context, Map<String, dynamic> pitch) async {
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

    try {
      await InteractionsService.sendMentorRequest(
        fromUserId: currentUid,
        toUserId: toUserId,
        fromName: profile.fullName,
        toName: toName,
        message:
            'Je souhaite investir dans votre projet "${pitch['title'] ?? ''}".',
        type: 'investment',
      );
      // Notifier l'entrepreneur
      await NotificationService.notifyUser(
        uid: toUserId,
        title: 'Proposition d\'investissement',
        message: '${profile.fullName} souhaite investir dans votre projet "${pitch['title'] ?? ''}".',
        type: 'investment',
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

  @override
  Widget build(BuildContext context) {
    final title = pitch['title']?.toString() ?? 'Pitch sans titre';
    final userName = pitch['userName']?.toString() ?? 'Entrepreneur';
    final sector = pitch['sector']?.toString() ?? '';
    final description = pitch['description']?.toString() ?? '';
    final amount = pitch['amount']?.toString() ?? '';
    final isInvestor =
        UserProfileController.profile.value.role == 'Investisseur';

    return Container(
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
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                      ),
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
                    '$amount FCFA',
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
                  Text(
                    isInvestor
                        ? 'Pitch · Opportunité d\'investissement'
                        : 'Pitch publié · En attente de mentor',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.muted),
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

              // Bouton investissement (Investisseur uniquement)
              if (isInvestor) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _sendInvestmentRequest(context, pitch),
                  icon: const Icon(Icons.monetization_on_rounded, size: 16),
                  label: const Text('Proposer un investissement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

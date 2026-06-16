import 'package:flutter/material.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';

class RequestsPage extends StatefulWidget {
  /// 0 = onglet Reçues (défaut), 1 = onglet Envoyées
  final int initialTab;
  const RequestsPage({super.key, this.initialTab = 0});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<MentorRequest>> _receivedStream;
  late Stream<List<MentorRequest>> _sentStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    final uid = AuthService.currentUid ?? '';
    _receivedStream = InteractionsService.getReceivedRequests(uid);
    _sentStream = InteractionsService.getSentRequests(uid);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Construit les widgets d'une section (pending en premier, puis traitées).
  List<Widget> _buildSection(
    List<MentorRequest> items, {
    required bool isSent,
    required String role,
  }) {
    final pending = items.where((r) => r.status == RequestStatus.pending).toList();
    final processed = items.where((r) => r.status != RequestStatus.pending).toList();
    return [
      if (pending.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            'En attente (${pending.length})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.amber,
            ),
          ),
        ),
        ...pending.map((r) => _RequestCard(request: r, isSent: isSent, role: role)),
      ],
      if (processed.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(
            'Traitées',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        ...processed.map((r) => _RequestCard(request: r, isSent: isSent, role: role)),
      ],
    ];
  }

  Widget _buildRequestList(
    Stream<List<MentorRequest>> stream, {
    required bool isSent,
  }) {
    return StreamBuilder<List<MentorRequest>>(
      stream: stream,
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

        final role = UserProfileController.profile.value.role;
        final currentUid = AuthService.currentUid ?? '';
        final all = snapshot.data ?? [];

        // Garde de direction côté client : garantit que "Envoyées" ne contient
        // que des demandes dont fromUserId == moi, et "Reçues" toUserId == moi.
        // Filet de sécurité si le filtre Firebase côté serveur est imparfait.
        final directionOk = isSent
            ? all.where((r) => r.fromUserId == currentUid).toList()
            : all.where((r) => r.toUserId == currentUid).toList();

        // Filtrage par rôle : chaque rôle ne voit que les types qui le concernent.
        final List<MentorRequest> requests;
        if (role == 'Mentor') {
          requests = directionOk.where((r) => r.type == 'mentor').toList();
        } else if (role == 'Investisseur') {
          requests = directionOk.where((r) => r.type == 'investment').toList();
        } else {
          // Entrepreneur : tout sauf les sessions (gérées par l'Agenda).
          requests = directionOk.where((r) => r.type != 'session').toList();
        }

        final mentorRequests =
            requests.where((r) => r.type == 'mentor').toList();
        final investmentRequests =
            requests.where((r) => r.type == 'investment').toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSent
                      ? Icons.send_outlined
                      : Icons.mail_outline_rounded,
                  size: 60,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  isSent
                      ? 'Aucune demande envoyée'
                      : 'Aucune demande reçue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDeep,
                  ),
                ),
              ],
            ),
          );
        }

        // Un entrepreneur qui contacte un investisseur cherche du financement ;
        // il ne "propose" pas d'investissement, donc on adapte le titre.
        final isEntrepreneur = role != 'Mentor' && role != 'Investisseur';
        final investSectionTitle = (isSent && isEntrepreneur)
            ? 'Demandes de financement'
            : 'Propositions d\'investissement';

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          children: [
            if (mentorRequests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Text(
                  'Demandes de mentorat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
              ),
              ..._buildSection(mentorRequests, isSent: isSent, role: role),
            ],
            if (investmentRequests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Text(
                  investSectionTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                  ),
                ),
              ),
              ..._buildSection(investmentRequests, isSent: isSent, role: role),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Demandes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicatorColor: AppColors.navyDeep,
          labelColor: AppColors.navyDeep,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Reçues'),
            Tab(text: 'Envoyées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestList(_receivedStream, isSent: false),
          _buildRequestList(_sentStream, isSent: true),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte de demande — s'adapte selon reçue ou envoyée
// ─────────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final MentorRequest request;
  /// true si c'est une demande envoyée par l'utilisateur courant
  final bool isSent;
  /// rôle de l'utilisateur courant ('Mentor', 'Investisseur', ou autre)
  final String role;

  const _RequestCard({required this.request, this.isSent = false, this.role = ''});

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.accepted:
        return AppColors.green;
      case RequestStatus.rejected:
        return AppColors.red;
      case RequestStatus.cancelled:
        return AppColors.muted;
      default:
        return AppColors.amber;
    }
  }

  String _getStatusLabel() {
    switch (request.status) {
      case RequestStatus.pending:
        return 'En attente';
      case RequestStatus.accepted:
        return 'Acceptée';
      case RequestStatus.rejected:
        return 'Refusée';
      case RequestStatus.cancelled:
        return 'Annulée';
    }
  }

  IconData get _typeIcon => request.type == 'investment'
      ? Icons.monetization_on_rounded
      : Icons.person_add_rounded;

  Color get _typeColor => request.type == 'investment'
      ? AppColors.green
      : AppColors.amber;

  String get _typeSubtitle {
    final isEntrepreneur = role != 'Mentor' && role != 'Investisseur';
    if (isSent) {
      if (request.type == 'investment') {
        // Entrepreneur cherchant du financement vs investisseur proposant.
        return isEntrepreneur
            ? 'Demande de financement envoyée à ${request.toName}'
            : 'Investissement proposé à ${request.toName}';
      }
      return role == 'Mentor'
          ? 'Offre de mentorat envoyée à ${request.toName}'
          : 'Demande de mentorat envoyée à ${request.toName}';
    }
    if (request.type == 'investment') {
      return '${request.fromName} te propose un investissement';
    }
    // Mentor qui offre son mentorat à un entrepreneur vs entrepreneur demandant.
    return isEntrepreneur
        ? '${request.fromName} te propose du mentorat'
        : '${request.fromName} te demande du mentorat';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == RequestStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? _typeColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon, color: _typeColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSent ? request.toName : request.fromName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _typeSubtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Il y a ${_formatTime(request.createdAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.navyDeep,
              height: 1.4,
            ),
          ),
          // Boutons Accepter/Refuser uniquement pour les demandes REÇUES en attente
          if (!isSent && isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRequest(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Refuser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red.withValues(alpha: 0.1),
                      foregroundColor: AppColors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(context),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Accepter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context) async {
    try {
      await InteractionsService.acceptRequest(request.id);

      // ── Incrémenter les compteurs selon le type de demande ──
      if (request.type == 'mentor') {
        final myUid = AuthService.currentUid;
        if (myUid != null) {
          // Mentor : +1 entrepreneur mentoré
          final profile = UserProfileController.profile.value;
          final updatedMentor = profile.copyWith(
            mentorsActive: profile.mentorsActive + 1,
          );
          UserProfileController.update(updatedMentor);
          await DatabaseService.updateUserProfile(myUid, updatedMentor);

          // Entrepreneur : +1 mentor actif
          try {
            final entrSnap =
                await DatabaseService.readUserProfile(request.fromUserId);
            if (entrSnap != null) {
              final updatedEntr = entrSnap.copyWith(
                mentorsActive: entrSnap.mentorsActive + 1,
              );
              await DatabaseService.updateUserProfile(
                  request.fromUserId, updatedEntr);
            }
          } catch (_) {}
        }
      } else if (request.type == 'investment') {
        // Investisseur : +1 opportunité active
        try {
          final investorSnap =
              await DatabaseService.readUserProfile(request.fromUserId);
          if (investorSnap != null) {
            final updatedInvestor = investorSnap.copyWith(
              mentorsActive: investorSnap.mentorsActive + 1,
            );
            await DatabaseService.updateUserProfile(
                request.fromUserId, updatedInvestor);
          }
        } catch (_) {}

        // Entrepreneur : +1 investisseur actif
        final myUid = AuthService.currentUid;
        if (myUid != null) {
          final profile = UserProfileController.profile.value;
          final updatedEntr = profile.copyWith(
            mentorsActive: profile.mentorsActive + 1,
          );
          UserProfileController.update(updatedEntr);
          await DatabaseService.updateUserProfile(myUid, updatedEntr);
        }
      }

      final label = request.type == 'investment'
          ? 'proposition d\'investissement'
          : 'demande de mentorat';
      await NotificationService.notifyUser(
        uid: request.fromUserId,
        title: 'Demande acceptée',
        message: '${request.toName} a accepté ta $label.',
        type: 'mentor_request_accepted',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Demande acceptée — notification envoyée.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur : impossible d\'accepter la demande. $e')),
      );
    }
  }

  Future<void> _rejectRequest(BuildContext context) async {
    try {
      await InteractionsService.rejectRequest(request.id);
      final label = request.type == 'investment'
          ? 'proposition d\'investissement'
          : 'demande de mentorat';
      await NotificationService.notifyUser(
        uid: request.fromUserId,
        title: 'Demande refusée',
        message: '${request.toName} a décliné ta $label.',
        type: 'mentor_request_rejected',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Demande refusée — notification envoyée.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur : impossible de refuser la demande. $e')),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${dt.day}/${dt.month}';
  }
}

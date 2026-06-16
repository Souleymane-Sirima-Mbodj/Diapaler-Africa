import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../data/donnees_mentors.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';

class SendRequestPage extends StatefulWidget {
  final Mentor mentor;
  /// true quand c'est un mentor qui propose son mentorat à un entrepreneur.
  final bool fromMentor;

  const SendRequestPage({super.key, required this.mentor, this.fromMentor = false});

  @override
  State<SendRequestPage> createState() => _SendRequestPageState();
}

class _SendRequestPageState extends State<SendRequestPage> {
  final _messageCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (_messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Écris un message.')),
      );
      return;
    }
    if (widget.mentor.isInvestor && _budgetCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indique le montant que tu recherches.'),
          backgroundColor: AppColors.amber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uid = AuthService.currentUid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion requise.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final currentProfile = UserProfileController.profile.value;
      // UID Firebase si le mentor est un membre inscrit, sinon nom (fallback demo).
      final toId = widget.mentor.uid.isNotEmpty
          ? widget.mentor.uid
          : widget.mentor.name;
      // Vérification anti-doublon : ne pas envoyer si une demande est déjà en attente.
      final alreadyPending = await InteractionsService.hasPendingRequest(
        fromUserId: uid,
        toUserId: toId,
      );
      if (alreadyPending) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu as déjà une demande en attente avec ce profil.'),
            backgroundColor: AppColors.amber,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final requestType = widget.mentor.isInvestor ? 'investment' : 'mentor';

      // Compose le message final avec la fourchette de budget si investisseur
      final budget = _budgetCtrl.text.trim();
      final fullMessage = widget.mentor.isInvestor && budget.isNotEmpty
          ? '${_messageCtrl.text}\n\nMontant recherché : $budget FCFA.'
          : _messageCtrl.text;

      final reqId = await InteractionsService.sendMentorRequest(
        fromUserId: uid,
        toUserId: toId,
        fromName: currentProfile.fullName,
        toName: widget.mentor.name,
        message: fullMessage,
        type: requestType,
      );

      final notifLabel = widget.fromMentor
          ? 'offre de mentorat'
          : widget.mentor.isInvestor
              ? 'proposition d\'investissement'
              : 'demande de mentorat';
      NotificationService.addNotification(
        title: 'Demande envoyée',
        message: 'Ton $notifLabel à ${widget.mentor.name} a bien été transmise.',
        type: 'mentor_request',
      );
      if (widget.mentor.uid.isNotEmpty) {
        final notifTitle = widget.fromMentor
            ? 'Offre de mentorat reçue 🤝'
            : widget.mentor.isInvestor
                ? 'Nouvelle demande d\'investissement 💰'
                : 'Nouvelle demande de mentorat 🤝';
        await NotificationService.notifyUser(
          uid: widget.mentor.uid,
          title: notifTitle,
          message: '${currentProfile.fullName} te contacte — "$fullMessage"',
          type: 'mentor_request',
          requestId: reqId,
          fromUserId: uid,
          fromName: currentProfile.fullName,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée! 🎉')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.fromMentor
              ? 'Proposer du mentorat'
              : widget.mentor.isInvestor
                  ? 'Rechercher un investissement'
                  : 'Demander du mentorat',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: [
          // Mentor Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Avatar(
                  initials: '${widget.mentor.name[0]}${widget.mentor.name.split(' ').length > 1 ? widget.mentor.name.split(' ')[1][0] : ''}',
                  size: 56,
                  background: AppColors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mentor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mentor.sectors.join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.mentor.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDeep,
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
          const SizedBox(height: 24),

          // ── Champ montant recherché (investisseur uniquement) ──
          if (widget.mentor.isInvestor) ...[
            const Text(
              'Montant recherché (FCFA) *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetCtrl,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Ex. 500 000 – 2 000 000',
                prefixIcon: const Icon(Icons.payments_rounded,
                    color: AppColors.subtle, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.fieldBg,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Indique une fourchette ou un montant précis.',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
          ],

          // ── Message ──
          const Text(
            'Ta demande',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageCtrl,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: widget.fromMentor
                  ? 'Présente ton expertise et en quoi tu peux aider cet entrepreneur…'
                  : widget.mentor.isInvestor
                      ? 'Présente ton projet et pourquoi tu cherches cet investissement…'
                      : 'Explique pourquoi tu cherches du mentorat, tes objectifs...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.fieldBg,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _sendRequest,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text(
                'ENVOYER LA DEMANDE',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

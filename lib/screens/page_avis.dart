import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_interactions.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_profil_public.dart';

/// Page listant tous les avis d'un profil (mentor, investisseur ou entrepreneur).
/// [canReview] = la relation est acceptée ET ce n'est pas son propre profil.
class ReviewsPage extends StatefulWidget {
  final Mentor mentor;
  final bool canReview;

  const ReviewsPage({
    super.key,
    required this.mentor,
    required this.canReview,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;
  late final Stream<List<Review>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = InteractionsService.getReviews(widget.mentor.uid);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final myUid = AuthService.currentUid ?? '';
    final myName = UserProfileController.profile.value.fullName;
    try {
      await InteractionsService.addReview(
        toUid: widget.mentor.uid,
        fromUid: myUid,
        fromName: myName.isNotEmpty ? myName : 'Utilisateur',
        text: text,
      );
      _ctrl.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de publier : $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  /// Formate une date en "15 jan 2026".
  String _fmt(DateTime d) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Initiales à partir d'un nom complet.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.mentor.name.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Avis',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDeep,
                ),
              ),
              Text(
                firstName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Liste des avis ──────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Review>>(
              stream: _stream,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) {
                  return _EmptyState(firstName: firstName);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ReviewCard(
                    review: reviews[i],
                    formatDate: _fmt,
                    initials: _initials(reviews[i].fromName),
                  ),
                );
              },
            ),
          ),

          // ── Zone basse : saisie ou message verrouillé ──────────
          _BottomArea(
            canReview: widget.canReview,
            ctrl: _ctrl,
            sending: _sending,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte d'un avis
// ─────────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final String Function(DateTime) formatDate;
  final String initials;

  const _ReviewCard({
    required this.review,
    required this.formatDate,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : avatar + nom (tappable) + date
          Row(
            children: [
              Avatar(initials: initials, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: review.fromUid.isNotEmpty
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfilPublicPage(
                                uid: review.fromUid,
                                name: review.fromName,
                              ),
                            ),
                          )
                      : null,
                  child: Text(
                    review.fromName,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: review.fromUid.isNotEmpty
                          ? AppColors.blue
                          : AppColors.navyDeep,
                      decoration: review.fromUid.isNotEmpty
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: AppColors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDate(review.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Texte de l'avis
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.navyDeep,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Zone basse (saisie ou message verrouillé)
// ─────────────────────────────────────────────────────────────────
class _BottomArea extends StatelessWidget {
  final bool canReview;
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSubmit;

  const _BottomArea({
    required this.canReview,
    required this.ctrl,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: canReview
          ? _InputRow(ctrl: ctrl, sending: sending, onSubmit: onSubmit)
          : const _LockedBanner(),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSubmit;

  const _InputRow({
    required this.ctrl,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            maxLines: 3,
            minLines: 1,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience…',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppColors.subtle),
              filled: true,
              fillColor: AppColors.fieldBg,
              counterStyle:
                  const TextStyle(fontSize: 10, color: AppColors.muted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.blue, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          height: 46,
          child: ElevatedButton(
            onPressed: sending ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock_outline_rounded, size: 15, color: AppColors.muted),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'Vous pourrez laisser un avis une fois la demande acceptée.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String firstName;
  const _EmptyState({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.reviews_outlined,
                  size: 38, color: AppColors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun avis pour l\'instant',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Soyez le premier à partager votre expérience avec $firstName.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/donnees_mentors.dart';
import '../data/interactions.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_agenda.dart';
import '../services/service_authentification.dart';
import '../services/service_cache.dart';
import '../services/service_navigation.dart';
import '../services/service_interactions.dart';
import '../services/service_notifications.dart';
import '../services/service_partage.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_avis.dart';
import 'page_connexion.dart';
import 'page_mes_pitchs.dart';
import 'page_modification_profil.dart';
import 'page_agenda.dart';
import 'page_mes_favoris.dart';
import 'page_mes_mentors.dart';
import 'page_pitches_publics.dart';
import 'page_requests.dart';

/// Pourcentage de complétion du profil — basé sur les champs remplis.
double _profileCompletion(UserProfile p) {
  final fields = <bool>[
    p.firstName.isNotEmpty,
    p.lastName.isNotEmpty,
    p.email.isNotEmpty,
    p.phone.isNotEmpty,
    p.birthDate != null,
    p.address.isNotEmpty,
    p.city.isNotEmpty,
    p.country.isNotEmpty,
    p.sector.isNotEmpty,
    p.bio.isNotEmpty,
    p.linkedin.isNotEmpty,
    p.interests.isNotEmpty,
  ];
  final filled = fields.where((x) => x).length;
  return filled / fields.length;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (_, p, __) {
        final completion = _profileCompletion(p);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon profil'),
            actions: [
              // Partage
              IconButton(
                tooltip: 'Partager mon profil',
                onPressed: () => ShareService.shareMyProfile(
                  name: p.fullName,
                  role: p.role,
                  sector: p.sector,
                  city: p.city,
                ),
                icon: const Icon(Icons.share_rounded),
              ),
              // Modifier
              IconButton(
                tooltip: 'Modifier',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const EditProfilePage(),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
              ),
              // Déconnexion (icône discrète dans l'AppBar)
              IconButton(
                tooltip: 'Se déconnecter',
                onPressed: () => _LogoutButton.confirmAndLogout(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.red),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // 1. Carte identité (photo, nom, rôle, complétion)
              _IdentityCard(profile: p, completion: completion),
              const SizedBox(height: 16),
              // 2. Stats (tappables)
              const _StatsStrip(),
              const SizedBox(height: 16),
              // 3. Bio + Coordonnées principales (condensées) + Intérêts
              _AboutCard(profile: p),
              const SizedBox(height: 12),
              _CompactCoordsCard(profile: p),
              const SizedBox(height: 12),
              _InterestsCard(interests: p.interests),
              // 4. Boutons d'actions rapides (Entrepreneur uniquement)
              if (p.role == 'Entrepreneur' || p.role == 'Entrepreneure') ...[
                const SizedBox(height: 16),
                const _InteractionsSection(),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Identity
// ─────────────────────────────────────────────────────────────────
class _IdentityCard extends StatelessWidget {
  final UserProfile profile;
  final double completion;
  const _IdentityCard({required this.profile, required this.completion});

  @override
  Widget build(BuildContext context) {
    final percent = (completion * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.amber, width: 2),
                    ),
                    child: Avatar(
                      initials: profile.initials,
                      size: 64,
                      background: AppColors.amber,
                      foreground: AppColors.navyDeep,
                      photoBase64: profile.photoBase64,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.role} · ${profile.sector}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            color: AppColors.amber, size: 13),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Text('  ·  🇸🇳', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barre de complétion du profil
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  color: AppColors.amber, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Profil complété',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '$percent %',
                style: const TextStyle(
                  color: AppColors.amber,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Stats strip — compacte
// ─────────────────────────────────────────────────────────────────
class _StatsStrip extends StatefulWidget {
  const _StatsStrip();

  @override
  State<_StatsStrip> createState() => _StatsStripState();
}

class _StatsStripState extends State<_StatsStrip> {
  late final String _uid;
  Stream<List<Review>>? _reviewsStream;
  Stream<Map<String, int>>? _ratingsStream;

  @override
  void initState() {
    super.initState();
    _uid = AuthService.currentUid ?? '';
    if (_uid.isNotEmpty) {
      _reviewsStream = InteractionsService.getReviews(_uid);
      _ratingsStream = InteractionsService.getRatings(_uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Double écoute : profile ET pendingRequestsCount
    // pour que les stats se mettent à jour dès que l'un ou l'autre change.
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserProfileController.profile,
      builder: (context, p, _) => ValueListenableBuilder<int>(
        valueListenable: pendingRequestsCount,
        builder: (context, pending, _) => ValueListenableBuilder<int>(
          valueListenable: pitchCount,
          builder: (context, pitches, _) =>
              _buildContent(context, p, pending, pitches),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, UserProfile p, int pending, int pitches) {
    if (p.role == 'Mentor' || p.role == 'Investisseur') {
      return _buildMentorInvestorStats(context, p);
    }
    // Entrepreneur / Entrepreneure — carte pleine largeur
    return _EntrepreneurStatCard(
      icon: Icons.rocket_launch_rounded,
      color: AppColors.amber,
      value: '$pitches',
      label: 'Projets',
      subtitle: 'pitch decks publiés',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MesPitchsPage()),
      ),
    );
  }

  Widget _buildMentorInvestorStats(BuildContext context, UserProfile p) {
    return Column(
      children: [
        // Carte expérience uniquement pour les Mentors
        if (p.role == 'Mentor') ...[
          _MentorExperienceCard(years: p.yearsExperience),
          const SizedBox(height: 10),
        ],
        // Ligne Note moy. + Avis reçus (live Firebase)
        Row(
          children: [
            Expanded(
              child: StreamBuilder<Map<String, int>>(
                stream: _ratingsStream,
                builder: (ctx, snap) {
                  final ratings = snap.data ?? {};
                  final avg = ratings.isEmpty
                      ? 0.0
                      : ratings.values.fold(0, (a, b) => a + b) /
                          ratings.length;
                  final display =
                      ratings.isEmpty ? '—' : avg.toStringAsFixed(1);
                  return _StatTile(
                    icon: Icons.star_rounded,
                    color: AppColors.amber,
                    value: display,
                    label: 'Note moy.',
                    subtitle:
                        '${ratings.length} vote${ratings.length != 1 ? 's' : ''}',
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<List<Review>>(
                stream: _reviewsStream,
                builder: (ctx, snap) {
                  final reviews = snap.data ?? [];
                  return _StatTile(
                    icon: Icons.reviews_outlined,
                    color: AppColors.purple,
                    value: '${reviews.length}',
                    label: 'Avis reçus',
                    subtitle: reviews.isEmpty ? 'Aucun avis' : 'au total',
                    onTap: _uid.isNotEmpty
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReviewsPage(
                                  mentor: _mentorFromProfile(p),
                                  canReview: false,
                                ),
                              ),
                            )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construit un objet [Mentor] depuis le profil courant pour accéder
  /// à la page d'avis en lecture seule (propre profil).
  Mentor _mentorFromProfile(UserProfile p) {
    return Mentor(
      initials: p.initials,
      name: p.fullName,
      title: p.sector.isNotEmpty ? p.sector : p.role,
      city: p.city,
      sectors: p.interests.isNotEmpty
          ? p.interests
          : (p.sector.isNotEmpty ? [p.sector] : ['—']),
      companies: const [],
      rating: p.score.toDouble(),
      reviews: 0,
      years: p.yearsExperience,
      compatibility: 0,
      role: p.role,
      bio: p.bio,
      uid: _uid,
      photoBase64: p.photoBase64,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Tuile de stat compacte (Note moy. / Avis reçus)
// ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? color.withValues(alpha: 0.35)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                if (onTap != null) ...[
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 14, color: AppColors.subtle),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDeep,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte expérience mentor (pleine largeur)
// ─────────────────────────────────────────────────────────────────
class _MentorExperienceCard extends StatelessWidget {
  final int years;
  const _MentorExperienceCard({required this.years});

  @override
  Widget build(BuildContext context) {
    final hasYears = years > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.roleMentor.withValues(alpha: 0.12),
            AppColors.amber.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.roleMentor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Icône dans un cercle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.35), width: 1.5),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: AppColors.amber, size: 26),
          ),
          const SizedBox(width: 16),
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasYears ? '$years ans' : 'Non renseigné',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: hasYears ? AppColors.navyDeep : AppColors.muted,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "d'expérience professionnelle",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          // Badge mentor
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.roleMentor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.roleMentor.withValues(alpha: 0.35)),
            ),
            child: const Text(
              'Mentor',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.roleMentor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte stat entrepreneur (design dédié 2 cartes)
// ─────────────────────────────────────────────────────────────────
class _EntrepreneurStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _EntrepreneurStatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDeep,
                height: 1,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.subtle),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: onTap != null
                    ? AppColors.blue.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDeep,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.2,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (badge > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Coordonnées condensées (email + téléphone + ville uniquement)
// ─────────────────────────────────────────────────────────────────
class _CompactCoordsCard extends StatelessWidget {
  final UserProfile profile;
  const _CompactCoordsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Email
          Expanded(
            child: _CompactRow(
              icon: Icons.mail_outline_rounded,
              text: profile.email.isEmpty ? '—' : profile.email,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          // Téléphone
          Expanded(
            child: _CompactRow(
              icon: Icons.phone_outlined,
              text: profile.phone.isEmpty ? 'Non renseigné' : profile.phone,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          // Ville
          Expanded(
            child: _CompactRow(
              icon: Icons.place_outlined,
              text: profile.city.isEmpty ? '—' : profile.city,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CompactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.navy),
        const SizedBox(height: 4),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.navyDeep,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Domaines d'intérêt + À propos
// ─────────────────────────────────────────────────────────────────
class _InterestsCard extends StatelessWidget {
  final List<String> interests;
  const _InterestsCard({required this.interests});

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
          const Text(
            "🏷️  Domaines d'intérêt",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          if (interests.isEmpty)
            const Text(
              'Aucun domaine sélectionné. Modifie ton profil pour en ajouter.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: interests
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.blueTint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final UserProfile profile;
  const _AboutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasBio = profile.bio.isNotEmpty;
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
          const Text(
            '📝  À propos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          if (hasBio)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 38,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navyDeep,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.amber, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Ajoute une bio pour te présenter aux mentors et investisseurs.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // ── Infos pro + LinkedIn (si renseignés) ─────────────
          if (profile.yearsExperience > 0 ||
              profile.investmentRange.isNotEmpty ||
              profile.linkedin.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Années d'expérience (Mentor)
                if (profile.yearsExperience > 0)
                  _ProChip(
                    icon: Icons.workspace_premium_rounded,
                    label: '${profile.yearsExperience} ans d\'expérience',
                    color: AppColors.roleMentor,
                  ),
                // Ticket d'investissement (Investisseur)
                if (profile.investmentRange.isNotEmpty)
                  _ProChip(
                    icon: Icons.payments_rounded,
                    label: profile.investmentRange,
                    color: AppColors.roleInvestor,
                  ),
                // LinkedIn (cliquable)
                if (profile.linkedin.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      var url = profile.linkedin.trim();
                      if (!url.startsWith('http')) url = 'https://$url';
                      final uri = Uri.tryParse(url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const _ProChip(
                      icon: Icons.link_rounded,
                      label: 'LinkedIn',
                      color: AppColors.blue,
                      tappable: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool tappable;
  const _ProChip({
    required this.icon,
    required this.label,
    required this.color,
    this.tappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 11, color: color),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Interactions Section
// ─────────────────────────────────────────────────────────────────
/// Boutons d'actions rapides — visibles pour les Entrepreneurs uniquement
/// (la section est conditionnée dans ProfilePage).
class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDeep,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _InteractionButton(
                icon: Icons.people_rounded,
                label: 'Mes demandes',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RequestsPage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.blue, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navyDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bouton "Se déconnecter" en bas de page
// ─────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  // Statique pour être appelable depuis l'AppBar
  static Future<void> confirmAndLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Tu devras te reconnecter pour accéder à ton tableau de bord.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await CacheService.clear();
    NotificationService.reset();
    await AgendaController.reset();
    UserProfileController.reset();
    appTabIndex.value = 0;
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: const LoginPage(),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => confirmAndLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

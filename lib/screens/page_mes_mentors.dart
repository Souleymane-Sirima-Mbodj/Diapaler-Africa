import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../services/service_interactions.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_detail_mentor.dart';

/// Convertit un [UserProfile] Firebase en objet [Mentor].
Mentor _mentorFromProfile(UserProfile p, String uid) {
  return Mentor(
    initials: p.initials,
    name: p.fullName,
    title: p.sector.isNotEmpty ? p.sector : p.role,
    city: p.city,
    sectors:
        p.interests.isNotEmpty ? p.interests : (p.sector.isNotEmpty ? [p.sector] : ['—']),
    companies: const [],
    rating: p.score.toDouble(),
    reviews: 0,
    years: p.yearsExperience,
    compatibility: 0,
    role: p.role,
    bio: p.bio,
    uid: uid,
    photoBase64: p.photoBase64,
  );
}

/// Entrée combinant l'objet [Mentor] et l'ID de la demande Firebase.
class _ContactEntry {
  final String requestId;
  final Mentor mentor;
  final String fromUserId;
  final String toUserId;

  _ContactEntry({
    required this.requestId,
    required this.mentor,
    required this.fromUserId,
    required this.toUserId,
  });
}

/// Liste des mentors ET des investisseurs actifs de l'entrepreneur connecté.
class MesMentorsPage extends StatefulWidget {
  const MesMentorsPage({super.key});

  @override
  State<MesMentorsPage> createState() => _MesMentorsPageState();
}

class _MesMentorsPageState extends State<MesMentorsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<_ContactEntry> _mentors = [];
  List<_ContactEntry> _investors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Chargement ──────────────────────────────────────────────────
  Future<void> _loadContacts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final myUid = AuthService.currentUid;
      if (myUid == null) {
        setState(() => _loading = false);
        return;
      }

      final snap =
          await FirebaseDatabase.instance.ref('mentorRequests').get();

      final List<_ContactEntry> mentors = [];
      final List<_ContactEntry> investors = [];

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);

        for (final entry in data.entries) {
          final m = Map<String, dynamic>.from(entry.value as Map);
          final status = m['status']?.toString() ?? '';
          final type = m['type']?.toString() ?? '';
          if (status != 'accepted') continue;

          final fromUid = m['fromUserId']?.toString() ?? '';
          final toUid = m['toUserId']?.toString() ?? '';
          String? profileUid;

          if (type == 'mentor' && fromUid == myUid) {
            profileUid = toUid; // UID du mentor
          } else if (type == 'investment' && toUid == myUid) {
            profileUid = fromUid; // UID de l'investisseur
          }

          if (profileUid == null || profileUid.isEmpty) continue;

          try {
            final profile = await DatabaseService.readUserProfile(profileUid);
            if (profile != null) {
              final contactEntry = _ContactEntry(
                requestId: entry.key,
                mentor: _mentorFromProfile(profile, profileUid),
                fromUserId: fromUid,
                toUserId: toUid,
              );
              if (type == 'mentor') {
                mentors.add(contactEntry);
              } else {
                investors.add(contactEntry);
              }
            }
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _mentors = mentors;
          _investors = investors;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement.';
          _loading = false;
        });
      }
    }
  }

  // ── Suppression ─────────────────────────────────────────────────
  Future<void> _deleteContact(
      BuildContext context, _ContactEntry entry, String type) async {
    final label = type == 'mentor' ? 'mentor' : 'investisseur';
    final name = entry.mentor.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer ce $label ?'),
        content:
            Text('$name sera retiré(e) de vos ${label}s actifs. Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await InteractionsService.cancelRequest(
        requestId: entry.requestId,
        fromUserId: entry.fromUserId,
        toUserId: entry.toUserId,
      );
      // Met à jour le compteur local immédiatement
      final p = UserProfileController.profile.value;
      UserProfileController.update(
          p.copyWith(mentorsActive: (p.mentorsActive - 1).clamp(0, 9999)));
      // Recharge la liste
      await _loadContacts();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name retiré(e) de vos ${label}s.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadContacts,
            tooltip: 'Actualiser',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          indicatorColor: AppColors.navyDeep,
          labelColor: AppColors.navyDeep,
          unselectedLabelColor: AppColors.muted,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.handshake_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text('Mentors (${_mentors.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text('Investisseurs (${_investors.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadContacts)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _ContactList(
                      entries: _mentors,
                      emptyIcon: Icons.handshake_outlined,
                      emptyTitle: 'Aucun mentor actif',
                      emptySubtitle:
                          'Envoie une demande depuis\nl\'onglet Matching.',
                      accentColor: AppColors.roleMentor,
                      roleLabel: 'Mentor',
                      onDelete: (entry) =>
                          _deleteContact(context, entry, 'mentor'),
                    ),
                    _ContactList(
                      entries: _investors,
                      emptyIcon: Icons.trending_up_outlined,
                      emptyTitle: 'Aucun investisseur actif',
                      emptySubtitle:
                          'Les investisseurs qui t\'ont contacté\napparaîtront ici.',
                      accentColor: AppColors.blue,
                      roleLabel: 'Investisseur',
                      onDelete: (entry) =>
                          _deleteContact(context, entry, 'investissement'),
                    ),
                  ],
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Liste de contacts (réutilisable pour mentors et investisseurs)
// ─────────────────────────────────────────────────────────────────
class _ContactList extends StatelessWidget {
  final List<_ContactEntry> entries;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final Color accentColor;
  final String roleLabel;
  final void Function(_ContactEntry) onDelete;

  const _ContactList({
    required this.entries,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.accentColor,
    required this.roleLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 64, color: AppColors.muted),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return _ContactCard(
          entry: entry,
          accentColor: accentColor,
          roleLabel: roleLabel,
          onDelete: () => onDelete(entry),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MentorDetailPage(mentor: entry.mentor),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Carte individuelle de contact
// ─────────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final _ContactEntry entry;
  final Color accentColor;
  final String roleLabel;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ContactCard({
    required this.entry,
    required this.accentColor,
    required this.roleLabel,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mentor = entry.mentor;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Avatar(
                initials: mentor.initials,
                background: accentColor,
                photoBase64: mentor.photoBase64,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mentor.title,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Bouton supprimer
              IconButton(
                icon: const Icon(Icons.person_remove_rounded),
                color: AppColors.red.withValues(alpha: 0.7),
                tooltip: 'Supprimer',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// État d'erreur
// ─────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_authentification.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';
import 'page_detail_mentor.dart';

/// Convertit un [UserProfile] Firebase en objet [Mentor] pour [MentorDetailPage].
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

/// Liste des mentors actifs de l'entrepreneur connecté.
/// Affiche uniquement les demandes de type 'mentor' acceptées.
class MesMentorsPage extends StatefulWidget {
  const MesMentorsPage({super.key});

  @override
  State<MesMentorsPage> createState() => _MesMentorsPageState();
}

class _MesMentorsPageState extends State<MesMentorsPage> {
  List<Mentor> _mentors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  Future<void> _loadMentors() async {
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

      // Demandes envoyées par moi (entrepreneur), acceptées, type mentor
      final snap = await FirebaseDatabase.instance
          .ref('mentorRequests')
          .orderByChild('fromUserId')
          .equalTo(myUid)
          .get();

      final List<Mentor> mentors = [];
      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        for (final v in data.values) {
          final m = Map<String, dynamic>.from(v as Map);
          final status = m['status']?.toString() ?? '';
          final type = m['type']?.toString() ?? 'mentor';
          if (status != 'accepted' || type != 'mentor') continue;

          final toUid = m['toUserId']?.toString() ?? '';
          if (toUid.isEmpty) continue;

          try {
            final profile = await DatabaseService.readUserProfile(toUid);
            if (profile != null) {
              mentors.add(_mentorFromProfile(profile, toUid));
            }
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _mentors = mentors;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Mentors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMentors,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: _loadMentors,
                          child: const Text('Réessayer')),
                    ],
                  ),
                )
              : _mentors.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.handshake_outlined,
                                size: 64, color: AppColors.muted),
                            SizedBox(height: 16),
                            Text(
                              'Aucun mentor actif pour l\'instant',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDeep),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Envoie une demande depuis\nl\'onglet Matching.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMentors,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: _mentors.length,
                        itemBuilder: (context, i) {
                          final mentor = _mentors[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Avatar(
                                initials: mentor.initials,
                                background: AppColors.roleMentor,
                                photoBase64: mentor.photoBase64,
                              ),
                              title: Text(
                                mentor.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDeep),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    mentor.title,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.muted),
                                  ),
                                  if (mentor.city.isNotEmpty)
                                    Text(
                                      mentor.city,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.muted),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MentorDetailPage(mentor: mentor),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

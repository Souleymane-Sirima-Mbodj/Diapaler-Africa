import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import 'page_detail_mentor.dart';

/// Pont de chargement : charge le profil Firebase puis redirige vers MentorDetailPage.
class ProfilPublicPage extends StatefulWidget {
  final String uid;
  final String name;

  const ProfilPublicPage({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  State<ProfilPublicPage> createState() => _ProfilPublicPageState();
}

class _ProfilPublicPageState extends State<ProfilPublicPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await DatabaseService.readUserProfile(widget.uid);
    if (!mounted) return;

    if (p == null) {
      // Profil introuvable — on reste sur cette page avec un message
      setState(() => _notFound = true);
      return;
    }

    final mentor = Mentor(
      uid: widget.uid,
      initials: p.initials,
      name: p.fullName,
      title: p.sector.isNotEmpty ? p.sector : p.role,
      city: p.city,
      sectors: p.interests.isNotEmpty
          ? p.interests
          : (p.sector.isNotEmpty ? [p.sector] : []),
      companies: const [],
      rating: p.score,
      reviews: 0,
      years: p.yearsExperience,
      compatibility: 0,
      role: p.role,
      gender: p.gender,
      bio: p.bio,
      photoBase64: p.photoBase64,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MentorDetailPage(mentor: mentor)),
    );
  }

  bool _notFound = false;

  @override
  Widget build(BuildContext context) {
    if (_notFound) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined, size: 56, color: AppColors.subtle),
              SizedBox(height: 14),
              Text(
                'Profil non disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyDeep,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

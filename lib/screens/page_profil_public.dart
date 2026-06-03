import 'package:flutter/material.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_base_de_donnees.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar.dart';

/// Page publique du profil d'un utilisateur Firebase (entrepreneur, etc.)
/// chargé par son UID.
class ProfilPublicPage extends StatelessWidget {
  final String uid;
  final String name;

  const ProfilPublicPage({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<UserProfile?>(
        future: DatabaseService.readUserProfile(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined,
                        size: 56, color: AppColors.subtle),
                    const SizedBox(height: 14),
                    const Text(
                      'Profil non disponible',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }
          return _ProfileBody(profile: p);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final UserProfile profile;
  const _ProfileBody({required this.profile});

  Color get _roleColor {
    switch (profile.role) {
      case 'Mentor':
        return AppColors.roleMentor;
      case 'Investisseur':
        return AppColors.blue;
      default:
        return AppColors.roleEntrepreneur;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        // ── Avatar + nom ─────────────────────────────────────────
        Row(
          children: [
            Avatar(
              initials: p.initials,
              size: 64,
              background: _roleColor,
              photoBase64: p.photoBase64,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDeep,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      p.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _roleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Infos rapides ─────────────────────────────────────────
        if (p.sector.isNotEmpty)
          _InfoRow(Icons.category_rounded, 'Secteur', p.sector),
        if (p.city.isNotEmpty) ...[
          const SizedBox(height: 10),
          _InfoRow(Icons.place_outlined, 'Ville', p.city),
        ],

        // ── Bio ───────────────────────────────────────────────────
        if (p.bio.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.bio,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.navyDeep,
                height: 1.5,
              ),
            ),
          ),
        ],

        // ── Domaines / intérêts ───────────────────────────────────
        if (p.interests.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Domaines',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDeep,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.interests
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _roleColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _roleColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _roleColor,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.navyDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

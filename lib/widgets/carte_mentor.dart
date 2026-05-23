import 'package:flutter/material.dart';
import '../data/donnees_mentors.dart';
import '../screens/page_detail_mentor.dart';
import '../theme/theme_app.dart';
import 'avatar.dart';
import 'carte_lumineuse.dart';

class MentorCard extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback? onTap;
  final double? distanceKm;

  const MentorCard({super.key, required this.mentor, this.onTap, this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return HoverGlowCard(
      onTap: onTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MentorDetailPage(mentor: mentor),
                ),
              ),
      padding: const EdgeInsets.all(14),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(initials: mentor.initials, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mentor.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navyDeep,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (mentor.isInvestor) const _InvestorBadge(),
                            if (mentor.cis && !mentor.isInvestor) const _CisBadge(),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mentor.title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppColors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${mentor.rating}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${mentor.reviews})  ·  ',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.muted,
                              ),
                            ),
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.muted),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                mentor.city,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mentor.sectors
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CompatibilityPill(value: mentor.compatibility),
                  if (distanceKm != null) ...[
                    const SizedBox(width: 8),
                    _DistancePill(km: distanceKm!),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MentorDetailPage(mentor: mentor),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                    child: const Text(
                      'Voir le profil  →',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  final double km;
  const _DistancePill({required this.km});

  @override
  Widget build(BuildContext context) {
    final label = km < 1
        ? '< 1 km'
        : km < 10
            ? '${km.toStringAsFixed(1)} km'
            : '${km.round()} km';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me_rounded, size: 13, color: AppColors.purple),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestorBadge extends StatelessWidget {
  const _InvestorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 12, color: AppColors.green),
          SizedBox(width: 3),
          Text(
            'Investisseur',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CisBadge extends StatelessWidget {
  const _CisBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amberSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: AppColors.amber),
          SizedBox(width: 3),
          Text(
            'CIS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.navyDeep,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityPill extends StatelessWidget {
  final int value;
  const _CompatibilityPill({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.green),
          const SizedBox(width: 4),
          Text(
            '$value % compatibilité',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

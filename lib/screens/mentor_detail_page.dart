import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';

class MentorDetailPage extends StatelessWidget {
  final Mentor mentor;
  const MentorDetailPage({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 218,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDeep, AppColors.navy, AppColors.blue],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Avatar(
                              initials: mentor.initials,
                              size: 70,
                              background: AppColors.amber,
                              foreground: AppColors.navyDeep,
                            ),
                            const SizedBox(width: 14),
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
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (mentor.cis) const _CisBadgeBig(),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mentor.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _HeroChip(
                                        icon: Icons.location_on_outlined,
                                        label: mentor.city,
                                      ),
                                      _HeroChip(
                                        icon: Icons.business_rounded,
                                        label:
                                            '${mentor.companies.length} entreprise${mentor.companies.length > 1 ? "s" : ""}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 8),
                        // Stats inline dans le hero
                        Row(
                          children: [
                            Expanded(child: _HeroStat(
                              icon: Icons.star_rounded,
                              color: AppColors.amber,
                              value: mentor.rating.toStringAsFixed(1),
                              label: 'Note',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.bolt_rounded,
                              color: AppColors.green,
                              value: '${mentor.compatibility} %',
                              label: 'Match',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.timeline_rounded,
                              color: AppColors.blueBright,
                              value: '${mentor.years}+',
                              label: 'Années',
                            )),
                            _HeroDivider(),
                            Expanded(child: _HeroStat(
                              icon: Icons.reviews_rounded,
                              color: AppColors.purple,
                              value: '${mentor.reviews}',
                              label: 'Avis',
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 18),
              const _SectionTitle('À propos'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${mentor.name} accompagne les jeunes entrepreneurs sénégalais '
                  'depuis ${mentor.years} ans dans les secteurs ${mentor.sectors.join(", ")}. '
                  'Convaincu·e que l\'avenir de l\'Afrique se joue dans la jeunesse, '
                  'il/elle privilégie un mentorat sectoriel concret et bienveillant.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Domaines d\'expertise'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mentor.sectors.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.blueTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (mentor.companies.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(
                    'Entreprises (${mentor.companies.length})'),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CompaniesList(companies: mentor.companies),
                ),
              ],
              const SizedBox(height: 22),
              const _SectionTitle('Créneaux disponibles'),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tape sur un créneau pour le sélectionner.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 10),
              const _SlotsRow(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Session réservée avec ${mentor.name.split(" ").first} 🎉'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month_rounded,
                            size: 18),
                        label: const Text('Réserver une session'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CisBadgeBig extends StatelessWidget {
  const _CisBadgeBig();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: AppColors.navyDeep),
          SizedBox(width: 4),
          Text(
            'CIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDeep,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.navyDeep,
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _HeroStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.amber, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompaniesList extends StatelessWidget {
  final List<String> companies;
  const _CompaniesList({required this.companies});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: companies.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.amber.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.business_rounded,
                  size: 13, color: AppColors.amber),
              const SizedBox(width: 6),
              Text(
                c,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SlotsRow extends StatefulWidget {
  const _SlotsRow();

  @override
  State<_SlotsRow> createState() => _SlotsRowState();
}

class _SlotsRowState extends State<_SlotsRow> {
  int? _selected;

  static const _slots = [
    ('Lundi', '14h00'),
    ('Mardi', '10h00'),
    ('Mercredi', '15h00'),
    ('Jeudi', '11h00'),
    ('Vendredi', '16h00'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = _slots[i];
          final isSelected = _selected == i;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(
                  () => _selected = isSelected ? null : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 96,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.navy : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppColors.amber.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.$1.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.amber
                            : AppColors.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.$2,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? Colors.white
                            : AppColors.navyDeep,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 11, color: AppColors.navyDeep),
                            SizedBox(width: 2),
                            Text(
                              'Choisi',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.navyDeep,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Libre',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

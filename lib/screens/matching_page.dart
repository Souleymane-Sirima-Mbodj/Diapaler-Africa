import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/mentor_card.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _sector = 'Tous';
  String _city = 'Toutes';

  static const _topSectors = <String>[
    'Tous',
    'Agro-industrie',
    'Tech & Digital',
    'Gastronomie',
    'FinTech',
    'Mode & Textile',
    'Cosmétique',
    'Automobile',
    'Énergie',
    'Santé',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Mentor> get _filtered {
    return mentors.where((m) {
      if (!m.matches(_query)) return false;
      if (_sector != 'Tous' &&
          !m.sectors.any((s) => s.toLowerCase() == _sector.toLowerCase())) {
        return false;
      }
      if (_city != 'Toutes' && m.city != _city) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.compatibility.compareTo(a.compatibility));
  }

  List<String> get _cities {
    final s = mentors.map((m) => m.city).toSet().toList()..sort();
    return ['Toutes', ...s];
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
      _sector = 'Tous';
      _city = 'Toutes';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasFilter =
        _query.isNotEmpty || _sector != 'Tous' || _city != 'Toutes';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trouver un mentor'),
        actions: [
          if (hasFilter)
            TextButton(
              onPressed: _resetFilters,
              child: const Text(
                'Réinitialiser',
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.subtle),
                hintText: 'Nom, secteur, ville…',
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.subtle),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
              ),
            ),
          ),
          // Pills secteurs
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _topSectors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _topSectors[i];
                final selected = s == _sector;
                return GestureDetector(
                  onTap: () => setState(() => _sector = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.navy : Colors.white,
                      border: Border.all(
                        color:
                            selected ? AppColors.navy : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        s,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.navyDeep,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Filtre ville (dropdown compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.place_outlined,
                    size: 16, color: AppColors.muted),
                const SizedBox(width: 4),
                _CityDropdown(
                  value: _city,
                  values: _cities,
                  onChanged: (v) => setState(() => _city = v),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} mentor${filtered.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        MentorCard(mentor: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CityDropdown extends StatelessWidget {
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _CityDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.muted, size: 18),
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.navyDeep,
        ),
        items: values
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.fieldBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.subtle, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'Aucun mentor trouvé',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Essaie de changer le secteur ou la ville,\nou de retirer la recherche.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

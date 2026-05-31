import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/donnees_mentors.dart';
import '../data/profil_utilisateur.dart';
import '../services/service_geolocation.dart';
import '../services/service_utilisateurs.dart';
import '../theme/theme_app.dart';
import '../widgets/carte_mentor.dart';

/// Retourne le titre de la page selon le rôle de l'utilisateur courant.
String _matchingTitle(String role) {
  switch (role) {
    case 'Mentor':
      return 'Mes Entrepreneurs';
    case 'Investisseur':
      return 'Entrepreneurs à financer';
    default:
      return 'Mentors & Investisseurs';
  }
}

/// Retourne les pills de filtre rôle selon le rôle de l'utilisateur courant.
List<String> _rolePills(String role) {
  if (role == 'Mentor' || role == 'Investisseur') {
    return ['Tous', 'Entrepreneur'];
  }
  return ['Tous', 'Mentor', 'Investisseur'];
}

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
  String _role = 'Tous';
  Position? _userPosition;
  bool _nearMe = false;
  bool _loadingLocation = false;

  /// Membres réels DIAPALER (inscrits via SignUpPage avec rôle Mentor/Investisseur).
  /// Affichés en tête de liste avec un badge "Membre DIAPALER".
  List<Mentor> _members = const [];
  bool _loadingMembers = true;

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
    _loadMembers();
  }

  int _computeCompatibility(Mentor m) {
    final profile = UserProfileController.profile.value;
    final userInterests = profile.interests
        .map((s) => s.toLowerCase().trim())
        .toSet();
    final mentorSectors = m.sectors
        .map((s) => s.toLowerCase().trim())
        .toSet();

    if (userInterests.isEmpty || mentorSectors.isEmpty) return 50;

    // Correspondance exacte
    final exact = userInterests.intersection(mentorSectors);
    if (exact.isNotEmpty) {
      final pct = (65 + (exact.length / mentorSectors.length) * 34).round();
      return pct.clamp(65, 99);
    }

    // Correspondance partielle (ex: "Agriculture" dans "Agro-industrie")
    final partial = userInterests.any((ui) =>
        mentorSectors.any((ms) => ms.contains(ui) || ui.contains(ms)));
    if (partial) return 60;

    // Même secteur principal
    final userSector = profile.sector.toLowerCase().trim();
    if (mentorSectors.any((ms) => ms.contains(userSector) || userSector.contains(ms))) {
      return 58;
    }

    return (20 + (userInterests.length * 2)).clamp(20, 40).toInt();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await UsersService.listMembers();
      if (!mounted) return;
      setState(() {
        _members = members;
        _loadingMembers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMembers = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Mentor> get _filtered {
    // Dédupliquer : les membres Firebase en priorité sur les profils statiques
    final seen = <String>{};
    final all = <Mentor>[];
    for (final m in _members) {
      if (seen.add(m.uid.isNotEmpty ? m.uid : m.name)) all.add(m);
    }
    for (final m in mentors) {
      if (seen.add(m.uid.isNotEmpty ? m.uid : m.name)) all.add(m);
    }
    final list = all.where((m) {
      if (!m.matches(_query)) return false;
      if (_sector != 'Tous' &&
          !m.sectors.any((s) => s.toLowerCase() == _sector.toLowerCase())) {
        return false;
      }
      if (_city != 'Toutes' && m.city != _city) return false;
      if (_role != 'Tous' && m.role != _role) return false;
      return true;
    }).toList();

    if (_nearMe && _userPosition != null) {
      list.sort((a, b) {
        final da = _distanceFor(a) ?? double.infinity;
        final db = _distanceFor(b) ?? double.infinity;
        return da.compareTo(db);
      });
    } else {
      // Membres DIAPALER (uid non vide) en priorité, puis tri par compatibilité calculée.
      list.sort((a, b) {
        final aIsMember = a.uid.isNotEmpty ? 1 : 0;
        final bIsMember = b.uid.isNotEmpty ? 1 : 0;
        if (aIsMember != bIsMember) return bIsMember - aIsMember;
        return _computeCompatibility(b).compareTo(_computeCompatibility(a));
      });
    }
    return list;
  }

  List<String> get _cities {
    final all = [..._members, ...mentors];
    final s = all.map((m) => m.city).toSet().toList()..sort();
    return ['Toutes', ...s];
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
      _sector = 'Tous';
      _city = 'Toutes';
      _role = 'Tous';
      _nearMe = false;
      _userPosition = null;
    });
  }

  Future<void> _toggleNearMe() async {
    if (_nearMe) {
      setState(() { _nearMe = false; _userPosition = null; });
      return;
    }
    setState(() => _loadingLocation = true);
    final pos = await GeolocationService.getCurrentLocation();
    if (!mounted) return;
    if (pos != null) {
      setState(() { _userPosition = pos; _nearMe = true; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'obtenir ta position.')),
      );
    }
    setState(() => _loadingLocation = false);
  }

  double? _distanceFor(Mentor m) {
    if (_userPosition == null) return null;
    return GeolocationService.distanceKmToCity(_userPosition!, m.city);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasFilter =
        _query.isNotEmpty || _sector != 'Tous' || _city != 'Toutes' || _role != 'Tous';

    return Scaffold(
      appBar: AppBar(
        title: Text(_matchingTitle(UserProfileController.profile.value.role)),
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
          // Bouton Près de moi
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: GestureDetector(
              onTap: _loadingLocation ? null : _toggleNearMe,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _nearMe ? AppColors.purple : Colors.white,
                  border: Border.all(
                    color: _nearMe ? AppColors.purple : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _loadingLocation
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.near_me_rounded,
                            size: 16,
                            color: _nearMe ? Colors.white : AppColors.purple,
                          ),
                    const SizedBox(width: 7),
                    Text(
                      _nearMe ? 'Trié par distance ✓' : 'Près de moi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _nearMe ? Colors.white : AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pills rôle — SingleChildScrollView pour éviter l'overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                for (final r in _rolePills(UserProfileController.profile.value.role))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _role = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _role == r ? AppColors.navyDeep : Colors.white,
                          border: Border.all(
                            color: _role == r
                                ? AppColors.navyDeep
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _role == r
                              ? [
                                  BoxShadow(
                                    color: AppColors.navyDeep
                                        .withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          r,
                          style: TextStyle(
                            color: _role == r
                                ? Colors.white
                                : AppColors.navyDeep,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
                if (_loadingMembers) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Chargement…',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else
                  Text(
                    '${filtered.length} profil${filtered.length > 1 ? "s" : ""}',
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
                    itemBuilder: (_, i) => MentorCard(
                      mentor: filtered[i],
                      distanceKm: _distanceFor(filtered[i]),
                    ),
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
              'Aucun profil trouvé',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDeep,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Essaie de changer le rôle, le secteur ou la ville.',
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

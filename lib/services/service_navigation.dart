import 'package:flutter/foundation.dart';

/// Notifier global pour changer d'onglet depuis n'importe quel widget enfant
/// sans dépendance circulaire entre les dashboards et la coquille principale.
///
/// Indices des onglets :
///   0 → Accueil     1 → Matching
///   2 → Messages    3 → Agenda    4 → Profil
final ValueNotifier<int> appTabIndex = ValueNotifier<int>(0);

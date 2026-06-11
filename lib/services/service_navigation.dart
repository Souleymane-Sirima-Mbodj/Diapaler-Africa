import 'package:flutter/foundation.dart';

/// Notifier global pour changer d'onglet depuis n'importe quel widget enfant
/// sans dépendance circulaire entre les dashboards et la coquille principale.
///
/// Indices des onglets :
///   0 → Accueil     1 → Matching
///   2 → Messages    3 → Agenda    4 → Profil
final ValueNotifier<int> appTabIndex = ValueNotifier<int>(0);

/// Nombre total de messages non lus — mis à jour par MessagesPage dès que
/// le stream Firebase émet de nouvelles données, même si l'onglet est inactif.
/// Utilisé par la barre de navigation pour afficher le badge sur l'onglet Messages.
final ValueNotifier<int> unreadMessagesCount = ValueNotifier<int>(0);

/// Nombre de demandes en attente (pending) reçues par l'utilisateur courant.
/// Mis à jour en temps réel depuis Firebase. Utilisé pour les badges sur les
/// boutons "Demandes" dans les dashboards Mentor, Investisseur et Profil.
final ValueNotifier<int> pendingRequestsCount = ValueNotifier<int>(0);

/// Nombre de pitchs publiés par l'entrepreneur connecté.
/// Mis à jour en temps réel depuis Firebase (nœud `pitches/`).
/// Utilisé pour les stats "Projets" et "Terminés" du profil entrepreneur.
final ValueNotifier<int> pitchCount = ValueNotifier<int>(0);

/// Demande de pré-filtre rôle pour MatchingPage.
/// Quand une valeur non vide est émise (ex. 'Mentor'), MatchingPage applique
/// ce filtre puis remet la valeur à '' pour éviter les re-déclenchements.
final ValueNotifier<String> matchingFilterRequest = ValueNotifier<String>('');

/// Déclenche le focus automatique sur le champ de recherche de MatchingPage.
/// Émis à true quand l'utilisateur tape sur la barre de recherche de l'accueil,
/// consommé par MatchingPage qui remet la valeur à false.
final ValueNotifier<bool> matchingFocusSearch = ValueNotifier<bool>(false);

---

&nbsp;

&nbsp;

&nbsp;

# ![Logo ESP]  École Supérieure Polytechnique de Dakar

&nbsp;

---

# DIAPALER AFRICA
## Plateforme mobile de mentorat entrepreneurial

&nbsp;

# LIVRABLE 5
## Fonctionnalités Avancées

&nbsp;

---

| | |
|---|---|
| **Membre 1** | Alioune Badara Barry |
| **Membre 2** | Anta Diama Kama |
| **Membre 3** | Souleymane Sirima Mbodj |
| **Membre 4** | Serigne Abdoul Aziz Ndiaye |
| **Membre 5** | Mohamed Moctar Niang |
| **Membre 6** | Mareme Tine |
| **Classe / Filière** | [Ta Classe] |
| **Enseignant** | [Nom du Professeur] |
| **Module** | Développement d'Applications Mobiles |
| **Institution** | École Supérieure Polytechnique (ESP) — Dakar |
| **Année académique** | 2025 – 2026 |
| **Date de remise** | [Date] |

---

&nbsp;

> **📸 [Insérer ici le logo de l'ESP et/ou une capture de l'application]**

&nbsp;

---

# LIVRABLE 5 — Fonctionnalités Avancées

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [Introduction](#introduction)
- [1. Système de Notifications](#1-système-de-notifications)
  - [1.1 Modèle de données](#11-modèle-de-données)
  - [1.2 Service de notifications](#12-service-de-notifications)
  - [1.3 Badge de notifications dynamique](#13-badge-de-notifications-dynamique)
  - [1.4 Centre de notifications](#14-centre-de-notifications-page_notificationsdart)
- [2. Recherche et Filtres avancés](#2-recherche-et-filtres-avancés)
- [3. Géolocalisation GPS](#3-géolocalisation-gps)
  - [3.1 Service de géolocalisation](#31-service-de-géolocalisation-service_geolocationdart)
  - [3.2 Bouton "Près de moi"](#32-bouton-près-de-moi)
  - [3.3 Affichage de la distance sur les cartes](#33-affichage-de-la-distance-sur-les-cartes)
- [4. Chatbot IA — DIALI](#4-chatbot-ia--diali)
  - [4.1 Présentation](#41-présentation)
  - [4.2 FAB chatbot avec animation "pulse"](#42-fab-chatbot-avec-animation-pulse-coquille_principaledart)
  - [4.3 Interface du chatbot](#43-interface-du-chatbot-page_chatbotdart)
- [5. Messagerie temps réel](#5-messagerie-temps-réel)
  - [5.1 Badge de messages non lus (ValueNotifier global)](#51-badge-de-messages-non-lus-valuenotifier-global)
  - [5.2 Liste des conversations](#52-liste-des-conversations)
  - [5.3 Chat individuel](#53-chat-individuel)
- [6. Fonctionnalités supplémentaires bonus](#6-fonctionnalités-supplémentaires-bonus)
  - [6.1 Agenda Firebase — Réservation bilatérale](#61-agenda-firebase--réservation-bilatérale-de-sessions)
  - [6.2 Planning (disponibilités mentor)](#62-planning-disponibilités-mentor)
  - [6.3 Demandes de mentorat](#63-demandes-de-mentorat)
- [7. Système de Pitch Entrepreneurial](#7-système-de-pitch-entrepreneurial)
  - [7.1 Dépôt de pitch — Formulaire 5 étapes](#71-dépôt-de-pitch--stepper-5-étapes-unifié-page_pitchdart)
  - [7.2 Fil des pitchs publics](#72-fil-des-pitchs-publics-page_pitches_publicsdart)
- [8. Dashboards par rôle](#8-dashboards-par-rôle)
  - [8.1 Dashboard Mentor](#81-dashboard-mentor-page_dashboard_mentordart)
  - [8.2 Dashboard Investisseur](#82-dashboard-investisseur-page_dashboard_investisseurdart)
- [9. Page Détail Mentor](#9-page-détail-mentor-page_detail_mentordart)
- [10. Partage sur Réseaux Sociaux](#10-partage-sur-réseaux-sociaux)
- [11. Paiement Mobile — Wave Premium](#11-paiement-mobile--wave-premium)
- [12. Déploiement](#12-déploiement)
- [Conclusion](#conclusion-du-livrable-5)

---

## Introduction

DIAPALER AFRICA implémente **toutes** les fonctionnalités avancées listées dans le sujet, plus plusieurs fonctionnalités bonus :

| Fonctionnalité avancée (sujet) | Implémentation DIAPALER AFRICA | Statut |
|---|---|---|
| Notifications | `NotificationService` (Firebase) + badge dynamique + centre + "Effacer tout" | ✅ |
| Recherche | Barre textuelle en temps réel (nom, secteur, ville) dans Matching + Pitchs Publiés | ✅ |
| Filtres | Matching : pills rôle + pills secteur (10) + dropdown ville + reset | ✅ |
| Filtres pitchs | Pitchs : barre recherche + pills secteur dynamiques + compteur + reset | ✅ (bonus) |
| Géolocalisation | GPS + bouton "Près de moi" + tri distance + puce km + `LocationService` auto-détection ville et localité/quartier (Nominatim OSM) dans la modification de profil | ✅ |
| Chatbot IA | DIALI (Llama 3.1 8B via Groq) + proxy Cloudflare + FAB pulsant | ✅ |
| Messagerie temps réel | Firebase WebSocket + badge `unreadMessagesCount` global | ✅ (bonus) |
| Système de Contacts | Onglet "Contacts" dans Messages — relations acceptées + searchable + badge rôle | ✅ (bonus) |
| Agenda | `AgendaController.bookBilateral()` + annulation bilatérale + bouton "Annuler" | ✅ (bonus) |
| Planning | Gestion disponibilités mentor via Firebase | ✅ (bonus) |
| Demandes mentorat | Envoi + accepter/refuser + notification croisée | ✅ (bonus) |
| Flux investisseur | "Proposer un investissement" + `MentorRequest` type `'investment'` + acceptation dans `RequestsPage` | ✅ (bonus) |
| Matching rôle-adaptatif | Titre + contenu adaptés selon rôle connecté (Mentor → Entrepreneurs, Investisseur → Entrepreneurs) | ✅ (bonus) |
| Compatibilité dynamique | Algorithme intérêts partagés — affiché ET trié de façon cohérente | ✅ (bonus) |
| **Navigation notifications** | Tap → onglet Messages / Agenda / `RequestsPage` selon le type | ✅ (bonus) |
| **Anti-doublon demandes** | `hasPendingRequest()` Firebase — bloque l'envoi si demande en attente | ✅ (bonus) |
| **Pitch (stepper 5 étapes)** | `PitchPage` — édition / création / publication unifiées, sauvegarde progressive par étape + publication directe sans stepper | ✅ (bonus) |
| **Fil de pitchs publics** | `PublicPitchesPage` → stream Firebase temps réel | ✅ (bonus) |
| **Dashboard Mentor** | `SliverAppBar` + stats + raccourcis | ✅ (bonus) |
| **Dashboard Investisseur** | Header + accès Pitchs + Matching "Entrepreneurs à financer" | ✅ (bonus) |
| **Détail mentor** | Réservation session + favori + bouton adapté rôle (mentorat/investissement) | ✅ (bonus) |
| **Avis et notation ⭐** | `page_avis.dart` — étoiles 1–5, moyenne live Firebase, accès restreint par relation acceptée | ✅ (bonus) |
| **Pitchs favoris 🔖** | `PitchFavoriteService` — bookmark investisseur, ValueNotifier temps réel, `page_mes_pitchs_favoris.dart` | ✅ (bonus) |

---

## 1. Système de Notifications

Le système de notifications est l'un des éléments qui rend l'application vraiment interactive. Chaque action importante — réception d'une demande de mentorat, confirmation d'une session, nouveau message — génère une notification visible depuis n'importe quel écran. Nous avons soigné les actions inline dans chaque notification : l'utilisateur peut accepter ou refuser une demande sans même quitter la page de notifications. Toute la logique est construite autour d'un `ValueNotifier` global alimenté par un stream Firebase en temps réel.

### 1.1 Modèle de données

```dart
// lib/services/service_notifications.dart
// Le type de notification est une chaîne de caractères libre
// (ex: 'message', 'request', 'session_booked', 'session_cancelled'…).
// Pas d'enum — permet d'ajouter de nouveaux types sans modifier le modèle.

class NotificationItem {
  final String   id;
  final String   title;
  final String   message;    // contenu de la notification
  final DateTime timestamp;  // horodatage de création
  final String   type;       // ex: 'message', 'investment_offer', 'session_request', 'session_booked'…
  bool           isRead;
  // Champs pour les actions inline (Accept/Decline dans NotificationsPage)
  // Non-nullables avec valeur par défaut '' — évite les null-checks partout
  final String requestId;    // ID du mentorRequest Firebase associé
  final String fromUserId;   // UID de l'expéditeur (pour ouvrir le chat après acceptation)
  final String fromName;     // Nom affiché dans la notification

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.requestId = '',
    this.fromUserId = '',
    this.fromName = '',
  });

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'message':     message,
    'timestamp':   timestamp.toIso8601String(),
    'type':        type,
    'isRead':      isRead,
    'requestId':   requestId,
    'fromUserId':  fromUserId,
    'fromName':    fromName,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id:          json['id']?.toString() ?? '',
        title:       json['title']?.toString() ?? '',
        message:     json['message']?.toString() ?? '',
        timestamp:   DateTime.tryParse(json['timestamp']?.toString() ?? '')
                     ?? DateTime.now(),
        type:        json['type']?.toString() ?? 'info',
        isRead:      json['isRead'] as bool? ?? false,
        requestId:   json['requestId']?.toString() ?? '',
        fromUserId:  json['fromUserId']?.toString() ?? '',
        fromName:    json['fromName']?.toString() ?? '',
      );
}
```

---

### 1.2 Service de notifications

Le `NotificationService` est le cœur du système. Il initialise une écoute Firebase sur le nœud `notifications/{userId}` dès la connexion de l'utilisateur, et maintient un `ValueNotifier` synchronisé avec les données du serveur. Deux méthodes distinctes permettent d'envoyer une notification à soi-même (`addNotification`) ou à un autre utilisateur (`notifyUser`), ce qui rend les notifications croisées possibles — par exemple quand un mentor confirme une session, l'entrepreneur est notifié automatiquement.

```dart
class NotificationService {
  static final _db = FirebaseDatabase.instance.ref();
  static String? _userId;
  static StreamSubscription? _subscription;

  // Notifier global — ValueListenableBuilder dans les dashboards et NotificationsPage
  static final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);

  /// Initialise l'écoute temps réel du nœud Firebase `notifications/$userId`.
  /// Annule l'ancien listener avant d'en créer un nouveau (évite les doublons entre sessions).
  static void init(String userId) {
    _subscription?.cancel();
    _userId = userId;
    _subscription = _db.child('notifications/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) { notifications.value = []; return; }
      try {
        final list = data.values
            .map<NotificationItem>(
                (v) => NotificationItem.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifications.value = list;
      } catch (_) { notifications.value = []; }
    }, onError: (_) => notifications.value = []);
  }

  /// Écrit une notification dans Firebase pour l'utilisateur courant.
  /// Le ValueNotifier est mis à jour automatiquement par le listener Firebase.
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String requestId = '',
    String fromUserId = '',
    String fromName = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NotificationItem(
      id: id, title: title, message: message,
      timestamp: DateTime.now(), type: type,
      requestId: requestId,
      fromUserId: fromUserId,
      fromName: fromName,
    );
    if (_userId != null) {
      await _db.child('notifications/$_userId/$id').set(item.toJson());
      // Le ValueNotifier est mis à jour par le listener Firebase en temps réel.
    } else {
      // Fallback mémoire si pas encore connecté.
      notifications.value = [item, ...notifications.value];
    }
  }

  /// Pousse une notification dans la boîte d'un AUTRE utilisateur.
  /// Utilisé pour les notifs croisées (ex: acceptation de demande de mentorat).
  static Future<void> notifyUser({
    required String uid,
    required String title,
    required String message,
    required String type,
    String requestId = '',
    String fromUserId = '',
    String fromName = '',
  }) async {
    if (uid.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NotificationItem(
      id: id, title: title, message: message,
      timestamp: DateTime.now(), type: type,
      requestId: requestId,
      fromUserId: fromUserId,
      fromName: fromName,
    );
    try {
      await _db.child('notifications/$uid/$id').set(item.toJson());
    } catch (_) {
      // Échec silencieux : la notif côté annulant a déjà été créée.
    }
  }

  /// Marque une notification comme lue (mise à jour Firebase).
  static Future<void> markAsRead(String id) async {
    if (_userId != null) {
      await _db.child('notifications/$_userId/$id').update({'isRead': true});
    }
  }

  /// Supprime toutes les notifications de l'utilisateur courant.
  static Future<void> clearAll() async {
    if (_userId != null) {
      await _db.child('notifications/$_userId').remove();
    }
    notifications.value = [];
  }

  /// Nombre de notifications non lues.
  static int get unreadCount =>
      notifications.value.where((n) => !n.isRead).length;

  /// Réinitialise le service à la déconnexion (évite la fuite de données entre sessions).
  static void reset() {
    _subscription?.cancel();
    _subscription = null;
    _userId = null;
    notifications.value = [];
  }
}
```

---

### 1.3 Badge de notifications dynamique

Le badge rouge apparaît sur **l'icône cloche** des dashboards et se met à jour sans setState :

```dart
// Dans les dashboards (SliverAppBar)
ValueListenableBuilder<List<NotificationItem>>(
  valueListenable: NotificationService.notifications,
  builder: (context, notifs, _) {
    final unread = notifs.where((n) => !n.isRead).length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.navyDeep,
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NotificationsPage())),
        ),
        // Badge rouge — visible seulement si > 0 notifications non lues
        if (unread > 0)
          Positioned(
            top: 6, right: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: AppColors.red, shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  },
),
```

> **📸 CAPTURE D'ÉCRAN — Badge rouge sur l'icône cloche (ex: 3 notifications non lues)**
> *(Insérer ici la capture d'écran)*

---

### 1.4 Centre de notifications (`page_notifications.dart`)

**Fonctionnalités complètes :**
- Liste toutes les notifications triées par date décroissante (Firebase)
- Icône et couleur distinctes selon le type (string) : `mentor_request` vert, `session_booked` bleu, `session_cancelled` rouge, `message` bleu, etc.
- Horodatage relatif ("Il y a 5m", "Il y a 2h"…) via `_formatTime()`
- Fond légèrement coloré pour les notifications non lues
- Point coloré (couleur du type) sur les non lues
- Tap → `NotificationService.markAsRead(id)` — met à jour Firebase
- Bouton **"Effacer tout"** → `NotificationService.clearAll()` — supprime le nœud Firebase
- État vide illustré si aucune notification

La page utilise un `ValueListenableBuilder` sur `NotificationService.notifications` et affiche soit un état vide illustré, soit une `ListView` de tuiles. Chaque tuile (`_NotificationTile`) déduit icône et couleur du champ `type` (String : `mentor_request`, `session_booked`, `session_cancelled`, `message`, `investment_offer`, `session_request`…). Tap → `markAsRead()` + navigation contextuelle, bouton "Effacer tout" → `clearAll()`.

**Actions inline Accept/Decline :** pour les types `investment_offer`, `session_request` **et `mentor_request`**, deux boutons "Accepter" / "Refuser" s'affichent directement dans la tuile — sans quitter la page. L'acceptation d'une demande de mentorat incrémente `mentorsActive` dans le profil, ouvre le chat avec l'expéditeur, et envoie une notification de confirmation. Le refus ouvre un `AlertDialog` pour saisir une raison optionnelle, puis appelle `InteractionsService.rejectRequest(requestId, reason: raison)` et notifie l'expéditeur du refus.

```dart
// Tuile — couleur et icône selon le type de notification
class _NotificationTile extends StatelessWidget {
  Color _getTypeColor() => switch (notification.type) {
    'mentor_request'          => AppColors.roleMentor,
    'mentor_request_accepted' => AppColors.green,
    'mentor_request_rejected' || 'session_cancelled' => AppColors.red,
    'session_booked' || 'message' => AppColors.blue,
    _ => AppColors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();
    return InkWell(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.surface : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(_getTypeIcon(), color: color),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(notification.message, maxLines: 2),
          Text(_formatTime(notification.timestamp)),
        ])),
      ]),
    ));
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Centre de notifications (plusieurs types de notifications)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Notification non lue (fond coloré + point coloré + bouton "Effacer tout")**
> *(Insérer ici la capture d'écran)*

---

## 2. Recherche et Filtres avancés

### 2.1 Matching — Filtres multicritères

La page Matching intègre un système de filtres multicritères : **barre de recherche textuelle** (temps réel sur nom/secteur/ville), **pills de rôle** (adaptées au rôle : Entrepreneur → `['Tous', 'Mentor', 'Investisseur']` ; Mentor et Investisseur → `['Entrepreneur']` uniquement), **pills de secteur** (10 secteurs sénégalais), **dropdown de ville**, et bouton **"Réinitialiser"** visible dès qu'un filtre est actif.

Tous les filtres convergent dans le getter `_filtered` qui combine les membres Firebase réels (priorité) et les 112 profils statiques :

```dart
// États des filtres
String _query = '', _role = 'Tous', _sector = 'Tous', _city = 'Toutes';
bool _nearMe = false;

// Getter principal — filtre + tri
List<Mentor> get _filtered {
  final all = [..._members, ...mentors]; // Membres Firebase + profils statiques
  final list = all.where((m) =>
    m.matches(_query) &&                   // nom, secteur, ville, tags
    (_role == 'Tous' || m.role == _role) &&
    (_sector == 'Tous' || m.sectors.any((s) => s.toLowerCase() == _sector.toLowerCase())) &&
    (_city == 'Toutes' || m.city == _city)
  ).toList();

  if (_nearMe && _userPosition != null) {
    list.sort((a, b) => (_distanceFor(a) ?? 9999).compareTo(_distanceFor(b) ?? 9999));
  } else {
    // Membres DIAPALER réels (uid non vide) en tête, puis par compatibilité DYNAMIQUE
    // _computeCompatibility() calcule le score basé sur les intérêts partagés —
    // même valeur que celle affichée sur la _CompatibilityPill (cohérence tri/affichage)
    list.sort((a, b) {
      if (b.uid.isNotEmpty != a.uid.isNotEmpty) {
        return b.uid.isNotEmpty ? 1 : -1;
      }
      return _computeCompatibility(b).compareTo(_computeCompatibility(a));
    });
  }
  return list;
}

// defaultRole = 'Entrepreneur' pour un Investisseur (son filtre par défaut), 'Tous' pour les autres
// Évite que "Réinitialiser" soit toujours visible pour un Investisseur
final myRole = UserProfileController.profile.value.role;
final defaultRole = myRole == 'Investisseur' ? 'Entrepreneur' : 'Tous';
bool get _hasFilter => _query.isNotEmpty || _sector != 'Tous' || _city != 'Toutes' || _role != defaultRole;
```

### 2.2 Pitchs Publiés — Filtres par secteur et recherche

La page Pitchs Publiés intègre également un système de filtres :
- **Barre de recherche** : filtre en temps réel sur titre, entrepreneur, secteur, description
- **Pills de secteur** : générées dynamiquement depuis les pitchs Firebase (pas de liste hardcodée)
- **Compteur** "X pitch(s)" mis à jour à chaque changement de filtre
- **Bouton "Réinitialiser"** visible si un filtre est actif

```dart
// États des filtres pitchs
String _query = '';
String _selectedSector = 'Tous';

// Getter principal
List<Map<String, dynamic>> get _filtered {
  return _pitches.where((p) {
    final matchQuery = _query.isEmpty ||
        p['title'].toString().toLowerCase().contains(_query.toLowerCase()) ||
        p['userName'].toString().toLowerCase().contains(_query.toLowerCase()) ||
        p['sector'].toString().toLowerCase().contains(_query.toLowerCase()) ||
        p['description'].toString().toLowerCase().contains(_query.toLowerCase());
    final matchSector = _selectedSector == 'Tous' ||
        p['sector'] == _selectedSector;
    return matchQuery && matchSector;
  }).toList();
}

// Secteurs extraits dynamiquement depuis les pitchs Firebase
Set<String> get _sectors => {
  'Tous',
  ..._pitches.map((p) => p['sector']?.toString() ?? '').where((s) => s.isNotEmpty),
};
```

> **📸 CAPTURE D'ÉCRAN — Matching : barre de recherche + pills rôle + pills secteur**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching : recherche "tech" active + compteur de résultats**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching : filtre "Mentor" + secteur "FinTech" actifs**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching : filtre ville actif (dropdown)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching : bouton "Réinitialiser" visible dans l'AppBar**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching : état vide (aucun résultat)**
> *(Insérer ici la capture d'écran)*

---

## 3. Géolocalisation GPS

La géolocalisation permet aux utilisateurs de trouver des mentors ou investisseurs proches géographiquement. Quand l'utilisateur appuie sur "Près de moi", l'application demande la permission d'accès à sa position, calcule la distance avec chaque profil membre en utilisant la formule Haversine, et trie les résultats du plus proche au plus loin. Cette fonctionnalité est particulièrement utile pour favoriser des rencontres en présentiel au Sénégal. Nous avons cartographié les coordonnées GPS de plus de 40 villes sénégalaises pour que le calcul fonctionne même avec les profils qui n'ont pas de coordonnées exactes.

### 3.1 Service de géolocalisation (`service_geolocation.dart`)

```dart
// lib/services/service_geolocation.dart
import 'package:geolocator/geolocator.dart';

class GeolocationService {
  /// Coordonnées GPS de toutes les villes du Sénégal (14 régions, 40+ villes)
  static const Map<String, List<double>> cityCoordinates = {
    'Dakar':       [14.6928, -17.4467],
    'Pikine':      [14.7500, -17.3833],
    'Thiès':       [14.7833, -16.9167],
    'Saint-Louis': [16.0333, -16.5000],
    'Kaolack':     [14.1500, -16.0667],
    'Ziguinchor':  [12.5667, -16.2667],
    'Touba':       [14.8500, -15.8833],
    // ... 33 autres villes sénégalaises
  };

  /// Distance en km entre la position utilisateur et une ville (formule Haversine)
  static double? distanceKmToCity(Position userPos, String city) {
    final coords = cityCoordinates[city];
    if (coords == null) return null;
    return Geolocator.distanceBetween(
      userPos.latitude, userPos.longitude,
      coords[0], coords[1],
    ) / 1000;  // Conversion mètres → km
  }

  /// Formate une distance km de façon lisible
  static String formatDistance(double km) {
    if (km < 1)  return '< 1 km';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }

  /// Demande la permission puis retourne la position GPS actuelle
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings(); // Invite l'utilisateur
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;  // Permission refusée
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,  // ~10 mètres
      );
    } catch (e) {
      return null;  // GPS non disponible (web, simulateur...)
    }
  }
}
```

**Permissions Android (`AndroidManifest.xml`) :**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

### 3.2 Bouton "Près de moi"

Un bouton dédié (sous la barre de recherche) active le tri par distance GPS avec animation et état visuel :

```dart
Position? _userPosition;
bool _nearMe = false;
bool _loadingLocation = false;

// Activation/désactivation du tri par distance
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

// Bouton animé — change de couleur et de texte selon l'état
GestureDetector(
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
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.near_me_rounded, size: 16,
                color: _nearMe ? Colors.white : AppColors.purple),
        const SizedBox(width: 7),
        Text(
          _nearMe ? 'Trié par distance ✓' : 'Près de moi',
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: _nearMe ? Colors.white : AppColors.purple,
          ),
        ),
      ],
    ),
  ),
),

// Calcul de la distance pour un profil
double? _distanceFor(Mentor m) {
  if (_userPosition == null) return null;
  return GeolocationService.distanceKmToCity(_userPosition!, m.city);
}
```

---

### 3.3 Affichage de la distance sur les cartes

```dart
// carte_mentor.dart — puce de distance en km (visible si position disponible)
if (distanceKm != null)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.green.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.green),
        const SizedBox(width: 3),
        Text(
          GeolocationService.formatDistance(distanceKm!),
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green,
          ),
        ),
      ],
    ),
  ),
```

> **📸 CAPTURE D'ÉCRAN — Bouton "Près de moi" (état inactif)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching avec distances en km sur chaque carte**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bouton "Trié par distance ✓" (état actif, violet)**
> *(Insérer ici la capture d'écran)*

---

### 3.4 Auto-détection ville dans la modification de profil (`LocationService`)

Au-delà du tri par proximité dans le Matching, la géolocalisation est également utilisée pour **pré-remplir automatiquement les champs localisation** lors de la modification du profil. L'utilisateur appuie sur un seul bouton et l'application détecte sa ville, son pays, et son quartier via le reverse geocoding Nominatim.

**Fichier :** `lib/services/service_geolocalisation.dart`

```dart
class LocationResult {
  final String city;
  final String country;
  final String locality; // quartier/suburb — vide si non détecté
  const LocationResult({
    required this.city,
    required this.country,
    this.locality = '',
  });
}

class LocationService {
  LocationService._();

  /// Détecte la ville de l'utilisateur via GPS + Nominatim reverse geocoding.
  static Future<LocationResult?> detectCity() async {
    // 1. Permission GPS
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // 2. Position GPS (précision moyenne, timeout 12s)
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 12),
    );

    // 3. Reverse geocoding Nominatim (OSM) — gratuit, sans clé API
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json&lat=${pos.latitude}&lon=${pos.longitude}&accept-language=fr',
    );
    final resp = await http
        .get(uri, headers: {'User-Agent': 'DiapalaAfrica/1.0 (sirimambodj@gmail.com)'})
        .timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final address = (data['address'] as Map?)?.cast<String, dynamic>() ?? {};

    // Extraire la ville depuis les champs possibles
    final rawCity = _firstNonEmpty([
      address['city'], address['town'], address['village'],
      address['municipality'], address['county'],
    ]);
    final rawCountry = address['country']?.toString() ?? '';
    // Extraire la localité fine (quartier, suburb, city_district…)
    final rawLocality = _firstNonEmpty([
      address['neighbourhood'], address['suburb'],
      address['quarter'], address['city_district'], address['residential'],
    ]);

    // Correspondance pays et ville supportés (pays.dart)
    final matchedCountry = _matchCountry(rawCountry);
    final matchedCity = _matchCity(rawCity, citiesOf(matchedCountry));

    return LocationResult(
      city: matchedCity,
      country: matchedCountry,
      locality: rawLocality,
    );
  }
}
```

**Intégration dans `page_modification_profil.dart` :**

```dart
Future<void> _autoDetectLocation() async {
  setState(() => _detectingLocation = true);
  try {
    final result = await LocationService.detectCity();
    if (!mounted || result == null) return;
    setState(() {
      _country = result.country;
      _city = result.city;
      // Pré-remplit le champ Adresse avec le quartier/suburb détecté
      if (result.locality.isNotEmpty) {
        _address.text = result.locality;
      }
    });
    // Snackbar 3 niveaux : "Sénégal · Dakar · Liberté 6"
    final localityPart =
        result.locality.isNotEmpty ? ' · ${result.locality}' : '';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Position détectée : ${result.country} · ${result.city}$localityPart'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
    ));
  } finally {
    if (mounted) setState(() => _detectingLocation = false);
  }
}
```

**Résultat :** Si l'utilisateur est à Liberté 6 (Dakar), le snackbar affiche "Position détectée : **Sénégal · Dakar · Liberté 6**" et le champ Adresse est pré-rempli avec "Liberté 6". Les dropdowns Pays et Ville sont automatiquement sélectionnés.

> **📸 CAPTURE D'ÉCRAN — Bouton "Détecter ma position" dans Modifier le profil**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Snackbar "Sénégal · Dakar · Liberté 6" après détection**
> *(Insérer ici la capture d'écran)*

---

## 4. Chatbot IA — DIALI

DIALI est l'assistant intelligent intégré à DIAPALER AFRICA. Il est alimenté par le modèle Llama 3.1-8b-instant de Groq, accessible via un proxy Cloudflare Worker qui protège la clé API côté serveur. DIALI peut répondre aux questions des entrepreneurs sur le financement, la création d'entreprise au Sénégal, et orienter vers les bonnes ressources comme la DER, le FJ ou la BNDE. Son nom vient du wolof "aller de l'avant", ce qui reflète bien son rôle d'encouragement et d'orientation dans l'application.

### 4.1 Présentation

**DIALI** (wolof : "aller de l'avant") est l'assistant IA de DIAPALER AFRICA. Propulsé par **Llama 3.1 8B** de Meta via **Groq**, il accompagne les entrepreneurs, mentors et investisseurs avec des conseils contextualisés à l'écosystème sénégalais.

| Caractéristique | Détail |
|---|---|
| API | Groq Chat Completions (via proxy Cloudflare Worker) |
| Modèle | llama-3.1-8b-instant (rapide + haute qualité) |
| Langue | Français (compréhension du wolof) |
| Contexte système | DER/FJ, BNDE, FONGIP, FONSIS, secteurs porteurs |
| Accès | FAB pulsant amber visible depuis tous les onglets |

> **Note — parser de réponse robuste :** Le code Flutter (`service_chatbot.dart`) envoie les requêtes au proxy Cloudflare Worker avec le champ `system` au premier niveau du corps JSON. Le **parser de réponse** détecte automatiquement le format retourné : d'abord **Groq/OpenAI** (`choices[0].message.content`), puis **Anthropic** (`content[0].text`) en fallback. Si aucun des deux formats n'est reconnu, une `Exception('Format de réponse inattendu du serveur.')` est levée. Cette détection en cascade rend le client résilient à tout changement de format côté proxy. Aucune clé API n'est exposée côté client.

---

### 4.2 FAB chatbot avec animation "pulse" (`coquille_principale.dart`)

Le bouton du chatbot est visible sur **tous les écrans** de l'app via un `FloatingActionButton` dans le `Scaffold` principal. Un anneau animé attire l'attention :

```dart
// Animation pulse : anneau qui s'agrandit de 1x à 2.2x tout en s'estompant
class _PulseFabState extends State<_PulseFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();  // Boucle infinie

    _scale   = Tween<double>(begin: 1.0, end: 2.2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.55, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Anneau animé (derrière le FAB)
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: _opacity.value),
              ),
            ),
          ),
        ),
        // ── Bouton principal
        FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.navyDeep,
          elevation: 4,
          tooltip: 'DIALI IA — Assistant entrepreneurial',
          child: const Icon(Icons.psychology_rounded, size: 26),
        ),
      ],
    );
  }
}
```

**Positionnement dans `coquille_principale.dart` :**
```dart
// Scaffold principal — FAB visible sur tous les onglets
floatingActionButton: _PulseFab(
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ChatbotPage()),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
```

> **📸 CAPTURE D'ÉCRAN — FAB chatbot DIALI (bouton doré avec anneau pulsant amber)**
> *(Insérer ici la capture d'écran)*

---

### 4.3 Interface du chatbot (`page_chatbot.dart`)

**Fonctionnalités :**
- En-tête : avatar IA amber + "DIALI IA" + "Assistant entrepreneurial"
- Message de bienvenue **commun à tous les rôles** (`static const _welcome`) — même accueil pour Entrepreneur, Mentor et Investisseur
- Bulles de messages : utilisateur → droite (navy) / DIALI → gauche (blanc)
- **Indicateur de frappe animé** (3 points) pendant la génération
- Scroll automatique vers le dernier message
- Champ de saisie multi-lignes + bouton envoi (désactivé pendant la génération)
- Historique conservé pendant toute la session

```dart
class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final _messages = <ChatbotMessage>[];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = false;
  late AnimationController _dotCtrl;

  // Message de bienvenue — identique pour tous les rôles
  static const _welcome =
      'Salut ! Je suis **DIALI**, ton assistant entrepreneurial IA de DIAPALER AFRICA. 🇸🇳\n\n'
      'Je peux t\'aider avec :\n'
      '• 💼 Ta stratégie business\n'
      '• 💰 DER/FJ, PAVIE 2, Be Yes (financement)\n'
      '• 🎯 La préparation de ton pitch\n'
      '• 🤝 Trouver mentors et investisseurs\n\n'
      '**Pose-moi ta question — *Jërejëf* !**';

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  Future<void> _send() async {
    final userText = _ctrl.text.trim();
    if (userText.isEmpty || _loading) return;
    final profile = UserProfileController.profile.value;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatbotMessage(role: 'user', content: userText));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final reply = await ChatbotService.sendMessage(
        messages: _messages,
        userName: profile.firstName,
        userRole: profile.role,
        userSector: profile.sector,
        userCity: profile.city,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatbotMessage(role: 'assistant', content: reply));
      });
      _scrollToBottom();
    } on Exception catch (e) {
      if (!mounted) return;
      String raw = e.toString().replaceFirst('Exception: ', '');
      final String msg;
      if (raw.toLowerCase().contains('credit') || raw.toLowerCase().contains('balance')) {
        msg = 'Service DIALI temporairement indisponible — crédits IA épuisés. Réessaie dans quelques instants.';
      } else if (raw.toLowerCase().contains('timeout') || raw.toLowerCase().contains('network')) {
        msg = 'Connexion internet instable. Vérifie ta connexion et réessaie.';
      } else {
        msg = 'DIALI rencontre une difficulté technique. Réessaie dans quelques instants.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _messages.removeLast());
      _ctrl.text = userText;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        actions: [
          // Bouton partage — visible si au moins un message IA dans l'historique
          if (_messages.any((m) => m.role == 'assistant'))
            IconButton(
              onPressed: () {
                final last = _messages.lastWhere((m) => m.role == 'assistant');
                final name = UserProfileController.profile.value.firstName;
                ShareService.shareDialiAdvice(advice: last.content, userName: name);
              },
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              tooltip: 'Partager ce conseil',
            ),
        ],
        title: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.psychology_rounded, color: AppColors.navyDeep, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIALI IA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 0.3)),
                Text('Assistant entrepreneurial DIAPALER',
                    style: TextStyle(fontSize: 10, color: Colors.white60,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Liste des messages (ListView + spread, message de bienvenue en premier)
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              children: [
                _AiMessage(
                  text: _welcome,
                  onShare: () => ShareService.shareDialiAdvice(
                    advice: _welcome,
                    userName: UserProfileController.profile.value.firstName,
                  ),
                ),
                ..._messages.map((m) => m.role == 'user'
                    ? _UserMessage(text: m.content)
                    : _AiMessage(
                        text: m.content,
                        onShare: () => ShareService.shareDialiAdvice(
                          advice: m.content,
                          userName: UserProfileController.profile.value.firstName,
                        ),
                      )),
                if (_loading) _TypingIndicator(controller: _dotCtrl),
              ],
            ),
          ),

          // ── Barre de saisie (widget dédié _InputBar)
          _InputBar(
            controller: _ctrl,
            loading: _loading,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA (message de bienvenue personnalisé)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA (conversation active)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Indicateur de frappe "..." pendant la génération**
> *(Insérer ici la capture d'écran)*

---

## 5. Messagerie temps réel

La messagerie est la fonctionnalité qui permet aux membres de DIAPALER AFRICA de communiquer directement après qu'une relation ait été établie. Elle repose entièrement sur Firebase Realtime Database en mode WebSocket, ce qui garantit la livraison instantanée des messages sans polling. Nous avons choisi d'implémenter un système de badge global via `ValueNotifier` pour que le nombre de messages non lus soit visible depuis n'importe quel onglet de l'application, même quand l'utilisateur n'est pas sur la page de messagerie.

### 5.1 Badge de messages non lus (ValueNotifier global)

Le badge sur l'onglet Messages se met à jour en temps réel grâce à un `ValueNotifier<int>` global dans `service_navigation.dart` :

```dart
// lib/services/service_navigation.dart
import 'package:flutter/foundation.dart';

/// Nombre total de messages non lus — mis à jour par MessagesPage dès que
/// le stream Firebase émet de nouvelles données, même si l'onglet est inactif.
final ValueNotifier<int> unreadMessagesCount = ValueNotifier<int>(0);

/// Index de l'onglet actif (0=Accueil, 1=Matching, 2=Messages, 3=Agenda, 4=Profil)
final ValueNotifier<int> appTabIndex = ValueNotifier<int>(0);
```

**Mise à jour dans `page_messages.dart` :**
```dart
// Le stream Firebase met à jour le compteur global dès qu'il y a un changement
@override
void initState() {
  super.initState();
  _conversationsStream = InteractionsService.getConversations(currentUid);
  _conversationsStream.listen((conversations) {
    final total = conversations.fold<int>(
        0, (sum, c) => sum + c.unreadCount);
    // Mise à jour du ValueNotifier global (reconstruit la NavBar)
    unreadMessagesCount.value = total;
  });
}
```

**Affichage dans la barre de navigation (`coquille_principale.dart`) :**
```dart
// Badge sur l'onglet Messages
ValueListenableBuilder<int>(
  valueListenable: unreadMessagesCount,
  builder: (_, count, __) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.chat_bubble_outline_rounded),
        if (count > 0)
          Positioned(
            top: -4, right: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.red, shape: BoxShape.circle,
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(fontSize: 8, color: Colors.white,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  },
),
```

---

### 5.2 Liste des conversations

La liste des conversations affiche toutes les discussions actives de l'utilisateur, triées par date du dernier message. Chaque tuile montre le nom du contact, l'aperçu du dernier message, et le nombre de messages non lus en badge rouge. La liste se met à jour automatiquement grâce au `StreamBuilder` connecté en temps réel à Firebase.

```dart
// page_messages.dart — StreamBuilder sur conversations Firebase
StreamBuilder<List<Conversation>>(
  stream: InteractionsService.getConversations(currentUid),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final conversations = snapshot.data!;
    if (conversations.isEmpty) {
      return const _EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Aucune conversation',
        hint: 'Contacte un mentor ou un investisseur depuis le Matching.',
      );
    }
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _ConversationTile(
        conversation: conversations[i],
        currentUid: currentUid,
      ),
    );
  },
)
```

---

### 5.3 Chat individuel

Le chat individuel fonctionne en WebSocket pur : chaque message envoyé est écrit dans Firebase et reçu instantanément par l'autre utilisateur sans délai visible. Les bulles sont alignées à droite pour l'utilisateur connecté et à gauche pour son interlocuteur. Le scroll automatique vers le bas garantit que le dernier message est toujours visible à l'arrivée d'un nouveau message.

```dart
// page_chat.dart — WebSocket Firebase en temps réel
StreamBuilder<List<ChatMessage>>(
  stream: InteractionsService.getMessages(conversationId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final messages = snapshot.data!;
    return ListView.builder(
      reverse: false,
      controller: _scrollCtrl,
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg     = messages[i];
        final isMe    = msg.senderId == currentUid;
        return _MessageBubble(message: msg, isMe: isMe);
      },
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Badge rouge sur l'onglet Messages (NavBar)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Messagerie : liste des conversations**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Chat individuel (messages en temps réel)**
> *(Insérer ici la capture d'écran)*

---

## 6. Fonctionnalités supplémentaires bonus

Ces fonctionnalités ont été développées en dehors du cahier des charges initial pour enrichir l'expérience utilisateur. Elles couvrent la gestion complète du cycle de vie d'une relation de mentorat : de la prise de contact à la réservation de sessions, en passant par la gestion des disponibilités du mentor et l'envoi de demandes formelles. Chacune de ces fonctionnalités est synchronisée avec Firebase en temps réel.

### 6.1 Agenda Firebase — Réservation bilatérale de sessions

L'agenda utilise `AgendaController` avec `ValueNotifier<List<BookedSession>>`. La réservation est **bilatérale** : la session s'écrit dans le calendrier des **deux parties** simultanément.

**Modèle `BookedSession` :**
```dart
// lib/services/service_agenda.dart
class BookedSession {
  final String id;
  final String mentorName;
  final String mentorInitials;
  final DateTime scheduledAt;
  /// UID Firebase de l'autre partie (mentor/investisseur ou demandeur).
  /// Reste vide pour les profils démo (liste statique).
  final String otherUid;

  const BookedSession({
    required this.id,
    required this.mentorName,
    required this.mentorInitials,
    required this.scheduledAt,
    this.otherUid = '',
  });

  static const _weekdays = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];
  static const _months = [
    'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUIN',
    'JUIL', 'AOÛT', 'SEP', 'OCT', 'NOV', 'DÉC',
  ];

  String get weekday => _weekdays[scheduledAt.weekday - 1];
  String get day     => scheduledAt.day.toString().padLeft(2, '0');
  String get month   => _months[scheduledAt.month - 1];
  String get timeRange {
    final h = scheduledAt.hour.toString().padLeft(2, '0');
    final hEnd = (scheduledAt.hour + 1).toString().padLeft(2, '0');
    return '$h:00 – $hEnd:00';
  }
}
```

**Contrôleur `AgendaController` :**
```dart
class AgendaController {
  AgendaController._();

  static final _db = FirebaseDatabase.instance.ref();
  static final sessions        = ValueNotifier<List<BookedSession>>([]);
  /// Demandes de session (pending/accepted/cancelled) pour l'utilisateur courant.
  static final sessionRequests = ValueNotifier<List<MentorRequest>>([]);

  static StreamSubscription? _subscription;
  static StreamSubscription? _sessionSubscription;

  /// Écoute Firebase en temps réel (WebSocket) + demandes de session.
  static Future<void> load(String userId) async {
    // Annule l'ancien listener avant d'en créer un nouveau (évite les doublons entre sessions).
    await _subscription?.cancel();
    _listenSessionRequests(userId);
    _subscription = _db.child('bookedSessions/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) { sessions.value = []; return; }
      try {
        final list = data.values
            .map<BookedSession>((v) =>
                BookedSession.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        sessions.value = list;
      } catch (_) {
        sessions.value = [];
      }
    }, onError: (_) => sessions.value = []);
  }

  /// Écriture bilatérale : agenda demandeur + agenda mentor/investisseur.
  static Future<void> bookBilateral({
    required String requesterUid,
    required String requesterName,
    required String requesterInitials,
    required String otherUid,
    required String otherName,
    required String otherInitials,
    required DateTime scheduledAt,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    // Côté demandeur
    await _db.child('bookedSessions/$requesterUid/$id').set(
      BookedSession(id: id, mentorName: otherName,
          mentorInitials: otherInitials, scheduledAt: scheduledAt,
          otherUid: otherUid).toJson(),
    );
    if (otherUid.isEmpty) return; // Mentor statique → pas de miroir
    // Côté mentor/investisseur
    await _db.child('bookedSessions/$otherUid/$id').set(
      BookedSession(id: id, mentorName: requesterName,
          mentorInitials: requesterInitials, scheduledAt: scheduledAt,
          otherUid: requesterUid).toJson(),
    );
    // Notification au mentor/investisseur de la nouvelle réservation.
    await NotificationService.notifyUser(
      uid: otherUid,
      title: 'Nouveau rendez-vous',
      message:
          '$requesterName a réservé une session avec toi le ${_formatDate(scheduledAt)}.',
      type: 'session_booked',
    );
  }

  /// Annulation bilatérale + notifications croisées (annulant + autre partie).
  static Future<void> cancel({
    required String userId,
    required String userName,
    required BookedSession session,
    required String reason,
  }) async {
    // Suppression côté annulant.
    await _db.child('bookedSessions/$userId/${session.id}').remove();
    // Suppression côté autre partie si elle a un compte.
    if (session.otherUid.isNotEmpty) {
      await _db.child('bookedSessions/${session.otherUid}/${session.id}').remove();
    }
    // Notif côté annulant : récap de son action.
    await NotificationService.addNotification(
      title: 'Rendez-vous annulé',
      message: 'Session avec ${session.mentorName} annulée — motif : $reason',
      type: 'session_cancelled',
    );
    // Notif croisée : avertit l'autre partie s'il a un compte (UID connu).
    // notifyUser() est no-op silencieux si otherUid est vide.
    await NotificationService.notifyUser(
      uid: session.otherUid,
      title: 'Rendez-vous annulé',
      message: '$userName a annulé votre session — motif : $reason',
      type: 'session_cancelled',
    );
  }
}
```

**Page `page_agenda.dart` avec `ValueListenableBuilder` :**
```dart
class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserProfileController.profile.value.role;

    // Textes adaptés selon le rôle (switch, pas ternaire)
    final String agendaTitle;
    final String summarySubtitle;
    final String emptyUpcoming;
    switch (role) {
      case 'Mentor':
        agendaTitle    = 'Mon agenda';
        summarySubtitle = 'Tes sessions de mentorat avec tes mentorés.';
        emptyUpcoming  = 'Aucune session planifiée. Définis tes disponibilités dans "Mon planning".';
        break;
      case 'Investisseur':
        agendaTitle    = 'Mes rendez-vous';
        summarySubtitle = 'Tes rendez-vous avec les entrepreneurs.';
        emptyUpcoming  = 'Aucun rendez-vous planifié. Explore les pitchs pour contacter des entrepreneurs.';
        break;
      default:
        agendaTitle    = 'Mes sessions';
        summarySubtitle = 'Tes sessions de mentorat planifiées.';
        emptyUpcoming  = 'Aucune session planifiée. Réserve une session depuis le profil d\'un mentor.';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(agendaTitle),
        actions: [
          // Bouton Planning uniquement pour les Mentors
          if (role == 'Mentor')
            IconButton(
              tooltip: 'Mon planning',
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SchedulePage())),
            ),
        ],
      ),
      body: ValueListenableBuilder<List<BookedSession>>(
        valueListenable: AgendaController.sessions,
        builder: (context, bookedSessions, _) =>
            ValueListenableBuilder<List<MentorRequest>>(
          valueListenable: AgendaController.sessionRequests,
          builder: (context, sessionReqs, _) {
            // Filtrage par statut — la date est stockée dans MentorRequest, pas BookedSession
            final today = DateTime.now();
            final todayStr =
                '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

            final pending  = sessionReqs.where((r) => r.status == RequestStatus.pending).toList();
            final accepted = sessionReqs.where((r) => r.status == RequestStatus.accepted).toList();
            final upcoming = accepted
                .where((r) => (r.proposedDate ?? '').compareTo(todayStr) >= 0)
                .toList();
            // upcomingCount = sessions bilatérales réservées + demandes acceptées à venir
            final upcomingCount = bookedSessions.length + upcoming.length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
              children: [
                _SummaryCard(
                    upcomingCount: upcomingCount,
                    pendingCount: pending.length,
                    subtitle: summarySubtitle),
                if (pending.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('En attente'),
                  const SizedBox(height: 10),
                  for (final r in pending) ...[
                    _PendingSessionCard(request: r),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 20),
                const _SectionLabel('À venir'),
                const SizedBox(height: 10),
                if (upcomingCount == 0)
                  _EmptyHint(emptyUpcoming)
                else ...[
                  // Demandes acceptées → _AcceptedSessionCard
                  for (final r in upcoming) ...[
                    _AcceptedSessionCard(request: r),
                    const SizedBox(height: 10),
                  ],
                  // Sessions bilatérales Firebase → _BookedSessionCard
                  for (final s in bookedSessions) ...[
                    _BookedSessionCard(session: s),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Agenda : sessions à venir (date + heure + bouton "Annuler le rendez-vous")**
> *(Insérer ici la capture d'écran)*

---

### 6.2 Planning (disponibilités mentor)

La page Planning est accessible uniquement aux mentors depuis leur agenda. Elle leur permet de définir les créneaux horaires où ils sont disponibles pour des sessions. Ces créneaux sont ensuite visibles sur la page de détail du mentor, et c'est à partir de cette liste que l'entrepreneur choisit son créneau lors de la réservation. Toute modification se propage en temps réel grâce au stream Firebase.

```dart
// page_planning.dart — Gestion des créneaux disponibles
StreamBuilder<Availability?>(
  stream: InteractionsService.getAvailability(currentUid),
  builder: (context, snapshot) {
    final availability = snapshot.data;
    // Affichage + modification des créneaux par jour via _DayScheduleCard
    return ListView(
      children: DayOfWeek.values.map((day) =>
        _DayScheduleCard(
          day: day,
          slots: availability?.slots[day] ?? [],
          onChanged: (updated) => _updateDay(day, updated),
        ),
      ).toList(),
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Planning du mentor : créneaux disponibles**
> *(Insérer ici la capture d'écran)*

---

### 6.3 Demandes de mentorat

Le système de demandes de mentorat gère tout le processus de mise en relation formelle. Un entrepreneur envoie une demande avec un message personnalisé, le mentor la reçoit dans sa liste de demandes et peut accepter ou refuser avec une raison optionnelle. Nous avons implémenté un mécanisme anti-doublon côté Firebase pour éviter qu'un utilisateur envoie plusieurs demandes au même profil tant qu'une est encore en attente. Une notification croisée est envoyée aux deux parties à chaque changement de statut.

```dart
// page_send_request.dart — Envoi d'une demande avec vérification anti-doublon
Future<void> _sendRequest() async {
  // ── Anti-doublon : bloque si une demande est déjà en attente
  final alreadyPending = await InteractionsService.hasPendingRequest(
    fromUserId: currentUid,
    toUserId: mentor.uid,
  );
  if (alreadyPending) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tu as déjà une demande en attente avec ce profil.'),
        backgroundColor: AppColors.amber,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  await InteractionsService.sendMentorRequest(
    fromUserId: currentUid,
    toUserId: mentor.uid,
    fromName: UserProfileController.profile.value.fullName,
    toName: mentor.name,
    message: _message.text.trim(),
  );
  await NotificationService.addNotification(
    title: 'Demande envoyée',
    message: 'Ta demande a été envoyée à ${mentor.name}.',
    type: 'request',
  );
}

// page_requests.dart — Liste des demandes reçues (Mentor)
StreamBuilder<List<MentorRequest>>(
  stream: InteractionsService.getReceivedRequests(currentUid),
  builder: (context, snapshot) {
    final requests = snapshot.data ?? [];
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (_, i) => _RequestCard(
        request: requests[i],
        onAccept: () => InteractionsService.acceptRequest(requests[i].id),
        // Le paramètre reason est optionnel — un dialog est affiché pour saisir la raison
        onReject: (String reason) => InteractionsService.rejectRequest(requests[i].id, reason: reason),
      ),
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Envoi d'une demande de mentorat**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Demandes reçues (Mentor) avec boutons Accepter/Refuser**
> *(Insérer ici la capture d'écran)*

---

## 7. Système de Pitch Entrepreneurial

Le système de pitch est la fonctionnalité centrale pour les entrepreneurs de DIAPALER AFRICA. Il leur permet de présenter leur projet de façon structurée, de le soumettre à l'attention des mentors et des investisseurs, et de le partager sur les réseaux sociaux. Nous avons conçu un parcours en deux temps : d'abord le dépôt du pitch via un formulaire guidé, puis la publication automatique dans un fil public visible par tous les membres de la plateforme.

### 7.1 Dépôt de pitch — Stepper 5 étapes unifié (`page_pitch.dart`)

`PitchPage` est la page unifiée de création, d'édition et de publication d'un pitch. Elle gère le **cycle de vie complet** du projet entrepreneur : démarrage depuis zéro, reprise à l'étape sauvegardée, complétion progressive, et publication publique.

**5 étapes du stepper :**
- **Étape 1 — Informations** : Titre (min 3 chars, obligatoire) + elevator pitch (optionnel)
- **Étape 2 — Détails** : Secteur dropdown (obligatoire) + description détaillée (min 20 chars, obligatoire)
- **Étape 3 — Financement** : Montant FCFA (optionnel) + carte explicative "Qui verra ton pitch ?"
- **Étape 4 — Documents** : Business Plan PDF (obligatoire) + vidéo de présentation (obligatoire) + deck (optionnel) — upload Cloudinary
- **Étape 5 — Récapitulatif** : Résumé complet + bouton **"PUBLIER MON PITCH"**

**Fonctionnalités clés :**
- **Validation par étape** : bouton CONTINUER désactivé + message d'aide si champ invalide
- **Navigation arrière** : bouton **"← Précédent"** affiché à partir de l'étape 2 (à gauche de CONTINUER) — permet de revenir à n'importe quelle étape précédente pour modifier des champs déjà remplis
- **Sauvegarde progressive** : à chaque avancement d'étape, le projet est sauvegardé localement + Firebase avec le `step` mis à jour
- **Reprise** : si `existingProject` est fourni, les champs sont pré-remplis et le stepper démarre à `existingProject.step - 1`
- **Publication séparée** : la publication dans `pitches/` (nœud global) n'a lieu qu'à l'étape 5 — les étapes 1–4 ne font que sauvegarder le brouillon
- **Publication directe sans stepper** : `_directPublish()` dans `page_accueil.dart` publie un projet existant sans repasser par le stepper

```dart
// Validations par étape — CONTINUER désactivé si non valide
bool get _step0Valid => _title.text.trim().length >= 3;
bool get _step1Valid =>
    _sector != null && _detailDescription.text.trim().length >= 20;
bool get _step2Valid => true;                          // montant optionnel
bool get _step3Valid =>
    _businessPlanUrl != null && _videoUrl != null;    // docs obligatoires
bool get _step4Valid => true;                          // récap toujours valide

// Sauvegarde à chaque avancement (étapes 1–4)
void _saveProgress() {
  final project = _buildProject();
  if (_isNew) {
    final added = UserProfileController.addProject(project);
    if (added) _isNew = false;
  } else {
    UserProfileController.updateProject(project);
  }
}

Future<void> _next() async {
  if (!_currentStepValid) return;
  if (_step < _total - 1) {
    _saveProgress();          // sauvegarde locale + Firebase
    setState(() => _step++);
    return;
  }
  _publish();                 // étape 5 uniquement : publication Firebase pitches/
}
```

> **📸 CAPTURE D'ÉCRAN — Étape 1 du formulaire Pitch (titre + bouton désactivé sans texte)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Étape 4 (upload Business Plan PDF + vidéo obligatoires)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Étape 5 (récapitulatif + bouton PUBLIER MON PITCH)**
> *(Insérer ici la capture d'écran)*

---

### 7.2 Fil des pitchs publics (`page_pitches_publics.dart`)

Le fil des pitchs est la vitrine des projets entrepreneuriaux sur DIAPALER AFRICA. Les mentors et investisseurs y accèdent depuis leur dashboard et voient tous les pitchs en **temps réel** grâce à `DatabaseService.getPitches()` (stream Firebase WebSocket).

**Fonctionnalités complètes de `page_pitches_publics.dart` :**
- StreamBuilder Firebase — tri **premium en tête** puis par date décroissante — les pitchs d'entrepreneurs Premium apparaissent en premier
- Badge ⭐ **Premium** sur les cartes des entrepreneurs abonnés (chip amber doré à côté du nom)
- Barre de recherche textuelle : filtre sur titre, entrepreneur, secteur, description (insensible à la casse)
- Pills de secteur générées dynamiquement depuis les pitchs Firebase
- Compteur "X pitch(s)" et bouton "Réinitialiser" si filtre actif
- Chaque carte : avatar, nom entrepreneur, **badge ⭐ Premium si abonné**, secteur (chip amber), titre, description (3 lignes max), montant FCFA
- **Tap sur une carte → `PitchDetailSheet`** (classe publique) : bottom sheet `DraggableScrollableSheet` avec tous les détails du pitch + bouton "Contacter" (non-Investisseurs) + bouton "💰 Proposer un investissement" (Investisseurs uniquement)
- **Gating** : "Contacter" vérifie `_checkRequestStatus()` — chat autorisé seulement si une demande acceptée existe entre les deux utilisateurs
- **Bouton "💰 Proposer un investissement"** : visible uniquement pour les Investisseurs → crée un `MentorRequest` de type `'investment'` dans Firebase + notification automatique à l'entrepreneur
- Bouton "Partager" (icône) sur chaque carte → `ShareService.sharePitch(...)`

```dart
// Filtre insensible à la casse — correction d'un bug de filtrage
final matchSector = _selectedSector == 'Tous' ||
    p['sector'].toString().toLowerCase() == _selectedSector.toLowerCase();

// ID de conversation généré avec les UIDs Firebase (jamais les emails)
final convId = InteractionsService.generateConversationId(
  AuthService.currentUid ?? '',  // UID Firebase
  pitch['userId'] ?? '',          // UID Firebase de l'entrepreneur
);
```

> **📸 CAPTURE D'ÉCRAN — Fil des pitchs publics (liste temps réel)**
> *(Insérer ici la capture d'écran)*

---

## 8. Dashboards par rôle

Chaque rôle dans DIAPALER AFRICA dispose d'un dashboard personnalisé qui s'affiche comme écran d'accueil. L'idée est que dès la connexion, chaque utilisateur voit une interface adaptée à ses besoins spécifiques : le mentor voit ses statistiques et demandes en attente, l'investisseur voit les opportunités et ses secteurs d'intérêt. Ces dashboards sont construits avec une `SliverAppBar` pour avoir un effet de scroll élégant, et sont connectés en temps réel à Firebase via `ValueListenableBuilder`.

### 8.1 Dashboard Mentor (`page_dashboard_mentor.dart`)

`CustomScrollView` + `SliverAppBar` épinglée. Contient : header avec avatar vert + badge notifications, grille de **4 statistiques** (Mentorés, Sessions, Années expé., Note moy.), domaines d'expertise (chips), bio, et boutons d'accès rapide. Le tout est enveloppé dans un `ValueListenableBuilder<UserProfile>` pour rester synchronisé. Note : le badge notification affiche `'$unread'` sans cap (pas de `9+`).

**Accès rapides (boutons OutlinedButton)** : Demandes, Mon Planning, Voir les pitchs publiés. Messages et Agenda sont accessibles via les onglets de la barre de navigation principale — les boutons doublons ont été supprimés.

```dart
CustomScrollView(slivers: [
  SliverAppBar(pinned: true, title: Row(children: [
    Avatar(initials: profile.initials, background: AppColors.roleMentor),
    Text('Bienvenue ${profile.firstName} 👋'),
    _NotificationBadge(), // ValueListenableBuilder sur NotificationService
  ])),
  SliverPadding(sliver: SliverList(delegate: SliverChildListDelegate([
    _StatsGrid(profile: profile),
    // Domaines d'expertise (chips vert clair)
    // Bio complète
    Row(children: [
      OutlinedButton.icon(label: Text('Demandes'),    onPressed: () => push(RequestsPage())),
      OutlinedButton.icon(label: Text('Mon Planning'), onPressed: () => push(SchedulePage())),
    ]),
    OutlinedButton.icon(label: Text('Voir les pitchs publiés'), onPressed: () => push(PublicPitchesPage())),
  ]))),
])
```

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor (header + stats + actions rapides)**
> *(Insérer ici la capture d'écran)*

---

### 8.2 Dashboard Investisseur (`page_dashboard_investisseur.dart`)

Même architecture que le Dashboard Mentor (SliverAppBar + ValueListenableBuilder), mais orienté découverte de projets. Contient : header avec avatar bleu + badge notifications, 3 stats (**Entrepreneurs** / Pitchs vus / Favoris), ticket d'investissement (si renseigné), secteurs d'intérêt (chips), bio, et deux boutons d'action principaux. Messages et Agenda sont accessibles via les onglets de la barre de navigation principale — les boutons doublons ont été supprimés. Note : le badge notification affiche `'$unread'` sans cap.

Dans l'onglet Matching, l'Investisseur voit les **Entrepreneurs à financer** (titre adapté) — le contenu du matching est filtré pour afficher les Entrepreneurs uniquement (pas les Mentors/Investisseurs).

```dart
CustomScrollView(slivers: [
  SliverAppBar(pinned: true, title: Row(children: [
    Avatar(initials: profile.initials, background: AppColors.blue),
    Text('Bienvenue ${profile.firstName} 👋'),
    _NotificationBadge(),
  ])),
  SliverPadding(sliver: SliverList(delegate: SliverChildListDelegate([
    _StatsGrid(profile: profile),
    // Ticket d'investissement (visible si profile.investmentRange.isNotEmpty)
    // Secteurs d'intérêt (chips bleu clair)
    // Bio complète
    ElevatedButton.icon(label: Text('Explorer'), onPressed: () => push(MatchingPage())),
    OutlinedButton.icon(label: Text('Pitchs reçus'),           onPressed: () => push(PublicPitchesPage())),
  ]))),
])
```

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur (header + accès rapide Pitchs)**
> *(Insérer ici la capture d'écran)*

---

## 9. Page Détail Mentor (`page_detail_mentor.dart`)

La page affiche le profil complet (bio, secteurs, distance GPS) et propose les actions selon la relation entre les deux utilisateurs.

**Section "Disponibilités" — `_AvailabilityPreview` :**
- Profils démo (uid vide) → 5 créneaux illustratifs avec badge "Exemple" (point gris)
- Membres Firebase → vraies disponibilités lues via `InteractionsService.getAvailability(mentor.uid)` (StreamBuilder)
- Si aucun créneau configuré → message "Disponibilités non encore configurées."

**Bouton principal adapté selon le rôle du profil :**
- Mentor → `_BookingSheet` (calendrier Firebase réel) : `DraggableScrollableSheet` avec StreamBuilder sur les disponibilités du mentor, sélection de créneau, puis `AgendaController.bookBilateral()` (écriture dans les deux agendas)
- Investisseur → "Proposer un investissement" (type `'investment'`)

**Bouton "Message" :**
L'ID de conversation est généré avec `AuthService.currentUid` (UID Firebase) — jamais l'email — pour garantir la cohérence avec `page_notifications.dart` qui utilise également les UIDs.

```dart
// Conversation ID avec UID Firebase (fallback email)
final myUid = AuthService.currentUid ??
    UserProfileController.profile.value.email;
final convId = InteractionsService.generateConversationId(
  myUid,
  mentor.uid.isNotEmpty ? mentor.uid : mentor.name,
);
```

**Gating :** Le bouton "Message" n'est visible que si `_checkRequestStatus()` confirme une demande acceptée (vérification bidirectionnelle dans Firebase — `fromUserId == moi` OU `toUserId == moi` avec `status == 'accepted'`).

> **📸 CAPTURE D'ÉCRAN — Profil détail mentor (bio + secteurs + créneaux disponibles)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Confirmation de réservation de session (SnackBar vert)**
> *(Insérer ici la capture d'écran)*

---

## 10. Partage sur Réseaux Sociaux

### 10.1 Service de partage — `ServicePartage`

Le partage natif utilise le package `share_plus` qui ouvre la **feuille de partage système** du téléphone (WhatsApp, Facebook, Telegram, X, LinkedIn, email, SMS…) sans configuration spécifique par réseau social.

**Fichier :** `lib/services/service_partage.dart`

```dart
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  /// Partage un pitch entrepreneur sur les réseaux sociaux.
  static Future<void> sharePitch({
    required String title,
    required String sector,
    required String description,
    required String authorName,
    String? amount,
  }) async {
    final amountLine = (amount != null && amount.isNotEmpty)
        ? '\n💰 Besoin de financement : $amount FCFA'
        : '';

    final preview = description.length > 200
        ? '${description.substring(0, 200)}…'
        : description;

    final text = '🚀 *$title* — Pitch sur DIAPALER AFRICA\n\n'
        '👤 $authorName · 🏢 $sector$amountLine\n\n'
        '📝 $preview\n\n'
        '🇸🇳 Retrouve ce projet sur DIAPALER AFRICA — la plateforme qui '
        'connecte entrepreneurs, mentors et investisseurs au Sénégal.\n\n'
        '👉 Télécharge : https://diapalerafrica.app';

    await Share.share(text, subject: 'Pitch : $title — DIAPALER AFRICA');
  }

  /// Partage le profil d'un mentor ou investisseur.
  static Future<void> shareMentorProfile({
    required String name,
    required String role,
    required String sector,
    required String city,
    String? bio,
  }) async {
    final bioLine = (bio != null && bio.isNotEmpty)
        ? '\n\n"${bio.length > 150 ? bio.substring(0, 150) + '…' : bio}"'
        : '';

    final text = '👤 *$name* — $role sur DIAPALER AFRICA\n\n'
        '🏢 Secteur : $sector\n'
        '📍 $city$bioLine\n\n'
        '🤝 Tu cherches un mentor ou un investisseur ?\n'
        'Retrouve $name sur DIAPALER AFRICA.\n\n'
        '🇸🇳 Plateforme de mentorat entrepreneurial — Sénégal\n'
        '👉 https://diapalerafrica.app';

    await Share.share(text, subject: '$name — $role DIAPALER AFRICA');
  }

  /// Partage son propre profil entrepreneur.
  static Future<void> shareMyProfile({
    required String name,
    required String role,
    required String sector,
    required String city,
    String? projectName,
  }) async {
    final projectLine = (projectName != null && projectName.isNotEmpty)
        ? '\n🚀 Projet : $projectName'
        : '';

    final text = '👋 Je suis *$name*, $role sur DIAPALER AFRICA !\n\n'
        '🏢 Secteur : $sector\n'
        '📍 $city$projectLine\n\n'
        'Je recherche des mentors et investisseurs pour mon projet.\n'
        'Connectons-nous sur DIAPALER AFRICA !\n\n'
        '🇸🇳 https://diapalerafrica.app';

    await Share.share(text, subject: 'Mon profil DIAPALER AFRICA — $name');
  }

  /// Partage un conseil donné par DIALI IA.
  static Future<void> shareDialiAdvice({
    required String advice,
    required String userName,
  }) async {
    final preview = advice.length > 280
        ? '${advice.substring(0, 280)}…'
        : advice;

    final text = '💡 Conseil de *DIALI IA* pour $userName\n\n'
        '$preview\n\n'
        '🤖 DIALI est l\'assistant IA de DIAPALER AFRICA — spécialisé dans '
        'l\'écosystème sénégalais (DER/FJ, PAVIE 2, Be Yes, BNDE…).\n\n'
        '🇸🇳 https://diapalerafrica.app';

    await Share.share(text, subject: 'Conseil DIALI IA — DIAPALER AFRICA');
  }
}
```

### 10.2 Intégration dans les écrans

Le bouton de partage `IconButton(icon: Icon(Icons.share_rounded))` a été intégré dans trois écrans :

| Écran | Emplacement | Méthode appelée |
|---|---|---|
| `PagePitchsPublics` | Icône dans chaque carte pitch | `ShareService.sharePitch(...)` |
| `PageProfil` | AppBar actions (avant le bouton modifier) | `ShareService.shareMyProfile(...)` |
| `PageDetailMentor` | SliverAppBar actions (avant le favori) | `ShareService.shareMentorProfile(...)` |
| `PageDetailPitch` | SliverAppBar actions | `ShareService.sharePitch(...)` |
| `ChatbotPage` | AppBar actions (dernier conseil IA) + lien "Partager" sous chaque bulle DIALI | `ShareService.shareDialiAdvice(...)` |

**Exemple — bouton partage dans la liste des pitchs :**

```dart
// lib/screens/page_pitches_publics.dart
import '../services/service_partage.dart';

// Dans la carte de chaque pitch :
IconButton(
  onPressed: () => ShareService.sharePitch(
    title: title,
    sector: sector,
    description: description,
    authorName: userName,
    amount: amount.isNotEmpty ? amount : null,
  ),
  icon: const Icon(Icons.share_rounded, size: 18),
  color: AppColors.muted,
),
```

**Exemple — bouton partage dans le profil personnel :**

```dart
// lib/screens/page_profil.dart
import '../services/service_partage.dart';

// Dans AppBar.actions :
IconButton(
  tooltip: 'Partager mon profil',
  onPressed: () => ShareService.shareMyProfile(
    name: p.fullName,
    role: p.role,
    sector: p.sector,
    city: p.city,
    projectName: p.projects.isNotEmpty ? p.projects.first.name : null,
  ),
  icon: const Icon(Icons.share_rounded),
),
```

### 10.3 Résultat du partage

Quand l'utilisateur appuie sur le bouton partage, la **feuille native du système** s'ouvre avec un texte pré-formaté :

```
🚀 *AgriTech Dakar* — Pitch sur DIAPALER AFRICA

👤 Moussa Diallo · 🏢 Agriculture
💰 Besoin de financement : 5000000 FCFA

📝 Solution numérique de mise en relation entre agriculteurs
sénégalais et acheteurs locaux / export...

🇸🇳 Retrouve ce projet sur DIAPALER AFRICA — la plateforme qui
connecte entrepreneurs, mentors et investisseurs au Sénégal.

👉 Télécharge : https://diapalerafrica.app
```

> **📸 CAPTURE D'ÉCRAN — Feuille de partage native (WhatsApp, Facebook, Telegram…)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bouton partage (icône) dans la liste des pitchs**
> *(Insérer ici la capture d'écran)*

---

## 10.bis Système de Contacts

### Description

Les contacts acceptés sont accessibles depuis `MesMentorsPage` (`page_mes_mentors.dart`) — page dédiée "Mes Contacts" navigable depuis l'accueil, avec **2 onglets** (Mentors / Investisseurs). Une relation est créée dès qu'une demande de mentorat **ou** une proposition d'investissement est acceptée.

**Fonctionnalités :**
- Liste des contacts (relations acceptées : mentor/mentoré, investisseur/entrepreneur)
- Searchable par nom en temps réel
- Chip badge coloré indiquant le rôle du contact (Mentor : vert, Investisseur : bleu, Entrepreneur : amber)
- Tap → ouvre directement le chat

**Logique de communication stricte :**

| Situation | Bouton affiché |
|---|---|
| Entrepreneur → Mentor (demande en attente) | "Envoyer une demande de mentorat" uniquement |
| Entrepreneur → Mentor (demande acceptée) | "Contacter" (chat) |
| Entrepreneur → Investisseur (proposition en attente) | "Proposer un investissement" uniquement |
| Entrepreneur → Investisseur (acceptée) | "Contacter" (chat) |
| Mentor / Investisseur → Entrepreneur | Accès libre au chat |

---

## 10.ter Flux Investisseur complet

### Description du flux

1. L'investisseur consulte les pitchs sur `page_pitches_publics.dart`
2. Il clique "💰 Proposer un investissement" sur un pitch
3. Un `MentorRequest` est créé dans Firebase avec `type: 'investment'`
4. L'entrepreneur reçoit une notification automatique
5. L'entrepreneur accepte ou refuse dans `page_requests.dart` (section "Propositions d'investissement")
6. Après acceptation → relation ajoutée dans les Contacts, communication autorisée

**Écran `page_requests.dart` — deux sections :**

| Section | Description |
|---|---|
| "Demandes de mentorat" | `MentorRequest` avec `type: 'mentor'` |
| "Propositions d'investissement" | `MentorRequest` avec `type: 'investment'` |

---

## 10.4 Système d'Avis et Notation ⭐

Le système d'avis et de notation a été ajouté pour renforcer la confiance au sein de la communauté DIAPALER AFRICA. Un entrepreneur peut noter un mentor après avoir travaillé avec lui, et inversement. Nous avons délibérément restreint l'accès à la notation aux membres ayant une relation acceptée — cela évite les avis non pertinents ou malveillants. La note moyenne calculée en temps réel depuis Firebase s'affiche directement sur le profil et les dashboards, donnant à chaque membre une réputation visible et crédible.

### Description

Le système d'avis permet aux membres ayant une **relation acceptée** de laisser une note (1 à 5 étoiles) et un commentaire sur le profil d'un autre membre.

**Fonctionnalités de `page_avis.dart` :**
- StreamBuilder sur `reviews/{toUid}` — mises à jour en temps réel
- Saisie de commentaire texte libre ; la note (1–5 étoiles) est stockée séparément via `InteractionsService.setRating()` dans le nœud `ratings/{toUid}/{fromUid}` (entier 1–5), distinct du nœud `reviews/`
- Calcul de la **moyenne live** depuis `getRatings()` — affichée avec icône ⭐ sur le profil et les dashboards
- **Accès restreint par relation** :
  - Relation acceptée → peut laisser un avis
  - Propre profil → lecture seule
  - Aucune relation → bannière "Relation requise pour laisser un avis"
- Affichage chronologique (plus récents en premier)
- Compteur d'avis mis à jour en temps réel

```dart
// service_interactions.dart
// Note : le modèle Review n'a PAS de champ rating — les notes sont stockées
// séparément dans ratings/{toUid}/{fromUid} (entier 1–5) via setRating()/getRatings().
static Future<void> addReview({
  required String toUid,
  required String fromUid,
  required String fromName,
  required String text,
}) async {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  await _db.child('reviews/$toUid/$id').set({
    'id': id,
    'fromUid': fromUid,
    'fromName': fromName,
    'text': text,
    'createdAt': DateTime.now().millisecondsSinceEpoch, // entier, PAS ISO string
  });
  try {
    await NotificationService.notifyUser(
      uid: toUid,
      title: 'Nouvel avis reçu 💬',
      message: '$fromName a laissé un avis sur votre profil.',
      type: 'new_review',
    );
  } catch (_) {}
}

static Stream<List<Review>> getReviews(String targetUid) =>
    _db.child('reviews/$targetUid').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return <Review>[];
      return data.values
          .map<Review>((v) => Review.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
```

> **📸 CAPTURE D'ÉCRAN — Page Avis (liste des avis + sélecteur étoiles)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Note moyenne ⭐ sur le profil d'un mentor**
> *(Insérer ici la capture d'écran)*

---

## 10.5 Pitchs Favoris (Bookmark Investisseur) 🔖

Cette fonctionnalité a été pensée spécifiquement pour les investisseurs qui parcourent de nombreux pitchs et ont besoin de garder une liste de projets qui les intéressent. D'un simple tap sur l'icône de bookmark, ils sauvegardent un pitch dans leur liste personnelle, accessible depuis leur profil à tout moment. Le système est entièrement réactif grâce à un `ValueNotifier` global synchronisé avec Firebase — le bookmark change d'état visuellement sans aucun délai ni rechargement.

### Description

Les investisseurs peuvent **sauvegarder des pitchs** d'un simple tap sur l'icône 🔖 dans la liste des pitchs publiés.

**Fonctionnalités :**
- `PitchFavoriteService.pitchFavorites` — `ValueNotifier<List<Map<String, dynamic>>>` global
- **Écoute temps réel** : stream Firebase `pitchFavorites/{userId}` → mise à jour automatique
- Tri par `savedAt` décroissant (derniers sauvegardés en premier)
- **Toggle bookmark** : si déjà favori → `.remove()`, sinon → `.set()`
- Page dédiée `page_mes_pitchs_favoris.dart` — liste réactive avec état vide illustré

```dart
// service_pitch_favoris.dart
class PitchFavoriteService {
  static final _db = FirebaseDatabase.instance.ref();
  static final pitchFavorites = ValueNotifier<List<Map<String, dynamic>>>([]);
  static StreamSubscription? _sub;

  // Clé Firebase unique par pitch — fallback sur titre normalisé
  static String _keyOf(Map<String, dynamic> pitch) {
    final id = pitch['id']?.toString() ?? '';
    if (id.isNotEmpty) return id;
    // Fallback : titre normalisé
    return (pitch['title']?.toString() ?? 'pitch')
        .replaceAll(RegExp(r'[^\w]'), '_')
        .toLowerCase();
  }

  static Future<void> load(String userId) async {
    await _sub?.cancel();
    _sub = _db.child('pitchFavorites/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        pitchFavorites.value = [];
        return;
      }
      try {
        final list = data.values
            .where((v) => v is Map)
            .map<Map<String, dynamic>>((v) => Map<String, dynamic>.from(v as Map))
            .toList()
          ..sort((a, b) {
            final at = (b['savedAt'] as int?) ?? 0;
            final bt = (a['savedAt'] as int?) ?? 0;
            return at.compareTo(bt);
          });
        pitchFavorites.value = list;
      } catch (_) {
        pitchFavorites.value = [];
      }
    }, onError: (_) => pitchFavorites.value = []);
  }

  static Future<void> reset() async {
    await _sub?.cancel();
    _sub = null;
    pitchFavorites.value = [];
  }

  static bool isFavorite(Map<String, dynamic> pitch) {
    final key = _keyOf(pitch);
    return pitchFavorites.value.any((p) => _keyOf(p) == key);
  }

  static Future<void> toggle(String userId, Map<String, dynamic> pitch) async {
    if (userId.isEmpty) return;
    final key = _keyOf(pitch);
    if (key.isEmpty) return;
    final ref = _db.child('pitchFavorites/$userId/$key');
    if (isFavorite(pitch)) {
      await ref.remove();
    } else {
      await ref.set({
        ...pitch,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Icône bookmark 🔖 dans la liste des pitchs (état sauvegardé)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Page Mes Pitchs Sauvegardés (liste des bookmarks)**
> *(Insérer ici la capture d'écran)*

---

## 11. Paiement Mobile — Wave Premium

Pour monétiser l'application, nous avons intégré Wave, le portefeuille mobile le plus utilisé au Sénégal avec plusieurs millions d'utilisateurs actifs. L'approche choisie utilise les liens marchands Wave avec montant dynamique, ce qui évite de déployer un backend complexe pour la phase de démonstration. L'utilisateur est redirigé vers l'application Wave installée sur son téléphone, complète son paiement, puis revient dans DIAPALER AFRICA pour activer son abonnement Premium. Un seul plan cible les entrepreneurs de la plateforme.

### 11.1 Architecture simplifiée (lien marchand)

DIAPALER AFRICA intègre le paiement via **Wave**, le portefeuille mobile le plus utilisé au Sénégal. L'approche choisie utilise le **lien marchand Wave** avec paramètre de montant dynamique — aucun backend supplémentaire nécessaire.

```
Utilisateur → appuie "Payer avec Wave"
    ↓
url_launcher → ouvre https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/?amount=4900
    ↓
App Wave (ou navigateur) → utilisateur confirme le paiement
    ↓
Revient dans DIAPALER AFRICA → clique "J'ai payé"
    ↓
Firebase → users/{uid}/isPremium = true
```

**Avantages :**
- Pas de clé API côté client (sécurité maximale)
- Pas de backend/webhook requis pour la démo
- Fonctionne avec l'app Wave installée ou le navigateur
- Montant pré-rempli automatiquement selon le plan choisi

### 11.2 Plans d'abonnement

| Plan | Tarif / mois | Avantages |
|---|---|---|
| **Entrepreneur Premium** | **4 900 FCFA** | Pitch épinglé en tête du fil mentors & investisseurs, badge ⭐ sur profil et pitchs, demandes de mentorat illimitées, meilleure visibilité investisseurs, accès prioritaire mentors certifiés |

### 11.3 Implémentation — `ServiceWave`

**Fichier :** `lib/services/service_wave.dart`

```dart
const _waveBaseUrl = 'https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/';

enum PremiumPlan {
  entrepreneur;

  String get label => 'Entrepreneur Premium';
  int get amountXof => 4900;
  String get amountDisplay => '4 900 FCFA / mois';

  List<String> get benefits => [
    'Pitch épinglé en tête du fil mentors & investisseurs',
    'Badge ⭐ Premium visible sur ton profil et tes pitchs',
    'Demandes de mentorat illimitées',
    'Meilleure visibilité auprès des investisseurs',
    'Accès prioritaire aux mentors certifiés',
  ];

  String get waveUrl =>
      '$_waveBaseUrl?amount=$amountXof'
      '&label=Abonnement+Premium+DIAPALER+AFRICA';
}

class WaveService {
  /// Ouvre l'app Wave avec le montant pré-rempli.
  static Future<void> openPayment(PremiumPlan plan) async {
    final uri = Uri.parse(plan.waveUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir Wave. Vérifie que l\'app Wave est installée.');
    }
  }

  /// Marque l'utilisateur Premium dans Firebase ET met à jour le profil en mémoire.
  /// Le badge ⭐ apparaît instantanément sans redémarrer l'app.
  static Future<void> activatePremium(PremiumPlan plan) async {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    // 1. Persistance Firebase (profil)
    await DatabaseService.setPremium(uid: uid, plan: plan.name);
    // 2. Marquer tous les pitchs existants comme premium
    await DatabaseService.markUserPitchesPremium(uid, isPremium: true);
    // 3. Mise à jour immédiate en mémoire → badge visible instantanément
    final updated = UserProfileController.profile.value.copyWith(
      isPremium: true,
      premiumPlan: plan.name,
    );
    UserProfileController.update(updated);
  }
}
```

**Nœud Firebase mis à jour lors du paiement :**
```dart
// lib/services/service_base_de_donnees.dart
static Future<void> setPremium({
  required String uid,
  required String plan,
}) async {
  await _userRef(uid).update({
    'isPremium': true,
    'premiumPlan': plan,            // 'entrepreneur'
    'premiumSince': ServerValue.timestamp,
  });
}

/// Marque tous les pitchs d'un utilisateur comme premium (ou non) en batch.
static Future<void> markUserPitchesPremium(String uid,
    {required bool isPremium}) async {
  final snap = await _db.ref('pitches').get();
  if (!snap.exists || snap.value == null) return;
  final data = Map<String, dynamic>.from(snap.value as Map);
  final updates = <String, dynamic>{};
  for (final entry in data.entries) {
    final pitch = Map<String, dynamic>.from(entry.value as Map);
    if (pitch['userId'] == uid) {
      updates['pitches/${entry.key}/isPremium'] = isPremium;
    }
  }
  if (updates.isNotEmpty) await _db.ref().update(updates);
}
```

**Champ `isPremium` dans le modèle `UserProfile` :**
```dart
// lib/data/profil_utilisateur.dart
@immutable
class UserProfile {
  // ... autres champs ...
  final bool isPremium;     // true après activation Wave
  final String premiumPlan; // 'entrepreneur' | ''
}
```

Le champ `isPremium` est sérialisé dans **Firebase** (`_toMap`/`_fromMap`) ET dans le **cache offline** (`CacheService`) — le statut Premium est donc disponible même sans connexion.

### 11.4 Interface — `WavePremiumSheet` + badge ⭐

La bottom sheet s'affiche quand l'utilisateur souhaite passer en Premium. Elle a **deux états** :

**État 1 — Avant paiement :** affiche les avantages du plan + bouton "Payer avec Wave" (bleu Wave `#1BA9FF`)

**État 2 — Après retour de Wave :** affiche un bandeau vert + bouton "Oui, j'ai payé — Activer Premium"

**Badge ⭐ et bannière Premium sur `page_profil.dart` (Entrepreneur uniquement — implémenté) :**

Trois éléments visuels s'affichent dès que `isPremium = true` :

1. **Avatar** : le point vert de statut est remplacé par un cercle doré avec une icône étoile blanche
2. **Carte identité** : badge "Entrepreneur Premium" (fond amber semi-transparent, bordure amber, icône ⭐) s'affiche sous le rôle
3. **Section Interactions** :
   - Si `!isPremium` → bannière cliquable "Passer Entrepreneur Premium / 4 900 FCFA/mois · Pitchs en tête de liste" → ouvre `WavePremiumSheet(PremiumPlan.entrepreneur)`
   - Si `isPremium` → badge vert "Compte Entrepreneur Premium actif"

```dart
// Ouverture de la bottom sheet depuis n'importe quel écran
await WavePremiumSheet.show(context, PremiumPlan.entrepreneur);

// Le retour est true si Premium activé, null/false sinon
```

**Flux utilisateur complet :**
1. Clique "Passer Premium" → bottom sheet s'ouvre
2. Voit les avantages + prix → clique "Payer avec Wave — 4 900 FCFA / mois"
3. L'app Wave s'ouvre avec le montant pré-rempli
4. Confirme le paiement dans Wave → revient dans DIAPALER AFRICA
5. Clique "Oui, j'ai payé — Activer Premium" → Firebase mis à jour → SnackBar vert

> **📸 CAPTURE D'ÉCRAN — Bottom sheet Premium (avantages + bouton Wave bleu)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — App Wave ouverte avec montant pré-rempli (4 900 FCFA)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Confirmation "Compte Premium activé !" (SnackBar vert)**
> *(Insérer ici la capture d'écran)*

---

## 12. Déploiement

Pour rendre l'application testable par les utilisateurs finaux et l'équipe pédagogique, nous avons compilé un APK release signé distribué via Google Drive. La signature avec un keystore RSA 2048 bits garantit l'intégrité de l'application et prépare la base pour une éventuelle publication sur le Play Store. La commande de build Flutter a activé le tree-shaking des icônes Material, ce qui a réduit le poids des assets de 1,6 MB à seulement 16 Ko.

### 12.1 Build release signé

L'application a été compilée en **APK release signé** prêt à l'installation :

```
flutter build apk --release
✓ Built build\app\outputs\flutter-apk\app-release.apk (58.2MB)
```

| Paramètre | Valeur |
|---|---|
| Type | APK release signé |
| Taille | 58.2 MB |
| Keystore | RSA 2048 bits, 10 000 jours de validité |
| Tree-shaking | MaterialIcons : −99 % (1,6 MB → 16 Ko) |

> **📸 CAPTURE D'ÉCRAN — Terminal : `✓ Built app-release.apk (58.2MB)`**
> *(Insérer ici la capture d'écran)*

---

### 12.2 Distribution via Google Drive

L'APK est distribué via Google Drive (gratuit, suffisant pour un projet académique). Le détail complet de la justification est dans le Livrable 6 §7.3.

**Lien de téléchargement APK :**
> 📦 https://drive.google.com/file/d/1XLJiSSJR8rQXCrAmY5mJWyx9i-6HFoGJ/view?usp=sharing

> **📸 CAPTURE D'ÉCRAN — Google Drive : APK DIAPALER AFRICA disponible au téléchargement**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Installation de l'APK sur Android (autoriser les sources inconnues)**
> *(Insérer ici la capture d'écran)*

---

## SECTIONS BONUS — Écrans et Fonctionnalités Additionnels

Les sections suivantes documentent les écrans et services additionnels non explicitement mentionnés dans les sections précédentes, mais présents dans le code et intégrés à l'application.

### 2.6 Recommandations intelligentes — `page_mentors_recommandes.dart`

Au-delà de la recherche manuelle, l'app propose des recommandations de mentors filtrées intelligemment selon le profil de l'utilisateur.

**Algorithme de recommandation :**
- Secteur principal de l'utilisateur (premier critère)
- Secteurs des projets en cours (critères secondaires)
- Centres d'intérêt partagés (tags)
- Distance GPS optionnelle

**Affichage :**
- Liste complète des mentors recommandés
- Cartes mentor standards (avatar, nom, secteur, distance, compatibilité %)
- Tri : compatibilité décroissante
- Tap → Détail profil + Réserver session

> **📸 CAPTURE D'ÉCRAN — Mentors Recommandés**
> *(Insérer ici la capture d'écran)*

---

### 4.7 Formulaire d'envoi demande — `page_send_request.dart`

Avant d'envoyer une demande de mentorat ou d'investissement, l'utilisateur peut personnaliser sa demande avec un message contextuel.

**Affichage :**
- Avatar + nom du mentor/investisseur en en-tête
- Champ message personnalisé (placeholder: "Explique pourquoi tu souhaites travailler ensemble…")
- **Pour demande d'investissement uniquement :** champ budget optionnel (en FCFA)
- Validation : message min 10 caractères
- Bouton "ENVOYER" → Création `MentorRequest` dans Firebase + notification destinataire
- Retour automatique à Profil / Pitchs après envoi

> **📸 CAPTURE D'ÉCRAN — Formulaire Envoi Demande**
> *(Insérer ici la capture d'écran)*

---

### 5.4 Mes Mentors — Relations acceptées (`page_mes_mentors.dart`)

`MesMentorsPage` — page dédiée "Mes Contacts" avec 2 onglets (Mentors / Investisseurs), affichant les relations acceptées.

**Affichage :**
- Liste des contacts selon l'onglet actif (Mentors ou Investisseurs)
- Avatar + nom + secteur + badge rôle coloré
- Tap → Messagerie directe (`ChatPage`)

Cette vue facilite la navigation rapide vers ses contacts sans chercher dans toute la messagerie.

> **📸 CAPTURE D'ÉCRAN — Mes Mentors**
> *(Insérer ici la capture d'écran)*

---

### 7.1.1 Consultation d'un pitch — `page_detail_pitch.dart` (vue propriétaire)

Le propriétaire d'un pitch peut consulter et modifier les détails de son pitch après publication, y compris uploader des fichiers d'accompagnement (PDF business plan, vidéo pitch, deck présentation).

**Fonctionnalités :**
- Bottom sheet `DraggableScrollableSheet` (hauteur min 0.5, max 1.0)
- Affichage titre, description, secteur, montant
- **Uploads facultatifs** (Cloudinary) :
  - Business plan (PDF max 10MB)
  - Vidéo pitch (MP4 max 50MB)
  - Deck de présentation (PDF max 5MB)
- Statut upload en temps réel (pourcentage)
- Bouton "Supprimer le pitch" (après confirmation)
- Retour à `PitchesPublics` après édition/suppression

---

### 7.3 Gestion mes pitchs — `page_mes_pitchs.dart`

Après création d'un pitch, l'entrepreneur peut accéder à sa liste personnelle de pitchs pour en consulter l'historique, les éditer, ou les supprimer.

**Fonctionnalités :**
- Onglet "Mes pitchs" accessible depuis Mon Profil ou via navigation
- Liste temps réel (`StreamBuilder`) de tous les pitchs créés par l'utilisateur
- Statut visuel : "Publié" (badge vert) / "Brouillon" (badge gris, optionnel)
- Tap sur un pitch → `PitchDetailPage` (vue propriétaire) pour éditer/voir uploads
- Bouton "Ajouter un pitch" → `PitchPage` (nouvelle création)
- Swipe ou bouton suppression → Dialog de confirmation → Suppression Firebase + `pitches/`
- Tri : date descroissante (plus récent en premier)

> **📸 CAPTURE D'ÉCRAN — Gestion Mes Pitchs**
> *(Insérer ici la capture d'écran)*

---

### 9. Système de Favoris — Mentors et Pitchs

L'app dispose de **deux systèmes de favoris distincts** :

#### 9.1 Favoris Mentors/Investisseurs — `page_mes_favoris.dart` + `service_favoris.dart`

Permet à tout utilisateur de mettre en favori des profils (mentors ou investisseurs) pour y revenir facilement.

**Fonctionnalités :**
- Icône ♥ clic sur chaque profil (Matching, Détail) → sauvegarde Firebase sous `favorites/$userId/$mentorKey`
- Liste réactive temps réel via `FavoriteService.favorites` (ValueNotifier)
- Affichage: cartes mentor standards avec Cœur 💖 rempli
- Tap → Détail profil + Réserver / Investir
- Suppression favori: tap cœur à nouveau

> **📸 CAPTURE D'ÉCRAN — Mes Favoris Mentors**
> *(Insérer ici la capture d'écran)*

#### 9.2 Favoris Pitchs — `page_mes_pitchs_favoris.dart` + `service_pitch_favoris.dart`

Les investisseurs peuvent sauvegarder les pitchs qui les intéressent pour consultation ultérieure (bookmark).

**Fonctionnalités :**
- Icône 🔖 sur chaque carte pitch (Pitchs Publics) → sauvegarde Firebase sous `pitchFavorites/$userId/$pitchKey`
- Liste réactive temps réel via `PitchFavoriteService.pitchFavorites` (ValueNotifier)
- Affichage: cartes pitch standards avec Bookmark 🔖 rempli
- Tap → Détail pitch détaillé
- Suppression favori: tap bookmark à nouveau

> **📸 CAPTURE D'ÉCRAN — Mes Pitchs Favoris**
> *(Insérer ici la capture d'écran)*

---

## Conclusion du Livrable 5

### Bilan des fonctionnalités implémentées

| Fonctionnalité (sujet) | Implémentation | Statut |
|---|---|---|
| Notifications | `NotificationService` (Firebase) + badge dynamique + centre + "Effacer tout" | ✅ |
| Recherche | Filtre textuel temps réel (nom, secteur, ville) dans Matching + Pitchs Publiés | ✅ |
| Filtres | Pills rôle + Pills secteur (10) + Dropdown ville + Reset (Matching) | ✅ |
| Filtres pitchs | Recherche + pills secteur dynamiques + compteur + reset dans Pitchs Publiés | ✅ (bonus) |
| Géolocalisation | `getCurrentLocation()` + tri proximité + puce distance km + `LocationService.detectCity()` + localité Nominatim (quartier/suburb) pré-rempli dans Modifier profil | ✅ |
| Chatbot IA | DIALI (llama-3.1-8b-instant) + proxy Cloudflare + FAB pulsant | ✅ |
| Messagerie temps réel | Firebase WebSocket + badge global `unreadMessagesCount` | ✅ (bonus) |
| Badge messages non lus | `ValueNotifier<int>` global dans `service_navigation.dart` | ✅ (bonus) |
| Bouton "Près de moi" | GPS + tri distance + animation couleur | ✅ (bonus) |
| Membres DIAPALER réels | `UsersService.listMembers()` en tête de liste Matching | ✅ (bonus) |
| Agenda Firebase | `AgendaController.bookBilateral()` + `cancel()` bilatéral | ✅ (bonus) |
| Bouton "Annuler" session | Dialog confirmation + suppression bilatérale Firebase | ✅ (bonus) |
| Planning mentor | Gestion disponibilités via `InteractionsService` | ✅ (bonus) |
| Demandes de mentorat | Envoi + accepter/refuser + notification automatique | ✅ (bonus) |
| **Flux investisseur** | "Proposer un investissement" + `type: 'investment'` + 2 sections dans `RequestsPage` | ✅ (bonus) |
| **Système de Contacts** | Onglet "Contacts" dans Messages — relations acceptées, searchable, badge rôle, tap → chat | ✅ (bonus) |
| **Matching rôle-adaptatif** | Mentor → "Mes Entrepreneurs", Investisseur → "Entrepreneurs à financer" | ✅ (bonus) |
| **Compatibilité dynamique** | Algorithme intérêts partagés — remplace valeurs hardcodées | ✅ (bonus) |
| **Pitch (stepper 5 étapes)** | `PitchPage` → validation par étape + sauvegarde progressive + **bouton Précédent** (retour libre entre étapes) + publication directe | ✅ (bonus) |
| **Fil de pitchs publics** | `PublicPitchesPage` → stream temps réel `DatabaseService.getPitches()` | ✅ (bonus) |
| **Dashboard Mentor** | SliverAppBar + stats + raccourcis Pitchs/Planning/Demandes | ✅ (bonus) |
| **Dashboard Investisseur** | SliverAppBar + ticket investissement + "Entrepreneurs à financer" | ✅ (bonus) |
| **Agenda rôle-spécifique** | Titre/description adaptés : "Mes sessions" / "Mon agenda" / "Mes rendez-vous" | ✅ (bonus) |
| **Détail mentor** | Bio Firebase réelle + pronom genre + bouton adapté rôle (mentorat/investissement) | ✅ (bonus) |
| **Bouton CIS informatif** | Bottom sheet expliquant le Club des Investisseurs du Sénégal | ✅ (bonus) |
| **Partage réseaux sociaux** | `ShareService` (share_plus) — pitch (`PagePitchsPublics` + `PageDetailPitch`), profil (perso + mentor), conseil DIALI (bouton AppBar + lien sous chaque bulle) | ✅ (bonus) |
| **Paiement mobile Wave** | `WaveService` + lien marchand + `WavePremiumSheet` + badge ⭐ profil | ✅ (bonus) |
| **Sauvegarde MDP** | `AutofillGroup` + `finishAutofillContext` → Google/Samsung/iCloud Password Manager | ✅ (bonus) |
| **Déploiement APK signé** | `flutter build apk --release` — APK 58.2 MB disponible en téléchargement | ✅ (bonus) |
| **Avis et notation ⭐** | `ReviewsPage` + `addReview()` + stream `reviews/` + accès restreint par relation | ✅ (bonus) |
| **Pitchs favoris 🔖** | `PitchFavoriteService` + `toggleFavorite()` + stream `pitchFavorites/` + `MesPitchsFavorisPage` | ✅ (bonus) |

---

### Perspectives de développement

Les trois fonctionnalités avancées mentionnées dans le sujet sont toutes implémentées :

| Fonctionnalité | Statut |
|---|---|
| Partage sur réseaux sociaux | ✅ Implémenté — voir section 10 |
| Paiement mobile (Wave) | ✅ Implémenté — voir section 11 |
| Déploiement | ✅ Implémenté — voir section 12 |

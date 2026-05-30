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
  - [7.1 Dépôt de pitch — Formulaire 3 étapes](#71-dépôt-de-pitch--formulaire-3-étapes-page_pitchdart)
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
| Recherche | Barre textuelle en temps réel (nom, secteur, ville) | ✅ |
| Filtres | Pills rôle + Pills secteur (10) + Dropdown ville + Reset | ✅ |
| Géolocalisation | GPS + bouton "Près de moi" + tri distance + puce km | ✅ |
| Chatbot IA | DIALI (Llama 3.1 8B via Groq) + proxy Cloudflare + FAB pulsant | ✅ |
| Messagerie temps réel | Firebase WebSocket + badge `unreadMessagesCount` global | ✅ (bonus) |
| Agenda | `AgendaController.bookBilateral()` + annulation bilatérale | ✅ (bonus) |
| Planning | Gestion disponibilités mentor via Firebase | ✅ (bonus) |
| Demandes mentorat | Envoi + accepter/refuser + notification croisée | ✅ (bonus) |
| **Pitch (stepper 3 étapes)** | `PitchPage` → double sauvegarde profil + `pitches/` global | ✅ (bonus) |
| **Fil de pitchs publics** | `PublicPitchesPage` → stream Firebase temps réel | ✅ (bonus) |
| **Dashboard Mentor** | `SliverAppBar` + stats + raccourcis | ✅ (bonus) |
| **Dashboard Investisseur** | Header + accès Pitchs + Matching | ✅ (bonus) |
| **Détail mentor** | Réservation session + favori + chat direct | ✅ (bonus) |

---

## 1. Système de Notifications

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
  final String   type;       // ex: 'message', 'request', 'session_booked'…
  bool           isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id':        id,
    'title':     title,
    'message':   message,
    'timestamp': timestamp.toIso8601String(),
    'type':      type,
    'isRead':    isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id:        json['id']?.toString() ?? '',
        title:     json['title']?.toString() ?? '',
        message:   json['message']?.toString() ?? '',
        timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')
                   ?? DateTime.now(),
        type:      json['type']?.toString() ?? 'info',
        isRead:    json['isRead'] as bool? ?? false,
      );
}
```

---

### 1.2 Service de notifications

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
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NotificationItem(
      id: id, title: title, message: message,
      timestamp: DateTime.now(), type: type,
    );
    if (_userId != null) {
      await _db.child('notifications/$_userId/$id').set(item.toJson());
      // Le ValueNotifier est mis à jour par le listener Firebase en temps réel.
    } else {
      notifications.value = [item, ...notifications.value]; // fallback mémoire
    }
  }

  /// Pousse une notification dans la boîte d'un AUTRE utilisateur.
  /// Utilisé pour les notifs croisées (ex: acceptation de demande de mentorat).
  static Future<void> notifyUser({
    required String uid,
    required String title,
    required String message,
    required String type,
  }) async {
    if (uid.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = NotificationItem(
      id: id, title: title, message: message,
      timestamp: DateTime.now(), type: type,
    );
    try {
      await _db.child('notifications/$uid/$id').set(item.toJson());
    } catch (_) {} // Échec silencieux
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

La page utilise un `ValueListenableBuilder` sur `NotificationService.notifications` et affiche soit un état vide illustré, soit une `ListView` de tuiles. Chaque tuile (`_NotificationTile`) déduit icône et couleur du champ `type` (String : `mentor_request`, `session_booked`, `session_cancelled`, `message`…). Tap → `markAsRead()`, bouton "Effacer tout" → `clearAll()`.

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

La page Matching intègre un système de filtres multicritères : **barre de recherche textuelle** (temps réel sur nom/secteur/ville), **pills de rôle** (Tous / Mentor / Investisseur), **pills de secteur** (10 secteurs sénégalais), **dropdown de ville**, et bouton **"Réinitialiser"** visible dès qu'un filtre est actif.

Tous les filtres convergent dans le getter `_filtered` qui combine les membres Firebase réels (priorité) et les 100+ profils statiques :

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
    // Membres DIAPALER réels (uid non vide) en tête, puis par compatibilité
    list.sort((a, b) => b.uid.isNotEmpty == a.uid.isNotEmpty
        ? b.compatibility.compareTo(a.compatibility)
        : (b.uid.isNotEmpty ? 1 : -1));
  }
  return list;
}

bool get _hasFilter => _query.isNotEmpty || _sector != 'Tous' || _city != 'Toutes' || _role != 'Tous';
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

  /// Formate une distance km de façon lisible
  static String formatDistance(double km) {
    if (km < 1)  return '< 1 km';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
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

## 4. Chatbot IA — DIALI

### 4.1 Présentation

**DIALI** (wolof : "aller de l'avant") est l'assistant IA de DIAPALER AFRICA. Propulsé par **Llama 3.1 8B** de Meta via **Groq**, il accompagne les entrepreneurs, mentors et investisseurs avec des conseils contextualisés à l'écosystème sénégalais.

| Caractéristique | Détail |
|---|---|
| API | Groq Chat Completions API |
| Modèle | llama-3.1-8b-instant (rapide + haute qualité) |
| Langue | Français (compréhension du wolof) |
| Contexte système | DER/FJ, BNDE, FONGIP, FONSIS, secteurs porteurs |
| Accès | FAB pulsant amber visible depuis tous les onglets |

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
  onPressed: () => Navigator.push(
    context,
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
- Message de bienvenue **personnalisé selon le rôle** de l'utilisateur
- Bulles de messages : utilisateur → droite (navy) / DIALI → gauche (blanc)
- **Indicateur de frappe animé** (3 points) pendant la génération
- Scroll automatique vers le dernier message
- Champ de saisie multi-lignes + bouton envoi (désactivé pendant la génération)
- Historique conservé pendant toute la session

```dart
class _ChatbotPageState extends State<ChatbotPage> {
  // Liste typée ChatbotMessage (pas des Map brutes)
  final _messages = <ChatbotMessage>[];
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Message de bienvenue personnalisé selon le rôle
    final profile = UserProfileController.profile.value;
    final greeting = switch (profile.role) {
      'Mentor' =>
        'Bonjour ${profile.firstName} ! Je suis DIALI. Je peux t\'aider à '
        'mieux accompagner tes mentorés ou structurer tes sessions.',
      'Investisseur' =>
        'Bonjour ${profile.firstName} ! Je suis DIALI. Je peux t\'aider à '
        'identifier des opportunités d\'investissement au Sénégal.',
      _ =>
        'Bonjour ${profile.firstName} ! Je suis DIALI, ton assistant '
        'entrepreneurial. Je t\'aide avec ton business plan, le financement, '
        'ou l\'écosystème sénégalais (DER/FJ, BNDE, FONGIP…).',
    };
    _messages.add(ChatbotMessage(role: 'assistant', content: greeting));
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    final profile = UserProfileController.profile.value;
    _ctrl.clear();

    setState(() {
      _messages.add(ChatbotMessage(role: 'user', content: text));
      _loading = true;
    });
    _scrollToBottom();

    try {
      // sendMessage attend des ChatbotMessage typés + infos profil pour le prompt système
      final reply = await ChatbotService.sendMessage(
        messages:   _messages,
        userName:   profile.firstName,
        userRole:   profile.role,
        userSector: profile.sector,
        userCity:   profile.city,
      );
      setState(() => _messages.add(ChatbotMessage(role: 'assistant', content: reply)));
    } catch (e) {
      setState(() => _messages.add(ChatbotMessage(
        role: 'assistant',
        content: 'Désolé, je rencontre une difficulté technique. Réessaie.',
      )));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.amber, radius: 16,
              child: Icon(Icons.psychology_rounded, size: 18, color: AppColors.navyDeep),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIALI IA',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text('Assistant entrepreneurial',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Liste des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _messages.length) {
                  return const _TypingIndicator(); // Indicateur "..."
                }
                final msg    = _messages[i];
                final isUser = msg.role == 'user';
                return _ChatBubble(text: msg.content, isUser: isUser);
              },
            ),
          ),

          // ── Champ de saisie
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 4, minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Pose ta question à DIALI…',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _loading ? null : _send,
                  backgroundColor: AppColors.amber,
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Icon(Icons.send_rounded, color: AppColors.navyDeep),
                ),
              ],
            ),
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
  final String otherUid; // UID de l'autre partie (notif croisée)

  String get weekday  => ['Lundi','Mardi','Mercredi','Jeudi','Vendredi',
                          'Samedi','Dimanche'][scheduledAt.weekday - 1];
  String get day      => scheduledAt.day.toString().padLeft(2, '0');
  String get month    => ['JAN','FÉV','MAR','AVR','MAI','JUIN',
                          'JUIL','AOÛT','SEP','OCT','NOV','DÉC'][scheduledAt.month - 1];
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
  static final _db = FirebaseDatabase.instance.ref();
  static final sessions = ValueNotifier<List<BookedSession>>([]);

  /// Écoute Firebase en temps réel (WebSocket).
  static Future<void> load(String userId) async {
    _db.child('bookedSessions/$userId').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) { sessions.value = []; return; }
      final list = data.values
          .map<BookedSession>((v) =>
              BookedSession.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      sessions.value = list;
    });
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
    // Notification push au mentor
    await NotificationService.notifyUser(
      uid: otherUid,
      title: 'Nouveau rendez-vous',
      message: '$requesterName a réservé une session avec toi.',
      type: 'session_booked',
    );
  }

  /// Annulation bilatérale + notification de l'autre partie.
  static Future<void> cancel({
    required String userId,
    required String userName,
    required BookedSession session,
    required String reason,
  }) async {
    await _db.child('bookedSessions/$userId/${session.id}').remove();
    if (session.otherUid.isNotEmpty) {
      await _db.child('bookedSessions/${session.otherUid}/${session.id}').remove();
      await NotificationService.notifyUser(
        uid: session.otherUid,
        title: 'Rendez-vous annulé',
        message: '$userName a annulé votre session — motif : $reason',
        type: 'session_cancelled',
      );
    }
  }
}
```

**Page `page_agenda.dart` avec `ValueListenableBuilder` :**
```dart
class AgendaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final role = UserProfileController.profile.value.role;
    // Titre adapté selon le rôle
    final title = role == 'Mentor'
        ? 'Mon agenda'
        : role == 'Investisseur'
            ? 'Mes rendez-vous'
            : 'Mes sessions';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        builder: (context, sessions, _) {
          final now      = DateTime.now();
          final upcoming = sessions.where((s) => s.scheduledAt.isAfter(now)).toList();
          final past     = sessions.where((s) => !s.scheduledAt.isAfter(now)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            children: [
              _SummaryCard(upcomingCount: upcoming.length),
              const _SectionLabel('À VENIR'),
              ...upcoming.map((s) => _BookedSessionCard(session: s)),
              const _SectionLabel('PASSÉES'),
              ...past.map((s) => _BookedSessionCard(session: s, isPast: true)),
            ],
          );
        },
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Agenda : sessions à venir (date + heure + bouton "Annuler le rendez-vous")**
> *(Insérer ici la capture d'écran)*

---

### 6.2 Planning (disponibilités mentor)

```dart
// page_planning.dart — Gestion des créneaux disponibles
StreamBuilder<Availability?>(
  stream: InteractionsService.getAvailability(currentUid),
  builder: (context, snapshot) {
    final availability = snapshot.data;
    // Affichage + modification des créneaux
    return _AvailabilityEditor(
      availability: availability,
      onSave: (updated) => InteractionsService.updateAvailability(updated),
    );
  },
)
```

> **📸 CAPTURE D'ÉCRAN — Planning du mentor : créneaux disponibles**
> *(Insérer ici la capture d'écran)*

---

### 6.3 Demandes de mentorat

```dart
// page_send_request.dart — Envoi d'une demande
Future<void> _sendRequest() async {
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
        onReject: () => InteractionsService.rejectRequest(requests[i].id),
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

### 7.1 Dépôt de pitch — Formulaire 3 étapes (`page_pitch.dart`)

Les entrepreneurs déposent leur pitch via un **stepper 3 étapes** avec validation obligatoire par étape.

**Fonctionnalités clés :**
- Étape 1 : Titre (min 3 chars, obligatoire) + elevator pitch (optionnel)
- Étape 2 : Secteur dropdown (obligatoire) + description détaillée (min 20 chars, obligatoire)
- Étape 3 : Montant FCFA (optionnel) + carte explicative "Qui verra ton pitch ?"
- **Validation par étape** : bouton CONTINUER désactivé + message d'aide si champ invalide
- **Double sauvegarde** : profil entrepreneur (`projects/`, `totalSteps: 3`) + nœud global `pitches/`
- **Après publication** : navigation vers l'onglet Profil + SnackBar "Retrouve-le dans ton profil → Mes projets"

```dart
// Validations par étape — CONTINUER désactivé si non valide
bool get _step0Valid => _title.text.trim().length >= 3;
bool get _step1Valid =>
    _sector != null && _detailDescription.text.trim().length >= 20;
bool get _step2Valid => true; // Montant optionnel

// Projet créé avec totalSteps: 3 (Idée → En cours → Lancé)
final project = Project(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: title, description: description, sector: sector,
  step: 1, totalSteps: 3,
);

// Après publication : navigation vers onglet Profil
appTabIndex.value = 4;
Navigator.of(context).pop();
```

> **📸 CAPTURE D'ÉCRAN — Étape 1 du formulaire Pitch (titre + bouton désactivé sans texte)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Étape 3 (montant FCFA + carte "Qui verra ton pitch ?")**
> *(Insérer ici la capture d'écran)*

---

### 7.2 Fil des pitchs publics (`page_pitches_publics.dart`)

Les mentors et investisseurs voient tous les pitchs en **temps réel** grâce à `DatabaseService.getPitches()` (stream Firebase WebSocket).

```dart
// lib/screens/page_pitches_publics.dart
class PublicPitchesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pitchs publiés')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: DatabaseService.getPitches(), // Stream WebSocket Firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pitches = snapshot.data ?? [];
          if (pitches.isEmpty) {
            return const Center(
              child: Text('Aucun pitch publié pour le moment.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: pitches.length,
            itemBuilder: (_, i) => _PitchCard(pitch: pitches[i]),
          );
        },
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  final Map<String, dynamic> pitch;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Avatar(initials: pitch['userName']?.toString().substring(0,1) ?? '?'),
        title: Text(pitch['title'] ?? ''),
        subtitle: Text('${pitch['sector']} · ${pitch['userName']}'),
        trailing: pitch['amount']?.toString().isNotEmpty == true
            ? Chip(label: Text(pitch['amount']))
            : null,
        onTap: () {
          // generateConversationId est SYNCHRONE (retourne String, pas Future)
          final convId = InteractionsService.generateConversationId(
            AuthService.currentUid ?? '',
            pitch['userId'] ?? '',
          );
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: convId,
              otherUserId:    pitch['userId'] ?? '',
              otherUserName:  pitch['userName'] ?? '',
            ),
          ));
        },
      ),
    );
  }
}
```

> **📸 CAPTURE D'ÉCRAN — Fil des pitchs publics (liste temps réel)**
> *(Insérer ici la capture d'écran)*

---

## 8. Dashboards par rôle

### 8.1 Dashboard Mentor (`page_dashboard_mentor.dart`)

`CustomScrollView` + `SliverAppBar` épinglée. Contient : header avec avatar vert + badge notifications, grille de 3 statistiques, et tuiles d'actions rapides (Pitchs publiés, Mon Planning, Demandes reçues). Le tout est enveloppé dans un `ValueListenableBuilder<UserProfile>` pour rester synchronisé.

```dart
CustomScrollView(slivers: [
  SliverAppBar(pinned: true, title: Row(children: [
    Avatar(initials: profile.initials, background: AppColors.roleMentor),
    Text('Bienvenue ${profile.firstName} 👋'),
    _NotificationBadge(), // ValueListenableBuilder sur NotificationService
  ])),
  SliverToBoxAdapter(child: _StatsGrid(profile: profile)),
  SliverToBoxAdapter(child: Column(children: [
    _ActionTile('Voir les Pitchs', onTap: () => push(PublicPitchesPage())),
    _ActionTile('Mon Planning',    onTap: () => push(PlanningPage())),
    _ActionTile('Demandes reçues', onTap: () => push(RequestsPage())),
  ])),
])
```

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor (header + stats + actions rapides)**
> *(Insérer ici la capture d'écran)*

---

### 8.2 Dashboard Investisseur (`page_dashboard_investisseur.dart`)

Même architecture que le Dashboard Mentor (SliverAppBar + ValueListenableBuilder), mais orienté découverte de projets : accès rapide aux pitchs des entrepreneurs et à la page Matching.

```dart
CustomScrollView(slivers: [
  SliverAppBar(pinned: true, title: Row(children: [
    Avatar(initials: profile.initials, background: AppColors.blue),
    Text('Bienvenue ${profile.firstName} 👋'),
    _NotificationBadge(),
  ])),
  SliverToBoxAdapter(child: Column(children: [
    _ActionTile('Pitchs des entrepreneurs', onTap: () => push(PublicPitchesPage())),
    _ActionTile('Matching entrepreneurs',   onTap: () => appTabIndex.value = 1),
  ])),
])
```

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur (header + accès rapide Pitchs)**
> *(Insérer ici la capture d'écran)*

---

## 9. Page Détail Mentor (`page_detail_mentor.dart`)

La page affiche le profil complet (bio, secteurs, distance GPS) et propose trois actions : réserver une session, ajouter aux favoris, ouvrir un chat direct.

```dart
// Réservation bilatérale : calcule le prochain créneau Lun–Ven et écrit dans Firebase
void _bookSession() {
  final profile = UserProfileController.profile.value;
  final daysUntil = slotWeekdays[_selectedSlotIndex] - DateTime.now().weekday;
  final scheduledAt = DateTime.now().add(Duration(days: daysUntil <= 0 ? daysUntil + 7 : daysUntil));
  AgendaController.bookBilateral(
    requesterUid: AuthService.currentUid!, requesterName: profile.fullName,
    otherUid: widget.mentor.uid, otherName: widget.mentor.name,
    scheduledAt: scheduledAt,
  );
}

// Favori : incrémente/décrémente favoritesCount dans le profil
void _toggleFavorite() => UserProfileController.update(
  profile.copyWith(favoritesCount: profile.favoritesCount + (_isFavorite ? -1 : 1)));
```

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

## 11. Paiement Mobile — Wave Premium

### 11.1 Architecture simplifiée (lien marchand)

DIAPALER AFRICA intègre le paiement via **Wave**, le portefeuille mobile le plus utilisé au Sénégal. L'approche choisie utilise le **lien marchand Wave** avec paramètre de montant dynamique — aucun backend supplémentaire nécessaire.

```
Utilisateur → appuie "Payer avec Wave"
    ↓
url_launcher → ouvre https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/?amount=7500
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
| **Entrepreneur Premium** | 7 500 FCFA | Pitch épinglé, badge ⭐, demandes illimitées, stats de vues |
| **Mentor Certifié** | 5 000 FCFA | Filtres avancés pitchs, badge ✅, suivi mentorés |
| **Investisseur Vérifié** | 15 000 FCFA | Pitchs complets, alertes secteur, badge 💎 |

### 11.3 Implémentation — `ServiceWave`

**Fichier :** `lib/services/service_wave.dart`

```dart
const _waveBaseUrl = 'https://pay.wave.com/m/M_sn_tH1ZQo00ZVko/c/sn/';

enum PremiumPlan {
  entrepreneur, mentor, investisseur;

  int get amountXof => switch (this) {
    PremiumPlan.entrepreneur => 7500,
    PremiumPlan.mentor       => 5000,
    PremiumPlan.investisseur => 15000,
  };

  /// URL Wave avec montant pré-rempli
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
      throw Exception('Impossible d\'ouvrir Wave.');
    }
  }

  /// Marque l'utilisateur Premium dans Firebase ET met à jour le profil en mémoire.
  /// Le badge ⭐ apparaît instantanément sans redémarrer l'app.
  static Future<void> activatePremium(PremiumPlan plan) async {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    // 1. Persistance Firebase
    await DatabaseService.setPremium(uid: uid, plan: plan.name);
    // 2. Mise à jour immédiate en mémoire → badge visible instantanément
    final updated = UserProfileController.profile.value.copyWith(
      isPremium: true,
      premiumPlan: plan.name,
    );
    UserProfileController.update(updated); // → cache + Firebase
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
    'premiumPlan': plan,            // 'entrepreneur' | 'mentor' | 'investisseur'
    'premiumSince': ServerValue.timestamp,
  });
}
```

**Champ `isPremium` dans le modèle `UserProfile` :**
```dart
// lib/data/profil_utilisateur.dart
@immutable
class UserProfile {
  // ... autres champs ...
  final bool isPremium;     // true après activation Wave
  final String premiumPlan; // 'entrepreneur' | 'mentor' | 'investisseur' | ''
}
```

Le champ `isPremium` est sérialisé dans **Firebase** (`_toMap`/`_fromMap`) ET dans le **cache offline** (`CacheService`) — le statut Premium est donc disponible même sans connexion.

### 11.4 Interface — `WavePremiumSheet` + badge ⭐

La bottom sheet s'affiche quand l'utilisateur souhaite passer en Premium. Elle a **deux états** :

**État 1 — Avant paiement :** affiche les avantages du plan + bouton "Payer avec Wave" (bleu Wave `#1BA9FF`)

**État 2 — Après retour de Wave :** affiche un bandeau vert + bouton "Oui, j'ai payé — Activer Premium"

**Badge ⭐ sur la page profil :** dès que `isPremium = true`, un badge amber apparaît sous le nom :
```dart
// lib/screens/page_profil.dart
if (profile.isPremium) Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
  decoration: BoxDecoration(
    color: const Color(0xFFF59E0B),
    borderRadius: BorderRadius.circular(20),
  ),
  child: const Text('⭐ Premium',
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
),
```

```dart
// Ouverture de la bottom sheet depuis n'importe quel écran
await WavePremiumSheet.show(context, PremiumPlan.entrepreneur);

// Le retour est true si Premium activé, null/false sinon
```

**Flux utilisateur complet :**
1. Clique "Passer Premium" → bottom sheet s'ouvre
2. Voit les avantages + prix → clique "Payer avec Wave — 7 500 FCFA / mois"
3. L'app Wave s'ouvre avec le montant pré-rempli
4. Confirme le paiement dans Wave → revient dans DIAPALER AFRICA
5. Clique "Oui, j'ai payé — Activer Premium" → Firebase mis à jour → SnackBar vert

> **📸 CAPTURE D'ÉCRAN — Bottom sheet Premium (avantages + bouton Wave bleu)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — App Wave ouverte avec montant pré-rempli (7 500 FCFA)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Confirmation "Compte Premium activé !" (SnackBar vert)**
> *(Insérer ici la capture d'écran)*

---

## 12. Déploiement

### 12.1 Build release signé

L'application a été compilée en **APK release signé** prêt à l'installation :

```
flutter build apk --release
✓ Built build\app\outputs\flutter-apk\app-release.apk (57.9MB)
```

| Paramètre | Valeur |
|---|---|
| Type | APK release signé |
| Taille | 57.9 MB |
| Keystore | RSA 2048 bits, 10 000 jours de validité |
| Tree-shaking | MaterialIcons : −99 % (1,6 MB → 16 Ko) |

> **📸 CAPTURE D'ÉCRAN — Terminal : `✓ Built app-release.apk (57.9MB)`**
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

## Conclusion du Livrable 5

### Bilan des fonctionnalités implémentées

| Fonctionnalité (sujet) | Implémentation | Statut |
|---|---|---|
| Notifications | `NotificationService` (Firebase) + badge dynamique + centre + "Effacer tout" | ✅ |
| Recherche | Filtre textuel temps réel (nom, secteur, ville) | ✅ |
| Filtres | Pills rôle + Pills secteur (10) + Dropdown ville + Reset | ✅ |
| Géolocalisation | `getCurrentLocation()` + tri proximité + puce distance km | ✅ |
| Chatbot IA | DIALI (llama-3.1-8b-instant) + proxy Cloudflare + FAB pulsant | ✅ |
| Messagerie temps réel | Firebase WebSocket + badge global `unreadMessagesCount` | ✅ (bonus) |
| Badge messages non lus | `ValueNotifier<int>` global dans `service_navigation.dart` | ✅ (bonus) |
| Bouton "Près de moi" | GPS + tri distance + animation couleur | ✅ (bonus) |
| Membres DIAPALER réels | `UsersService.listMembers()` en tête de liste Matching | ✅ (bonus) |
| Agenda Firebase | `AgendaController.bookBilateral()` + `cancel()` bilatéral | ✅ (bonus) |
| Planning mentor | Gestion disponibilités via `InteractionsService` | ✅ (bonus) |
| Demandes de mentorat | Envoi + accepter/refuser + notification automatique | ✅ (bonus) |
| **Pitch (stepper 3 étapes)** | `PitchPage` → validation par étape + double sauvegarde (`totalSteps: 3`) + redirect Profil | ✅ (bonus) |
| **Fil de pitchs publics** | `PublicPitchesPage` → stream temps réel `DatabaseService.getPitches()` | ✅ (bonus) |
| **Dashboard Mentor** | SliverAppBar + stats + raccourcis Pitchs/Planning/Demandes | ✅ (bonus) |
| **Dashboard Investisseur** | SliverAppBar + ticket investissement + accès Pitchs + Matching | ✅ (bonus) |
| **Agenda rôle-spécifique** | Titre/description adaptés : "Mes sessions" / "Mon agenda" / "Mes rendez-vous" | ✅ (bonus) |
| **Détail mentor** | Bio Firebase réelle + pronom genre + bouton "Envoyer une demande" (Entrepreneur) | ✅ (bonus) |
| **Bouton CIS informatif** | Bottom sheet expliquant le Club des Investisseurs du Sénégal | ✅ (bonus) |
| **Partage réseaux sociaux** | `ShareService` (share_plus) — pitch, profil, conseil DIALI | ✅ (bonus) |
| **Paiement mobile Wave** | `WaveService` + lien marchand + `WavePremiumSheet` + badge ⭐ profil | ✅ (bonus) |
| **Sauvegarde MDP** | `AutofillGroup` + `finishAutofillContext` → Google/Samsung/iCloud Password Manager | ✅ (bonus) |
| **Déploiement APK signé** | `flutter build apk --release` — APK 57.9 MB disponible en téléchargement | ✅ (bonus) |

---

### Perspectives de développement

Les trois fonctionnalités avancées mentionnées dans le sujet sont toutes implémentées :

| Fonctionnalité | Statut |
|---|---|
| Partage sur réseaux sociaux | ✅ Implémenté — voir section 10 |
| Paiement mobile (Wave) | ✅ Implémenté — voir section 11 |
| Déploiement | ✅ Implémenté — voir section 12 |

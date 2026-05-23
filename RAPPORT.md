# Rapport Projet DIAPALER AFRICA

## 1. Présentation du Projet

**Nom :** DIAPALER AFRICA — Plateforme mobile de mentorat et de mise en relation entrepreneuriale  
**Domaine :** Entrepreneuriat, Mentorat, Investissement  
**Région cible :** Sénégal et Afrique de l'Ouest  

DIAPALER AFRICA est une plateforme mobile innovante conçue pour connecter les entrepreneurs, mentors et investisseurs. L'application facilite la mise en réseau, le partage d'expertise et l'accès au financement pour soutenir l'écosystème entrepreneurial africain.

### Public cible
- **Entrepreneurs** : Cherchent du mentorat et des investisseurs  
- **Mentors** : Mettent à disposition leur expertise  
- **Investisseurs** : Recherchent des opportunités d'investissement

## 2. Choix Techniques

### Architecture
- **Framework :** Flutter (Dart)
- **Backend :** Firebase (Authentication + Realtime Database)
- **Local Storage :** SharedPreferences + Cache local offline
- **Architecture UI :** MVVM avec ValueNotifier pour la gestion d'état

### Dépendances principales
```yaml
- flutter: SDK
- firebase_auth: ^5.3.4 (Authentification)
- firebase_database: ^11.1.7 (Base de données temps réel)
- image_picker: ^1.1.0 (Upload photo de profil)
- geolocator: ^11.0.0 (Géolocalisation)
- google_fonts: ^6.2.1 (Typographie)
- shared_preferences: ^2.3.0 (Persistance locale)
```

### Justification des choix
- **Flutter** : Développement cross-platform rapide (iOS + Android)
- **Firebase** : Infrastructure cloud serverless, authentification intégrée, base de données temps réel
- **SharedPreferences** : Cache local pour l'expérience offline
- **Image Picker** : Interface native pour sélectionner photos de profil

## 3. Fonctionnalités Implémentées

### Livrables 1-4 (✓ Complétés)

#### **Livrable 1 : Création du Projet Flutter**
- ✓ Projet créé et configuré
- ✓ Structure claire et maintenable (lib/screens, lib/widgets, lib/services, lib/data)
- ✓ Navigation fluide entre pages

#### **Livrable 2 : Consommation d'API REST/Firebase**
- ✓ Intégration Firebase Realtime Database
- ✓ CRUD complet (Create, Read, Update, Delete)
- ✓ Opérations asynchrones avec gestion d'erreurs

#### **Livrable 3 : Authentification**
- ✓ Page Connexion : Email + Mot de passe
- ✓ Page Inscription : Multi-étapes (4 étapes)
- ✓ Mot de passe oublié : Réinitialisation par email
- ✓ Gestion des rôles (Entrepreneur, Mentor, Investisseur)
- ✓ Redirection automatique après auth

#### **Livrable 4 : Gestion des Profils**
- ✓ Modification du profil complet
- ✓ Upload/changement photo de profil (base64)
- ✓ Sauvegarde locale et synchronisation Firebase
- ✓ Dashboards adaptés par rôle

### Fonctionnalités Avancées (✓ Implémentées)

1. **Notifications** : Système complet avec :
   - Liste des notifications en temps réel (ValueNotifier)
   - Types variés (mentor, investisseur, message, pitch, etc.)
   - Marquage comme lu et effacement groupé
   - Cloche de notification sur l'accueil avec navigation directe

2. **Chat temps réel** :
   - Messagerie via Firebase Realtime Database (StreamBuilder)
   - Historique des conversations
   - Indicateur d'envoi / heure du message
   - Bulles distinctes émetteur/destinataire

3. **Système de matching et demandes de mentorat** :
   - Demandes envoyées/reçues avec statuts (En attente, Acceptée, Refusée)
   - Formulaire de demande avec message personnalisé
   - Accepter / refuser via Firebase

4. **Planning de disponibilité** :
   - Créneaux par jour de la semaine avec Firebase
   - Activation/désactivation de chaque journée

5. **Gamification / Succès** :
   - Badges débloqués (Inscrit, 1er projet, Mentoré, Profil complet)
   - Barre de progression du profil en temps réel (complétion)

6. **Orientation DER/FJ (Sénégal)** :
   - Bottom sheet informatif sur les programmes de financement sénégalais
   - DER/FJ, PAVIE 2 : conditions, montants, documents, contacts

7. **Filtres et Recherche avancée** :
   - Matching avec filtres par secteur, ville, texte libre
   - Mentors triés par score de compatibilité
   - Réinitialisation des filtres en un clic

8. **Géolocalisation** :
   - Permission et requête de localisation
   - Formatage des coordonnées GPS
   - Support iOS/Android

9. **Dashboards Spécialisés** :
   - Dashboard Investisseur : Statistiques, secteurs, actions rapides
   - Dashboard Mentor : Sessions, mentorés, score, domaines
   - Dashboard Entrepreneur : Projets, mentors recommandés, pitch

### Pages/Écrans Créés (22 écrans)
- ✓ Splash animé (orbites DIAPALER, init Firebase en parallèle)
- ✓ Page Choix Rôle (Entrepreneur / Mentor / Investisseur)
- ✓ Page Connexion + validation temps réel
- ✓ Page Inscription multi-étapes (4 étapes : identité → localisation → intérêts → sécurité)
- ✓ Page Mot de Passe Oublié (email Firebase)
- ✓ Page Accueil (adaptive selon rôle, squelettes de chargement)
- ✓ Page Profil (gamification, complétion, coordonnées, projets)
- ✓ Page Modification Profil (photo, bio, intérêts, LinkedIn)
- ✓ Page Matching (recherche + filtres secteur/ville)
- ✓ Page Détail Mentor + Demande de mentorat
- ✓ Page Messages (liste des conversations)
- ✓ Page Chat (messagerie temps réel Firebase)
- ✓ Page Agenda / Disponibilités
- ✓ Page Planning (créneaux jour par jour)
- ✓ Page Demandes (accepter / refuser)
- ✓ Page Notifications (cloche connectée)
- ✓ Page Nouveau Projet (création avec étapes)
- ✓ Page Pitch
- ✓ Page Découverte
- ✓ Dashboard Investisseur
- ✓ Dashboard Mentor
- ✓ Page Mentors Recommandés

## 4. Captures d'écran

### Authentification
- Écran de connexion avec validation en temps réel
- Formulaire d'inscription multi-étapes avec upload photo
- Page de réinitialisation mot de passe

### Dashboards
- Dashboard spécifique pour chaque rôle
- Affichage statistiques et domaines d'expertise
- Actions rapides contextuelles

### Interface Générale
- Navigation inférieure 5 onglets (Accueil, Matching, Messages, Agenda, Profil)
- Design cohérent avec thème navy/amber/blue
- Animations fluides et transitions

## 5. Difficultés Rencontrées

### 1. Gestion des Rôles Différents
**Problème** : Formulaire d'inscription initialement générique, comportements différents par rôle.  
**Solution** : Refactorisation avec `UserRole` enum, dashboards adaptatifs (`ValueListenableBuilder`).

### 2. Upload Photo de Profil (compatibilité Web + Mobile)
**Problème** : `image_picker` retourne des types différents selon la plateforme (path vs bytes).  
**Solution** : Lecture directe en octets (`readAsBytes()`), encodage base64, stockage Firebase. Compatible Web et Android/iOS.

### 3. Navigation et État Global Réactif
**Problème** : Synchronisation du profil entre toutes les pages après modification.  
**Solution** : `ValueNotifier<UserProfile>` global (`UserProfileController`) — toutes les pages se mettent à jour automatiquement.

### 4. Architecture Offline-First
**Problème** : Firebase nécessite Internet ; l'app doit démarrer même hors-ligne.  
**Solution** : `CacheService` (SharedPreferences) charge le dernier profil connu au démarrage, la synchronisation Firebase se fait en arrière-plan.

### 5. Sécurité async avec BuildContext
**Problème** : Utilisation du `context` après des opérations async peut provoquer des crashs si le widget est démonté.  
**Solution** : Vérification systématique `if (!mounted) return;` avant toute utilisation de `context` après un `await`.

### 6. Qualité du Code
**Résultat** : `flutter analyze` retourne **0 issues** — aucun warning ni erreur sur l'ensemble des 50+ fichiers Dart.

## 6. Solutions Proposées et Déploiement

### Architecture Resiliente
- Cache local avec SharedPreferences
- Synchronisation bidirectionnelle Firebase
- Gestion des erreurs réseau avec fallback

### Configuration Play Store
1. Clé de signature générée
2. App ID : `com.diapaler.africa`
3. Version : 1.0.0 (build 1)
4. Permissions configurées :
   - Accès à la caméra (photo profil)
   - Accès à la galerie (images)
   - Accès réseau (Firebase)
   - Accès localisation (géolocalisation)
   - Accès calendrier (agenda)

### Prêt pour Production
- ✓ Tests sur émulateur Android
- ✓ Tests sur émulateur iOS (simulator)
- ✓ Gestion des permissions runtime
- ✓ Stockage sécurisé tokens Firebase
- ✓ Validation formulaires et erreurs

## 7. Conclusion

DIAPALER AFRICA est une **plateforme complète et deployable** capable de :
- ✓ Connecter trois acteurs clés de l'écosystème entrepreneurial
- ✓ Fonctionner offline et synchroniser online
- ✓ Personnaliser l'expérience selon le rôle utilisateur
- ✓ Gérer authentification, profils et données sensibles
- ✓ Offrir une UI/UX moderne et responsive

### Points Forts
1. Architecture modulaire et maintenable
2. Expérience offline-first
3. Dashboards adaptatifs par rôle
4. Gestion d'erreurs robuste
5. Conformité sécurité (Firebase Auth, permissions)

### Améliorations Futures
- Push notifications natives
- Chat temps réel avec Socket.io
- Paiement mobile (Wave, Orange Money)
- Maps intégrées pour géolocalisation
- Système de notation et reviews
- Podcast/ressources d'apprentissage
- Gamification avancée

### Livrables Remis
1. ✓ Code source complet (Flutter + Firebase)
2. ✓ APK testable (Android)
3. ✓ Architecture documentée
4. ✓ Rapport technique complet
5. ✓ Prêt Play Store et App Store

**Date de finalisation :** Mai 2026  
**Équipe :** Développement Flutter + Firebase

---

*DIAPALER AFRICA : Connecter les entrepreneures, les mentors et les investisseurs pour un écosystème africain prospère.*

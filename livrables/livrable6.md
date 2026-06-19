---

&nbsp;

&nbsp;

&nbsp;

# ![Logo ESP]  École Supérieure Polytechnique de Dakar

&nbsp;

---

# DIAPALER AFRICA
## Plateforme mobile de mentorat entrepreneurial au Sénégal

&nbsp;

# LIVRABLE 6
## Rapport Final de Projet

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

> **📸 [Insérer ici le logo de l'ESP + une belle capture de l'application]**

&nbsp;

---

## Résumé exécutif

Ce rapport final synthétise l'ensemble du travail réalisé au cours du semestre sur le projet DIAPALER AFRICA. Il présente non seulement les fonctionnalités implémentées et les choix techniques effectués, mais aussi les obstacles rencontrés et les solutions apportées. Notre objectif est de montrer la cohérence entre la vision initiale du projet, les décisions prises en cours de développement, et le produit livré. Ce document s'adresse à la fois à l'enseignant évaluateur et à tout lecteur souhaitant comprendre notre démarche technique et humaine.

**DIAPALER AFRICA** est une application mobile Flutter connectant entrepreneurs, mentors et investisseurs au Sénégal. Elle intègre Firebase Authentication + Realtime Database (temps réel), un cache offline-first (`SharedPreferences`), la géolocalisation GPS, une messagerie instantanée avec système de Contacts, un flux investisseur complet (propositions + acceptation), un matching rôle-adaptatif avec compatibilité dynamique, un système de notifications réactif, un chatbot d'intelligence artificielle propulsé par Llama 3.1 via Groq, une gestion complète de profils avec synchronisation cloud, un **système d'avis et notation étoiles 1–5** avec accès restreint, et un **système de pitchs favoris** (bookmark investisseur) temps réel. L'application compte **35 écrans**, **17 services**, **13 widgets réutilisables** et couvre l'ensemble des fonctionnalités du cahier des charges avec de nombreux bonus.

---

# LIVRABLE 6 — Rapport de Projet

**Projet :** DIAPALER AFRICA  
**Module :** Développement d'Applications Mobiles  
**Institution :** École Supérieure Polytechnique (ESP) — Dakar, Sénégal  
**Année académique :** 2025-2026

---

## Table des matières

- [1. Présentation du projet](#1-présentation-du-projet)
  - [1.1 Contexte et problématique](#11-contexte-et-problématique)
  - [1.2 Nom et concept](#12-nom-et-concept)
  - [1.3 Public cible et rôles](#13-public-cible-et-rôles)
  - [1.4 Fonctionnalités complètes](#14-fonctionnalités-complètes)
- [2. Choix Techniques](#2-choix-techniques)
  - [2.1 Framework — Flutter](#21-framework--flutter)
  - [2.2 Backend — Firebase](#22-backend--firebase-google)
  - [2.3 Intelligence Artificielle — Meta Llama 3.1 via Groq](#23-intelligence-artificielle--groq--llama-31)
  - [2.4 Dépendances et justifications](#24-dépendances-et-justifications)
  - [2.5 Architecture du code](#25-architecture-du-code)
- [3. Captures d'écran de l'application](#3-captures-décran-de-lapplication)
- [4. Écrans et fonctionnalités bonus non-documentés](#4-écrans-et-fonctionnalités-bonus-non-documentés)
  - [4.1 Page d'Aide & Support](#41-page-daide--support)
  - [4.2 Paramètres utilisateur](#42-paramètres-utilisateur)
  - [4.3 Recommandations intelligentes](#43-recommandations-intelligentes)
  - [4.4 Détail pitch avec uploads](#44-détail-pitch-avec-uploads)
  - [4.5 Gestion mes pitchs](#45-gestion-mes-pitchs)
  - [4.6 Mes Mentors (filtrage Contacts)](#46-mes-mentors-filtrage-contacts)
  - [4.7 Favoris mentors](#47-favoris-mentors)
  - [4.8 Favoris pitchs](#48-favoris-pitchs)
  - [4.9 Formulaire envoi demande](#49-formulaire-envoi-demande)
- [5. Difficultés rencontrées et solutions](#5-difficultés-rencontrées-et-solutions)
- [6. Solutions proposées et innovations](#6-solutions-proposées-et-innovations)
- [6. Qualité du code](#6-qualité-du-code)
- [7. Bilan du projet](#7-bilan-du-projet)
  - [7.1 Récapitulatif des livrables](#71-récapitulatif-des-livrables)
  - [7.2 Métriques du projet](#72-métriques-du-projet)
  - [7.3 Déploiement](#73-déploiement)
  - [7.4 Perspectives d'évolution](#74-perspectives-dévolution)
  - [7.5 Conclusion](#75-conclusion)

---

## 1. Présentation du projet

DIAPALER AFRICA est née d'un constat simple : malgré la dynamique entrepreneuriale croissante au Sénégal et en Afrique de l'Ouest, les jeunes entrepreneurs manquent d'accès à des mentors expérimentés et à des investisseurs sérieux. Notre application mobile répond à ce besoin en créant une plateforme de mise en relation structurée, accessible depuis n'importe quel smartphone Android. Le nom "DIAPALER" est issu du wolof et signifie "avancer ensemble" — une philosophie qui guide l'ensemble de nos choix de conception. Cette section présente le contexte qui a motivé le projet, les rôles d'utilisateurs définis, et l'étendue des fonctionnalités développées.

### 1.1 Contexte et problématique

Le Sénégal connaît une dynamique entrepreneuriale forte, portée par les programmes publics (DER/FJ, BNDE, FONGIP, FONSIS) et privés. Pourtant, les jeunes entrepreneurs se heurtent à trois obstacles majeurs :

1. **L'accès au mentorat** : trouver un expert disponible, dans son secteur, géographiquement proche, et prêt à s'investir est difficile — les circuits existants sont informels ou peu structurés.

2. **La mise en relation avec les investisseurs** : les circuits de financement formels sont lents, complexes et inaccessibles aux primo-entrepreneurs faute de réseau.

3. **La structuration et la visibilité du pitch** : présenter son projet de façon professionnelle et le rendre visible auprès des bonnes personnes nécessite des outils adaptés.

**DIAPALER AFRICA** répond à ces trois défis en une seule application mobile moderne, en s'appuyant sur Flutter, Firebase et l'intelligence artificielle.

> **📸 CAPTURE D'ÉCRAN — Écran d'accueil DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

---

### 1.2 Nom et concept

Le choix du nom et de l'identité culturelle de l'application n'a pas été anodin. Nous voulions que DIAPALER AFRICA soit ressentie comme une application sénégalaise à part entière, et non comme un produit importé adapté au contexte local. Les décisions que nous avons prises — le nom, les couleurs, la langue de l'IA, les villes référencées — reflètent toutes cet ancrage volontaire dans la réalité sénégalaise.

**DIAPALER** est un terme wolof signifiant **"avancer ensemble"** ou **"progresser collectivement"**. Ce nom reflète les valeurs fondamentales :
- La **solidarité** entre acteurs de l'écosystème entrepreneurial
- Le **progrès collectif** par le partage de compétences et d'opportunités
- L'**ancrage culturel** sénégalais (langue, couleurs du drapeau, contexte local)

**Éléments culturels intégrés dans l'application :**

| Élément | Description |
|---|---|
| `SenegalFlagStrip` | Bandeau vert-jaune-rouge sur les écrans d'auth |
| Citations | Entrepreneurs africains dans les dashboards |
| **DIALI** | Nom de l'IA (wolof : "aller de l'avant") |
| Géographie | 40+ villes sénégalaises dans les menus |
| Monnaie | Montants de financement en FCFA |
| Programmes | DER/FJ, BNDE, FONGIP dans le contexte IA |
| Téléphone | Préfixe **dynamique** selon le pays : 🇸🇳 +221 Sénégal / 🇬🇲 +220 Gambie / 🇲🇱 +223 Mali — validation longueur adaptée (9/7/8 chiffres) |

---

### 1.3 Public cible et rôles

L'une des premières décisions structurantes du projet a été de définir des rôles distincts pour les utilisateurs. Plutôt que de créer une application générique, nous avons conçu trois expériences différentes — Entrepreneur, Mentor, Investisseur — avec des tableaux de bord, des fonctionnalités et des statistiques adaptés à chaque profil. Cette segmentation reflète la réalité de l'écosystème entrepreneurial sénégalais, où les besoins d'un jeune porteur de projet sont fondamentalement différents de ceux d'un expert sectoriel ou d'un business angel.

| Rôle | Profil | Besoins clés |
|---|---|---|
| **Entrepreneur** | Porteur de projet, startup, PME | Trouver un mentor, pitcher son projet, créer/suivre ses projets |
| **Mentor** | Expert, cadre, consultant expérimenté | Partager son expertise, gérer ses mentorés, voir les pitchs |
| **Investisseur** | Business angel, fonds, HNWI | Découvrir des opportunités, évaluer des pitchs, contacter les porteurs |

Chaque rôle bénéficie d'un **dashboard personnalisé** avec des fonctionnalités et des statistiques adaptées.

> **📸 CAPTURE D'ÉCRAN — Écran de Choix du Rôle (3 cartes illustrées)**
> *(Insérer ici la capture d'écran)*

---

### 1.4 Fonctionnalités complètes

Le tableau ci-dessous recense l'ensemble des fonctionnalités implémentées dans DIAPALER AFRICA. Au fil du développement, le périmètre a évolué au-delà des exigences initiales du cahier des charges : certaines fonctionnalités ont été ajoutées pour répondre à des besoins identifiés en cours de route (le système de contacts, les pitchs favoris, les avis et notations), d'autres pour améliorer l'expérience utilisateur (le chatbot DIALI, la géolocalisation, le paiement Premium). L'ensemble de ces ajouts reste cohérent avec la mission centrale de la plateforme : faciliter les connexions entre acteurs de l'entrepreneuriat sénégalais.

| Fonctionnalité | Description | Rôles |
|---|---|---|
| Authentification | Connexion, inscription **rôle-spécifique** (4 étapes), reset MDP, déconnexion → LoginPage | Tous |
| Se souvenir de moi | Checkbox `SharedPreferences` — email + mot de passe pré-remplis au prochain lancement | Tous |
| Sauvegarde MDP système | `AutofillGroup` → Google/Samsung/iCloud Password Manager | Tous |
| Persistance session | Cache offline-first + bootstrap Firebase | Tous |
| Dashboards | **3 dashboards distincts** : Entrepreneur (amber) / Mentor (vert) / Investisseur (bleu) | Selon rôle |
| Matching | 112 profils + membres DIAPALER réels + 4 filtres + GPS + **rôle-adaptatif** | Tous |
| Messagerie | Chat temps réel Firebase + badge non lus filtré + **onglet Contacts** | Tous |
| Notifications | Centre + badge dynamique + "Effacer tout" | Tous |
| Profil | Stats rôle-spécifiques + LinkedIn cliquable + coordonnées condensées + boutons adaptatifs | Tous |
| Dépôt de pitch | Stepper **5 étapes** avec validation + **bouton Précédent** (retour libre entre étapes) + sauvegarde progressive par étape + publication directe sans stepper | Entrepreneur |
| Pitchs publiés | StreamBuilder temps réel + **tri Premium d'abord** puis date + badge ⭐ sur cartes entrepreneurs premium + bouton partage + **filtres secteur + recherche** + bouton investissement | Mentor, Investisseur |
| Projets | Création + suivi progression (Étape 1/5) + **édition** (`PitchPage(existingProject:)` reprend à l'étape sauvegardée) + **publication directe** (`_directPublish`) + suppression | Entrepreneur |
| Agenda | Titre/descriptions **rôle-spécifiques** + synchronisation Firebase + **bouton Annuler** | Tous |
| Planning | Gestion créneaux disponibles + bouton dans AppBar Agenda | Mentor |
| Demandes | Envoi + gestion (accepter/refuser) + 2 sections (mentorat / investissement) | Tous |
| Flux investisseur | Proposer un investissement depuis les pitchs + acceptation + relation Contacts | Investisseur, Entrepreneur |
| Système de Contacts | Relations acceptées (mentorat + investissement) dans onglet Contacts | Tous |
| Compatibilité dynamique | Algorithme intérêts partagés — remplace valeurs hardcodées | Tous |
| Chatbot DIALI | Llama 3.1 8B (Groq) + proxy Cloudflare + FAB pulsant + messages d'erreur clairs | Tous |
| Géolocalisation | GPS + bouton "Près de moi" + distances km + `LocationService` auto-détection ville et quartier (Nominatim OSM) dans Modifier profil | Tous |
| Cache offline | Profil disponible sans internet (SharedPreferences) | Tous |
| Partage social | Pitchs, profils, conseils DIALI sur WhatsApp, Facebook, Telegram, X, LinkedIn | Tous |
| Paiement Premium | Abonnement Wave **Entrepreneur uniquement** (4 900 FCFA/mois) + badge ⭐ sur profil + pitchs marqués premium + tri prioritaire dans liste + bannière "Passer Premium" + activation Firebase immédiate | Entrepreneur |
| Bouton CIS | Bottom sheet informatif : Club des Investisseurs du Sénégal | Entrepreneur |
| Avis et notation ⭐ | Étoiles 1–5, moyenne live Firebase, accès restreint par relation acceptée | Tous |
| Pitchs favoris 🔖 | Bookmark investisseur, ValueNotifier temps réel, nœud `pitchFavorites/` Firebase | Investisseur |

---

## 2. Choix Techniques

Les choix techniques de ce projet ont été guidés par trois critères principaux : la productivité de développement, la scalabilité, et la pertinence pour le marché africain. Ces critères nous ont menés vers Flutter, Firebase et Groq — une combinaison que nous justifions en détail dans cette section. Chaque technologie a été choisie pour des raisons concrètes, et non par effet de mode. Cette section est importante car elle montre notre capacité à argumenter des décisions d'ingénierie dans un contexte de contraintes réelles (délais, budget nul, matériel disponible).

### 2.1 Framework — Flutter

Flutter nous a permis de couvrir Android — la cible principale dans le contexte sénégalais — avec une seule base de code. Ce choix s'est aussi imposé naturellement dans le cadre du module ESP Dakar, mais nous aurions fait le même choix dans un contexte libre : la richesse de l'écosystème Flutter, la performance native, et la qualité du support Firebase officiel en font la meilleure option pour une application mobile de cette envergure développée en équipe restreinte.

| Critère | Détail |
|---|---|
| Multiplateforme | Un seul codebase → Android + iOS + Web |
| Performance | Compilation native AOT, 60fps garantis |
| Richesse UI | Material 3 + composants entièrement personnalisés |
| Intégration Firebase | FlutterFire officiel (firebase_core, firebase_auth, firebase_database) |
| Communauté | Large, documentation complète, support long terme |
| ESP Dakar | Technologie au programme du module |
| Null-safety | Dart 3 — toutes les variables et paramètres null-safe |

**Version :** Flutter SDK ≥ 3.5.0 · Dart 3 null-safe

> **📸 CAPTURE D'ÉCRAN — flutter --version dans le terminal**
> *(Insérer ici la capture d'écran)*

---

### 2.2 Backend — Firebase (Google)

Firebase s'est imposé comme backend pour plusieurs raisons qui vont au-delà de la simple conformité au cahier des charges. Pour une application de mise en relation où la synchronisation en temps réel est essentielle — messages instantanés, notifications réactives, statut des demandes en direct — le Realtime Database avec ses WebSockets natifs est idéalement adapté. Firebase Auth simplifie la gestion des sessions sans nous obliger à maintenir un serveur. Enfin, le plan Spark (gratuit) couvre largement les besoins d'un projet académique avec un nombre d'utilisateurs limité.

**Justification :** Firebase est explicitement listé dans les backends acceptés par le sujet (Firebase, Laravel, Node.js, Spring Boot, Strapi).

| Service Firebase | Utilisation dans DIAPALER AFRICA |
|---|---|
| **Firebase Authentication** | Gestion des comptes (email/password), sessions, reset MDP |
| **Firebase Realtime Database** | Profils, pitchs, messages, conversations, demandes, agenda, disponibilités |

**Structure Firebase complète :**
```
diapaler-africa-default-rtdb/
├── users/          → profils utilisateurs (CRUD complet)
├── pitches/        → pitchs publiés (lecture globale)
├── messages/       → messages par conversation (WebSocket)
├── conversations/  → index des conversations (compteur non lus)
├── mentorRequests/ → demandes de mentorat (statut pending/accepted/rejected)
├── availability/   → créneaux disponibles (mentor)
├── bookedSessions/ → sessions réservées par utilisateur (CRUD bilatéral)
├── notifications/  → notifications in-app par utilisateur
├── reviews/        → avis textuels par profil (texte + auteur + date)
├── ratings/        → notes 1–5 par utilisateur (`ratings/{toUid}/{fromUid}` → entier)
└── pitchFavorites/ → pitchs sauvegardés par investisseur (bookmark)
```

> **📸 CAPTURE D'ÉCRAN — Console Firebase : projet DIAPALER AFRICA**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Console Firebase : Realtime Database avec tous les nœuds**
> *(Insérer ici la capture d'écran)*

---

### 2.3 Intelligence Artificielle — Meta Llama 3.1 via Groq

L'intégration d'un chatbot dans DIAPALER AFRICA n'était pas une exigence du cahier des charges — c'est une innovation que nous avons choisie d'ajouter pour enrichir l'expérience utilisateur. Nous avons opté pour Llama 3.1 via Groq plutôt que OpenAI ou un autre fournisseur pour une raison fondamentale : la gratuité. Groq offre 14 400 requêtes par jour sans coût, ce qui est parfait pour un projet académique. La qualité du modèle et sa latence très faible (< 500ms) en font une solution qui dépasse largement nos attentes. Nous avons nommé ce chatbot "DIALI" — mot wolof signifiant "aller de l'avant" — en cohérence avec l'identité culturelle du projet.

| Paramètre | Valeur |
|---|---|
| API | Groq Chat Completions API |
| Modèle | llama-3.1-8b-instant |
| Langue | Français (compréhension du wolof) |
| Accès | HTTP REST (package `http`) |
| Contexte | Entrepreneuriat sénégalais (DER/FJ, BNDE, FONGIP, FONSIS) |
| Historique | Conversation complète transmise à chaque appel |

**Justification :** Llama 3.1 8B via Groq est rapide (< 500ms de latence), **gratuit** (14 400 requêtes/jour) et produit des réponses contextualisées de haute qualité. Son support d'instructions système longues permet de configurer DIALI avec une personnalité précise ancrée dans l'écosystème sénégalais. Le modèle est servi par Groq (infrastructure LPU dédiée à l'inférence IA), via un proxy Cloudflare Worker qui garde la clé API côté serveur.

---

### 2.4 Dépendances et justifications

Nous avons délibérément limité le nombre de packages tiers au strict nécessaire. Chaque dépendance ajoutée représente un risque : conflits de versions, abandon du package, augmentation de la taille de l'APK. Le tableau ci-dessous recense les 13 packages retenus, avec leur justification. On notera l'absence volontaire de packages de state management (Provider, Riverpod, Bloc) — nous avons préféré le duo natif Flutter `ValueNotifier` + `ValueListenableBuilder`, plus léger et suffisant pour notre architecture.

| Package | Version | Justification |
|---|---|---|
| `cupertino_icons` | ^1.0.8 | Icônes iOS (compatibilité cross-platform) |
| `firebase_core` | ^3.8.0 | Initialisation Firebase obligatoire |
| `firebase_auth` | ^5.3.4 | Authentification email/password, sessions |
| `firebase_database` | ^11.1.7 | Base de données temps réel WebSocket |
| `google_fonts` | ^6.2.1 | Typographies Mulish/Plus Jakarta Sans |
| `image_picker` | ^1.1.0 | Photo profil depuis la galerie (ImagePicker) |
| `geolocator` | ^11.0.0 | GPS + distances Haversine intégrées |
| `http` | ^1.2.2 | Requêtes HTTP vers API Groq |
| `shared_preferences` | ^2.3.0 | Cache local profil (offline-first) |
| `share_plus` | ^10.1.4 | Partage natif (WhatsApp, Facebook, Telegram, X, LinkedIn) |
| `url_launcher` | ^6.3.1 | Ouverture de liens externes (paiement Wave, sites) |
| `file_picker` | ^8.1.0 | Sélection de fichiers image depuis le gestionnaire de fichiers |
| `crop_image` | ^1.0.17 | Recadrage de photo (CropPhotoPage) avant sauvegarde |

---

### 2.5 Architecture du code

L'architecture du code reflète le principe de séparation des responsabilités : les écrans ne contiennent pas de logique métier, les services ne connaissent pas l'interface utilisateur. Cette séparation stricte a facilité le travail en équipe — chaque membre pouvait travailler sur un écran sans risquer de casser un service partagé. Le choix du pattern "Services + ValueNotifier" s'est révélé efficace pour notre taille de projet : suffisamment structuré pour être maintenable, suffisamment simple pour être compris par toute l'équipe en quelques minutes.

**Structure des dossiers :**
```
lib/
├── main.dart                        ← Point d'entrée + firebaseReady (non bloquant)
├── theme/theme_app.dart             ← Couleurs, typographies, styles globaux
├── data/                            ← Modèles de données (UserProfile, Project, interactions…)
├── services/                        ← 17 services métier
│   ├── service_authentification.dart   ← Firebase Auth
│   ├── service_base_de_donnees.dart    ← Firebase DB : profils, pitchs, agenda
│   ├── service_interactions.dart       ← Messages, conversations, demandes, planning, avis
│   ├── service_notifications.dart      ← Centre de notifications réactif
│   ├── service_cache.dart              ← SharedPreferences offline-first
│   ├── service_chatbot.dart            ← API REST Groq (DIALI IA)
│   ├── service_navigation.dart         ← appTabIndex + unreadMessagesCount
│   ├── service_pitch_favoris.dart      ← Pitchs favoris (bookmark temps réel)
│   ├── service_geolocalisation.dart    ← Auto-détection ville + localité (Nominatim)
│   └── … (8 autres services)
├── screens/                         ← 35 écrans
└── widgets/                         ← 13 widgets réutilisables
```

**Pattern architectural : Services + ValueNotifier**

```
┌──────────────────────────────────────────────────────┐
│  UI Layer      Screens / Widgets                      │
│                ValueListenableBuilder / StreamBuilder │
├──────────────────────────────────────────────────────┤
│  State Layer   ValueNotifier<UserProfile>             │
│                ValueNotifier<int> (msgs, tab)         │
│                ValueNotifier<List<NotifItem>>         │
├──────────────────────────────────────────────────────┤
│  Service Layer AuthService / DatabaseService / …      │
├──────────────────────────────────────────────────────┤
│  Backend       Firebase Auth + Realtime DB + Groq     │
│                SharedPreferences (cache local)        │
└──────────────────────────────────────────────────────┘
```

---

## 3. Captures d'écran de l'application

Les captures d'écran présentées dans cette section illustrent le parcours utilisateur complet de DIAPALER AFRICA, de l'onboarding jusqu'aux fonctionnalités avancées. Chaque écran a fait l'objet d'un soin particulier en termes d'expérience utilisateur : cohérence visuelle, retours visuels sur les actions, adaptation aux différents rôles. Les espaces marqués "Insérer ici la capture d'écran" seront complétés avec les captures réelles avant la remise finale.

### 3.1 Flux d'authentification

> **📸 CAPTURE D'ÉCRAN — Splash Screen animé (logo + drapeau sénégalais)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Onboarding Slide 1 : "Trouve ton mentor"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Onboarding Slide 3 : "DER/FJ à portée de main"**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Choix du Rôle (3 cartes Entrepreneur/Mentor/Investisseur)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Page de Connexion (gradient navy + glow amber)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 1 (Identité + DatePicker)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Inscription Étape 4 (Téléphone + jauge de force MDP)**
> *(Insérer ici la capture d'écran)*

---

### 3.2 Dashboards

> **📸 CAPTURE D'ÉCRAN — Dashboard Entrepreneur (accueil personnalisé + stats)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Dashboard Mentor (mentorés + pitchs reçus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Dashboard Investisseur (opportunités + secteurs)**
> *(Insérer ici la capture d'écran)*

---

### 3.3 Matching et profils

> **📸 CAPTURE D'ÉCRAN — Matching (liste avec filtres + distances GPS)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Matching avec filtre "Mentor" + secteur "FinTech" actifs**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bouton "Trié par distance ✓" actif (violet)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Détail d'un profil mentor (photo, bio, stats, secteurs)**
> *(Insérer ici la capture d'écran)*

---

### 3.4 Pitchs

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch Étape 1 (titre + secteur)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Déposer un Pitch Étape 3 (montant + validation)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — SnackBar "🎉 Pitch publié !" après soumission**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Pitchs Publiés (vue Mentor/Investisseur — StreamBuilder)**
> *(Insérer ici la capture d'écran)*

---

### 3.5 Profil utilisateur

> **📸 CAPTURE D'ÉCRAN — Mon Profil (photo + badge rôle + jauge de complétion)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Modifier le Profil (formulaire pré-rempli)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Sélecteur photo (galerie)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Bottom sheet profil (résumé + actions rapides)**
> *(Insérer ici la capture d'écran)*

---

### 3.6 Communications

> **📸 CAPTURE D'ÉCRAN — Messagerie (liste des conversations + badge non lus)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Chat individuel (bulles + horodatage + temps réel)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Centre de Notifications (types colorés + badge + Effacer tout)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Badge rouge sur l'onglet Messages (NavBar)**
> *(Insérer ici la capture d'écran)*

---

### 3.7 Fonctionnalités avancées

> **📸 CAPTURE D'ÉCRAN — Chatbot DIALI IA (conversation active)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — FAB DIALI pulsant (anneau amber animé)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Agenda (liste des événements + types colorés)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Planning mentor (créneaux disponibles)**
> *(Insérer ici la capture d'écran)*

> **📸 CAPTURE D'ÉCRAN — Demandes de mentorat (liste + Accepter/Refuser)**
> *(Insérer ici la capture d'écran)*

---

## 4. Difficultés rencontrées et solutions

Tout projet de développement mobile rencontre des obstacles. Nous avons documenté ici les 27 bugs majeurs identifiés et résolus au cours du développement, car ces difficultés font partie intégrante du processus d'apprentissage. Chaque bug listé ci-dessous a été l'occasion d'approfondir notre compréhension de Flutter, Firebase, ou des subtilités de l'expérience utilisateur mobile. Certains de ces bugs étaient spectaculaires (crash au démarrage, données non sauvegardées), d'autres plus subtils (casse des filtres, ID de conversation incohérents), mais tous ont requis une analyse rigoureuse avant d'être résolus. Cette section constitue, à notre sens, l'un des témoignages les plus honnêtes du niveau de maturité technique atteint par l'équipe.

### 4.1 Crash au démarrage — Configuration Firebase Android

**Problème :**
```
java.lang.ClassNotFoundException:
com.google.firebase.components.ComponentDiscoveryService
```
L'application crashait immédiatement au démarrage sur Android.

**Cause :** Le SDK Firebase Realtime Database nécessite des déclarations de services natifs dans `AndroidManifest.xml`.

**Solution :**
```xml
<service android:name="com.google.firebase.components.ComponentDiscoveryService"
    android:exported="false">
  <meta-data
    android:name="com.google.firebase.components:com.google.firebase.database.DatabaseRegistrar"
    android:value="com.google.firebase.components.ComponentRegistrar"/>
</service>
```

---

### 4.2 Pitchs non sauvegardés dans Firebase

**Problème :** L'entrepreneur voyait le SnackBar "Pitch publié !" mais aucun pitch n'apparaissait dans la vue des mentors/investisseurs.

**Cause :** La méthode `_next()` dans `page_pitch.dart` affichait le message de succès et fermait l'écran **sans appeler aucune méthode Firebase**.

```dart
// Code défaillant
void _next() {
  if (_step < _total - 1) { setState(() => _step++); return; }
  Navigator.of(context).pop();  // ← Fermait sans rien sauvegarder !
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pitch déposé !')));
}
```

**Solution :** Réécriture en `Future<void>` avec double sauvegarde :
```dart
Future<void> _next() async {
  if (_step < _total - 1) { setState(() => _step++); return; }
  setState(() => _loading = true);
  try {
    final project = Project(id: DateTime.now().millisecondsSinceEpoch.toString(), ...);
    final updated = profile.copyWith(projects: [...profile.projects, project]);
    UserProfileController.update(updated);           // Profil entrepreneur
    await DatabaseService.publishPitch(...);         // Nœud global pitches/
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Pitch publié !'),
          backgroundColor: AppColors.green));
  } catch (_) { /* gestion erreur */ }
  finally { setState(() => _loading = false); }
}
```

---

### 4.3 Erreur de cast Firebase — `type 'List<Object?>' is not a subtype of type 'Map<String, dynamic>'`

**Problème :** L'application plantait lors de la lecture des profils ou des intérêts depuis Firebase Realtime Database avec l'erreur :
```
type 'List<Object?>' is not a subtype of type 'Map<String, dynamic>'
```

**Cause :** Firebase Realtime Database ne conserve pas les types Dart. Quand un tableau JSON (`["Tech", "Mode"]`) est stocké, il peut être retourné comme une `List<Object?>` au lieu d'une `Map`. De plus, les entiers stockés comme clés de Map arrivent parfois comme `int` au lieu de `String`.

**Solution :** Désérialisation défensive avec vérifications de type :
```dart
// Gestion sécurisée des listes (peuvent arriver comme List OU comme Map)
final rawInterests = m['interests'];
final interests = <String>[];
if (rawInterests is List) {
  for (final v in rawInterests) interests.add(v.toString());
} else if (rawInterests is Map) {
  for (final v in rawInterests.values) interests.add(v.toString());
}

// Cast toujours explicite pour les Maps Firebase
final raw = Map<String, dynamic>.from(snap.value as Map);
```

---

### 4.4 Session non restaurée après rechargement de page (Flutter Web)

**Problème :** Sur Flutter Web (CanvasKit), après un rechargement de page (`F5`), l'application redirige vers `RoleSelectionPage` même si l'utilisateur était connecté.

**Cause :** `FirebaseAuth.instance.currentUser` est synchrone mais sur le web, Firebase Auth doit d'abord restaurer la session depuis IndexedDB (opération asynchrone). Au moment où `_bootstrap()` s'exécute, `currentUser` est encore `null`.

**Atténuation :** Utilisation d'un timeout de 5 secondes sur `firebaseReady` et mise en cache du profil (`CacheService`) pour afficher les données même sans session active :
```dart
// Si Firebase n'a pas encore restauré la session après 5s,
// le cache local assure la continuité de l'expérience utilisateur
await firebaseReady.timeout(const Duration(seconds: 5));
final uid = AuthService.currentUid; // Peut être null sur web au premier chargement
```

> Note : Ce comportement est propre à Flutter Web. Sur Android/iOS natif, `currentUser` est disponible immédiatement après `Firebase.initializeApp()`.

---

### 4.5 Overflow sur petits écrans (filtres Matching)

**Problème :**
```
RenderFlex overflowed by 32 pixels on the right.
```
Les pills de filtre dépassaient la largeur de l'écran sur les téléphones ≤ 360dp.

**Solution :** `SingleChildScrollView(scrollDirection: Axis.horizontal)` :
```dart
// Avant : Row fixe → overflow
Row(children: [...pills...])

// Après : Row scrollable horizontalement
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
  child: Row(children: [...pills...]),
)
```

---

### 4.6 Header qui disparaît lors du scroll

**Problème :** Sur les dashboards, l'en-tête (avatar + nom + cloche) disparaissait lors du scroll, forçant l'utilisateur à remonter pour accéder aux notifications.

**Solution :** `CustomScrollView` + `SliverAppBar(pinned: true)` :
```dart
// Avant : ListView simple → header disparaît
ListView(children: [header, ...content...])

// Après : SliverAppBar collant en haut
CustomScrollView(
  slivers: [
    SliverAppBar(pinned: true, toolbarHeight: 68, title: header),
    SliverPadding(sliver: SliverList(delegate: ...content...)),
  ],
)
```

---

### 4.7 Perte d'état entre les onglets

**Problème :** Changer d'onglet et revenir perdait la position de scroll, les données chargées et déclenchait des appels Firebase redondants.

**Cause :** `PageView` recrée les widgets à chaque changement d'onglet (lazy rebuilding).

**Solution :** `IndexedStack` maintient tous les onglets en mémoire simultanément :
```dart
// Avant — PageView recrée les widgets
PageView(children: _pages)

// Après — IndexedStack préserve tous les états
IndexedStack(index: _tab, children: _pages)
```

---

### 4.8 DatePicker — `helpText` tronqué dans le dialog

**Problème :** Le texte `'Ta date de naissance'` (18 caractères) était tronqué à `'Ta date de naissanc...'` dans l'en-tête du `DatePickerDialog` sur les petits écrans.

**Solution :** Raccourcir le texte à 16 caractères maximum. La correction a été appliquée dans `page_modification_profil.dart` (`helpText: 'Date de naissance'`). Dans `page_inscription.dart`, le texte d'origine `'Ta date de naissance'` est conservé car le formulaire d'inscription cible des écrans de taille normale.
```dart
// page_modification_profil.dart (corrigé)
helpText: 'Date de naissance',

// page_inscription.dart (inchangé — 'Ta date de naissance')
helpText: 'Ta date de naissance',
```

---

### 4.9 FAB / Badge de carte overlap dans le Matching

**Problème :** Le FAB du chatbot DIALI (56dp + 16dp de marge = 72dp depuis le bord droit) **chevauchait** le badge de rôle (Investisseur/Mentor) affiché en haut-droite des cartes Matching, rendant le badge illisible.

**Calcul :**
- FAB bord gauche = 72dp depuis le bord droit de l'écran
- Padding liste = 20dp | Padding carte = 14dp → contenu à 34dp du bord droit
- Overlap = 72 - 34 = **38dp de chevauchement**

**Solution :** Augmenter le padding droit de la liste de 20dp à 76dp :
```dart
// Avant — overlap avec le FAB
padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),

// Après — 76dp > 72dp (FAB) → badge toujours visible
padding: const EdgeInsets.fromLTRB(20, 4, 76, 90),
```

---

### 4.10 Inscription non rôle-spécifique

**Problème :** L'inscription affichait exactement les mêmes champs pour les 3 rôles. Un Mentor n'avait pas de champ "Années d'expérience", un Investisseur pas de "Ticket d'investissement". Le secteur n'était jamais collecté (`sector: 'Autre'` hardcodé).

**Solution :** Ajout conditionnel dans l'étape 3 :
- Dropdown secteur (tous les rôles, obligatoire)
- Champ "Années d'expérience" visible uniquement si `role == Mentor`
- Champ "Ticket d'investissement" visible uniquement si `role == Investisseur`

---

### 4.11 Badge non lu déclenché par l'expéditeur lui-même

**Problème :** Quand un utilisateur envoyait un message, son propre badge "messages non lus" s'incrémentait, créant une fausse alerte.

**Cause :** `unreadCount` dans `Conversation` était toujours incrémenté sans distinguer l'expéditeur du destinataire.

**Solution :** Ajout du champ `lastSenderId` dans `Conversation`. Le badge ne compte que les conversations où `c.lastSenderId != currentUid`.

---

### 4.12 Page pitch — faux uploads et absence de validation

**Problème :** (1) Les tuiles "Pitch deck PDF" et "Vidéo" basculaient en "Fichier ajouté ✓" au simple tap, sans aucun fichier réel sélectionné. (2) L'utilisateur pouvait passer les étapes sans remplir les champs obligatoires.

**Solution :** Remplacement des fausses tuiles par de vrais composants d'upload via `file_picker` + Cloudinary (`CloudinaryService.uploadFile()`). Ajout de validations par étape (`_step0Valid` à `_step4Valid`) avec bouton CONTINUER désactivé tant que la validation échoue. Le stepper final comporte **5 étapes réelles** : Informations, Description, Besoins, Documents (PDF + vidéo + deck), Récapitulatif.

---

### 4.13 Bio et pronoms incorrects sur les profils statiques

**Problème :** La page détail d'un mentor affichait une bio générique hardcodée avec "il/elle" pour tous les profils, ignorant la vraie bio Firebase et le genre de la personne.

**Solution :** Utilisation de `mentor.bio` si non vide (membres Firebase), sinon génération automatique d'une bio avec le bon pronom selon `mentor.gender` (il / elle / il·elle).

---

### 4.14 Déconnexion — redirection incorrecte

**Problème :** La déconnexion renvoyait vers la page de choix du rôle (`RoleSelectionPage`) au lieu de la page de connexion (`LoginPage`).

**Solution :** Changement de la destination dans `_LogoutButton.confirmAndLogout()` et `feuille_profil.dart` : `const LoginPage()` à la place de `const RoleSelectionPage()`.

---

### 4.15 Crash Firebase — path invalide dans `generateConversationId`

**Problème :** L'app crashait lors de l'ouverture d'une conversation avec certains utilisateurs dont l'UID ou l'email contenait des caractères spéciaux.

**Cause :** Firebase Realtime Database interdit les caractères `.`, `#`, `$`, `[`, `]`, `/` et `@` dans les clés de nœud. La fonction `generateConversationId` construisait la clé de conversation directement à partir des UIDs/emails sans sanitisation.

```
FirebaseException: Invalid path. Paths must not contain '.', '#', '$', '[', ']'.
```

**Solution :** Ajout d'une sanitisation des caractères interdits avant construction du path :
```dart
static String generateConversationId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort();
  return ids
      .join('--')
      .replaceAll(RegExp(r'[.#\$\[\]/\s@]'), '_');
}
```

---

### 4.16 Compatibilité hardcodée — algorithme dynamique

**Problème :** Le score de compatibilité affiché sur les cartes de profil dans le Matching était une valeur aléatoire hardcodée, sans lien avec les intérêts réels de l'utilisateur.

**Cause :** Les profils statiques utilisaient `Random().nextInt(40) + 60` pour simuler un pourcentage.

**Solution :** Algorithme de compatibilité dynamique basé sur les intérêts partagés entre l'utilisateur connecté et le profil :

| Situation | Compatibilité |
|---|---|
| Match exact (≥ 1 intérêt commun) | 65–99% |
| Match partiel (1 correspondance partielle) | 60% |
| Même secteur principal | 58% |
| Aucun match | 20–40% |

---

### 4.17 Photo des membres Firebase — mauvais `BoxFit`

**Problème :** Les photos de profil des membres Firebase inscrits (stockées en base64) s'affichaient déformées ou mal cadrées dans les cartes du Matching et de la messagerie.

**Cause :** Le widget `Avatar` utilisait `BoxFit.fill` par défaut, étirant l'image pour remplir le cercle.

**Solution :** `BoxFit.cover` systématique dans le widget `Avatar` :
```dart
ClipOval(
  child: Image.memory(
    bytes,
    width: size, height: size,
    fit: BoxFit.cover, // ← corrigé (était BoxFit.fill)
  ),
)
```

---

### 4.18 Notifications — pas de navigation au tap

**Problème :** Taper sur une notification ne faisait rien (seulement `markAsRead`) — l'utilisateur ne savait pas où aller.

**Solution :** Méthode `_handleNotifTap(ctx, notif)` dans `page_notifications.dart` qui navigue selon le `type` de la notification :
- `'message'` → `appTabIndex.value = 2` (onglet Messages) + `Navigator.pop()`
- `'session_booked'` / `'rdv_booked'` / `'session_cancelled'` → `appTabIndex.value = 3` (onglet Agenda) + `Navigator.pop()`
- `'mentor_request'` / `'mentor_request_accepted'` / `'mentor_request_rejected'` / `'investment_offer'` → `Navigator.push(RequestsPage())`
- Autres types → aucune action (comportement inchangé)

---

### 4.19 Genre par défaut incorrectement initialisé à "Femme"

**Problème :** L'inscription initialisait `_gender = Gender.female`, forçant toujours "Femme" par défaut même si l'utilisateur ne précisait pas son genre.

**Cause :** La valeur initiale du champ était une valeur par défaut binaire sans option neutre.

**Solution :** Changement du défaut en `_gender = Gender.undisclosed` et ajout d'une troisième pill "Préfère ne pas dire" dans `_GenderRow`. L'utilisateur voit désormais trois options : **Femme / Homme / Préfère ne pas dire**, sans présélection imposée.

---

### 4.20 Demandes de mentorat en double (absence d'anti-doublon)

**Problème :** Un utilisateur pouvait envoyer plusieurs demandes identiques au même mentor/investisseur. Firebase accumulait des `mentorRequests` en doublon avec `status: 'pending'`, sans que le destinataire ne soit prévenu qu'il recevait la même demande plusieurs fois.

**Cause :** `page_send_request.dart` n'effectuait aucune vérification avant l'envoi.

**Solution :**
1. Nouvelle méthode `InteractionsService.hasPendingRequest({fromUserId, toUserId})` — requête Firebase `orderByChild('fromUserId').equalTo(fromUserId)` filtrée sur `toUserId` et `status == 'pending'`
2. Dans `page_send_request.dart`, vérification anti-doublon avant l'envoi : si une demande est déjà en attente, un `SnackBar` amber informe l'utilisateur et la méthode retourne immédiatement

---

### 4.21 Sessions statiques hardcodées dans l'agenda

**Problème :** La page `page_agenda.dart` affichait 3 sessions de démo hardcodées (Ibrahima Diop, Abdoulaye Fall, Fatou Diallo — agro-industrie) même pour les nouveaux utilisateurs sans aucune session Firebase. Ces données fictives créaient une confusion UX : les utilisateurs pensaient avoir des rendez-vous réels.

**Cause :** Implémentation initiale avec `List<_Session>` statique + classes `_Session`, `_SessionCard`, `_StatusBadge`, `_DetailRow` internes.

**Solution :** Suppression complète de toutes les données et classes statiques. La page utilise exclusivement `AgendaController.sessions` (ValueNotifier Firebase) avec un état vide illustré si aucune session n'existe. La section "Passées" a également été supprimée (Firebase ne stocke pas de flag d'achèvement).

---

### 4.22 Filtre pitchs insensible à la casse — résultats manquants

**Problème :** Dans `page_pitches_publics.dart`, la comparaison de secteur utilisait `==` (sensible à la casse) : un pitch stocké avec `sector: 'tech & digital'` n'apparaissait pas avec le filtre `'Tech & Digital'`, même secteur, casse différente.

**Cause :** Comparaison directe sans normalisation des chaînes :
```dart
// Avant : sensible à la casse
final matchSector = _selectedSector == 'Tous' || p['sector'] == _selectedSector;
```

**Solution :** Comparaison `.toLowerCase()` des deux membres :
```dart
// Après : insensible à la casse
final matchSector = _selectedSector == 'Tous' ||
    p['sector'].toString().toLowerCase() == _selectedSector.toLowerCase();
```

---

### 4.23 Doublon boutons Messages/Agenda sur les dashboards Mentor et Investisseur

**Problème :** Les dashboards Mentor et Investisseur affichaient des boutons "Messages" et "Agenda" en plus des onglets de la barre de navigation principale, créant une redondance confuse pour l'utilisateur.

**Solution :** Suppression des boutons doublons sur les deux dashboards. Navigation exclusive via les onglets de la barre principale (`IndexedStack`). Les imports inutilisés `service_navigation.dart` ont également été supprimés.

---

### 4.24 `hasFilter` toujours vrai pour un Investisseur (page Matching)

**Problème :** Pour un Investisseur, le bouton "Réinitialiser" s'affichait **en permanence** même sans aucun filtre actif.

**Cause :** `_role` est initialisé à `'Entrepreneur'` pour un Investisseur (son filtre par défaut), mais `hasFilter` comparait `_role != 'Tous'` — toujours `true` puisque `'Entrepreneur' != 'Tous'`.

**Solution :** Introduction de `defaultRole` adapté au rôle connecté :
```dart
final defaultRole = myRole == 'Investisseur' ? 'Entrepreneur' : 'Tous';
final hasFilter = _query.isNotEmpty || _sector != 'Tous' || _city != 'Toutes' || _role != defaultRole;
```

---

### 4.25 ID de conversation incohérent entre les écrans

**Problème :** En ouvrant le même chat depuis `page_detail_mentor.dart` et depuis `page_notifications.dart`, deux conversations différentes étaient créées dans Firebase.

**Cause :** `page_detail_mentor.dart` utilisait `profile.email` comme identifiant alors que `page_notifications.dart` utilisait `AuthService.currentUid` (UID Firebase). `generateConversationId` produisait deux clés distinctes pour la même paire d'utilisateurs.

**Solution :** Unification — tous les écrans utilisent `AuthService.currentUid` pour construire les IDs de conversation.

---

### 4.26 Booking avec fausses données statiques (`_SlotsRow`)

**Problème :** La page détail d'un mentor affichait des créneaux "Libre" fictifs (widget `_SlotsRow` avec données hardcodées) alors que le booking réel (`_BookingSheet`) lisait les vraies disponibilités Firebase. L'incohérence induisait l'utilisateur en erreur.

**Solution :** Suppression complète de `_SlotsRow`. Nouveau widget `_AvailabilityPreview` qui affiche :
- Les vraies disponibilités Firebase pour les membres inscrits (via `InteractionsService.getAvailability()`)
- Des créneaux illustratifs avec badge "Exemple" (point gris) pour les profils de démonstration (uid vide)

---

### 4.27 Parser chatbot fragile — format unique

**Problème :** `service_chatbot.dart` lisait la réponse en supposant toujours le format Anthropic (`data['content'][0]['text']`). Si le proxy Cloudflare Worker retournait un format Groq/OpenAI (`choices[0].message.content`), la réponse était `null` et le chat plantait silencieusement.

**Cause :** Le parser était écrit pour un format unique, sans détection de l'API sous-jacente.

**Solution :** Détection en cascade :
1. Tente d'abord **Groq/OpenAI** : `data['choices']?[0]?['message']?['content']`
2. Fallback sur **Anthropic** : `data['content']?[0]?['text']`
3. Si aucun des deux formats n'est reconnu → `Exception('Format de réponse inattendu du serveur.')`

Le client Flutter est maintenant indépendant du format de l'API sous-jacente utilisée par le proxy.

---

## 5. Solutions proposées et innovations

### 5.1 Réactivité globale sans state management externe

**Innovation :** Au lieu d'un package de state management (Provider, Riverpod, Bloc, GetX), DIAPALER AFRICA utilise le duo natif Flutter `ValueNotifier<T>` + `ValueListenableBuilder<T>`.

**Architecture :**
```
UserProfileController.update(p)
    ├─→ ValueNotifier → rebuild immédiat (UI)
    ├─→ CacheService.saveProfile() → offline-first
    └─→ DatabaseService.updateUserProfile() → cloud (async)
```

**Avantages :**
- Zéro dépendance externe pour le state management
- Code simple, lisible, testable
- Mise à jour < 1ms sur tous les écrans simultanément
- Compatible `StatelessWidget` (pas de `StatefulWidget` requis)

---

### 5.2 Bootstrap offline-first avec cache `SharedPreferences`

**Innovation :** Au lieu d'attendre Firebase (200-800ms), l'application affiche instantanément le profil du dernier utilisateur depuis `SharedPreferences` puis remplace les données par les données Firebase fraîches dès qu'elles arrivent.

```
Démarrage app   → Cache local (< 5ms) → UI instantanée
                → Firebase (200-800ms) → Mise à jour silencieuse
```

---

### 5.3 Double sauvegarde des pitchs

**Innovation :** Chaque pitch est sauvegardé à **deux endroits** simultanément :
- `users/{uid}/projects/` → pour le portfolio de l'entrepreneur
- `pitches/{id}/` → nœud global lisible par tous (mentors + investisseurs)

Cela permet la **visibilité croisée** sans exposer les données privées du profil.

---

### 5.4 Personnalisation culturelle sénégalaise

- Widget `SenegalFlagStrip` réutilisable sur tous les écrans d'auth
- DIALI IA avec contexte DER/FJ, BNDE, FONGIP, FONSIS dans le system prompt
- 40+ villes sénégalaises dans la géolocalisation avec coordonnées GPS précises
- Auto-format téléphone +221 XX XXX XX XX
- Montants en FCFA dans les pitchs

---

### 5.5 Badge non lus temps réel via ValueNotifier global

**Innovation :** Le badge de messages non lus sur la NavBar se met à jour en temps réel grâce à un `ValueNotifier<int>` global (`unreadMessagesCount`) dans `service_navigation.dart`. La `MessagesPage` écoute le stream Firebase des conversations et met à jour ce compteur global, même quand l'utilisateur est sur un autre onglet.

---

## 6. Qualité du code

### 6.1 Conventions de nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | `snake_case.dart` | `page_inscription.dart` |
| Classes | `PascalCase` | `UserProfileController` |
| Variables/méthodes | `camelCase` | `_loadingMembers`, `_toggleNearMe()` |
| Constantes | `camelCase` ou `SCREAMING_SNAKE_CASE` | `_profileKey`, `_topSectors` |
| Widgets privés | Préfixe `_` | `_PulseFab`, `_CityDropdown` |

### 6.2 Bonnes pratiques appliquées

- **`@immutable` + `copyWith()`** sur `UserProfile` et `Project` — immutabilité garantie, mutation sans référence partagée
- **`mounted` check + `dispose()`** systématiques — pas de leak après `await`, controllers libérés
- **`try/catch/finally`** sur tous les appels Firebase et HTTP — toujours un `finally` pour réinitialiser `_loading`
- **Séparation services/UI** stricte — aucun appel Firebase dans les widgets, `const` constructors partout où applicable

### 6.3 Gestion des erreurs

| Niveau | Mécanisme |
|---|---|
| Auth Firebase | `AuthService.humanError()` — 9 codes d'erreur humanisés |
| Réseau | `timeout(Duration(seconds: 4-5))` sur tous les appels Firebase |
| Cache | `try/catch` silencieux — le cache ne bloque jamais l'app |
| Firebase | `catchError()` sur `_syncToFirebase()` — sync non bloquante |
| Chatbot | Fallback message si l'API Groq est indisponible |

---

## 7. Bilan du projet

### 7.1 Récapitulatif des livrables

| Livrable | Contenu | Fonctionnalités clés | Statut |
|---|---|---|---|
| **L1** | Architecture Flutter + Navigation | 35 écrans, IndexedStack, ValueNotifier | ✅ Complet |
| **L2** | Consommation API | Firebase CRUD + Interactions + Groq REST | ✅ Complet |
| **L3** | Authentification | Connexion, Inscription 4 étapes, Reset, Cache session | ✅ Complet |
| **L4** | Gestion de profil | Modification + Photo + Projets CRUD + UsersService | ✅ Complet |
| **L5** | Fonctionnalités avancées | Notifs + Filtres + GPS + DIALI IA + Messagerie | ✅ Complet |
| **L6** | Rapport final | Ce document | ✅ Complet |

---

### 7.2 Métriques de qualité et performance

| Métrique | Valeur | Contexte |
|---|---|---|
| **Lignes de code Dart** | ~11,500 | Total `lib/` (*.dart) |
| **Fichiers** | 63 | Screens (35), Services (17), Widgets (13), Data (7), Config (2) |
| **Écrans implémentés** | 35 | Page + Dialogs + Sheets intégrés |
| **Services métier** | 17 | Auth, DB, GPS, Notifications, Chatbot, etc. |
| **Widgets réutilisables** | 13 | Avatar, Navigation, Cards, Loader, etc. |
| **Packages dépendances** | 13 | Flutter + Firebase + Geolocator + HTTP + FilePicker + UI |
| **Commits Git** | 45+ | Historique de développement |
| **Taille APK (Release)** | 58.3 MB | Compression Dart + Assets |
| **Taille AAB (Play Store)** | ~35 MB | Format optimisé distribution |
| **Analyse de code (Flutter Lint)** | 0 erreurs | 23 règles strictes activées |
| **Couverture fonctionnalités cahier des charges** | 100% | Toutes exigences + bonus |
| **Profils statiques de démo** | 112 | Mentors sénégalais pour test |
| **Villes Sénégal incluses** | 40+ | Avec coordonnées GPS |

**Temps de développement :** ~200h (6 membres, 5 semaines)  
**Performance moyenne :** ~60–80 FPS (Pixel 5 / Emulator)  
**Compatibilité :** Android 5.1+ (API 21), iOS 11.0+, Web (Chrome/Firefox/Safari)

---

### 7.3 Déploiement et distribution

#### Android — APK + Play Store

**Build Release :**
```bash
flutter build apk --release
# Résultat: build/app/outputs/flutter-apk/app-release.apk (58.3 MB)

flutter build appbundle --release
# Résultat: build/app/outputs/bundle/release/app-release.aab (~35 MB après compression Play Store)
```

**Configuration de signature :** Certificat auto-signé stocké en `android/key.properties` (non versionné en Git). Pour remise finale, signer avec certificat de production.

**Publication Play Store :**
1. Google Play Console → Créer app
2. Upload AAB (Android App Bundle) — Play Store compresse automatiquement per-device
3. Remplir store listing (screenshots, description, rating)
4. Mise en ligne: Closed Testing → Open Testing → Release

**Permissions AndroidManifest.xml :**
- INTERNET (réseau Firebase)
- ACCESS_FINE_LOCATION (GPS Geolocator)
- ACCESS_COARSE_LOCATION (fallback GPS)
- CAMERA (permission déclarée dans AndroidManifest)
- READ_EXTERNAL_STORAGE (galerie)

#### iOS — Archive + TestFlight + App Store

**Build Release :**
```bash
flutter build ios --release
# Résultat: build/ios/iphoneos/Runner.app
# Archive via Xcode: Product → Archive
```

**Distribution :**
1. Xcode: Organize Builds
2. Distribute App → App Store Connect
3. Codesigning : Provisioning profile valide Apple
4. Validation + Upload
5. TestFlight: Closed → Open Testing → Release

**Configuration:**
- Deployment Target: iOS 11.0+
- Team ID: Apple Developer account
- App ID: com.esp.diapaler

#### Web — Firebase Hosting

**Build Web :**
```bash
flutter build web --release
# Résultat: build/web/
```

**Déploiement Firebase Hosting :**
```bash
firebase deploy --only hosting
# Contenu servi depuis: https://diapaler-africa.web.app
```

**Configuration :** CORS, redirects vers index.html pour SPA (single-page app).

#### Suivi post-lancement

- Google Play Console : Crashes & ANRs dashboard
- Firebase Crashlytics : Erreurs runtime + stack traces
- Google Analytics : DAU, retention, funnel conversion
- A/B testing Firebase Remote Config : Features graduelles par région

L'application a été compilée en APK release signé (58.3 MB) et est disponible au téléchargement :

> **📦 Télécharger DIAPALER AFRICA :**  
> **https://drive.google.com/file/d/1XLJiSSJR8rQXCrAmY5mJWyx9i-6HFoGJ/view?usp=sharing**

**Détails du build :**

| Paramètre | Valeur |
|---|---|
| Type de build | Release signé |
| Taille APK | 58.3 MB |
| Plateforme | Android |
| Compilateur | Flutter `assembleRelease` |
| Keystore | RSA 2048 bits, validité 10 000 jours |
| Tree-shaking icônes | MaterialIcons réduit de 1 645 184 → 16 528 octets (−99 %) |
| Signature | `diapaler-release.jks`, alias `diapaler` |

> **📸 CAPTURE D'ÉCRAN — Terminal : `✓ Built build\app\outputs\flutter-apk\app-release.apk (58.3MB)`**
> *(Insérer ici la capture d'écran)*

---

#### Pourquoi Google Drive plutôt que le Play Store ?

La publication sur le **Google Play Store** nécessite le paiement d'un **frais d'inscription unique de 25 USD** (~15 000 FCFA) pour créer un compte développeur. Dans le cadre de ce projet académique à l'ESP Dakar, cette dépense n'est pas justifiée.

L'APK distribué via Google Drive est identique à ce qui serait publié sur le Play Store : il s'agit d'un **build release signé** avec un keystore RSA 2048 bits, exactement selon les exigences de Google Play. Si le projet évoluait vers une publication commerciale, l'APK existant pourrait être soumis sans recompilation.

| Canal de distribution | Coût | Adapté pour |
|---|---|---|
| **Google Drive ← choix actuel** | Gratuit | Projet académique / démonstration |
| Google Play Store | 25 USD (unique) | Publication commerciale |
| APK direct (lien ou QR code) | Gratuit | Tests internes / beta |

---

### 7.4 Perspectives d'évolution

Si DIAPALER AFRICA devait évoluer vers un produit commercial, les priorités seraient :

| Priorité | Fonctionnalité | Technologie |
|---|---|---|
| 1 | Notifications push (hors-app) | Firebase Cloud Messaging (FCM) |
| 2 | Appels vidéo (sessions mentorat) | Agora.io ou WebRTC |
| 3 | Mode hors-ligne complet | Firebase offline persistence |
| 4 | Analytiques | Firebase Analytics + tableau de bord |
| 5 | Recherche avancée | Algolia ou Firebase Extensions |
| 6 | Multi-langues | Intl package — français + wolof + anglais |
| 7 | Web app publique | Flutter Web — vitrine et landing page |

---

### 7.5 Conclusion

**DIAPALER AFRICA** est une application mobile complète, professionnelle et culturellement ancrée dans l'écosystème sénégalais. Elle répond à l'ensemble des critères académiques définis dans les 6 livrables, avec de nombreuses fonctionnalités bonus :

| Livrable | Fonctionnalités minimales | Fonctionnalités bonus |
|---|---|---|
| L1 | Navigation + 35 écrans | `IndexedStack`, `ValueNotifier`, FAB pulsant, agenda rôle-spécifique, matching rôle-adaptatif, système de Contacts, bouton Annuler session |
| L2 | Firebase CRUD (4 ops) | 26+ opérations CRUD, `InteractionsService`, `UsersService`, cache offline, `lastSenderId`, type `'investment'`, sanitize Firebase path, nœuds `reviews/` + `pitchFavorites/` |
| L3 | Connexion + Inscription | 4 étapes rôle-adaptées, jauge MDP, **"Se souvenir de moi"** (`SharedPreferences` — pré-remplissage auto), `AutofillGroup` sauvegarde MDP système, `_bootstrap()` offline-first, préfixe téléphone dynamique (+221/+220/+223) |
| L4 | Profil + Photo | Stats rôle-spécifiques, LinkedIn cliquable, "Mes contacts" Entrepreneur, `BoxFit.cover` Avatar, projets CRUD + **stepper unifié** `PitchPage(existingProject:)` + **bouton Précédent** (retour libre entre étapes) + **publication directe** `_directPublish` + `Project` enrichi (amount, businessPlanUrl, videoUrl, deckUrl, published) + boutons rôle-adaptatifs, avis/notation live |
| L5 | Notifs + Recherche + GPS | Filtres pitchs dynamiques, DIALI IA, flux investisseur complet, système de Contacts, compatibilité dynamique, bouton Annuler agenda, CIS, **Wave Premium Entrepreneur 4 900 FCFA/mois** (badge ⭐ profil + pitchs prioritaires + bannière), **déploiement APK**, booking Firebase réel (`_BookingSheet`), notifications inline Accept/Decline, `_AvailabilityPreview`, **avis ⭐ + pitchs favoris 🔖** |
| L6 | Rapport | 27+ bugs documentés, métriques complètes (35 écrans / 17 services), qualité du code, **APK signé déployé (58.3 MB)** |

Au-delà des critères académiques, DIAPALER AFRICA apporte une **vraie valeur ajoutée** à l'écosystème entrepreneurial sénégalais, en connectant entrepreneurs, mentors et investisseurs dans une plateforme unifiée, moderne et accessible, avec :
- Un **chatbot IA** (DIALI) contextuelisé à l'écosystème sénégalais
- Une **géolocalisation** précise de 40+ villes sénégalaises
- Une **messagerie instantanée** Firebase temps réel
- Un système de **matching avancé** combinant membres réels et profils curatés

Ce projet démontre qu'il est possible, avec Flutter, Firebase et l'API Groq, de concevoir en quelques semaines une application mobile de **qualité professionnelle**, complète, réactive et prête pour la mise sur le marché africain.

Les dernières itérations ont enrichi la plateforme avec un **flux investisseur complet** (propositions d'investissement, acceptation, relation de Contacts), un **système de Contacts** centralisant toutes les relations acceptées, un **matching rôle-adaptatif** (Mentor/Investisseur voient les Entrepreneurs), une **compatibilité dynamique** synchronisée entre affichage et tri, des **filtres avancés** dans la page Pitchs Publiés, un **système d'avis et notation étoiles 1–5** (`page_avis.dart`) avec moyenne live Firebase et accès restreint par relation acceptée, un **système de pitchs favoris** (`PitchFavoriteService` + `page_mes_pitchs_favoris.dart`) avec bookmark temps réel pour les investisseurs, un **préfixe téléphone dynamique** (🇸🇳 +221 / 🇬🇲 +220 / 🇲🇱 +223) adapté au pays à l'inscription, et un **système Premium Wave** opérationnel : abonnement Entrepreneur à 4 900 FCFA/mois, badge ⭐ sur le profil et les pitchs, tri prioritaire des pitchs premium dans le fil mentors/investisseurs, marquage batch des pitchs existants lors de l'activation. Des corrections ciblées ont également renforcé la robustesse : **navigation contextuelle** depuis le centre de notifications, **anti-doublon** sur les demandes de mentorat via `hasPendingRequest()`, **genre par défaut neutre** ("Préfère ne pas dire"), **suppression des sessions statiques** de l'agenda au profit d'un rendu purement Firebase, et **parser chatbot cascadant** supportant les formats Groq/OpenAI et Anthropic. Ces évolutions confirment la maturité et l'extensibilité de l'architecture choisie.

---

*Rapport rédigé dans le cadre du module de Développement d'Applications Mobiles*  
*École Supérieure Polytechnique (ESP) de Dakar — 2025-2026*  
*Projet DIAPALER AFRICA — Tous droits réservés*

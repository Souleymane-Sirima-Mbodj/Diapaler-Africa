const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, ExternalHyperlink,
  HeadingLevel, BorderStyle, WidthType, ShadingType, PageNumber, PageBreak,
} = require("docx");

// ─── Couleurs DIAPALER ────────────────────────────────────────────────────
const NAVY = "0A234B";
const NAVY_DEEP = "0F1729";
const BLUE = "1E50A0";
const AMBER = "F59E0B";
const GREEN = "10B981";
const RED = "E31B23";
const PURPLE = "8B5CF6";
const MUTED = "6B7280";
const BORDER = "E5E7EB";
const SOFT = "F3F4F6";
const FLAG_GREEN = "00853F";
const FLAG_YELLOW = "FDEF42";
const FLAG_RED = "E31B23";

// ─── Helpers ──────────────────────────────────────────────────────────────
const p = (children, opts = {}) =>
  new Paragraph({
    children: Array.isArray(children) ? children : [children],
    spacing: opts.spacing ?? { before: 80, after: 80 },
    alignment: opts.align,
    pageBreakBefore: opts.pageBreakBefore,
  });

const text = (str, opts = {}) =>
  new TextRun({
    text: str,
    bold: opts.bold,
    italics: opts.italics,
    color: opts.color,
    size: opts.size,
    font: opts.font,
    break: opts.break,
  });

const h1 = (str) =>
  new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children: [new TextRun({ text: str, color: NAVY, bold: true })],
    border: {
      bottom: { style: BorderStyle.SINGLE, size: 8, color: AMBER, space: 4 },
    },
    spacing: { before: 360, after: 200 },
  });

const h2 = (str) =>
  new Paragraph({
    heading: HeadingLevel.HEADING_2,
    children: [new TextRun({ text: str, color: NAVY, bold: true })],
    spacing: { before: 280, after: 120 },
  });

const h3 = (str) =>
  new Paragraph({
    heading: HeadingLevel.HEADING_3,
    children: [new TextRun({ text: str, color: BLUE, bold: true })],
    spacing: { before: 200, after: 100 },
  });

const para = (str, opts = {}) =>
  p(text(str, { color: NAVY_DEEP, ...opts }), { spacing: { before: 60, after: 80 } });

const bullet = (str, level = 0) =>
  new Paragraph({
    numbering: { reference: "bullets", level },
    children: [new TextRun({ text: str, color: NAVY_DEEP, size: 22 })],
    spacing: { before: 40, after: 40 },
  });

const code = (cmd) =>
  new Paragraph({
    children: [
      new TextRun({ text: cmd, font: "Consolas", color: NAVY_DEEP, size: 20 }),
    ],
    spacing: { before: 60, after: 60 },
    shading: { type: ShadingType.CLEAR, fill: SOFT },
    indent: { left: 200, right: 200 },
    border: {
      top: { style: BorderStyle.SINGLE, size: 4, color: AMBER, space: 4 },
      bottom: { style: BorderStyle.SINGLE, size: 4, color: AMBER, space: 4 },
      left: { style: BorderStyle.SINGLE, size: 4, color: AMBER, space: 4 },
      right: { style: BorderStyle.SINGLE, size: 4, color: AMBER, space: 4 },
    },
  });

const tableRow = (cells, isHeader = false) =>
  new TableRow({
    tableHeader: isHeader,
    children: cells.map(
      (c) =>
        new TableCell({
          width: { size: c.w, type: WidthType.DXA },
          shading: isHeader
            ? { type: ShadingType.CLEAR, fill: NAVY }
            : { type: ShadingType.CLEAR, fill: c.fill ?? "FFFFFF" },
          margins: { top: 100, bottom: 100, left: 140, right: 140 },
          borders: {
            top: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
            bottom: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
            left: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
            right: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
          },
          children: [
            p(
              text(c.t, {
                color: isHeader ? "FFFFFF" : NAVY_DEEP,
                bold: isHeader || c.bold,
                size: 21,
              })
            ),
          ],
        })
    ),
  });

const status = (label, color) =>
  new TextRun({
    text: " " + label + " ",
    color: "FFFFFF",
    bold: true,
    size: 18,
    shading: { type: ShadingType.CLEAR, fill: color },
  });

const calloutBlock = (label, content, fill, accent, emoji) =>
  new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            width: { size: 9360, type: WidthType.DXA },
            shading: { type: ShadingType.CLEAR, fill },
            margins: { top: 200, bottom: 200, left: 240, right: 240 },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 12, color: accent },
              bottom: { style: BorderStyle.NIL },
              left: { style: BorderStyle.NIL },
              right: { style: BorderStyle.NIL },
            },
            children: [
              p([
                text(emoji + " " + label, { bold: true, color: accent, size: 22 }),
              ]),
              p(text(content, { color: NAVY_DEEP, size: 21 })),
            ],
          }),
        ],
      }),
    ],
  });

const link = (label, url) =>
  new ExternalHyperlink({
    children: [new TextRun({ text: label, color: BLUE, underline: {} })],
    link: url,
  });

// ─── Document ─────────────────────────────────────────────────────────────
const doc = new Document({
  creator: "Équipe DIAPALER AFRICA",
  title: "Rapport technique — DIAPALER AFRICA",
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 36, bold: true, font: "Arial", color: NAVY },
        paragraph: { spacing: { before: 360, after: 200 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial", color: NAVY },
        paragraph: { spacing: { before: 280, after: 120 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 24, bold: true, font: "Arial", color: BLUE },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 } },
    ],
  },
  numbering: {
    config: [
      { reference: "bullets",
        levels: [
          { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 540, hanging: 280 } } } },
          { level: 1, format: LevelFormat.BULLET, text: "◦", alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 900, hanging: 280 } } } },
        ] },
    ],
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
      },
    },
    headers: {
      default: new Header({
        children: [
          p([
            text("DIAPAL", { bold: true, color: FLAG_GREEN, size: 18 }),
            text("ER", { bold: true, color: AMBER, size: 18 }),
            text("  AFRICA", { bold: true, color: FLAG_RED, size: 18 }),
            new TextRun({ text: "\tRapport technique", color: MUTED, size: 18 }),
          ]),
        ],
      }),
    },
    footers: {
      default: new Footer({
        children: [
          p([
            text("ESP Dakar  |  L3 GLSI/GLSIB  |  2025 – 2026", { color: MUTED, size: 18 }),
            new TextRun({ text: "\tPage ", color: MUTED, size: 18 }),
            new TextRun({ children: [PageNumber.CURRENT], color: MUTED, size: 18 }),
            text(" / ", { color: MUTED, size: 18 }),
            new TextRun({ children: [PageNumber.TOTAL_PAGES], color: MUTED, size: 18 }),
          ]),
        ],
      }),
    },
    children: [
      // ───── Page de garde ─────
      p([text("", { size: 200 })], { spacing: { before: 1800 } }),
      p([
        text("DIAPAL", { bold: true, color: FLAG_GREEN, size: 96 }),
        text("ER", { bold: true, color: AMBER, size: 96 }),
      ], { align: AlignmentType.CENTER, spacing: { before: 0, after: 0 } }),
      p([text("AFRICA", { bold: true, color: FLAG_RED, size: 56 })],
        { align: AlignmentType.CENTER, spacing: { before: 0, after: 200 } }),
      p([text("« Connecte ton idée à ton succès »",
        { italics: true, color: MUTED, size: 24 })],
        { align: AlignmentType.CENTER }),
      p([text(" ", { size: 24 })], { spacing: { before: 600, after: 200 } }),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [9360],
        rows: [new TableRow({
          children: [new TableCell({
            width: { size: 9360, type: WidthType.DXA },
            shading: { type: ShadingType.CLEAR, fill: NAVY_DEEP },
            margins: { top: 400, bottom: 400, left: 360, right: 360 },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 24, color: AMBER },
              bottom: { style: BorderStyle.SINGLE, size: 24, color: AMBER },
              left: { style: BorderStyle.NIL },
              right: { style: BorderStyle.NIL },
            },
            children: [
              p(text("RAPPORT TECHNIQUE", { bold: true, color: AMBER, size: 30 }),
                { align: AlignmentType.CENTER }),
              p(text("État du projet · Fonctionnalités livrées · Roadmap",
                { color: "FFFFFF", size: 22 }),
                { align: AlignmentType.CENTER }),
            ],
          })],
        })],
      }),
      p([text(" ", { size: 22 })], { spacing: { before: 400 } }),
      p([text("Plateforme mobile Flutter de mentorat et de mise en relation ",
        { color: NAVY_DEEP, size: 22 })],
        { align: AlignmentType.CENTER }),
      p([text("entrepreneuriale au Sénégal",
        { color: NAVY_DEEP, size: 22, bold: true })],
        { align: AlignmentType.CENTER }),
      p([text(" ", { size: 22 })], { spacing: { before: 600 } }),
      p([text("Document destiné aux développeurs · Mai 2026",
        { color: MUTED, size: 20, italics: true })],
        { align: AlignmentType.CENTER }),
      p([text("ESP Dakar  ·  Département Génie Informatique  ·  L3 GLSI/GLSIB",
        { color: MUTED, size: 20 })],
        { align: AlignmentType.CENTER }),
      p([text(" ", { size: 24 })], { spacing: { before: 400 } }),
      p([
        text("Repo : ", { color: MUTED, size: 20 }),
        link("github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa",
          "https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa"),
      ], { align: AlignmentType.CENTER }),

      // ───── 1. VUE D'ENSEMBLE ─────
      new Paragraph({ children: [new PageBreak()] }),
      h1("1. Vue d'ensemble"),
      h2("1.1 Le projet"),
      para(
        "DIAPALER AFRICA est une application mobile Flutter de mise en relation " +
          "entrepreneuriale destinée à l'écosystème sénégalais. Le mot « Diapaler » " +
          "vient du wolof et signifie « accompagner, épauler, guider quelqu'un dans " +
          "une démarche ». L'application connecte trois profils : les jeunes entrepreneurs, " +
          "les mentors sectoriels (notamment du Club des Investisseurs Sénégalais — CIS) et " +
          "les investisseurs privés."
      ),
      h2("1.2 Problématique adressée"),
      bullet("Absence d'accompagnement qualifié — l'accès à un mentor reste conditionné au réseau"),
      bullet("Capital sans conseils stratégiques — investissements à l'aveugle"),
      bullet("80 % d'échec des startups sénégalaises dans les 3 premières années (Banque Mondiale 2023)"),
      h2("1.3 Statut actuel"),
      para(
        "Le projet est dans la phase Livrable 0 — Proposition + maquettes fonctionnelles. " +
          "L'application possède une UI complète, une vraie authentification Firebase et " +
          "une base de données Realtime opérationnelle. Le périmètre actuel couvre " +
          "l'inscription Entrepreneur uniquement (Mentor / Investisseur en attente)."
      ),

      // ───── 2. STACK TECHNIQUE ─────
      h1("2. Stack technique"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [3000, 6360],
        rows: [
          tableRow([{ t: "Couche", w: 3000 }, { t: "Technologie", w: 6360 }], true),
          tableRow([{ t: "Framework UI", w: 3000 }, { t: "Flutter 3.41 / Dart 3.11", w: 6360 }]),
          tableRow([{ t: "Plateforme cible", w: 3000 }, { t: "Web (Chrome) — Android prévu Livrable 1", w: 6360 }]),
          tableRow([{ t: "Authentification", w: 3000 }, { t: "Firebase Auth (email/password)", w: 6360 }]),
          tableRow([{ t: "Base de données", w: 3000 }, { t: "Firebase Realtime Database (eur3 / Belgique)", w: 6360 }]),
          tableRow([{ t: "Polices", w: 3000 }, { t: "Inter (via google_fonts)", w: 6360 }]),
          tableRow([{ t: "État de l'app", w: 3000 }, { t: "ValueNotifier (UserProfileController) — pas de Provider/Bloc", w: 6360 }]),
          tableRow([{ t: "Versionnement", w: 3000 }, { t: "Git + GitHub avec branch protection sur main", w: 6360 }]),
          tableRow([{ t: "Workflow", w: 3000 }, { t: "Feature branches + Pull Requests + review owner", w: 6360 }]),
          tableRow([{ t: "Build mode démo", w: 3000 }, { t: "flutter run -d chrome --release", w: 6360 }]),
        ],
      }),
      p([text("", { size: 22 })], { spacing: { before: 200 } }),
      calloutBlock(
        "Choix d'architecture",
        "Pas de Provider, pas de Bloc, pas de GetX. On utilise les ValueNotifier natifs " +
          "Flutter pour partager l'état (UserProfileController). Pour un projet de cette taille, " +
          "c'est suffisant et garde le code lisible. À reconsidérer si on dépasse 30+ écrans.",
        "DCE6F5", BLUE, "💡"
      ),

      // ───── 3. STRUCTURE DU CODE ─────
      h1("3. Structure du code"),
      para(
        "Tout est dans le dossier lib/. Pas de sur-engineering : un fichier par écran, " +
          "un fichier par widget réutilisable. Les services Firebase sont isolés dans services/."
      ),
      h2("3.1 Arborescence"),
      code(
        "lib/\n" +
        "├── main.dart                    Entry point + Firebase init parallèle au splash\n" +
        "├── firebase_options.dart        Config Firebase Web (généré manuellement)\n" +
        "├── theme/\n" +
        "│   └── app_theme.dart           AppColors (drapeau Sénégal) + ThemeData light\n" +
        "├── data/\n" +
        "│   ├── user_profile.dart        Modèle UserProfile, Project, Gender + UserProfileController\n" +
        "│   ├── mock_data.dart           12 mentors sénégalais + recommendedMentorsFor()\n" +
        "│   ├── countries.dart           Pays/villes (Sénégal/Gambie/Mali) + ageFromBirthDate()\n" +
        "│   └── quotes.dart              8 citations (proverbes wolof + entrepreneurs panafricains)\n" +
        "├── services/\n" +
        "│   ├── auth_service.dart        Wrapper FirebaseAuth + erreurs FR\n" +
        "│   └── database_service.dart    CRUD profil sur Realtime Database\n" +
        "├── screens/                     11 pages\n" +
        "│   ├── splash_page.dart         Anim 1.1s + Firebase init + auto-login\n" +
        "│   ├── role_selection_page.dart Choix du rôle (Entrepreneur / Mentor / Investor)\n" +
        "│   ├── login_page.dart          Connexion (hero navy + gradient button)\n" +
        "│   ├── signup_page.dart         Inscription en 4 étapes avec validations live\n" +
        "│   ├── onboarding_page.dart     3 slides après signup\n" +
        "│   ├── root_shell.dart          Bottom-nav + IndexedStack + FAB pitch\n" +
        "│   ├── home_page.dart           Dashboard avec stats dynamiques\n" +
        "│   ├── matching_page.dart       Recherche mentors + filtres\n" +
        "│   ├── mentor_detail_page.dart  Hero + stats + entreprises + slots\n" +
        "│   ├── profile_page.dart        Mon profil compact\n" +
        "│   ├── edit_profile_page.dart   Modifier (cascade pays/ville)\n" +
        "│   ├── add_project_page.dart    Nouveau projet (nom + secteur + desc)\n" +
        "│   └── pitch_page.dart          Stepper 3 étapes pour déposer un pitch\n" +
        "└── widgets/                     13 widgets partagés\n" +
        "    ├── animated_counter.dart    Compteur 0 → valeur (Tween 1.1s)\n" +
        "    ├── avatar.dart              Avatar circulaire + indicateur en ligne\n" +
        "    ├── bottom_nav.dart          BottomAppBar 2 onglets + notch FAB\n" +
        "    ├── cursor_follower.dart     Traînée d'étoiles drapeau qui suit la souris\n" +
        "    ├── diapaler_logo.dart       LogoTile (handshake + orbites) + Wordmark drapeau\n" +
        "    ├── flag_strip.dart          3 lignes drapeau Sénégal\n" +
        "    ├── hover_glow_card.dart     Scale + shadow ambre au hover\n" +
        "    ├── mentor_card.dart         Card mentor avec badge CIS + score\n" +
        "    ├── profile_sheet.dart       Bottom sheet profil + logout\n" +
        "    ├── quote_carousel.dart      Carousel auto-rotatif (5s)\n" +
        "    ├── rotating_tagline.dart    Citation alternée sous le greeting\n" +
        "    ├── section_header.dart      Titre + lien d'action\n" +
        "    └── skeleton.dart            Boîtes shimmer + MentorCardSkeleton"
      ),

      // ───── 4. FONCTIONNALITÉS LIVRÉES ─────
      h1("4. Fonctionnalités livrées"),
      h2("4.1 Authentification (Firebase Auth)"),
      bullet("Inscription email + mot de passe avec création du compte Firebase Auth réel"),
      bullet("Création automatique du node /users/{uid} dans Realtime Database avec le profil complet"),
      bullet("Connexion réelle avec lecture du profil distant à la connexion"),
      bullet("Auto-login : si la session est active, le splash route directement vers RootShell"),
      bullet("Déconnexion via FirebaseAuth.signOut() — retour au splash"),
      bullet("12 erreurs Firebase traduites en français (email invalide, mdp faible, etc.)"),

      h2("4.2 Inscription en 4 étapes"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [1500, 3000, 4860],
        rows: [
          tableRow([
            { t: "Étape", w: 1500 },
            { t: "Titre", w: 3000 },
            { t: "Champs", w: 4860 },
          ], true),
          tableRow([
            { t: "1 / 4", w: 1500, bold: true },
            { t: "Identité", w: 3000 },
            { t: "Rôle, Nom, Email, Sexe, Date naissance (avec calcul d'âge live)", w: 4860 },
          ]),
          tableRow([
            { t: "2 / 4", w: 1500, bold: true },
            { t: "Localisation", w: 3000 },
            { t: "Pays (3) + Ville en cascade + Adresse (optionnelle)", w: 4860 },
          ]),
          tableRow([
            { t: "3 / 4", w: 1500, bold: true },
            { t: "Profil pro", w: 3000 },
            { t: "À propos (opt), LinkedIn (opt), Centres d'intérêt (obligatoire ≥ 1)", w: 4860 },
          ]),
          tableRow([
            { t: "4 / 4", w: 1500, bold: true },
            { t: "Sécurité", w: 3000 },
            { t: "Téléphone (auto-format) + Mdp (force) + Confirmation + CGU", w: 4860 },
          ]),
        ],
      }),
      p([text("", { size: 22 })], { spacing: { before: 200 } }),
      h3("Validations live"),
      bullet("Email : regex en temps réel, badge ✓ vert / ✗ rouge à droite du champ"),
      bullet("Téléphone : auto-format 'XX XXX XX XX' et limite à 9 chiffres"),
      bullet("Mot de passe : barre de force colorée (rouge / ambre / vert)"),
      bullet("Confirmation : pastille verte/rouge selon match"),
      bullet("Boutons CONTINUER / S'INSCRIRE désactivés tant que l'étape courante invalide"),
      h3("Mentor / Investisseur"),
      para(
        "Pour limiter le périmètre du Livrable 0, l'inscription pour ces 2 rôles est " +
          "désactivée : le formulaire devient vide quand le pill est sélectionné, et le bouton " +
          "CONTINUER reste grisé. Implémentation à compléter au Livrable 1."
      ),

      h2("4.3 Profil utilisateur (Realtime Database)"),
      para("Stockage complet dans /users/{uid} avec les champs suivants :"),
      code(
        "{\n" +
        "  firstName, lastName, email, phone,\n" +
        "  gender (female|male), birthDate (ISO),\n" +
        "  address, city, country,\n" +
        "  sector, role, bio, linkedin,\n" +
        "  interests: [],\n" +
        "  projects: [{ id, name, description, sector, step, totalSteps }],\n" +
        "  mentorsActive, sessionsCount, favoritesCount, score,\n" +
        "  updatedAt: ServerValue.timestamp\n" +
        "}"
      ),
      bullet("Page Mon profil compacte (identité + coords + projets + intérêts + bio)"),
      bullet("EditProfilePage avec dropdowns cascading pays/ville + multi-select 31 secteurs"),
      bullet("ValueListenableBuilder<UserProfile> dans toutes les vues — refresh live"),

      h2("4.4 Multi-projets"),
      bullet("Modèle Project avec id, nom, description, secteur, step, totalSteps"),
      bullet("Règle métier : « 1 actif à la fois » — canStartNewProject = tous les projets terminés"),
      bullet("Empty state : gros bouton + ambre dans le hero du dashboard et du profil"),
      bullet("AddProjectPage : nom + secteur (dropdown 31) + description"),
      bullet("Badges : EN COURS (ambre) / TERMINÉ (vert)"),

      h2("4.5 Dashboard"),
      bullet("Greeting personnalisé « Bonjour [prénom] » + tagline rotative (citations 6s)"),
      bullet("Avatar tappable → bottom sheet profil"),
      bullet("Cloche avec badge non-lus"),
      bullet("Hero card projet : gradient navy + cercles décoratifs + progress animé"),
      bullet("Stats horizontales (5 stats lues du profile) avec compteurs animés"),
      bullet("Mentors recommandés calculés dynamiquement (sector ∪ projects ∪ interests)"),
      bullet("Card DER/FJ PAVIE 2"),
      bullet("Pull-to-refresh + skeletons shimmer 900ms au démarrage"),

      h2("4.6 Matching"),
      bullet("12 mentors sénégalais avec entreprises détaillées (3 à 8 par mentor)"),
      bullet("Recherche live (nom, secteur, ville)"),
      bullet("Pills filtres (10 secteurs) + dropdown ville"),
      bullet("Tri automatique par compatibility décroissante"),
      bullet("Empty state si 0 résultat"),
      bullet("Page détail mentor : SliverAppBar gradient + 4 stats + entreprises + créneaux + 2 CTA"),

      h2("4.7 Pitch deck"),
      bullet("FAB ambre central pour y accéder depuis n'importe quel onglet"),
      bullet("Stepper 3 étapes : infos → secteur (dropdown) → documents"),
      bullet("Upload zones pointillées (PDF + vidéo)"),
      bullet("Snackbar succès vert au dépôt"),

      h2("4.8 UX premium"),
      bullet("Splash 1.1s : logo handshake construit + 3 orbites drapeau Sénégal allumées en cascade"),
      bullet("Curseur étoiles drapeau qui suit la souris (web/desktop, no-op sur tactile)"),
      bullet("Hover glow sur cards : scale 1.015 + shadow ambré + bordure bleue"),
      bullet("Compteurs animés (TweenAnimationBuilder, Curves.easeOutQuart)"),
      bullet("Skeletons shimmer pour le chargement initial"),
      bullet("Pull-to-refresh sur le dashboard"),
      bullet("Transitions fade-through entre toutes les pages"),
      bullet("Bottom sheet profil avec liste d'options + logout"),
      bullet("Bouton SE CONNECTER avec gradient navy → bleu + glow ambre"),
      bullet("Mode --release optimisé pour la démo (5× plus rapide que --debug)"),

      h2("4.9 Branch protection GitHub"),
      bullet("Require pull request before merging (1 approval required = owner)"),
      bullet("Dismiss stale approvals on new commits"),
      bullet("Require conversation resolution before merging"),
      bullet("Block force pushes + block deletions"),
      bullet("Workflow : feature branch → push → PR → review owner → merge"),

      // ───── 5. RESTE À FAIRE ─────
      h1("5. Reste à faire"),
      para(
        "Périmètre découpé par échéance. Les TODO les plus urgents sont en haut. " +
          "Les statuts utilisent un code couleur : rouge (bloquant pour la prochaine livraison), " +
          "ambre (important), gris (nice to have)."
      ),

      h2("5.1 Court terme — Livrable 1"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [3500, 1700, 4160],
        rows: [
          tableRow([
            { t: "Tâche", w: 3500 },
            { t: "Priorité", w: 1700 },
            { t: "Notes", w: 4160 },
          ], true),
          tableRow([
            { t: "Inscription Mentor + Investisseur", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Champs spécifiques (expertise, ticket d'investissement, vérification CIS)", w: 4160 },
          ]),
          tableRow([
            { t: "Vraie messagerie temps réel", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Page conversations + chat. Firebase Realtime DB ou Firestore selon volume", w: 4160 },
          ]),
          tableRow([
            { t: "Dépôt de pitch persistant", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Stocker dans /pitches/{pitchId}, lier à user.projects, upload PDF via Firebase Storage", w: 4160 },
          ]),
          tableRow([
            { t: "Upload photo de profil", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Firebase Storage + remplacer Avatar initials par CachedNetworkImage", w: 4160 },
          ]),
          tableRow([
            { t: "Système de favoris fonctionnel", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Toggle bookmark sur mentor → /users/{uid}/favorites", w: 4160 },
          ]),
          tableRow([
            { t: "Réservation de session mentor", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Page calendrier réelle + node /sessions avec slot, confirmation", w: 4160 },
          ]),
          tableRow([
            { t: "Notifications push (FCM)", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Firebase Cloud Messaging — token par device + topic par rôle", w: 4160 },
          ]),
          tableRow([
            { t: "Mode sombre (réactiver)", w: 3500 },
            { t: "BASSE", w: 1700, fill: "F3F4F6" },
            { t: "Code de AppTheme.dark déjà présent — juste rebrancher le toggle", w: 4160 },
          ]),
        ],
      }),

      h2("5.2 Moyen terme — Livrable 2"),
      bullet("Configuration Android (google-services.json + plugin Gradle) pour APK"),
      bullet("Configuration iOS (GoogleService-Info.plist) si soumission App Store"),
      bullet("Déploiement Firebase Hosting pour la version web publique"),
      bullet("CI/CD GitHub Actions : flutter analyze + flutter test + build à chaque PR"),
      bullet("Couverture de tests > 50 % (widgets + unit tests sur services)"),
      bullet("Internationalisation FR / Wolof avec flutter_intl"),
      bullet("Mode hors-ligne partiel (cache Hive ou Isar pour mentors et conversations)"),
      bullet("Page DER/FJ avec vraies fiches PAVIE 2 + Be Yes + check d'éligibilité"),

      h2("5.3 Long terme — Vision Livrable 3+"),
      bullet("Algorithme de matching avancé (scoring pondéré multi-critères ou ML léger)"),
      bullet("Intégration mobile money pour paiement de session (Wave / Orange Money / Free Money)"),
      bullet("Vidéoconférence intégrée (Jitsi Meet ou Daily.co)"),
      bullet("Système de notation/avis post-session (alimente le compatibility score)"),
      bullet("Analytics (Firebase Analytics + dashboard métier interne)"),
      bullet("Recherche full-text sur mentors via Algolia ou Typesense"),
      bullet("Webhook Calendly / Google Calendar pour synchro des créneaux"),
      bullet("Export PDF du pitch deck à partager hors plateforme"),

      // ───── 6. WORKFLOW ÉQUIPE ─────
      h1("6. Workflow équipe"),
      h2("6.1 Conventions de commit"),
      para("Utiliser un préfixe pour clarifier la nature du commit :"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [1800, 7560],
        rows: [
          tableRow([{ t: "Préfixe", w: 1800 }, { t: "Pour quoi", w: 7560 }], true),
          tableRow([{ t: "feat:", w: 1800, bold: true }, { t: "Nouvelle fonctionnalité", w: 7560 }]),
          tableRow([{ t: "fix:", w: 1800, bold: true }, { t: "Correction de bug", w: 7560 }]),
          tableRow([{ t: "ux:", w: 1800, bold: true }, { t: "Amélioration UI/UX (style, animation)", w: 7560 }]),
          tableRow([{ t: "perf:", w: 1800, bold: true }, { t: "Optimisation performance", w: 7560 }]),
          tableRow([{ t: "refactor:", w: 1800, bold: true }, { t: "Refonte de code sans nouvelle fonctionnalité", w: 7560 }]),
          tableRow([{ t: "docs:", w: 1800, bold: true }, { t: "Documentation (README, guides)", w: 7560 }]),
          tableRow([{ t: "chore:", w: 1800, bold: true }, { t: "Tâches techniques (deps, gitignore, etc.)", w: 7560 }]),
          tableRow([{ t: "test:", w: 1800, bold: true }, { t: "Ajout / modif de tests", w: 7560 }]),
        ],
      }),
      h2("6.2 Workflow Pull Request"),
      code(
        "# 1. Créer une branche feature à partir de main\n" +
        "git checkout main && git pull\n" +
        "git checkout -b feat/nom-de-la-fonctionnalite\n\n" +
        "# 2. Coder, committer, pusher\n" +
        "git add lib/...\n" +
        "git commit -m \"feat: description courte\"\n" +
        "git push -u origin feat/nom-de-la-fonctionnalite\n\n" +
        "# 3. Ouvrir une PR sur GitHub vers main\n" +
        "gh pr create --base main --title \"feat: ...\" --body \"...\"\n\n" +
        "# 4. Attendre la review de l'owner\n" +
        "# Si changements demandés : push de nouveaux commits sur la même branche\n\n" +
        "# 5. Une fois approuvée, merger via l'UI GitHub (Squash and merge recommandé)"
      ),
      h2("6.3 Avant chaque commit"),
      bullet("flutter analyze — doit retourner « No issues found »"),
      bullet("Vérifier visuellement que l'app tourne en mode release sans erreur console"),
      bullet("Si modification de UserProfile : penser à updater DatabaseService._toMap / _fromMap"),
      bullet("Pas de print() ni de TODO commit dans le code de la PR"),

      // ───── 7. POINTS D'ATTENTION ─────
      h1("7. Points d'attention"),
      calloutBlock(
        "Sécurité Firebase",
        "Les règles Realtime Database sont actuellement en mode test (lecture/écriture " +
          "ouvertes 30 jours). Avant tout déploiement public, il faut écrire les règles " +
          "réelles : un user peut lire/écrire seulement /users/{uid} où {uid} == auth.uid.",
        "FEF3C7", AMBER, "⚠"
      ),
      p([text("", { size: 22 })], { spacing: { before: 200 } }),
      calloutBlock(
        "Plateforme",
        "Pour l'instant l'app ne tourne que sur Chrome (web). La config Android/iOS " +
          "Firebase n'est pas faite — c'est ~30 min de boulot mais à planifier avant " +
          "de pouvoir distribuer un APK ou TestFlight.",
        "DCE6F5", BLUE, "💡"
      ),
      p([text("", { size: 22 })], { spacing: { before: 200 } }),
      calloutBlock(
        "Performance",
        "Le mode --debug est très lent en web (5× plus lent que release). Pour la démo, " +
          "toujours utiliser --release. Pour le développement, utiliser le hot reload " +
          "avec --debug malgré la lenteur — ça vaut le coup pour itérer.",
        "DCFCE7", GREEN, "🚀"
      ),

      // ───── 8. RESSOURCES ─────
      h1("8. Ressources"),
      bullet("Repo GitHub : github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa"),
      bullet("Console Firebase : console.firebase.google.com/project/diapaler-africa"),
      bullet("Documentation Flutter : docs.flutter.dev"),
      bullet("FlutterFire (plugin Firebase) : firebase.flutter.dev"),
      bullet("Guide d'installation pour rejoindre le projet : docs/Guide_Installation_DIAPALER.docx"),
      bullet("Doc fonctionnelle (Livrable 0 du cours) : docs externes (DOCX original)"),
      bullet("Maquettes haute fidélité : présentation PowerPoint du Livrable 0"),

      // ───── Footer ─────
      p([text("", { size: 22 })], { spacing: { before: 600 } }),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [9360],
        rows: [new TableRow({
          children: [new TableCell({
            width: { size: 9360, type: WidthType.DXA },
            shading: { type: ShadingType.CLEAR, fill: NAVY },
            margins: { top: 280, bottom: 280, left: 360, right: 360 },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 16, color: AMBER },
              bottom: { style: BorderStyle.SINGLE, size: 16, color: AMBER },
              left: { style: BorderStyle.NIL },
              right: { style: BorderStyle.NIL },
            },
            children: [
              p(text("« Connecte ton idée à ton succès »",
                { color: "FFFFFF", italics: true, size: 24, bold: true }),
                { align: AlignmentType.CENTER }),
              p(text("— L'équipe DIAPALER AFRICA —", { color: AMBER, size: 20 }),
                { align: AlignmentType.CENTER }),
            ],
          })],
        })],
      }),
      p([text("Document généré pour les développeurs · Bon code 🇸🇳",
        { color: MUTED, size: 20 })],
        { align: AlignmentType.CENTER, spacing: { before: 200 } }),
    ],
  }],
});

Packer.toBuffer(doc).then((buffer) => {
  fs.writeFileSync(
    "C:/Users/HP/entreprenariat/docs/Rapport_Technique_DIAPALER.docx",
    buffer
  );
  console.log("OK Rapport_Technique_DIAPALER.docx generated.");
});

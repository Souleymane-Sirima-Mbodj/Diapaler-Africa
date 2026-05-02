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
const MUTED = "6B7280";
const BORDER = "E5E7EB";
const SOFT = "F3F4F6";

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

const numbered = (str) =>
  new Paragraph({
    numbering: { reference: "numbers", level: 0 },
    children: [new TextRun({ text: str, color: NAVY_DEEP, size: 22 })],
    spacing: { before: 40, after: 40 },
  });

const code = (cmd) =>
  new Paragraph({
    children: [
      new TextRun({
        text: cmd,
        font: "Consolas",
        color: NAVY_DEEP,
        size: 20,
      }),
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

const calloutTip = (label, content) =>
  new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            width: { size: 9360, type: WidthType.DXA },
            shading: { type: ShadingType.CLEAR, fill: "DCE6F5" },
            margins: { top: 200, bottom: 200, left: 240, right: 240 },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 12, color: BLUE },
              bottom: { style: BorderStyle.NIL },
              left: { style: BorderStyle.NIL },
              right: { style: BorderStyle.NIL },
            },
            children: [
              p([
                text("\u{1F4A1} " + label, { bold: true, color: BLUE, size: 22 }),
              ]),
              p(text(content, { color: NAVY_DEEP, size: 21 })),
            ],
          }),
        ],
      }),
    ],
  });

const calloutWarn = (content) =>
  new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            width: { size: 9360, type: WidthType.DXA },
            shading: { type: ShadingType.CLEAR, fill: "FEF3C7" },
            margins: { top: 200, bottom: 200, left: 240, right: 240 },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 12, color: AMBER },
              bottom: { style: BorderStyle.NIL },
              left: { style: BorderStyle.NIL },
              right: { style: BorderStyle.NIL },
            },
            children: [
              p([
                text("⚠  " + content, { color: NAVY_DEEP, size: 21 }),
              ]),
            ],
          }),
        ],
      }),
    ],
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
            : { type: ShadingType.CLEAR, fill: "FFFFFF" },
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
                bold: isHeader,
                size: isHeader ? 21 : 21,
              })
            ),
          ],
        })
    ),
  });

const link = (label, url) =>
  new ExternalHyperlink({
    children: [
      new TextRun({
        text: label,
        color: BLUE,
        underline: {},
      }),
    ],
    link: url,
  });

// ─── Document ─────────────────────────────────────────────────────────────
const doc = new Document({
  creator: "Équipe DIAPALER AFRICA",
  title: "Guide d'installation DIAPALER AFRICA",
  styles: {
    default: {
      document: { run: { font: "Arial", size: 22 } },
    },
    paragraphStyles: [
      {
        id: "Heading1",
        name: "Heading 1",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 36, bold: true, font: "Arial", color: NAVY },
        paragraph: { spacing: { before: 360, after: 200 }, outlineLevel: 0 },
      },
      {
        id: "Heading2",
        name: "Heading 2",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 28, bold: true, font: "Arial", color: NAVY },
        paragraph: { spacing: { before: 280, after: 120 }, outlineLevel: 1 },
      },
      {
        id: "Heading3",
        name: "Heading 3",
        basedOn: "Normal",
        next: "Normal",
        quickFormat: true,
        run: { size: 24, bold: true, font: "Arial", color: BLUE },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 },
      },
    ],
  },
  numbering: {
    config: [
      {
        reference: "bullets",
        levels: [
          {
            level: 0,
            format: LevelFormat.BULLET,
            text: "•",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 540, hanging: 280 } } },
          },
          {
            level: 1,
            format: LevelFormat.BULLET,
            text: "◦",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 900, hanging: 280 } } },
          },
        ],
      },
      {
        reference: "numbers",
        levels: [
          {
            level: 0,
            format: LevelFormat.DECIMAL,
            text: "%1.",
            alignment: AlignmentType.LEFT,
            style: { paragraph: { indent: { left: 540, hanging: 280 } } },
          },
        ],
      },
    ],
  },
  sections: [
    {
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
              text("DIAPALER", { bold: true, color: GREEN, size: 18 }),
              text("ER", { bold: true, color: AMBER, size: 18 }), // 'ER' deja inclus
              text("  AFRICA", { bold: true, color: RED, size: 18 }),
              new TextRun({
                text: "\tGuide d'installation",
                color: MUTED,
                size: 18,
              }),
            ]),
          ],
        }),
      },
      footers: {
        default: new Footer({
          children: [
            p([
              text("ESP Dakar  |  L3 GLSI/GLSIB  |  2025 – 2026", {
                color: MUTED,
                size: 18,
              }),
              new TextRun({
                text: "\tPage ",
                color: MUTED,
                size: 18,
              }),
              new TextRun({
                children: [PageNumber.CURRENT],
                color: MUTED,
                size: 18,
              }),
              text(" / ", { color: MUTED, size: 18 }),
              new TextRun({
                children: [PageNumber.TOTAL_PAGES],
                color: MUTED,
                size: 18,
              }),
            ]),
          ],
        }),
      },
      children: [
        // ───────── Page de garde ─────────
        new Paragraph({
          children: [text("", { size: 200 })],
          spacing: { before: 1800 },
        }),
        p(
          [
            text("DIAPAL", { bold: true, color: GREEN, size: 96 }),
            text("ER", { bold: true, color: AMBER, size: 96 }),
          ],
          { align: AlignmentType.CENTER, spacing: { before: 0, after: 0 } }
        ),
        p(
          [text("AFRICA", { bold: true, color: RED, size: 56 })],
          { align: AlignmentType.CENTER, spacing: { before: 0, after: 200 } }
        ),
        p(
          [
            text("« Connecte ton idée à ton succès »", {
              italics: true,
              color: MUTED,
              size: 24,
            }),
          ],
          { align: AlignmentType.CENTER }
        ),
        p(
          [text(" ", { size: 24 })],
          { spacing: { before: 600, after: 200 } }
        ),
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [9360],
          rows: [
            new TableRow({
              children: [
                new TableCell({
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
                    p(
                      text("GUIDE D'INSTALLATION", {
                        bold: true,
                        color: AMBER,
                        size: 30,
                      }),
                      { align: AlignmentType.CENTER }
                    ),
                    p(
                      text(
                        "Récupérer et lancer l'application sur votre ordinateur",
                        { color: "FFFFFF", size: 22 }
                      ),
                      { align: AlignmentType.CENTER }
                    ),
                  ],
                }),
              ],
            }),
          ],
        }),
        p([text(" ", { size: 22 })], { spacing: { before: 400 } }),
        p(
          [
            text("Plateforme mobile de mentorat et de mise en relation ", {
              color: NAVY_DEEP,
              size: 22,
            }),
          ],
          { align: AlignmentType.CENTER }
        ),
        p(
          [
            text("entrepreneuriale au Sénégal", {
              color: NAVY_DEEP,
              size: 22,
              bold: true,
            }),
          ],
          { align: AlignmentType.CENTER }
        ),
        p([text(" ", { size: 22 })], { spacing: { before: 600 } }),
        p(
          [
            text("ESP Dakar  ·  Département Génie Informatique", {
              color: MUTED,
              size: 20,
            }),
          ],
          { align: AlignmentType.CENTER }
        ),
        p(
          [text("Licence 3 GLSI/GLSIB  ·  2025 – 2026", { color: MUTED, size: 20 })],
          { align: AlignmentType.CENTER }
        ),
        p([text(" ", { size: 24 })], { spacing: { before: 400 } }),
        p(
          [
            text("Repo GitHub : ", { color: MUTED, size: 20 }),
            link(
              "github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa",
              "https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa"
            ),
          ],
          { align: AlignmentType.CENTER }
        ),

        // ───────── Présentation ─────────
        new Paragraph({ children: [new PageBreak()] }),
        h1("1. Présentation du projet"),
        para(
          "DIAPALER AFRICA est une application mobile développée en Flutter dans " +
            "le cadre du cours d'approfondissement en développement mobile (ESP Dakar, " +
            "L3 GLSI/GLSIB). Le projet propose une plateforme de mentorat qui connecte " +
            "les jeunes entrepreneurs sénégalais aux mentors du Club des Investisseurs " +
            "Sénégalais (CIS), aux investisseurs privés et aux dispositifs publics " +
            "comme la DER/FJ."
        ),
        para(
          "Le mot « Diapaler » vient du wolof et signifie « accompagner, épauler, " +
            "guider quelqu'un dans une démarche ». Ce guide vous explique comment " +
            "récupérer le code source et lancer l'application sur votre ordinateur " +
            "personnel en moins de 15 minutes."
        ),
        h2("Ce que vous obtiendrez"),
        bullet("Une application web Flutter qui tourne dans votre navigateur Chrome"),
        bullet("Connexion à une vraie base de données Firebase (Auth + Realtime DB)"),
        bullet("Inscription, connexion et sauvegarde de profil en temps réel"),
        bullet("Toutes les fonctionnalités : matching de mentors, dépôt de pitch, dashboard, profils détaillés"),

        // ───────── Pré-requis ─────────
        h1("2. Pré-requis"),
        para(
          "Avant de commencer, vous aurez besoin des outils suivants. Si vous les " +
            "avez déjà installés, passez directement à la section suivante."
        ),
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [2200, 4400, 2760],
          rows: [
            tableRow(
              [
                { t: "Outil", w: 2200 },
                { t: "À quoi ça sert", w: 4400 },
                { t: "Installé ?", w: 2760 },
              ],
              true
            ),
            tableRow([
              { t: "Flutter SDK", w: 2200 },
              { t: "Compiler et lancer l'application Flutter (version 3.5+)", w: 4400 },
              { t: "Obligatoire", w: 2760 },
            ]),
            tableRow([
              { t: "Git", w: 2200 },
              { t: "Cloner le code source depuis GitHub", w: 4400 },
              { t: "Obligatoire", w: 2760 },
            ]),
            tableRow([
              { t: "Google Chrome", w: 2200 },
              { t: "Lancer l'application en mode web", w: 4400 },
              { t: "Déjà installé", w: 2760 },
            ]),
            tableRow([
              { t: "VS Code", w: 2200 },
              { t: "IDE recommandé pour modifier le code (extension Flutter)", w: 4400 },
              { t: "Recommandé", w: 2760 },
            ]),
            tableRow([
              { t: "Compte GitHub", w: 2200 },
              { t: "Pas obligatoire pour cloner un repo public", w: 4400 },
              { t: "Optionnel", w: 2760 },
            ]),
          ],
        }),
        p([text("", { size: 22 })], { spacing: { before: 200 } }),
        calloutTip(
          "Astuce",
          "Pas besoin d'Android Studio ni de configurer Firebase de votre côté — " +
            "la configuration Firebase est déjà incluse dans le projet et pointe sur le projet partagé. " +
            "Vous accéderez aux mêmes données que toute l'équipe."
        ),

        // ───────── Installation Flutter ─────────
        h1("3. Installer Flutter (si vous ne l'avez pas)"),
        para(
          "Si la commande flutter --version retourne une erreur dans votre terminal, " +
            "voici la marche à suivre. Sinon, passez à la section 4."
        ),
        h3("Sur Windows"),
        numbered("Téléchargez Flutter depuis le site officiel"),
        p(
          [
            text("    → ", { color: MUTED, size: 21 }),
            link(
              "https://docs.flutter.dev/get-started/install/windows",
              "https://docs.flutter.dev/get-started/install/windows"
            ),
          ],
          { spacing: { before: 40, after: 80 } }
        ),
        numbered("Décompressez l'archive ZIP dans un dossier sans espaces ni accents"),
        para("Par exemple : C:\\src\\flutter (évitez C:\\Program Files)", {
          italics: true,
          color: MUTED,
          size: 20,
        }),
        numbered("Ajoutez Flutter au PATH Windows"),
        bullet("Ouvrir « Modifier les variables d'environnement système »"),
        bullet("Cliquer sur « Variables d'environnement... »"),
        bullet("Sélectionner Path dans Variables utilisateur, cliquer Modifier"),
        bullet("Cliquer Nouveau et coller : C:\\src\\flutter\\bin"),
        bullet("Valider avec OK trois fois"),
        numbered("Ouvrez un nouveau terminal (PowerShell ou Git Bash) et vérifiez"),
        code("flutter --version"),
        para(
          "Vous devriez voir quelque chose comme « Flutter 3.41.x · channel stable ». " +
            "Lancez ensuite la commande suivante pour vérifier que tout est bien configuré :"
        ),
        code("flutter doctor"),
        para(
          "Si flutter doctor signale des éléments manquants, suivez ses recommandations. " +
            "Pour notre démo web sur Chrome, il vous suffit que la ligne « Chrome » soit verte."
        ),
        h3("Sur macOS"),
        para(
          "Téléchargez Flutter depuis docs.flutter.dev/get-started/install/macos, " +
            "décompressez dans ~/development/flutter, et ajoutez à votre PATH dans " +
            "~/.zshrc avec : export PATH=\"$PATH:$HOME/development/flutter/bin\""
        ),

        // ───────── Cloner et lancer ─────────
        h1("4. Récupérer le projet et le lancer"),
        para(
          "Une fois Flutter installé, ouvrez un terminal (PowerShell, Git Bash ou Terminal " +
            "macOS) et exécutez les 5 commandes suivantes les unes après les autres."
        ),
        h3("Étape 1 — Cloner le repo"),
        code(
          "git clone https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa.git"
        ),
        para(
          "Cette commande télécharge tout le code source dans un dossier nommé " +
            "Diapaler-Africa. Vous pouvez la lancer depuis n'importe quel emplacement, " +
            "le dossier sera créé là où vous êtes."
        ),
        h3("Étape 2 — Entrer dans le projet"),
        code("cd Diapaler-Africa"),
        h3("Étape 3 — Vérifier Flutter"),
        code("flutter --version"),
        para("Doit afficher Flutter 3.5 ou supérieur. Si erreur, retournez à la section 3."),
        h3("Étape 4 — Installer les dépendances"),
        code("flutter pub get"),
        para(
          "Cette commande télécharge tous les packages utilisés (Firebase, Google Fonts, etc.). " +
            "Première exécution : 1 à 3 minutes. Les fois suivantes : quelques secondes."
        ),
        h3("Étape 5 — Lancer l'application"),
        code("flutter run -d chrome --release --web-port=5555"),
        para(
          "Le mode --release est environ 5 fois plus rapide que le mode debug. " +
            "Le premier build prend 30 à 60 secondes. Une fois terminé, Chrome ouvre " +
            "automatiquement http://localhost:5555 et vous voyez le splash animé du logo " +
            "DIAPALER avec les trois orbites aux couleurs du drapeau du Sénégal."
        ),
        calloutTip(
          "Hot reload",
          "Si vous voulez modifier le code et voir les changements en temps réel, " +
            "lancez plutôt flutter run -d chrome --web-port=5555 (sans --release). " +
            "Tapez ensuite r dans le terminal pour rafraîchir, ou R pour redémarrer complètement."
        ),

        // ───────── Tester ─────────
        h1("5. Tester l'application"),
        para(
          "Une fois l'application ouverte dans Chrome, voici un parcours rapide " +
            "pour vérifier que tout fonctionne."
        ),
        h3("Premier lancement"),
        numbered("Le splash s'affiche pendant ~1 seconde avec l'animation du logo"),
        numbered("Vous arrivez sur l'écran « Je suis... » avec 3 rôles"),
        numbered("Choisissez Entrepreneur (sélectionné par défaut) puis CONTINUER"),
        h3("Inscription en 4 étapes"),
        numbered("Étape 1/4 — Identité : nom complet, email, sexe, date de naissance"),
        numbered("Étape 2/4 — Localisation : pays (Sénégal / Gambie / Mali) + ville"),
        numbered("Étape 3/4 — Profil pro : choisissez au moins 1 centre d'intérêt (obligatoire)"),
        numbered("Étape 4/4 — Sécurité : téléphone (8 chiffres) + mot de passe (6+ caractères)"),
        numbered("Validez avec S'INSCRIRE — votre compte est créé dans Firebase"),
        h3("Vérifier dans Firebase"),
        para(
          "Pendant que vous êtes inscrit, ouvrez la console Firebase pour voir vos données :"
        ),
        bullet("Authentification : votre compte apparaît avec son UID"),
        p(
          [
            text("    → ", { color: MUTED, size: 21 }),
            link(
              "console.firebase.google.com/project/diapaler-africa/authentication/users",
              "https://console.firebase.google.com/project/diapaler-africa/authentication/users"
            ),
          ],
          { spacing: { before: 40, after: 80 } }
        ),
        bullet("Realtime Database : un node /users/{uid} avec votre profil JSON complet"),
        p(
          [
            text("    → ", { color: MUTED, size: 21 }),
            link(
              "console.firebase.google.com/project/diapaler-africa/database",
              "https://console.firebase.google.com/project/diapaler-africa/database"
            ),
          ],
          { spacing: { before: 40, after: 80 } }
        ),
        h3("Dashboard et matching"),
        bullet("Le dashboard affiche votre prénom et 0 stats (normal pour un nouveau compte)"),
        bullet("La section « Mentors recommandés » filtre selon vos centres d'intérêt"),
        bullet("Tap sur l'icône + au centre de la barre du bas pour déposer un pitch"),
        bullet("Tap sur l'onglet Matching pour voir les 12 mentors avec recherche et filtres"),
        bullet("Tap sur un mentor pour voir sa fiche détaillée et la liste de ses entreprises"),
        h3("Modifier votre profil"),
        bullet("Tap sur votre avatar (en haut à gauche) pour ouvrir le menu profil"),
        bullet("Tap sur « Mon profil » pour voir la fiche complète"),
        bullet("Tap sur le crayon en haut à droite pour modifier"),
        bullet("Toute modification est sauvegardée en temps réel dans Firebase"),

        // ───────── Troubleshooting ─────────
        h1("6. En cas de problème"),
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [3500, 5860],
          rows: [
            tableRow(
              [
                { t: "Problème", w: 3500 },
                { t: "Solution", w: 5860 },
              ],
              true
            ),
            tableRow([
              { t: "flutter: command not found", w: 3500 },
              {
                t: "Flutter n'est pas dans le PATH. Redémarrez votre terminal. Si toujours rien, vérifiez les variables d'environnement Windows.",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "flutter pub get échoue", w: 3500 },
              {
                t: "Vérifiez votre connexion internet. Lancez flutter clean puis flutter pub get.",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "L'app reste sur écran blanc", w: 3500 },
              {
                t: "Faites Ctrl+Shift+R dans Chrome pour vider le cache. Vérifiez la console Chrome (F12) pour les erreurs.",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "Erreur Firebase au démarrage", w: 3500 },
              {
                t: "Vérifiez votre connexion internet. L'app a besoin d'internet pour Firebase Auth et la Realtime Database.",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "Build très lent (> 5 minutes)", w: 3500 },
              {
                t: "Premier build seulement. Les fois suivantes seront beaucoup plus rapides. Le mode --release est plus rapide que --debug.",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "Port 5555 déjà utilisé", w: 3500 },
              {
                t: "Changez le port : flutter run -d chrome --web-port=5556 (ou un autre numéro libre).",
                w: 5860,
              },
            ]),
            tableRow([
              { t: "Email déjà utilisé à l'inscription", w: 3500 },
              {
                t: "Quelqu'un de l'équipe a déjà créé un compte avec cet email. Utilisez un autre email ou connectez-vous avec celui existant.",
                w: 5860,
              },
            ]),
          ],
        }),
        p([text("", { size: 22 })], { spacing: { before: 200 } }),
        calloutWarn(
          "Si vous testez sur un téléphone Android : la version Android de Firebase " +
            "n'est pas configurée dans le repo. Pour la démo, restez sur Chrome (web)."
        ),

        // ───────── Récap commandes ─────────
        h1("7. Récapitulatif des commandes"),
        para(
          "Une fois le setup fait, voici les commandes que vous utiliserez le plus souvent :"
        ),
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [4500, 4860],
          rows: [
            tableRow(
              [
                { t: "Action", w: 4500 },
                { t: "Commande", w: 4860 },
              ],
              true
            ),
            tableRow([
              { t: "Lancer l'app (mode démo rapide)", w: 4500 },
              { t: "flutter run -d chrome --release --web-port=5555", w: 4860 },
            ]),
            tableRow([
              { t: "Lancer l'app (mode dev avec hot reload)", w: 4500 },
              { t: "flutter run -d chrome --web-port=5555", w: 4860 },
            ]),
            tableRow([
              { t: "Mettre à jour le code depuis GitHub", w: 4500 },
              { t: "git pull", w: 4860 },
            ]),
            tableRow([
              { t: "Réinstaller les dépendances", w: 4500 },
              { t: "flutter pub get", w: 4860 },
            ]),
            tableRow([
              { t: "Nettoyer le cache de build", w: 4500 },
              { t: "flutter clean", w: 4860 },
            ]),
            tableRow([
              { t: "Vérifier la configuration Flutter", w: 4500 },
              { t: "flutter doctor", w: 4860 },
            ]),
            tableRow([
              { t: "Mettre à jour Flutter", w: 4500 },
              { t: "flutter upgrade", w: 4860 },
            ]),
            tableRow([
              { t: "Construire la version web optimisée", w: 4500 },
              { t: "flutter build web --release", w: 4860 },
            ]),
          ],
        }),

        // ───────── Liens utiles ─────────
        h1("8. Liens utiles"),
        bullet("Repo GitHub du projet : github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa"),
        bullet("Documentation Flutter : docs.flutter.dev"),
        bullet("Console Firebase : console.firebase.google.com/project/diapaler-africa"),
        bullet("Documentation Firebase Flutter : firebase.flutter.dev"),
        bullet("Forum d'entraide Flutter : flutter.dev/community"),

        // ───────── Footer page ─────────
        p([text("", { size: 22 })], { spacing: { before: 600 } }),
        new Table({
          width: { size: 9360, type: WidthType.DXA },
          columnWidths: [9360],
          rows: [
            new TableRow({
              children: [
                new TableCell({
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
                    p(
                      text("« Connecte ton idée à ton succès »", {
                        color: "FFFFFF",
                        italics: true,
                        size: 24,
                        bold: true,
                      }),
                      { align: AlignmentType.CENTER }
                    ),
                    p(
                      text("— L'équipe DIAPALER AFRICA —", {
                        color: AMBER,
                        size: 20,
                      }),
                      { align: AlignmentType.CENTER }
                    ),
                  ],
                }),
              ],
            }),
          ],
        }),
        p(
          [text("Bon développement et bonne soutenance \u{1F1F8}\u{1F1F3}", { color: MUTED, size: 20 })],
          { align: AlignmentType.CENTER, spacing: { before: 200 } }
        ),
      ],
    },
  ],
});

Packer.toBuffer(doc).then((buffer) => {
  fs.writeFileSync(
    "C:/Users/HP/entreprenariat/docs/Guide_Installation_DIAPALER.docx",
    buffer
  );
  console.log("OK Guide_Installation_DIAPALER.docx generated.");
});

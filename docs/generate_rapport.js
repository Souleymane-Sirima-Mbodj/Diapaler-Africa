const fs = require("fs");
const sharp = require("sharp");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, ImageRun, AlignmentType, LevelFormat, ExternalHyperlink,
  HeadingLevel, BorderStyle, WidthType, ShadingType, PageNumber, PageBreak,
} = require("docx");

// Convertit un SVG (string) en buffer PNG via sharp.
async function svgToPng(svg, width = 1600, height = 700) {
  return await sharp(Buffer.from(svg, "utf8"), { density: 240 })
    .resize({ width, height, fit: "inside" })
    .png()
    .toBuffer();
}

// ─── Couleurs DIAPALER ────────────────────────────────────────────────────
const NAVY = "0A234B";
const NAVY_DEEP = "0F1729";
const BLUE = "1E50A0";
const BLUE_TINT = "DCE6F5";
const AMBER = "F59E0B";
const AMBER_SOFT = "FCD5A0";
const GREEN = "10B981";
const RED = "E31B23";
const PURPLE = "8B5CF6";
const MUTED = "6B7280";
const BORDER = "E5E7EB";
const SOFT = "F3F4F6";
const FLAG_GREEN = "00853F";
const FLAG_YELLOW = "FDEF42";
const FLAG_RED = "E31B23";

// ─── Helpers texte / structure ────────────────────────────────────────────
const p = (children, opts = {}) =>
  new Paragraph({
    children: Array.isArray(children) ? children : [children],
    spacing: opts.spacing ?? { before: 80, after: 80 },
    alignment: opts.align,
  });

const text = (str, opts = {}) =>
  new TextRun({
    text: str, bold: opts.bold, italics: opts.italics, color: opts.color,
    size: opts.size, font: opts.font, break: opts.break,
  });

const h1 = (str) => new Paragraph({
  heading: HeadingLevel.HEADING_1,
  children: [new TextRun({ text: str, color: NAVY, bold: true })],
  border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: AMBER, space: 4 } },
  spacing: { before: 360, after: 200 },
});
const h2 = (str) => new Paragraph({
  heading: HeadingLevel.HEADING_2,
  children: [new TextRun({ text: str, color: NAVY, bold: true })],
  spacing: { before: 280, after: 120 },
});
const h3 = (str) => new Paragraph({
  heading: HeadingLevel.HEADING_3,
  children: [new TextRun({ text: str, color: BLUE, bold: true })],
  spacing: { before: 200, after: 100 },
});

const para = (str, opts = {}) =>
  p(text(str, { color: NAVY_DEEP, ...opts }), { spacing: { before: 60, after: 80 } });

// Inline monospace (noms de fichiers, fonctions, classes)
const mono = (str) => new TextRun({
  text: str, font: "Consolas", color: BLUE, size: 21,
});

// Paragraphe avec mix texte + bouts de code en monospace.
// children = array of (string | TextRun)
const paraMix = (children, opts = {}) =>
  new Paragraph({
    children: children.map((c) => typeof c === "string"
      ? text(c, { color: NAVY_DEEP, size: 22 })
      : c),
    spacing: opts.spacing ?? { before: 60, after: 80 },
  });

// Bloc "Fichier(s) concerné(s) :" sous chaque sous-fonctionnalité
const fileLine = (label, files) =>
  new Paragraph({
    children: [
      text(label + " : ", { color: MUTED, size: 20, bold: true }),
      ...files.flatMap((f, i) => [
        mono(f),
        i < files.length - 1
          ? text(" · ", { color: MUTED, size: 20 })
          : text("", { size: 20 }),
      ]),
    ],
    spacing: { before: 20, after: 80 },
  });

const bullet = (str, level = 0) => new Paragraph({
  numbering: { reference: "bullets", level },
  children: [new TextRun({ text: str, color: NAVY_DEEP, size: 22 })],
  spacing: { before: 40, after: 40 },
});

const code = (cmd) => new Paragraph({
  children: [new TextRun({ text: cmd, font: "Consolas", color: NAVY_DEEP, size: 20 })],
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

const tableRow = (cells, isHeader = false) => new TableRow({
  tableHeader: isHeader,
  children: cells.map(c => new TableCell({
    width: { size: c.w, type: WidthType.DXA },
    shading: isHeader ? { type: ShadingType.CLEAR, fill: NAVY }
      : { type: ShadingType.CLEAR, fill: c.fill ?? "FFFFFF" },
    margins: { top: 100, bottom: 100, left: 140, right: 140 },
    borders: {
      top: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
      bottom: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
      left: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
      right: { style: BorderStyle.SINGLE, size: 4, color: BORDER },
    },
    children: [p(text(c.t, {
      color: isHeader ? "FFFFFF" : NAVY_DEEP,
      bold: isHeader || c.bold, size: 21,
    }))],
  })),
});

const calloutBlock = (label, content, fill, accent, emoji) => new Table({
  width: { size: 9360, type: WidthType.DXA },
  columnWidths: [9360],
  rows: [new TableRow({
    children: [new TableCell({
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
        p([text(emoji + " " + label, { bold: true, color: accent, size: 22 })]),
        p(text(content, { color: NAVY_DEEP, size: 21 })),
      ],
    })],
  })],
});

const link = (label, url) => new ExternalHyperlink({
  children: [new TextRun({ text: label, color: BLUE, underline: {} })],
  link: url,
});

// ─── SVG schemas ──────────────────────────────────────────────────────────
const SVG_HDR =
  `<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n` +
  `<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n`;

// 1) Navigation flow des écrans
const svgNavFlow = SVG_HDR + `<svg xmlns="http://www.w3.org/2000/svg" width="900" height="540" viewBox="0 0 900 540">
  <style>
    .box { fill: #fff; stroke: #${BLUE}; stroke-width: 2; rx: 10; }
    .boxNavy { fill: #${NAVY}; stroke: #${AMBER}; stroke-width: 2; rx: 10; }
    .boxAmber { fill: #${AMBER}; stroke: #${NAVY_DEEP}; stroke-width: 2; rx: 10; }
    .boxGreen { fill: #${GREEN}; stroke: #${NAVY_DEEP}; stroke-width: 2; rx: 10; }
    .label { font-family: Arial; font-weight: 700; font-size: 13px; fill: #${NAVY_DEEP}; text-anchor: middle; }
    .labelW { font-family: Arial; font-weight: 700; font-size: 13px; fill: #fff; text-anchor: middle; }
    .arrow { stroke: #${MUTED}; stroke-width: 2; fill: none; marker-end: url(#arrowhead); }
    .title { font-family: Arial; font-weight: 800; font-size: 18px; fill: #${NAVY}; }
    .sub { font-family: Arial; font-size: 11px; fill: #${MUTED}; text-anchor: middle; }
  </style>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#${MUTED}"/>
    </marker>
  </defs>
  <text x="20" y="26" class="title">Flow de navigation des écrans</text>

  <!-- Top row: Splash -->
  <rect class="boxNavy" x="380" y="55" width="140" height="50" rx="10"/>
  <text class="labelW" x="450" y="85">SplashPage</text>

  <!-- Role selection -->
  <rect class="boxNavy" x="380" y="135" width="140" height="50" rx="10"/>
  <text class="labelW" x="450" y="165">RoleSelection</text>

  <!-- Login / Signup -->
  <rect class="box" x="200" y="220" width="140" height="50" rx="10"/>
  <text class="label" x="270" y="250">LoginPage</text>

  <rect class="box" x="560" y="220" width="140" height="50" rx="10"/>
  <text class="label" x="630" y="250">SignUpPage (4 étapes)</text>

  <!-- Onboarding -->
  <rect class="boxAmber" x="560" y="305" width="140" height="50" rx="10"/>
  <text class="label" x="630" y="335">Onboarding</text>

  <!-- RootShell -->
  <rect class="boxGreen" x="380" y="395" width="140" height="50" rx="10"/>
  <text class="labelW" x="450" y="425">RootShell</text>

  <!-- Sub-screens -->
  <rect class="box" x="50" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="110" y="500">HomePage</text>

  <rect class="box" x="190" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="250" y="500">MatchingPage</text>

  <rect class="box" x="330" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="390" y="500">PitchPage</text>

  <rect class="box" x="470" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="530" y="500">ProfilePage</text>

  <rect class="box" x="610" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="670" y="500">EditProfile</text>

  <rect class="box" x="750" y="475" width="120" height="40" rx="8"/>
  <text class="label" x="810" y="500">MentorDetail</text>

  <!-- Arrows -->
  <path class="arrow" d="M 450 105 L 450 130"/>
  <path class="arrow" d="M 420 185 L 320 218"/>
  <path class="arrow" d="M 480 185 L 580 218"/>
  <path class="arrow" d="M 630 270 L 630 302"/>
  <path class="arrow" d="M 270 270 L 415 393"/>
  <path class="arrow" d="M 630 355 L 485 393"/>
  <path class="arrow" d="M 420 445 L 110 472"/>
  <path class="arrow" d="M 430 445 L 250 472"/>
  <path class="arrow" d="M 440 445 L 390 472"/>
  <path class="arrow" d="M 460 445 L 530 472"/>
  <path class="arrow" d="M 470 445 L 670 472"/>
  <path class="arrow" d="M 480 445 L 810 472"/>

  <text class="sub" x="450" y="535">RootShell pivote vers les pages de détail, profil et pitch</text>
</svg>`;

// 2) Architecture client / Firebase
const svgArch = SVG_HDR + `<svg xmlns="http://www.w3.org/2000/svg" width="900" height="380" viewBox="0 0 900 380">
  <style>
    .col { fill: #fff; stroke: #${BORDER}; stroke-width: 1.5; rx: 14; }
    .colHead { font-family: Arial; font-weight: 800; font-size: 14px; fill: #${NAVY}; text-anchor: middle; }
    .item { fill: #${SOFT}; stroke: #${BLUE_TINT}; stroke-width: 1; rx: 8; }
    .label { font-family: Arial; font-weight: 600; font-size: 12px; fill: #${NAVY_DEEP}; text-anchor: middle; }
    .ctx { font-family: Arial; font-size: 10px; fill: #${MUTED}; text-anchor: middle; }
    .firebase { fill: #${AMBER_SOFT}; stroke: #${AMBER}; stroke-width: 1; rx: 8; }
    .arrow { stroke: #${BLUE}; stroke-width: 2; fill: none; marker-end: url(#a2); }
    .title { font-family: Arial; font-weight: 800; font-size: 18px; fill: #${NAVY}; }
  </style>
  <defs>
    <marker id="a2" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#${BLUE}"/>
    </marker>
  </defs>
  <text x="20" y="26" class="title">Architecture client / serveur</text>

  <!-- Frontend -->
  <rect class="col" x="30" y="60" width="240" height="290"/>
  <text class="colHead" x="150" y="88">FRONTEND (Flutter)</text>
  <rect class="item" x="50" y="105" width="200" height="40" rx="8"/>
  <text class="label" x="150" y="130">Pages (11 écrans)</text>
  <rect class="item" x="50" y="155" width="200" height="40" rx="8"/>
  <text class="label" x="150" y="180">Widgets partagés (13)</text>
  <rect class="item" x="50" y="205" width="200" height="40" rx="8"/>
  <text class="label" x="150" y="230">UserProfileController</text>
  <text class="ctx" x="150" y="252">(ValueNotifier)</text>
  <rect class="item" x="50" y="275" width="200" height="40" rx="8"/>
  <text class="label" x="150" y="300">Theme + AppColors</text>

  <!-- Services -->
  <rect class="col" x="330" y="60" width="240" height="290"/>
  <text class="colHead" x="450" y="88">SERVICES</text>
  <rect class="item" x="350" y="105" width="200" height="60" rx="8"/>
  <text class="label" x="450" y="130">AuthService</text>
  <text class="ctx" x="450" y="150">signIn / signUp / signOut</text>
  <rect class="item" x="350" y="180" width="200" height="60" rx="8"/>
  <text class="label" x="450" y="205">DatabaseService</text>
  <text class="ctx" x="450" y="225">CRUD profil JSON</text>
  <rect class="item" x="350" y="255" width="200" height="60" rx="8"/>
  <text class="label" x="450" y="280">recommendedMentorsFor()</text>
  <text class="ctx" x="450" y="300">algo de matching</text>

  <!-- Firebase -->
  <rect class="col" x="630" y="60" width="240" height="290"/>
  <text class="colHead" x="750" y="88">FIREBASE</text>
  <rect class="firebase" x="650" y="105" width="200" height="50" rx="8"/>
  <text class="label" x="750" y="130">Firebase Auth</text>
  <text class="ctx" x="750" y="148">email / password</text>
  <rect class="firebase" x="650" y="170" width="200" height="80" rx="8"/>
  <text class="label" x="750" y="195">Realtime Database</text>
  <text class="ctx" x="750" y="215">/users/{uid}</text>
  <text class="ctx" x="750" y="232">eur3 (Belgique)</text>
  <rect class="firebase" x="650" y="265" width="200" height="50" rx="8" fill="#${SOFT}" stroke="#${MUTED}" stroke-dasharray="4,4"/>
  <text class="label" x="750" y="290" fill="#${MUTED}">Storage / FCM</text>
  <text class="ctx" x="750" y="308">à venir</text>

  <!-- arrows -->
  <path class="arrow" d="M 250 130 L 348 130"/>
  <path class="arrow" d="M 250 180 L 348 200"/>
  <path class="arrow" d="M 550 130 L 648 130"/>
  <path class="arrow" d="M 550 200 L 648 195"/>
</svg>`;

// 3) Inscription en 4 étapes
const svgSignup = SVG_HDR + `<svg xmlns="http://www.w3.org/2000/svg" width="900" height="280" viewBox="0 0 900 280">
  <style>
    .step { fill: #${NAVY}; rx: 12; }
    .stepInactive { fill: #${SOFT}; stroke: #${BORDER}; stroke-width: 1.5; rx: 12; }
    .stepNum { font-family: Arial; font-weight: 900; font-size: 28px; fill: #${AMBER}; text-anchor: middle; }
    .stepTitle { font-family: Arial; font-weight: 800; font-size: 13px; fill: #fff; text-anchor: middle; }
    .stepDesc { font-family: Arial; font-size: 10.5px; fill: #${BLUE_TINT}; text-anchor: middle; }
    .arrow { stroke: #${AMBER}; stroke-width: 3; fill: none; marker-end: url(#a3); }
    .title { font-family: Arial; font-weight: 800; font-size: 18px; fill: #${NAVY}; }
    .endbox { fill: #${GREEN}; rx: 12; }
    .endTitle { font-family: Arial; font-weight: 900; font-size: 14px; fill: #fff; text-anchor: middle; }
  </style>
  <defs>
    <marker id="a3" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#${AMBER}"/>
    </marker>
  </defs>
  <text x="20" y="26" class="title">Inscription en 4 étapes</text>

  <rect class="step" x="40" y="70" width="170" height="170"/>
  <text class="stepNum" x="125" y="115">1</text>
  <text class="stepTitle" x="125" y="145">IDENTITÉ</text>
  <text class="stepDesc" x="125" y="170">• Rôle</text>
  <text class="stepDesc" x="125" y="185">• Nom complet</text>
  <text class="stepDesc" x="125" y="200">• Email</text>
  <text class="stepDesc" x="125" y="215">• Sexe</text>
  <text class="stepDesc" x="125" y="230">• Date naissance + âge</text>

  <path class="arrow" d="M 215 155 L 250 155"/>

  <rect class="step" x="255" y="70" width="170" height="170"/>
  <text class="stepNum" x="340" y="115">2</text>
  <text class="stepTitle" x="340" y="145">LOCALISATION</text>
  <text class="stepDesc" x="340" y="170">• Pays (3) *</text>
  <text class="stepDesc" x="340" y="185">• Ville (cascade) *</text>
  <text class="stepDesc" x="340" y="200">• Adresse (opt)</text>

  <path class="arrow" d="M 430 155 L 465 155"/>

  <rect class="step" x="470" y="70" width="170" height="170"/>
  <text class="stepNum" x="555" y="115">3</text>
  <text class="stepTitle" x="555" y="145">PROFIL PRO</text>
  <text class="stepDesc" x="555" y="170">• À propos (opt)</text>
  <text class="stepDesc" x="555" y="185">• LinkedIn (opt)</text>
  <text class="stepDesc" x="555" y="200">• Centres d&apos;intérêt *</text>
  <text class="stepDesc" x="555" y="215">(au moins 1)</text>

  <path class="arrow" d="M 645 155 L 680 155"/>

  <rect class="step" x="685" y="70" width="170" height="170"/>
  <text class="stepNum" x="770" y="115">4</text>
  <text class="stepTitle" x="770" y="145">SÉCURITÉ</text>
  <text class="stepDesc" x="770" y="170">• Téléphone *</text>
  <text class="stepDesc" x="770" y="185">• Mot de passe *</text>
  <text class="stepDesc" x="770" y="200">• Confirmation</text>
  <text class="stepDesc" x="770" y="215">• CGU (checkbox)</text>

  <rect class="endbox" x="350" y="252" width="200" height="20" rx="6"/>
  <text class="endTitle" x="450" y="266">→ S&apos;INSCRIRE → Realtime DB</text>
</svg>`;

// 4) Algo de recommandation
const svgReco = SVG_HDR + `<svg xmlns="http://www.w3.org/2000/svg" width="900" height="380" viewBox="0 0 900 380">
  <style>
    .src { fill: #${BLUE_TINT}; stroke: #${BLUE}; stroke-width: 1.5; rx: 10; }
    .algo { fill: #${NAVY}; stroke: #${AMBER}; stroke-width: 2; rx: 12; }
    .out { fill: #${AMBER_SOFT}; stroke: #${AMBER}; stroke-width: 1.5; rx: 10; }
    .label { font-family: Arial; font-weight: 700; font-size: 13px; fill: #${NAVY_DEEP}; text-anchor: middle; }
    .labelW { font-family: Arial; font-weight: 800; font-size: 14px; fill: #fff; text-anchor: middle; }
    .ctx { font-family: Arial; font-size: 10.5px; fill: #${MUTED}; text-anchor: middle; }
    .arrow { stroke: #${AMBER}; stroke-width: 2; fill: none; marker-end: url(#a4); }
    .title { font-family: Arial; font-weight: 800; font-size: 18px; fill: #${NAVY}; }
  </style>
  <defs>
    <marker id="a4" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
      <polygon points="0 0, 10 3, 0 6" fill="#${AMBER}"/>
    </marker>
  </defs>
  <text x="20" y="26" class="title">Algorithme de recommandation des mentors</text>

  <!-- 3 sources -->
  <rect class="src" x="50" y="65" width="200" height="60"/>
  <text class="label" x="150" y="92">Secteur principal</text>
  <text class="ctx" x="150" y="110">profile.sector</text>

  <rect class="src" x="50" y="160" width="200" height="60"/>
  <text class="label" x="150" y="188">Projets actifs</text>
  <text class="ctx" x="150" y="206">profile.projects.sectors</text>

  <rect class="src" x="50" y="255" width="200" height="60"/>
  <text class="label" x="150" y="283">Centres d&apos;intérêt</text>
  <text class="ctx" x="150" y="301">profile.interests</text>

  <!-- algo -->
  <rect class="algo" x="380" y="120" width="180" height="140"/>
  <text class="labelW" x="470" y="160">recommendedMentorsFor()</text>
  <text class="ctx" x="470" y="180" fill="#${BLUE_TINT}">union des secteurs</text>
  <text class="ctx" x="470" y="195" fill="#${BLUE_TINT}">filtre overlap &gt; 0</text>
  <text class="ctx" x="470" y="210" fill="#${BLUE_TINT}">tri par overlap</text>
  <text class="ctx" x="470" y="225" fill="#${BLUE_TINT}">puis compatibility</text>
  <text class="ctx" x="470" y="245" fill="#${AMBER}">live (ValueListenable)</text>

  <!-- output -->
  <rect class="out" x="690" y="65" width="180" height="55"/>
  <text class="label" x="780" y="92">Top mentor #1</text>
  <text class="ctx" x="780" y="108">overlap × compat</text>

  <rect class="out" x="690" y="135" width="180" height="55"/>
  <text class="label" x="780" y="162">Top mentor #2</text>
  <text class="ctx" x="780" y="178">→ HomePage</text>

  <rect class="out" x="690" y="205" width="180" height="105"/>
  <text class="label" x="780" y="240">Liste complète triée</text>
  <text class="ctx" x="780" y="260">→ MatchingPage</text>
  <text class="ctx" x="780" y="278">avec recherche</text>
  <text class="ctx" x="780" y="294">+ filtres pills</text>

  <!-- arrows -->
  <path class="arrow" d="M 250 95 L 378 165"/>
  <path class="arrow" d="M 250 190 L 378 190"/>
  <path class="arrow" d="M 250 285 L 378 215"/>
  <path class="arrow" d="M 560 165 L 688 92"/>
  <path class="arrow" d="M 560 190 L 688 162"/>
  <path class="arrow" d="M 560 220 L 688 230"/>
</svg>`;

const pngImage = (pngBuffer, w = 600, h = 280) =>
  p([new ImageRun({
    type: "png",
    data: pngBuffer,
    transformation: { width: w, height: h },
    altText: { title: "Schéma", description: "Schéma DIAPALER", name: "Schéma" },
  })], { align: AlignmentType.CENTER, spacing: { before: 200, after: 200 } });

// ─── Génération PNG des schémas avant construction du doc ─────────────────
async function build() {
  const pngArch = await svgToPng(svgArch, 1600, 680);
  const pngNavFlow = await svgToPng(svgNavFlow, 1600, 960);
  const pngSignup = await svgToPng(svgSignup, 1600, 500);
  const pngReco = await svgToPng(svgReco, 1600, 680);

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
        children: [p([
          text("DIAPAL", { bold: true, color: FLAG_GREEN, size: 18 }),
          text("ER", { bold: true, color: AMBER, size: 18 }),
          text("  AFRICA", { bold: true, color: FLAG_RED, size: 18 }),
          new TextRun({ text: "\tRapport technique", color: MUTED, size: 18 }),
        ])],
      }),
    },
    footers: {
      default: new Footer({
        children: [p([
          text("ESP Dakar  |  L3 GLSI/GLSIB  |  2025 – 2026", { color: MUTED, size: 18 }),
          new TextRun({ text: "\tPage ", color: MUTED, size: 18 }),
          new TextRun({ children: [PageNumber.CURRENT], color: MUTED, size: 18 }),
          text(" / ", { color: MUTED, size: 18 }),
          new TextRun({ children: [PageNumber.TOTAL_PAGES], color: MUTED, size: 18 }),
        ])],
      }),
    },
    children: [
      // ───── Page de garde ─────
      p([text("", { size: 200 })], { spacing: { before: 1800 } }),
      p([
        text("DIAPAL", { bold: true, color: FLAG_GREEN, size: 96 }),
        text("ER", { bold: true, color: AMBER, size: 96 }),
      ], { align: AlignmentType.CENTER }),
      p([text("AFRICA", { bold: true, color: FLAG_RED, size: 56 })],
        { align: AlignmentType.CENTER, spacing: { after: 200 } }),
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
                { color: "FFFFFF", size: 22 }), { align: AlignmentType.CENTER }),
            ],
          })],
        })],
      }),
      p([text(" ", { size: 22 })], { spacing: { before: 400 } }),
      p([text("Plateforme mobile Flutter de mentorat et de mise en relation ",
        { color: NAVY_DEEP, size: 22 })], { align: AlignmentType.CENTER }),
      p([text("entrepreneuriale au Sénégal",
        { color: NAVY_DEEP, size: 22, bold: true })], { align: AlignmentType.CENTER }),
      p([text(" ", { size: 22 })], { spacing: { before: 600 } }),
      p([text("Document destiné aux développeurs · Mai 2026",
        { color: MUTED, size: 20, italics: true })], { align: AlignmentType.CENTER }),
      p([text("ESP Dakar  ·  Département Génie Informatique  ·  L3 GLSI/GLSIB",
        { color: MUTED, size: 20 })], { align: AlignmentType.CENTER }),
      p([text(" ", { size: 24 })], { spacing: { before: 400 } }),
      p([text("Repo : ", { color: MUTED, size: 20 }),
        link("github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa",
          "https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa")],
        { align: AlignmentType.CENTER }),

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

      // ───── 2. ARCHITECTURE ─────
      h1("2. Architecture & schémas"),
      h2("2.1 Architecture client / serveur"),
      para(
        "L'app Flutter (web Chrome pour la démo, Android prévu Livrable 1) communique " +
        "avec deux services Firebase. La logique d'accès aux services est isolée dans des " +
        "wrappers (services/) pour pouvoir évoluer ou tester indépendamment de l'UI."
      ),
      pngImage(pngArch, 600, 255),

      h2("2.2 Flow de navigation des écrans"),
      para(
        "Tous les écrans sont accessibles depuis le RootShell (bottom nav 2 onglets + " +
        "FAB central pour le pitch). Le splash effectue une auto-login si la session est " +
        "active, sinon route vers la sélection de rôle."
      ),
      pngImage(pngNavFlow, 600, 360),

      h2("2.3 Inscription en 4 étapes"),
      para(
        "Pour réduire la charge cognitive, l'inscription est découpée en 4 sections " +
        "thématiques. Chaque étape valide localement avant de débloquer la suivante. " +
        "Centres d'intérêt obligatoires (≥ 1) pour permettre le matching personnalisé."
      ),
      pngImage(pngSignup, 600, 188),

      h2("2.4 Algorithme de recommandation"),
      para(
        "Les mentors recommandés sur le dashboard sont calculés en live à partir de " +
        "trois sources combinées dans le profil utilisateur : le secteur déclaré, les " +
        "secteurs des projets actifs et les centres d'intérêt."
      ),
      pngImage(pngReco, 600, 255),

      // ───── 3. STACK TECHNIQUE ─────
      h1("3. Stack technique"),
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
        BLUE_TINT, BLUE, "💡"
      ),

      // ───── 4. STRUCTURE DU CODE ─────
      h1("4. Structure du code"),
      para(
        "Tout est dans le dossier lib/. Pas de sur-engineering : un fichier par écran, " +
        "un fichier par widget réutilisable. Les services Firebase sont isolés dans services/."
      ),
      code(
        "lib/\n" +
        "├── main.dart                    Entry point + Firebase init parallèle au splash\n" +
        "├── firebase_options.dart        Config Firebase Web (généré manuellement)\n" +
        "├── theme/\n" +
        "│   └── app_theme.dart           AppColors (drapeau Sénégal) + ThemeData light\n" +
        "├── data/\n" +
        "│   ├── user_profile.dart        Modèle UserProfile, Project, Gender + Controller\n" +
        "│   ├── mock_data.dart           12 mentors sénégalais + recommendedMentorsFor()\n" +
        "│   ├── countries.dart           Pays/villes (Sénégal/Gambie/Mali)\n" +
        "│   └── quotes.dart              8 citations (proverbes wolof + entrepreneurs)\n" +
        "├── services/\n" +
        "│   ├── auth_service.dart        Wrapper FirebaseAuth + erreurs FR\n" +
        "│   └── database_service.dart    CRUD profil sur Realtime Database\n" +
        "├── screens/                     11 pages\n" +
        "│   ├── splash_page.dart\n" +
        "│   ├── role_selection_page.dart\n" +
        "│   ├── login_page.dart\n" +
        "│   ├── signup_page.dart\n" +
        "│   ├── onboarding_page.dart\n" +
        "│   ├── root_shell.dart\n" +
        "│   ├── home_page.dart\n" +
        "│   ├── matching_page.dart\n" +
        "│   ├── mentor_detail_page.dart\n" +
        "│   ├── profile_page.dart\n" +
        "│   ├── edit_profile_page.dart\n" +
        "│   ├── add_project_page.dart\n" +
        "│   └── pitch_page.dart\n" +
        "└── widgets/                     13 widgets partagés\n" +
        "    ├── animated_counter.dart\n" +
        "    ├── avatar.dart\n" +
        "    ├── bottom_nav.dart\n" +
        "    ├── cursor_follower.dart\n" +
        "    ├── diapaler_logo.dart\n" +
        "    ├── flag_strip.dart\n" +
        "    ├── hover_glow_card.dart\n" +
        "    ├── mentor_card.dart\n" +
        "    ├── profile_sheet.dart\n" +
        "    ├── quote_carousel.dart\n" +
        "    ├── rotating_tagline.dart\n" +
        "    ├── section_header.dart\n" +
        "    └── skeleton.dart"
      ),

      // ───── 5. FONCTIONNALITÉS LIVRÉES ─────
      h1("5. Fonctionnalités livrées"),
      para(
        "Pour chaque fonctionnalité ci-dessous, on précise ce qu'elle fait, le ou les " +
        "fichiers concernés, et les principales fonctions ou classes à connaître pour " +
        "intervenir dessus."
      ),

      h2("5.1 Authentification Firebase"),
      paraMix([
        "Toute la logique d'authentification est isolée dans un service dédié qui wrap ",
        mono("FirebaseAuth.instance"),
        ". L'app n'appelle jamais directement Firebase — elle passe toujours par ",
        mono("AuthService"),
        ". Les méthodes ",
        mono("signIn()"),
        ", ",
        mono("signUp()"),
        " et ",
        mono("signOut()"),
        " retournent les ",
        mono("UserCredential"),
        " standards. La méthode ",
        mono("humanError()"),
        " traduit les 12 codes d'erreur Firebase en français lisible (« Email ou mot de passe incorrect », « Mot de passe trop faible », etc.).",
      ]),
      paraMix([
        "Au moment de l'inscription, on crée immédiatement le node ",
        mono("/users/{uid}"),
        " dans la Realtime Database via ",
        mono("DatabaseService.createUserProfile()"),
        ". À chaque connexion, ",
        mono("LoginPage._signIn()"),
        " recharge le profil distant et appelle ",
        mono("UserProfileController.update()"),
        " pour rafraîchir l'UI globalement.",
      ]),
      fileLine("Fichiers", [
        "lib/services/auth_service.dart",
        "lib/services/database_service.dart",
        "lib/firebase_options.dart",
        "lib/main.dart",
      ]),

      h2("5.2 Auto-login au démarrage"),
      paraMix([
        "Le splash sert aussi de gate d'authentification. Dans ",
        mono("main.dart"),
        ", la variable globale ",
        mono("firebaseReady"),
        " lance ",
        mono("Firebase.initializeApp()"),
        " en parallèle de ",
        mono("runApp()"),
        " — l'animation tourne pendant l'init. La méthode ",
        mono("SplashPage._bootstrap()"),
        " attend Firebase puis vérifie ",
        mono("AuthService.currentUid"),
        " : si la session est active, on lit le profil distant via ",
        mono("DatabaseService.readUserProfile(uid)"),
        " et on route directement vers ",
        mono("RootShell"),
        ". Sinon on tombe sur ",
        mono("RoleSelectionPage"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/main.dart",
        "lib/screens/splash_page.dart",
      ]),

      h2("5.3 Inscription Entrepreneur en 4 étapes"),
      paraMix([
        "Toute l'inscription est dans un seul ",
        mono("StatefulWidget"),
        " — ",
        mono("SignUpPage"),
        " — qui maintient un compteur ",
        mono("_step (0..3)"),
        " et 4 builders distincts (",
        mono("_buildStep1"),
        " à ",
        mono("_buildStep4"),
        "). Chaque étape a son getter de validation : ",
        mono("_step1Valid"),
        ", ",
        mono("_step2Valid"),
        ", ",
        mono("_step3Valid"),
        ", ",
        mono("_step4Valid"),
        ". Le bouton CONTINUER appelle ",
        mono("_next()"),
        " qui incrémente ",
        mono("_step"),
        " ou déclenche ",
        mono("_submit()"),
        " sur la dernière étape.",
      ]),
      paraMix([
        "Les validations live utilisent des regex (",
        mono("_emailRegex"),
        "), un calcul de force de mot de passe (",
        mono("_computeStrength()"),
        " → 0..4 affiché par ",
        mono("_StrengthMeter"),
        "), et un formatter de téléphone custom (",
        mono("_PhoneFormatter"),
        ") qui transforme ",
        mono("771234567"),
        " en ",
        mono("77 123 45 67"),
        " automatiquement.",
      ]),
      paraMix([
        "Les pays et villes en cascade viennent de ",
        mono("data/countries.dart"),
        " : 3 pays (Sénégal, Gambie, Mali) avec leurs villes. Quand l'utilisateur change le pays, on appelle ",
        mono("citiesOf(country).first"),
        " pour reset la ville. La date de naissance ouvre un ",
        mono("showDatePicker()"),
        " et l'âge live est calculé par ",
        mono("ageFromBirthDate(_birthDate)"),
        ".",
      ]),
      paraMix([
        "Pour Mentor et Investisseur, le formulaire est volontairement vide — on affiche ",
        mono("SizedBox.shrink()"),
        " à la place du contenu. Le bouton CONTINUER reste désactivé tant que ",
        mono("_role != UserRole.entrepreneur"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/screens/signup_page.dart",
        "lib/data/countries.dart",
      ]),

      h2("5.4 Profil utilisateur partagé en mémoire"),
      paraMix([
        "L'état du profil est centralisé dans ",
        mono("UserProfileController.profile"),
        " — un ",
        mono("ValueNotifier<UserProfile>"),
        " unique pour toute l'app. Toutes les vues qui affichent ou modifient le profil l'écoutent via ",
        mono("ValueListenableBuilder<UserProfile>"),
        " : ",
        mono("HomePage._Header"),
        ", ",
        mono("ProfilePage"),
        ", ",
        mono("ProfileSheet"),
        ", ",
        mono("EditProfilePage"),
        ". Quand on appelle ",
        mono("UserProfileController.update(next)"),
        ", toutes ces vues se rebuild instantanément.",
      ]),
      paraMix([
        "Le modèle ",
        mono("UserProfile"),
        " est ",
        mono("@immutable"),
        " avec un ",
        mono("copyWith()"),
        " complet. Les champs : ",
        mono("firstName, lastName, email, phone, gender, birthDate, address, city, country, sector, role, bio, linkedin, interests, projects, mentorsActive, sessionsCount, favoritesCount, score"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/data/user_profile.dart",
      ]),

      h2("5.5 Persistance dans la Realtime Database"),
      paraMix([
        "Les méthodes CRUD du profil sont dans ",
        mono("DatabaseService"),
        " : ",
        mono("createUserProfile(uid, profile)"),
        ", ",
        mono("updateUserProfile(uid, profile)"),
        ", ",
        mono("readUserProfile(uid)"),
        ". La sérialisation se fait via les helpers privés ",
        mono("_toMap(p)"),
        " et ",
        mono("_fromMap(m)"),
        " qui gèrent la conversion ",
        mono("Gender ↔ String"),
        ", ",
        mono("DateTime ↔ ISO 8601"),
        ", et la liste imbriquée des projets.",
      ]),
      paraMix([
        "À chaque sauvegarde, on ajoute ",
        mono("ServerValue.timestamp"),
        " sur le champ ",
        mono("updatedAt"),
        " — utile pour les futurs sync conflicts.",
      ]),
      code(
        "/users/{uid}\n" +
        "  ├── firstName, lastName, email, phone\n" +
        "  ├── gender, birthDate, address, city, country\n" +
        "  ├── sector, role, bio, linkedin\n" +
        "  ├── interests: [String]\n" +
        "  ├── projects: [{ id, name, description, sector, step, totalSteps }]\n" +
        "  ├── mentorsActive, sessionsCount, favoritesCount, score\n" +
        "  └── updatedAt (ServerValue.timestamp)"
      ),
      fileLine("Fichiers", [
        "lib/services/database_service.dart",
      ]),

      h2("5.6 Multi-projets avec règle « 1 actif à la fois »"),
      paraMix([
        "Le modèle ",
        mono("Project"),
        " est défini dans ",
        mono("user_profile.dart"),
        " avec ses helpers ",
        mono("isCompleted"),
        " (step ≥ totalSteps) et ",
        mono("progress"),
        " (step / totalSteps). La règle métier est centralisée dans le getter ",
        mono("UserProfile.canStartNewProject"),
        " : il retourne ",
        mono("true"),
        " uniquement si tous les projets existants sont terminés (ou s'il n'y en a aucun).",
      ]),
      paraMix([
        "L'ajout passe par ",
        mono("UserProfileController.addProject(p)"),
        " qui vérifie d'abord la règle. La page ",
        mono("AddProjectPage"),
        " présente un formulaire simple (nom + secteur + description) avec validation. Le bouton « + Nouveau projet » sur ",
        mono("ProfilePage"),
        " est grisé via ",
        mono("_NewProjectButton(canStart: profile.canStartNewProject)"),
        ".",
      ]),
      paraMix([
        "Quand l'utilisateur n'a aucun projet, le hero du dashboard bascule en mode empty state via ",
        mono("_EmptyProjectHero"),
        " — un gros bouton + ambre cliquable qui ouvre ",
        mono("AddProjectPage"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/data/user_profile.dart",
        "lib/screens/profile_page.dart",
        "lib/screens/add_project_page.dart",
        "lib/screens/home_page.dart",
      ]),

      h2("5.7 Dashboard Entrepreneur"),
      paraMix([
        "Le dashboard ",
        mono("HomePage"),
        " est un ",
        mono("StatefulWidget"),
        " avec un flag ",
        mono("_loading"),
        " qui affiche les skeletons shimmer pendant 900 ms au boot. Le ",
        mono("RefreshIndicator"),
        " déclenche ",
        mono("_refresh()"),
        " qui simule un reload (700 ms).",
      ]),
      paraMix([
        "Tous les sous-blocs réagissent au profile : ",
        mono("_Header"),
        " (greeting + avatar + tagline), ",
        mono("_ProjectHero"),
        " (bascule entre la card projet et l'empty state), ",
        mono("_StatsStrip"),
        " (5 mini-cards lues du profile via ",
        mono("ValueListenableBuilder"),
        "), et ",
        mono("_RecommendedMentors"),
        " (top 2 mentors filtrés en live).",
      ]),
      paraMix([
        "Le greeting personnalisé utilise ",
        mono("p.firstName"),
        ". La tagline rotative ",
        mono("RotatingTagline"),
        " est un widget qui alterne les 8 citations toutes les 6 secondes via un ",
        mono("Timer.periodic"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/screens/home_page.dart",
        "lib/widgets/rotating_tagline.dart",
        "lib/widgets/skeleton.dart",
      ]),

      h2("5.8 Algorithme de recommandation"),
      paraMix([
        "La fonction ",
        mono("recommendedMentorsFor()"),
        " dans ",
        mono("data/mock_data.dart"),
        " prend trois sources de secteurs : ",
        mono("userSector"),
        ", ",
        mono("userInterests"),
        ", ",
        mono("projectSectors"),
        ". Elle calcule pour chaque mentor le nombre de secteurs en commun (",
        mono("overlap"),
        "), filtre ceux avec overlap > 0, et trie d'abord par overlap décroissant puis par ",
        mono("compatibility"),
        ".",
      ]),
      paraMix([
        "Le widget ",
        mono("_RecommendedMentors"),
        " (dans ",
        mono("home_page.dart"),
        ") l'appelle dans un ",
        mono("ValueListenableBuilder"),
        " : dès que l'utilisateur modifie ses centres d'intérêt dans ",
        mono("EditProfilePage"),
        ", le dashboard se rafraîchit avec les nouvelles recommandations.",
      ]),
      fileLine("Fichiers", [
        "lib/data/mock_data.dart",
        "lib/screens/home_page.dart",
      ]),

      h2("5.9 Matching de mentors"),
      paraMix([
        "La page ",
        mono("MatchingPage"),
        " contient les 12 mentors hardcodés dans ",
        mono("mock_data.dart"),
        ". Le filtrage combine recherche texte (",
        mono("Mentor.matches(query)"),
        " — case-insensitive sur nom, secteurs, ville, titre), un filtre de secteur (pills horizontales) et un filtre de ville (",
        mono("DropdownButton"),
        "). Le getter ",
        mono("_filtered"),
        " applique les 3 filtres et trie par compatibility.",
      ]),
      paraMix([
        "Au tap sur une carte, ",
        mono("MentorCard"),
        " ouvre ",
        mono("MentorDetailPage"),
        " — un ",
        mono("CustomScrollView"),
        " avec ",
        mono("SliverAppBar"),
        " gradient navy. La page affiche 4 stats (note, match, années, avis), les domaines, la liste complète des entreprises (",
        mono("_CompaniesList"),
        "), les créneaux (",
        mono("_SlotsRow"),
        "), et 2 CTA (Message / Réserver).",
      ]),
      fileLine("Fichiers", [
        "lib/screens/matching_page.dart",
        "lib/screens/mentor_detail_page.dart",
        "lib/widgets/mentor_card.dart",
        "lib/data/mock_data.dart",
      ]),

      h2("5.10 Dépôt de pitch"),
      paraMix([
        "Accessible via le ",
        mono("FloatingActionButton"),
        " ambre central de ",
        mono("RootShell"),
        " (placement ",
        mono("centerDocked"),
        "). La page ",
        mono("PitchPage"),
        " utilise un compteur ",
        mono("_step (0..2)"),
        " avec ",
        mono("_buildStep1"),
        " (titre + élévator pitch), ",
        mono("_buildStep2"),
        " (secteur via dropdown des 31 secteurs définis dans ",
        mono("allSectors"),
        ", + description), et ",
        mono("_buildStep3"),
        " (montant FCFA + zones d'upload pointillées via ",
        mono("DottedBorder"),
        " + ",
        mono("_DottedPainter"),
        ").",
      ]),
      paraMix([
        "À la validation, on affiche un ",
        mono("SnackBar"),
        " vert et on ferme la page. Le pitch n'est pas encore persisté — c'est sur la TODO Livrable 1.",
      ]),
      fileLine("Fichiers", [
        "lib/screens/pitch_page.dart",
        "lib/screens/root_shell.dart",
      ]),

      h2("5.11 UX premium"),
      paraMix([
        "Le splash ",
        mono("SplashPage"),
        " utilise un ",
        mono("AnimationController"),
        " 1.1 s avec un mixin ",
        mono("TickerProviderStateMixin"),
        ". Les 3 orbites drapeau s'allument en cascade via des ",
        mono("Interval"),
        " (0.30→0.50, 0.40→0.60, 0.50→0.70).",
      ]),
      paraMix([
        "Le curseur étoiles est dans ",
        mono("CursorFollower"),
        " (web/desktop seulement, no-op via ",
        mono("kIsWeb"),
        "). Il maintient une liste de ",
        mono("_Star"),
        " avec position, couleur (drapeau Sénégal), durée de vie 900 ms. Un ",
        mono("Ticker"),
        " supprime les étoiles expirées et le ",
        mono("CustomPainter"),
        " ",
        mono("_StarsPainter"),
        " les redessine.",
      ]),
      paraMix([
        "Le hover glow sur les cards est implémenté dans ",
        mono("HoverGlowCard"),
        " via ",
        mono("MouseRegion"),
        " + ",
        mono("AnimatedContainer"),
        " (scale 1.015 + shadow ambré). Toutes les cards interactives passent par ce wrapper : ",
        mono("MentorCard"),
        ", ",
        mono("_StatCard"),
        ", ",
        mono("_DerCard"),
        ".",
      ]),
      paraMix([
        "Les compteurs animés utilisent ",
        mono("AnimatedCounter"),
        " (TweenAnimationBuilder + ",
        mono("Curves.easeOutQuart"),
        " sur 1.1 s). Les transitions de page sont configurées globalement dans ",
        mono("main.dart"),
        " via ",
        mono("_FadeThroughBuilder"),
        ".",
      ]),
      fileLine("Fichiers", [
        "lib/screens/splash_page.dart",
        "lib/widgets/cursor_follower.dart",
        "lib/widgets/hover_glow_card.dart",
        "lib/widgets/animated_counter.dart",
        "lib/main.dart",
      ]),

      h2("5.12 Branch protection GitHub"),
      paraMix([
        "Configurée via Settings → Branches sur le repo. La branche ",
        mono("main"),
        " exige : Pull Request avec 1 approval (owner), dismissal des stale approvals, conversation resolution avant merge, et bloque les force pushes et deletions. Pour le développeur, le workflow est : ",
        mono("git checkout -b feat/..."),
        " → ",
        mono("git push -u origin feat/..."),
        " → ",
        mono("gh pr create"),
        " → review → merge.",
      ]),

      // ───── 6. RESTE À FAIRE ─────
      h1("6. Reste à faire"),
      para(
        "Périmètre découpé par échéance. Les TODO les plus urgents sont en haut. " +
        "Le code couleur du tableau : rouge = bloquant pour la prochaine livraison, " +
        "ambre = important, gris = nice to have."
      ),

      h2("6.1 Court terme — Livrable 1"),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [3500, 1700, 4160],
        rows: [
          tableRow([
            { t: "Tâche", w: 3500 }, { t: "Priorité", w: 1700 }, { t: "Notes", w: 4160 },
          ], true),
          tableRow([
            { t: "Inscription Mentor + Investisseur", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Champs spécifiques (expertise, ticket d'investissement, vérification CIS)", w: 4160 },
          ]),
          tableRow([
            { t: "Dashboard Mentor (vue dédiée)", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Mes mentees, demandes en attente, sessions à venir, mes pitchs reçus", w: 4160 },
          ]),
          tableRow([
            { t: "Dashboard Investisseur (vue dédiée)", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Pitchs à étudier, portefeuille, ROI, mes investissements en cours", w: 4160 },
          ]),
          tableRow([
            { t: "Vraie messagerie temps réel", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Page conversations + chat. Firebase Realtime DB ou Firestore selon volume", w: 4160 },
          ]),
          tableRow([
            { t: "Dépôt de pitch persistant", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Stocker dans /pitches/{pitchId}, lier à user.projects, upload PDF via Storage", w: 4160 },
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
            { t: "Mot de passe oublié", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "FirebaseAuth.sendPasswordResetEmail() + page basique de saisie d'email", w: 4160 },
          ]),
          tableRow([
            { t: "Vérification de l'email à l'inscription", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "user.sendEmailVerification() — banner non-vérifié + reauth après clic sur le lien", w: 4160 },
          ]),
          tableRow([
            { t: "OTP par téléphone", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Phone Auth Firebase (le doc DIAPALER original le mentionne explicitement)", w: 4160 },
          ]),
          tableRow([
            { t: "Suppression de compte (CDP Sénégal)", w: 3500 },
            { t: "HAUTE", w: 1700, bold: true, fill: "FEE2E2" },
            { t: "Obligation légale RGPD/CDP — supprime user Firebase Auth + node /users/{uid}", w: 4160 },
          ]),
          tableRow([
            { t: "Édition / suppression d'un projet existant", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Aujourd'hui on peut créer mais pas modifier — ajouter EditProjectPage", w: 4160 },
          ]),
          tableRow([
            { t: "Module DER/FJ avec vraies fiches", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Fonctionnalité F7 du doc cours — fiches PAVIE 2 + Be Yes + critères d'éligibilité", w: 4160 },
          ]),
          tableRow([
            { t: "Vue calendrier des sessions", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Sessions à venir + passées côté entrepreneur (et côté mentor au Livrable 2)", w: 4160 },
          ]),
          tableRow([
            { t: "Notation et avis post-session", w: 3500 },
            { t: "MOYENNE", w: 1700, fill: "FEF3C7" },
            { t: "Fonctionnalité F11 du doc — alimente le compatibility score du matching", w: 4160 },
          ]),
          tableRow([
            { t: "Bibliothèque de ressources", w: 3500 },
            { t: "BASSE", w: 1700, fill: "F3F4F6" },
            { t: "Fonctionnalité F10 — articles, mini-formations, modèles (BP, étude marché) FR/wolof", w: 4160 },
          ]),
          tableRow([
            { t: "Mode sombre (réactiver)", w: 3500 },
            { t: "BASSE", w: 1700, fill: "F3F4F6" },
            { t: "Code de AppTheme.dark déjà présent — juste rebrancher le toggle", w: 4160 },
          ]),
        ],
      }),

      h2("6.2 Moyen terme — Livrable 2"),
      bullet("Configuration Android (google-services.json + plugin Gradle) pour APK"),
      bullet("Configuration iOS (GoogleService-Info.plist) si soumission App Store"),
      bullet("Déploiement Firebase Hosting pour la version web publique"),
      bullet("CI/CD GitHub Actions : flutter analyze + flutter test + build à chaque PR"),
      bullet("Couverture de tests > 50 % (widgets + unit tests sur services)"),
      bullet("Internationalisation FR / Wolof avec flutter_intl"),
      bullet("Mode hors-ligne partiel (cache Hive ou Isar pour mentors et conversations)"),
      bullet("Page DER/FJ avec vraies fiches PAVIE 2 + Be Yes + check d'éligibilité"),

      h2("6.3 Long terme — Vision Livrable 3+"),
      bullet("Algorithme de matching avancé (scoring pondéré multi-critères ou ML léger)"),
      bullet("Intégration mobile money pour paiement de session (Wave / Orange Money / Free Money)"),
      bullet("Vidéoconférence intégrée (Jitsi Meet ou Daily.co)"),
      bullet("Système de notation/avis post-session (alimente le compatibility score)"),
      bullet("Analytics (Firebase Analytics + dashboard métier interne)"),
      bullet("Recherche full-text sur mentors via Algolia ou Typesense"),
      bullet("Webhook Calendly / Google Calendar pour synchro des créneaux"),
      bullet("Export PDF du pitch deck à partager hors plateforme"),
      bullet("Programme de parrainage (lien d'invitation + récompense au filleul actif)"),

      // ───── 7. WORKFLOW ÉQUIPE ─────
      h1("7. Workflow équipe"),
      h2("7.1 Conventions de commit"),
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
      h2("7.2 Workflow Pull Request"),
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
      h2("7.3 Avant chaque commit"),
      bullet("flutter analyze — doit retourner « No issues found »"),
      bullet("Vérifier visuellement que l'app tourne en mode release sans erreur console"),
      bullet("Si modification de UserProfile : penser à updater DatabaseService._toMap / _fromMap"),
      bullet("Pas de print() ni de TODO commit dans le code de la PR"),

      // ───── 8. POINTS D'ATTENTION ─────
      h1("8. Points d'attention"),
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
        BLUE_TINT, BLUE, "💡"
      ),
      p([text("", { size: 22 })], { spacing: { before: 200 } }),
      calloutBlock(
        "Performance",
        "Le mode --debug est très lent en web (5× plus lent que release). Pour la démo, " +
        "toujours utiliser --release. Pour le développement, utiliser le hot reload " +
        "avec --debug malgré la lenteur — ça vaut le coup pour itérer.",
        "DCFCE7", GREEN, "🚀"
      ),

      // ───── 9. RESSOURCES ─────
      h1("9. Ressources"),
      bullet("Repo GitHub : github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa"),
      bullet("Console Firebase : console.firebase.google.com/project/diapaler-africa"),
      bullet("Documentation Flutter : docs.flutter.dev"),
      bullet("FlutterFire (plugin Firebase) : firebase.flutter.dev"),
      bullet("Guide d'installation : docs/Guide_Installation_DIAPALER.docx"),
      bullet("Doc fonctionnelle (Livrable 0 du cours) : DOCX original de l'équipe"),
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

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(
    "C:/Users/HP/entreprenariat/docs/Rapport_Technique_DIAPALER.docx",
    buffer
  );
  console.log("OK Rapport_Technique_DIAPALER.docx generated.");
}

build().catch((e) => {
  console.error("FAILED:", e);
  process.exit(1);
});

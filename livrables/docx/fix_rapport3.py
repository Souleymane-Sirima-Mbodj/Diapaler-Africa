"""
Version 3 — corrige le bug de suppression des images
"""
import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

SRC = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

with zipfile.ZipFile(SRC) as z:
    xml = z.read('word/document.xml').decode('utf-8')
    all_files = {name: z.read(name) for name in z.namelist()}

# ─────────────────────────────────────────────────────────────
# 1. Corrections textuelles dans le corps
# ─────────────────────────────────────────────────────────────
xml = xml.replace('4. Ecrans et fonctionnalites bonus', '4. Écrans et fonctionnalités bonus')
xml = xml.replace('4.1 Parametres et support', '4.1 Paramètres et support')
xml = xml.replace('4.3 Detail pitch avec uploads', '4.3 Détail pitch avec uploads')
xml = xml.replace('>Dashboards<', '>3.2 Dashboards<')

# Supprimer les runs contenant uniquement des virgules — SEULEMENT les runs texte pur
# On cible: <w:t>,,</w:t> ou <w:t>,</w:t> dans n'importe quel contexte
xml = re.sub(r'<w:t( xml:space="preserve")?>,,?</w:t>', '', xml)
print("Corrections textuelles OK")

# NE PAS supprimer les paragraphes "vides" car les paragraphes d'images
# n'ont pas de <w:t> mais ont <w:drawing> — on les garde tous.

# ─────────────────────────────────────────────────────────────
# 2. Trouver les bornes de la TDM
# ─────────────────────────────────────────────────────────────
all_paras = [(m.start(), m.end(), m.group(0))
             for m in re.finditer(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL)]

toc_header_idx = None
section1_idx   = None

for i, (s, e, p) in enumerate(all_paras):
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else ''
    if 'Titre2' in style and 'Table des mati' in text:
        toc_header_idx = i
    if toc_header_idx is not None and section1_idx is None:
        if 'Titre2' in style and text.startswith('1. Pr'):
            section1_idx = i
            break

print(f"TDM: paras {toc_header_idx+1} à {section1_idx-1}")
toc_paras   = all_paras[toc_header_idx + 1 : section1_idx]
toc_xml_start = toc_paras[0][0]
toc_xml_end   = toc_paras[-1][1]
print(f"Bloc TDM: {toc_xml_start} -> {toc_xml_end} ({toc_xml_end - toc_xml_start} chars)")

# ─────────────────────────────────────────────────────────────
# 3. Ajouter des bookmarks sur les headings du corps
# ─────────────────────────────────────────────────────────────
HEADINGS = [
    ('bm_s1',  '1. Présentation du projet'),
    ('bm_s11', '1.1 Contexte'),
    ('bm_s12', '1.2 Nom et concept'),
    ('bm_s13', '1.3 Public cible'),
    ('bm_s14', '1.4 Fonctionnalit'),
    ('bm_s2',  '2. Choix Techniques'),
    ('bm_s21', '2.1 Framework'),
    ('bm_s22', '2.2 Backend'),
    ('bm_s23', '2.3 Intelligence'),
    ('bm_s24', '2.4 Dépendances'),
    ('bm_s25', '2.5 Architecture'),
    ('bm_s3',  '3. Captures d'),
    ('bm_s31', '3.1 Flux'),
    ('bm_s32', '3.2 Dashboards'),
    ('bm_s33', '3.3 Matching'),
    ('bm_s34', '3.4 Pitchs'),
    ('bm_s35', '3.5 Profil utilisateur'),
    ('bm_s36', '3.6 Communications'),
    ('bm_s37', '3.7 Fonctionnalit'),
    ('bm_s4',  '4. Écrans et fonctionnalit'),
    ('bm_s41', '4.1 Param'),
    ('bm_s42', '4.2 Recommandations'),
    ('bm_s43', '4.3 Détail'),
    ('bm_s44', '4.4 Gestion mes pitchs'),
    ('bm_s45', '4.5 Mes Mentors'),
    ('bm_s46', '4.6 Favoris mentors'),
    ('bm_s47', '4.7 Favoris pitchs'),
    ('bm_s48', '4.8 Formulaire'),
    ('bm_s49', '4.9 Profil public'),
    ('bm_s5',  '5. Difficult'),
    ('bm_s6',  '6. Solutions'),
    ('bm_s7',  '7. Qualit'),
    ('bm_s8',  '8. Bilan'),
    ('bm_s81', '8.1 R'),
    ('bm_s82', '8.2 M'),
    ('bm_s83', '8.3 Déploiement'),
    ('bm_s84', '8.4 Perspectives'),
    ('bm_s85', '8.5 Conclusion'),
]

existing_ids = [int(x) for x in re.findall(r'w:bookmarkStart w:id="(\d+)"', xml)]
next_id = (max(existing_ids) + 1) if existing_ids else 1

# Trouver les headings dans le corps (après la TDM)
# On cherche les paragraphes Titre2/Titre3 après toc_xml_end
matched_headings = set()
insertions = []

for (s, e, p) in all_paras:
    if s <= toc_xml_end:
        continue
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else ''
    if 'Titre' not in style:
        continue
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()

    for (bm_name, match_prefix) in HEADINGS:
        if bm_name in matched_headings:
            continue
        if text.startswith(match_prefix[:15]):
            matched_headings.add(bm_name)
            bm_id = next_id
            next_id += 1
            first_r = re.search(r'<w:r[ >]', p)
            if first_r:
                abs_insert = s + first_r.start()
                abs_end    = e - len('</w:p>')
                bm_start = f'<w:bookmarkStart w:id="{bm_id}" w:name="{bm_name}"/>'
                bm_end   = f'<w:bookmarkEnd w:id="{bm_id}"/>'
                insertions.append((abs_insert, bm_start))
                insertions.append((abs_end, bm_end))
                print(f"  BM {bm_name} -> '{text[:50]}'")
            break

for pos, ins in sorted(insertions, key=lambda x: x[0], reverse=True):
    xml = xml[:pos] + ins + xml[pos:]
print(f"Bookmarks: {len(insertions)//2} sections marquées")

# ─────────────────────────────────────────────────────────────
# 4. Construire les nouveaux paragraphes TDM avec hyperliens
# ─────────────────────────────────────────────────────────────
def esc(t):
    return t.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

def toc_para(level, display, bm_name):
    bold = '<w:b/>' if level == 1 else ''
    indent = '' if level == 1 else '<w:ind w:left="360"/>'
    return (
        f'<w:p w:rsidR="00FC4A5C" w:rsidRDefault="005D33E6">'
        f'<w:pPr><w:pStyle w:val="Listepuces"/>{indent}'
        f'<w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr>'
        f'<w:hyperlink w:anchor="{bm_name}" w:history="1">'
        f'<w:r><w:rPr>{bold}<w:color w:val="1155CC"/><w:u w:val="single"/>'
        f'<w:lang w:val="fr-FR"/></w:rPr>'
        f'<w:t xml:space="preserve">{esc(display)}</w:t></w:r>'
        f'</w:hyperlink></w:p>'
    )

TOC = [
    (1, '1. Présentation du projet',                    'bm_s1'),
    (2, '1.1 Contexte et problématique',                'bm_s11'),
    (2, '1.2 Nom et concept',                           'bm_s12'),
    (2, '1.3 Public cible et rôles',                    'bm_s13'),
    (2, '1.4 Fonctionnalités complètes',                'bm_s14'),
    (1, '2. Choix Techniques',                          'bm_s2'),
    (2, '2.1 Framework — Flutter',                      'bm_s21'),
    (2, '2.2 Backend — Firebase',                       'bm_s22'),
    (2, '2.3 Intelligence Artificielle — Llama 3.1 / Groq', 'bm_s23'),
    (2, '2.4 Dépendances et justifications',            'bm_s24'),
    (2, '2.5 Architecture du code',                     'bm_s25'),
    (1, "3. Captures d'écran de l'application",         'bm_s3'),
    (2, "3.1 Flux d'authentification",                  'bm_s31'),
    (2, '3.2 Dashboards',                               'bm_s32'),
    (2, '3.3 Matching et profils',                      'bm_s33'),
    (2, '3.4 Pitchs',                                   'bm_s34'),
    (2, '3.5 Profil utilisateur',                       'bm_s35'),
    (2, '3.6 Communications',                           'bm_s36'),
    (2, '3.7 Fonctionnalités avancées',                 'bm_s37'),
    (1, '4. Écrans et fonctionnalités bonus',           'bm_s4'),
    (2, '4.1 Paramètres et support',                    'bm_s41'),
    (2, '4.2 Recommandations intelligentes',            'bm_s42'),
    (2, '4.3 Détail pitch avec uploads',                'bm_s43'),
    (2, '4.4 Gestion mes pitchs',                       'bm_s44'),
    (2, '4.5 Mes Mentors',                              'bm_s45'),
    (2, '4.6 Favoris mentors',                          'bm_s46'),
    (2, '4.7 Favoris pitchs',                           'bm_s47'),
    (2, '4.8 Formulaire envoi demande',                 'bm_s48'),
    (2, '4.9 Profil public',                            'bm_s49'),
    (1, '5. Difficultés rencontrées et solutions',      'bm_s5'),
    (1, '6. Solutions proposées et innovations',        'bm_s6'),
    (1, '7. Qualité du code',                           'bm_s7'),
    (1, '8. Bilan du projet',                           'bm_s8'),
    (2, '8.1 Récapitulatif des livrables',              'bm_s81'),
    (2, '8.2 Métriques de qualité et performance',      'bm_s82'),
    (2, '8.3 Déploiement et distribution',              'bm_s83'),
    (2, "8.4 Perspectives d'évolution",                 'bm_s84'),
    (2, '8.5 Conclusion',                               'bm_s85'),
]

new_toc = '\n'.join(toc_para(lvl, disp, bm) for (lvl, disp, bm) in TOC)

# ─────────────────────────────────────────────────────────────
# 5. Remplacer le bloc TDM dans le XML
#    (recalculer les bornes après ajout des bookmarks)
# ─────────────────────────────────────────────────────────────
all_paras2 = [(m.start(), m.end(), m.group(0))
              for m in re.finditer(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL)]

toc_hdr_found = False
toc_start2 = None
toc_end2   = None

for i, (s, e, p) in enumerate(all_paras2):
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else ''

    if 'Titre2' in style and 'Table des mati' in text:
        toc_hdr_found = True
        continue
    if toc_hdr_found:
        if toc_start2 is None:
            toc_start2 = s
        if 'Titre2' in style and text.startswith('1. Pr'):
            toc_end2 = all_paras2[i-1][1]
            break

print(f"Nouveau bloc TDM: {toc_start2} -> {toc_end2} ({toc_end2 - toc_start2} chars)")
xml = xml[:toc_start2] + new_toc + xml[toc_end2:]
print("TDM remplacée")

# ─────────────────────────────────────────────────────────────
# 6. Vérification finale
# ─────────────────────────────────────────────────────────────
drawings = xml.count('<w:drawing>')
print(f"<w:drawing> dans le XML final: {drawings}")

# ─────────────────────────────────────────────────────────────
# 7. Écrire le nouveau docx
# ─────────────────────────────────────────────────────────────
all_files['word/document.xml'] = xml.encode('utf-8')

with zipfile.ZipFile(DST, 'w', zipfile.ZIP_DEFLATED) as zout:
    for name, data in all_files.items():
        zout.writestr(name, data)

print(f"\nFichier créé : {DST}")

"""
Corrige RAPPORT_DIAPALER_AFRICA.docx :
 1. Supprime les ",," parasites
 2. Corrige les titres section 4 (accents manquants)
 3. Corrige "Dashboards" -> "3.2 Dashboards"
 4. Remplace la TDM texte brut par une vraie TDM avec hyperliens Word cliquables
 5. Numèrote correctement (6->7 Qualité, 7->8 Bilan, 7.5->8.5 Conclusion)
"""
import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re, shutil, os

SRC = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

with zipfile.ZipFile(SRC) as z:
    xml = z.read('word/document.xml').decode('utf-8')
    all_files = {name: z.read(name) for name in z.namelist()}

# ─────────────────────────────────────────────────────────────
# 1. Corrections textuelles dans le corps du document
# ─────────────────────────────────────────────────────────────

# Section 4 : accents manquants
xml = xml.replace('4. Ecrans et fonctionnalites bonus', '4. Écrans et fonctionnalités bonus')
xml = xml.replace('4.1 Parametres et support', '4.1 Paramètres et support')
xml = xml.replace('4.3 Detail pitch avec uploads', '4.3 Détail pitch avec uploads')

# "Dashboards" -> "3.2 Dashboards"
xml = xml.replace('>Dashboards<', '>3.2 Dashboards<')

# ─────────────────────────────────────────────────────────────
# 2. Supprimer les paragraphes parasites ",," ou ","
# ─────────────────────────────────────────────────────────────
# Supprime les runs qui ne contiennent que des virgules
xml = re.sub(r'<w:t[^>]*>,,?</w:t>', '', xml)
# Supprime les paragraphes vides résultants
xml = re.sub(r'<w:p[^>]*>(?:<w:pPr>.*?</w:pPr>)?(?:\s*<w:r[^>]*>(?:<w:rPr>.*?</w:rPr>)?</w:r>)*</w:p>',
             lambda m: m.group(0) if re.search(r'<w:t', m.group(0)) else '',
             xml, flags=re.DOTALL)

# ─────────────────────────────────────────────────────────────
# 3. Obtenir le max ID de bookmarks existants
# ─────────────────────────────────────────────────────────────
existing_ids = [int(x) for x in re.findall(r'<w:bookmarkStart[^>]+w:id="(\d+)"', xml)]
next_id = (max(existing_ids) + 1) if existing_ids else 1

# ─────────────────────────────────────────────────────────────
# 4. Définir la TDM correcte (texte affiché, texte à chercher dans le corps)
# ─────────────────────────────────────────────────────────────
TOC = [
    # (niveau, texte_tdm, texte_heading_dans_corps)
    (1, '1. Présentation du projet',                   '1. Présentation du projet'),
    (2, '1.1 Contexte et problématique',               '1.1 Contexte et problématique'),
    (2, '1.2 Nom et concept',                          '1.2 Nom et concept'),
    (2, '1.3 Public cible et rôles',                   '1.3 Public cible et rôles'),
    (2, '1.4 Fonctionnalités complètes',               '1.4 Fonctionnalités complètes'),
    (1, '2. Choix Techniques',                         '2. Choix Techniques'),
    (2, '2.1 Framework — Flutter',                     '2.1 Framework'),
    (2, '2.2 Backend — Firebase',                      '2.2 Backend'),
    (2, '2.3 Intelligence Artificielle — Llama 3.1 via Groq', '2.3 Intelligence Artificielle'),
    (2, '2.4 Dépendances et justifications',           '2.4 Dépendances et justifications'),
    (2, '2.5 Architecture du code',                    '2.5 Architecture du code'),
    (1, "3. Captures d'écran de l'application",        "3. Captures d"),
    (2, '3.1 Flux d\'authentification',                '3.1 Flux'),
    (2, '3.2 Dashboards',                              '3.2 Dashboards'),
    (2, '3.3 Matching et profils',                     '3.3 Matching'),
    (2, '3.4 Pitchs',                                  '3.4 Pitchs'),
    (2, '3.5 Profil utilisateur',                      '3.5 Profil utilisateur'),
    (2, '3.6 Communications',                          '3.6 Communications'),
    (2, '3.7 Fonctionnalités avancées',                '3.7 Fonctionnalit'),
    (1, '4. Écrans et fonctionnalités bonus',          '4. Écrans et fonctionnalit'),
    (2, '4.1 Paramètres et support',                   '4.1 Param'),
    (2, '4.2 Recommandations intelligentes',           '4.2 Recommandations'),
    (2, '4.3 Détail pitch avec uploads',               '4.3 D'),
    (2, '4.4 Gestion mes pitchs',                      '4.4 Gestion mes pitchs'),
    (2, '4.5 Mes Mentors',                             '4.5 Mes Mentors'),
    (2, '4.6 Favoris mentors',                         '4.6 Favoris mentors'),
    (2, '4.7 Favoris pitchs',                          '4.7 Favoris pitchs'),
    (2, '4.8 Formulaire envoi demande',                '4.8 Formulaire envoi demande'),
    (2, '4.9 Profil public',                           '4.9 Profil public'),
    (1, '5. Difficultés rencontrées et solutions',     '5. Difficult'),
    (1, '6. Solutions proposées et innovations',       '6. Solutions'),
    (1, '7. Qualité du code',                          '7. Qualit'),
    (1, '8. Bilan du projet',                          '8. Bilan du projet'),
    (2, '8.1 Récapitulatif des livrables',             '8.1 R'),
    (2, '8.2 Métriques de qualité et performance',     '8.2 M'),
    (2, '8.3 Déploiement et distribution',             '8.3 D'),
    (2, "8.4 Perspectives d'évolution",                '8.4 Perspectives'),
    (2, '8.5 Conclusion',                              '8.5 Conclusion'),
]

# ─────────────────────────────────────────────────────────────
# 5. Ajouter des bookmarks sur chaque heading correspondant
# ─────────────────────────────────────────────────────────────
def bookmark_name(idx):
    return f'toc_s{idx}'

# Pour chaque entrée TDM, trouver le paragraphe heading correspondant dans le corps
# et y insérer un bookmark
bm_map = {}  # match_text -> bookmark_name
for i, (lvl, display, match) in enumerate(TOC):
    bm = bookmark_name(i)
    bm_map[match] = (bm, i)

# Trouver les paragraphes Titre2/Titre3 dans le corps et y insérer les bookmarks
def add_bookmarks(xml, bm_map, next_id):
    # On cherche les paragraphes de style Titre2 ou Titre3
    # Pattern: <w:p ...><w:pPr><w:pStyle w:val="Titre2"/> ... </w:pPr>...<w:t>text</w:t>...</w:p>

    paragraphs = list(re.finditer(r'<w:p[ >].*?</w:p>', xml, re.DOTALL))

    inserts = []  # (position_in_xml, bookmark_start_xml, bookmark_end_xml, bm_id)
    used_next_id = next_id

    for p_match in paragraphs:
        p_text = p_match.group(0)
        if 'Titre2' not in p_text and 'Titre3' not in p_text:
            continue

        # Extraire le texte complet du paragraphe
        runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p_text)
        full_text = ''.join(runs).strip()

        # Chercher si ce texte correspond à une entrée TDM
        matched_bm = None
        for match_text, (bm, idx) in bm_map.items():
            if full_text.startswith(match_text[:20]) or match_text[:20] in full_text:
                matched_bm = (bm, idx)
                break

        if not matched_bm:
            continue

        bm_name, idx = matched_bm

        # Insérer le bookmark autour du premier run de texte dans le paragraphe
        # Trouver la position du premier <w:r> dans ce paragraphe
        first_run_start = p_text.find('<w:r')
        if first_run_start == -1:
            continue

        # Position absolue dans le xml
        abs_pos = p_match.start() + first_run_start

        bm_id = used_next_id
        used_next_id += 1

        bm_start = f'<w:bookmarkStart w:id="{bm_id}" w:name="{bm_name}"/>'
        bm_end = f'<w:bookmarkEnd w:id="{bm_id}"/>'

        inserts.append((abs_pos, bm_start, bm_end, bm_id, p_match.end()))

    # Appliquer les insertions (de la fin vers le début pour ne pas décaler les positions)
    result = xml
    offset = 0
    for abs_pos, bm_start, bm_end, bm_id, p_end in sorted(inserts, key=lambda x: x[0]):
        insert_pos = abs_pos + offset
        result = result[:insert_pos] + bm_start + result[insert_pos:]
        offset += len(bm_start)

        # Insérer bm_end juste avant </w:p>
        p_close_pos = result.find('</w:p>', insert_pos)
        if p_close_pos != -1:
            result = result[:p_close_pos] + bm_end + result[p_close_pos:]
            offset += len(bm_end)

    return result, used_next_id

xml, next_id = add_bookmarks(xml, bm_map, next_id)
print(f"Bookmarks ajoutés. Prochain ID: {next_id}")

# ─────────────────────────────────────────────────────────────
# 6. Construire la nouvelle TDM avec hyperliens Word vrais
# ─────────────────────────────────────────────────────────────

def make_toc_para(level, display_text, bm_name, rsid='00FC4A5C'):
    """Génère un paragraphe TDM avec style et hyperlien interne Word."""
    # Style de la ligne TDM selon le niveau
    style = 'TDM1' if level == 1 else 'TDM2'

    # Couleur hyperlien : bleu standard Word
    hyperlink_xml = (
        f'<w:hyperlink w:anchor="{bm_name}" w:history="1">'
        f'<w:r><w:rPr><w:rStyle w:val="LienHypertexte"/></w:rPr>'
        f'<w:t xml:space="preserve">{_esc(display_text)}</w:t>'
        f'</w:r>'
        f'</w:hyperlink>'
    )

    return (
        f'<w:p w:rsidR="{rsid}" w:rsidRDefault="005D33E6">'
        f'<w:pPr><w:pStyle w:val="Listepuces"/><w:ind w:left="{0 if level == 1 else 360}"/>'
        f'<w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr>'
        f'{hyperlink_xml}'
        f'</w:p>'
    )

def _esc(text):
    return text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

# Construire les paragraphes TDM
new_toc_paras = []
for i, (lvl, display, match) in enumerate(TOC):
    bm = bookmark_name(i)
    new_toc_paras.append(make_toc_para(lvl, display, bm))

new_toc_xml = '\n'.join(new_toc_paras)

# ─────────────────────────────────────────────────────────────
# 7. Remplacer l'ancienne TDM dans le document
# ─────────────────────────────────────────────────────────────
# La TDM est une série de paragraphes Listepuces entre "Table des matières" et "1. Présentation"
# On cherche le premier paragraphe Listepuces contenant "[1." jusqu'au dernier contenant "#75"

# Stratégie : trouver le premier para Listepuces "[1." et le dernier para Listepuces "Conclusion"
# puis remplacer tout ce bloc

# Chercher la position du premier paragraph TDM
first_toc_match = re.search(
    r'<w:p[^>]*>(?:<w:pPr>.*?</w:pPr>)?(?:.*?)</w:p>',
    xml, re.DOTALL
)

# On cherche le pattern: paragraphes Listepuces contenant "[1. Pr" jusqu'à "Conclusion"
# Trouver tous les paragraphes Listepuces successifs qui forment la TDM
toc_block_start = xml.find('[1. Pr')
if toc_block_start == -1:
    toc_block_start = xml.find('[1. P')

# Reculer jusqu'au début du paragraphe contenant cet index
p_open = xml.rfind('<w:p ', 0, toc_block_start)
p_open2 = xml.rfind('<w:p>', 0, toc_block_start)
toc_para_start = max(p_open if p_open != -1 else 0,
                     p_open2 if p_open2 != -1 else 0)

# Trouver la fin de la TDM : le dernier paragraphe Listepuces avant "1. Présentation du projet" heading
# Chercher "7.5 Conclusion" ou "8.5 Conclusion" text
toc_end_marker = xml.find('Conclusion</w:t>', toc_block_start)
if toc_end_marker == -1:
    toc_end_marker = xml.find('Conclusion', toc_block_start)
toc_para_end = xml.find('</w:p>', toc_end_marker) + len('</w:p>')

old_toc_block = xml[toc_para_start:toc_para_end]
print(f"TDM trouvée: {toc_para_start} -> {toc_para_end} ({len(old_toc_block)} chars)")
print(f"Début: {old_toc_block[:100]}")

xml = xml[:toc_para_start] + new_toc_xml + xml[toc_para_end:]
print("TDM remplacée")

# ─────────────────────────────────────────────────────────────
# 8. Écrire le nouveau docx
# ─────────────────────────────────────────────────────────────
all_files['word/document.xml'] = xml.encode('utf-8')

with zipfile.ZipFile(DST, 'w', zipfile.ZIP_DEFLATED) as zout:
    for name, data in all_files.items():
        zout.writestr(name, data)

print(f"\nFichier créé : {DST}")
print("TERMINÉ")

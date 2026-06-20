"""
Post-traitement sur RAPPORT_DIAPALER_AFRICA_v2.docx :
 - Corrige <w:t>Detail</w:t> → <w:t>Détail</w:t> dans le heading 4.3
 - Ajoute le bookmark bm_s1 sur le heading "1. Présentation du projet"
 - Ajoute le bookmark bm_s43 sur le heading "4.3 Detail..."
"""
import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

SRC = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'
DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

with zipfile.ZipFile(SRC) as z:
    xml = z.read('word/document.xml').decode('utf-8')
    all_files = {name: z.read(name) for name in z.namelist()}

# ─────────────────────────────────────────────────────────────
# 1. Corriger "Detail" → "Détail" dans le contexte du heading 4.3
#    Le pattern est : run contenant "4.3 " suivi d'un run contenant "Detail"
#    On fait un remplacement regex ciblé dans les paragraphes Titre3
# ─────────────────────────────────────────────────────────────

# Remplacer dans le contexte précis du heading "4.3 ... Detail ..."
# Pattern: <w:t>4.3 </w:t> ... (dans le même paragraphe) ... <w:t>Detail</w:t>
# On utilise une regex qui capture tout le paragraphe Titre3 contenant "4.3 "

def fix_43_detail(xml):
    # Chercher le paragraphe Titre3 qui contient "4.3 " et "Detail"
    pattern = re.compile(
        r'(<w:p(?:\s[^>]*)?>(?:(?!<w:p[ >]).)*?Titre3(?:(?!<w:p[ >]).)*?'
        r'4\.3 (?:(?!<w:p[ >]).)*?)<w:t>Detail</w:t>',
        re.DOTALL
    )
    def replacer(m):
        return m.group(1) + '<w:t>Détail</w:t>'

    new_xml, count = re.subn(pattern, replacer, xml)
    if count > 0:
        print(f"  '4.3 Detail' corrigé en '4.3 Détail' ({count} occurrence)")
    else:
        print("  ATTENTION: '4.3 Detail' non trouvé — essai de remplacement direct")
        # Fallback : remplacer le run <w:t>Detail</w:t> directement s'il n'y a qu'une occurrence
        occurrences = xml.count('<w:t>Detail</w:t>')
        print(f"  Occurrences de <w:t>Detail</w:t>: {occurrences}")
        if occurrences == 1:
            new_xml = xml.replace('<w:t>Detail</w:t>', '<w:t>Détail</w:t>')
            print("  Remplacement direct effectué")
        else:
            new_xml = xml
    return new_xml

xml = fix_43_detail(xml)

# ─────────────────────────────────────────────────────────────
# 2. Ajouter bookmarks manquants : bm_s1 et bm_s43
# ─────────────────────────────────────────────────────────────
existing_ids = [int(x) for x in re.findall(r'w:bookmarkStart w:id="(\d+)"', xml)]
next_id = (max(existing_ids) + 1) if existing_ids else 100

MISSING = [
    ('bm_s1',  '1. Présentation du projet', 'Titre2'),
    ('bm_s43', '4.3 D',                     'Titre3'),  # D covers both Detail et Détail
]

paras = list(re.finditer(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL))
insertions = []
already_found = set(re.findall(r'w:name="(bm_s\w+)"', xml))

for (bm_name, match_prefix, req_style) in MISSING:
    if bm_name in already_found:
        print(f"  {bm_name} déjà présent, skip")
        continue
    for m in paras:
        p = m.group(0)
        style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
        style = style_m.group(1) if style_m else ''
        if req_style not in style:
            continue
        runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
        text = ''.join(runs).strip()
        if not text.startswith(match_prefix):
            continue
        # Trouver le premier <w:r> dans ce paragraphe
        first_r = re.search(r'<w:r[ >]', p)
        if not first_r:
            print(f"  {bm_name}: para trouvé ('{text[:40]}') mais pas de <w:r>")
            continue
        abs_insert = m.start() + first_r.start()
        abs_end    = m.end() - len('</w:p>')
        bm_id = next_id
        next_id += 1
        insertions.append((abs_insert, f'<w:bookmarkStart w:id="{bm_id}" w:name="{bm_name}"/>'))
        insertions.append((abs_end, f'<w:bookmarkEnd w:id="{bm_id}"/>'))
        print(f"  Bookmark {bm_name} -> '{text[:60]}'")
        break

for pos, ins in sorted(insertions, key=lambda x: x[0], reverse=True):
    xml = xml[:pos] + ins + xml[pos:]

# ─────────────────────────────────────────────────────────────
# 3. Vérification finale
# ─────────────────────────────────────────────────────────────
drawings = xml.count('<w:drawing>')
bm_count = len(re.findall(r'w:name="(bm_s\w+)"', xml))
print(f"\nImages: {drawings} | Bookmarks bm_s*: {bm_count}")

# Vérifier le titre 4.3 dans le corps
paras2 = re.finditer(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL)
for m in paras2:
    p = m.group(0)
    if 'Titre3' not in p:
        continue
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    if text.startswith('4.3'):
        print(f"Heading 4.3 final: '{text}'")
        break

# ─────────────────────────────────────────────────────────────
# 4. Écrire
# ─────────────────────────────────────────────────────────────
all_files['word/document.xml'] = xml.encode('utf-8')
with zipfile.ZipFile(DST, 'w', zipfile.ZIP_DEFLATED) as zout:
    for name, data in all_files.items():
        zout.writestr(name, data)

print(f"Fichier mis à jour: {DST}")

import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

with zipfile.ZipFile(DST) as z:
    xml = z.read('word/document.xml').decode('utf-8')

# 1. Vérifier la TDM
print("=== VÉRIFICATION TDM ===")
paras = re.findall(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL)
in_toc = False
for p in paras:
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else ''
    if 'Titre2' in style and 'Table des mati' in text:
        in_toc = True
        continue
    if in_toc:
        if 'Titre2' in style and '1. Pr' in text:
            in_toc = False
            break
        if text:
            has_hyperlink = '<w:hyperlink' in p
            has_bookmark_anchor = 'w:anchor=' in p
            print(f"  {'[LIEN]' if has_hyperlink else '[TEXT]'} {text[:70]}")

# 2. Vérifier les bookmarks ajoutés
print("\n=== BOOKMARKS ===")
bms = re.findall(r'w:name="(bm_s\w+)"', xml)
print(f"Bookmarks bm_s* trouvés: {len(bms)}")
for bm in bms:
    print(f"  {bm}")

# 3. Vérifier les titres section 4
print("\n=== SECTION 4 TITRES ===")
for p in paras:
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else ''
    if 'Titre' in style:
        runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
        text = ''.join(runs).strip()
        if text.startswith('4.'):
            print(f"  [{style}] {text}")

# 4. Vérifier absences de ",,"
print("\n=== VIRGULES PARASITES ===")
stray = re.findall(r'<w:t[^>]*>,,?</w:t>', xml)
print(f"Virgules parasites restantes: {len(stray)}")
if stray:
    for s in stray:
        print(f"  {s}")

# 5. Vérifier les images
drawings = xml.count('<w:drawing>')
print(f"\n=== IMAGES: {drawings} <w:drawing> ===")

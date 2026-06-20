import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

SRC = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
with zipfile.ZipFile(SRC) as z:
    xml = z.read('word/document.xml').decode('utf-8')

# Chercher le paragraphe Titre3 contenant "4.3"
paras = re.finditer(r'<w:p(?:\s[^>]*)?>.*?</w:p>', xml, re.DOTALL)
for m in paras:
    p = m.group(0)
    if 'Titre3' not in p:
        continue
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    if text.startswith('4.3') or text.startswith('4.4'):
        print(f"TEXT: '{text}'")
        # Montrer le XML brut du run
        r_matches = re.findall(r'<w:r[^>]*>.*?</w:r>', p, re.DOTALL)
        for r in r_matches:
            print(f"  RUN: {r[:200]}")
        print()

# Chercher "1. Présentation" dans le body (après position 34000)
idx = xml.find('1. Présentation du projet', 34000)
print(f"\n'1. Présentation du projet' trouvé à: {idx}")
idx2 = xml.find('1. Pr', 34000)
print(f"'1. Pr' trouvé à: {idx2}")

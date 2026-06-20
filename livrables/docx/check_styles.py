import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

with zipfile.ZipFile(DST) as z:
    names = z.namelist()
    # Lire les styles
    if 'word/styles.xml' in names:
        styles_xml = z.read('word/styles.xml').decode('utf-8')
        lien = 'LienHypertexte' in styles_xml or 'Hyperlink' in styles_xml
        print(f"Style LienHypertexte present: {lien}")
        # Chercher le style exact
        found = re.findall(r'w:styleId="([^"]*[Ll]ien[^"]*|[Hh]yperlink[^"]*)"', styles_xml)
        print(f"Styles lien trouves: {found}")

    # Vérifier que le XML est valide (pas de tags non fermés)
    xml = z.read('word/document.xml').decode('utf-8')
    open_p = xml.count('<w:p ')  + xml.count('<w:p>')
    close_p = xml.count('</w:p>')
    print(f"\nParagraphes: {open_p} ouverts / {close_p} fermés")

    open_r = xml.count('<w:r>') + xml.count('<w:r ')
    close_r = xml.count('</w:r>')
    print(f"Runs: {open_r} ouverts / {close_r} fermés")

    # Taille du fichier
    import os
    size = os.path.getsize(DST)
    print(f"\nTaille du fichier: {size/1024:.0f} KB")

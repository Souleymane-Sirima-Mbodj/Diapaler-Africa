import sys
sys.stdout.reconfigure(encoding='utf-8')
from docx import Document
from docx.shared import Pt, RGBColor
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import re

doc = Document()

# Titre
titre = doc.add_paragraph()
run = titre.add_run('Liens DIAPALER AFRICA')
run.bold = True
run.font.size = Pt(16)

doc.add_paragraph()

# Fonction pour ajouter un hyperlien cliquable
def add_hyperlink(paragraph, text, url):
    part = paragraph.part
    r_id = part.relate_to(url, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink', is_external=True)

    hyperlink = OxmlElement('w:hyperlink')
    hyperlink.set(qn('r:id'), r_id)
    hyperlink.set(qn('w:history'), '1')

    new_run = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')

    rStyle = OxmlElement('w:rStyle')
    rStyle.set(qn('w:val'), 'Hyperlink')
    rPr.append(rStyle)

    color = OxmlElement('w:color')
    color.set(qn('w:val'), '1155CC')
    rPr.append(color)

    u = OxmlElement('w:u')
    u.set(qn('w:val'), 'single')
    rPr.append(u)

    new_run.append(rPr)

    t = OxmlElement('w:t')
    t.text = text
    new_run.append(t)

    hyperlink.append(new_run)
    paragraph.add_run()
    paragraph._p.append(hyperlink)

# Lien 1 — Application web
p1 = doc.add_paragraph()
p1.add_run('Application web : ').bold = True
add_hyperlink(p1, 'https://diapaler-africa.web.app', 'https://diapaler-africa.web.app')

doc.add_paragraph()

# Lien 2 — Google Drive
p2 = doc.add_paragraph()
p2.add_run('Dossier Google Drive (APK + livrables) : ').bold = True
add_hyperlink(p2, 'https://drive.google.com/drive/folders/17DLuBz4cX-9ABv0-no2LEwYzclJMCPU-?usp=drive_link',
              'https://drive.google.com/drive/folders/17DLuBz4cX-9ABv0-no2LEwYzclJMCPU-?usp=drive_link')

doc.add_paragraph()

# Lien 3 — GitHub
p3 = doc.add_paragraph()
p3.add_run('Dépôt GitHub (code source) : ').bold = True
add_hyperlink(p3, 'https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa.git',
              'https://github.com/Souleymane-Sirima-Mbodj/Diapaler-Africa.git')

out = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\LIENS_DIAPALER_v2.docx'
doc.save(out)
print(f'Fichier créé : {out}')

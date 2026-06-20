import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

docx_path = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
with zipfile.ZipFile(docx_path) as z:
    xml = z.read('word/document.xml').decode('utf-8')

paras = re.findall(r'<w:p[ >].*?</w:p>', xml, re.DOTALL)

for p in paras:
    style_m = re.search(r'<w:pStyle w:val="([^"]+)"', p)
    style = style_m.group(1) if style_m else 'Normal'
    runs = re.findall(r'<w:t[^>]*>([^<]*)</w:t>', p)
    text = ''.join(runs).strip()
    if text:
        if 'Titre' in style or 'Heading' in style:
            print(f'[{style}] {text}')
        elif 'CAPTURE' in text.upper():
            print(f'[CAPTURE] {text}')
        else:
            print(text[:120])

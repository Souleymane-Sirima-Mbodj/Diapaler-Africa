import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

def count_para_tags(path):
    with zipfile.ZipFile(path) as z:
        xml = z.read('word/document.xml').decode('utf-8')
    # Compter les vrais tags <w:p> (paragraphe) vs <w:p... autres
    open_tags = re.findall(r'<w:p(?:\s[^>]*)?>', xml)
    close_tags = re.findall(r'</w:p>', xml)
    return len(open_tags), len(close_tags), xml

SRC = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
DST = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA_v2.docx'

o1, c1, _ = count_para_tags(SRC)
o2, c2, xml2 = count_para_tags(DST)

print(f"Original : {o1} ouverts / {c1} fermés  (diff: {o1-c1})")
print(f"v2       : {o2} ouverts / {c2} fermés  (diff: {o2-c2})")

# Tester avec python-docx
try:
    from docx import Document
    doc = Document(DST)
    paras = len(doc.paragraphs)
    print(f"\npython-docx : {paras} paragraphes lus sans erreur ✅")
except Exception as e:
    print(f"\npython-docx erreur : {e}")

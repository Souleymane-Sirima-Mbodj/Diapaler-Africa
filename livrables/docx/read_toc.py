import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

docx_path = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
with zipfile.ZipFile(docx_path) as z:
    xml = z.read('word/document.xml').decode('utf-8')

# Find the TOC section (between Table des matières and section 1)
toc_start = xml.find('Table des mati')
toc_end = xml.find('1. Présentation du projet', toc_start)
if toc_end == -1:
    toc_end = xml.find('Présentation du projet', toc_start)

toc_xml = xml[toc_start:toc_end]
print(f"TOC length: {len(toc_xml)}")
print("---TOC XML (first 5000 chars)---")
print(toc_xml[:5000])

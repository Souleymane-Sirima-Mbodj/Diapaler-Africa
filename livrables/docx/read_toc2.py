import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

docx_path = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
with zipfile.ZipFile(docx_path) as z:
    xml = z.read('word/document.xml').decode('utf-8')

# Find TOC paragraphs - look for the [1. Présentation block
idx = xml.find('[1. Pr')
if idx == -1:
    idx = xml.find('[1. P')

# Show 8000 chars around TOC
start = max(0, idx - 200)
end = min(len(xml), idx + 6000)
print(xml[start:end])

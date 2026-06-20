import sys
sys.stdout.reconfigure(encoding='utf-8')
import zipfile, re

docx_path = r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\RAPPORT_DIAPALER_AFRICA.docx'
with zipfile.ZipFile(docx_path) as z:
    names = z.namelist()
    images = [n for n in names if n.startswith('word/media/')]
    print(f"Images trouvees: {len(images)}")
    for img in images[:10]:
        print(f"  {img}")

    xml = z.read('word/document.xml').decode('utf-8')

# Count drawing elements (embedded images in document)
drawings = xml.count('<w:drawing>')
blips = xml.count('<a:blip ')
print(f"\nBalises <w:drawing>: {drawings}")
print(f"Balises <a:blip>: {blips}")

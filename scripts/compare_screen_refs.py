import re
from pathlib import Path

project = Path('lib/screens')
files = sorted(p.name for p in project.glob('page_*.dart'))
refs = {}
for md in Path('livrables').glob('livrable*.md'):
    text = md.read_text(encoding='utf-8')
    names = re.findall(r'page_[a-z0-9_]+\.dart', text)
    refs[md.name] = sorted(set(names))

print('Project screen files:')
for f in files:
    print(f)
print('\nReferences in livrables and missing files:')
for md, names in refs.items():
    missing = [n for n in names if n not in files]
    print(f'{md}: {len(names)} refs, missing from project: {missing}')

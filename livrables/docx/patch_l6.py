import sys
sys.stdout.reconfigure(encoding='utf-8')

with open(r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\unpacked_l6\word\document.xml', encoding='utf-8') as f:
    content = f.read()

# ── Templates ─────────────────────────────────────────────────────────
def titre2(text):
    return f'    <w:p w:rsidR="00FC4A5C" w:rsidRDefault="005D33E6"><w:pPr><w:pStyle w:val="Titre2"/><w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr><w:r><w:rPr><w:lang w:val="fr-FR"/></w:rPr><w:t>{text}</w:t></w:r></w:p>'

def titre3(text):
    return f'    <w:p w:rsidR="00FC4A5C" w:rsidRDefault="005D33E6"><w:pPr><w:pStyle w:val="Titre3"/><w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr><w:r><w:rPr><w:lang w:val="fr-FR"/></w:rPr><w:t>{text}</w:t></w:r></w:p>'

def body(text):
    return f'    <w:p w:rsidR="00FC4A5C" w:rsidRDefault="005D33E6"><w:pPr><w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr><w:r><w:rPr><w:lang w:val="fr-FR"/></w:rPr><w:t xml:space="preserve">{text}</w:t></w:r></w:p>'

def capture(text):
    return f'    <w:p w:rsidR="00FC4A5C" w:rsidRDefault="005D33E6"><w:pPr><w:pBdr><w:left w:val="single" w:sz="8" w:space="6" w:color="F59E0B"/></w:pBdr><w:shd w:val="clear" w:color="auto" w:fill="FEF3C7"/><w:spacing w:before="200" w:after="0"/><w:rPr><w:lang w:val="fr-FR"/></w:rPr></w:pPr><w:r><w:rPr><w:lang w:val="fr-FR"/></w:rPr><w:t>CAPTURE D\'ECRAN -- {text}</w:t></w:r></w:p>'

# ── Section 4 ──────────────────────────────────────────────────────────
blocks = [
    titre2('4. Ecrans et fonctionnalites bonus'),
    body('Au-dela des ecrans principaux, DIAPALER AFRICA integre des ecrans complementaires qui enrichissent le parcours utilisateur.'),

    titre3('4.1 Parametres et support'),
    body('Accessible depuis le profil. Permet de changer le mot de passe, de contacter le support (support@diapaler.sn), de voir la version et les informations de l\'application.'),
    capture('Page Parametres (langue, version, changement mot de passe, support)'),

    titre3('4.2 Recommandations intelligentes'),
    body('Affiche les mentors filtres selon les interets et le secteur de l\'entrepreneur, avec un score de compatibilite dynamique base sur les interets partages.'),
    capture('Page Mentors recommandes (filtrage interets + score compatibilite)'),

    titre3('4.3 Detail pitch avec uploads'),
    body('Affiche le contenu complet d\'un pitch : description, montant, PDF du business plan et video de presentation. Accessible depuis la liste des pitchs publies.'),
    capture('Detail pitch (description + montant + PDF + video + bouton investir)'),

    titre3('4.4 Gestion mes pitchs'),
    body('Liste en temps reel des pitchs publies par l\'entrepreneur, avec titre, secteur, description et date de publication.'),
    capture('Mes Pitchs publies (liste StreamBuilder temps reel)'),

    titre3('4.5 Mes Mentors'),
    body('Liste les mentors et investisseurs avec qui l\'utilisateur a une relation acceptee. Permet d\'ouvrir le chat ou de consulter le profil directement.'),
    capture('Mes Mentors actifs (relations acceptees -- mentorat et investissement)'),

    titre3('4.6 Favoris mentors'),
    body('Affiche les profils mis en favori par l\'utilisateur. Permet de retrouver rapidement les profils interessants sans repasser par le Matching.'),
    capture('Favoris mentors (profils sauvegardes)'),

    titre3('4.7 Favoris pitchs'),
    body('Liste reactive des pitchs sauvegardes par l\'investisseur via le bookmark. Permet d\'acceder au detail et d\'envoyer une proposition d\'investissement.'),
    capture('Mes Pitchs favoris (bookmarks investisseur -- ValueNotifier temps reel)'),

    titre3('4.8 Formulaire envoi demande'),
    body('Permet de personnaliser le message accompagnant une demande de mentorat ou d\'investissement avant de l\'envoyer.'),
    capture('Formulaire envoi demande (message personnalise)'),

    titre3('4.9 Profil public'),
    body('Vue du profil d\'un utilisateur accessible depuis le Matching. Affiche les informations publiques, les avis recus et les actions possibles selon le role.'),
    capture('Profil public (bio + avis + actions selon le role)'),
]
section4 = '\n'.join(blocks)

# ── Nouvelles captures L5 ─────────────────────────────────────────────
new_captures = '\n'.join([
    capture('Notifications in-app -- badge rouge dynamique sur la cloche'),
    capture('Notification inline -- boutons Accepter/Refuser dans la tuile'),
    capture('Recherche Matching -- barre de recherche + pills filtres actifs'),
    capture('Filtres Pitchs -- pills secteur dynamiques + compteur de resultats'),
    capture('Geolocalisation GPS -- bouton Pres de moi actif + distances en km'),
    capture('Messagerie -- onglet Contacts (relations acceptees)'),
    capture('Partage reseaux sociaux (WhatsApp, Facebook, LinkedIn)'),
    capture('Avis et notation -- etoiles 1 a 5 + moyenne live Firebase'),
    capture('Pitchs favoris -- icone bookmark sur une carte pitch'),
    capture('Wave Premium -- abonnement 4 900 FCFA + badge etoile sur le profil'),
])

# ── 1. Inserer section 4 avant le titre Difficultes ────────────────────
marker = '<w:t>4. Difficult'
idx = content.find(marker)
para_start = content.rfind('<w:p ', 0, idx)
content = content[:para_start] + section4 + '\n' + content[para_start:]
print('Section 4 inseree')

# ── 2. Ajouter captures L5 apres Paiment Wave ─────────────────────────
for wave in ['Paiment Wave', 'Paiement Wave']:
    idx_w = content.find(wave)
    if idx_w != -1:
        end_p = content.find('</w:p>', idx_w) + 6
        content = content[:end_p] + '\n' + new_captures + content[end_p:]
        print(f'Captures L5 inserees apres {wave}')
        break

# ── 3. Renumerotation (du plus grand au plus petit) ────────────────────
replacements = [
    ('7.5 Conclusion</w:t>', '8.5 Conclusion</w:t>'),
    ('7.4 Perspectives', '8.4 Perspectives'),
    ('7.3 Déploiement', '8.3 Déploiement'),
    ('7.3 Deploiement', '8.3 Deploiement'),
    ('7.2 Métriques', '8.2 Métriques'),
    ('7.2 Metriques', '8.2 Metriques'),
    ('7.1 Récapitulatif', '8.1 Récapitulatif'),
    ('7.1 Recapitulatif', '8.1 Recapitulatif'),
    ('7. Bilan du projet</w:t>', '8. Bilan du projet</w:t>'),
    ('6.3 Gestion des erreurs', '7.3 Gestion des erreurs'),
    ('6.2 Bonnes pratiques', '7.2 Bonnes pratiques'),
    ('6.1 Conventions', '7.1 Conventions'),
    ('6. Qualité du code</w:t>', '7. Qualité du code</w:t>'),
    ('6. Qualite du code</w:t>', '7. Qualite du code</w:t>'),
    ('5.5 Badge non lus', '6.5 Badge non lus'),
    ('5.4 Personnalisation', '6.4 Personnalisation'),
    ('5.3 Double sauvegarde', '6.3 Double sauvegarde'),
    ('5.2 Bootstrap', '6.2 Bootstrap'),
    ('5.1 Réactivité', '6.1 Réactivité'),
    ('5.1 Reactivite', '6.1 Reactivite'),
    ('5. Solutions proposées et innovations</w:t>', '6. Solutions proposées et innovations</w:t>'),
    ('5. Solutions proposees et innovations</w:t>', '6. Solutions proposees et innovations</w:t>'),
    ('4.11 Photo', '5.11 Photo'),
    ('4.10 Compatibilité', '5.10 Compatibilité'),
    ('4.10 Compatibilite', '5.10 Compatibilite'),
    ('4.9 Crash Firebase', '5.9 Crash Firebase'),
    ('4.8 FAB', '5.8 FAB'),
    ('4.7 Perte d', '5.7 Perte d'),
    ('4.6 Header', '5.6 Header'),
    ('4.5 Overflow', '5.5 Overflow'),
    ('4.4 Session non restaurée', '5.4 Session non restaurée'),
    ('4.4 Session non restauree', '5.4 Session non restauree'),
    ('4.3 Erreur de cast', '5.3 Erreur de cast'),
    ('4.2 Pitchs non sauvegardés', '5.2 Pitchs non sauvegardés'),
    ('4.2 Pitchs non sauvegardes', '5.2 Pitchs non sauvegardes'),
    ('4.1 Crash au démarrage', '5.1 Crash au démarrage'),
    ('4.1 Crash au demarrage', '5.1 Crash au demarrage'),
    ('4. Difficultés rencontrées et solutions</w:t>', '5. Difficultés rencontrées et solutions</w:t>'),
    ('4. Difficultes rencontrees et solutions</w:t>', '5. Difficultes rencontrees et solutions</w:t>'),
]

for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        print(f'OK: {old[:50]}')
    else:
        print(f'SKIP: {old[:50]}')

# ── 4. Fix stray 's' ──────────────────────────────────────────────────
import re
content = re.sub(r'<w:t>s</w:t>', '', content)
print('Stray s removed')

with open(r'C:\Users\HP\OneDrive\Documents\Claude\Projects\ndiaye\livrables\docx\unpacked_l6\word\document.xml', 'w', encoding='utf-8') as f:
    f.write(content)
print('DONE')

# Proxy DIALI IA — Cloudflare Workers

Pourquoi : l'API Anthropic refuse les appels directs depuis un navigateur (CORS),
et embarquer une clé d'API côté client est une faille de sécurité. Ce dossier
contient un Worker Cloudflare qui sert de proxy : le client Flutter web l'appelle,
le Worker ajoute la clé Anthropic (stockée en secret côté serveur) et relaie la
réponse.

Quota gratuit Cloudflare Workers : **100 000 requêtes / jour**, pas de carte
bancaire demandée.

## Étapes de déploiement (via le dashboard, sans CLI)

1. **Révoque l'ancienne clé exposée** sur https://console.anthropic.com/settings/keys
   (elle a été publique sur GitHub et dans le bundle web).
2. **Génère une nouvelle clé** sur la même page (`Create Key`). Copie-la.
3. Crée un compte Cloudflare gratuit sur https://dash.cloudflare.com/sign-up
   (mail + mot de passe — pas de carte demandée).
4. Une fois connecté, va dans **Workers & Pages → Create application →
   Create Worker**.
5. Donne-lui un nom : `diali-proxy`. Clique sur **Deploy** (déploie une réponse
   "Hello World" par défaut).
6. Clique sur **Edit code** (en haut à droite de la page du Worker). Efface tout
   le contenu et **colle le contenu de [worker.js](worker.js)**. Clique sur
   **Deploy** en haut à droite.
7. Retour sur la page du Worker → **Settings → Variables and Secrets → Add
   variable** :
   - Variable name : `ANTHROPIC_API_KEY`
   - Type : **Secret**
   - Value : ta nouvelle clé Anthropic (`sk-ant-api03-…`)
   - Clique **Deploy** / **Save**.
8. Note l'URL du Worker, affichée en haut de sa page :
   `https://diali-proxy.<ton-sous-domaine>.workers.dev`.
9. **Mets cette URL dans Flutter** : ouvre
   `lib/services/service_chatbot.dart` et remplace la valeur de `_proxyUrl`
   par `https://diali-proxy.<ton-sous-domaine>.workers.dev/chat` (le `/chat`
   final est libre — le Worker répond sur tous les chemins).
10. `flutter build web --release && firebase deploy --only hosting`, vide le
    cache navigateur (Ctrl+Shift+R), teste DIALI IA.

## Test rapide depuis PowerShell

```powershell
curl.exe -X POST https://diali-proxy.<ton-sous-domaine>.workers.dev/chat `
  -H "Content-Type: application/json" `
  -d '{\"model\":\"claude-haiku-4-5-20251001\",\"max_tokens\":50,\"messages\":[{\"role\":\"user\",\"content\":\"Bonjour\"}]}'
```

Réponse attendue : un JSON avec `content[0].text` contenant la réponse de Claude.

## Sécurité

- La clé Anthropic n'est **jamais** dans le bundle web — elle vit uniquement
  dans les secrets Cloudflare, accessibles seulement depuis le Worker.
- Le code source ne contient plus de clé en dur.
- Pour limiter l'abus, tu peux restreindre l'origine CORS à `https://diapaler-africa.web.app`
  au lieu de `*` dans `worker.js` (ligne `Access-Control-Allow-Origin`).

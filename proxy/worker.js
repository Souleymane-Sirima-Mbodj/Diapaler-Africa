// Cloudflare Worker — Proxy DIALI IA → API Anthropic.
//
// Le navigateur ne peut pas appeler directement api.anthropic.com (CORS) et
// embarquer la clé côté client est une faille de sécurité. Ce Worker reçoit
// les messages du client Flutter, ajoute la clé stockée en secret côté
// serveur, et relaie la réponse.
//
// Variable d'environnement (secret) à configurer dans Cloudflare :
//   ANTHROPIC_API_KEY = sk-ant-api03-…
//
// Voir proxy/README.md pour les étapes de déploiement.

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Max-Age': '86400',
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }
    if (request.method !== 'POST') {
      return json({ error: { message: 'Method not allowed' } }, 405);
    }
    if (!env.ANTHROPIC_API_KEY) {
      return json(
        { error: { message: 'ANTHROPIC_API_KEY non configurée côté Worker.' } },
        500,
      );
    }

    let payload;
    try {
      payload = await request.json();
    } catch (_) {
      return json({ error: { message: 'JSON invalide.' } }, 400);
    }

    const upstream = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const body = await upstream.text();
    return new Response(body, {
      status: upstream.status,
      headers: {
        'Content-Type': 'application/json',
        ...CORS_HEADERS,
      },
    });
  },
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
  });
}

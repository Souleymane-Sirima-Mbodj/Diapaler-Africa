import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotMessage {
  final String role; // 'user' ou 'assistant'
  final String content;
  const ChatbotMessage({required this.role, required this.content});
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class ChatbotService {
  /// URL du proxy Cloudflare Worker qui détient la clé Groq côté serveur.
  /// Le Worker appelle l'API Groq (llama-3.1-8b-instant) et retourne
  /// le même format de réponse — aucun changement côté Flutter nécessaire.
  static const _proxyUrl =
      'https://diali-proxy.sirimambodj.workers.dev/chat';

  static const _model = 'llama-3.1-8b-instant';

  static String _systemPrompt({
    required String userName,
    required String userRole,
    required String userSector,
    required String userCity,
  }) {
    return '''Tu es DIALI, l'assistant IA de DIAPALER AFRICA — la plateforme qui connecte entrepreneurs, mentors et investisseurs au Sénégal et en Afrique de l'Ouest.

Tu accompagnes $userName, $userRole dans le secteur $userSector basé(e) à $userCity.

Tes domaines d'expertise :
• Stratégie entrepreneuriale et développement de projet au Sénégal
• Financement sénégalais : DER/FJ (100 000 à 30 000 000 FCFA), PAVIE 2, Be Yes (18-40 ans), ADPME, BNDE
• Conditions DER/FJ : nationalité sénégalaise, âge 18-35 ans, dossier complet (CNI, plan d'affaires, photos passeport, relevé de compte)
• Préparation de pitchs et dossiers investisseurs
• Marketing digital, e-commerce, Made in Sénégal
• Mise en relation mentors et investisseurs via DIAPALER

Directives :
- Réponds toujours en français, avec un ton bienveillant, concret et adapté au contexte africain
- Utilise ponctuellement des mots en wolof (Ndank ndank, Baraka, Jërejëf, Yëgël...) pour créer du lien
- Donne des conseils actionnables, pas des généralités
- Pour le financement, cite les montants en FCFA et les conditions précises
- Sois concis : 3-4 paragraphes maximum par réponse
- Si l'utilisateur demande de l'aide pour un pitch, propose-lui un plan structuré''';
  }

  static Future<String> sendMessage({
    required List<ChatbotMessage> messages,
    required String userName,
    required String userRole,
    required String userSector,
    required String userCity,
  }) async {
    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'model': _model,
            'max_tokens': 1024,
            'system': _systemPrompt(
              userName: userName,
              userRole: userRole,
              userSector: userSector,
              userCity: userCity,
            ),
            'messages': messages.map((m) => m.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      // Format Groq / OpenAI : { "choices": [{ "message": { "content": "..." } }] }
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices[0]?['message'];
        if (msg is Map) {
          final text = msg['content'];
          if (text is String && text.isNotEmpty) return text;
        }
      }

      // Format Anthropic : { "content": [{ "text": "..." }] }
      final content = data['content'];
      if (content is List && content.isNotEmpty) {
        final first = content[0];
        if (first is Map) {
          final text = first['text'];
          if (text is String && text.isNotEmpty) return text;
        }
      }

      // Fallback générique
      throw Exception('Format de réponse inattendu du serveur.');
    } else if (response.statusCode == 429) {
      throw Exception(
        'Limite d\'utilisation atteinte. Réessaie dans quelques instants.',
      );
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(
        body['error']?['message'] ?? 'Erreur API (${response.statusCode})',
      );
    }
  }
}

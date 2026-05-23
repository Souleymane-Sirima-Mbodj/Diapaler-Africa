import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotMessage {
  final String role; // 'user' ou 'assistant'
  final String content;
  const ChatbotMessage({required this.role, required this.content});
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class ChatbotService {
  static const _keyPref = 'anthropic_api_key';
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-haiku-4-5-20251001';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPref);
  }

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPref, key.trim());
  }

  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPref);
  }

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
    final key = await getApiKey();
    if (key == null || key.isEmpty) {
      throw Exception('no_key');
    }

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
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
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    } else if (response.statusCode == 401) {
      throw Exception(
        'Clé API invalide. Tape sur ⚙️ pour la corriger.',
      );
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

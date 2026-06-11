import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service d'upload vers Cloudinary via unsigned upload preset.
///
/// ──────────────────────────────────────────────
/// CONFIGURATION (à faire une seule fois) :
///
/// 1. Crée un compte sur https://cloudinary.com
/// 2. Note ton [_cloudName] affiché sur le dashboard (ex. "dxyz123abc")
/// 3. Va dans Settings → Upload → Upload Presets → Add upload preset
///    • Signing Mode : Unsigned
///    • Folder : pitches   (optionnel, pour organiser)
///    • Note le nom du preset (ex. "diapaler_unsigned")
/// 4. Renseigne les 2 constantes ci-dessous.
/// ──────────────────────────────────────────────
class CloudinaryService {
  /// Ton Cloud Name Cloudinary (visible sur dashboard.cloudinary.com)
  static const String _cloudName = 'ddpgzzwxb';

  /// Nom du preset non-signé créé dans Settings → Upload → Upload Presets
  static const String _uploadPreset = 'diapaler_unsigned';

  /// Uploade des octets en mémoire (photo, etc.) vers Cloudinary.
  /// Retourne l'URL publique HTTPS. Utilise pour les photos choisies depuis
  /// la galerie sans passer par un fichier temporaire.
  static Future<String> uploadBytes({
    required List<int> bytes,
    required String filename,
    String resourceType = 'image',
    String folder = 'avatars',
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = data['secure_url']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('URL absente dans la réponse Cloudinary.');
      }
      return url;
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      final msg = body?['error']?['message']?.toString() ?? response.body;
      throw Exception('Cloudinary erreur ${response.statusCode} : $msg');
    }
  }

  /// Uploade [filePath] vers Cloudinary et retourne l'URL publique HTTPS.
  ///
  /// [resourceType] : 'auto' détecte automatiquement image/video/raw (PDF).
  /// [folder]       : sous-dossier dans ton Cloud (ex. 'pitches/businessPlan').
  static Future<String> uploadFile({
    required String filePath,
    String resourceType = 'auto',
    String folder = 'pitches',
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = data['secure_url']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('URL absente dans la réponse Cloudinary.');
      }
      return url;
    } else {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      final msg = body?['error']?['message']?.toString() ?? response.body;
      throw Exception('Cloudinary erreur ${response.statusCode} : $msg');
    }
  }
}

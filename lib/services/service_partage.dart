import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ServicePartage — Partage de contenu sur les réseaux sociaux / messageries.
// Utilise share_plus qui ouvre la feuille de partage native du système
// (WhatsApp, Facebook, Telegram, X, LinkedIn, email, SMS…).
// ─────────────────────────────────────────────────────────────────────────────

class ShareService {
  ShareService._();

  /// Partage un pitch entrepreneur sur les réseaux sociaux.
  static Future<void> sharePitch({
    required String title,
    required String sector,
    required String description,
    required String authorName,
    String? amount,
  }) async {
    final amountLine = (amount != null && amount.isNotEmpty)
        ? '\n💰 Besoin de financement : $amount FCFA'
        : '';

    final preview = description.length > 200
        ? '${description.substring(0, 200)}…'
        : description;

    final text = '🚀 *$title* — Pitch sur DIAPALER AFRICA\n\n'
        '👤 $authorName · 🏢 $sector$amountLine\n\n'
        '📝 $preview\n\n'
        '🇸🇳 Retrouve ce projet sur DIAPALER AFRICA — la plateforme qui '
        'connecte entrepreneurs, mentors et investisseurs au Sénégal.\n\n'
        '👉 Télécharge : https://diapalerafrica.app';

    await Share.share(text, subject: 'Pitch : $title — DIAPALER AFRICA');
  }

  /// Partage le profil d'un mentor ou investisseur.
  static Future<void> shareMentorProfile({
    required String name,
    required String role,
    required String sector,
    required String city,
    String? bio,
  }) async {
    final bioLine = (bio != null && bio.isNotEmpty)
        ? '\n\n"${bio.length > 150 ? '${bio.substring(0, 150)}…' : bio}"'
        : '';

    final text = '👤 *$name* — $role sur DIAPALER AFRICA\n\n'
        '🏢 Secteur : $sector\n'
        '📍 $city$bioLine\n\n'
        '🤝 Tu cherches un mentor ou un investisseur ?\n'
        'Retrouve $name sur DIAPALER AFRICA.\n\n'
        '🇸🇳 Plateforme de mentorat entrepreneurial — Sénégal\n'
        '👉 https://diapalerafrica.app';

    await Share.share(text, subject: '$name — $role DIAPALER AFRICA');
  }

  /// Partage son propre profil entrepreneur.
  static Future<void> shareMyProfile({
    required String name,
    required String role,
    required String sector,
    required String city,
    String? projectName,
  }) async {
    final projectLine = (projectName != null && projectName.isNotEmpty)
        ? '\n🚀 Projet : $projectName'
        : '';

    final text = '👋 Je suis *$name*, $role sur DIAPALER AFRICA !\n\n'
        '🏢 Secteur : $sector\n'
        '📍 $city$projectLine\n\n'
        'Je recherche des mentors et investisseurs pour mon projet.\n'
        'Connectons-nous sur DIAPALER AFRICA !\n\n'
        '🇸🇳 https://diapalerafrica.app';

    await Share.share(text, subject: 'Mon profil DIAPALER AFRICA — $name');
  }

  /// Partage un conseil donné par DIALI IA.
  static Future<void> shareDialiAdvice({
    required String advice,
    required String userName,
  }) async {
    final preview = advice.length > 280
        ? '${advice.substring(0, 280)}…'
        : advice;

    final text = '💡 Conseil de *DIALI IA* pour $userName\n\n'
        '$preview\n\n'
        '🤖 DIALI est l\'assistant IA de DIAPALER AFRICA — spécialisé dans '
        'l\'écosystème sénégalais (DER/FJ, PAVIE 2, Be Yes, BNDE…).\n\n'
        '🇸🇳 https://diapalerafrica.app';

    await Share.share(text, subject: 'Conseil DIALI IA — DIAPALER AFRICA');
  }
}

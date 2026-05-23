import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

/// Avatar circulaire de l'utilisateur ou d'un mentor.
///
/// Affiche la photo de profil si [photoBase64] est fourni, sinon les
/// initiales sur un fond coloré. Un point vert optionnel indique la présence
/// en ligne.
class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final bool online;

  /// Photo de profil encodée en base64 (chaîne vide = avatar à initiales).
  final String photoBase64;

  const Avatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = AppColors.navy,
    this.foreground = Colors.white,
    this.online = false,
    this.photoBase64 = '',
  });

  /// Décode la photo en octets, ou renvoie `null` si absente / invalide.
  Uint8List? get _photoBytes {
    if (photoBase64.isEmpty) return null;
    try {
      return base64Decode(photoBase64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _photoBytes;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (bytes != null)
            ClipOval(
              child: Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _initialsCircle(),
              ),
            )
          else
            _initialsCircle(),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Cercle coloré affichant les initiales (avatar par défaut).
  Widget _initialsCircle() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: foreground,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

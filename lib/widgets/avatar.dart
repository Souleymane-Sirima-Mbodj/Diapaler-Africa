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

  /// Si true, un tap ouvre la photo en plein écran avec zoom (uniquement si
  /// [photoBase64] est non vide). Désactivé par défaut pour ne pas voler les
  /// taps des avatars utilisés dans des listes (qui naviguent ailleurs).
  final bool tappable;

  const Avatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = AppColors.navy,
    this.foreground = Colors.white,
    this.online = false,
    this.photoBase64 = '',
    this.tappable = false,
  });

  bool get _isUrl => photoBase64.startsWith('http://') || photoBase64.startsWith('https://');

  /// Décode la photo en octets, ou renvoie `null` si absente / invalide / URL.
  Uint8List? get _photoBytes {
    if (photoBase64.isEmpty || _isUrl) return null;
    try {
      return base64Decode(photoBase64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _photoBytes;
    final canZoom = tappable && (bytes != null || _isUrl);
    final avatar = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_isUrl)
            ClipOval(
              child: Image.network(
                photoBase64,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsCircle(),
              ),
            )
          else if (bytes != null)
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
    if (!canZoom) return avatar;
    return MouseRegion(
      cursor: SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTap: () {
          if (_isUrl) {
            _openUrlViewer(context, photoBase64);
          } else if (bytes != null) {
            _openPhotoViewer(context, bytes);
          }
        },
        child: avatar,
      ),
    );
  }

  void _openPhotoViewer(BuildContext context, Uint8List bytes) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _PhotoViewer(bytes: bytes),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openUrlViewer(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _PhotoViewerUrl(url: url),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
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

/// Visionneuse plein écran zoomable pour une photo chargée depuis une URL.
class _PhotoViewerUrl extends StatelessWidget {
  final String url;
  const _PhotoViewerUrl({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white54,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Fermer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Visionneuse plein écran zoomable pour une photo (octets décodés).
class _PhotoViewer extends StatelessWidget {
  final Uint8List bytes;
  const _PhotoViewer({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Center(
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  tooltip: 'Fermer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

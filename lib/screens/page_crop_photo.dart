import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

/// Page de recadrage d'image interactive.
/// Utilisateur peut ajuster le rectangle de crop et confirmer.
class CropPhotoPage extends StatefulWidget {
  final Uint8List imageBytes;

  const CropPhotoPage({super.key, required this.imageBytes});

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();
}

class _CropPhotoPageState extends State<CropPhotoPage> {
  late final CropController _cropController;

  @override
  void initState() {
    super.initState();
    _cropController = CropController(
      aspectRatio: 1.0, // Carré (idéal pour avatar)
      defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );
  }

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _crop() async {
    try {
      // Obtenir l'image croppée sous forme de bitmap
      final ui.Image croppedBitmap = await _cropController.croppedBitmap();
      
      // Convertir en bytes PNG
      final ByteData? byteData = await croppedBitmap.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List croppedBytes = byteData!.buffer.asUint8List();
      
      if (!mounted) return;
      Navigator.of(context).pop(croppedBytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de recadrage: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recadrer ta photo'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: AppColors.navyDeep,
                child: CropImage(
                  controller: _cropController,
                  image: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                  gridColor: AppColors.amber.withOpacity(0.7),
                  gridInnerColor: AppColors.amber.withOpacity(0.3),
                  gridCornerColor: AppColors.amber,
                  scrimColor: Colors.black.withOpacity(0.6),
                  alwaysShowThirdLines: false,
                  onCrop: (_) {}, // Callback pour chaque modification
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  const Text(
                    'Ajuste le carré pour centrer ta photo',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _crop,
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

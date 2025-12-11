import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:petcare/core/color_theme.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Límite de tamaño: 2MB en bytes
  static const int maxFileSizeBytes = 2 * 1024 * 1024; // 2MB

  /// Selecciona, valida y recorta una imagen para foto de perfil
  /// Retorna el archivo de imagen recortado o null si se cancela/falla
  Future<File?> pickAndCropImage(BuildContext context) async {
    try {
      // Paso 1: Seleccionar imagen de la galería
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // Usuario canceló la selección
        return null;
      }

      // Paso 2: Validar tamaño del archivo
      final File imageFile = File(pickedFile.path);
      final int fileSize = await imageFile.length();

      if (fileSize > maxFileSizeBytes) {
        // Mostrar advertencia pero permitir continuar con compresión
        if (context.mounted) {
          final bool? shouldContinue = await _showSizeWarningDialog(
            context,
            fileSize,
          );

          if (shouldContinue != true) {
            return null;
          }
        }
      }

      // Paso 3: Leer bytes de la imagen
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Paso 4: Mostrar interfaz de recorte
      if (!context.mounted) return null;

      final Uint8List? croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (context) => _ImageCropperScreen(
            imageBytes: imageBytes,
            originalPath: pickedFile.path,
          ),
        ),
      );

      if (croppedBytes == null) {
        // Usuario canceló el recorte
        return null;
      }

      // Paso 5: Guardar imagen recortada en archivo temporal
      final String tempPath =
          '${imageFile.parent.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File(tempPath);
      await croppedFile.writeAsBytes(croppedBytes);

      // Paso 6: Verificar tamaño final después del recorte
      final int finalSize = await croppedFile.length();

      if (finalSize > maxFileSizeBytes) {
        // Aún muy grande después del recorte
        if (context.mounted) {
          _showErrorDialog(
            context,
            'La imagen es demasiado grande incluso después de la compresión. '
            'Por favor, selecciona una imagen más pequeña.',
          );
        }
        // Eliminar archivo temporal
        await croppedFile.delete();
        return null;
      }

      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error al procesar la imagen. Por favor, intenta de nuevo.',
        );
      }
      return null;
    }
  }

  /// Muestra un diálogo de advertencia sobre el tamaño del archivo
  Future<bool?> _showSizeWarningDialog(
    BuildContext context,
    int fileSizeBytes,
  ) async {
    final double fileSizeMB = fileSizeBytes / (1024 * 1024);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Imagen grande',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'La imagen seleccionada tiene ${fileSizeMB.toStringAsFixed(1)} MB. '
            'El límite recomendado es 2 MB.\n\n'
            'Se comprimirá automáticamente durante el recorte. '
            '¿Deseas continuar?',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Error',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Formatea el tamaño de archivo a una cadena legible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Pantalla de recorte de imagen
class _ImageCropperScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String originalPath;

  const _ImageCropperScreen({
    required this.imageBytes,
    required this.originalPath,
  });

  @override
  State<_ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<_ImageCropperScreen> {
  final _cropController = CropController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Ajustar foto de perfil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _cropImage,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              onCropped: (croppedData) {
                setState(() => _isProcessing = false);
                Navigator.of(context).pop(croppedData);
              },
              aspectRatio: 1.0, // Relación 1:1 para foto de perfil
              initialSize: 0.8,
              withCircleUi: true, // UI circular
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.7),
              radius: 20,
              cornerDotBuilder: (size, edgeAlignment) =>
                  const DotControl(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  void _cropImage() {
    setState(() => _isProcessing = true);
    _cropController.crop();
  }
}

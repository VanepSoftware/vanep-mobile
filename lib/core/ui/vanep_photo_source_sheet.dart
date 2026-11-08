import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

Future<PhotoSource?> showVanepPhotoSourceSheet(
  BuildContext context, {
  required String galleryLabel,
  required String cameraLabel,
}) {
  return showModalBottomSheet<PhotoSource>(
    context: context,
    backgroundColor: context.palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VanepPhotoSourceOption(
              icon: Icons.photo_library_outlined,
              label: galleryLabel,
              onTap: () => Navigator.of(sheetContext).pop(PhotoSource.gallery),
            ),
            VanepPhotoSourceOption(
              icon: Icons.photo_camera_outlined,
              label: cameraLabel,
              onTap: () => Navigator.of(sheetContext).pop(PhotoSource.camera),
            ),
          ],
        ),
      ),
    ),
  );
}

class VanepPhotoSourceOption extends StatelessWidget {
  const VanepPhotoSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.palette.textPrimary),
      title: Text(label, style: context.typography.body),
      onTap: onTap,
    );
  }
}

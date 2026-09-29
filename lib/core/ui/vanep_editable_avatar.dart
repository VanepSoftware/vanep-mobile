import 'package:flutter/material.dart';

import 'vanep_avatar.dart';
import 'vanep_photo_edit_badge.dart';

class VanepEditableAvatar extends StatelessWidget {
  const VanepEditableAvatar({
    required this.semanticLabel,
    required this.onTap,
    this.photoUrl,
    this.size = 96,
    this.isUploading = false,
    super.key,
  });

  final String semanticLabel;
  final VoidCallback? onTap;
  final String? photoUrl;
  final double size;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isUploading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              VanepAvatar(photoUrl: photoUrl, size: size),
              if (isUploading)
                const Positioned.fill(
                  child: VanepUploadingOverlay(shape: BoxShape.circle),
                ),
              if (onTap != null && !isUploading)
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: VanepPhotoEditBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

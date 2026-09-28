import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

class VanepPhotoEditBadge extends StatelessWidget {
  const VanepPhotoEditBadge({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: VanepColors.action,
          shape: BoxShape.circle,
          border: Border.all(color: VanepColors.card, width: 2),
        ),
        child: Icon(
          Icons.photo_camera_outlined,
          size: size * 0.5,
          color: VanepColors.card,
        ),
      ),
    );
  }
}

class VanepUploadingOverlay extends StatelessWidget {
  const VanepUploadingOverlay({this.shape = BoxShape.rectangle, super.key});

  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VanepColors.textPrimary.withValues(alpha: 0.45),
        shape: shape,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: VanepColors.card,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import '../network/api_image_provider.dart';
import 'vanep_photo_edit_badge.dart';

class VanepPhotoSlot extends StatelessWidget {
  const VanepPhotoSlot({
    this.photoUrl,
    this.label,
    this.placeholderIcon = Icons.image_outlined,
    this.onTap,
    this.isUploading = false,
    this.aspectRatio = 4 / 3,
    super.key,
  });

  final String? photoUrl;
  final String? label;
  final IconData placeholderIcon;
  final VoidCallback? onTap;
  final bool isUploading;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final image = apiImageFor(context, photoUrl);
    final placeholder = VanepPhotoPlaceholder(icon: placeholderIcon);
    final label = this.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Semantics(
            button: onTap != null,
            label: label,
            child: Material(
              color: VanepColors.avatarPlaceholder,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isUploading ? null : onTap,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (image == null)
                      placeholder
                    else
                      Image(
                        image: image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            placeholder,
                      ),
                    if (isUploading) const VanepUploadingOverlay(),
                    if (onTap != null && !isUploading)
                      const Positioned(
                        right: 8,
                        bottom: 8,
                        child: VanepPhotoEditBadge(size: 26),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(label, style: VanepTypography.cardSubtitle),
        ],
      ],
    );
  }
}

class VanepPhotoPlaceholder extends StatelessWidget {
  const VanepPhotoPlaceholder({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon, size: 32, color: VanepColors.textMuted));
  }
}

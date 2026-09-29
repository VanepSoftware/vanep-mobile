import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../network/api_image_provider.dart';

class VanepAvatar extends StatelessWidget {
  const VanepAvatar({
    this.photoUrl,
    this.size = 48,
    this.placeholderIcon = Icons.person_outline,
    super.key,
  });

  final String? photoUrl;
  final double size;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final image = apiImageFor(context, photoUrl);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: VanepColors.avatarPlaceholder,
      foregroundImage: image,
      onForegroundImageError: image == null
          ? null
          : keepPlaceholderOnImageError,
      child: Icon(
        placeholderIcon,
        size: size * 0.5,
        color: VanepColors.textMuted,
      ),
    );
  }
}

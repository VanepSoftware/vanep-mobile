import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';

class VanepAvatar extends StatelessWidget {
  const VanepAvatar({
    this.photoUrl,
    this.size = 48,
    this.placeholderIcon = Icons.person_outline,
    this.initials,
    this.backgroundColor = VanepColors.avatarPlaceholder,
    this.foregroundColor = VanepColors.textMuted,
    super.key,
  });

  final String? photoUrl;
  final double size;
  final IconData placeholderIcon;
  final String? initials;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final image = apiImageFor(context, photoUrl);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      foregroundImage: image,
      onForegroundImageError: image == null
          ? null
          : keepPlaceholderOnImageError,
      child: initials == null
          ? Icon(placeholderIcon, size: size * 0.5, color: foregroundColor)
          : Text(
              initials!,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
    );
  }
}

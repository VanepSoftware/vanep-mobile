import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/network/api_image.dart';

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({required this.photoUrl, this.size = 48, super.key});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: VanepColors.avatarPlaceholder,
      foregroundImage: ApiImage.forPath(photoUrl),
      child: Icon(
        Icons.person_outline,
        size: size * 0.55,
        color: VanepColors.textMuted,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({required this.photoUrl, this.size = 48, super.key});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: VanepColors.avatarPlaceholder,
      foregroundImage: (url != null && url.isNotEmpty)
          ? NetworkImage(url)
          : null,
      child: Icon(
        Icons.person_outline,
        size: size * 0.55,
        color: VanepColors.textMuted,
      ),
    );
  }
}

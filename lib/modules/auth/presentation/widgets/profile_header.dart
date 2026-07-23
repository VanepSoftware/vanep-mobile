import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    super.key,
  });

  final String name;
  final String? email;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfileAvatar(photoUrl: photoUrl),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: VanepTypography.pageTitle.copyWith(fontSize: 22),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (email != null && email!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  email!,
                  style: VanepTypography.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({this.photoUrl, this.size = 72, super.key});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: VanepColors.avatarPlaceholder,
            foregroundImage: (url != null && url.isNotEmpty)
                ? NetworkImage(url)
                : null,
            child: Icon(
              Icons.person_outline,
              size: size * 0.45,
              color: VanepColors.textMuted,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: IgnorePointer(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: VanepColors.brand.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: VanepColors.card, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 14,
                  color: VanepColors.card,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    this.rating,
    this.city,
    this.statusLabel,
    this.statusColor,
    super.key,
  });

  final String name;
  final String? email;
  final String? photoUrl;
  final double? rating;
  final String? city;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final hasRatingOrCity =
        rating != null || (city != null && city!.isNotEmpty);
    final hasStatus = statusLabel != null && statusLabel!.isNotEmpty;

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
              if (hasRatingOrCity) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (rating != null) ...[
                      const Icon(
                        Icons.star,
                        size: 15,
                        color: VanepColors.ratingStar,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: VanepTypography.ratingLabel,
                      ),
                    ],
                    if (rating != null && city != null)
                      const Text(
                        ' · ',
                        style: TextStyle(color: VanepColors.textMuted),
                      ),
                    if (city != null)
                      Flexible(
                        child: Text(
                          city!,
                          style: VanepTypography.cardSubtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ] else if (hasStatus) ...[
                const SizedBox(height: 6),
                ProfileAssistantStatusChip(
                  label: statusLabel!,
                  color: statusColor ?? VanepColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileAssistantStatusChip extends StatelessWidget {
  const ProfileAssistantStatusChip({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: VanepTypography.cardSubtitle.copyWith(
            color: color,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver.dart';
import 'driver_avatar.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    required this.driver,
    this.onTap,
    this.coverage = const [],
    super.key,
  });

  final Driver driver;
  final VoidCallback? onTap;

  final List<String> coverage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return VanepCard(
      onTap: onTap,
      child: Row(
        children: [
          DriverAvatar(photoUrl: driver.photoUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.name, style: VanepTypography.cardTitle),
                if (coverage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatDriverCoverage(coverage),
                    style: VanepTypography.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (driver.experienceYears != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.driverExperienceYears(driver.experienceYears!),
                    style: VanepTypography.cardSubtitle,
                  ),
                ],
                const SizedBox(height: 6),
                DriverRatingRow(rating: driver.rating, city: driver.city),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: VanepColors.textMuted),
        ],
      ),
    );
  }
}

/// Placeholder that mirrors [DriverCard]'s layout while the list is loading.
class DriverCardSkeleton extends StatelessWidget {
  const DriverCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepCard(
      child: Row(
        children: [
          Bone.circle(size: 48),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2, fontSize: 16),
                SizedBox(height: 6),
                Bone.text(words: 3, fontSize: 13),
                SizedBox(height: 6),
                Bone.text(width: 96, fontSize: 13),
              ],
            ),
          ),
          SizedBox(width: 12),
          Bone.icon(size: 20),
        ],
      ),
    );
  }
}

String formatDriverCoverage(List<String> coverage) {
  return coverage.map(firstWordOf).where((word) => word.isNotEmpty).join(' · ');
}

String firstWordOf(String region) {
  final trimmed = region.trim();
  if (trimmed.isEmpty) return '';
  final separator = trimmed.indexOf(' ');
  return separator == -1 ? trimmed : trimmed.substring(0, separator);
}

class DriverRatingRow extends StatelessWidget {
  const DriverRatingRow({required this.rating, required this.city, super.key});

  final double? rating;
  final String? city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (rating != null) ...[
          const Icon(Icons.star, size: 15, color: VanepColors.ratingStar),
          const SizedBox(width: 4),
          Text(rating!.toStringAsFixed(1), style: VanepTypography.ratingLabel),
        ],
        if (rating != null && city != null)
          const Text(' · ', style: TextStyle(color: VanepColors.textMuted)),
        if (city != null)
          Flexible(
            child: Text(
              city!,
              style: VanepTypography.cardSubtitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

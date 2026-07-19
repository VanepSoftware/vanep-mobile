import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver.dart';
import 'driver_avatar.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({required this.driver, this.onTap, super.key});

  final Driver driver;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: VanepColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              DriverAvatar(photoUrl: driver.photoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: VanepTypography.cardTitle),
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
              const Icon(
                Icons.chevron_right,
                color: VanepColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_avatar.dart';
import '../../../../core/ui/vanep_photo_slot.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver_profile.dart';
import '../formatters/driver_profile_formatters.dart';

class DriverProfileHeader extends StatelessWidget {
  const DriverProfileHeader({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return ColoredBox(
      color: VanepColors.actionSurface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topInset, 20, 24),
        child: Column(
          children: [
            VanepAvatar(photoUrl: profile.photoUrl, size: 96),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: VanepTypography.heading,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DriverProfileHighlights extends StatelessWidget {
  const DriverProfileHighlights({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final experienceYears = profile.experienceYears;
    final rating = profile.rating;

    return Column(
      children: [
        if (experienceYears != null)
          Text(
            l10n.driverProfileExperience(experienceYears),
            style: VanepTypography.cardSubtitle,
          ),
        if (rating != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: VanepColors.ratingStar),
              const SizedBox(width: 4),
              Text(
                l10n.driverProfileRating(rating.toStringAsFixed(1)),
                style: VanepTypography.ratingLabel.copyWith(
                  color: VanepColors.ratingStar,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class DriverProfileInfoRow extends StatelessWidget {
  const DriverProfileInfoRow({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: VanepColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: VanepTypography.body)),
        ],
      ),
    );
  }
}

class DriverProfileVehicleSection extends StatelessWidget {
  const DriverProfileVehicleSection({required this.vehicle, super.key});

  final DriverProfileVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatVanTitle(l10n, vehicle), style: VanepTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            formatVanDetails(l10n, vehicle),
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.driverProfileVanPhotos,
            style: VanepTypography.cardSubtitle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: VanepPhotoSlot(
                  photoUrl: vehicle.photoFrontUrl,
                  placeholderIcon: Icons.airport_shuttle_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VanepPhotoSlot(
                  photoUrl: vehicle.photoSideUrl,
                  placeholderIcon: Icons.airport_shuttle_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

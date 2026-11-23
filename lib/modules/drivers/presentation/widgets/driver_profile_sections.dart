import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/network/api_image_provider.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_ratings_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_van_photos_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_verification_sheet.dart';

class DriverProfileCoverCarousel extends StatefulWidget {
  const DriverProfileCoverCarousel({required this.profile, super.key});

  final DriverProfile profile;

  @override
  State<DriverProfileCoverCarousel> createState() =>
      _DriverProfileCoverCarouselState();
}

class _DriverProfileCoverCarouselState
    extends State<DriverProfileCoverCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photos = collectDriverVehiclePhotos(l10n, widget.profile);

    return GestureDetector(
      onTap: photos.isEmpty
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DriverVanPhotosPage(profile: widget.profile),
                ),
              ),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              Container(
                color: context.palette.avatarPlaceholder,
                child: Icon(
                  Icons.directions_bus_outlined,
                  size: 48,
                  color: context.palette.textMuted,
                ),
              )
            else
              PageView.builder(
                controller: _controller,
                itemCount: photos.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final entry = photos[index];
                  final image = apiImageFor(context, entry.url);
                  if (image == null) {
                    return Container(color: context.palette.avatarPlaceholder);
                  }
                  return Image(
                    image: image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: context.palette.avatarPlaceholder,
                      child: Icon(
                        Icons.directions_bus_outlined,
                        size: 48,
                        color: context.palette.textMuted,
                      ),
                    ),
                  );
                },
              ),
            if (photos.isNotEmpty)
              Positioned(
                right: 16,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.driverProfilePhotoCounter(_index + 1, photos.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DriverProfileIdentityBlock extends StatelessWidget {
  const DriverProfileIdentityBlock({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = vanepInitialAvatarColors(context.palette, profile.token);
    final rating = profile.rating;
    final experience = profile.experienceYears;
    final count = profile.ratingCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        VanepAvatar(
          photoUrl: profile.photoUrl,
          size: 56,
          initials: vanepInitialOf(profile.name),
          backgroundColor: tone.surface,
          foregroundColor: tone.text,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.name,
                      style: context.typography.heading.copyWith(fontSize: 20),
                    ),
                  ),
                  if (profile.verified) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: context.palette.action,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  if (rating != null) ...[
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: context.palette.warning,
                    ),
                    Text(
                      count != null && count > 0
                          ? l10n.driverProfileRatingSummary(
                              formatDriverRating(l10n, rating),
                              count,
                            )
                          : formatDriverRating(l10n, rating),
                      style: context.typography.ratingLabel,
                    ),
                  ] else
                    Text(
                      l10n.findVanNewOnVanep,
                      style: context.typography.cardSubtitle,
                    ),
                ],
              ),
              if (experience != null && experience > 0) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.driverProfileExperience(experience),
                  style: context.typography.cardSubtitle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class DriverProfileVacanciesCard extends StatelessWidget {
  const DriverProfileVacanciesCard({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = profile.basePrice;
    final vacancies = profile.shiftVacancies;

    return VanepSection(
      title: l10n.driverProfileVacanciesSectionTitle,
      child: VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vacancies.isNotEmpty)
              for (var i = 0; i < vacancies.length; i++) ...[
                _ShiftVacancyRow(vacancy: vacancies[i]),
                if (i < vacancies.length - 1) const SizedBox(height: 8),
              ]
            else
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: profile.available
                          ? context.palette.success
                          : context.palette.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.available
                        ? l10n.findVanSpotsAvailable
                        : l10n.findVanSpotsFull,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: profile.available
                          ? context.palette.success
                          : context.palette.danger,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Divider(height: 1, color: context.palette.divider),
            const SizedBox(height: 12),
            if (price != null)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.driverProfileStartingFromValue(
                        formatMoney(l10n, (price * 100).round()),
                      ),
                      style: context.typography.cardTitle,
                    ),
                    TextSpan(
                      text: l10n.findVanPerMonth,
                      style: context.typography.cardSubtitle,
                    ),
                  ],
                ),
              )
            else
              Text(
                l10n.findVanPriceOnRequest,
                style: context.typography.cardSubtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShiftVacancyRow extends StatelessWidget {
  const _ShiftVacancyRow({required this.vacancy});

  final DriverShiftVacancy vacancy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spots = vacancy.spots;
    final String statusLabel;
    final Color statusColor;

    if (vacancy.status != null && vacancy.status!.isNotEmpty) {
      statusLabel = vacancy.status!;
      statusColor = (spots ?? 1) <= 0
          ? context.palette.danger
          : spots == 1
          ? context.palette.warning
          : context.palette.success;
    } else if (spots == null || spots <= 0) {
      statusLabel = l10n.driverProfileShiftFull;
      statusColor = context.palette.danger;
    } else {
      statusLabel = l10n.driverProfileShiftVacancyAvailable(spots);
      statusColor = spots == 1
          ? context.palette.warning
          : context.palette.success;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(vacancy.shift, style: context.typography.body)),
        const SizedBox(width: 8),
        Text(
          statusLabel,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}

class DriverProfileVansSection extends StatelessWidget {
  const DriverProfileVansSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicles = profile.vehicles;

    return VanepSection(
      title: l10n.driverProfileVansSectionTitle,
      child: vehicles.isEmpty
          ? VanepCard(
              child: Text(
                l10n.driverProfileNoVan,
                style: context.typography.cardSubtitle,
              ),
            )
          : VanepCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DriverVanPhotosPage(profile: profile),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < vehicles.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatVanModelYear(l10n, vehicles[i]),
                                style: context.typography.cardTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatVanPublicSubtitle(l10n, vehicles[i]),
                                style: context.typography.cardSubtitle,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: context.palette.textMuted,
                        ),
                      ],
                    ),
                    if (i < vehicles.length - 1) ...[
                      const SizedBox(height: 12),
                      Divider(height: 1, color: context.palette.divider),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}

class DriverProfileServiceSection extends StatelessWidget {
  const DriverProfileServiceSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final areas = formatServiceAreaList(profile.serviceAreas);
    final workStart = profile.workStartTime;
    final workEnd = profile.workEndTime;
    final workDays = profile.workDays;
    final waitMinutes = profile.waitToleranceMinutes;

    final rows = <({String label, String value})>[
      if (areas.isNotEmpty)
        (label: l10n.driverProfileServiceAreasLabel, value: areas),
      if (workStart != null && workEnd != null)
        (
          label: l10n.driverProfileWorkHoursLabel,
          value: workDays != null && workDays.isNotEmpty
              ? l10n.driverProfileWorkHoursValue(workStart, workEnd, workDays)
              : '$workStart às $workEnd',
        ),
      if (waitMinutes != null)
        (
          label: l10n.driverProfileWaitToleranceLabel,
          value: l10n.driverProfileWaitToleranceValue(waitMinutes),
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return VanepSection(
      title: l10n.driverProfileServiceSectionTitle,
      child: VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      rows[i].label,
                      style: context.typography.cardSubtitle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      style: context.typography.body.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              if (i < rows.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class DriverProfileVerifiedCard extends StatelessWidget {
  const DriverProfileVerifiedCard({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      onTap: () => DriverVerificationSheet.show(
        context,
        driverName: profile.name,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.palette.successSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: context.palette.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverProfileVerifiedCardTitle,
                  style: context.typography.cardTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.driverProfileVerifiedCardSubtitle,
                  style: context.typography.cardSubtitle,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.palette.textMuted),
        ],
      ),
    );
  }
}

class DriverProfileRatingsSection extends StatelessWidget {
  const DriverProfileRatingsSection({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasDetail =
        profile.ratings.isNotEmpty || profile.ratingBreakdown.isNotEmpty;
    if (profile.rating == null && !hasDetail) {
      return const SizedBox.shrink();
    }
    final previews = profile.ratings.take(2).toList();

    return VanepSection(
      title: l10n.driverProfileReviewsSectionTitle,
      actionLabel: hasDetail ? l10n.driverProfileSeeAllReviews : null,
      onAction: hasDetail
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DriverRatingsPage(profile: profile),
                ),
              )
          : null,
      child: Column(
        children: [
          DriverRatingsSummaryCard(profile: profile),
          for (final review in previews) ...[
            const SizedBox(height: 10),
            DriverReviewCard(review: review),
          ],
        ],
      ),
    );
  }
}

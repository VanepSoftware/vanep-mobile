import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';

class FindVanDriverCard extends StatelessWidget {
  const FindVanDriverCard({
    required this.driver,
    this.onTap,
    this.onProfileTapped,
    this.onQuoteRequested,
    super.key,
  });

  final DriverSearchResult driver;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTapped;
  final VoidCallback? onQuoteRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = vanepInitialAvatarColors(context.palette, driver.token);
    final coverageSummary = driver.serviceAreas.join(' · ');

    return Material(
      color: context.palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.palette.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? onProfileTapped,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VanepAvatar(
                    photoUrl: driver.photoUrl,
                    size: 48,
                    initials: initialsOf(driver.name),
                    backgroundColor: tone.surface,
                    foregroundColor: tone.text,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                driver.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.typography.cardTitle.copyWith(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: context.palette.action,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        _RatingAndExperienceLine(driver: driver),
                        if (coverageSummary.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            coverageSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.cardSubtitle.copyWith(
                              fontSize: 12.5,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AvailabilityLine(available: driver.available),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: context.palette.divider,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PriceFooter(basePrice: driver.basePrice),
                    Wrap(
                      spacing: 4,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: onProfileTapped ?? onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: context.palette.action,
                            minimumSize: const Size(44, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.findVanProfileButton,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: context.palette.action,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: driver.available ? onQuoteRequested : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: context.palette.action,
                            foregroundColor: context.palette.onAction,
                            disabledBackgroundColor:
                                context.palette.inputBorder,
                            disabledForegroundColor:
                                context.palette.textMuted,
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.driverRequestQuoteButton,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingAndExperienceLine extends StatelessWidget {
  const _RatingAndExperienceLine({required this.driver});

  final DriverSearchResult driver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rating = driver.rating;
    final experienceYears = driver.experienceYears;

    return Row(
      children: [
        if (rating != null) ...[
          const Icon(
            Icons.star_rounded,
            size: 15,
            color: VanepColors.ratingStar,
          ),
          const SizedBox(width: 3),
          Text(
            _formatRating(l10n, rating),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
        ] else ...[
          Text(
            l10n.findVanNewOnVanep,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.palette.action,
            ),
          ),
        ],
        if (experienceYears != null)
          Flexible(
            child: Text(
              ' · ${l10n.findVanExperienceYearsShort(experienceYears)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.cardSubtitle.copyWith(
                fontSize: 12.5,
              ),
            ),
          ),
      ],
    );
  }

  String _formatRating(AppLocalizations l10n, double value) {
    final raw = value.toStringAsFixed(1);
    return l10n.localeName.startsWith('pt') ? raw.replaceAll('.', ',') : raw;
  }
}

class _AvailabilityLine extends StatelessWidget {
  const _AvailabilityLine({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusText = available
        ? l10n.findVanSpotsAvailable
        : l10n.findVanSpotsFull;
    final statusColor = available
        ? context.palette.success
        : context.palette.danger;

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: statusColor,
      ),
    );
  }
}

class _PriceFooter extends StatelessWidget {
  const _PriceFooter({required this.basePrice});

  final double? basePrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = basePrice;
    if (price == null) {
      return Text(
        l10n.findVanPriceOnRequest,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: context.palette.textSecondary,
        ),
      );
    }

    final cents = (price * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.findVanPriceStartingFrom,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: context.palette.textSecondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                formatMoney(l10n, cents),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: context.palette.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            Text(
              l10n.findVanPerMonth,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

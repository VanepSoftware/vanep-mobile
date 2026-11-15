import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    required this.driver,
    this.onTap,
    this.coverage = const [],
    this.basePriceCents,
    this.onQuoteRequested,
    super.key,
  });

  final Driver driver;
  final VoidCallback? onTap;

  final List<String> coverage;

  final int? basePriceCents;

  final VoidCallback? onQuoteRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final basePriceCents = this.basePriceCents;
    final onQuoteRequested = this.onQuoteRequested;
    final summary = Row(
      children: [
        VanepAvatar(photoUrl: driver.photoUrl),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver.name, style: context.typography.cardTitle),
              if (coverage.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  formatDriverCoverage(coverage),
                  style: context.typography.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (driver.experienceYears != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.driverExperienceYears(driver.experienceYears!),
                  style: context.typography.cardSubtitle,
                ),
              ],
              const SizedBox(height: 6),
              DriverRatingRow(rating: driver.rating, city: driver.city),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: context.palette.textMuted),
      ],
    );

    return VanepCard(
      onTap: onTap,
      child: basePriceCents == null && onQuoteRequested == null
          ? summary
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: basePriceCents == null
                          ? const SizedBox.shrink()
                          : Text(
                              l10n.driverBasePriceFrom(
                                formatMoney(l10n, basePriceCents),
                              ),
                              style: context.typography.cardSubtitle.copyWith(
                                color: context.palette.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    if (onQuoteRequested != null)
                      SizedBox(
                        width: 168,
                        child: VanepSecondaryButton(
                          label: l10n.driverRequestQuoteButton,
                          onPressed: onQuoteRequested,
                        ),
                      ),
                  ],
                ),
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
          Text(
            rating!.toStringAsFixed(1),
            style: context.typography.ratingLabel,
          ),
        ],
        if (rating != null && city != null)
          Text(' · ', style: TextStyle(color: context.palette.textMuted)),
        if (city != null)
          Flexible(
            child: Text(
              city!,
              style: context.typography.cardSubtitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

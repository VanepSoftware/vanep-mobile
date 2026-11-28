import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/presentation/formatters/driver_profile_formatters.dart';

class DriverRatingsPage extends StatelessWidget {
  const DriverRatingsPage({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(
        title: l10n.driverProfileRatingsTitle,
        caption: profile.name,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          DriverRatingsSummaryCard(profile: profile),
          const SizedBox(height: 16),
          if (profile.ratings.isEmpty)
            VanepCard(
              child: Text(
                l10n.driverProfileNoReviewsYet,
                style: context.typography.cardSubtitle,
              ),
            )
          else
            for (final review in profile.ratings) ...[
              DriverReviewCard(review: review),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class DriverRatingsSummaryCard extends StatelessWidget {
  const DriverRatingsSummaryCard({required this.profile, super.key});

  final DriverProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rating = profile.rating;
    final count = profile.ratingCount ?? profile.ratings.length;
    final breakdown = profile.ratingBreakdown;
    final totalVotes = breakdown.fold<int>(0, (sum, entry) => sum + entry.count);

    return VanepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating != null ? formatDriverRating(l10n, rating) : '—',
                style: context.typography.pageTitle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: rating != null && index < rating.round()
                        ? context.palette.warning
                        : context.palette.divider,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count > 0
                    ? l10n.driverProfileReviewsCount(count)
                    : l10n.findVanNewOnVanep,
                style: context.typography.cardSubtitle,
              ),
            ],
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (final stars in [5, 4, 3, 2, 1]) ...[
                    _BreakdownBarRow(
                      stars: stars,
                      count: breakdown
                          .where((item) => item.stars == stars)
                          .fold<int>(0, (sum, item) => sum + item.count),
                      total: totalVotes,
                    ),
                    if (stars > 1) const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownBarRow extends StatelessWidget {
  const _BreakdownBarRow({
    required this.stars,
    required this.count,
    required this.total,
  });

  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '$stars',
            style: context.typography.cardSubtitle.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: context.palette.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.palette.warning,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DriverReviewCard extends StatelessWidget {
  const DriverReviewCard({required this.review, super.key});

  final DriverProfileRating review;

  @override
  Widget build(BuildContext context) {
    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(review.authorName, style: context.typography.sectionTitle),
              if (review.dateLabel.isNotEmpty)
                Text(
                  review.dateLabel,
                  style: context.typography.cardSubtitle,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                size: 16,
                color: index < review.stars
                    ? context.palette.warning
                    : context.palette.divider,
              ),
            ),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: context.typography.body),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
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
    final openProfile = onProfileTapped ?? onTap;

    return VanepCard(
      onTap: openProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VanepAvatar(
                photoUrl: driver.photoUrl,
                size: 48,
                initials: vanepInitialOf(driver.name),
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
                            style: context.typography.cardTitle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: context.palette.action,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _RatingLine(driver: driver),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AvailabilityLine(available: driver.available),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.palette.divider),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                _PriceSummary(basePrice: driver.basePrice, l10n: l10n),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    VanepSecondaryButton(
                      label: l10n.findVanProfileButton,
                      compact: true,
                      onPressed: openProfile,
                    ),
                    _CompactQuoteButton(
                      label: l10n.findVanRequestQuoteButton,
                      onPressed: onQuoteRequested,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.driver});

  final DriverSearchResult driver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rating = driver.rating;
    if (rating == null) {
      return Text(
        l10n.findVanNewOnVanep,
        style: context.typography.cardSubtitle,
      );
    }

    final formatted = NumberFormat('0.0', l10n.localeName).format(rating);
    final count = driver.ratingCount;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Icon(Icons.star_rounded, size: 16, color: context.palette.warning),
        Text(formatted, style: context.typography.ratingLabel),
        if (count != null && count > 0)
          Text('($count)', style: context.typography.cardSubtitle),
      ],
    );
  }
}

class _AvailabilityLine extends StatelessWidget {
  const _AvailabilityLine({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = available ? context.palette.success : context.palette.danger;
    final label = available
        ? l10n.findVanSpotsAvailable
        : l10n.findVanSpotsFull;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.basePrice, required this.l10n});

  final double? basePrice;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final price = basePrice;
    if (price == null) {
      return Text(
        l10n.findVanPriceOnRequest,
        style: context.typography.cardSubtitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final formatted = formatMoney(l10n, (price * 100).round());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.findVanPriceStartingFrom,
          style: context.typography.cardSubtitle.copyWith(fontSize: 11.5),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatted,
              style: context.typography.cardTitle.copyWith(fontSize: 16),
            ),
            Text(
              l10n.findVanPerMonth,
              style: context.typography.cardSubtitle.copyWith(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactQuoteButton extends StatelessWidget {
  const _CompactQuoteButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.palette.action,
          foregroundColor: context.palette.onAction,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/formatters/van_central_labels.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';

const vanSummaryRadius = 16.0;

final vanSummarySheen = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(vanSummaryRadius)),
  gradient: RadialGradient(
    center: Alignment.topRight,
    radius: 1.2,
    colors: [
      VanepColors.brandSheen.withValues(alpha: 0.26),
      VanepColors.brandSheen.withValues(alpha: 0),
    ],
    stops: const [0, 0.55],
  ),
);

class VanSummaryCard extends StatelessWidget {
  const VanSummaryCard({
    required this.van,
    required this.occupancy,
    required this.withAssistant,
    super.key,
  });

  final DriverVan van;
  final DriverOccupancy? occupancy;
  final bool withAssistant;

  @override
  Widget build(BuildContext context) {
    final occupancy = this.occupancy;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: VanepColors.brandNavy,
        borderRadius: BorderRadius.all(Radius.circular(vanSummaryRadius)),
      ),
      child: DecoratedBox(
        decoration: vanSummarySheen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VanSummaryHeader(van: van, withAssistant: withAssistant),
              const SizedBox(height: 16),
              if (occupancy == null)
                const VanOccupancyUnavailable()
              else
                VanShiftMeters(occupancy: occupancy, capacity: van.capacity),
            ],
          ),
        ),
      ),
    );
  }
}

class VanSummaryHeader extends StatelessWidget {
  const VanSummaryHeader({
    required this.van,
    required this.withAssistant,
    super.key,
  });

  final DriverVan van;
  final bool withAssistant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: VanepColors.onBrand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: VanepColors.onBrand.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.airport_shuttle,
            size: 36,
            color: VanepColors.onBrand.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vanTitleLabel(l10n, van),
                style: VanepTypography.cardTitle.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: VanepColors.onBrand,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vanDetailsLabel(l10n, van, withAssistant: withAssistant),
                style: VanepTypography.cardSubtitle.copyWith(
                  color: VanepColors.onBrand.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 4),
              VanOperationStatus(active: van.active),
            ],
          ),
        ),
      ],
    );
  }
}

class VanOperationStatus extends StatelessWidget {
  const VanOperationStatus({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textColor = active
        ? VanepColors.successOnBrand
        : VanepColors.onBrand.withValues(alpha: 0.6);
    final dotColor = active
        ? VanepColors.successDotOnBrand
        : VanepColors.onBrand.withValues(alpha: 0.4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          active ? l10n.vanCentralInOperation : l10n.vanCentralOutOfOperation,
          style: VanepTypography.ratingLabel.copyWith(color: textColor),
        ),
      ],
    );
  }
}

class VanShiftMeters extends StatelessWidget {
  const VanShiftMeters({
    required this.occupancy,
    required this.capacity,
    super.key,
  });

  final DriverOccupancy occupancy;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final shifts = occupancy.visibleShifts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < shifts.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: VanShiftMeter(occupancy: shifts[index], capacity: capacity),
          ),
        ],
      ],
    );
  }
}

class VanShiftMeter extends StatelessWidget {
  const VanShiftMeter({
    required this.occupancy,
    required this.capacity,
    super.key,
  });

  final ShiftOccupancy occupancy;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shiftName = operationShiftLabel(l10n, occupancy.shift);
    final isFull = occupancy.isFullIn(capacity);
    final textStyle = VanepTypography.ratingLabel.copyWith(
      color: VanepColors.onBrand,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                shiftName,
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              shiftStatusLabel(l10n, occupancy, capacity),
              style: isFull
                  ? textStyle.copyWith(color: VanepColors.brandMeter)
                  : textStyle,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          label: l10n.vanCentralShiftMeterLabel(
            shiftName,
            occupancy.passengers,
            capacity,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: occupancy.fillRatioIn(capacity),
              minHeight: 8,
              color: VanepColors.brandMeter,
              backgroundColor: VanepColors.onBrand.withValues(alpha: 0.16),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.vanCentralShiftSeats(occupancy.passengers, capacity),
          style: VanepTypography.cardSubtitle.copyWith(
            fontSize: 12,
            color: VanepColors.onBrand.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class VanOccupancyUnavailable extends StatelessWidget {
  const VanOccupancyUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.vanCentralOccupancyUnavailable,
      style: VanepTypography.cardSubtitle.copyWith(
        color: VanepColors.onBrand.withValues(alpha: 0.72),
      ),
    );
  }
}

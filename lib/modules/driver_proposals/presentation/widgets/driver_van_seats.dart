import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/formatters/schedule_labels.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/shift_seats.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';

class DriverVanSeatsSection extends StatelessWidget {
  const DriverVanSeatsSection({required this.seats, super.key});

  final List<ShiftSeats> seats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DetailSection(
      title: l10n.driverSeatsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final shift in seats)
            DetailInfoRow(
              label: operationShiftLabel(l10n, shift.shift),
              values: [
                formatShiftOccupancy(l10n, shift),
                formatSeatsAfterAccept(l10n, shift),
              ],
            ),
          const SizedBox(height: 6),
          DetailNotice(text: l10n.driverSeatsTodayNotice),
        ],
      ),
    );
  }
}

class DriverVanVacancies extends StatelessWidget {
  const DriverVanVacancies({required this.seats, super.key});

  final List<ShiftSeats> seats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 26, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final shift in seats)
            Text(
              formatShiftVacancies(l10n, shift),
              style: context.typography.cardSubtitle,
            ),
        ],
      ),
    );
  }
}

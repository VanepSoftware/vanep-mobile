import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

String clientVanStatusLabel(AppLocalizations l10n, String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'ATIVA':
      return l10n.clientVansActiveBadge;
    case 'PENDING':
    case 'PENDENTE':
      return l10n.clientVansPendingBadge;
    default:
      return status;
  }
}

String clientVanVehicleSubtitle(
  AppLocalizations l10n,
  ClientVanVehicle vehicle,
) {
  final parts = <String>[
    if (vehicle.manufactureYear != null) '${vehicle.manufactureYear}',
    if (vehicle.color != null && vehicle.color!.trim().isNotEmpty)
      vehicle.color!.trim(),
    if (vehicle.capacity != null) l10n.clientVansSeats(vehicle.capacity!),
  ];
  return parts.join(' • ');
}

String? clientVanContractPeriod(
  AppLocalizations l10n,
  ClientVanContract contract,
) {
  final startsOn = contract.startsOn;
  final endsOn = contract.endsOn;
  if (startsOn == null || endsOn == null) return null;
  final format = DateFormat('dd/MM/yyyy');
  return '${format.format(startsOn)} até ${format.format(endsOn)}';
}

String clientVanInstallmentText(
  AppLocalizations l10n,
  ClientVanContract contract,
) {
  final parts = <String>[
    if (contract.installmentAmount != null)
      '${formatMoney(l10n, (contract.installmentAmount! * 100).round())}/mês',
    if (contract.dueDay != null) l10n.clientVansDueDay(contract.dueDay!),
  ];
  return parts.join(' • ');
}

String clientVanShiftLabel(AppLocalizations l10n, SchoolShift? shift) {
  if (shift == null) return '';
  final formatted = formatShift(l10n, shift).trim();
  if (formatted.isEmpty) return '';
  return formatted[0].toUpperCase() + formatted.substring(1);
}

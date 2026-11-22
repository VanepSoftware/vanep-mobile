import 'package:intl/intl.dart';

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
    '${vehicle.manufactureYear}',
    vehicle.color,
    l10n.clientVansSeats(vehicle.capacity),
  ];
  return parts.join(' • ');
}

String clientVanContractPeriod(
  AppLocalizations l10n,
  ClientVanContract contract,
) {
  final format = DateFormat('dd/MM/yyyy');
  return '${format.format(contract.startsOn)} até ${format.format(contract.endsOn)}';
}

String clientVanInstallmentText(
  AppLocalizations l10n,
  ClientVanContract contract,
) {
  final cents = (contract.installmentAmount * 100).round();
  final money = formatMoney(l10n, cents);
  return '$money/mês • ${l10n.clientVansDueDay(contract.dueDay)}';
}

String clientVanShiftLabel(AppLocalizations l10n, String raw) {
  final formatted = formatApiSchoolShift(l10n, raw).trim();
  if (formatted.isEmpty) return '';
  return formatted[0].toUpperCase() + formatted.substring(1);
}

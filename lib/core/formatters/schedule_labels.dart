import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/legs_summary.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

String routeLegLabel(AppLocalizations l10n, RouteLeg leg) {
  return switch (leg) {
    RouteLeg.outbound => l10n.negotiationLegOutbound,
    RouteLeg.homebound => l10n.negotiationLegHomebound,
  };
}

String legsSummaryLabel(AppLocalizations l10n, LegsSummary summary) {
  return switch (summary) {
    LegsSummary.roundTrip => l10n.negotiationLegsRoundTrip,
    LegsSummary.outboundOnly => l10n.negotiationLegsOutboundOnly,
    LegsSummary.homeboundOnly => l10n.negotiationLegsHomeboundOnly,
    LegsSummary.mixed => l10n.negotiationLegsMixed,
  };
}

String operationShiftLabel(AppLocalizations l10n, OperationShift shift) {
  return switch (shift) {
    OperationShift.morning => l10n.vanCentralShiftMorning,
    OperationShift.afternoon => l10n.vanCentralShiftAfternoon,
    OperationShift.night => l10n.vanCentralShiftNight,
  };
}

String formatClockTime(ClockTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

String formatRequestChildrenFirstNames(
  AppLocalizations l10n,
  DriverServiceRequest request,
) {
  return joinNames(l10n, [
    for (final item in request.items) item.dependentFirstName,
  ]);
}

String formatClientAndChildren(
  AppLocalizations l10n,
  DriverServiceRequest request,
) {
  return l10n.driverProposalsClientAndChildren(
    request.clientFirstName,
    formatRequestChildrenFirstNames(l10n, request),
  );
}

List<String> formatRequestSchools(
  AppLocalizations l10n,
  DriverServiceRequest request,
) {
  return [
    for (final group in groupItemsBySchool(request.items))
      if (group.schoolName case final school?)
        switch (formatSchoolShift(l10n, group)) {
          final shift? => l10n.clientProposalsSchoolAndShift(school, shift),
          null => school,
        },
  ];
}

List<String> formatPickupNeighborhoods(
  AppLocalizations l10n,
  DriverServiceRequest request,
) {
  return [
    for (final neighborhood in {
      for (final item in request.items) ?item.pickupNeighborhood,
    })
      l10n.negotiationChatPickupIn(neighborhood),
  ];
}

String formatDriverTurnTitle(
  AppLocalizations l10n,
  DriverServiceRequest request,
) {
  final proposal = request.currentProposal;
  return switch (driverTurnOf(request)) {
    DriverTurn.newRequest => l10n.driverProposalsNewRequest,
    DriverTurn.adjustmentRequested => l10n.driverProposalsAdjustmentRequested,
    _ when proposal != null => formatInstallments(
      l10n,
      proposal.installments,
      proposal.installmentAmountCents,
    ),
    _ => '',
  };
}

String? formatDriverTurnDeadline(
  AppLocalizations l10n,
  DriverServiceRequest request,
  DateTime now,
) {
  final proposal = request.currentProposal;
  return switch (driverTurnOf(request)) {
    DriverTurn.newRequest => formatProposalExpiry(l10n, request.expiresAt, now),
    DriverTurn.waitingForFamily when proposal != null => formatProposalExpiry(
      l10n,
      proposal.validUntil,
      now,
    ),
    _ => null,
  };
}

String formatRequestReceived(
  AppLocalizations l10n,
  DriverServiceRequest request,
  DateTime now,
) {
  final daysAgo = calendarDaysBetween(request.createdAt.toLocal(), now);
  return l10n.driverRequestReceived(daysAgo < 0 ? 0 : daysAgo);
}

String formatDriverStudentDetail(
  AppLocalizations l10n,
  DriverRequestItem item,
) {
  return formatStudentDetail(l10n, item, ageInYears: item.dependentAge);
}

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

String formatClockTime(DateTime time, {required String languageCode}) {
  return formatDepartureTime(
    time.hour * minutesPerHour + time.minute,
    languageCode: languageCode,
  );
}

String formatDayAndMonth(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String joinFirstNames(AppLocalizations l10n, List<String> fullNames) {
  final names = fullNames.map(firstNameOf).toList();
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  return l10n.assistantHomeNamesAnd(
    names.sublist(0, names.length - 1).join(', '),
    names.last,
  );
}

List<String> namesGoingAt(AssistantRouteStop stop) => [
  for (final passenger in stop.passengers)
    if (passenger.checklistStatus != ChecklistStatus.absent) passenger.name,
];

String stopPassengersLine(AppLocalizations l10n, AssistantRouteStop stop) {
  final names = joinFirstNames(l10n, namesGoingAt(stop));
  return stop.kind.isBoarding ? names : l10n.assistantHomeDropOffLine(names);
}

const maxNamesInDropOffLine = 2;

String stopRouteLine(AppLocalizations l10n, AssistantRouteStop stop) {
  if (!stop.kind.isBoarding) {
    final names = namesGoingAt(stop);
    return names.length > maxNamesInDropOffLine
        ? l10n.assistantStopsDropOffCount(names.length)
        : l10n.assistantHomeDropOffLine(joinFirstNames(l10n, names));
  }
  final boarding = [
    for (final passenger in stop.passengers)
      if (passenger.checklistStatus != ChecklistStatus.absent &&
          passenger.checklistStatus != ChecklistStatus.skipped)
        passenger.name,
  ];
  return [
    if (boarding.isNotEmpty) joinFirstNames(l10n, boarding),
    for (final passenger in stop.passengers)
      if (passenger.checklistStatus == ChecklistStatus.skipped)
        l10n.assistantStopsNoShow(
          firstNameOf(passenger.name),
          skipReasonText(l10n, passenger),
        )
      else if (passenger.checklistStatus == ChecklistStatus.absent)
        l10n.assistantStopsNotGoing(firstNameOf(passenger.name)),
  ].join(vanSubtitleSeparator);
}

String stopKindTitle(AppLocalizations l10n, RouteStopKind kind) {
  return switch (kind) {
    RouteStopKind.pickupHome => l10n.assistantHomeHomeBoarding,
    RouteStopKind.dropOffSchool => l10n.assistantHomeSchoolArrival,
    RouteStopKind.pickupSchool => l10n.assistantHomeSchoolBoarding,
    RouteStopKind.dropOffHome => l10n.assistantHomeHomeDropOff,
  };
}

String tripLegLabel(AppLocalizations l10n, TripLeg leg) {
  return switch (leg) {
    TripLeg.outbound => l10n.assistantHomeLegOutbound,
    TripLeg.inbound => l10n.assistantHomeLegReturn,
  };
}

String assistantHomeVanLabel(AppLocalizations l10n, AssistantVan van) {
  return l10n.assistantHomeVanLabel(
    firstNameOf(van.driverName),
    van.model,
    van.plate,
  );
}

String noShowReasonLabel(AppLocalizations l10n, NoShowReason reason) {
  return switch (reason) {
    NoShowReason.notAtStop => l10n.assistantNoShowReasonNotAtStop,
    NoShowReason.returnedHome => l10n.assistantNoShowReasonReturnedHome,
    NoShowReason.pickedUpByGuardian =>
      l10n.assistantNoShowReasonPickedUpByGuardian,
    NoShowReason.sick => l10n.assistantNoShowReasonSick,
    NoShowReason.other => l10n.assistantNoShowReasonOther,
  };
}

String skipReasonText(
  AppLocalizations l10n,
  AssistantRoutePassenger passenger,
) => skipReasonLine(l10n, passenger.noShowReason, passenger.skipNotes);

String skipReasonLine(
  AppLocalizations l10n,
  NoShowReason? reason,
  String? notes,
) {
  final chosen = reason ?? NoShowReason.other;
  if (chosen == NoShowReason.other && notes != null && notes.isNotEmpty) {
    return notes;
  }
  return noShowReasonLabel(l10n, chosen).toLowerCase();
}

bool isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String absenceNoticeLine(
  AppLocalizations l10n,
  AssistantAbsence absence, {
  required DateTime now,
  required String languageCode,
}) => noticeLine(
  l10n,
  source: absence.source,
  notifiedAt: absence.notifiedAt,
  now: now,
  languageCode: languageCode,
);

String noticeLine(
  AppLocalizations l10n, {
  required AbsenceSource source,
  required DateTime notifiedAt,
  required DateTime now,
  required String languageCode,
}) {
  if (!isSameDay(notifiedAt, now)) return l10n.assistantHomeNotifiedYesterday;
  final time = formatClockTime(notifiedAt, languageCode: languageCode);
  return source == AbsenceSource.client
      ? l10n.assistantHomeNotifiedByFamily(time)
      : l10n.assistantHomeNotifiedByDriver(time);
}

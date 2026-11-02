import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';

String operationShiftLabel(AppLocalizations l10n, OperationShift shift) {
  return switch (shift) {
    OperationShift.morning => l10n.vanCentralShiftMorning,
    OperationShift.afternoon => l10n.vanCentralShiftAfternoon,
    OperationShift.night => l10n.vanCentralShiftNight,
  };
}

String operationShiftWithArticle(AppLocalizations l10n, OperationShift shift) {
  return switch (shift) {
    OperationShift.morning => l10n.vanCentralShiftArticleMorning,
    OperationShift.afternoon => l10n.vanCentralShiftArticleAfternoon,
    OperationShift.night => l10n.vanCentralShiftArticleNight,
  };
}

String operationShiftWithPreposition(
  AppLocalizations l10n,
  OperationShift shift,
) {
  return switch (shift) {
    OperationShift.morning => l10n.vanCentralShiftPrepositionMorning,
    OperationShift.afternoon => l10n.vanCentralShiftPrepositionAfternoon,
    OperationShift.night => l10n.vanCentralShiftPrepositionNight,
  };
}

String joinWithAnd(AppLocalizations l10n, List<String> parts) {
  if (parts.length <= 1) return parts.join();
  return l10n.vanCentralListJoin(
    parts.sublist(0, parts.length - 1).join(', '),
    parts.last,
  );
}

String vanPillLabel(AppLocalizations l10n, DriverVan van) =>
    l10n.vanCentralVanPill(van.model, van.plate);

String vanTitleLabel(AppLocalizations l10n, DriverVan van) =>
    l10n.vanCentralVanTitle(van.model, van.manufactureYear);

String vanDetailsLabel(
  AppLocalizations l10n,
  DriverVan van, {
  required bool withAssistant,
}) {
  return withAssistant
      ? l10n.vanCentralVanDetailsWithAssistant(van.color, van.capacity)
      : l10n.vanCentralVanDetails(van.color, van.capacity);
}

String shiftStatusLabel(
  AppLocalizations l10n,
  ShiftOccupancy occupancy,
  int capacity,
) {
  return occupancy.isFullIn(capacity)
      ? l10n.vanCentralShiftFull
      : l10n.vanCentralShiftVacancies(occupancy.vacanciesIn(capacity));
}

String studentsSummary(AppLocalizations l10n, DriverOccupancy occupancy) {
  final count = l10n.vanCentralStudentsCount(occupancy.students);
  if (occupancy.students == 0) return count;
  return '$count · ${l10n.vanCentralStudentsWithFamily(occupancy.studentsWithFamily)}';
}

String assistantsSummary(AppLocalizations l10n, List<VanAssistant> team) {
  final parts = [
    for (final assistant in team.working) assistant.name.split(' ').first,
    if (team.pendingCount > 0)
      l10n.vanCentralAssistantsPending(team.pendingCount),
  ];
  return parts.isEmpty ? l10n.vanCentralAssistantsNone : parts.join(' · ');
}

String acceptingStudentsSummary(
  AppLocalizations l10n, {
  required DriverAttendance attendance,
  required DriverOccupancy? occupancy,
  required int? capacity,
}) {
  if (!attendance.acceptingStudents) return l10n.vanCentralNotAccepting;
  if (occupancy == null || capacity == null) return l10n.vanCentralAccepting;
  final open = occupancy.shiftsWithVacanciesIn(capacity);
  if (open.isEmpty) return l10n.vanCentralAcceptingFull;
  if (open.length == 1) {
    return l10n.vanCentralAcceptingOneShift(
      operationShiftWithArticle(l10n, open.single),
    );
  }
  return l10n.vanCentralAcceptingSeveralShifts(
    joinWithAnd(l10n, [
      for (final shift in open) operationShiftWithPreposition(l10n, shift),
    ]),
  );
}

String serviceAreasSummary(AppLocalizations l10n, List<ServiceArea> areas) {
  if (areas.isEmpty) return l10n.vanCentralServiceAreasNone;
  return joinWithAnd(l10n, [
    for (final area in areas) area.coversWholeCity ? area.cityName : area.name,
  ]);
}

String basePriceSummary(AppLocalizations l10n, DriverAttendance attendance) {
  final cents = attendance.basePriceCents;
  if (cents == null || cents == 0) return l10n.vanCentralBasePriceNone;
  return l10n.vanCentralBasePriceValue(formatMoney(l10n, cents));
}

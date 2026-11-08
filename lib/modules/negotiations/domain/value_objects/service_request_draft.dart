import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

const serviceRequestNotesMaxLength = 1000;

enum ServiceRequestDraftError {
  studentRequired,
  studentWithoutLeg,
  startDateRequired,
  startDateInPast,
  notesTooLong,
}

class RequestDraftItem extends Equatable {
  const RequestDraftItem({
    required this.dependentToken,
    this.legsByDay = const {},
  });

  factory RequestDraftItem.withEveryLegOn(
    String dependentToken,
    Iterable<Weekday> schoolDays,
  ) {
    return RequestDraftItem(
      dependentToken: dependentToken,
      legsByDay: {for (final day in schoolDays) day: RouteLeg.values.toSet()},
    );
  }

  final String dependentToken;

  final Map<Weekday, Set<RouteLeg>> legsByDay;

  bool hasLeg(Weekday weekday, RouteLeg leg) {
    return legsByDay[weekday]?.contains(leg) ?? false;
  }

  bool get hasAnyLeg => legsByDay.values.any((legs) => legs.isNotEmpty);

  Map<Weekday, Set<RouteLeg>> get daysToSend => {
    for (final weekday in Weekday.values)
      if (legsByDay[weekday] case final legs? when legs.isNotEmpty)
        weekday: legs,
  };

  RequestDraftItem withLeg(
    Weekday weekday,
    RouteLeg leg, {
    required bool enabled,
  }) {
    final current = legsByDay[weekday];
    if (current == null) return this;
    final legs = {...current};
    enabled ? legs.add(leg) : legs.remove(leg);
    return RequestDraftItem(
      dependentToken: dependentToken,
      legsByDay: {...legsByDay, weekday: legs},
    );
  }

  @override
  List<Object?> get props => [dependentToken, legsByDay];
}

class ServiceRequestDraft extends Equatable {
  const ServiceRequestDraft({
    required this.driverToken,
    this.desiredStartDate,
    this.notes = '',
    this.items = const [],
  });

  final String driverToken;

  final DateTime? desiredStartDate;

  final String notes;

  final List<RequestDraftItem> items;

  String? get notesToSend => trimmedOrNull(notes);

  bool isSelected(String dependentToken) {
    return items.any((item) => item.dependentToken == dependentToken);
  }

  ServiceRequestDraft withStudent(
    String dependentToken,
    Iterable<Weekday> schoolDays,
  ) {
    if (isSelected(dependentToken)) return this;
    return withItems([
      ...items,
      RequestDraftItem.withEveryLegOn(dependentToken, schoolDays),
    ]);
  }

  ServiceRequestDraft withoutStudent(String dependentToken) {
    return withItems([
      for (final item in items)
        if (item.dependentToken != dependentToken) item,
    ]);
  }

  ServiceRequestDraft withLeg(
    String dependentToken,
    Weekday weekday,
    RouteLeg leg, {
    required bool enabled,
  }) {
    return withItems([
      for (final item in items)
        item.dependentToken == dependentToken
            ? item.withLeg(weekday, leg, enabled: enabled)
            : item,
    ]);
  }

  ServiceRequestDraft withItems(List<RequestDraftItem> value) {
    return ServiceRequestDraft(
      driverToken: driverToken,
      desiredStartDate: desiredStartDate,
      notes: notes,
      items: value,
    );
  }

  ServiceRequestDraft withDesiredStartDate(DateTime? value) {
    return ServiceRequestDraft(
      driverToken: driverToken,
      desiredStartDate: value,
      notes: notes,
      items: items,
    );
  }

  ServiceRequestDraft withNotes(String value) {
    return ServiceRequestDraft(
      driverToken: driverToken,
      desiredStartDate: desiredStartDate,
      notes: value,
      items: items,
    );
  }

  @override
  List<Object?> get props => [driverToken, desiredStartDate, notes, items];
}

Set<ServiceRequestDraftError> validateServiceRequestDraft(
  ServiceRequestDraft draft, {
  required DateTime today,
}) {
  final desiredStartDate = draft.desiredStartDate;
  return {
    if (draft.items.isEmpty) ServiceRequestDraftError.studentRequired,
    if (draft.items.any((item) => !item.hasAnyLeg))
      ServiceRequestDraftError.studentWithoutLeg,
    if (desiredStartDate == null)
      ServiceRequestDraftError.startDateRequired
    else if (calendarDaysBetween(today, desiredStartDate) < 0)
      ServiceRequestDraftError.startDateInPast,
    if (isLongerThan(draft.notes, serviceRequestNotesMaxLength))
      ServiceRequestDraftError.notesTooLong,
  };
}

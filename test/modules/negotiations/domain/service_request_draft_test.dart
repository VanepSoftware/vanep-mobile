import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

final today = DateTime(2026, 10, 1);

ServiceRequestDraft draftForBia() {
  return ServiceRequestDraft(
    driverToken: 'driver-carlos',
    desiredStartDate: DateTime(2027, 2, 1),
  ).withStudent('dep-bia', weekdaysMondayToFriday);
}

void main() {
  test('a new student starts with both legs on every school day', () {
    final item = draftForBia().items.single;

    expect(item.dependentToken, 'dep-bia');
    expect(item.legsByDay.keys, weekdaysMondayToFriday);
    expect(item.legsByDay.values, everyElement(RouteLeg.values.toSet()));
  });

  test('a complete draft is valid', () {
    expect(validateServiceRequestDraft(draftForBia(), today: today), isEmpty);
  });

  test('needs at least one student', () {
    final draft = draftForBia().withoutStudent('dep-bia');

    expect(
      validateServiceRequestDraft(draft, today: today),
      contains(ServiceRequestDraftError.studentRequired),
    );
  });

  test('every student needs at least one leg', () {
    var draft = draftForBia().withStudent('dep-davi', [Weekday.monday]);
    for (final leg in RouteLeg.values) {
      draft = draft.withLeg('dep-davi', Weekday.monday, leg, enabled: false);
    }

    expect(validateServiceRequestDraft(draft, today: today), {
      ServiceRequestDraftError.studentWithoutLeg,
    });
  });

  test('Wednesday outbound only is sent as outbound only', () {
    final draft = draftForBia().withLeg(
      'dep-bia',
      Weekday.wednesday,
      RouteLeg.homebound,
      enabled: false,
    );

    expect(draft.items.single.daysToSend[Weekday.wednesday], {
      RouteLeg.outbound,
    });
  });

  test('a day without legs is not sent', () {
    var draft = draftForBia();
    for (final leg in RouteLeg.values) {
      draft = draft.withLeg('dep-bia', Weekday.friday, leg, enabled: false);
    }

    expect(draft.items.single.daysToSend.keys, [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
    ]);
  });

  test('a day without school cannot be turned on', () {
    final draft = draftForBia().withLeg(
      'dep-bia',
      Weekday.saturday,
      RouteLeg.outbound,
      enabled: true,
    );

    expect(draft.items.single.legsByDay.keys, weekdaysMondayToFriday);
  });

  test('the message goes without surrounding spaces, or not at all', () {
    expect(
      draftForBia().withNotes('  Oi, Carlos.  ').notesToSend,
      'Oi, Carlos.',
    );
    expect(draftForBia().withNotes('   ').notesToSend, isNull);
  });

  test('surrounding spaces do not count for the limit', () {
    final draft = draftForBia().withNotes('${'a' * 1000}   ');

    expect(validateServiceRequestDraft(draft, today: today), isEmpty);
  });

  test('adding a student twice keeps the first grid', () {
    final draft = draftForBia()
        .withLeg('dep-bia', Weekday.monday, RouteLeg.outbound, enabled: false)
        .withStudent('dep-bia', weekdaysMondayToFriday);

    expect(draft.items, hasLength(1));
    expect(
      draft.items.single.hasLeg(Weekday.monday, RouteLeg.outbound),
      isFalse,
    );
  });

  test('the start date is required', () {
    final draft = draftForBia().withDesiredStartDate(null);

    expect(validateServiceRequestDraft(draft, today: today), {
      ServiceRequestDraftError.startDateRequired,
    });
  });

  test('today is the earliest start date', () {
    expect(
      validateServiceRequestDraft(
        draftForBia().withDesiredStartDate(today),
        today: today,
      ),
      isEmpty,
    );
    expect(
      validateServiceRequestDraft(
        draftForBia().withDesiredStartDate(DateTime(2026, 9, 30)),
        today: today,
      ),
      {ServiceRequestDraftError.startDateInPast},
    );
  });

  test('the message has up to 1000 characters', () {
    expect(
      validateServiceRequestDraft(
        draftForBia().withNotes('a' * 1000),
        today: today,
      ),
      isEmpty,
    );
    expect(
      validateServiceRequestDraft(
        draftForBia().withNotes('a' * 1001),
        today: today,
      ),
      {ServiceRequestDraftError.notesTooLong},
    );
  });
}

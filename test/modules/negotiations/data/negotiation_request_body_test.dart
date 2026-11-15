import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_request_body.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

import '../negotiations_fixtures.dart';

ProposalDraft proposalForTheo() {
  return ProposalDraft.fromRequest(
        TestDriverServiceRequest(
          items: [
            TestDriverRequestItem(days: roundTripOn([Weekday.monday])),
          ],
        ),
      )
      .withTotalAmount(100000)
      .withInstallments(3)
      .withDueDay(10)
      .withEndsOn(DateTime(2027, 12, 17))
      .withVehicle('van-master')
      .withMessage('  Posso buscar 10 min antes. ')
      .withTimeOnEveryDay(
        'dep-theo',
        RouteLeg.outbound,
        const ClockTime(hour: 12, minute: 5),
      )
      .withTimeOnEveryDay(
        'dep-theo',
        RouteLeg.homebound,
        const ClockTime(hour: 18, minute: 0),
      );
}

void main() {
  test(
    'a request sends the days with their legs, without the school period',
    () {
      final draft =
          ServiceRequestDraft(
                driverToken: 'driver-carlos',
                desiredStartDate: DateTime(2027, 2, 1),
                notes: '  Theo sai às 12h. ',
              )
              .withStudent('dep-theo', [Weekday.wednesday, Weekday.monday])
              .withLeg(
                'dep-theo',
                Weekday.wednesday,
                RouteLeg.homebound,
                enabled: false,
              );

      expect(serviceRequestDraftToJson(draft), {
        'driverToken': 'driver-carlos',
        'desiredStartDate': '2027-02-01',
        'notes': 'Theo sai às 12h.',
        'items': [
          {
            'dependentToken': 'dep-theo',
            'days': [
              {'weekday': 'MONDAY', 'needsOutbound': true, 'needsReturn': true},
              {
                'weekday': 'WEDNESDAY',
                'needsOutbound': true,
                'needsReturn': false,
              },
            ],
          },
        ],
      });
    },
  );

  test('a request without a message leaves it out', () {
    final draft = ServiceRequestDraft(
      driverToken: 'driver-carlos',
      desiredStartDate: DateTime(2027, 2, 1),
    ).withStudent('dep-theo', [Weekday.monday]);

    expect(serviceRequestDraftToJson(draft), isNot(contains('notes')));
  });

  test('a proposal sends amounts with two decimals and times as HH:mm', () {
    expect(proposalDraftToJson(proposalForTheo()), {
      'startsOn': '2027-02-01',
      'endsOn': '2027-12-17',
      'totalAmount': 1000.0,
      'installments': 3,
      'dueDay': 10,
      'adjustmentPolicy': 'IPCA_AT_RENEWAL',
      'cancellationPolicy': 'NOTICE_30_DAYS_WITH_FEE',
      'vehicleToken': 'van-master',
      'validDays': 7,
      'message': 'Posso buscar 10 min antes.',
      'items': [
        {
          'dependentToken': 'dep-theo',
          'slots': [
            {
              'weekday': 'MONDAY',
              'leg': 'OUTBOUND',
              'shift': 'AFTERNOON',
              'pickupTime': '12:05',
            },
            {
              'weekday': 'MONDAY',
              'leg': 'RETURN',
              'shift': 'AFTERNOON',
              'pickupTime': '18:00',
            },
          ],
        },
      ],
    });
  });

  test('a proposal with an enrollment fee sends it', () {
    final body = proposalDraftToJson(
      proposalForTheo().withEnrollmentFee(15000),
    );

    expect(body['enrollmentFee'], 150.0);
  });

  test('an adjustment sends the subject and only the texts filled in', () {
    const draft = ProposalAdjustmentDraft(
      field: ProposalAdjustmentField.schedule,
      suggestedValue: ' ',
      note: ' Pode buscar 10 min antes? ',
    );

    expect(proposalAdjustmentDraftToJson(draft), {
      'field': 'SCHEDULE',
      'note': 'Pode buscar 10 min antes?',
    });
  });

  test('a decline sends the reason only when there is one', () {
    expect(declineToJson(' Sem vaga à tarde. '), {
      'reason': 'Sem vaga à tarde.',
    });
    expect(declineToJson('  '), isEmpty);
    expect(declineToJson(null), isEmpty);
  });
}

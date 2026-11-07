import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/proposal_dto.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/service_request_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiation_json_fixtures.dart';

void main() {
  group('the client view of a request', () {
    test('reads the request with the conversation and its dates', () {
      final request = ClientServiceRequestDto.fromJson(
        clientServiceRequestJson(),
      );

      expect(request.token, 'request-1');
      expect(request.conversationToken, 'conversation-1');
      expect(request.status, ServiceRequestStatus.answered);
      expect(request.driverName, 'Carlos Souza');
      expect(request.driverRating, 4.8);
      expect(request.desiredStartDate, DateTime(2027, 2, 1));
      expect(request.expiresAt, DateTime.utc(2026, 10, 4, 12));
      expect(request.updatedAt, DateTime.utc(2026, 10, 2, 9, 30));
      expect(request.notes, 'Theo sai às 12h.');
    });

    test('reads every student with the requested days and legs', () {
      final item = ClientServiceRequestDto.fromJson(clientServiceRequestJson())
          .items
          .single;

      expect(item.dependentName, 'Theo Souza');
      expect(item.dependentBirthDate, '2017-03-22');
      expect(item.pickupNeighborhood, 'Taguatinga');
      expect(item.days.last.weekday, Weekday.wednesday);
      expect(item.days.last.schoolShift, SchoolShift.afternoon);
      expect(item.days.last.needsOutbound, isTrue);
      expect(item.days.last.needsReturn, isFalse);
    });

    test('reads the current proposal in cents', () {
      final summary = ClientServiceRequestDto.fromJson(
        clientServiceRequestJson(
          currentProposal: proposalSummaryJson(hasPendingAdjustment: true),
        ),
      ).currentProposal!;

      expect(summary.version, 2);
      expect(summary.status, ProposalStatus.sent);
      expect(summary.totalAmountCents, 360000);
      expect(summary.installmentAmountCents, 30000);
      expect(summary.lastInstallmentAmountCents, 30000);
      expect(summary.startsOn, DateTime(2027, 2, 15));
      expect(summary.validUntil, DateTime.utc(2026, 10, 9, 12));
      expect(summary.hasPendingAdjustment, isTrue);
    });

    test('a request without a proposal or a rating reads them as absent', () {
      final request = ClientServiceRequestDto.fromJson(
        clientServiceRequestJson(status: 'OPEN', driverRating: null),
      );

      expect(request.currentProposal, isNull);
      expect(request.driverRating, isNull);
    });

    test('an unknown status is not read', () {
      expect(
        () => ClientServiceRequestDto.fromJson(
          clientServiceRequestJson(status: 'ARCHIVED'),
        ),
        throwsFormatException,
      );
    });
  });

  test('the driver view reads the first name and age only', () {
    final request = DriverServiceRequestDto.fromJson(
      driverServiceRequestJson(),
    );

    expect(request.clientFirstName, 'Maria');
    expect(request.status, ServiceRequestStatus.open);
    expect(request.items.single.dependentFirstName, 'Theo');
    expect(request.items.single.dependentAge, 9);
    expect(request.notes, isNull);
  });

  group('a proposal', () {
    test('reads the terms in cents and the conditions', () {
      final proposal = ProposalDto.fromJson(proposalJson());

      expect(proposal.version, 2);
      expect(proposal.status, ProposalStatus.sent);
      expect(proposal.totalAmountCents, 100000);
      expect(proposal.installmentAmountCents, 33333);
      expect(proposal.lastInstallmentAmountCents, 33334);
      expect(proposal.enrollmentFeeCents, 15000);
      expect(proposal.dueDay, 10);
      expect(proposal.startsOn, DateTime(2027, 2, 15));
      expect(proposal.endsOn, DateTime(2027, 12, 17));
      expect(proposal.adjustmentPolicy, ProposalAdjustmentPolicy.ipcaAtRenewal);
      expect(
        proposal.cancellationPolicy,
        ProposalCancellationPolicy.notice30DaysWithFee,
      );
      expect(proposal.acceptedAt, isNull);
    });

    test('reads the slots with their time', () {
      final slots = ProposalDto.fromJson(proposalJson()).items.single.slots;

      expect(slots.first.leg, RouteLeg.outbound);
      expect(slots.first.shift, OperationShift.afternoon);
      expect(slots.first.pickupTime, const ClockTime(hour: 12, minute: 5));
      expect(slots.last.leg, RouteLeg.homebound);
      expect(slots.last.pickupTime, const ClockTime(hour: 18, minute: 0));
    });

    test('reads the van and the adjustments', () {
      final proposal = ProposalDto.fromJson(proposalJson());

      expect(proposal.vehicle?.token, 'van-master');
      expect(proposal.vehicle?.model, 'Master');
      expect(proposal.vehicle?.capacity, 15);
      expect(proposal.adjustments.single.field, ProposalAdjustmentField.price);
      expect(proposal.adjustments.single.suggestedValue, 'R\$ 290');
      expect(
        proposal.adjustments.single.createdAt,
        DateTime.utc(2026, 10, 2, 15),
      );
    });

    test(
      'the driver view has no full name, and the client view no van token',
      () {
        final forDriver = ProposalDto.fromJson(
          proposalJson(dependentName: null),
        );
        final forClient = ProposalDto.fromJson(
          proposalJson(vehicleToken: null),
        );

        expect(forDriver.items.single.dependentName, isNull);
        expect(forDriver.items.single.dependentFirstName, 'Theo');
        expect(forClient.vehicle?.token, isNull);
      },
    );

    test('a proposal missing a required number is unreadable', () {
      expect(
        () => ProposalDto.fromJson({...proposalJson(), 'version': null}),
        throwsFormatException,
      );
      expect(
        () => ProposalDto.fromJson({...proposalJson(), 'totalAmount': null}),
        throwsFormatException,
      );
    });

    test('a proposal without an enrollment fee reads it as absent', () {
      final proposal = ProposalDto.fromJson(proposalJson(enrollmentFee: null));

      expect(proposal.enrollmentFeeCents, isNull);
    });
  });

  group('a missing token is unreadable', () {
    final cases = <String, void Function()>{
      'request token of the client view': () =>
          ClientServiceRequestDto.fromJson(
            withoutField(clientServiceRequestJson(), 'token'),
          ),
      'link token of the client view': () => ClientServiceRequestDto.fromJson(
        withoutField(clientServiceRequestJson(), 'clientDriverToken'),
      ),
      'driver token of the client view': () => ClientServiceRequestDto.fromJson(
        withoutField(clientServiceRequestJson(), 'driverToken'),
      ),
      'student token of the client view': () =>
          ClientServiceRequestDto.fromJson(
            withoutItemField(clientServiceRequestJson(), 'dependentToken'),
          ),
      'request token of the driver view': () =>
          DriverServiceRequestDto.fromJson(
            withoutField(driverServiceRequestJson(), 'token'),
          ),
      'link token of the driver view': () => DriverServiceRequestDto.fromJson(
        withoutField(driverServiceRequestJson(), 'clientDriverToken'),
      ),
      'student token of the driver view': () =>
          DriverServiceRequestDto.fromJson(
            withoutItemField(driverServiceRequestJson(), 'dependentToken'),
          ),
      'token of the current proposal': () => ClientServiceRequestDto.fromJson(
        clientServiceRequestJson(
          currentProposal: withoutField(proposalSummaryJson(), 'token'),
        ),
      ),
      'proposal token': () =>
          ProposalDto.fromJson(withoutField(proposalJson(), 'token')),
      'request token of the proposal': () => ProposalDto.fromJson(
        withoutField(proposalJson(), 'serviceRequestToken'),
      ),
      'link token of the proposal': () => ProposalDto.fromJson(
        withoutField(proposalJson(), 'clientDriverToken'),
      ),
      'student token of the proposal': () => ProposalDto.fromJson(
        withoutItemField(proposalJson(), 'dependentToken'),
      ),
    };

    for (final MapEntry(key: description, value: read) in cases.entries) {
      test(description, () => expect(read, throwsFormatException));
    }

    test('an empty token is as unreadable as a missing one', () {
      expect(
        () => ProposalDto.fromJson({...proposalJson(), 'token': ''}),
        throwsFormatException,
      );
    });

    test('the conversation and the van token may be absent', () {
      final request = ClientServiceRequestDto.fromJson(
        withoutField(clientServiceRequestJson(), 'conversationToken'),
      );
      final proposal = ProposalDto.fromJson(proposalJson(vehicleToken: null));

      expect(request.conversationToken, isNull);
      expect(proposal.vehicle?.token, isNull);
    });
  });
}

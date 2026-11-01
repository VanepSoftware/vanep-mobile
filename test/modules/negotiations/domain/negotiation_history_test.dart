import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiations_fixtures.dart';

final versionOneSentAt = DateTime.utc(2026, 10, 2, 9);
final adjustmentAt = DateTime.utc(2026, 10, 2, 15);
final versionTwoSentAt = DateTime.utc(2026, 10, 3, 10);

TestProposal versionOne({ProposalStatus status = ProposalStatus.superseded}) {
  return TestProposal(
    status: status,
    createdAt: versionOneSentAt,
    adjustments: [TestProposalAdjustment(createdAt: adjustmentAt)],
  );
}

TestProposal versionTwo({
  ProposalStatus status = ProposalStatus.sent,
  DateTime? acceptedAt,
  DateTime? updatedAt,
}) {
  return TestProposal(
    token: 'proposal-v2',
    version: 2,
    status: status,
    installmentAmountCents: 30000,
    createdAt: versionTwoSentAt,
    acceptedAt: acceptedAt,
    updatedAt: updatedAt,
  );
}

void main() {
  test('a request without proposals has only the request', () {
    final history = buildNegotiationHistory(TestDriverServiceRequest(), []);

    expect(history, [RequestSentEvent(at: requestCreatedAt)]);
  });

  test('lists the request, versions and adjustments by date', () {
    final history = buildNegotiationHistory(
      TestDriverServiceRequest(status: ServiceRequestStatus.answered),
      [versionTwo(), versionOne()],
    );

    expect(history, [
      RequestSentEvent(at: requestCreatedAt),
      ProposalSentEvent(
        at: versionOneSentAt,
        proposalToken: 'proposal-v1',
        version: 1,
        isOpen: false,
      ),
      AdjustmentRequestedEvent(
        at: adjustmentAt,
        field: ProposalAdjustmentField.price,
        suggestedValue: 'R\$ 290',
      ),
      ProposalSentEvent(
        at: versionTwoSentAt,
        proposalToken: 'proposal-v2',
        version: 2,
        isOpen: true,
      ),
    ]);
  });

  test('an adjustment without a value keeps its subject', () {
    final history = buildNegotiationHistory(TestDriverServiceRequest(), [
      TestProposal(
        createdAt: versionOneSentAt,
        adjustments: [
          TestProposalAdjustment(
            createdAt: adjustmentAt,
            field: ProposalAdjustmentField.schedule,
            suggestedValue: null,
            note: 'Pode buscar 10 min antes?',
          ),
        ],
      ),
    ]);

    expect(
      history.last,
      AdjustmentRequestedEvent(
        at: adjustmentAt,
        field: ProposalAdjustmentField.schedule,
        note: 'Pode buscar 10 min antes?',
      ),
    );
  });

  test('ends with the acceptance', () {
    final acceptedAt = DateTime.utc(2026, 10, 4, 8);

    final history = buildNegotiationHistory(
      TestDriverServiceRequest(status: ServiceRequestStatus.converted),
      [
        versionOne(),
        versionTwo(status: ProposalStatus.accepted, acceptedAt: acceptedAt),
      ],
    );

    expect(history.last, ProposalAcceptedEvent(at: acceptedAt, version: 2));
  });

  test('ends with the family declining the proposal', () {
    final declinedAt = DateTime.utc(2026, 10, 4, 8);

    final history = buildNegotiationHistory(
      TestDriverServiceRequest(status: ServiceRequestStatus.withdrawn),
      [versionTwo(status: ProposalStatus.declined, updatedAt: declinedAt)],
    );

    expect(history.last, ProposalDeclinedEvent(at: declinedAt, version: 2));
  });

  test('ends with the driver declining the request', () {
    final declinedAt = DateTime.utc(2026, 10, 2, 8);

    final history = buildNegotiationHistory(
      TestDriverServiceRequest(
        status: ServiceRequestStatus.declined,
        updatedAt: declinedAt,
      ),
      [],
    );

    expect(history.last, RequestDeclinedEvent(at: declinedAt));
  });

  test('events at the same moment keep the negotiation order', () {
    final history = buildNegotiationHistory(
      TestDriverServiceRequest(createdAt: versionOneSentAt),
      [TestProposal(createdAt: versionOneSentAt)],
    );

    expect(history.first, isA<RequestSentEvent>());
    expect(history.last, isA<ProposalSentEvent>());
  });
}

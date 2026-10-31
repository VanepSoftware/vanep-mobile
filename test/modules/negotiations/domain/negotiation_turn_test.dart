import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiations_fixtures.dart';

TestDriverServiceRequest requestWith(
  ServiceRequestStatus status, {
  bool? hasPendingAdjustment,
}) {
  return TestDriverServiceRequest(
    status: status,
    currentProposal: hasPendingAdjustment == null
        ? null
        : TestProposalSummary(hasPendingAdjustment: hasPendingAdjustment),
  );
}

void main() {
  test('an open request waits for the driver, who has a new request', () {
    final request = requestWith(ServiceRequestStatus.open);

    expect(clientTurnOf(request), ClientTurn.requestSent);
    expect(driverTurnOf(request), DriverTurn.newRequest);
  });

  test('an answered proposal is the family turn', () {
    final request = requestWith(
      ServiceRequestStatus.answered,
      hasPendingAdjustment: false,
    );

    expect(clientTurnOf(request), ClientTurn.proposalReceived);
    expect(driverTurnOf(request), DriverTurn.waitingForFamily);
  });

  test('a requested adjustment is the driver turn', () {
    final request = requestWith(
      ServiceRequestStatus.answered,
      hasPendingAdjustment: true,
    );

    expect(clientTurnOf(request), ClientTurn.adjustmentRequested);
    expect(driverTurnOf(request), DriverTurn.adjustmentRequested);
  });

  test('a converted request is closed as accepted', () {
    final request = requestWith(ServiceRequestStatus.converted);

    expect(clientTurnOf(request), ClientTurn.accepted);
    expect(driverTurnOf(request), DriverTurn.closed);
  });

  test('a declined request is closed by the driver', () {
    final request = requestWith(ServiceRequestStatus.declined);

    expect(clientTurnOf(request), ClientTurn.declinedByDriver);
    expect(driverTurnOf(request), DriverTurn.closed);
  });

  test('a withdrawn request is closed by the family', () {
    final request = requestWith(ServiceRequestStatus.withdrawn);

    expect(clientTurnOf(request), ClientTurn.closedByClient);
    expect(driverTurnOf(request), DriverTurn.closed);
  });

  test('an expired request is closed as expired', () {
    final request = requestWith(ServiceRequestStatus.expired);

    expect(clientTurnOf(request), ClientTurn.expired);
    expect(driverTurnOf(request), DriverTurn.closed);
  });

  test('an expired proposal reopens the request for the driver', () {
    final request = requestWith(ServiceRequestStatus.open);

    expect(request.currentProposal, isNull);
    expect(clientTurnOf(request), ClientTurn.requestSent);
    expect(clientTurnOf(request).isClosed, isFalse);
  });

  test('only the proposal received is the family turn', () {
    final clientTurns = ClientTurn.values.where((turn) => turn.isClientsTurn);
    final waiting = ClientTurn.values.where((turn) => turn.isWaitingForDriver);

    expect(clientTurns, [ClientTurn.proposalReceived]);
    expect(waiting, [ClientTurn.requestSent, ClientTurn.adjustmentRequested]);
  });

  test('the driver answers new requests and adjustments', () {
    final driverTurns = DriverTurn.values.where((turn) => turn.isDriversTurn);

    expect(driverTurns, [
      DriverTurn.newRequest,
      DriverTurn.adjustmentRequested,
    ]);
  });
}

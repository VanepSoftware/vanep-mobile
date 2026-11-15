import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

enum ClientTurn {
  requestSent,
  proposalReceived,
  adjustmentRequested,
  accepted,
  declinedByDriver,
  closedByClient,
  expired;

  bool get isClientsTurn => this == proposalReceived;

  bool get isWaitingForDriver =>
      this == requestSent || this == adjustmentRequested;

  bool get isClosed => !isClientsTurn && !isWaitingForDriver;
}

enum DriverTurn {
  newRequest,
  adjustmentRequested,
  waitingForFamily,
  closed;

  bool get isDriversTurn => this == newRequest || this == adjustmentRequested;
}

bool isAdjustmentPending(ServiceRequest request) {
  return request.currentProposal?.hasPendingAdjustment ?? false;
}

ClientTurn clientTurnOf(ServiceRequest request) {
  return switch (request.status) {
    ServiceRequestStatus.open => ClientTurn.requestSent,
    ServiceRequestStatus.answered when isAdjustmentPending(request) =>
      ClientTurn.adjustmentRequested,
    ServiceRequestStatus.answered => ClientTurn.proposalReceived,
    ServiceRequestStatus.converted => ClientTurn.accepted,
    ServiceRequestStatus.declined => ClientTurn.declinedByDriver,
    ServiceRequestStatus.withdrawn => ClientTurn.closedByClient,
    ServiceRequestStatus.expired => ClientTurn.expired,
  };
}

DriverTurn driverTurnOf(ServiceRequest request) {
  return switch (request.status) {
    ServiceRequestStatus.open => DriverTurn.newRequest,
    ServiceRequestStatus.answered when isAdjustmentPending(request) =>
      DriverTurn.adjustmentRequested,
    ServiceRequestStatus.answered => DriverTurn.waitingForFamily,
    ServiceRequestStatus.converted ||
    ServiceRequestStatus.declined ||
    ServiceRequestStatus.withdrawn ||
    ServiceRequestStatus.expired => DriverTurn.closed,
  };
}

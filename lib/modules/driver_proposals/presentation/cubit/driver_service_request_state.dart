import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/shift_seats.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

enum DriverServiceRequestStatus {
  initial,
  loading,
  ready,
  loadFailed,
  notFound,
}

class DriverServiceRequestState extends Equatable {
  const DriverServiceRequestState({
    this.status = DriverServiceRequestStatus.initial,
    this.request,
    this.actionFailure,
    this.seats = const [],
  });

  final DriverServiceRequestStatus status;

  final DriverServiceRequest? request;

  final NegotiationFailure? actionFailure;

  final List<ShiftSeats> seats;

  bool get isReady =>
      status == DriverServiceRequestStatus.ready && request != null;

  bool get canAnswer => request?.status == ServiceRequestStatus.open;

  @override
  List<Object?> get props => [status, request, actionFailure, seats];
}

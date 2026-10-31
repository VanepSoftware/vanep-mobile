import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

abstract class ServiceRequest {
  String get token;

  String get clientDriverToken;

  String? get conversationToken;

  ServiceRequestStatus get status;

  DateTime get desiredStartDate;

  String? get notes;

  String? get declineReason;

  DateTime get expiresAt;

  ProposalSummary? get currentProposal;

  List<RequestItem> get items;

  DateTime get createdAt;

  DateTime get updatedAt;
}

abstract class RequestItem {
  String get dependentToken;

  String? get schoolName;

  String? get pickupCityName;

  String? get pickupStateUf;

  String? get pickupNeighborhood;

  List<RequestedDay> get days;
}

abstract class RequestedDay {
  Weekday get weekday;

  SchoolShift? get schoolShift;

  bool get needsOutbound;

  bool get needsReturn;
}

abstract class ClientServiceRequest implements ServiceRequest {
  String get driverToken;

  String get driverName;

  double? get driverRating;

  @override
  List<ClientRequestItem> get items;
}

abstract class ClientRequestItem implements RequestItem {
  String get dependentName;

  String? get dependentBirthDate;
}

abstract class DriverServiceRequest implements ServiceRequest {
  String get clientFirstName;

  @override
  List<DriverRequestItem> get items;
}

abstract class DriverRequestItem implements RequestItem {
  String get dependentFirstName;

  int? get dependentAge;
}

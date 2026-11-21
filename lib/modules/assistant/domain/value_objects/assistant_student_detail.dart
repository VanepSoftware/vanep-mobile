import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/weekday.dart';

class AssistantStudentSibling extends Equatable {
  const AssistantStudentSibling({
    required this.token,
    required this.name,
    required this.relationship,
    required this.schoolName,
  });

  final String token;
  final String name;
  final String relationship;
  final String schoolName;

  @override
  List<Object?> get props => [token, name, relationship, schoolName];
}

class AssistantStudentGuardian extends Equatable {
  const AssistantStudentGuardian({
    required this.name,
    required this.relationship,
    this.phone,
  });

  final String name;
  final String relationship;
  final String? phone;

  @override
  List<Object?> get props => [name, relationship, phone];
}

class AssistantStudentDetail extends Equatable {
  const AssistantStudentDetail({
    required this.token,
    required this.name,
    required this.schoolName,
    required this.pickupAddress,
    this.shift,
    this.pickupWindowStart,
    this.pickupWindowEnd,
    this.returnDepartureAt,
    this.returnAddress,
    this.outboundDays = const {},
    this.inboundDays = const {},
    this.siblings = const [],
    this.guardian,
    this.canSeeGuardianContact = false,
    this.hasFamilyInApp = true,
    this.driverNote,
  });

  final String token;
  final String name;
  final String schoolName;
  final String pickupAddress;
  final String? shift;
  final DateTime? pickupWindowStart;
  final DateTime? pickupWindowEnd;
  final DateTime? returnDepartureAt;
  final String? returnAddress;
  final Set<Weekday> outboundDays;
  final Set<Weekday> inboundDays;
  final List<AssistantStudentSibling> siblings;
  final AssistantStudentGuardian? guardian;
  final bool canSeeGuardianContact;
  final bool hasFamilyInApp;
  final String? driverNote;

  bool get returnsToPickupAddress =>
      returnAddress == null || returnAddress == pickupAddress;

  AssistantStudentGuardian? get visibleGuardian =>
      canSeeGuardianContact && hasFamilyInApp ? guardian : null;

  @override
  List<Object?> get props => [
    token,
    name,
    schoolName,
    pickupAddress,
    shift,
    pickupWindowStart,
    pickupWindowEnd,
    returnDepartureAt,
    returnAddress,
    outboundDays,
    inboundDays,
    siblings,
    guardian,
    canSeeGuardianContact,
    hasFamilyInApp,
    driverNote,
  ];
}

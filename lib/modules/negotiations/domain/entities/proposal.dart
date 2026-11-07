import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

abstract class Proposal {
  String get token;

  String get serviceRequestToken;

  String get clientDriverToken;

  int get version;

  ProposalStatus get status;

  DateTime get validUntil;

  DateTime get startsOn;

  DateTime get endsOn;

  int get totalAmountCents;

  int get installments;

  int get installmentAmountCents;

  int get lastInstallmentAmountCents;

  int get dueDay;

  int? get enrollmentFeeCents;

  ProposalAdjustmentPolicy get adjustmentPolicy;

  ProposalCancellationPolicy get cancellationPolicy;

  ProposalVehicle? get vehicle;

  String? get message;

  String? get declineReason;

  DateTime? get acceptedAt;

  List<ProposalItem> get items;

  List<ProposalAdjustment> get adjustments;

  DateTime get createdAt;

  DateTime get updatedAt;
}

abstract class ProposalItem {
  String get dependentToken;

  String? get dependentName;

  String get dependentFirstName;

  List<ScheduleSlot> get slots;
}

abstract class ScheduleSlot {
  Weekday get weekday;

  RouteLeg get leg;

  OperationShift get shift;

  ClockTime get pickupTime;
}

abstract class ProposalVehicle {
  String? get token;

  String get plate;

  String get brand;

  String get model;

  int get manufactureYear;

  String get color;

  int get capacity;
}

abstract class ProposalAdjustment {
  ProposalAdjustmentField get field;

  String? get suggestedValue;

  String? get note;

  DateTime get createdAt;
}

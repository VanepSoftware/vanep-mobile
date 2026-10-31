import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

final requestCreatedAt = DateTime.utc(2026, 10, 1, 12);

const weekdaysMondayToFriday = [
  Weekday.monday,
  Weekday.tuesday,
  Weekday.wednesday,
  Weekday.thursday,
  Weekday.friday,
];

class TestRequestedDay implements RequestedDay {
  const TestRequestedDay({
    required this.weekday,
    this.schoolShift = SchoolShift.afternoon,
    this.needsOutbound = true,
    this.needsReturn = true,
  });

  @override
  final Weekday weekday;

  @override
  final SchoolShift? schoolShift;

  @override
  final bool needsOutbound;

  @override
  final bool needsReturn;
}

List<TestRequestedDay> roundTripOn(List<Weekday> weekdays) => [
  for (final weekday in weekdays) TestRequestedDay(weekday: weekday),
];

class TestDriverRequestItem implements DriverRequestItem {
  TestDriverRequestItem({
    this.dependentToken = 'dep-theo',
    this.dependentFirstName = 'Theo',
    this.dependentAge = 9,
    this.schoolName = 'Colégio Delta',
    this.pickupCityName = 'Brasília',
    this.pickupStateUf = 'DF',
    this.pickupNeighborhood = 'Taguatinga',
    List<RequestedDay>? days,
  }) : days = days ?? roundTripOn(weekdaysMondayToFriday);

  @override
  final String dependentToken;

  @override
  final String dependentFirstName;

  @override
  final int? dependentAge;

  @override
  final String? schoolName;

  @override
  final String? pickupCityName;

  @override
  final String? pickupStateUf;

  @override
  final String? pickupNeighborhood;

  @override
  final List<RequestedDay> days;
}

class TestProposalSummary implements ProposalSummary {
  TestProposalSummary({
    this.token = 'proposal-v1',
    this.version = 1,
    this.status = ProposalStatus.sent,
    this.totalAmountCents = 408000,
    this.installments = 12,
    this.installmentAmountCents = 34000,
    this.lastInstallmentCents,
    DateTime? validUntil,
    DateTime? startsOn,
    this.hasPendingAdjustment = false,
  }) : validUntil = validUntil ?? DateTime.utc(2026, 10, 9),
       startsOn = startsOn ?? DateTime(2027, 2, 1);

  @override
  final String token;

  @override
  final int version;

  @override
  final ProposalStatus status;

  @override
  final int totalAmountCents;

  @override
  final int installments;

  @override
  final int installmentAmountCents;

  final int? lastInstallmentCents;

  @override
  int get lastInstallmentAmountCents =>
      lastInstallmentCents ?? installmentAmountCents;

  @override
  final DateTime validUntil;

  @override
  final DateTime startsOn;

  @override
  final bool hasPendingAdjustment;
}

class TestDriverServiceRequest implements DriverServiceRequest {
  TestDriverServiceRequest({
    this.token = 'request-1',
    this.clientDriverToken = 'link-1',
    this.conversationToken = 'conversation-1',
    this.status = ServiceRequestStatus.open,
    DateTime? desiredStartDate,
    this.notes,
    this.declineReason,
    DateTime? expiresAt,
    this.currentProposal,
    this.clientFirstName = 'Maria',
    List<DriverRequestItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : desiredStartDate = desiredStartDate ?? DateTime(2027, 2, 1),
       expiresAt = expiresAt ?? DateTime.utc(2026, 10, 4, 12),
       items = items ?? [TestDriverRequestItem()],
       createdAt = createdAt ?? requestCreatedAt,
       updatedAt = updatedAt ?? requestCreatedAt;

  @override
  final String token;

  @override
  final String clientDriverToken;

  @override
  final String? conversationToken;

  @override
  final ServiceRequestStatus status;

  @override
  final DateTime desiredStartDate;

  @override
  final String? notes;

  @override
  final String? declineReason;

  @override
  final DateTime expiresAt;

  @override
  final ProposalSummary? currentProposal;

  @override
  final String clientFirstName;

  @override
  final List<DriverRequestItem> items;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;
}

class TestScheduleSlot implements ScheduleSlot {
  const TestScheduleSlot({
    required this.weekday,
    required this.leg,
    this.shift = OperationShift.afternoon,
    this.pickupTime = const ClockTime(hour: 12, minute: 5),
  });

  @override
  final Weekday weekday;

  @override
  final RouteLeg leg;

  @override
  final OperationShift shift;

  @override
  final ClockTime pickupTime;
}

List<TestScheduleSlot> roundTripSlotsOn(List<Weekday> weekdays) => [
  for (final weekday in weekdays) ...[
    TestScheduleSlot(weekday: weekday, leg: RouteLeg.outbound),
    TestScheduleSlot(
      weekday: weekday,
      leg: RouteLeg.homebound,
      pickupTime: const ClockTime(hour: 18, minute: 0),
    ),
  ],
];

class TestProposalItem implements ProposalItem {
  TestProposalItem({
    this.dependentToken = 'dep-theo',
    this.dependentName,
    this.dependentFirstName = 'Theo',
    List<ScheduleSlot>? slots,
  }) : slots = slots ?? roundTripSlotsOn(weekdaysMondayToFriday);

  @override
  final String dependentToken;

  @override
  final String? dependentName;

  @override
  final String dependentFirstName;

  @override
  final List<ScheduleSlot> slots;
}

class TestProposalVehicle implements ProposalVehicle {
  const TestProposalVehicle({
    this.token = 'van-master',
    this.plate = 'JKL1A23',
    this.brand = 'Renault',
    this.model = 'Master',
    this.manufactureYear = 2019,
    this.color = 'Branca',
    this.capacity = 15,
  });

  @override
  final String? token;

  @override
  final String plate;

  @override
  final String brand;

  @override
  final String model;

  @override
  final int manufactureYear;

  @override
  final String color;

  @override
  final int capacity;
}

class TestProposalAdjustment implements ProposalAdjustment {
  const TestProposalAdjustment({
    required this.createdAt,
    this.field = ProposalAdjustmentField.price,
    this.suggestedValue = 'R\$ 290',
    this.note,
  });

  @override
  final ProposalAdjustmentField field;

  @override
  final String? suggestedValue;

  @override
  final String? note;

  @override
  final DateTime createdAt;
}

class TestProposal implements Proposal {
  TestProposal({
    this.token = 'proposal-v1',
    this.serviceRequestToken = 'request-1',
    this.clientDriverToken = 'link-1',
    this.version = 1,
    this.status = ProposalStatus.sent,
    DateTime? validUntil,
    DateTime? startsOn,
    DateTime? endsOn,
    this.totalAmountCents = 408000,
    this.installments = 12,
    this.installmentAmountCents = 34000,
    this.lastInstallmentCents,
    this.dueDay = 10,
    this.enrollmentFeeCents,
    this.adjustmentPolicy = ProposalAdjustmentPolicy.ipcaAtRenewal,
    this.cancellationPolicy = ProposalCancellationPolicy.notice30DaysWithFee,
    this.vehicle = const TestProposalVehicle(),
    this.message,
    this.declineReason,
    this.acceptedAt,
    List<ProposalItem>? items,
    this.adjustments = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : validUntil = validUntil ?? DateTime.utc(2026, 10, 9),
       startsOn = startsOn ?? DateTime(2027, 2, 1),
       endsOn = endsOn ?? DateTime(2027, 12, 17),
       items = items ?? [TestProposalItem()],
       createdAt = createdAt ?? DateTime.utc(2026, 10, 2, 9),
       updatedAt = updatedAt ?? createdAt ?? DateTime.utc(2026, 10, 2, 9);

  @override
  final String token;

  @override
  final String serviceRequestToken;

  @override
  final String clientDriverToken;

  @override
  final int version;

  @override
  final ProposalStatus status;

  @override
  final DateTime validUntil;

  @override
  final DateTime startsOn;

  @override
  final DateTime endsOn;

  @override
  final int totalAmountCents;

  @override
  final int installments;

  @override
  final int installmentAmountCents;

  final int? lastInstallmentCents;

  @override
  int get lastInstallmentAmountCents =>
      lastInstallmentCents ?? installmentAmountCents;

  @override
  final int dueDay;

  @override
  final int? enrollmentFeeCents;

  @override
  final ProposalAdjustmentPolicy adjustmentPolicy;

  @override
  final ProposalCancellationPolicy cancellationPolicy;

  @override
  final ProposalVehicle? vehicle;

  @override
  final String? message;

  @override
  final String? declineReason;

  @override
  final DateTime? acceptedAt;

  @override
  final List<ProposalItem> items;

  @override
  final List<ProposalAdjustment> adjustments;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;
}

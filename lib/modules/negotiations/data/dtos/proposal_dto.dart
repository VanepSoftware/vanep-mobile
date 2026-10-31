import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_json.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

part 'proposal_dto.freezed.dart';
part 'proposal_dto.g.dart';

@Freezed(toJson: false)
abstract class ScheduleSlotDto with _$ScheduleSlotDto implements ScheduleSlot {
  const factory ScheduleSlotDto({
    @JsonKey(fromJson: readWeekday) required Weekday weekday,
    @JsonKey(fromJson: readRouteLeg) required RouteLeg leg,
    @JsonKey(fromJson: readOperationShift) required OperationShift shift,
    @JsonKey(fromJson: readClockTime) required ClockTime pickupTime,
  }) = _ScheduleSlotDto;

  factory ScheduleSlotDto.fromJson(Map<String, Object?> json) =>
      _$ScheduleSlotDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ProposalItemDto with _$ProposalItemDto implements ProposalItem {
  const factory ProposalItemDto({
    @JsonKey(fromJson: readToken) required String dependentToken,
    String? dependentName,
    @Default('') String dependentFirstName,
    @Default([]) List<ScheduleSlotDto> slots,
  }) = _ProposalItemDto;

  factory ProposalItemDto.fromJson(Map<String, Object?> json) =>
      _$ProposalItemDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ProposalVehicleDto
    with _$ProposalVehicleDto
    implements ProposalVehicle {
  const factory ProposalVehicleDto({
    String? token,
    @Default('') String plate,
    @Default('') String brand,
    @Default('') String model,
    @Default(0) int manufactureYear,
    @Default('') String color,
    @Default(0) int capacity,
  }) = _ProposalVehicleDto;

  factory ProposalVehicleDto.fromJson(Map<String, Object?> json) =>
      _$ProposalVehicleDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ProposalAdjustmentDto
    with _$ProposalAdjustmentDto
    implements ProposalAdjustment {
  const factory ProposalAdjustmentDto({
    @JsonKey(fromJson: readAdjustmentField)
    required ProposalAdjustmentField field,
    String? suggestedValue,
    String? note,
    @JsonKey(fromJson: readInstant) required DateTime createdAt,
  }) = _ProposalAdjustmentDto;

  factory ProposalAdjustmentDto.fromJson(Map<String, Object?> json) =>
      _$ProposalAdjustmentDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ProposalDto with _$ProposalDto implements Proposal {
  const factory ProposalDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readToken) required String serviceRequestToken,
    @JsonKey(fromJson: readToken) required String clientDriverToken,
    @JsonKey(fromJson: readInt) required int version,
    @JsonKey(fromJson: readProposalStatus) required ProposalStatus status,
    @JsonKey(fromJson: readInstant) required DateTime validUntil,
    @JsonKey(fromJson: readCalendarDate) required DateTime startsOn,
    @JsonKey(fromJson: readCalendarDate) required DateTime endsOn,
    @JsonKey(name: 'totalAmount', fromJson: readCents)
    required int totalAmountCents,
    @JsonKey(fromJson: readInt) required int installments,
    @JsonKey(name: 'installmentAmount', fromJson: readCents)
    required int installmentAmountCents,
    @JsonKey(name: 'lastInstallmentAmount', fromJson: readCents)
    required int lastInstallmentAmountCents,
    @JsonKey(fromJson: readInt) required int dueDay,
    @JsonKey(name: 'enrollmentFee', fromJson: readOptionalCents)
    int? enrollmentFeeCents,
    @JsonKey(fromJson: readAdjustmentPolicy)
    required ProposalAdjustmentPolicy adjustmentPolicy,
    @JsonKey(fromJson: readCancellationPolicy)
    required ProposalCancellationPolicy cancellationPolicy,
    ProposalVehicleDto? vehicle,
    String? message,
    String? declineReason,
    @JsonKey(fromJson: readOptionalInstant) DateTime? acceptedAt,
    @Default([]) List<ProposalItemDto> items,
    @Default([]) List<ProposalAdjustmentDto> adjustments,
    @JsonKey(fromJson: readInstant) required DateTime createdAt,
    @JsonKey(fromJson: readInstant) required DateTime updatedAt,
  }) = _ProposalDto;

  factory ProposalDto.fromJson(Map<String, Object?> json) =>
      _$ProposalDtoFromJson(json);
}

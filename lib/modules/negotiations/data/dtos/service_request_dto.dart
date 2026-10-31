import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/negotiation_json.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/proposal_summary_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

part 'service_request_dto.freezed.dart';
part 'service_request_dto.g.dart';

@Freezed(toJson: false)
abstract class RequestedDayDto with _$RequestedDayDto implements RequestedDay {
  const factory RequestedDayDto({
    @JsonKey(fromJson: readWeekday) required Weekday weekday,
    @JsonKey(fromJson: SchoolShift.fromApi) SchoolShift? schoolShift,
    @Default(false) bool needsOutbound,
    @Default(false) bool needsReturn,
  }) = _RequestedDayDto;

  factory RequestedDayDto.fromJson(Map<String, Object?> json) =>
      _$RequestedDayDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ClientRequestItemDto
    with _$ClientRequestItemDto
    implements ClientRequestItem {
  const factory ClientRequestItemDto({
    @JsonKey(fromJson: readToken) required String dependentToken,
    @Default('') String dependentName,
    String? dependentBirthDate,
    String? schoolName,
    String? pickupCityName,
    String? pickupStateUf,
    String? pickupNeighborhood,
    @Default([]) List<RequestedDayDto> days,
  }) = _ClientRequestItemDto;

  factory ClientRequestItemDto.fromJson(Map<String, Object?> json) =>
      _$ClientRequestItemDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class DriverRequestItemDto
    with _$DriverRequestItemDto
    implements DriverRequestItem {
  const factory DriverRequestItemDto({
    @JsonKey(fromJson: readToken) required String dependentToken,
    @Default('') String dependentFirstName,
    int? dependentAge,
    String? schoolName,
    String? pickupCityName,
    String? pickupStateUf,
    String? pickupNeighborhood,
    @Default([]) List<RequestedDayDto> days,
  }) = _DriverRequestItemDto;

  factory DriverRequestItemDto.fromJson(Map<String, Object?> json) =>
      _$DriverRequestItemDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class ClientServiceRequestDto
    with _$ClientServiceRequestDto
    implements ClientServiceRequest {
  const factory ClientServiceRequestDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readToken) required String clientDriverToken,
    String? conversationToken,
    @JsonKey(fromJson: readToken) required String driverToken,
    @Default('') String driverName,
    double? driverRating,
    @JsonKey(fromJson: readServiceRequestStatus)
    required ServiceRequestStatus status,
    @JsonKey(fromJson: readCalendarDate) required DateTime desiredStartDate,
    String? notes,
    String? declineReason,
    @JsonKey(fromJson: readInstant) required DateTime expiresAt,
    ProposalSummaryDto? currentProposal,
    @Default([]) List<ClientRequestItemDto> items,
    @JsonKey(fromJson: readInstant) required DateTime createdAt,
    @JsonKey(fromJson: readInstant) required DateTime updatedAt,
  }) = _ClientServiceRequestDto;

  factory ClientServiceRequestDto.fromJson(Map<String, Object?> json) =>
      _$ClientServiceRequestDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class DriverServiceRequestDto
    with _$DriverServiceRequestDto
    implements DriverServiceRequest {
  const factory DriverServiceRequestDto({
    @JsonKey(fromJson: readToken) required String token,
    @JsonKey(fromJson: readToken) required String clientDriverToken,
    String? conversationToken,
    @Default('') String clientFirstName,
    @JsonKey(fromJson: readServiceRequestStatus)
    required ServiceRequestStatus status,
    @JsonKey(fromJson: readCalendarDate) required DateTime desiredStartDate,
    String? notes,
    String? declineReason,
    @JsonKey(fromJson: readInstant) required DateTime expiresAt,
    ProposalSummaryDto? currentProposal,
    @Default([]) List<DriverRequestItemDto> items,
    @JsonKey(fromJson: readInstant) required DateTime createdAt,
    @JsonKey(fromJson: readInstant) required DateTime updatedAt,
  }) = _DriverServiceRequestDto;

  factory DriverServiceRequestDto.fromJson(Map<String, Object?> json) =>
      _$DriverServiceRequestDtoFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auth/data/dtos/user_profile_dto.dart';
import '../../domain/entities/pending_invite.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/value_objects/assistant_status.dart';
import '../../domain/value_objects/driver_approval_status.dart';

part 'profile_summary_dto.freezed.dart';
part 'profile_summary_dto.g.dart';

@freezed
abstract class PendingInviteDriverDto
    with _$PendingInviteDriverDto
    implements PendingInviteDriver {
  const factory PendingInviteDriverDto({
    String? name,
    @JsonKey(name: 'photo') String? photoUrl,
    String? city,
    double? rating,
  }) = _PendingInviteDriverDto;

  factory PendingInviteDriverDto.fromJson(Map<String, Object?> json) =>
      _$PendingInviteDriverDtoFromJson(json);
}

@freezed
abstract class PendingInviteDto
    with _$PendingInviteDto
    implements PendingInvite {
  const factory PendingInviteDto({
    required String token,
    String? expiresAt,
    PendingInviteDriverDto? driver,
  }) = _PendingInviteDto;

  factory PendingInviteDto.fromJson(Map<String, Object?> json) =>
      _$PendingInviteDtoFromJson(json);
}

@freezed
abstract class ClientProfileSummaryDto
    with _$ClientProfileSummaryDto
    implements ClientProfileSummary {
  const factory ClientProfileSummaryDto({
    required String token,
    @JsonKey(name: 'photo') String? photoUrl,
    double? rating,
    bool? active,
    UserProfileDto? user,
  }) = _ClientProfileSummaryDto;

  factory ClientProfileSummaryDto.fromJson(Map<String, Object?> json) =>
      _$ClientProfileSummaryDtoFromJson(json);
}

@freezed
abstract class DriverProfileSummaryDto
    with _$DriverProfileSummaryDto
    implements DriverProfileSummary {
  const factory DriverProfileSummaryDto({
    required String token,
    @JsonKey(name: 'photo') String? photoUrl,
    double? rating,
    String? city,
    @JsonKey(
      fromJson: DriverApprovalStatus.fromApi,
      toJson: DriverApprovalStatus.toApi,
    )
    DriverApprovalStatus? approvalStatus,
    bool? available,
    bool? active,
    UserProfileDto? user,
  }) = _DriverProfileSummaryDto;

  factory DriverProfileSummaryDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileSummaryDtoFromJson(json);
}

@freezed
abstract class AssistantProfileSummaryDto
    with _$AssistantProfileSummaryDto
    implements AssistantProfileSummary {
  const factory AssistantProfileSummaryDto({
    required String token,
    @JsonKey(name: 'photo') String? photoUrl,
    @JsonKey(fromJson: AssistantStatus.fromApi, toJson: AssistantStatus.toApi)
    AssistantStatus? status,
    PendingInviteDto? pendingInvite,
    UserProfileDto? user,
  }) = _AssistantProfileSummaryDto;

  factory AssistantProfileSummaryDto.fromJson(Map<String, Object?> json) =>
      _$AssistantProfileSummaryDtoFromJson(json);
}

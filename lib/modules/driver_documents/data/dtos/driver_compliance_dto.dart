import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/document_json_readers.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

part 'driver_compliance_dto.freezed.dart';
part 'driver_compliance_dto.g.dart';

@Freezed(toJson: false)
abstract class DriverComplianceDto
    with _$DriverComplianceDto
    implements DriverCompliance {
  const factory DriverComplianceDto({
    @JsonKey(fromJson: readCalendarDate) required DateTime asOf,
    @JsonKey(fromJson: readRequirementStatuses)
    required List<RequirementStatusDto> driverRequirements,
    @Default([]) List<VehicleComplianceDto> vehicles,
  }) = _DriverComplianceDto;

  factory DriverComplianceDto.fromJson(Map<String, Object?> json) =>
      _$DriverComplianceDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class VehicleComplianceDto
    with _$VehicleComplianceDto
    implements VehicleCompliance {
  const factory VehicleComplianceDto({
    @JsonKey(fromJson: readToken) required String token,
    required String plate,
    required String brand,
    required String model,
    required bool qualified,
    @JsonKey(fromJson: readRequirementStatuses)
    required List<RequirementStatusDto> requirements,
  }) = _VehicleComplianceDto;

  factory VehicleComplianceDto.fromJson(Map<String, Object?> json) =>
      _$VehicleComplianceDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class RequirementStatusDto
    with _$RequirementStatusDto
    implements RequirementStatus {
  const factory RequirementStatusDto({
    @JsonKey(name: 'requirement', fromJson: readRequirementType)
    required DocumentType type,
    required bool optional,
    required bool satisfied,
    @JsonKey(fromJson: readComplianceState) required ComplianceState state,
    bool? expiringSoon,
    DocumentSubmissionDto? current,
    DocumentSubmissionDto? pending,
  }) = _RequirementStatusDto;

  factory RequirementStatusDto.fromJson(Map<String, Object?> json) =>
      _$RequirementStatusDtoFromJson(json);
}

@Freezed(toJson: false)
abstract class DocumentSubmissionDto
    with _$DocumentSubmissionDto
    implements DocumentSubmission {
  const factory DocumentSubmissionDto({
    @JsonKey(fromJson: readDocumentKind) required DocumentKind kind,
    @JsonKey(fromJson: readToken) required String token,
    String? documentNumber,
    @JsonKey(fromJson: readOptionalCalendarDate) DateTime? expiresAt,
    @JsonKey(fromJson: readSubmissionStatus) required SubmissionStatus status,
    @JsonKey(fromJson: readOptionalRejectionReason)
    RejectionReason? rejectionReasonCode,
    String? rejectionReason,
    @JsonKey(fromJson: readOptionalInstant) DateTime? reviewedAt,
    @JsonKey(fromJson: readInstant) required DateTime createdAt,
    @Default(0) int version,
    String? fileUrl,
    @JsonKey(fromJson: readOptionalDocumentFile) DocumentFile? file,
    @JsonKey(name: 'category') String? cnhCategory,
    @JsonKey(name: 'issueDate', fromJson: readOptionalCalendarDate)
    DateTime? cnhIssueDate,
  }) = _DocumentSubmissionDto;

  factory DocumentSubmissionDto.fromJson(Map<String, Object?> json) =>
      _$DocumentSubmissionDtoFromJson(json);
}

List<RequirementStatusDto> readRequirementStatuses(Object? raw) => [
  for (final entry in readKnownRequirements(raw))
    RequirementStatusDto.fromJson(entry),
];

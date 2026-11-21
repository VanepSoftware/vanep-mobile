import 'package:vanep_mobile/modules/driver_documents/domain/entities/document_submission.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/driver_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/requirement_status.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/entities/vehicle_compliance.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

final testAsOf = DateTime(2026, 11, 20);

class TestSubmission implements DocumentSubmission {
  TestSubmission({
    this.status = SubmissionStatus.approved,
    this.hasFile = true,
    this.expiresAt,
    this.token = 'submission-1',
    this.kind = DocumentKind.driverDocument,
    this.documentNumber,
    this.rejectionReasonCode,
    this.rejectionReason,
    this.cnhCategory,
    this.cnhIssueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(2026, 10, 1);

  final bool hasFile;

  @override
  final DocumentKind kind;
  @override
  final String token;
  @override
  final String? documentNumber;
  @override
  final DateTime? expiresAt;
  @override
  final SubmissionStatus status;
  @override
  final RejectionReason? rejectionReasonCode;
  @override
  final String? rejectionReason;
  @override
  DateTime? get reviewedAt => null;
  @override
  final DateTime createdAt;
  @override
  int get version => 0;
  @override
  String? get fileUrl => hasFile ? '/api/driver-documents/$token/file' : null;
  @override
  DocumentFile? get file => hasFile
      ? const DocumentFile(mimeType: 'application/pdf', sizeBytes: 1200)
      : null;
  @override
  final String? cnhCategory;
  @override
  final DateTime? cnhIssueDate;
}

class TestRequirement implements RequirementStatus {
  TestRequirement({
    required this.type,
    required this.state,
    this.current,
    this.pending,
    this.optional = false,
    this.satisfied = false,
    this.expiringSoon,
  });

  @override
  final DocumentType type;
  @override
  final ComplianceState state;
  @override
  final DocumentSubmission? current;
  @override
  final DocumentSubmission? pending;
  @override
  final bool optional;
  @override
  final bool satisfied;
  @override
  final bool? expiringSoon;
}

class TestVehicle implements VehicleCompliance {
  TestVehicle({
    required this.token,
    required this.plate,
    required this.model,
    required this.requirements,
    this.brand = 'Mercedes-Benz',
    this.qualified = false,
  });

  @override
  final String token;
  @override
  final String plate;
  @override
  final String brand;
  @override
  final String model;
  @override
  final bool qualified;
  @override
  final List<RequirementStatus> requirements;
}

class TestCompliance implements DriverCompliance {
  TestCompliance({
    this.driverRequirements = const [],
    this.vehicles = const [],
    DateTime? asOf,
  }) : asOf = asOf ?? testAsOf;

  @override
  final DateTime asOf;
  @override
  final List<RequirementStatus> driverRequirements;
  @override
  final List<VehicleCompliance> vehicles;
}

TestRequirement missing(DocumentType type, {bool optional = false}) =>
    TestRequirement(
      type: type,
      state: ComplianceState.missing,
      optional: optional,
    );

TestRequirement approved(DocumentType type, {DateTime? expiresAt}) =>
    TestRequirement(
      type: type,
      state: ComplianceState.approved,
      satisfied: true,
      current: TestSubmission(expiresAt: expiresAt),
    );

TestRequirement underReview(DocumentType type) => TestRequirement(
  type: type,
  state: ComplianceState.pending,
  current: TestSubmission(status: SubmissionStatus.pending),
);

TestRequirement rejected(DocumentType type) => TestRequirement(
  type: type,
  state: ComplianceState.rejected,
  current: TestSubmission(
    status: SubmissionStatus.rejected,
    rejectionReasonCode: RejectionReason.dataMismatch,
  ),
);

TestRequirement expired(DocumentType type) => TestRequirement(
  type: type,
  state: ComplianceState.expired,
  current: TestSubmission(expiresAt: DateTime(2026, 11, 19)),
);

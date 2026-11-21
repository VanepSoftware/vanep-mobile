import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/data/dtos/driver_compliance_dto.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

import 'driver_documents_json_fixture.dart';

void main() {
  final compliance = DriverComplianceDto.fromJson(complianceJson);

  test('reads the date of the back and the requirements in order', () {
    expect(compliance.asOf, DateTime(2026, 11, 20));
    expect(compliance.driverRequirements.map((entry) => entry.type), [
      DocumentType.driverLicense,
      DocumentType.criminalRecord,
      DocumentType.municipalAuthorization,
    ]);
  });

  test('reads an approved CNH with its file, category and issue date', () {
    final cnh = compliance.driverRequirements.first;
    final submission = cnh.current!;

    expect(cnh.state, ComplianceState.approved);
    expect(cnh.satisfied, isTrue);
    expect(cnh.expiringSoon, isFalse);
    expect(submission.kind, DocumentKind.driverCnh);
    expect(submission.status, SubmissionStatus.approved);
    expect(submission.expiresAt, DateTime(2031, 8, 12));
    expect(submission.cnhCategory, 'AD');
    expect(submission.cnhIssueDate, DateTime(2021, 8, 12));
    expect(submission.version, 3);
    expect(submission.fileUrl, '/api/driver-cnhs/cnh-1/file?v=abc');
    expect(
      submission.file,
      const DocumentFile(
        mimeType: 'application/pdf',
        sizeBytes: 1400000,
        originalName: 'cnh.pdf',
      ),
    );
    expect(submission.createdAt, DateTime.utc(2026, 10, 13, 10));
  });

  test('a pending submission without a file has no file', () {
    final submission = compliance.driverRequirements[1].current!;

    expect(submission.fileUrl, isNull);
    expect(submission.file, isNull);
    expect(submission.documentNumber, 'CERT-2026-1');
  });

  test('an optional requirement with nothing sent', () {
    final optional = compliance.driverRequirements.last;

    expect(optional.optional, isTrue);
    expect(optional.current, isNull);
    expect(optional.pending, isNull);
  });

  test('reads each van with its rejected document and reason', () {
    final van = compliance.vehicles.single;
    final inspection = van.requirements.single.current!;

    expect(van.token, 'sprinter');
    expect(van.plate, 'SDF4E21');
    expect(van.model, 'Sprinter');
    expect(van.qualified, isFalse);
    expect(inspection.kind, DocumentKind.vehicleDocument);
    expect(inspection.rejectionReasonCode, RejectionReason.illegible);
    expect(inspection.rejectionReason, 'Foto tremida');
    expect(inspection.file?.originalName, isNull);
  });

  test('an unknown requirement of a newer back is skipped', () {
    final newer = DriverComplianceDto.fromJson({
      ...complianceJson,
      'driverRequirements': [
        ...complianceJson['driverRequirements']! as List,
        {
          'requirement': 'FIRST_AID_COURSE',
          'optional': false,
          'satisfied': false,
          'state': 'MISSING',
          'expiringSoon': false,
          'current': null,
          'pending': null,
        },
      ],
    });

    expect(newer.driverRequirements, hasLength(3));
  });
}

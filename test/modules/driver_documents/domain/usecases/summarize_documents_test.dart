import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/summarize_documents.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

import '../../driver_documents_fixture.dart';

void main() {
  test(
    'counts missing, incomplete, rejected and expired, but not the optional',
    () {
      final summary = summarizeDocuments([
        missing(DocumentType.schoolDriverCourse),
        missing(DocumentType.municipalAuthorization, optional: true),
        rejected(DocumentType.criminalRecord),
        expired(DocumentType.vehicleInspection),
        TestRequirement(
          type: DocumentType.driverLicense,
          state: ComplianceState.pending,
          current: TestSubmission(
            status: SubmissionStatus.pending,
            hasFile: false,
          ),
        ),
        underReview(DocumentType.vehicleRegistration),
      ], testAsOf);

      expect(summary.pendingCount, 4);
      expect(summary.needsAttention, isTrue);
    },
  );

  test(
    'without pending documents, tells the nearest expiry within 30 days',
    () {
      final summary = summarizeDocuments([
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 12, 10),
        ),
        approved(
          DocumentType.vehicleRegistration,
          expiresAt: DateTime(2026, 11, 29),
        ),
        approved(
          DocumentType.schoolVehicleAuthorization,
          expiresAt: DateTime(2027, 6, 1),
        ),
      ], testAsOf);

      expect(summary.pendingCount, 0);
      expect(summary.nearestExpiryDays, 9);
      expect(summary.needsAttention, isTrue);
    },
  );

  test('everything approved and far from expiring needs nothing', () {
    final summary = summarizeDocuments([
      approved(DocumentType.vehicleInspection, expiresAt: DateTime(2027, 5, 1)),
      missing(DocumentType.municipalAuthorization, optional: true),
    ], testAsOf);

    expect(summary.pendingCount, 0);
    expect(summary.nearestExpiryDays, isNull);
    expect(summary.needsAttention, isFalse);
  });
}

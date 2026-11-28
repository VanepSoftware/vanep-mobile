import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/summarize_documents.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

import '../../driver_documents_fixture.dart';

void main() {
  test('counts missing, rejected and expired, but not the optional', () {
    final summary = summarizeDocuments([
      missing(DocumentType.schoolDriverCourse),
      missing(DocumentType.municipalAuthorization, optional: true),
      rejected(DocumentType.criminalRecord),
      expired(DocumentType.vehicleInspection),
      underReview(DocumentType.driverLicense),
    ], testAsOf);

    expect(summary.pendingCount, 3);
  });

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
    },
  );

  test('an optional document never counts as pending', () {
    final summary = summarizeDocuments([
      TestRequirement(
        type: DocumentType.municipalAuthorization,
        state: ComplianceState.rejected,
        optional: true,
      ),
      TestRequirement(
        type: DocumentType.criminalRecord,
        state: ComplianceState.expired,
        optional: true,
      ),
    ], testAsOf);

    expect(summary.pendingCount, 0);
    expect(summary.nearestExpiryDays, isNull);
  });

  test('everything approved and far from expiring needs nothing', () {
    final summary = summarizeDocuments([
      approved(DocumentType.vehicleInspection, expiresAt: DateTime(2027, 5, 1)),
      missing(DocumentType.municipalAuthorization, optional: true),
    ], testAsOf);

    expect(summary.pendingCount, 0);
    expect(summary.nearestExpiryDays, isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/resolve_document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

import '../../driver_documents_fixture.dart';

DocumentDisplayState resolve(TestRequirement requirement) =>
    resolveDocumentDisplayState(requirement, testAsOf);

void main() {
  test('nothing sent is "not sent", and keeps the optional flag', () {
    expect(
      resolve(missing(DocumentType.criminalRecord)),
      const DocumentNotSent(isOptional: false),
    );
    expect(
      resolve(missing(DocumentType.municipalAuthorization, optional: true)),
      const DocumentNotSent(isOptional: true),
    );
  });

  test(
    'a pending submission without a file is incomplete, not under review',
    () {
      final requirement = TestRequirement(
        type: DocumentType.criminalRecord,
        state: ComplianceState.pending,
        current: TestSubmission(
          status: SubmissionStatus.pending,
          hasFile: false,
        ),
      );

      expect(resolve(requirement), const DocumentIncomplete());
    },
  );

  test('a renewal without a file is incomplete even with an approved one', () {
    final requirement = TestRequirement(
      type: DocumentType.driverLicense,
      state: ComplianceState.approved,
      satisfied: true,
      current: TestSubmission(expiresAt: DateTime(2027, 1, 1)),
      pending: TestSubmission(status: SubmissionStatus.pending, hasFile: false),
    );

    expect(resolve(requirement), const DocumentIncomplete());
  });

  test('rejected and expired follow the state of the back', () {
    expect(
      resolve(rejected(DocumentType.criminalRecord)),
      const DocumentRejected(),
    );
    expect(
      resolve(expired(DocumentType.vehicleInspection)),
      const DocumentExpired(),
    );
  });

  test('only a pending submission with a file is under review', () {
    expect(
      resolve(underReview(DocumentType.schoolDriverCourse)),
      const DocumentUnderReview(),
    );
  });

  test(
    'an approved one with a renewal on review is a renewal under review',
    () {
      final requirement = TestRequirement(
        type: DocumentType.driverLicense,
        state: ComplianceState.approved,
        satisfied: true,
        current: TestSubmission(expiresAt: DateTime(2026, 12, 10)),
        pending: TestSubmission(status: SubmissionStatus.pending),
      );

      expect(resolve(requirement), const DocumentRenewalUnderReview());
    },
  );

  test('approved and due within 30 days of the back date is expiring', () {
    expect(
      resolve(
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 11, 29),
        ),
      ),
      const DocumentExpiringSoon(daysLeft: 9),
    );
    expect(
      resolve(
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 12, 20),
        ),
      ),
      const DocumentExpiringSoon(daysLeft: 30),
    );
  });

  test('due today and tomorrow keep their day count', () {
    expect(
      resolve(approved(DocumentType.vehicleRegistration, expiresAt: testAsOf)),
      const DocumentExpiringSoon(daysLeft: 0),
    );
    expect(
      resolve(
        approved(
          DocumentType.vehicleRegistration,
          expiresAt: DateTime(2026, 11, 21),
        ),
      ),
      const DocumentExpiringSoon(daysLeft: 1),
    );
  });

  test('approved and due after 30 days, or with no expiry, is approved', () {
    expect(
      resolve(
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 12, 21),
        ),
      ),
      const DocumentApproved(),
    );
    expect(
      resolve(approved(DocumentType.criminalRecord)),
      const DocumentApproved(),
    );
  });

  test('the expiring flag of the back wins over the app window', () {
    final notFlagged = TestRequirement(
      type: DocumentType.vehicleInspection,
      state: ComplianceState.approved,
      satisfied: true,
      current: TestSubmission(expiresAt: DateTime(2026, 11, 29)),
      expiringSoon: false,
    );
    final flagged = TestRequirement(
      type: DocumentType.vehicleInspection,
      state: ComplianceState.approved,
      satisfied: true,
      current: TestSubmission(expiresAt: DateTime(2027, 2, 1)),
      expiringSoon: true,
    );

    expect(resolve(notFlagged), const DocumentApproved());
    expect(resolve(flagged), const DocumentExpiringSoon(daysLeft: 73));
  });

  test('the days are counted from the date of the back, not the device', () {
    final requirement = approved(
      DocumentType.vehicleInspection,
      expiresAt: DateTime(2026, 11, 29),
    );

    expect(
      resolveDocumentDisplayState(requirement, DateTime(2026, 11, 25)),
      const DocumentExpiringSoon(daysLeft: 4),
    );
  });
}

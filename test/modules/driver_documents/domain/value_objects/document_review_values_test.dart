import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_file.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/rejection_reason.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

void main() {
  test('reads the compliance states of the back', () {
    expect(ComplianceState.fromApi('MISSING'), ComplianceState.missing);
    expect(ComplianceState.fromApi('PENDING'), ComplianceState.pending);
    expect(ComplianceState.fromApi('APPROVED'), ComplianceState.approved);
    expect(ComplianceState.fromApi('REJECTED'), ComplianceState.rejected);
    expect(ComplianceState.fromApi('EXPIRED'), ComplianceState.expired);
    expect(ComplianceState.fromApi('UNKNOWN'), isNull);
  });

  test('reads the submission statuses of the back', () {
    expect(SubmissionStatus.fromApi('PENDING'), SubmissionStatus.pending);
    expect(SubmissionStatus.fromApi('APPROVED'), SubmissionStatus.approved);
    expect(SubmissionStatus.fromApi('REJECTED'), SubmissionStatus.rejected);
    expect(SubmissionStatus.fromApi(null), isNull);
  });

  test('reads the rejection reasons of the back', () {
    expect(RejectionReason.fromApi('ILLEGIBLE'), RejectionReason.illegible);
    expect(RejectionReason.fromApi('EXPIRED'), RejectionReason.expired);
    expect(
      RejectionReason.fromApi('DATA_MISMATCH'),
      RejectionReason.dataMismatch,
    );
    expect(RejectionReason.fromApi('WRONG_TYPE'), RejectionReason.wrongType);
    expect(RejectionReason.fromApi('INCOMPLETE'), RejectionReason.incomplete);
    expect(RejectionReason.fromApi('OTHER'), RejectionReason.other);
    expect(RejectionReason.fromApi('LATE'), isNull);
  });

  test('a document file compares by value and knows when it is a PDF', () {
    const pdf = DocumentFile(
      mimeType: 'application/pdf',
      sizeBytes: 1200,
      originalName: 'cnh.pdf',
    );

    expect(
      pdf,
      const DocumentFile(
        mimeType: 'application/pdf',
        sizeBytes: 1200,
        originalName: 'cnh.pdf',
      ),
    );
    expect(pdf.isPdf, isTrue);
    expect(
      const DocumentFile(mimeType: 'image/jpeg', sizeBytes: 1).isPdf,
      isFalse,
    );
  });
}

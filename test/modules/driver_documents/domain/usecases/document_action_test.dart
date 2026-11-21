import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_action.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/submission_status.dart';

import '../../driver_documents_fixture.dart';

void main() {
  test('each state offers its action, and the waiting ones offer none', () {
    expect(
      documentActionFor(const DocumentNotSent(isOptional: false)),
      DocumentAction.send,
    );
    expect(
      documentActionFor(const DocumentIncomplete()),
      DocumentAction.finish,
    );
    expect(documentActionFor(const DocumentRejected()), DocumentAction.resend);
    expect(documentActionFor(const DocumentExpired()), DocumentAction.sendNew);
    expect(
      documentActionFor(const DocumentExpiringSoon(daysLeft: 9)),
      DocumentAction.sendNew,
    );
    expect(
      documentActionFor(const DocumentApproved()),
      DocumentAction.sendUpdated,
    );
    expect(documentActionFor(const DocumentUnderReview()), isNull);
    expect(documentActionFor(const DocumentRenewalUnderReview()), isNull);
  });

  test('the incomplete submission is the pending one without a file', () {
    final withoutFile = TestSubmission(
      token: 'doc-2',
      status: SubmissionStatus.pending,
      hasFile: false,
    );
    final requirement = TestRequirement(
      type: DocumentType.driverLicense,
      state: ComplianceState.approved,
      current: TestSubmission(token: 'doc-1'),
      pending: withoutFile,
    );

    expect(incompleteSubmissionOf(requirement), same(withoutFile));
    expect(
      incompleteSubmissionOf(approved(DocumentType.driverLicense)),
      isNull,
    );
  });

  test('finds a personal requirement and a van requirement', () {
    final sprinter = TestVehicle(
      token: 'sprinter',
      plate: 'SDF4E21',
      model: 'Sprinter',
      requirements: [missing(DocumentType.vehicleInspection)],
    );
    final compliance = TestCompliance(
      driverRequirements: [rejected(DocumentType.criminalRecord)],
      vehicles: [sprinter],
    );

    expect(
      findRequirement(compliance, DocumentType.criminalRecord)?.state,
      ComplianceState.rejected,
    );
    expect(
      findRequirement(
        compliance,
        DocumentType.vehicleInspection,
        vehicleToken: 'sprinter',
      )?.state,
      ComplianceState.missing,
    );
    expect(findVehicle(compliance, 'sprinter'), same(sprinter));
    expect(
      findRequirement(
        compliance,
        DocumentType.vehicleInspection,
        vehicleToken: 'gone',
      ),
      isNull,
    );
  });
}

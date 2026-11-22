import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/usecases/document_groups.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/compliance_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_display_state.dart';
import 'package:vanep_mobile/modules/driver_documents/domain/value_objects/document_type.dart';

import '../../driver_documents_fixture.dart';

void main() {
  test('pending documents come first, each group in the order of the spec', () {
    final groups = groupDocuments([
      approved(DocumentType.schoolDriverCourse),
      missing(DocumentType.municipalAuthorization, optional: true),
      approved(DocumentType.driverLicense),
      rejected(DocumentType.criminalRecord),
    ], testAsOf);

    expect(groups.pending.map((entry) => entry.requirement.type), [
      DocumentType.criminalRecord,
    ]);
    expect(groups.sent.map((entry) => entry.requirement.type), [
      DocumentType.driverLicense,
      DocumentType.schoolDriverCourse,
    ]);
    expect(groups.optional.map((entry) => entry.requirement.type), [
      DocumentType.municipalAuthorization,
    ]);
    expect(groups.all, hasLength(4));
  });

  test('an optional document stays in the optional group in any state', () {
    final groups = groupDocuments([
      TestRequirement(
        type: DocumentType.municipalAuthorization,
        state: ComplianceState.rejected,
        optional: true,
      ),
    ], testAsOf);

    expect(groups.pending, isEmpty);
    expect(groups.sent, isEmpty);
    expect(groups.optional.single.state, const DocumentRejected());
  });

  test('an optional document does not count as pending for the van', () {
    final vans = groupVehicleDocuments([
      TestVehicle(
        token: 'master',
        plate: 'RTA3B45',
        model: 'Master',
        requirements: [
          approved(DocumentType.vehicleRegistration),
          missing(DocumentType.schoolVehicleAuthorization, optional: true),
        ],
      ),
    ], testAsOf);

    expect(vans.single.pendingCount, 0);
    expect(vans.single.isUpToDate, isTrue);
  });

  test('a van with something to do comes before a van in order', () {
    final inOrder = TestVehicle(
      token: 'master',
      plate: 'RTA3B45',
      model: 'Master',
      qualified: true,
      requirements: [
        approved(DocumentType.vehicleRegistration),
        approved(DocumentType.vehicleInspection),
        approved(DocumentType.schoolVehicleAuthorization),
      ],
    );
    final withPending = TestVehicle(
      token: 'sprinter',
      plate: 'SDF4E21',
      model: 'Sprinter',
      requirements: [
        approved(DocumentType.vehicleRegistration),
        missing(DocumentType.schoolVehicleAuthorization),
        approved(
          DocumentType.vehicleInspection,
          expiresAt: DateTime(2026, 11, 29),
        ),
      ],
    );

    final vans = groupVehicleDocuments([inOrder, withPending], testAsOf);

    expect(vans.map((van) => van.vehicle.token), ['sprinter', 'master']);
    expect(vans.first.pendingCount, 2);
    expect(vans.last.isUpToDate, isTrue);
    expect(vans.first.groups.pending.map((entry) => entry.requirement.type), [
      DocumentType.vehicleInspection,
      DocumentType.schoolVehicleAuthorization,
    ]);
  });

  test('the van filter keeps only that van', () {
    final vans = groupVehicleDocuments(
      [
        TestVehicle(
          token: 'a',
          plate: 'AAA1A11',
          model: 'Sprinter',
          requirements: [],
        ),
        TestVehicle(
          token: 'b',
          plate: 'BBB2B22',
          model: 'Master',
          requirements: [],
        ),
      ],
      testAsOf,
      onlyVehicleToken: 'b',
    );

    expect(vans.map((van) => van.vehicle.token), ['b']);
  });
}
